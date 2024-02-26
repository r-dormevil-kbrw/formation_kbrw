defmodule Server.Database do
    @json_file "lib/chap1/server/orders_dump/orders_chunk0.json"

    use GenServer

    def start_link(_init_value) do
        GenServer.start_link(__MODULE__, :undefined, name: __MODULE__)
    end

    @impl true
    def init(_) do
        case :ets.whereis(:my_table) do
            :undefined -> my_table = :ets.new(:my_table, [:named_table, :set])
                          list = JsonLoader.load_to_database(my_table, @json_file)
                          {:ok, list}
            my_table -> list = :ets.tab2list(my_table)
                        {:ok, list}
        end
    end

    def search(database, criteria) do
        parsed_criteria = Poison.Parser.parse!(criteria, %{keys: :atoms})
        list = :ets.match_object(database, {:_, parsed_criteria})
        {:ok, list}
    end

    @impl true
    def handle_call(:get, _from, _list) do
        new_list = :ets.tab2list(:my_table)
        {:reply, new_list, new_list}
    end

    @impl true
    def handle_call({:get, key}, _from, list) do
        object = :ets.lookup(:my_table, key)
        {:reply, object, [object | list]}
    end

    @impl true
    def handle_cast({:post, object}, list) do
        {key, _} = object
        case :ets.lookup(:my_table, key) do
            [] -> new_object = :ets.insert(:my_table, object)
                  {:noreply, [new_object | list]}
            _object -> {:noreply, list}
        end
    end

    @impl true
    def handle_cast({:put, object}, _list) do
        :ets.insert(:my_table, object)
        new_list = :ets.tab2list(:my_table)
        {:noreply, new_list}
    end

    @impl true
    def handle_cast({:delete, key}, _list) do
        :ets.delete(:my_table, key)
        new_list = :ets.tab2list(:my_table)
        {:noreply, new_list}
    end
end
