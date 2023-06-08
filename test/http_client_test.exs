defmodule StickerClient.HTTPClientTest do
  use ExUnit.Case, async: true

  alias StickerClient.HTTPClient

  import Mox

  setup :verify_on_exit!

  test "can get valid response" do
    StickerClient.HTTPAdapterMock
    |> expect(:perform_get, fn _url -> {:ok, %{status: 200, body: "Example Text"}} end)

    response = HTTPClient.get("https://example.com")
    assert response == {:ok, "Example Text"}
  end

  test "when performing get, exception is passed" do
    StickerClient.HTTPAdapterMock
    |> expect(:perform_get, fn _url -> {:error, %Mint.TransportError{reason: :timeout}} end)

    response = HTTPClient.get("https://example.com")
    assert response == {:error, %StickerClient.Exception{message: "timeout"}}
  end

  test "when invalid response code, exception is passed" do
    StickerClient.HTTPAdapterMock
    |> expect(:perform_get, fn _url -> {:ok, %{status: 404, body: "Example Text"}} end)

    response = HTTPClient.get("https://example.com")

    assert response ==
             {:error, %StickerClient.Exception{message: "Unexpected HTTP response code: 404"}}
  end
end
