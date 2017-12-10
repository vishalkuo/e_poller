# EPoller

An SQS long poller meant to simulate the functionality seen in the [Ruby SQS SDK](http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SQS/QueuePoller.html). 

[Documentation](https://hexdocs.pm/e_poller/api-reference.html)

### Note About Authentication

If you're planning on using config file authentication, the following needs to be added to your
`config.exs`:

```elixir
config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, {:awscli, "default", 30}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, {:awscli, "default", 30}, :instance_role]
```

## Installation

Add `e_poller` to your `mix.exs` file

```elixir
def deps do
  [{:e_poller, "~> 0.1.1"}]
end
```

and run `$ mix deps.get`.

## Usage
```elixir
iex(1)> {:ok, poller_pid} = EPoller.start_link("my_worker_queue", fn m -> IO.inspect m end)
{:ok, #PID<0.234.0>}
iex(2)> EPoller.poll(poller_pid)
"1\n"
"1\n2"
"1\n2"
:ok
```
Every poller process is initialized with a queue name and a message handler function. Further configuration, such as region, visibility timeout, and poll duration, can also be configured at this step. 

Every time the queue is polled, the handler function is called for each message. If the handler function doesn't raise an error, the message is assumed to have been parsed correctly and the message is deleted from the queue. 

### Configuration
Pollers can also be initialized with config variables:
```elixir
iex(1)> config = [wait_time_seconds: 10, visibility_timeout: 2,region: "us-west-1"]
iex(2)> {:ok, poller_pid} = EPoller.start_link("my_worker_queue", fn m -> IO.inspect m end, config)
```
