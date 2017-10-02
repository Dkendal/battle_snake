defmodule Bs.Game.PubSub do
  def broadcast(topic, message) when is_integer(topic) do
    Phoenix.PubSub.broadcast(__MODULE__, to_string(topic), message)
  end

  def broadcast!(topic, message) when is_integer(topic) do
    Phoenix.PubSub.broadcast!(__MODULE__, to_string(topic), message)
  end

  def broadcast_from(from_pid, topic, message) when is_integer(topic) do
    Phoenix.PubSub.broadcast_from(__MODULE__, from_pid, to_string(topic), message)
  end

  def broadcast_from!(from_pid, topic, message) when is_integer(topic) do
    Phoenix.PubSub.broadcast_from!(__MODULE__, from_pid, to_string(topic), message)
  end

  def subscribe(topic, opts \\ [])

  def subscribe(topic, opts) when is_integer(topic) do
    Phoenix.PubSub.subscribe(__MODULE__, to_string(topic), opts)
  end

  def subscribe(topic, opts) when is_binary(topic) do
    Phoenix.PubSub.subscribe(__MODULE__, topic, opts)
  end

  def unsubscribe(pid, topic) when is_integer(topic) do
    Phoenix.PubSub.unsubscribe(__MODULE__, pid, to_string(topic))
  end

  def unsubscribe(pid, topic) when is_binary(topic) do
    Phoenix.PubSub.unsubscribe(__MODULE__, pid, topic)
  end
end
