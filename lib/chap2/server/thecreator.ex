defmodule Server.TheCreator do

  defmacro __using__(_opts) do
    quote do
      import Server.TheCreator

      @requests_params []
      @error_params {}

      @before_compile Server.TheCreator
    end
  end

  defmacro my_get(path, do: {code, message}) do
    params = {path, {code, message}}
    quote do
      @requests_params [unquote(params) | @requests_params]
    end
  end

  defmacro my_error(code: code_error, content: message_error)do
    params = {code_error, message_error}
    quote do
      @error_params unquote(params)
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      import Plug.Conn
      require Logger

      def init(opts), do: opts

      def call(conn, _opts) do
        {code_error, message_error} = @error_params

        Logger.info("Access to path: #{conn.request_path}")

        param = Enum.find(@requests_params, fn {path, _} -> conn.request_path == path end)

        case param do
          {_, {code, message}} -> send_resp(conn, code, message)
          nil -> send_resp(conn, code_error, message_error)
        end
      end
    end
  end
end
