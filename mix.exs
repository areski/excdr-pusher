defmodule ExCdrPusher.Mixfile do
  use Mix.Project

  def project do
    [
      app: :excdr_pusher,
      version: "0.10.2",
      elixir: "~> 1.7.3",
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
      {:ex_doc, "~> 0.19.1", only: :dev},
      {:distillery, "~> 2.0.12"},
      # {:sqlitex, path: "../sqlitex"},
      {:sqlitex, "~> 1.5.0"},
      # {:esqlite, "0.2.4"},
      # {:esqlite, git: "https://github.com/mmzeeman/esqlite.git", ref: "c1a0d60574539cda1f3310826945485f1d202d9c"},
      {:esqlite, path: "/home/areski/projects/elixir/esqlite", override: true},
      {:ecto, "~> 2.2.10"},
      {:postgrex, ">= 0.0.0"},
      {:logger_file_backend, "0.0.10"},
      {:instream, "~> 0.18.0"},
      {:swab, github: "crownedgrouse/swab", branch: "master"},
      {:timex, "~> 3.4.2"},
      {:timex_ecto, "~> 3.3.0"},
      {:tzdata, "~> 0.5.19"},
      # used test and code style,
      {:mix_test_watch, "~> 0.9.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false}
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
