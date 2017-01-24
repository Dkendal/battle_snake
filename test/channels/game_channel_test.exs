defmodule BattleSnake.GameChannelTest do
  use BattleSnake.ChannelCase

  alias BattleSnake.{
    GameChannel,
    GameForm,
    GameServer,
    SnakeForm,
  }

  @snake_form %SnakeForm{url: "localhost:3000"}
  @game_form %GameForm{snakes: [@snake_form], delay: 0}

  setup [:teardown]

  describe "BattleSnake.GameChannel.join/3" do
    test "returns OK and the socket" do
      game_id = create_game_form().game_id
      assert {:ok, _, %Phoenix.Socket{}} = "user_id"
      |> socket(%{})
      |> subscribe_and_join(GameChannel, "game:#{game_id}")
    end

    test "assigns the game server pid" do
      %{socket: socket} = create_game_form() |> join_topic()
      assert %{game_server_pid: game_server_pid} = socket.assigns
      assert is_pid game_server_pid
    end

    test "assigns the game form" do
      %{socket: socket} = create_game_form() |> join_topic()
      assert %{game_form: %GameForm{}} = socket.assigns
    end

    test "game starts suspended" do
      create_game_form() |> join_topic()
      assert_push "state_change", %{data: :suspend}
    end

    test "joins already running games" do
      id = create_game_form().game_id
      {:ok, game_server} = GameServer.Registry.create(id)

      assert {:ok, _, socket} = "user_id"
      |> socket(%{})
      |> subscribe_and_join(GameChannel, "game:#{id}")

      assert game_server == socket.assigns.game_server_pid
    end

    test "the created game server starts suspended" do
      %{socket: socket} = create_game_form() |> join_topic()
      game_server_pid = socket.assigns.game_server_pid
      assert {:suspend, %GameServer.State{}} = :sys.get_state(game_server_pid)
    end

    test "joining a game that doesn't exist returns an error" do
      assert {:error, %Mnesia.RecordNotFoundError{}} = "user_id"
      |> socket(%{})
      |> subscribe_and_join(GameChannel, "game:fake-game-server")
    end
  end

  describe "BattleSnake.GameChannel.handle_info(:after_join, _)" do
    setup [:create_game_form, :join_topic]

    test "pushes a state change", %{socket: socket} do
      assert {:noreply, socket} == GameChannel.handle_info(:after_join, socket)
      assert_push "state_change", data
      assert %{data: :suspend} == data
    end
  end

  describe "GameChannel.handle_info({:render, _}, _)" do
    setup [:create_game_form, :join_topic]

    test "broadcasts a rendered version of the game world", %{socket: socket} do
      state = %BattleSnake.GameServer.State{
        world: %BattleSnake.World{}}
      assert {:noreply, _} = GameChannel.handle_info({:render, state}, socket)
      assert_broadcast "tick", %{html: html}
      assert html =~ "</svg>"
    end
  end

  describe "PUSH start" do
    setup [:create_game_form, :join_topic]

    test "replies with ok", %{socket: socket} do
      assert_reply push(socket, "start"), :ok
    end

    test "broadcasts a state change event", %{socket: socket} do
      assert_push "state_change", %{data: :suspend}
      assert_reply push(socket, "start"), :ok
    end

    test "broadcasts a tick", %{socket: socket} do
      flush()
      push(socket, "start")
      assert_broadcast "tick", %{html: _}, 500
    end
  end

  describe "PUSH prev" do
    setup [:create_game_form, :join_topic]

    test "responds with ok", %{socket: socket} do
      ref = push socket, "prev"
      assert_reply ref, :ok
    end
  end

  describe "PUSH pause" do
    setup [:create_game_form, :join_topic]

    test "responds with OK", %{socket: socket} do
      ref = push socket, "pause"
      assert_reply ref, :ok
    end
  end

  describe "PUSH stop" do
    setup [:create_game_form, :join_topic]

    test "responds with OK", %{socket: socket} do
      ref = push socket, "stop"
      assert_reply ref, :ok
    end
  end

  describe "PUSH next" do
    setup [:create_game_form, :join_topic]

    test "steps through a single move", %{socket: socket} do
      flush()
      push socket, "next"
      assert_broadcast "tick", _
      refute_broadcast "tick", _, 10
    end
  end

  describe "BattleSnake.GameChannel.load_game_server_pid/1" do
    test "assigns an existing game server" do
      %{game_id: game_id, game_form: game_form} = create_game_form()

      {:ok, game_server_pid} = GameServer.Registry.create(game_id)

      assert {:ok, ^game_server_pid} =
        GameChannel.load_game_server_pid(game_form)

      assert is_pid game_server_pid
      assert %{active: 1} = Supervisor.count_children(GameServer.Supervisor)
    end

    test "starts a new game server" do
      %{game_form: game_form} = create_game_form()

      assert {:ok, game_server_pid} =
        GameChannel.load_game_server_pid(game_form)

      assert is_pid game_server_pid
      assert %{active: 1} = Supervisor.count_children(GameServer.Supervisor)
    end
  end

  def join_topic(context \\ %{}) do
    %{game_id: game_id} = context
    {:ok, _, socket} = socket("user_id", %{})
    |> subscribe_and_join(GameChannel, "game:#{game_id}")

    Map.put(context, :socket, socket)
  end

  def create_game_form(context \\ %{}) do
    game_form = @game_form
    |> GameForm.changeset
    |> Ecto.Changeset.apply_changes
    |> GameForm.save

    context
    |> Map.put(:game_form, game_form)
    |> Map.put(:game_id, game_form.id)
  end

  def teardown c do
    on_exit fn ->
      BattleSnake.GameServerTesting.teardown
    end
    c
  end

  def flush(c \\ :ok) do
    receive do
      _ ->
        flush()
    after 0 ->
        c
    end
  end
end
