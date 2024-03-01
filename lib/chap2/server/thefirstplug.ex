defmodule Server.TheFirstPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    put_resp_content_type(conn, "application/json")
    case conn.request_path do
      "/" -> send_resp(conn, 200, "Welcome to the new world of Plugs!\n")
      "/me" -> send_resp(conn, 200, "I am The First, The One, Le Geant Plug Vert, Le Grand Plug, Le Plug Cosmique.\n")
      _ -> send_resp(conn, 404, "Go away, you are not welcome here.\n")
    end
  end
end
