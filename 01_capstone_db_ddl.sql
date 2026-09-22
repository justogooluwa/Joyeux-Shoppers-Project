DROP DATABASE IF EXISTS `capstone_db`;
CREATE DATABASE `capstone_db`;

USE `capstone_db`;





-- 1. DISTRIBUTION CENTERS


CREATE TABLE distribution_centers (
    id INT NOT NULL,
    name VARCHAR(100),
    latitude DECIMAL(10,4),
    longitude DECIMAL(10,4),

    PRIMARY KEY (id)
);



-- 2. PRODUCTS


CREATE TABLE products (
    id INT NOT NULL,
    cost DECIMAL(10,5),
    category VARCHAR(100),
    name VARCHAR(300),
    brand VARCHAR(100),
    retail_price DECIMAL(10,4),
    department VARCHAR(100),
    sku VARCHAR(100),
    distribution_center_id INT,

    PRIMARY KEY (id),

    CONSTRAINT fk_products_distribution_center
        FOREIGN KEY (distribution_center_id)
        REFERENCES distribution_centers(id)
);



-- 3. USERS


CREATE TABLE users (
    id INT NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100),
    age INT,
    gender VARCHAR(100),
    state VARCHAR(100),
    street_address VARCHAR(100),
    postal_code VARCHAR(100),
    city VARCHAR(100),
    country VARCHAR(100),
    latitude DECIMAL(10,5),
    longitude DECIMAL(10,5),
    traffic_source VARCHAR(100),
    created_at DATETIME,

    PRIMARY KEY (id)
);



-- 4. ORDERS


CREATE TABLE orders (
    order_id INT NOT NULL,
    user_id INT,
    status VARCHAR(100),
    gender VARCHAR(100),
    created_at DATETIME,
    returned_at DATETIME,
    shipped_at DATETIME,
    delivered_at DATETIME,
    num_of_item INT,

    PRIMARY KEY (order_id),

    CONSTRAINT fk_orders_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
);



-- 5. INVENTORY ITEMS



CREATE TABLE inventory_items (
    id INT NOT NULL,
    product_id INT,
    created_at DATETIME,
    sold_at DATETIME,
    cost DECIMAL(10,5),
    product_category VARCHAR(100),
    product_name VARCHAR(300),
    product_brand VARCHAR(100),
    product_retail_price DECIMAL(10,3),
    product_department VARCHAR(100),
    product_sku VARCHAR(100),
    product_distribution_center_id INT,

    PRIMARY KEY (id),

    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id)
        REFERENCES products(id),

    CONSTRAINT fk_inventory_distribution_center
        FOREIGN KEY (product_distribution_center_id)
        REFERENCES distribution_centers(id)
);



-- 6. ORDER ITEMS


CREATE TABLE order_items (
    id INT NOT NULL,
    order_id INT,
    user_id INT,
    product_id INT,
    inventory_item_id INT,
    status VARCHAR(100),
    created_at DATETIME,
    shipped_at DATETIME,
    delivered_at DATETIME,
    returned_at DATETIME,
    sale_price DECIMAL(10,2),

    PRIMARY KEY (id),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_order_items_user
        FOREIGN KEY (user_id)
        REFERENCES users(id),

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(id),

    CONSTRAINT fk_order_items_inventory
        FOREIGN KEY (inventory_item_id)
        REFERENCES inventory_items(id)
);



-- 7. EVENTS


CREATE TABLE events (
    id INT NOT NULL,
    user_id INT,
    sequence_number INT,
    session_id VARCHAR(100),
    created_at DATETIME,
    ip_address VARCHAR(50),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(100),
    browser VARCHAR(100),
    traffic_source VARCHAR(100),
    uri VARCHAR(100),
    event_type VARCHAR(100),

    PRIMARY KEY (id),

    CONSTRAINT fk_events_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
);


