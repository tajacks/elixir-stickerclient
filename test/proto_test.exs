defmodule StickerClient.ProtosTest do
  use ExUnit.Case, async: true

  test "can map protofbuf models from known decrypted content" do
    pack = File.read!("test/resources/unencrypted_manifest") |> StickerClient.Protos.Pack.decode()
    assert pack.title == "oh my frog by ilaso"
    assert pack.author == "https://t.me/addstickers/ohmyfrog_ilaso"
    assert pack.stickers |> Enum.count() == 40
  end
end
