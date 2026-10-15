/* =========================================================
   04. Dòng tiền vào / ra của từng khách hàng
   net_flow = tiền vào TB/tháng - tiền ra TB/tháng
   net_flow < 0  -> tiêu nhiều hơn tiền nạp vào = có nhu cầu tín dụng
   ========================================================= */
USE data_bank;
GO

DROP TABLE IF EXISTS customer_cashflow;

WITH monthly AS (       -- mỗi KH, mỗi tháng
    SELECT
          customer_id
        , EOMONTH(txn_date) AS report_month
        , SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE 0 END) AS money_in
        , SUM(CASE WHEN txn_type IN ('withdrawal', 'purchase') THEN txn_amount ELSE 0 END) AS money_out
    FROM transactions_clean
    GROUP BY customer_id, EOMONTH(txn_date)
)
SELECT
      customer_id
    , COUNT(0) AS active_months
    , AVG(money_in + 0.0) AS avg_in
    , AVG(money_out + 0.0) AS avg_out
    , AVG(money_in + 0.0) - AVG(money_out + 0.0) AS net_flow
INTO customer_cashflow
FROM monthly
GROUP BY customer_id;

-- Gộp với thông tin KH -> bảng phân tích chính
DROP TABLE IF EXISTS customer_base;

SELECT
      T1.*
    , T1.income / 12.0 AS monthly_income
    , T2.active_months
    , T2.avg_in
    , T2.avg_out
    , T2.net_flow
    , CASE WHEN T2.net_flow < 0 THEN 1 ELSE 0 END AS is_deficit
INTO customer_base
FROM customer_clean T1
JOIN customer_cashflow T2 ON T1.ID = T2.customer_id;

SELECT COUNT(0) AS n, SUM(is_deficit) AS deficit_customers
FROM customer_base;   -- 495 KH, 283 KH thâm hụt (57%)
