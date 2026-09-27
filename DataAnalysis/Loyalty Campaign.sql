SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
    u.email,
    u.country,
    u.gender,
    ROUND(SUM(oi.sale_price), 2) AS total_revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN users u
    ON oi.user_id = u.id
JOIN products p
    ON oi.product_id = p.id
WHERE o.status NOT IN ('Cancelled', 'Returned')
  AND u.country = 'Germany'
  AND u.gender = 'F'
  AND p.brand = 'Calvin Klein'
GROUP BY
    u.id,
    u.first_name,
    u.last_name,
    u.email,
    u.country,
    u.gender
ORDER BY total_revenue DESC
LIMIT 5;