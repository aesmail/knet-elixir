defmodule Knet do
  @moduledoc """
  Documentation for `Knet`.
  """

  @doc """
  Takes a map of payment details and returns a KNET payment link.
  The `payment_details` map should contain the following required keys:
  - `knet_username`
  - `knet_password`
  - `knet_key`
  - `amount`
  - `response_url`
  - `error_url`
  - `track_id`

  The following keys are optional:
  - `knet_url` (defaults to https://kpay.com.kw/kpg/PaymentHTTP.htm)
  - `currency_code` (defaults to 414)
  - `lang`. Could be ENG or AR (defaults to ENG)
  - `udf1` to `udf5` (user defined fields). These are optional and will be returned back to you in the response.

  """
  @spec get_payment_link(map()) :: String.t()
  def get_payment_link(payment_details) do
    payment_details
    |> get_payment_params()
    |> encrypt_params(payment_details)
    |> get_payment_url(payment_details)
  end

  defp get_payment_params(payment_details) do
    %{
      "id" => Map.get(payment_details, "knet_username"),
      "password" => Map.get(payment_details, "knet_password"),
      "amt" => Map.get(payment_details, "amount"),
      "currencycode" => Map.get(payment_details, "currency_code", "414"),
      "action" => "1",
      "langid" => Map.get(payment_details, "lang", "ENG"),
      "responseURL" => Map.get(payment_details, "response_url"),
      "errorURL" => Map.get(payment_details, "error_url"),
      "trackid" => Map.get(payment_details, "track_id"),
      "udf1" => Map.get(payment_details, "udf1"),
      "udf2" => Map.get(payment_details, "udf2"),
      "udf3" => Map.get(payment_details, "udf3"),
      "udf4" => Map.get(payment_details, "udf4"),
      "udf5" => Map.get(payment_details, "udf5")
    }
  end

  defp encrypt_params(params, payment_details) do
    params =
      params
      |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
      |> Enum.join("&")

    block_size = 16
    pad = block_size - rem(String.length(params), block_size)
    padded_params = params <> String.duplicate(List.to_string([pad]), pad)

    api_key = Map.get(payment_details, "knet_key")

    :crypto.crypto_one_time(:aes_128_cbc, api_key, api_key, padded_params, true)
    |> Base.encode16(case: :lower)
  end

  defp get_payment_url(encrypted_data, payment_details) do
    knet_url = Map.get(payment_details, "knet_url", "https://kpay.com.kw/kpg/PaymentHTTP.htm")
    knet_username = Map.get(payment_details, "knet_username")
    response_url = Map.get(payment_details, "response_url")
    error_url = Map.get(payment_details, "error_url")

    "#{knet_url}?param=paymentInit&trandata=#{encrypted_data}&tranportalId=#{knet_username}&responseURL=#{response_url}&errorURL=#{error_url}"
  end
end
