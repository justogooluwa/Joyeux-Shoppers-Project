SELECT
    u.gender,
    ROUND(SUM(oi.sale_price), 2) AS total_revenue,
    COUNT(oi.id) AS total_items_purchased
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN users u
    ON oi.user_id = u.id
WHERE o.status NOT IN ('Cancelled', 'Returned')
GROUP BY u.gender
ORDER BY total_revenue DESC;