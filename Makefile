# .PHONY: up schema load indexes db verify down reset

# up:
# 	docker compose up -d

# schema: up
# # 	docker compose exec -T db psql -U airbnb -d airbnb -f /work/sql/schema.sql
# 	@echo "Waiting for Postgres to be ready..."
# 	@for i in 1 2 3 4 5; do \
# 		if docker compose exec -T db pg_isready -U airbnb -d airbnb; then \
# 			echo "Postgres is ready. Applying schema..."; \
# 			docker compose exec -T db psql -U airbnb -d airbnb -f /work/sql/schema.sql && break; \
# 		else \
# 			echo "Still starting up... retry $$i"; \
# 			sleep 2; \
# 		fi; \
# 	done

# load:
# 	docker compose exec -T db psql -U airbnb -d airbnb -f /work/sql/load.sql

# indexes:
# 	docker compose exec -T db psql -U airbnb -d airbnb -f /work/sql/indexes.sql

# db: up schema load indexes

# verify:
# 	docker compose exec -T db psql -U airbnb -d airbnb -c "\dt raw.*"
# 	docker compose exec -T db psql -U airbnb -d airbnb -c "SELECT COUNT(*) FROM raw.listings;"
# 	docker compose exec -T db psql -U airbnb -d airbnb -c "SELECT COUNT(*) FROM raw.reviews;"
# 	docker compose exec -T db psql -U airbnb -d airbnb -c "\d raw.listings"
# 	docker compose exec -T db psql -U airbnb -d airbnb -c "\d raw.reviews"

# down:
# 	docker compose down

# reset:
# 	docker compose down -v
# 	docker compose up -d
# 	sleep 5
# 	docker compose exec -T db psql -U airbnb -d airbnb -f /work/sql/schema.sql
# 	docker compose exec -T db psql -U airbnb -d airbnb -f /work/sql/load.sql
# 	docker compose exec -T db psql -U airbnb -d airbnb -f /work/sql/indexes.sql

# count_rows:
# 	docker compose exec -T db psql -U airbnb -d airbnb -c "\
# 	SELECT 'listings' AS table, COUNT(*) AS n FROM raw.listings \
# 	UNION ALL \
# 	SELECT 'reviews', COUNT(*) FROM raw.reviews;"

.PHONY: help up down reset schema load indexes db verify count_rows wait dbshell appshell

# ---- Config ----
APP        := app
DB         := db
DB_USER    := airbnb
DB_NAME    := airbnb
DB_HOST    := db
SQL_DIR    := sql
ON_ERROR   := -v ON_ERROR_STOP=1

# Run psql from the APP container (has project files mounted at /app)
define PSQL_APP
docker compose run --rm $(APP) bash -lc 'psql -h $(DB_HOST) -U $(DB_USER) -d $(DB_NAME) $(ON_ERROR) $$*'
endef

help:
	@echo "make up           - start containers"
	@echo "make schema       - apply schema.sql"
	@echo "make load         - run load.sql"
	@echo "make indexes      - run indexes.sql"
	@echo "make db           - schema + load + indexes"
	@echo "make verify       - basic sanity checks"
	@echo "make count_rows   - quick row counts"
	@echo "make dbshell      - psql shell inside db service"
	@echo "make appshell     - bash shell in app service"
	@echo "make down         - stop containers"
	@echo "make reset        - down -v, then full recreate + seed"

up:
	docker compose up -d

# Wait until Postgres accepts connections
wait: up
	@echo "Waiting for Postgres to be ready..."
	@for i in 1 2 3 4 5 6 7 8 9 10; do \
		if docker compose exec -T $(DB) pg_isready -U $(DB_USER) -d $(DB_NAME) >/dev/null 2>&1; then \
			echo "Postgres is ready."; \
			exit 0; \
		else \
			echo "Still starting up... retry $$i"; \
			sleep 2; \
		fi; \
	done; \
	echo "Postgres did not become ready in time." >&2; \
	exit 1

schema: wait
	@echo "Applying schema..."
	$(call PSQL_APP,-f /app/$(SQL_DIR)/schema.sql)

load:
	@echo "Loading data..."
	$(call PSQL_APP,-f /app/$(SQL_DIR)/load.sql)

indexes:
	@echo "Creating indexes..."
	$(call PSQL_APP,-f /app/$(SQL_DIR)/indexes.sql)

db: schema load indexes

verify:
	$(call PSQL_APP,-c "\dt raw.*")
	$(call PSQL_APP,-c "SELECT COUNT(*) FROM raw.listings;")
	$(call PSQL_APP,-c "SELECT COUNT(*) FROM raw.reviews;")
	$(call PSQL_APP,-c "\d+ raw.listings")
	$(call PSQL_APP,-c "\d+ raw.reviews")

count_rows:
	$(call PSQL_APP,-c "SELECT 'listings' AS table, COUNT(*) AS n FROM raw.listings UNION ALL SELECT 'reviews', COUNT(*) FROM raw.reviews;")

down:
	docker compose down

reset:
	docker compose down -v
	docker compose up -d
	$(MAKE) db

# Handy shells
dbshell:
	docker compose exec -it $(DB) psql -U $(DB_USER) -d $(DB_NAME)

appshell:
	docker compose run --rm -it $(APP) bash
