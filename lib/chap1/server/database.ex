defmodule Server.Database do
    @json_file "lib/chap1/server/orders_dump/orders_chunk0.json"

    use GenServer
    require Logger

    def start_link(_init_value) do
        GenServer.start_link(__MODULE__, :undefined, name: __MODULE__)
    end

    @impl true
    def init(_) do
        Logger.info("Starting database...")
        case :ets.whereis(:my_table) do
            :undefined -> my_table = :ets.new(:my_table, [:named_table, :set])
                          JsonLoader.load_to_database(my_table, @json_file)
                          {:ok, %{name_table: :my_table}}
            _ -> {:ok, %{name_table: :my_table}}
        end
    end

    def search(database, criterias) do
        list = :ets.match_object(database, {:_, criterias})
        {:ok, list}
    end

    @impl true
    def handle_call(:get, _from, state) do
        new_list = :ets.tab2list(state[:name_table])
        {:reply, new_list, state}
    end

    @impl true
    def handle_call({:get, key}, _from, state) do
        object = :ets.lookup(state[:name_table], key)
        {:reply, object, state}
    end

    @impl true
    def handle_cast({:post, new_objects}, state) do
        existing_objecs = :ets.tab2list(state[:name_table])
        new_keys = Enum.map(new_objects, fn {key, _} -> key end)
        existing_keys = Enum.map(existing_objecs, fn {key, _} -> key end)
        results = Enum.find(new_keys, fn key -> Enum.member?(existing_keys, key) end)
        case results do
            nil -> :ets.insert(state[:name_table], new_objects)
                 {:noreply, state}
            _ -> {:noreply, state}
        end
    end

    @impl true
    def handle_cast({:put, objects}, state) do
        :ets.insert(state[:name_table], objects)
        {:noreply, state}
    end

    @impl true
    def handle_cast({:delete, key}, state) do
        :ets.delete(state[:name_table], key)
        {:noreply, state}
    end
end
