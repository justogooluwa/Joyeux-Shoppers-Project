WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(o.created_at, '%Y-%m-01') AS month,
        SUM(oi.sale_price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.status NOT IN ('Cancelled', 'Returned')
    GROUP BY DATE_FORMAT(o.created_at, '%Y-%m-01')
),
last_9_months AS (
    SELECT
        month,
        revenue
    FROM monthly_sales
    ORDER BY month DESC
    LIMIT 9
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue
FROM last_9_months
ORDER BY month;