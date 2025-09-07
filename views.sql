-- ====================================================================
-- 业务洞察视图创建
-- ====================================================================

-- Q1: 每种支付方式的交易数量和总销售数量
CREATE VIEW v_payment_method_summary AS
SELECT
    payment_method,
    COUNT(*) AS cnt_payment_methods,
    SUM(quantity) AS total_quantity
FROM
    walmart
GROUP BY
    payment_method;

-- Q2: 每个分支机构中评分最高的产品类别
CREATE VIEW v_branch_top_rated_category AS
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

-- Q3: 每个分支机构一周中最忙的一天（基于交易数量）
CREATE VIEW v_branch_busiest_day AS
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
        TRIM(TO_CHAR(TO_DATE(date, 'DD-MM-YY'), 'Day'))
) AS DailyTransactions
WHERE
    rk = 1;

-- Q4: 每种支付方式销售的物品总数量
CREATE VIEW v_payment_method_quantity AS
SELECT
    payment_method,
    SUM(quantity) AS total_quantity_sold
FROM
    walmart
GROUP BY
    payment_method;

-- Q5: 每个城市中每个产品类别的评分统计
CREATE VIEW v_city_category_rating_stats AS
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

-- Q6: 每个产品类别的总销售额和总利润
CREATE VIEW v_category_sales_profit AS
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

-- Q7: 每个分支机构中最常用的支付方式
CREATE VIEW v_branch_preferred_payment AS
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

-- Q8: 每个分支机构在不同时段的交易数量分布
CREATE VIEW v_branch_time_distribution AS
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

-- Q9: 2022年到2023年收入下降最大的5个分支机构
CREATE VIEW v_top5_revenue_decline_branches AS
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

-- ====================================================================
-- 视图使用示例
-- ====================================================================

-- 查询各支付方式摘要
SELECT * FROM v_payment_method_summary;

-- 查询各分支最高评分类别
SELECT * FROM v_branch_top_rated_category;

-- 查询各分支最忙的一天
SELECT * FROM v_branch_busiest_day;

-- 查询支付方式销量统计
SELECT * FROM v_payment_method_quantity;

-- 查询城市类别评分统计
SELECT * FROM v_city_category_rating_stats;

-- 查询类别销售利润
SELECT * FROM v_category_sales_profit;

-- 查询分支偏好支付方式
SELECT * FROM v_branch_preferred_payment;

-- 查询分支时段分布
SELECT * FROM v_branch_time_distribution;

-- 查询收入下降前5分支
SELECT * FROM v_top5_revenue_decline_branches;

-- ====================================================================
-- 视图管理命令（如需删除视图时使用）
-- ====================================================================

/*
DROP VIEW IF EXISTS v_payment_method_summary;
DROP VIEW IF EXISTS v_branch_top_rated_category;
DROP VIEW IF EXISTS v_branch_busiest_day;
DROP VIEW IF EXISTS v_payment_method_quantity;
DROP VIEW IF EXISTS v_city_category_rating_stats;
DROP VIEW IF EXISTS v_category_sales_profit;
DROP VIEW IF EXISTS v_branch_preferred_payment;
DROP VIEW IF EXISTS v_branch_time_distribution;
DROP VIEW IF EXISTS v_top5_revenue_decline_branches;
*/

COPY (SELECT
    payment_method,
    COUNT(*) AS cnt_payment_methods,
    SUM(quantity) AS total_quantity
FROM
    walmart
GROUP BY
    payment_method) TO 'D:/coding/DataAnalysis/Walmart Sales/payment_method_summary.csv' WITH CSV HEADER;