defmodule StickerClient.HTTPAdapterBehaviour do
  @moduledoc false

  @callback perform_get(String.t()) :: {:ok, any()} | {:error, Exception.t()}
end
