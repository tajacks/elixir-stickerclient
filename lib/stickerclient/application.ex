defmodule StickerClient.Runtime.Application do
  use Application

  @moduledoc false

  @cacert_path Path.join(:code.priv_dir(:stickerclient), "cacert.pem")

  # {:error, reason} is returned if there is an issue loading CA Certs, which also matches 
  # the return type of the Application `start` callback 
  # Thanks Rockwell Shrock!
  def start(_type, _args) do
    with :ok <- :public_key.cacerts_load(@cacert_path) do
      Supervisor.start_link([], strategy: :one_for_one)
    end
  end
end
