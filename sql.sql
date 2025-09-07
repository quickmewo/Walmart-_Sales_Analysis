-- ====================================================================
-- Initial Data Exploration
-- ====================================================================

-- Quick look at the raw data structure and content.
SELECT * FROM walmart;

-- Count transactions for each payment method.
SELECT
    payment_method,
    COUNT(*) AS transaction_count
FROM
    walmart
GROUP BY
    payment_method;

-- Count transactions for each product category.
SELECT
    category,
    COUNT(*) AS transaction_count
FROM
    walmart
GROUP BY
    category;

-- Find the overall minimum and maximum quantity per single transaction.
SELECT
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity
FROM
    walmart;

-- ====================================================================
-- Business Insights
-- ====================================================================

-- Q1: What is the number of transactions and total quantity sold for each payment method?
SELECT
    payment_method,
    COUNT(*) AS cnt_payment_methods,
    SUM(quantity) AS total_quantity
FROM
    walmart
GROUP BY
    payment_method;

-- Q2: What is the highest-rated product category within each branch?
WITH RankedRatings AS (
    SELECT
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rk
    FROM
        walmart
    GROUP BY
        branch,
        category
)
SELECT
    branch,
    category,
    avg_rating
FROM
    RankedRatings
WHERE
    rk = 1;

-- Q3: What is the busiest day of the week for each branch based on the number of transactions?
SELECT
    branch,
    day_name,
    cnt_trans
FROM (
    SELECT
        branch,
        TRIM(TO_CHAR(TO_DATE(date, 'DD-MM-YY'), 'Day')) AS day_name,
        COUNT(*) AS cnt_trans,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rk
    FROM
        walmart
    GROUP BY
        branch,
        day_name
) AS DailyTransactions
WHERE
    rk = 1;

-- Q4: What is the total quantity of items sold per payment method?
SELECT
    payment_method,
    SUM(quantity) AS total_quantity_sold
FROM
    walmart
GROUP BY
    payment_method;

-- Q5: What are the minimum, maximum, and average ratings for each product category in each city?
SELECT
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM
    walmart
GROUP BY
    city,
    category
ORDER BY
    city,
    category;

-- Q6: What are the total sales and total profit for each product category?
SELECT
    category,
    SUM(total_amount) AS total_sales,
    SUM(profit_margin * quantity) AS total_profit
FROM
    walmart
GROUP BY
    category
ORDER BY
    total_sales DESC;

-- Q7: What is the most frequently used payment method in each branch?
SELECT
    branch,
    payment_method,
    cnt_payment_methods
FROM (
    SELECT
        branch,
        payment_method,
        COUNT(*) AS cnt_payment_methods,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rk
    FROM
        walmart
    GROUP BY
        branch,
        payment_method
) AS PaymentRank
WHERE
    rk = 1;

-- Q8: How many transactions occur in the morning, afternoon, and evening at each branch?
WITH TimeOfDay AS (
    SELECT
        branch,
        CASE
            WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'morning'
            WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'afternoon'
            ELSE 'evening'
        END AS time_of_day
    FROM
        walmart
)
SELECT
    branch,
    time_of_day,
    COUNT(*) AS cnt_transactions
FROM
    TimeOfDay
GROUP BY
    branch,
    time_of_day
ORDER BY
    branch,
    CASE time_of_day
        WHEN 'morning' THEN 1
        WHEN 'afternoon' THEN 2
        ELSE 3
    END;

-- Q9: Which 5 branches had the largest percentage decrease in revenue from 2022 to 2023?
WITH t_2023 AS (
    SELECT
        branch,
        SUM(total_amount) AS revenue_2023
    FROM
        walmart
    WHERE
        EXTRACT(YEAR FROM TO_DATE(date, 'DD-MM-YY')) = 2023
    GROUP BY
        branch
),
t_2022 AS (
    SELECT
        branch,
        SUM(total_amount) AS revenue_2022
    FROM
        walmart
    WHERE
        EXTRACT(YEAR FROM TO_DATE(date, 'DD-MM-YY')) = 2022
    GROUP BY
        branch
)
SELECT
    t_2022.branch,
    t_2022.revenue_2022,
    t_2023.revenue_2023,
    (t_2023.revenue_2023 - t_2022.revenue_2022) / t_2022.revenue_2022 * 100 AS revenue_growth,
    TO_CHAR(ABS((t_2023.revenue_2023 - t_2022.revenue_2022) / t_2022.revenue_2022) * 100, 'FM999.00') || '%' AS revenue_desc_ratio
FROM
    t_2022
JOIN t_2023
    ON t_2022.branch = t_2023.branch
WHERE
    (t_2023.revenue_2023 - t_2022.revenue_2022) / t_2022.revenue_2022 < 0
ORDER BY
    revenue_growth ASC
LIMIT 5;

