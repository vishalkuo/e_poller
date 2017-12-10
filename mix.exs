defmodule EPoller.Mixfile do
  use Mix.Project

  def project do
    [
      app: :e_poller,
      version: "0.1.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      name: "e_poller",
      source_url: "https://github.com/vishalkuo/e_poller",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "An SQS long poller written in Elixir. Simulates the SQS poll function seen in the official AWS Ruby client."
  end

  defp deps do
    [
      {:ex_aws, "~> 2.0.2"},
      {:ex_aws_sqs, "~> 2.0"},      
      {:poison, "~> 3.0"},
      {:hackney, "~> 1.9"},
      {:configparser_ex, "~> 2.0"},
      {:sweet_xml, "~> 0.6"},
      {:mock, "~> 0.3.0", only: :test},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      name: "e_poller",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Vishal Kuo"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/vishalkuo/e_poller"}
    ]
  end
end
