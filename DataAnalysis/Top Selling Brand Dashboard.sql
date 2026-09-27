WITH brand_sales AS (
    SELECT
        p.brand,
        SUM(oi.sale_price) AS total_sales,
        COUNT(oi.id) AS total_quantity
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    JOIN products p
        ON oi.product_id = p.id
    WHERE o.status NOT IN ('Cancelled', 'Returned')
    GROUP BY p.brand
),
ranked_brands AS (
    SELECT
        DENSE_RANK() OVER (
            ORDER BY total_quantity DESC
        ) AS ranking,
        brand,
        total_sales,
        total_quantity
    FROM brand_sales
)

SELECT
    ranking,
    brand,
    ROUND(total_sales, 2) AS total_sales,
    total_quantity
FROM ranked_brands
WHERE ranking <= 10
ORDER BY ranking;