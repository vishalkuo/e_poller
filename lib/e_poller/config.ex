defmodule EPoller.Config do
  @default_config [wait_time_seconds: 20, 
    visibility_timeout: 10, 
    max_messages: 10]

    @spec get_full_config(map) :: map
    def get_full_config(user_config) do 
      res = Keyword.merge(@default_config, user_config)
      [
        max_number_of_messages: res[:max_messages],
        visibility_timeout: res[:visibility_timeout],
        wait_time_seconds: res[:wait_time_seconds]
      ]
    end 
end
