WITH product_sales AS (
    SELECT
        p.id AS product_id,
        p.name AS product_name,
        SUM(oi.sale_price) AS total_sales,
        COUNT(oi.id) AS total_quantity
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    JOIN products p
        ON oi.product_id = p.id
    WHERE o.status NOT IN ('Cancelled', 'Returned')
    GROUP BY
        p.id,
        p.name
)

SELECT
    RANK() OVER (
        ORDER BY total_quantity DESC
    ) AS ranking,
    product_id,
    product_name,
    ROUND(total_sales, 2) AS total_sales,
    total_quantity
FROM product_sales
ORDER BY ranking;