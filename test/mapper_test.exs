defmodule StickerClient.MapperTest do
  use ExUnit.Case, async: true

  doctest StickerClient.Mapper, import: true

  import StickerClient.Mapper

  test "can map pack from protobuf to basic struct" do
    pack = File.read!("test/resources/unencrypted_manifest") |> StickerClient.Protos.Pack.decode()
    mapped = map_pack(pack, pack.stickers)
    assert mapped.title == "oh my frog by ilaso"
    assert mapped.author == "https://t.me/addstickers/ohmyfrog_ilaso"
    assert mapped.cover != nil
    assert mapped.stickers |> Enum.count() == 40
  end

  test "can map stickers and add data" do
    pack = File.read!("test/resources/unencrypted_manifest") |> StickerClient.Protos.Pack.decode()

    sticker = pack.stickers |> hd() |> map_sticker(<<9>>)
    assert sticker.data == <<9>>
  end
end
