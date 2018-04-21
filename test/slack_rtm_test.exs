defmodule SlackRtmTest do
  use ExUnit.Case
  doctest SlackRtm

  test "greets the world" do
    assert SlackRtm.hello() == :world
  end
end
