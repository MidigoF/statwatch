defmodule StatwatchTest do
  use ExUnit.Case
  doctest Statwatch

  test "greets the world" do
    assert Statwatch.hello() == :world
  end
end
