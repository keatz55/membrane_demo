# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Video.Repo.insert!(%Video.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Video.Factory

### Streams ######

Enum.map(1..50, fn idx ->
  insert(:stream, name: "Register #{idx}")
end)
