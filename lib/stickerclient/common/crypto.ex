defmodule StickerClient.Crypto do
  @moduledoc """
  `StickerClient.Crypto` provides cryptographic utilities required when interacting with
  the Signal Sticker API.
  """

  @decrypt_info "Sticker Pack"

  @doc """
  Attempts to decrypt the given binary using the provided AES key for encryption 
  and HMAC key for integrity


  This method should be used alongside `StickerClient.Crypto.derive_keys/1` to 
  derive the keys once, then decrypting and validating all content by providing 
  those keys, as well as the encrypted content, to this method. 
  """
  @spec decrypt_content(binary(), String.t(), String.t()) ::
          {:ok, binary()} | {:error, StickerClient.Exception.t()}
  def decrypt_content(encrypted_content, aes_key, hmac_key) do
    {content_iv, content_body, content_hmac} = slice_decryption_segments(encrypted_content)

    case validate_hmac(content_iv <> content_body, content_hmac, hmac_key) do
      true ->
        :crypto.crypto_one_time(:aes_256_cbc, aes_key, content_iv, content_body, false)
        |> (&{:ok, unpad(&1)}).()

      _ ->
        {:error,
         StickerClient.Exception.new(
           "Integrity of the content could not be validated with the given HMAC key"
         )}
    end
  end

  @doc """
  Attempts to decrypt the given binary by first deriving AES and HMAC keys 
  from the pack key, then decrypting the content using the derived keys


  This method is a convenience to avoid a call to `StickerClient.Crypto.derive_keys/1` 
  yourself, but is effectively the same. If decrypting multiple binaries which are all from
  the same pack, consider instead deriving the keys once and passing those keys to 
  `StickerClient.Crypto.decrypt_content/3` instead.
  """
  @spec decrypt_content(binary(), String.t()) ::
          {:ok, binary()} | {:error, StickerClient.Exception.t()}
  def decrypt_content(encrypted_content, key) do
    with {:ok, {aes, hmac}} <- derive_keys(key) do
      decrypt_content(encrypted_content, aes, hmac)
    end
  end

  @doc """
  Derives the AES (encryption) and HMAC (integrity) keys from the 
  provided pack key. 


  Typically not called directly as part of pack downloading or uploading, this 
  function allows for the keys to be derived outside of the crypto operations 
  on a per element (manifest|sticker) basis. Useful to prevent re-calculation of 
  keys per element.

  ## Examples

      iex> StickerClient.Crypto.derive_keys("15ec8868cec15c35764af51e09951fc15b548d1dfc1267d0f56bcf7e339b7d09")
      {:ok,
      {<<157, 123, 104, 238, 5, 106, 230, 214, 253, 151, 230, 234, 151, 95, 32, 176,
        221, 225, 219, 243, 120, 210, 71, 116, 175, 39, 55, 12, 43, 78, 77, 247>>,
      <<124, 62, 227, 68, 78, 143, 206, 10, 171, 80, 50, 133, 219, 154, 242, 93, 6,
        140, 58, 98, 2, 68, 110, 40, 98, 252, 58, 176, 55, 15, 149, 227>>}}

      iex(1)> StickerClient.Crypto.derive_keys("15e4af51e09951fc15b548d1dfc1267d0f56bcf7e339b7d")
      {:error, %StickerClient.Exception{message: "Invalid key size. Expected 64 bytes."}}

  """
  @spec derive_keys(String.t()) ::
          {:ok, {binary(), binary()}} | {:error, StickerClient.Exception.t()}
  def derive_keys(pack_key) when is_binary(pack_key) do
    with {:ok, input_key_material} <- String.downcase(pack_key) |> Base.decode16(case: :lower) do
      HKDF.derive(:sha256, input_key_material, 512, "", @decrypt_info)
      |> slice_aes_hmac_keys()
    end
  end

  # AES Key = First 32 bytes, HMAC Key = Next 32 Bytes
  defp slice_aes_hmac_keys(joined_key) when byte_size(joined_key) >= 64 do
    aes = joined_key |> binary_slice(0..31)
    hmac = joined_key |> binary_slice(32..63)
    {:ok, {aes, hmac}}
  end

  defp slice_aes_hmac_keys(_joined_key),
    do: {:error, StickerClient.Exception.new("Invalid key size. Expected 64 bytes.")}

  # IV = 16 Bytes, Body = Variable Bytes, HMAC = Last 32 Bytes
  defp slice_decryption_segments(binary) do
    iv = binary_slice(binary, 0..15)
    body = binary_slice(binary, 16..-33//1)
    hmac = binary_slice(binary, -32..-1//1)
    {iv, body, hmac}
  end

  defp validate_hmac(given_binary, given_hmac, hmac_key) do
    try do
      :crypto.mac(:hmac, :sha256, hmac_key, given_binary) |> :crypto.hash_equals(given_hmac)
    catch
      _t, _v -> false
    end
  end

  # Removes AES CBC Padding
  defp unpad(binary) do
    to_remove = :binary.last(binary)
    binary_slice(binary, 0, byte_size(binary) - to_remove)
  end
end
