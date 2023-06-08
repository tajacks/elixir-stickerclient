defmodule StickerClient.CryptoTest do
  use ExUnit.Case, async: true

  import StickerClient.Crypto

  @encrypted_manifest File.read!("test/resources/encrypted_manifest")
  @unencrypted_manifest File.read!("test/resources/unencrypted_manifest")
  @pack_key "9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41"

  test "given key can derive_keys aes and hmac" do
    # Easier to assert against hex values
    {:ok, {aes, hmac}} = derive_keys(@pack_key)

    assert Base.encode16(aes, case: :lower) ==
             "b2c23709262591cbca362c5e55224a5c853badc96f0c278ee6f4c9b9b484cd16"

    assert Base.encode16(hmac, case: :lower) ==
             "4aa4dcf93378d765539140cc626ea0721183908b8f55c69c3f130cf73066fafb"
  end

  test "can decrypt given key and matches known decrypted content" do
    assert decrypt_content(
             @encrypted_manifest,
             @pack_key) == {:ok, @unencrypted_manifest}

    {:ok, {aes, hmac}} =
      derive_keys(@pack_key)

    assert decrypt_content(@encrypted_manifest, aes, hmac) == {:ok, @unencrypted_manifest}
  end

  test "error message when unable to validate content" do
    {:ok, {aes, hmac}} = derive_keys(@pack_key)
    decrypt_result = decrypt_content(<<82, 73, 70, 70>>, aes, hmac)
    assert decrypt_result == {:error, %StickerClient.Exception{message: "Integrity of the content could not be validated with the given HMAC key"}}
  end
end
