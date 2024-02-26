defmodule Server.MyGenericServer do
    def loop({callback_module, server_state}) do
        receive do
            {:cast, request} ->
                new_state = handle_cast(callback_module, request, server_state)
                loop({callback_module, new_state})

            {:call, request, caller} ->
                response = handle_call(callback_module, request, server_state)
                send(caller, response)
                loop({callback_module, server_state})
        end
    end

    def cast(process_pid, request) do
        send(process_pid, {:cast, request})
        {:ok}
    end

    def call(process_pid, request) do
        caller = self()
        send(process_pid, {:call, request, caller})
        receive do
            {:reply, amount} -> amount
        end
    end

    def start_link(callback_module, server_initial_state) do
        pid = spawn_link(fn -> loop({callback_module, server_initial_state}) end)
        {:ok, pid}
    end

    defp handle_cast(callback_module, request, server_state) do
        apply(callback_module, :handle_cast, [request, server_state]);
    end

     defp handle_call(callback_module, request, server_state) do
        apply(callback_module, :handle_call, [request, server_state]);
    end
end
