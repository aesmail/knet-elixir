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
    Knet.Request.get_payment_link(payment_details)
  end

  @doc """
  Takes a map of transaction details and returns the transaction details from KNET.

  The `params` map should contain the following required keys:
  - `knet_username`
  - `knet_password`
  - `track_id` (the same `track_id` used in the payment link)
  - `amount`


  The following keys are optional:
  - `knet_url` (defaults to https://kpay.com.kw/kpg/tranPipe.htm?param=tranInit)
  - `trans_id` (defaults to the `track_id` value)
  - `udf5` (defaults to "TrackID")


  This function returns:
  - `{:ok, map()}` if the transaction details were fetched successfully.
  - `{:error, map()}` if the transaction details could not be obtained successfully.


  Example of a successful attempt to retrieve an existing transaction:

  ```
  {:ok,
   %{
     "amt" => "9.500",
     "auth" => "887766",
     "authRespCode" => "00",
     "avr" => "N",
     "payid" => "123456789",
     "postdate" => "0814",
     "ref" => "35666353638",
     "result" => "SUCCESS",
     "trackid" => "23098372989272",
     "tranid" => "328276498379404",
     "udf1" => "some-value",
     "udf2" => "",
     "udf3" => nil,
     "udf4" => nil,
     "udf5" => "TrackID",
     "udf6" => nil,
     "udf7" => nil,
     "udf8" => nil,
     "udf9" => nil,
     "udf10" => nil
   }}
  ```


  Example of a failed attempt to retrieve a non-existent transaction:

  ```
  {:error,
   %{
     "error_code_tag" => "IPAY0100263",
     "error_service_tag" => "null",
     "result" => "!ERROR!-IPAY0100263-Transaction not found."
   }}
  ```

  """
  @spec get_transaction_details(map()) :: {:ok, map()} | {:error, map()}
  def get_transaction_details(params) do
    Knet.Request.fetch_transaction(params)
  end
end