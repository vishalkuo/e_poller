defmodule EPoller.Config do
  @moduledoc """
  This module contains the configuration management for queue polling
  """

  @default_config [wait_time_seconds: 20, 
    visibility_timeout: 10, 
    max_messages: 10, 
    region: "us-east-1"]

    @doc """
    Gets the user and default config for polling and merges them

    Why have a config abstraction for virtually the same values seen in ExAws.SQS?
    1. In case config changes from the ExAws side. EPoller's client shouldn't know what the underlying
    implementation of SQS polling is and shouldn't have to deal with it
    2. We don't necessarily want to config _all_ parameters. Polling might not function as promised if 
    we start tweaking too many knobs (relates to 1). 
    """
    @spec get_full_config(map) :: map
    def get_full_config(user_config) do 
      res = Keyword.merge(@default_config, user_config)
      sqs_conf = [
        max_number_of_messages: res[:max_messages],
        visibility_timeout: res[:visibility_timeout],
        wait_time_seconds: res[:wait_time_seconds]
      ]
      %{:region => res[:region], :sqs_conf => sqs_conf}
    end 
end
