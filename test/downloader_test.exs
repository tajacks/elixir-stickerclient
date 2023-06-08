defmodule DownloaderTest do
  use ExUnit.Case, async: true

  doctest StickerClient.Downloader, import: true

  import StickerClient.Downloader
  import Mox

  @downloaded_manifest File.read!("test/resources/encrypted_manifest")
  @downloaded_sticker File.read!("test/resources/encrypted_sticker")

  @test_key "9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41"
  @test_id "45bdc863f62e6a2548052e0a0c4cb153"
  @test_url "https://signal.art/addstickers/#pack_id=45bdc863f62e6a2548052e0a0c4cb153&pack_key=9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41"

  test "can create download urls" do
    assert manifest_url("45bdc863f62e6a2548052e0a0c4cb153") ==
             "https://cdn.signal.org/stickers/45bdc863f62e6a2548052e0a0c4cb153/manifest.proto"

    assert sticker_url("45bdc863f62e6a2548052e0a0c4cb153", 10) ==
             "https://cdn.signal.org/stickers/45bdc863f62e6a2548052e0a0c4cb153/full/10"
  end

  test "can download manifest" do
    StickerClient.HTTPAdapterMock
    |> expect(:perform_get, fn _url -> {:ok, %{status: 200, body: @downloaded_manifest}} end)

    {:ok, response} = StickerClient.Downloader.download_manifest(@test_id, @test_key)
    assert response.title == "oh my frog by ilaso"
    assert response.author == "https://t.me/addstickers/ohmyfrog_ilaso"
    assert Enum.count(response.stickers) == 40
  end

  test "can download sticker" do
    StickerClient.HTTPAdapterMock
    |> expect(:perform_get, 2, fn _url -> {:ok, %{status: 200, body: @downloaded_sticker}} end)

    {:ok, response} = StickerClient.Downloader.download_sticker(10, @test_id, @test_key)
    {:ok, alt_response = StickerClient.Downloader.download_stickers([10], @test_id, @test_key)}
    assert response == hd(alt_response)
    assert response.id == 10
    assert response.emoji == nil
    assert response.data != nil
  end

  test "can download pack" do
    StickerClient.HTTPAdapterMock
    |> expect(:perform_get, 41, fn url ->
      case String.contains?(url, "manifest") do
        true ->
          {:ok, %{status: 200, body: @downloaded_manifest}}

        # Downloading the same sticker for each test, that's OK
        false ->
          {:ok, %{status: 200, body: @downloaded_sticker}}
      end
    end)

    {:ok, response} = StickerClient.Downloader.download_pack(@test_url)
    assert response.title == "oh my frog by ilaso"
    assert response.author == "https://t.me/addstickers/ohmyfrog_ilaso"
    assert Enum.count(response.stickers) == 40
    assert Enum.all?(response.stickers, fn s -> s.data != nil end)
  end
end
