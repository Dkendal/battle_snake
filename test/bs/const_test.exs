defmodule Bs.ConstTest do
  alias Bs.Const
  use Bs.Case, async: true

  test "#heads returns the list of head svgs" do
    assert Const.heads == [
      "bendr",
      "dead",
      "fang",
      "pixel",
      "regular",
      "safe",
      "sand-worm",
      "shades",
      "smile",
      "tongue"
    ]
  end

  test "#tails returns the list of tail svgs" do
    assert Const.heads == [
      "bendr",
      "dead",
      "fang",
      "pixel",
      "regular",
      "safe",
      "sand-worm",
      "shades",
      "smile",
      "tongue"
    ]
  end
end
