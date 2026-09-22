# Joyeux Shoppers — Data Preparation & Loading

## Deliverables

1. `01_rds_setup.sql` — Step 1 database setup for AWS RDS MySQL 8.0.
2. `02_capstone_ddl.sql` — Step 2: all seven table DDL statements in one SQL file.
3. `03_erd_screenshot.png` — Step 3 ERD screenshot for the GitHub repository.
4. `04_load_capstone_data_rds.py` — Step 4 Python loader for all seven CSV files.

## Database

- Database: `capstone_db`
- Engine: MySQL 8.0 on AWS RDS
- RDS endpoint: `joyeux-shoppers-db.c94wcos2i4y6.eu-north-1.rds.amazonaws.com`
- Port: `3306`

## Tables

1. `distribution_centers`
2. `users`
3. `products`
4. `inventory_items`
5. `orders`
6. `order_items`
7. `events`

## Load order

The Python loader uses this dependency order:

`distribution_centers -> users -> products -> inventory_items -> orders -> order_items -> events`

This keeps the foreign-key relationships valid.

## Run the loader

Install the driver:

```bash
pip install pymysql
```

Set the password in Windows CMD:

```cmd
set RDS_PASSWORD=YOUR_RDS_PASSWORD
```

Then edit `CSV_DIR` in the Python script and run:

```cmd
python 04_load_capstone_data_rds.py
```

The password is read from an environment variable and is not stored in the repository.

## GitHub structure

```text
joyeux-shoppers-capstone/
├── 01_rds_setup.sql
├── 02_capstone_ddl.sql
├── 03_erd_screenshot.png
├── 04_load_capstone_data_rds.py
└── README.md
```
"# Joyeux-Shoppers-Project" 
