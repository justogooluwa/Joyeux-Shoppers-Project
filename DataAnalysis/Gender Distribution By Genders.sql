SELECT
    u.gender,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN users u
    ON o.user_id = u.id
WHERE o.status NOT IN ('Cancelled', 'Returned')
GROUP BY u.gender
ORDER BY total_orders DESC;