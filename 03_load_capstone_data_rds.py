"""
Joyeux Shoppers - AWS RDS MySQL 8.0 CSV Loader

Step 3:
Loads the seven CSV files into capstone_db on AWS RDS.

Requirements:
    pip install pymysql

Before running:
    Windows CMD:
        set RDS_PASSWORD=your_password
        python load_capstone_data_rds.py



import csv
import os
import sys
import time
import pymysql

# ------------------------------------------------------------
# AWS RDS configuration
# ------------------------------------------------------------
RDS_HOST = "joyeux-shoppers-db.c94wcos2i4y6.eu-north-1.rds.amazonaws.com"
RDS_PORT = 3306
RDS_USER = "admin"
RDS_DATABASE = "capstone_db"
RDS_PASSWORD = os.environ["RDS_PASSWORD"]


CSV_DIR = r"C:\Users\Admin\Downloads\dataTables"

BATCH_SIZE = 50_000
COMMIT_EVERY = 150_000
MAX_ATTEMPTS = 30

csv.field_size_limit(min(sys.maxsize, 2**31 - 1))

TABLES = [
    {
        "file": "distribution_centers.csv",
        "table": "distribution_centers",
        "columns": ["id", "name", "latitude", "longitude"],
        "timestamp_cols": [],
    },
    {
        "file": "users.csv",
        "table": "users",
        "columns": [
            "id", "first_name", "last_name", "email", "age", "gender",
            "state", "street_address", "postal_code", "city", "country",
            "latitude", "longitude", "traffic_source", "created_at",
        ],
        "timestamp_cols": ["created_at"],
    },
    {
        "file": "products.csv",
        "table": "products",
        "columns": [
            "id", "cost", "category", "name", "brand", "retail_price",
            "department", "sku", "distribution_center_id",
        ],
        "timestamp_cols": [],
    },
    {
        "file": "inventory_items.csv",
        "table": "inventory_items",
        "columns": [
            "id", "product_id", "created_at", "sold_at", "cost",
            "product_category", "product_name", "product_brand",
            "product_retail_price", "product_department", "product_sku",
            "product_distribution_center_id",
        ],
        "timestamp_cols": ["created_at", "sold_at"],
    },
    {
        "file": "orders.csv",
        "table": "orders",
        "columns": [
            "order_id", "user_id", "status", "gender", "created_at",
            "returned_at", "shipped_at", "delivered_at", "num_of_item",
        ],
        "timestamp_cols": [
            "created_at", "returned_at", "shipped_at", "delivered_at"
        ],
    },
    {
        "file": "order_items.csv",
        "table": "order_items",
        "columns": [
            "id", "order_id", "user_id", "product_id", "inventory_item_id",
            "status", "created_at", "shipped_at", "delivered_at",
            "returned_at", "sale_price",
        ],
        "timestamp_cols": [
            "created_at", "shipped_at", "delivered_at", "returned_at"
        ],
    },
    {
        "file": "events.csv",
        "table": "events",
        "columns": [
            "id", "user_id", "sequence_number", "session_id", "created_at",
            "ip_address", "city", "state", "postal_code", "browser",
            "traffic_source", "uri", "event_type",
        ],
        "timestamp_cols": ["created_at"],
    },
]


def clean_value(value, column_name, timestamp_cols):
    """Convert CSV blanks/NaN to NULL and remove the UTC suffix."""
    if value is None:
        return None

    value = value.strip()

    if value == "" or value.lower() == "nan":
        return None

    if column_name in timestamp_cols and value.endswith(" UTC"):
        return value[:-4]

    return value


def build_insert_sql(table_name, columns):
    column_sql = ", ".join(columns)
    placeholders = ", ".join(["%s"] * len(columns))
    return (
        f"INSERT INTO {table_name} "
        f"({column_sql}) VALUES ({placeholders})"
    )


def count_csv_rows(file_path):
    with open(file_path, "r", encoding="utf-8", errors="replace") as file:
        return sum(1 for _ in file) - 1


def rows_already_loaded(cursor, table_name):
    cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
    return cursor.fetchone()[0]


def connect():
    connection = pymysql.connect(
        host=RDS_HOST,
        port=RDS_PORT,
        user=RDS_USER,
        password=RDS_PASSWORD,
        database=RDS_DATABASE,
        connect_timeout=30,
        read_timeout=1800,
        write_timeout=1800,
        autocommit=False,
    )

    cursor = connection.cursor()
    cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
    cursor.execute("SET UNIQUE_CHECKS = 0")

    return connection, cursor


def load_one_table(connection, cursor, table_def):
    file_path = os.path.join(CSV_DIR, table_def["file"])
    table_name = table_def["table"]
    columns = table_def["columns"]
    timestamp_cols = set(table_def["timestamp_cols"])

    if not os.path.exists(file_path):
        raise FileNotFoundError(file_path)

    total_rows = count_csv_rows(file_path)
    already_loaded = rows_already_loaded(cursor, table_name)

    print(f"\n{'=' * 70}")
    print(f"{table_name}: {total_rows:,} CSV rows")

    if already_loaded >= total_rows:
        print(f"SKIP: {already_loaded:,} rows already loaded")
        return 0

    print(
        f"Loading from row {already_loaded + 1:,} "
        f"to {total_rows:,}"
    )

    insert_sql = build_insert_sql(table_name, columns)
    batch = []
    inserted = 0
    since_commit = 0
    start_time = time.time()

    with open(
        file_path,
        "r",
        encoding="utf-8",
        errors="replace",
        newline=""
    ) as file:
        reader = csv.DictReader(file)

        # Resume from the last committed row.
        for _ in range(already_loaded):
            next(reader, None)

        for row in reader:
            values = tuple(
                clean_value(row[column], column, timestamp_cols)
                for column in columns
            )
            batch.append(values)

            if len(batch) >= BATCH_SIZE:
                cursor.executemany(insert_sql, batch)

                inserted += len(batch)
                since_commit += len(batch)
                batch.clear()

                if since_commit >= COMMIT_EVERY:
                    connection.commit()
                    since_commit = 0

                done = already_loaded + inserted
                elapsed = time.time() - start_time
                rate = inserted / elapsed if elapsed else 0

                print(
                    f"{table_name}: "
                    f"{done:,}/{total_rows:,} "
                    f"({done / total_rows:.1%}) "
                    f"{rate:,.0f} rows/s",
                    flush=True,
                )

        if batch:
            cursor.executemany(insert_sql, batch)
            inserted += len(batch)

    connection.commit()

    elapsed = time.time() - start_time
    rate = inserted / elapsed if elapsed else 0

    print(
        f"{table_name}: DONE - "
        f"{inserted:,} rows in {elapsed / 60:.1f} minutes "
        f"({rate:,.0f} rows/s)"
    )

    return inserted


def run_once():
    connection, cursor = connect()

    cursor.execute("SELECT VERSION()")
    print("Connected to:", RDS_HOST)
    print("MySQL version:", cursor.fetchone()[0])
    print("Database:", RDS_DATABASE)

    total_loaded = 0

    for table_def in TABLES:
        total_loaded += load_one_table(
            connection,
            cursor,
            table_def
        )

    cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
    cursor.execute("SET UNIQUE_CHECKS = 1")
    connection.commit()

    cursor.close()
    connection.close()

    print(f"\nALL DONE: {total_loaded:,} rows loaded this run.")


def main():
    for attempt in range(1, MAX_ATTEMPTS + 1):
        try:
            run_once()
            return

        except (
            pymysql.err.DataError,
            pymysql.err.IntegrityError,
            pymysql.err.ProgrammingError,
            pymysql.err.NotSupportedError,
        ):
            # Real schema/data errors should not be hidden by retries.
            raise

        except Exception as error:
            if attempt == MAX_ATTEMPTS:
                raise

            wait_seconds = min(300, 30 * attempt)

            print(
                f"\nTemporary connection failure: "
                f"{type(error).__name__}: {error}"
            )
            print(
                f"Retry {attempt}/{MAX_ATTEMPTS} "
                f"in {wait_seconds} seconds..."
            )

            time.sleep(wait_seconds)


if __name__ == "__main__":
    main()
