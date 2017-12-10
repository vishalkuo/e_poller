defmodule EPoller.Config do
  @moduledoc """
  This module contains the configuration management for queue polling
  """

  @default_config [wait_time_seconds: 20, 
    visibility_timeout: 10, 
    max_messages: 10, 
    region: "us-east-1"]

  @typedoc """ 
  The configurable parameters for the long poller.

  `wait_time_seconds` sets how long the poller will wait for a message to arrive

  `visibility_timeout` sets how long, in seconds, a message will be hidden from
    subsequent requests after being taken off the queue.

  `max_messages` sets the max number of messages that can be consumed from the poller.
    This number is limited to 10.
    
  `region` sets the region that the queue currently exists in. 
  """
  @type attribute_name :: 
    :wait_time_seconds | 
    :visibility_timeout | 
    :max_messages | 
    :region

  @typedoc """
  The configuration list for the long poller
  """
  @type poller_config_opts :: [attribute_name, ...]


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
