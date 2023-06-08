defmodule StickerClient.Downloader do
  @moduledoc """
  `StickerClient.Downloader` is used to download content from the Signal sticker API,
  including Pack information and Stickers. 
  """

  alias StickerClient.HTTPClient
  alias StickerClient.Crypto
  alias StickerClient.Validator
  alias StickerClient.Mapper

  @manifest_url "https://cdn.signal.org/stickers/{pack_id}/manifest.proto"

  @sticker_url "https://cdn.signal.org/stickers/{pack_id}/full/{sticker_id}"

  @download_defaults [concurrency: 10, timeout: 20_000]

  @doc """
  Download a pack from the given valid URL, optionally providing concurrency settings.

  The URL takes the format of `https://signal.arwt/addstickers/#pack_id=PACK_ID&pack_key=PACK_KEY`. 
  """
  @spec download_pack(url :: bitstring(), options :: keyword()) ::
          {:ok, StickerClient.Pack.t()} | {:error, StickerClient.Exception.t()}
  def download_pack(url, opts \\ []) when is_binary(url) do
    case Validator.parse_download_url(url) do
      {:ok, pack_id, pack_key} -> download_pack(pack_id, pack_key, opts)
      _ -> {:error, StickerClient.Exception.new("Pack ID and Key could not be parsed")}
    end
  end

  @doc """
  Download a pack from the given Pack Key and Pack ID, providing concurrency settings.
  """
  @spec download_pack(pack_id :: bitstring(), pack_key :: bitstring(), options :: keyword()) ::
          {:ok, StickerClient.Pack.t()} | {:error, StickerClient.Exception.t()}
  def download_pack(pack_id, pack_key, opts) when is_binary(pack_id) and is_binary(pack_key) do
    with {:ok, {aes, hmac}} <- Crypto.derive_keys(pack_key),
         {:ok, manifest} <- download_manifest(pack_id, aes, hmac),
         stickers <- _download_stickers(manifest.stickers, pack_id, aes, hmac, opts) do
      {:ok, %{manifest | stickers: stickers}}
    end
  end

  @doc """
  Download a manifest given a Pack ID and Pack Key. 

  The downloaded manifest will not contain Sticker data, only Sticker metadata.
  """
  @spec download_manifest(pack_id :: bitstring(), pack_key :: bitstring()) ::
          {:ok, StickerClient.Pack.t()} | {:error, StickerClient.Exception.t()}
  def download_manifest(pack_id, pack_key) when is_binary(pack_id) and is_binary(pack_key) do
    case Crypto.derive_keys(pack_key) do
      {:ok, {aes, hmac}} -> download_manifest(pack_id, aes, hmac)
      _ -> {:error, "Unable to derive AES and HMAC Keys"}
    end
  end

  def download_sticker(%StickerClient.Sticker{id: nil}, _pack_id, _pack_key),
    do: {:error, "Sticker ID must not be nil"}

  @doc """
  Download a sticker, providing either a sticker ID as integer, or, a `StickerClient.Sticker` with a set ID. 

  The downloaded sticker will not have metadata such as the associated emoji if a 
  numeric ID is given, or if the provided `StickerClient.Sticker` also does not contain
  metadata. 
  """
  @spec download_sticker(
          sticker :: StickerClient.Sticker.t(),
          pack_id :: bitstring(),
          pack_key :: bitstring()
        ) :: {:ok, StickerClient.Sticker.t()} | {:error, StickerClient.Exception.t()}
  def download_sticker(%StickerClient.Sticker{} = sticker, pack_id, pack_key) do
    case Crypto.derive_keys(pack_key) do
      {:ok, {aes, hmac}} -> _download_sticker(sticker, pack_id, aes, hmac)
      _ -> {:error, "Unable to derive AES and HMAC Keys"}
    end
  end

  @spec download_sticker(sticker_id :: integer(), pack_id :: bitstring(), pack_key :: bitstring()) ::
          {:ok, StickerClient.Sticker.t()} | {:error, StickerClient.Exception.t()}
  def download_sticker(sticker_id, pack_id, pack_key) do
    case Crypto.derive_keys(pack_key) do
      {:ok, {aes, hmac}} -> _download_sticker(sticker_id, pack_id, aes, hmac)
      _ -> {:error, StickerClient.Exception.new("Unable to derive AES and HMAC Keys")}
    end
  end

  @doc """
  Downloads multiple stickers, providing an enumerable containing sticker IDs as integers, or,`StickerClient.Sticker`'s, with set IDs

  The downloaded sticker will not have metadata such as the associated emoji if a 
  numeric ID is given, or if the provided `StickerClient.Sticker` also does not contain
  metadata. 
  """
  @spec download_stickers(
          stickers :: [StickerClient.Sticker.t()] | [integer()],
          pack_id :: bitstring(),
          pack_key :: bitstring(),
          options :: keyword()
        ) :: [StickerClient.Sticker.t()] | {:error, StickerClient.Exception.t()}
  def download_stickers(stickers, pack_id, pack_key, opts \\ []) do
    case Crypto.derive_keys(pack_key) do
      {:ok, {aes, hmac}} -> _download_stickers(stickers, pack_id, aes, hmac, opts)
      _ -> {:error, StickerClient.Exception.new("Unable to derive AES and HMAC Keys")}
    end
  end

  defp download_manifest(pack_id, aes_key, hmac_key) do
    alias StickerClient.HTTPClient

    with {:ok, encrypted_manifest} <- pack_id |> manifest_url() |> HTTPClient.get(),
         {:ok, decrypted_manifest} <-
           Crypto.decrypt_content(encrypted_manifest, aes_key, hmac_key),
         manifest_proto <- StickerClient.Protos.Pack.decode(decrypted_manifest),
         stickers_without_data <-
           manifest_proto.stickers |> Enum.map(&Mapper.map_sticker/1) |> Enum.to_list() do
      {:ok, Mapper.map_pack(manifest_proto, stickers_without_data)}
    end
  end

  defp _download_sticker(
         %StickerClient.Sticker{id: sticker_id} = sticker,
         pack_id,
         aes_key,
         hmac_key
       )
       when is_integer(sticker_id) do
    case _download_sticker(sticker_id, pack_id, aes_key, hmac_key) do
      {:ok, downloaded_sticker} -> {:ok, %{sticker | data: downloaded_sticker.data}}
      {:error, message} -> {:error, message}
    end
  end

  defp _download_sticker(sticker_id, pack_id, aes_key, hmac_key) when is_integer(sticker_id) do
    with {:ok, encrypted_sticker} <- sticker_url(pack_id, sticker_id) |> HTTPClient.get(),
         {:ok, decrypted_sticker} <- Crypto.decrypt_content(encrypted_sticker, aes_key, hmac_key) do
      {:ok, %StickerClient.Sticker{id: sticker_id, data: decrypted_sticker}}
    end
  end

  defp _download_stickers(stickers, pack_id, aes_key, hmac_key, opts) when is_list(opts) do
    options = Keyword.merge(@download_defaults, opts)

    stickers
    |> Task.async_stream(
      fn s -> _download_sticker(s, pack_id, aes_key, hmac_key) end,
      # StickerClient.Downloader,
      # :_download_sticker,
      # [pack_id, aes_key, hmac_key],
      max_concurrency: options[:concurrency],
      timeout: options[:timeout]
    )
    |> Stream.filter(&match?({:ok, {:ok, _}}, &1))
    |> Stream.map(fn {_, {_, body}} -> body end)
    |> Enum.to_list()
  end

  @doc false
  def manifest_url(pack_id) when is_binary(pack_id) do
    String.replace(@manifest_url, "{pack_id}", pack_id)
  end

  @doc false
  def sticker_url(pack_id, sticker_id) when is_integer(sticker_id) and is_binary(pack_id) do
    @sticker_url
    |> String.replace("{pack_id}", pack_id)
    |> String.replace("{sticker_id}", Integer.to_string(sticker_id))
  end
end
