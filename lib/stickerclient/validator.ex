defmodule StickerClient.Validator do
  @moduledoc """
  `StickerClient.Validator` is a utility module which provides parsing and validation to support `StickerClient`.
  """

  @download_url_pattern ~r/^https:\/\/signal\.art\/addstickers\/#pack_id=(?<pack_id>\w{32})&pack_key=(?<pack_key>\w{64})$/

  @doc """
  Attempts to parse an `https://signal.art/addstickers` URL to extract the Pack ID and Key. 

  ## Examples

      iex> parse_download_url("https://signal.art/addstickers/#pack_id=45bdc863f62e6a2548052e0a0c4cb153&pack_key=9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41")
      {:ok, "45bdc863f62e6a2548052e0a0c4cb153", "9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41"}

      # Typo in pack_key
      iex> parse_download_url("https://signal.art/addstickers/#pack_id=45bdc863f62e6a2548052e0a0c4cb153&pack_ke=9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41")  
      {:error, "Invalid format, Pack ID and Key could not be parsed"}
  """
  def parse_download_url(url) when is_bitstring(url) do
    captures = Regex.named_captures(@download_url_pattern, url)

    case captures do
      %{"pack_id" => pack_id, "pack_key" => pack_key} -> {:ok, pack_id, pack_key}
      _ -> {:error, "Invalid format, Pack ID and Key could not be parsed"}
    end
  end
end
