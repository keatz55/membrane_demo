.PHONY: test

db.seed:
	@make compose.up
	mix run priv/repo/seeds.exs

iex: 
	@make install
	@make compose.up
	iex -S mix phx.server

install:
	mix deps.get
	mix compile

compose.up:
	docker compose up -d --remove-orphans
	docker compose ps	

compose.down:
	docker compose down

compose.logs:
	docker compose logs -f --tail 100

test:
	@make compose.up
	mix test

test.iex:
	@make compose.up
	iex -S mix test
