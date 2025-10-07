# Airbnb London Prices — ML Engineer Handover

## Project Overview
This project aims to model **Airbnb listing prices and related host/market dynamics** using the London dataset.
The dataset has been cleaned, structured, and loaded into a **PostgreSQL database running in Docker**, with supporting SQL scripts and a reproducible pipeline.

**Goal:** prepare a machine learning–ready dataset for regression and exploratory modelling (price prediction, occupancy estimation, etc.).

---

## Repository Layout

```
airbnb-london-prices/
│
├── sql/
│   ├── schema.sql      # defines raw schema structure
│   ├── load.sql        # loads listings + reviews CSVs
│   ├── indexes.sql     # performance indexes
│
├── notebooks/
│   ├── listings_feature_engineering.ipynb      # cleaning + feature prep
│   ├── eda_listings.ipynb                # exploratory visualisations
│
├── docker-compose.yml   # defines Postgres + app containers
├── Makefile             # orchestration commands
└── README.md            # high-level notes
```

---

## Environment & Setup

### Docker Services
- **`db`** — PostgreSQL 16 container
  Credentials:
  ```
  user: airbnb
  password: airbnb
  database: airbnb
  host: db
  port: 5432
  ```
- **`app`** — Python/Jupyter environment (with psycopg2, SQLAlchemy, pandas, seaborn, plotly)

### Key Makefile Targets
| Command | Description |
|----------|-------------|
| `make up` | Start containers |
| `make db` | Run schema + load + index scripts |
| `make verify` | Verify that tables and counts loaded |
| `make reset` | Full teardown and reload |
| `make appshell` | Bash shell inside app container |
| `make dbshell` | psql shell in database |

---

## Data Schemas

### `raw` schema
Source data loaded from CSVs:
- **`raw.listings`** (~96k rows)
- **`raw.reviews`** (~2M rows)

### `cleaned` schema
Refined, ML-ready tables:
- **`cleaned.listings_base`** → base features (price, host, property, availability, etc.)
- **`cleaned.listing_amenities_wide`** → pivoted one-hot for modeling `(listing_id, amenity)`

---

## Data Notes
- Prices parsed and stored as numeric (`price_num`).
- Host attributes cleaned and typed (`host_since` → datetime, `host_tenure_yrs` derived).
- Amenities normalized and stored separately.
- Reviews kept raw for aggregation on demand (e.g., average rating per listing).

---

## For the ML Engineer

### Next Steps
**Accessing the Cleaned Tables**
From Inside Docker
Start services
  `make up`            # or: `make db`   (schema + load + indexes)

**Launch Jupyter in the app container**
`docker compose up app` #copy the token URL from logs and open in your browser

**Load cleaned data**
   ```python
   import pandas as pd
   from sqlalchemy import create_engine, text
   import os

   engine = create_engine(os.getenv("DATABASE_URL"), pool_pre_ping=True)
   listings = pd.read_sql("SELECT * FROM cleaned.listings_base", engine)
   amenities = pd.read_sql("SELECT * FROM cleaned.listing_amenities_wide", engine)
   ```

2. **Feature Engineering**
   - One-hot encode **amenities** (select top-N frequent ones).
   - Aggregate review metrics per listing.
   - Create derived features:
     - `price_per_person = price_num / accommodates`
     - `occupancy_rate = estimated_occupancy_l365d`
     - `revenue_per_bed = estimated_revenue_l365d / beds`
     - `host_tenure_yrs`, `reviews_per_month`, etc.

3. **Modeling Targets**
   - **Primary:** `price`
   - **Secondary:** `estimated_occupancy_l365d`, `estimated_revenue_l365d`

4. **Recommended Baselines**
   - Linear Regression / Lasso
   - Gradient Boosting (LightGBM, XGBoost)
   - Tree ensembles with SHAP feature explanations

5. **EDA Notebook (`02_eda.ipynb`)**
   - Includes ready-to-run visualizations for price, host behavior, occupancy, and revenue.
   - Uses seaborn/matplotlib; can extend to plotly for interactivity.

---

## Verification Commands

To confirm data load and counts:
```bash
make verify
# or within SQL:
SELECT COUNT(*) FROM cleaned.listings_base;
SELECT COUNT(*) FROM cleaned.listing_amenities;
```

---

## Contacts & Handover Notes
**Data Source:** Airbnb London open dataset (listings.csv + reviews.csv)
**DB Host:** Docker internal (`db`)
**Access Method:** via app container (`psql -h db -U airbnb -d airbnb`)
**Owner:** Yahya Risasi (Data Science & Data Pipeline Setup)
**Next Owner:** [Emmanuelle Torissi]

---

**In summary**
- All data is cleaned, structured, and versioned inside Postgres (Dockerized).
- The ML Engineer can load from `cleaned.listings_base` and `cleaned.listing_amenities`.
- Recommended next step: further feature engineering + baseline modeling (price prediction).
