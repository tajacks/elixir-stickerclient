defmodule StickerClient.Pack do
  @moduledoc """
  Represents a Pack returned from the Signal stickers API.
  """

  @type t() :: %StickerClient.Pack{
          title: bitstring(),
          author: bitstring(),
          cover: StickerClient.Sticker.t(),
          stickers: list(StickerClient.Sticker.t())
        }

  defstruct [:title, :author, :cover, :stickers]
end
