import os
from sqlalchemy import create_engine, text
url = os.getenv("DATABASE_URL", "postgresql+psycopg2://airbnb:airbnb@db:5432/airbnb")
engine = create_engine(url, pool_pre_ping=True, future=True)
with engine.connect() as c:
    print("DB version:", c.execute(text("SELECT version()")).scalar())
