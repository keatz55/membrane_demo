defmodule Video.Repo.Migrations.CreateStreams do
  use Ecto.Migration

  def change do
    create table(:streams) do
      add(:name, :string)
      add(:type, :string, null: false)

      timestamps()
    end
  end
end
