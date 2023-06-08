defmodule StickerClient.Exception do
  @type t :: %__MODULE__{
          message: String.t()
        }

  @default_message "StickerClient Exception"

  defexception message: @default_message

  def wrap(e) when is_exception(e) do
    %__MODULE__{message: Exception.message(e)}
  end

  def new(msg \\ @default_message), do: %__MODULE__{message: msg}
end
