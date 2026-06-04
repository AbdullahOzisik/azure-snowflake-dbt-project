"""Voer een .sql-bestand in z'n geheel uit tegen Snowflake — handig als je
geen snowsql CLI hebt en Snowsight-gedoe wilt vermijden.

Gebruik (vanuit de venv, met SNOWFLAKE_USER/PASSWORD gezet):
    python snowflake/run_sql.py snowflake/01_setup.sql
    python snowflake/run_sql.py snowflake/02_seed_raw_data.sql

Verbindt als ACCOUNTADMIN en draait alle statements in volgorde.
'YOUR_USERNAME' in het script wordt vervangen door je SNOWFLAKE_USER.
"""

import os
import sys
import pathlib

import snowflake.connector

ACCOUNT = os.environ.get("SNOWFLAKE_ACCOUNT", "AFHVMYZ-UX38783")
USER = os.environ["SNOWFLAKE_USER"]
PASSWORD = os.environ["SNOWFLAKE_PASSWORD"]

sql_path = pathlib.Path(sys.argv[1])
sql = sql_path.read_text(encoding="utf-8").replace("YOUR_USERNAME", USER)

con = snowflake.connector.connect(
    account=ACCOUNT,
    user=USER,
    password=PASSWORD,
    role="ACCOUNTADMIN",
)
try:
    for cur in con.execute_string(sql):
        first_line = (cur.query or "").strip().splitlines()[0][:70]
        print(f"  OK  {first_line}")
finally:
    con.close()

print(f"Klaar: {sql_path}")
