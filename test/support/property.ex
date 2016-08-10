defmodule Property do
  ExUnit.plural_rule("property", "properties")
  # -define(FORCE(X), (X)()).
  # -define(DELAY(X), fun() -> X end).
  # -define(LAZY(X), proper_types:lazy(?DELAY(X))).
  # -define(SIZED(SizeArg,Gen), proper_types:sized(fun(SizeArg) -> Gen end)).
  # -define(LET(X,RawType,Gen), proper_types:bind(RawType,fun(X) -> Gen end,false)).
  # -define(SHRINK(Gen,AltGens),
  #  proper_types:shrinkwith(?DELAY(Gen),?DELAY(AltGens))).
  # -define(LETSHRINK(Xs,RawType,Gen),
  #  proper_types:bind(RawType,fun(Xs) -> Gen end,true)).
  # -define(SUCHTHAT(X,RawType,Condition),
  #  proper_types:add_constraint(RawType,fun(X) -> Condition end,true)).
  # -define(SUCHTHATMAYBE(X,RawType,Condition),
  #  proper_types:add_constraint(RawType,fun(X) -> Condition end,false)).

  # -define(SUCHTHAT(X,RawType,Condition),
  #  proper_types:add_constraint(RawType,fun(X) -> Condition end,true)).
  def suchthat(raw_type, condition) do
    :proper_types.add_constraint(raw_type, condition, true)
  end

  defmacro property(message, var \\ quote(do: _), contents) do
    contents =
      case contents do
        [do: block] ->
          quote do
            import :proper
            import :proper_types

            property = fn ->
              unquote(block)
            end

            {:ok, pid} = Agent.start_link fn -> [] end

            output_fn = fn (string, terms) ->
              Agent.update pid, fn state ->
                [{string, terms} |state]
              end
            end

            passed = quickcheck(on_output(output_fn, property.()))

            output = Agent.get(pid, &(&1))

            message = Enum.join Enum.map(output, fn {x, y}->
              :io_lib.format(x, y)
            end)

            Agent.stop pid, :normal

            assert passed, message: message

            :ok
          end
        _ ->
          quote do
            try(unquote(contents))
            :ok
          end
      end

    var      = Macro.escape(var)
    contents = Macro.escape(contents, unquote: true)

    quote bind_quoted: [var: var, contents: contents, message: message] do
      name = ExUnit.Case.register_test(__ENV__, :property, message, [])
      def unquote(name)(unquote(var)), do: unquote(contents)
    end
  end

  defmacro __using__(_) do
    quote do
      import Property
      require Property
    end
  end
end
