defmodule StickerClient.CryptoTest do
  use ExUnit.Case, async: true

  import StickerClient.Crypto

  test "given key can derive_keys aes and hmac" do
    # Easier to assert against hex values
    {:ok, {aes, hmac}} =
      derive_keys("9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41")

    assert Base.encode16(aes, case: :lower) ==
             "b2c23709262591cbca362c5e55224a5c853badc96f0c278ee6f4c9b9b484cd16"

    assert Base.encode16(hmac, case: :lower) ==
             "4aa4dcf93378d765539140cc626ea0721183908b8f55c69c3f130cf73066fafb"
  end

  test "can decrypt given key and matches known decrypted content" do
    encrypted = File.read!("test/resources/encrypted_manifest")
    decrypted = {:ok, File.read!("test/resources/unencrypted_manifest")}

    assert decrypt_content(
             encrypted,
             "9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41"
           ) == decrypted

    {:ok, {aes, hmac}} =
      derive_keys("9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41")

    assert decrypt_content(encrypted, aes, hmac) == decrypted
  end
end
