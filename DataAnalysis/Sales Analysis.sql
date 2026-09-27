USE capstone_db;

SELECT
    DATE_FORMAT(o.created_at, '%Y-%m-01') AS month,
    ROUND(SUM(oi.sale_price), 2) AS total_sales,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.user_id) AS customer_count
FROM orders as o
JOIN order_items as oi
    ON o.order_id = oi.order_id
WHERE o.status NOT IN ('Cancelled', 'Returned')
GROUP BY DATE_FORMAT(o.created_at, '%Y-%m-01')
ORDER BY month;