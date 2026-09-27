SELECT
    CASE
        WHEN age <= 12 THEN 'Kids'
        WHEN age BETWEEN 13 AND 19 THEN 'Teenager'
        WHEN age BETWEEN 20 AND 55 THEN 'Adult'
        WHEN age >= 56 THEN 'Senior'
        ELSE 'Unknown'
    END AS age_group,
    COUNT(*) AS customer_count
FROM users
GROUP BY
    CASE
        WHEN age <= 12 THEN 'Kids'
        WHEN age BETWEEN 13 AND 19 THEN 'Teenager'
        WHEN age BETWEEN 20 AND 55 THEN 'Adult'
        WHEN age >= 56 THEN 'Senior'
        ELSE 'Unknown'
    END
ORDER BY customer_count DESC;