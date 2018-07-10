defmodule ExCdrPusher.Mixfile do
  use Mix.Project

  def project do
    [
      app: :excdr_pusher,
      version: "0.10.0",
      elixir: "~> 1.6.4",
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
      {:ex_doc, "~> 0.18.3", only: :dev},
      {:distillery, "~> 1.5.2"},
      # {:sqlitex, path: "../sqlitex"},
      {:sqlitex, "~> 1.3.3"},
      {:ecto, "~> 2.2.10"},
      {:postgrex, ">= 0.0.0"},
      {:logger_file_backend, "0.0.10"},
      {:instream, "~> 0.17.1"},
      {:swab, github: "crownedgrouse/swab", branch: "master"},
      {:timex, "~> 3.3.0"},
      {:timex_ecto, "~> 3.3.0"},
      {:tzdata, "~> 0.5.16"},
      # used test and code style,
      {:mix_test_watch, "~> 0.6.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 0.9.2", only: [:dev, :test], runtime: false}
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
