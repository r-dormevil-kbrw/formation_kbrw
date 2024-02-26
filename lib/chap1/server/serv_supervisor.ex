defmodule Server.Supervisor do
    use Supervisor

    @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
    def start_link(_initial_args) do
        Supervisor.start_link(__MODULE__, :undefined, name: __MODULE__)
    end

    @impl true
    def init(_) do
        children = [
            {Server.Database, 0}
        ]
        Supervisor.init(children, strategy: :one_for_one)
    end
end
