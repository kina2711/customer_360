-- Tính giá trị RFM
SELECT
    CustomerID AS customer_id,
    MIN(CAST(created_date AS DATE)) AS created_date,
    COUNT(DISTINCT(CAST(Purchase_Date AS DATE))) AS total_purchases,
    (DATEDIFF(YEAR, MIN(CAST(created_date AS DATE)), '2022-09-01') + 1) AS contract_year,
    DATEDIFF(DAY, MAX(CAST(Purchase_Date AS DATE)), '2022-09-01') AS recency,
    1.0 * COUNT(DISTINCT(CAST(Purchase_Date AS DATE))) / (DATEDIFF(YEAR, MIN(CAST(created_date AS DATE)), '2022-09-01') + 1) AS frequency,
    SUM(CAST(GMV AS BIGINT)) / (DATEDIFF(YEAR, MIN(CAST(created_date AS DATE)), '2022-09-01') + 1) AS monetary,
    ROW_NUMBER() OVER (ORDER BY DATEDIFF(DAY, MAX(CAST(Purchase_Date AS DATE)), '2022-09-01')) AS rn_recency,
    ROW_NUMBER() OVER (ORDER BY 1.0 * COUNT(DISTINCT(CAST(Purchase_Date AS DATE))) / (DATEDIFF(YEAR, MIN(CAST(created_date AS DATE)), '2022-09-01') + 1)) AS rn_frequency,
    ROW_NUMBER() OVER (ORDER BY SUM(CAST(GMV AS BIGINT)) / (DATEDIFF(YEAR, MIN(CAST(created_date AS DATE)), '2022-09-01') + 1)) AS rn_monetary
INTO #rfm_raw
FROM Customer_Registered cr
JOIN Customer_Transaction ct ON cr.ID = ct.CustomerID
WHERE created_date < '2022-09-01'
    AND created_date != ''
    AND created_date IS NOT NULL
    AND stopdate != ''
    AND stopdate IS NOT NULL
    AND cr.ID != 0
    AND ct.GMV > 0
GROUP BY CustomerID
HAVING SUM(GMV) > 0;

-- Tính toán điểm RFM
SELECT
    *,
    CASE
        WHEN recency >= (SELECT recency FROM #rfm_raw WHERE rn_recency = 1)
            AND recency < (SELECT recency FROM #rfm_raw WHERE rn_recency = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.25 AS INT) FROM #rfm_raw))
            THEN '4'
        WHEN recency >= (SELECT recency FROM #rfm_raw WHERE rn_recency = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.25 AS INT) FROM #rfm_raw))
            AND recency < (SELECT recency FROM #rfm_raw WHERE rn_recency = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.5 AS INT) FROM #rfm_raw))
            THEN '3'
        WHEN recency >= (SELECT recency FROM #rfm_raw WHERE rn_recency = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.5 AS INT) FROM #rfm_raw))
            AND recency < (SELECT recency FROM #rfm_raw WHERE rn_recency = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.75 AS INT) FROM #rfm_raw))
            THEN '2'
        ELSE '1'
    END AS R,
    CASE
        WHEN frequency >= (SELECT frequency FROM #rfm_raw WHERE rn_frequency = 1)
            AND frequency < (SELECT frequency FROM #rfm_raw WHERE rn_frequency = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.25 AS INT) FROM #rfm_raw))
            THEN '1'
        WHEN frequency >= (SELECT frequency FROM #rfm_raw WHERE rn_frequency = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.25 AS INT) FROM #rfm_raw))
            AND frequency < (SELECT frequency FROM #rfm_raw WHERE rn_frequency = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.5 AS INT) FROM #rfm_raw))
            THEN '2'
        WHEN frequency >= (SELECT frequency FROM #rfm_raw WHERE rn_frequency = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.5 AS INT) FROM #rfm_raw))
            AND frequency < (SELECT frequency FROM #rfm_raw WHERE rn_frequency = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.75 AS INT) FROM #rfm_raw))
            THEN '3'
        ELSE '4'
    END AS F,
    CASE
        WHEN monetary >= (SELECT monetary FROM #rfm_raw WHERE rn_monetary = 1)
            AND monetary < (SELECT monetary FROM #rfm_raw WHERE rn_monetary = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.25 AS INT) FROM #rfm_raw))
            THEN '1'
        WHEN monetary >= (SELECT monetary FROM #rfm_raw WHERE rn_monetary = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.25 AS INT) FROM #rfm_raw))
            AND monetary < (SELECT monetary FROM #rfm_raw WHERE rn_monetary = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.5 AS INT) FROM #rfm_raw))
            THEN '2'
        WHEN monetary >= (SELECT monetary FROM #rfm_raw WHERE rn_monetary = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.5 AS INT) FROM #rfm_raw))
            AND monetary < (SELECT monetary FROM #rfm_raw WHERE rn_monetary = (SELECT CAST(COUNT(DISTINCT customer_id) * 0.75 AS INT) FROM #rfm_raw))
            THEN '3'
        ELSE '4'
    END AS M
INTO #rfm_score
FROM #rfm_raw;

-- Kết hợp điểm R, F và M
SELECT
    *,
    CONCAT(R, F, M) AS rfm
INTO all_rfm_score
FROM #rfm_score;

-- Phân loại khách hàng dựa trên RFM score
CREATE VIEW rfm_statistic AS
SELECT
    *,
    CASE
        WHEN rfm IN ('444', '443', '434', '344') THEN 'Champions'
        WHEN rfm IN ('442', '441', '432', '431', '433', '343', '342', '341') THEN 'Loyal Customer'
        WHEN rfm IN ('424', '423', '324', '323', '413', '414', '343', '334') THEN 'Potential Loyalist'
        WHEN rfm IN ('333', '332', '331', '313') THEN 'Promising'
        WHEN rfm IN ('422', '421', '412', '411', '311', '321', '312', '322') THEN 'New Customer'
        WHEN rfm IN ('131', '132', '141', '142', '231', '232', '241', '242') THEN 'Price Sensitive'
        WHEN rfm IN ('244', '234', '243', '233', '224', '214', '213', '134', '144', '143', '133') THEN 'Need Attention'
        WHEN rfm IN ('244', '234', '243', '233', '224', '214', '213', '134', '144', '143', '133') THEN 'At Risk Customers'
        WHEN rfm IN ('111', '112', '113', '114', '121', '122', '123', '221', '211', '222') THEN 'Lost Customer'
        ELSE 'Other'
    END AS customer_type
FROM all_rfm_score;

-- Gọi VIEW
SELECT * FROM rfm_statistic;
