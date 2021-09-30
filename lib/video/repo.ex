defmodule Video.Repo do
  use Ecto.Repo,
    otp_app: :video,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
