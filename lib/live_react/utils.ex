defmodule LiveReact.Utils do
  def encode_props(props) do
    props
    |> Enum.map(fn {k, v} -> {to_string(k), encode_prop_value(v)} end)
    |> Enum.into(%{})
  end

  defp encode_prop_value(%{} = map) do
    encode_props(map)
  end

  defp encode_prop_value(value) when is_function(value) do
    {:function, inspect(value)}
  end

  defp encode_prop_value(value) do
    value
  end

  def decode_props(props) do
    props
    |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), decode_prop_value(v)} end)
    |> Enum.into(%{})
  end

  defp decode_prop_value(%{} = map) do
    decode_props(map)
  end

  defp decode_prop_value({:function, _str}) do
    fn -> nil end
  end

  defp decode_prop_value(value) do
    value
  end
end
