.PHONY: up schema load indexes db verify down reset

up:
	docker compose up -d

schema: up
	docker compose exec -T db psql -U airbnb -d airbnb -f /work/sql/schema.sql

load:
	docker compose exec -T db psql -U airbnb -d airbnb -f /work/sql/load.sql

indexes:
	docker compose exec -T db psql -U airbnb -d airbnb -f /work/sql/indexes.sql

db: up schema load indexes

verify:
	docker compose exec -T db psql -U airbnb -d airbnb -c "\dt raw.*"
	docker compose exec -T db psql -U airbnb -d airbnb -c "SELECT COUNT(*) FROM raw.listings;"
	docker compose exec -T db psql -U airbnb -d airbnb -c "SELECT COUNT(*) FROM raw.reviews;"
	docker compose exec -T db psql -U airbnb -d airbnb -c "\d raw.listings"
	docker compose exec -T db psql -U airbnb -d airbnb -c "\d raw.reviews"

down:
	docker compose down

reset:
	docker compose down -v
	docker compose up -d
	sleep 5
	docker compose exec -T db psql -U airbnb -d airbnb -f /work/sql/schema.sql
	docker compose exec -T db psql -U airbnb -d airbnb -f /work/sql/load.sql
	docker compose exec -T db psql -U airbnb -d airbnb -f /work/sql/indexes.sql

count_rows:
	docker compose exec -T db psql -U airbnb -d airbnb -c "\
	SELECT 'listings' AS table, COUNT(*) AS n FROM raw.listings \
	UNION ALL \
	SELECT 'reviews', COUNT(*) FROM raw.reviews;"
