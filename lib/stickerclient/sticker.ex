defmodule StickerClient.Sticker do
  @moduledoc """
  Represents a Sticker returned from the Signal stickers API.
  """

  @type t() :: %StickerClient.Sticker{
          id: integer(),
          emoji: bitstring(),
          data: binary()
        }

  defstruct [:id, :emoji, :data]
end
