defmodule BattleSnake.Game.PubSub do
  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(__MODULE__, topic, message)
  end

  def broadcast!(topic, message) do
    Phoenix.PubSub.broadcast!(__MODULE__, topic, message)
  end

  def broadcast_from(from_pid, topic, message) do
    Phoenix.PubSub.broadcast_from(__MODULE__, from_pid, topic, message)
  end

  def broadcast_from!(from_pid, topic, message) do
    Phoenix.PubSub.broadcast_from!(__MODULE__, from_pid, topic, message)
  end

  def subscribe(topic, opts \\ []) do
    Phoenix.PubSub.subscribe(__MODULE__, topic, opts)
  end

  def unsubscribe(pid, topic) do
    Phoenix.PubSub.unsubscribe(__MODULE__, pid, topic)
  end
end
