defmodule StickerClient.HTTPAdapterBehaviour do
  @callback perform_get(String.t()) :: {:ok, any()} | {:error, Exception.t()}
end
