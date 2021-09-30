# Membrane Demo

Dynamically generates pipelines via `tracks` stored in postgres. Groups `track` HLS output via parent `stream`.

## Getting started

```shell
# terminal 1
make compose.up # spins up postgresql
mix ecto.create
mix ecto.migrate
make db.seed # seeds 50 streams with one audio and video track each
make iex

# terminal 2
./load.sh {n} # spins up n number of gstreamer process to push audio + video srtp packets

# terminal 3
ffplay output/{stream.id}/long/index.m3u8 # plays tee'd 60s segment HLS playlist by stream id
ffplay output/{stream.id}/short/index.m3u8 # plays tee'd 4s segment HLS playlist by stream id
```
