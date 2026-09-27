WITH channel_sales AS (
    SELECT
        u.traffic_source AS channel,
        ROUND(SUM(oi.sale_price), 2) AS total_sales,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    JOIN users u
        ON o.user_id = u.id
    WHERE o.status NOT IN ('Cancelled', 'Returned')
    GROUP BY u.traffic_source
)

SELECT
    channel,
    total_sales,
    total_orders
FROM channel_sales
ORDER BY total_sales DESC
LIMIT 3;