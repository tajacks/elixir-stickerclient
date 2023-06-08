defmodule StickerClient.HTTPClient do
  
  @spec get(String.t) :: {:ok, String.t} | {:error, StickerClient.Exception.t}
  def get(url) do
    results = adapter().perform_get(url)

    case results do
      {:ok, %{:status => code, :body => body}} when div(code, 100) == 2 ->
        {:ok, body}

      {:ok, %{:status => code}} ->
        {:error, StickerClient.Exception.new("Unexpected HTTP response code: #{code}")}

      {:error, e} ->
        {:error, StickerClient.Exception.wrap(e)}
    end
  end

  # Fallback to the 'production' adapter if none is configured in the environment 
  defp adapter, do: Application.get_env(:sticker_client, :http_adapter, StickerClient.HTTPAdapter)
end
