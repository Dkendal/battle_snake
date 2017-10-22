defmodule Mix.Tasks.Phx.Gen.View do
  @app BsWeb

  def run(opts) do
    path = path(opts)

    content = gen(opts)

    path
    |> Path.dirname()
    |> File.mkdir_p!()

    :ok = File.write(path, content)

    """
    Wrote template to #{path}:

    #{content}
    """
    |> Mix.Shell.IO.info()
  end

  def module_name(context, model) do
    String.to_atom("#{@app}.#{context}.#{model}View")
  end

  def path([context, model, _]) do
    path =
      "#{@app}.Views.#{context}.#{model}View"
      |> String.to_atom()
      |> Macro.underscore()

    Path.join(["lib", path]) <> ".ex"
  end

  def gen([context, model, struct]) do
    module = module_name(context, model)
    key = String.to_atom(Macro.underscore(model))
    atom = String.to_existing_atom("Elixir.#{struct}")
    fields = Map.keys(struct(atom))
    assign = Macro.var(key, nil)

    dict =
      for f <- fields, to_string(f) =~ ~r"^[a-zA-Z]", do: {
        f,
        {{:., [], [assign, f]}, [], []}
      }

    dict = {:%{}, [], dict}

    quote do
      defmodule unquote(module) do
        use unquote(@app), :view

        def render("show.json", %{unquote(key) => unquote(assign)}) do
          unquote(dict)
        end
      end
    end
    |> Macro.to_string()
  end
end
