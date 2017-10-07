defmodule Bs.Game do
  alias Bs.Game.PubSub
  alias Bs.Game.Registry
  alias Bs.Game.Supervisor
  alias Bs.Game.Server

  use GenServer

  import GenServer, only: [call: 2]

  defdelegate handle_call(request, from, state), to: Server
  defdelegate handle_cast(request, state), to: Server
  defdelegate handle_info(request, state), to: Server
  defdelegate init(args), to: Server
  defdelegate name(id), to: Registry, as: :via
  defdelegate subscribe(name), to: PubSub

  @moduledoc """
  The Game is a GenServer that handles running a single Bs match.
  """

  def start_link(args, opts \\ [])

  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def get_game_state(id) when is_binary(id) do
    id |> do_ensure_started |> call(:get_game_state)
  end

  def next(id) when is_binary(id) do
    id |> do_ensure_started |> call(:next)
  end

  def pause(id) when is_binary(id) do
    id |> dispatch(&call &1, :pause)
  end

  def prev(id) when is_binary(id) do
    id |> dispatch(&call &1, :prev)
  end

  def stop(id, reason \\ :normal)
  def stop(id, reason) when is_binary(id) do
    id |> dispatch(&GenServer.stop &1, reason)
  end

  def restart(id) when is_binary(id) do
    case ensure_started id do
      {:ok, pid, :already_started} ->
        ref = Process.monitor pid

        GenServer.stop pid

        receive do
          {:DOWN, ^ref, _, ^pid, :normal} -> :ok
        end

        ensure_started id

      {:ok, _pid, :started} ->
        :ok
    end
  end

  def resume(id) when is_binary id do
    id |> do_ensure_started |> call(:resume)
  end

  def alive?(id) do
    case Registry.lookup(id) do
      [_] ->
        true

      _ ->
        false
    end
  end

  def find! name do
    case lookup_or_create name do
      {:ok, pid} when is_pid pid ->
        pid

      {:error, {:already_started, pid}} when is_pid pid ->
        pid

      {:error, err} ->
        {:error, err}
    end
  end

  def lookup_or_create(id) when is_binary(id) do
    case Registry.lookup(id) do
      [{pid, _}] ->
        {:ok , pid}
      _ ->
        start(id)
    end
  end

  def ensure_started id do
    with [] <- Registry.lookup(id),
         {:ok, pid} <- start(id)
    do
      {:ok, pid, :started}
    else
      [{pid, _}]->
        {:ok, pid, :already_started}

      {:error, {:already_started, pid}} ->
        {:ok, pid, :already_started}
    end
  end

  def start(id) when is_binary(id) do
    Elixir.Supervisor.start_child(
      Supervisor,
      [id, [name: {:via, Elixir.Registry, {Registry, id}}]]
    )
  end

  defp do_ensure_started id do
    {:ok, pid, _} = ensure_started(id)
    pid
  end

  defp dispatch(id, fun) when is_binary id and is_function fun  do
    Registry.dispatch id, fn [{pid, _}] ->
      apply fun, [pid]
    end
  end
end
