defmodule Server.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/", do: send_resp(conn, 200, "Hello world! Welcome to my place")

  get "/orders/" do
    orders = GenServer.call(Server.Database, :get)
    orders_json = JsonLoader.format_orders_to_JSON(orders)
    conn
    |>put_resp_content_type("application/json")
    |>send_resp(200, orders_json)
  end

  get "/orders/:id" do
    orders = GenServer.call(Server.Database, {:get, id})
    orders_json = JsonLoader.format_orders_to_JSON(orders)
    conn
    |>put_resp_content_type("application/json")
    |>send_resp(200, orders_json)
  end

  get "/search/" do
    criterias = fetch_query_params(conn).query_params
    {_, orders} = Server.Database.search(:my_table, criterias)
    orders_json = JsonLoader.format_orders_to_JSON(orders)
    conn
    |>put_resp_content_type("application/json")
    |>send_resp(200, orders_json)
  end

  post "/orders" do
    {_, orders_json, _} = read_body(conn)
    orders = JsonLoader.format_orders_json(orders_json)
    GenServer.cast(Server.Database, {:post, orders})
    send_resp(conn, 200, "Success!")
  end

  put "/orders/:id" do
    {_, order_json, _} = read_body(conn)
    order = JsonLoader.format_orders_json(order_json)
    GenServer.cast(Server.Database, {:put, order})
    send_resp(conn, 200, "Success!")
  end

  delete "/orders/:id" do
    GenServer.call(Server.Database, {:get, id})
    send_resp(conn, 200, "Success!")
  end

  match _, do: send_resp(conn, 404, "Page Not Found")

end
