defmodule EPoller.Poller do
  use Agent

  @spec start_link(binary, ExAws.SQS.receive_message_opts()) :: {:ok, PID}

  # Should define custom names, maybe multiple processes in the same threadspace will poll
  def start_link(queue_name, config \\ []) do
    Agent.start_link(fn -> %{:queue_name => queue_name, :config => config} end, name: __MODULE__)
  end

  def poll() do 
    Agent.get(__MODULE__, fn m -> 
      ExAws.SQS.receive_message(m[:queue_name]) |> ExAws.request
    end)
  end
end
