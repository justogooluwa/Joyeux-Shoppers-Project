SELECT country, gender, COUNT(DISTINCT id) as total_customers 
FROM users
GROUP BY country, gender
ORDER BY country, total_customers DESC;