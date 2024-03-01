defmodule JsonLoader do
    @spec load_to_database(
            atom() | :ets.tid(),
            binary()
            | maybe_improper_list(
                binary() | maybe_improper_list(any(), binary() | []) | char(),
                binary() | []
              )
          ) :: true
    def load_to_database(database, json_file) do
        json_data = File.read!(json_file)
        orders = format_orders_json(json_data)
        :ets.insert(database, orders)
    end

    def format_orders_json(orders_json) do
        orders_data = List.wrap(Poison.Parser.parse!(orders_json, %{keys: :atoms}))
        Enum.map(orders_data, fn order -> order_id = order.id
                                          order_data = order
                                          {order_id, order_data} end)
    end

    def format_orders_to_JSON(orders) do
      Enum.map(orders, fn {_, order_data} -> Poison.encode!(order_data) end)
    end
end
