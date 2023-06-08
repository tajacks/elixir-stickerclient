Mox.defmock(StickerClient.HTTPAdapterMock, for: StickerClient.HTTPAdapterBehaviour)
Application.put_env(:sticker_client, :http_adapter, StickerClient.HTTPAdapterMock)
ExUnit.start()
