WITH monthly_data AS (
    SELECT
        DATE_FORMAT(o.created_at, '%Y-%m-01') AS month,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(DISTINCT o.user_id) AS total_customers
    FROM orders o
    WHERE o.status NOT IN ('Cancelled', 'Returned')
    GROUP BY DATE_FORMAT(o.created_at, '%Y-%m-01')
),
last_9_months AS (
    SELECT *
    FROM monthly_data
    ORDER BY month DESC
    LIMIT 9
)

SELECT
    month,
    total_orders,
    total_customers
FROM last_9_months
ORDER BY month;