defmodule DownloaderTest do
  use ExUnit.Case, async: true

  doctest StickerClient.Downloader, import: true

  import StickerClient.Downloader

  test "can create download urls" do
    assert manifest_url("45bdc863f62e6a2548052e0a0c4cb153") ==
             "https://cdn.signal.org/stickers/45bdc863f62e6a2548052e0a0c4cb153/manifest.proto"

    assert sticker_url("45bdc863f62e6a2548052e0a0c4cb153", 10) ==
             "https://cdn.signal.org/stickers/45bdc863f62e6a2548052e0a0c4cb153/full/10"
  end
end
