defmodule ExCdrPusher.Mixfile do
  use Mix.Project

  def project do
    [
      app: :excdr_pusher,
      version: "0.13.5",
      elixir: "~> 1.8.1",
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
    [mod: {ExCdrPusher, []}, extra_applications: [:logger]]
  end

  # Dependencies
  defp deps do
    [
      {:ex_doc, "~> 0.19.3", only: :dev},
      {:distillery, "~> 2.0.12"},
      {:memoize, "~> 1.3.0"},
      {:sqlitex, "~> 1.5.1"},
      # patched but now available in 1.5.1
      # {:sqlitex, path: "/home/areski/projects/elixir/sqlitex", override: true},
      {:decimal, "~> 1.7"},
      # {:sqlitex, "~> 1.5.0"},
      {:esqlite, "0.3.0"},
      # {:esqlite, git: "https://github.com/mmzeeman/esqlite.git", ref: "c1a0d60574539cda1f3310826945485f1d202d9c"},
      # {:esqlite, path: "/home/areski/projects/elixir/esqlite", override: true},
      {:ecto, "~> 3.0.7"},
      {:ecto_sql, "~> 3.0.5"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.1.2"},
      {:logger_file_backend, "0.0.10"},
      {:instream, "~> 0.19.0"},
      {:swab, github: "crownedgrouse/swab", branch: "master"},
      {:timex, "~> 3.5.0"},
      # {:timex_ecto, "~> 3.3.0"},
      {:tzdata, "~> 0.5.19"},
      # used test and code style,
      {:mix_test_watch, "~> 0.9.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.0.3", only: [:dev, :test], runtime: false}
      # {:dogma, "~> 0.1", only: :dev},
    ]
  end

  defp description, do: "Push FreeSWITCH CDRS from Sqlite to PostgreSQL & InfluxDB"

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
