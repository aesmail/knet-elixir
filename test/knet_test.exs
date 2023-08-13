defmodule KnetTest do
  use ExUnit.Case
  doctest Knet

  test "greets the world" do
    assert Knet.hello() == :world
  end
end
