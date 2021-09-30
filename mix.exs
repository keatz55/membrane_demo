defmodule Video.MixProject do
  use Mix.Project

  def project do
    [
      app: :video,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Video.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:ecto_sql, "~> 3.6"},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:ex_aws_s3, "~> 2.0"},
      {:ex_aws, "~> 2.1"},
      {:ex_libsrtp, "~> 0.1.0"},
      {:ex_machina, "~> 2.7.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:gettext, "~> 0.18"},
      {:hackney, "~> 1.9"},
      {:jason, "~> 1.2"},
      {:membrane_aac_format, "~> 0.3.0"},
      {:membrane_aac_plugin, "~> 0.7.0"},
      {:membrane_core, "~> 0.7.0"},
      {:membrane_element_fake, "~> 0.5.0"},
      {:membrane_element_tee, "~> 0.5.0"},
      {:membrane_element_udp, "~> 0.5.0"},
      {:membrane_file_plugin, "~> 0.6.0"},
      {:membrane_h264_ffmpeg_plugin, "~> 0.9.0"},
      {:membrane_http_adaptive_stream_plugin, "~> 0.3.0"},
      {:membrane_mp4_plugin, "~> 0.6.0"},
      {:membrane_rtp_aac_plugin, "~> 0.4.0"},
      {:membrane_rtp_format, "~> 0.3.0"},
      {:membrane_rtp_h264_plugin, "~> 0.5.0"},
      {:membrane_rtp_plugin, "~> 0.6.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.16.0"},
      {:phoenix, "~> 1.6.0-rc.0", override: true},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:scrivener_ecto, "~> 2.0"},
      {:sweet_xml, "~> 0.6"},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:telemetry, "~> 0.4", override: true}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
