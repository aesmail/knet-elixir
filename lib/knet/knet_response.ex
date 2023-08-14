defmodule Knet.Response do
  @moduledoc false

  def parse({:ok, %Finch.Response{status: 200} = response}) do
    response.body
    |> then(fn body -> "<response>#{body}</response>" end)
    |> XmlToMap.naive_map()
    |> parse_result()
  end

  def parse({_status, _response}), do: {:error, %{"result" => "KNET server error"}}

  defp parse_result(%{"response" => %{"error_code_tag" => _} = result}) do
    {:error, result}
  end

  defp parse_result(%{"response" => %{"result" => _} = result}) do
    {:ok, result}
  end
end
