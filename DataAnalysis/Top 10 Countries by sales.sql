SELECT
    u.country,
    ROUND(SUM(oi.sale_price), 2) AS total_sales
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN users u
    ON oi.user_id = u.id
WHERE o.status NOT IN ('Cancelled', 'Returned')
GROUP BY u.country
ORDER BY total_sales DESC
LIMIT 10;