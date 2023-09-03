defmodule Knet.Request do
  @moduledoc false

  def get_payment_link(payment_details) do
    payment_details
    |> get_payment_params()
    |> encrypt_params(payment_details)
    |> get_payment_url(payment_details)
  end

  def fetch_transaction(params) do
    params
    |> get_transaction_params()
    |> start_transaction_fetch_request(params)
  end

  defp start_transaction_fetch_request(request_xml, params) do
    url = Map.get(params, "knet_url", "https://kpay.com.kw/kpg/tranPipe.htm?param=tranInit")

    Finch.build(:post, url, [], request_xml)
    |> Finch.request(KnetFinch)
    |> Knet.Response.parse()
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
      "udf5" => Map.get(payment_details, "udf5"),
      "udf6" => Map.get(payment_details, "udf6"),
      "udf7" => Map.get(payment_details, "udf7"),
      "udf8" => Map.get(payment_details, "udf8"),
      "udf9" => Map.get(payment_details, "udf9"),
      "udf10" => Map.get(payment_details, "udf10")
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

  defp get_transaction_params(params) do
    ~s{
      <hash>
        <request>
          <id>#{Map.get(params, "knet_username")}</id>
          <password>#{Map.get(params, "knet_password")}</password>
          <action>8</action>
          <trackid>#{Map.get(params, "track_id")}</trackid>
          <transId>#{Map.get(params, "trans_id")}</transId>
          <amt>#{Map.get(params, "amount")}</amt>
          <udf5>#{Map.get(params, "udf5", "TrackID")}</udf5>
        </request>
      </hash>
    }
  end

  defp get_payment_url(encrypted_data, payment_details) do
    knet_url = Map.get(payment_details, "knet_url", "https://kpay.com.kw/kpg/PaymentHTTP.htm")
    knet_username = Map.get(payment_details, "knet_username")
    response_url = Map.get(payment_details, "response_url")
    error_url = Map.get(payment_details, "error_url")

    "#{knet_url}?param=paymentInit&trandata=#{encrypted_data}&tranportalId=#{knet_username}&responseURL=#{response_url}&errorURL=#{error_url}"
  end
end
