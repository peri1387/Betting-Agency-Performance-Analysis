CREATE DATABASE opap_store;
USE opap_store;   

CREATE TABLE transactions (
    Transaction_ID INT NOT NULL PRIMARY KEY,
    Date DATE NOT NULL,
    Game_Type VARCHAR(255) NOT NULL,
    Amount_Staked DECIMAL(10, 2) NOT NULL,
    Payout_Amount DECIMAL(10, 2),
    Customer_Type ENUM('Regular', 'Occasional', 'VIP') NOT NULL
);   

-- 1) GGR (Gross Gaming Revenue)
SELECT SUM(Amount_Staked) AS Total_Sales, 
       SUM(Payout_Amount) AS Total_Payouts,
       SUM(Amount_Staked) - SUM(Payout_Amount) AS GGR
FROM transactions;

-- 2) Performance per Game
SELECT Game_Type, 
       SUM(Amount_Staked) AS Revenue,
       COUNT(*) AS Number_of_Bets,
       SUM(Amount_Staked) - SUM(Payout_Amount) AS GGR_per_Game
FROM transactions
GROUP BY Game_Type
ORDER BY Revenue DESC;

-- 3) Analysis by Customer Type
--    Which customers (VIP, Regular, etc.) are the most profitable?
SELECT Customer_Type, 
       concat(round(AVG(Amount_Staked),0),' €') AS Average_Bet_Size,
       concat(round(SUM(Amount_Staked) - SUM(Payout_Amount),0),' €') AS Profit_per_Type
FROM transactions
GROUP BY Customer_Type;

-- 4) Finding the "Big Winners"
SELECT * FROM transactions 
WHERE Payout_Amount > 200
ORDER BY Payout_Amount DESC
LIMIT 10;

-- 5) Monthly Turnover (Time Series)
--    How has the store performed over time?
SELECT MONTH(Date) AS Month, 
       SUM(Amount_Staked) AS Monthly_Revenue
FROM transactions
GROUP BY Month
ORDER BY Month;

-- 6) Commission per Game
WITH GameCommissions AS (
    SELECT Game_Type, Amount_Staked,
        CASE 
            WHEN Game_Type = 'Kino' THEN 0.07            -- 7% προμήθεια
            WHEN Game_Type = 'Pame Stoixima' THEN 0.06   -- 6% προμήθεια
            WHEN Game_Type = 'Joker' THEN 0.125          -- 12.5% προμήθεια
            WHEN Game_Type = 'Virtual Sports' THEN 0.03  -- 3% προμήθεια
            WHEN Game_Type = 'Scratch' THEN 0.08         -- 8% προμήθεια
        END as Commission_Rate
    FROM transactions
)
SELECT 
    Game_Type,
    SUM(Amount_Staked) as Total_Staked,
    round(SUM(Amount_Staked * Commission_Rate),0) as Total_Commission
FROM GameCommissions
GROUP BY Game_Type
ORDER BY Total_Commission DESC;