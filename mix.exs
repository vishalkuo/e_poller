defmodule EPoller.Mixfile do
  use Mix.Project

  def project do
    [
      app: :e_poller,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),

      # Docs
      name: "E_Poller",
      source_url: "https://github.com/vishalkuo/e_poller"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_aws, "~> 2.0"},
      {:ex_aws_sqs, "~> 2.0"},      
      {:poison, "~> 3.0"},
      {:hackney, "~> 1.9"},
      {:configparser_ex, "~> 2.0"},
      {:sweet_xml, "~> 0.6"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end
end
