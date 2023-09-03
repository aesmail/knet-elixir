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

  def decrypt_payment_response(params) do
    key = Map.get(params, "knet_key")
    data = Map.get(params, "trandata")
    decoded = Base.decode16!(data)
    decrypted_data = :crypto.crypto_one_time(:aes_128_cbc, key, key, decoded, false)
    <<x::utf8>> = binary_part(decrypted_data, String.length(decrypted_data) - 1, 1)

    # pad_length = String.slice(decrypted_data, String.length(decrypted_data) - x, x) |> String.length()

    details =
      decrypted_data
      |> String.slice(0, String.length(decrypted_data) - x)
      |> URI.decode_query()
      |> process_response_details()

    {:ok, details}
  end

  defp process_response_details(params) do
    status =
      case Map.get(params, "result") do
        "CAPTURED" -> :paid
        "NOT CAPTURED" -> :failed
        "CANCELED" -> :cancelled
        _ -> :error
      end

    %{
      status: status,
      paid?: status == :paid,
      failed?: status == :failed,
      cancelled?: status == :cancelled,
      amount: Map.get(params, "amt") |> Decimal.new(),
      payment_id: Map.get(params, "paymentid"),
      post_date: Map.get(params, "postdate"),
      track_id: Map.get(params, "trackid"),
      trx_id: Map.get(params, "tranid"),
      reference: Map.get(params, "ref"),
      auth_code: Map.get(params, "auth"),
      raw: params
    }
  end
end
