alias Bs.Event
alias Bs.Game.PubSub

defmodule Bs.Notification do
  require Logger

  @moduledoc ~S"""
  Convience module for sending formatted events about a running game.
  """

  def broadcast!(id, opts) do
    name = Keyword.fetch!(opts, :name)
    rel = Keyword.fetch!(opts, :rel)
    data = Keyword.fetch!(opts, :data)
    view = Keyword.get(opts, :view)

    Logger.info("[Notification] #{id}//#{name}")

    data =
      if view do
        Phoenix.View.render(BsWeb.EventView, view, data)
      else
        data
      end

    PubSub.broadcast!(id, %Event{
      name: name,
      rel: rel,
      data: data
    })
  end
end
