defmodule Video.Repo.Migrations.CreateTracks do
  use Ecto.Migration

  def change do
    create table(:tracks) do
      add(:ssrc, :serial, null: false)
      add(:type, :string, null: false)

      add(:stream_id, references(:streams, on_delete: :delete_all), null: false)

      timestamps()
    end

    create index(:tracks, [:stream_id])
    create unique_index(:tracks, [:ssrc])
  end
end
