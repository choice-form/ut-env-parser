defmodule UTEnvParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :ut_env_parser,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      "ci.check": ["format --check-formatted", "credo", &ci_test/1]
    ]
  end

  defp ci_test(_) do
    # 解决 ci.check 中的 MIX_ENV 是 dev ，无法运行 mix test 的问题
    Mix.shell().cmd("mix test")
  end
end
