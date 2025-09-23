# Clean Schema Handover (for Yahaya)

## Input
- raw.listings
- raw.reviews

## Output
- clean.listings_features (or some other name you prefer)

## Todo suggestions
1. **Data typing**
   - Everything is currently TEXT
   - Convert price from text to numeric.
   - Cast latitude/longitude to REAL.
   - Cast review scores to numeric.

2. **Feature engineering**
   - Move amenities into dummy columns or counts.
   - Create new features (e.g., host_is_superhost -> boolean).
   - Handle missing values (decide defaults or drop).

3. **Data cleaning**
   - Remove duplicates if any.
   - Filter unrealistic values (eg price < 0, minimum_nights really high).
   - Standardise categorical text if needed?

4. **Documentation**
   - Write a short feature dictionary describing each engineered column.
   - Save as docs/feature_dictionary.md
   - This could be useful for Dipali kinda like a handover?

## Notes
- Don't overwrite raw.* tables.
- All your cleaned/engineered tables stored in the clean schema so everything is clear.
