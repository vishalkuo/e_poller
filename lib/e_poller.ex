defmodule EPoller do
  use Agent

  @moduledoc """
  Documentation for EPoller.
  """

  @spec start_link(binary, ExAws.SQS.receive_message_opts()) :: {:ok, PID}
  def start_link(queue_name, config \\ []) do
    Agent.start_link(fn -> %{:queue_name => queue_name, :config => config} end)
  end

  @spec poll(PID) :: {:ok, map()}
  def poll(pid) do 
     Agent.get(pid, fn m -> 
      {:ok, result} = ExAws.SQS.receive_message(m[:queue_name]) 
        |> ExAws.request

      mapped_result = result
        |> Map.get(:body)
        |> Map.get(:messages)
        |> Enum.map(fn m -> m[:body] end)

      {:ok, mapped_result}
    end)
  end
end
