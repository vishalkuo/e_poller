defmodule EPoller do
  @moduledoc """
  Documentation for EPoller.
  """

  @doc """
  Hello world.

  ## Examples

      iex> EPoller.hello
      :world

  """

  def poll do
    ExAws.SQS.list_queues()
  end
end
