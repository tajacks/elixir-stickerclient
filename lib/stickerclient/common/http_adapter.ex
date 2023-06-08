defmodule StickerClient.HTTPAdapter do
  @behaviour StickerClient.HTTPAdapterBehaviour

  @moduledoc false

  @impl StickerClient.HTTPAdapterBehaviour
  def perform_get(url) do
    Req.get(url, connect_options: [transport_opts: [cacerts: :public_key.cacerts_get()]])
  end
end
