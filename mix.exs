defmodule Knet.MixProject do
  use Mix.Project

  @version "1.2.0"
  @source_url "https://github.com/aesmail/knet-elixir"

  def project do
    [
      app: :knet,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Knet.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:finch, "~> 0.16.0"},
      {:elixir_xml_to_map, "~> 3.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      maintainers: ["Abdullah Esmail"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp description() do
    "An elixir package for dealing with KNET payments in Kuwait (https://www.knet.com.kw)"
  end
end
