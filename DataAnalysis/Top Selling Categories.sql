WITH category_sales AS (
    SELECT
        p.category,
        SUM(oi.sale_price) AS total_sales,
        COUNT(oi.id) AS total_quantity
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    JOIN products p
        ON oi.product_id = p.id
    WHERE o.status NOT IN ('Cancelled', 'Returned')
    GROUP BY p.category
)

SELECT
    ROW_NUMBER() OVER (
        ORDER BY total_quantity DESC
    ) AS ranking,
    category,
    ROUND(total_sales, 2) AS total_sales,
    total_quantity
FROM category_sales
ORDER BY ranking;