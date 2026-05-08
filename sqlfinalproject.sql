-- Simplified Fraud Detection SQL Project
CREATE DATABASE sqlproject1;
USE sqlproject1;

CREATE TABLE accounts (
  account_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_name VARCHAR(150),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE transactions (
  transaction_id INT AUTO_INCREMENT PRIMARY KEY,
  account_id INT NOT NULL,
  amount NUMERIC(12,2),
  txn_time TIMESTAMP,
  device_id VARCHAR(50),
  ip_address VARCHAR(50),
  geo_lat DOUBLE PRECISION,
  geo_lon DOUBLE PRECISION,
  FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE blacklists (
  blacklist_id INT AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(20),
  value VARCHAR(100),
  reason TEXT
);

CREATE TABLE alerts (
  alert_id INT AUTO_INCREMENT PRIMARY KEY,
  transaction_id INT,
  rule_triggered VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW(),
  FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);

-- Insert Values 
INSERT INTO accounts (customer_name) VALUES
('Neha Sharma'),
('Vikram Joshi'),
('Pooja Mehta'),
('Suresh Desai'),
('Kiran Rao'),
('Manish Verma'),
('Deepa Iyer'),
('Samir Purohit'),
('Anita Kapoor'),
('Prakash Yadav'),
('Harsha Kulkarni');


INSERT INTO transactions (account_id, amount, txn_time, device_id, ip_address, geo_lat, geo_lon) VALUES
(1, 12000, DATE_SUB(NOW(), INTERVAL 1 DAY), 'dev1', '1.1.1.1', 19.07, 72.87),
(1, 200, DATE_SUB(NOW(), INTERVAL 10 MINUTE), 'dev1', '1.1.1.1', 19.07, 72.87),
(1, 250, DATE_SUB(NOW(), INTERVAL 9 MINUTE), 'dev1', '1.1.1.1', 19.07, 72.87),
(1, 300, DATE_SUB(NOW(), INTERVAL 8 MINUTE), 'dev1', '1.1.1.1', 19.07, 72.87),
(1, 350, DATE_SUB(NOW(), INTERVAL 7 MINUTE), 'dev1', '1.1.1.1', 19.07, 72.87),
(1, 400, DATE_SUB(NOW(), INTERVAL 6 MINUTE), 'dev1', '1.1.1.1', 19.07, 72.87);

INSERT INTO blacklists (type, value, reason) VALUES
('ip', '9.9.9.9', 'Known fraud IP used in multiple chargebacks'),
('device', 'devX123', 'Suspicious device flagged earlier'),
('account', '3', 'Account linked to repeated fraudulent activity');
INSERT INTO blacklists (type, value, reason)
VALUES ('ip', '1.1.1.1', 'Suspicious IP detected in past fraud cases');

INSERT INTO alerts (transaction_id, rule_triggered) VALUES
(1, 'HIGH_AMOUNT'),
(2, 'VELOCITY'),
(3, 'BLACKLIST_IP'),
(1, 'NEW_DEVICE'),
(2, 'AMOUNT_OUTLIER');

SELECT * FROM accounts;
SELECT * FROM transactions;
SELECT * FROM blacklists;
SELECT * FROM alerts;

describe accounts;
describe transactions;
describe blacklists;
describe alerts;

#Joins
#1Display all transactions along with the customer name who performed them.
SELECT 
    a.customer_name,
    t.transaction_id,
    t.amount,
    t.txn_time
FROM accounts a
JOIN transactions t
ON a.account_id = t.account_id;

#Q2: Show all transactions that were flagged as alerts along with the rule triggered.
SELECT
    t.transaction_id,
    t.amount,
    a.rule_triggered,
    a.created_at AS alert_time
FROM transactions t
JOIN alerts a
ON t.transaction_id = a.transaction_id;

#Q3: List transactions that match any blacklisted IP along with the blacklist reason.
SELECT
    t.transaction_id,
    t.account_id,
    t.ip_address,
    b.reason
FROM transactions t
JOIN blacklists b
ON b.type = 'ip'
AND b.value = t.ip_address;

#Subquery
#1✅ 1. Find all accounts that have at least one alert
Select account_id
From transactions
where transaction_id IN(
Select transaction_id from alerts
);
#2✅ 2. Get transactions higher than average amount
select transaction_id,amount
From transactions
where amount>(select avg(amount) from transactions);
#Find all transactions whose amount is greater than the minimum transaction amount.
Select transaction_id, amount
from transactions
where amount>(select min(amount) from transactions);

#Windows Function
#Q1: Running total of transactions per account.
SELECT 
    account_id,
    transaction_id,
    amount,
    COUNT(*) OVER (PARTITION BY account_id ORDER BY txn_time) 
        AS running_count
FROM transactions;

#Q2: Rank accounts based on total transaction amount.
SELECT 
    account_id,
    SUM(amount) AS total_amount,
    RANK() OVER (ORDER BY SUM(amount) DESC) AS rank_no
FROM transactions
GROUP BY account_id;

#Q3: Show each transaction with the average amount per account.
SELECT 
    transaction_id,
    account_id,
    amount,
    AVG(amount) OVER (PARTITION BY account_id) AS avg_amount
FROM transactions;

