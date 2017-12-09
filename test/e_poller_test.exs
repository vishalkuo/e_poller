defmodule EPollerTest do
  use ExUnit.Case, async: false
  doctest EPoller

  import Mock 
  
  setup do
    {:ok, queue_name: "test_queue"}
  end

  test "Can poll empty queues", state do
    with_mock ExAws, 
      [request: fn
        (%{action: :receive_message}, _) -> {:ok, %{body: %{messages: []}}} 
        (%{action: :delete_message}, _) -> raise "Should not call delete"
      end] do
      {:ok, poller} =  EPoller.start_link(state[:queue_name], fn x -> x end)
      EPoller.poll(poller)
    end
  end

  test "Can handle single message", state do 
    text = "sample_message"
    msg = sample_messages([text])
    with_mock ExAws, 
      [request: fn
        (%{action: :receive_message}, _) -> msg
        (%{action: :delete_message}, _) -> :ok
      end] do
      {:ok, poller} =  EPoller.start_link(state[:queue_name], fn x -> x end)
      EPoller.poll(poller)
      
      assert called ExAws.request(
        %{action: :delete_message,
          path: "/" <> state[:queue_name],
          params: %{"ReceiptHandle" => get_rec_handle(text)}},
        :_)
    end
  end

  test "Can handle multiple messages", state do 
    text1 = "sample_message1"
    text2 = "sample_message2"
    msgs = sample_messages([text1, text2])
    with_mock ExAws, 
      [request: fn
        (%{action: :receive_message}, _) -> msgs
        (%{action: :delete_message}, _) -> :ok
      end] do
      {:ok, poller} =  EPoller.start_link(state[:queue_name], fn x -> x end)

      EPoller.poll(poller)

      assert called ExAws.request(
        %{action: :delete_message,
          path: "/" <> state[:queue_name],
          params: %{"ReceiptHandle" => get_rec_handle(text1)}},
        :_)
      assert called ExAws.request(
        %{action: :delete_message,
          path: "/" <> state[:queue_name],
          params: %{"ReceiptHandle" => get_rec_handle(text2)}},
        :_)
    end
  end

  test "Can handle failed handler", state do 
    text = "sample_message"
    msg = sample_messages([text])

    with_mock ExAws, 
      [request: fn
        (%{action: :receive_message}, _) -> msg
        (%{action: :delete_message}, _) -> 
          raise "Should not call delete"
      end] do
      {:ok, poller} =  EPoller.start_link(state[:queue_name], fn _ -> 
        raise "Intended error"
      end)

      EPoller.poll(poller)
    end
  end

  
  defp sample_messages(bodies) do
    formatted_bodies = bodies 
      |> Enum.map(fn body -> 
        %{body: body, receipt_handle: get_rec_handle(body)}
      end)
  
    {:ok, %{body: %{messages: formatted_bodies}}}
  end

  defp get_rec_handle(body) do
    body <> "rec_handle"
  end
end
