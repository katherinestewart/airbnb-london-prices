CREATE INDEX IF NOT EXISTS idx_raw_listings_id
  ON raw.listings(id);

CREATE INDEX IF NOT EXISTS idx_raw_reviews_listing
  ON raw.reviews(listing_id);
