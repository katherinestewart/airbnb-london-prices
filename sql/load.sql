\echo 'Loading listings...'
\copy raw.listings FROM '/app/data/raw/listings.csv' CSV HEADER;

\echo 'Loading reviews...'
\copy raw.reviews  FROM '/app/data/raw/reviews.csv'  CSV HEADER;

\echo 'Counts:'
SELECT 'listings' AS table, COUNT(*) FROM raw.listings
UNION ALL
SELECT 'reviews', COUNT(*) FROM raw.reviews;
