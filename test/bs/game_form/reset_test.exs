defmodule BsWeb.GameForm.ResetTest do
  alias BsWeb.GameForm.Reset

  use Bs.Case, async: false

  @game_form %BsWeb.GameForm{
    delay: 100,
    max_food: 1,
    height: 10,
    width: 20
  }

  @world %Bs.World{
    width: 20,
    height: 10
  }

  @snake_form %BsWeb.SnakeForm{
    url: "http://example.com"
  }

  @snake %Bs.Snake{}

  @initialized_game_form put_in(@game_form.world, @world)

  @game_form_with_snakes put_in(@initialized_game_form.snakes, [@snake_form])

  @world_with_snakes put_in(@world.snakes, [@snake])

  describe "Reset.init_world/1" do
    @init_world Reset.init_world(@game_form)

    test "returns a BsWeb.GameForm struct" do
      assert(match?(%BsWeb.GameForm{}, @init_world))
    end

    test "sets game_form.world.width based on config" do
      assert(@init_world.world.width == 20)
    end

    test "sets game_form.world.height based on config" do
      assert(@init_world.world.height == 10)
    end

    test "sets game_form.world.max_food based on config" do
      assert(@init_world.world.max_food == 1)
    end

    test "empties game_form.world.snakes" do
      assert(@init_world.world.snakes == [])
    end
  end

  describe "Reset.load_snakes/2" do
    @load_snakes Reset.load_snakes(@game_form_with_snakes)
    @loaded_snake @load_snakes.world.snakes |> hd()

    @unhealthy_snakes_game Reset.load_snakes(
      @game_form_with_snakes,
      fn(_snake_form, _game_form) ->
        %Bs.Api.Response{parsed_response: {:error, :test}}
      end)

    @unhealthy_snake @unhealthy_snakes_game.world.snakes |> hd()

    test "adds all snakes from the snake-forms in game_form.snakes" do
      Reset.load_snakes(@game_form_with_snakes)
      assert(@load_snakes.world.snakes |> length() == 1)
    end

    test "marks loaded snakes as healthy" do
      assert(match? %Bs.Snake{}, @loaded_snake)
      assert(@loaded_snake.health == :ok)
    end

    test "adds snakes that failed to load" do
      assert(@unhealthy_snakes_game.snakes |> length() == 1)
    end

    test "snakes that failed to load are marked as unhealthy" do
      assert(match? %Bs.Snake{}, @unhealthy_snake)
      assert(@unhealthy_snake.health == {:error, :test})
    end
  end

  describe "Reset.reset_game_form/1" do
    @reset_game_form Reset.reset_game_form(@game_form_with_snakes)

    test "adds snakes to the world based on the config" do
      assert(@reset_game_form.world.snakes |> length() == 1)
    end

    test "adds food to the world based on the config" do
      assert(@reset_game_form.world.food |> length() == 1)
    end
  end

  describe "Reset.position_snakes/1" do
    @position_snakes Reset.position_snakes(@world_with_snakes)

    test "returns a world" do
      assert(match?(%Bs.World{}, @position_snakes))
    end

    test "still contains the same number of snakes" do
      assert(@position_snakes.snakes |> length() == 1)
    end

    test "gives each snake initial starting coordinates" do
      for snake <- @position_snakes.snakes do
        assert([p, p, p] = snake.coords)
        assert(%Bs.Point{} = p)
      end
    end
  end
end
