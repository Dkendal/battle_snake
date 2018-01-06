defmodule BsWeb.GameView do
  alias BsRepo.GameForm

  use BsWeb, :view

  require GameForm

  defmacro snake_assets do
    root = File.cwd!()
    img_dir = Path.join(root, "assets/static")

    Path.join(img_dir, "images/snake/{head,tail}/*.svg")
    |> Path.wildcard()
    |> Enum.map(fn path ->
      rel_path = Path.relative_to(path, img_dir)

      id =
        rel_path
        |> Path.relative_to("images/")
        |> Path.rootname(".svg")
        |> String.replace("/", "-")

      [id: id, src: rel_path]
    end)
  end

  def snake_img_tags(conn) do
    snake_assets()
    |> Enum.map(fn asset ->
      content_tag(
        :object,
        "",
        id: asset[:id],
        data: static_path(conn, "/#{asset[:src]}"),
        charset: "utf-8",
        type: "image/svg+xml"
      )
    end)
  end

  def bs_js_object(assigns, _ \\ %{}) do
    Phoenix.View.render(BsWeb.BoardConfigView, "show.json", assigns)
    |> Poison.encode!()
  end
end
