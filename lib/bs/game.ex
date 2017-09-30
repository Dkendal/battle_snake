defmodule Bs.Game do
  alias Bs.Game.PubSub
  alias Bs.Game.Registry
  alias Bs.Game.Server
  alias __MODULE__
  use GenServer

  defmodule Command, do: defstruct [:name, :data]

  @type server :: GenServer.server

  @moduledoc """
  The Game is a GenServer that handles running a single Bs match.
  """

  def start_link(args, opts \\ [])

  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def get_game_state(pid) do
    GenServer.call(pid, :get_game_state)
  end

  def next(pid) do
    GenServer.call(pid, :next)
  end

  def pause(pid) do
    GenServer.call(pid, :pause)
  end

  def prev(pid) do
    GenServer.call(pid, :prev)
  end

  def resume(pid) do
    GenServer.call(pid, :resume)
  end

  @spec alive?(number) :: boolean
  def alive?(id) do
    case Registry.lookup(id) do
      [_] ->
        true

      _ ->
        false
    end
  end

  @doc "Replay the current game."
  @spec replay(Game.server) :: term
  def replay(pid) do
    GenServer.call(pid, :replay)
  end

  defdelegate handle_call(request, from, state), to: Server
  defdelegate handle_cast(request, state), to: Server
  defdelegate handle_info(request, state), to: Server
  defdelegate init(args), to: Server

  def find! name do
    case find name do
      {:ok, pid} when is_pid pid ->
        pid

      {:error, {:already_started, pid}} when is_pid pid ->
        pid

      {:error, err} ->
        raise err
    end
  end

  def find name do
    fn ->
      BsWeb.GameForm |> BsRepo.get(name)
    end
    |> Registry.lookup_or_create(name)
  end

  defdelegate name(id), to: Registry, as: :via

  defdelegate subscribe(name), to: PubSub
end
