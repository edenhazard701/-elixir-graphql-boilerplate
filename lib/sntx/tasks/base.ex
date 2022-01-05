defmodule Sntx.Tasks.Base do
  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
    :ecto_sql,
    :timex,
    :oban
  ]

  @repos Application.get_env(:sntx, :ecto_repos, [])

  def start_services do
    IO.puts("Starting dependencies..")
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # Start the Repo(s) for app
    IO.puts("Starting repos..")

    # Switch pool_size to 2 for ecto > 3.0
    Enum.each(@repos, & &1.start_link(pool_size: 4))
  end

  def stop_services do
    IO.puts("Success!")
    :init.stop()
  end
end
