defmodule JsonLoader do
    def load_to_database(database, json_file) do
        json_data = File.read!(json_file)
        orders_data = Poison.Parser.parse!(json_data, %{keys: :atoms})
        orders = format_orders_data(orders_data)
        :ets.insert(database, orders)
    end

    defp format_orders_data(orders_data) do
       orders_data|> Enum.map(fn order ->
                                          order_id = order.id
                                          order_data = order
                                          {order_id, order_data}
       end)
    end
end
