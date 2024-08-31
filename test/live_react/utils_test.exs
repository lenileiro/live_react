defmodule LiveReact.UtilsTest do
  use ExUnit.Case, async: true
  alias LiveReact.Utils

  test "encode_props/1 encodes props correctly" do
    props = %{
      string: "value",
      number: 42,
      boolean: true,
      list: [1, 2, 3],
      map: %{nested: "map"},
      func: fn -> "function" end
    }

    encoded = Utils.encode_props(props)

    assert encoded["string"] == "value"
    assert encoded["number"] == 42
    assert encoded["boolean"] == true
    assert encoded["list"] == [1, 2, 3]
    assert encoded["map"] == %{"nested" => "map"}
    assert {:function, _} = encoded["func"]
  end

  test "decode_props/1 decodes props correctly" do
    props = %{
      "string" => "value",
      "number" => 42,
      "boolean" => true,
      "list" => [1, 2, 3],
      "map" => %{"nested" => "map"},
      "func" => {:function, "fn -> :ok end"}
    }

    decoded = Utils.decode_props(props)

    assert decoded.string == "value"
    assert decoded.number == 42
    assert decoded.boolean == true
    assert decoded.list == [1, 2, 3]
    assert decoded.map == %{nested: "map"}
    assert is_function(decoded.func)
  end
end
