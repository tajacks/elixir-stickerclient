defmodule StickerClient.ValidatorTest do
  use ExUnit.Case, async: true

  doctest StickerClient.Validator, import: true

  import StickerClient.Validator

  @valid_url "https://signal.art/addstickers/#pack_id=45bdc863f62e6a2548052e0a0c4cb153&pack_key=9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41"

  @missing_key_url "https://signal.art/addstickers/#pack_id=45bdc863f62e6a2548052e0a0c4cb153&pack_kley=9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41"

  @missing_id_url "https://signal.art/addstickers/#pack_ip=45bdc863f62e6a2548052e0a0c4cb153&pack_key=9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41"

  @invalid_url "https://signal.art/addstickers/#pack_unknown=45bdc863f62e6a2548052e0a0c4cb153&pack_nothing=9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41"

  @pack_id "45bdc863f62e6a2548052e0a0c4cb153"

  @pack_key "9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41"

  test "can parse valid url with correct matches" do
    assert parse_download_url(@valid_url) == {:ok, @pack_id, @pack_key}
  end

  test "can error on invalid URL" do
    assert parse_download_url(@invalid_url) ==
             {:error,
              %StickerClient.Exception{
                message: "Invalid format, Pack ID and Key could not be parsed"
              }}

    assert parse_download_url("https://google.ca") ==
             {:error,
              %StickerClient.Exception{
                message: "Invalid format, Pack ID and Key could not be parsed"
              }}

    assert parse_download_url(@missing_id_url) ==
             {:error,
              %StickerClient.Exception{
                message: "Invalid format, Pack ID and Key could not be parsed"
              }}

    assert parse_download_url(@missing_key_url) ==
             {:error,
              %StickerClient.Exception{
                message: "Invalid format, Pack ID and Key could not be parsed"
              }}
  end
end
