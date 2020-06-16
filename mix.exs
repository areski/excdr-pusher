defmodule ExCdrPusher.Mixfile do
  use Mix.Project

  def project do
    [
      app: :excdr_pusher,
      version: "1.4.4",
      elixir: "> 1.9.0",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      extra_applications: [:logger],
      mod: {ExCdrPusher.Application, []}
    ]
  end

  # Dependencies
  defp deps do
    [
      {:ecto, "~> 3.4.5"},
      {:ecto_sql, "~> 3.4.4"},
      {:postgrex, ">= 0.0.0"},
      {:sqlitex, "~> 1.7.1"},
      {:esqlite, "0.4.1"},
      {:jason, "~> 1.2.1"},
      {:logger_file_backend, "0.0.11"},
      {:observer_cli, "~> 1.5.3"},
      {:distillery, "~> 2.1.1"},
      {:memoize, "~> 1.3.0"},
      {:decimal, "~> 1.8.1"},
      {:timex, "~> 3.6.2"},
      {:tzdata, "~> 1.0.3"},
      # used test and code style,
      {:ex_doc, "~> 0.22.1", only: :dev},
      {:mix_test_watch, "~> 1.0.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.4.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp description, do: "Push FreeSWITCH CDRS from Sqlite to PostgreSQL"

  defp package do
    [
      name: :excdr_pusher,
      license_file: "LICENSE",
      external_dependencies: [],
      maintainers: ["Areski Belaid"],
      vendor: "Areski Belaid",
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/areski/excdr-pusher",
        "Homepage" => "https://github.com/areski/excdr-pusher"
      }
    ]
  end
end
