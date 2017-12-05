defmodule EPoller do
  use Agent

  @moduledoc """
  This module serves to enable clients to initialize polling processes
  and have them poll on their own schedule.
  """

  @doc """
  Initializes a queue poller with the given `queue_name``, `message_handler`, and `config`. 

  Returns `{:ok, PID}`
  """
  @spec start_link(binary, function(), list) :: {:ok, PID}
  def start_link(
    queue_name, 
    handler, 
    config \\ []) do
    formatted_conf = EPoller.Config.get_full_config(config)
    Agent.start_link(fn -> 
      %{:queue_name => queue_name,
      :handler => handler,
      :config => formatted_conf} 
    end)
  end

  @doc """
  Polls the queue with the config for the process assigned to `pid`. 

  For each message in the polling result this function: 
  1. Calls the handler on that message
  2. Deletes the message from the queue (provided the handler doesn't throw an exception)

  Returns `{:ok, map}`
  """
  @spec poll(PID) :: {:ok, map}
  def poll(pid) do 
     Agent.get(pid, fn state -> 
      queue_name = state[:queue_name]
      sqs_conf = state[:config][:sqs_conf]
      region = state[:config][:region]

      {:ok, result} = ExAws.SQS.receive_message(queue_name, sqs_conf) 
        |> ExAws.request(region: region)

      result
        |> Map.get(:body)
        |> Map.get(:messages)
        |> Enum.each(fn m -> 
          state[:handler].(m[:body])
          delete_message(queue_name, m) 
        end)
        
        :ok
    end, 30_000)
  end

  defp delete_message(queue_name, body) do 
    ExAws.SQS.delete_message(queue_name, body[:receipt_handle]) 
      |> ExAws.request
  end
end
