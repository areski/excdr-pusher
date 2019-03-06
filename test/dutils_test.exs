defmodule DUtilsTest do
  use ExUnit.Case, async: true
  alias DUtils

  test "test get current time" do
    # assert DUtils.current_time() < ~T[04:00:00.004] or DUtils.current_time() > ~T[04:00:00.004]
    assert Time.compare(DUtils.current_time(), ~T[04:00:00.004]) == :lt or
             Time.compare(DUtils.current_time(), ~T[04:00:00.004]) == :gt
  end
end
