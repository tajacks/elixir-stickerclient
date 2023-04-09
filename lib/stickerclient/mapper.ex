defmodule StickerClient.Mapper do
  @moduledoc """
  `StickerClient.Mapper` is a utility module for converting Protobuf Structs to StickerClient defined Structs.
  """

  @doc """
  Convert a Protobuf defined sticker Struct to a `StickerClient.Sticker` without data.
  """
  def map_sticker(%StickerClient.Protos.Pack.Sticker{} = sticker) do
    %StickerClient.Sticker{id: sticker.id, emoji: sticker.emoji, data: nil}
  end

  @doc """
  Convert a Protobuf defined sticker Struct to a `StickerClient.Sticker` with data.
  """
  def map_sticker(%StickerClient.Protos.Pack.Sticker{} = sticker, data) do
    %StickerClient.Sticker{id: sticker.id, emoji: sticker.emoji, data: data}
  end

  @doc """
  Convert a Protobuf defined Pack and list of Stickers to a `StickerClient.Pack`.
  """
  def map_pack(%StickerClient.Protos.Pack{} = pack, stickers) when is_list(stickers) do
    %StickerClient.Pack{
      title: pack.title,
      author: pack.author,
      cover: pack.cover,
      stickers: stickers
    }
  end
end
