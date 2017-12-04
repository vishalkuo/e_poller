defmodule EPoller do
  use Agent

  @moduledoc """
  This module serves to enable clients to initialize polling processes
  and have them poll on their own schedule.
  """

  @doc """
  Initializes a queue poller with the given `queue_name` and `config`. 

  Returns `{:ok, PID}`
  """
  @spec start_link(binary, function(), ExAws.SQS.receive_message_opts()) :: {:ok, PID}
  def start_link(queue_name, handler, config \\ []) do
    Agent.start_link(fn -> 
      %{:queue_name => queue_name, 
      :handler => handler,
      :config => config} 
    end)
  end

  @doc """
  Polls the queue with the config for the process assigned to `pid`

  Returns `{:ok, map}`
  """
  @spec poll(PID) :: {:ok, map}
  def poll(pid) do 
     Agent.get(pid, fn state -> 

      queue_name = state[:queue_name]
      {:ok, result} = ExAws.SQS.receive_message(queue_name, state[:config]) 
        |> ExAws.request

      result
        |> Map.get(:body)
        |> Map.get(:messages)
        |> Enum.map(fn m -> 
          state[:handler].(m[:body])
          m
        end)
        |> Enum.each(fn m -> 
          delete_message(queue_name, m) 
        end)

        :ok
    end)
  end

  defp delete_message(queue_name, body) do 
    ExAws.SQS.delete_message(queue_name, body[:receipt_handle]) 
      |> ExAws.request
  end
end
