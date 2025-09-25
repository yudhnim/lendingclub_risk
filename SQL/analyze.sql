-- 1.1 Total loans, total volume, average loan size
SELECT COUNT(*) AS total_loans,
       SUM(loan_amnt) AS total_volume,
       AVG(loan_amnt) AS avg_loan_size
FROM star_schema.fact_loans;

-- 1.2 Distribution by grade
SELECT l.grade, COUNT(*) AS loan_count, SUM(f.loan_amnt) AS total_amount
FROM star_schema.fact_loans f
JOIN star_schema.dim_loan l ON f.loan_key = l.loan_key
GROUP BY l.grade
ORDER BY l.grade;

-- 1.3 Distribution by subgrade
SELECT l.sub_grade, COUNT(*) AS loan_count, SUM(f.loan_amnt) AS total_amount
FROM star_schema.fact_loans f
JOIN star_schema.dim_loan l ON f.loan_key = l.loan_key
GROUP BY l.sub_grade
ORDER BY l.sub_grade;

-- 1.4 Funding efficiency
SELECT SUM(funded_amnt) * 1.0 / SUM(loan_amnt) AS funding_efficiency
FROM star_schema.fact_loans;

-- 1.5 Loan purpose distribution
SELECT l.purpose, COUNT(*) AS loan_count, SUM(f.loan_amnt) AS total_amount
FROM star_schema.fact_loans f
JOIN star_schema.dim_loan l ON f.loan_key = l.loan_key
GROUP BY l.purpose
ORDER BY total_amount DESC;

-- 2.1 Loan status distribution
SELECT loan_status, COUNT(*) AS loan_count
FROM star_schema.fact_loans
GROUP BY loan_status
ORDER BY loan_count DESC;

-- 2.2 Default rate by grade
SELECT l.grade,
       ROUND(AVG(CASE WHEN f.loan_status IN ('Default','Charged Off') THEN 1 ELSE 0 END),4) AS default_rate
FROM star_schema.fact_loans f
JOIN star_schema.dim_loan l ON f.loan_key = l.loan_key
GROUP BY l.grade
ORDER BY l.grade;

-- 2.3 Recovery ratio
SELECT SUM(recoveries) / NULLIF(SUM(loan_amnt),0) AS recovery_rate
FROM star_schema.fact_loans;

-- 2.4 Repayment ratio (total paid vs original amount)
SELECT SUM(total_pymnt) / NULLIF(SUM(loan_amnt),0) AS repayment_ratio
FROM star_schema.fact_loans;

-- 2.5 Outstanding principal trend by year
SELECT d.year,
       SUM(f.out_prncp) AS total_outstanding
FROM star_schema.fact_loans f
JOIN star_schema.dim_date d ON f.date_key = d.date_key
GROUP BY d.year
ORDER BY d.year;

-- 3.1 Default rate by income group
SELECT CASE
         WHEN b.annual_inc < 40000 THEN 'Low Income'
         WHEN b.annual_inc BETWEEN 40000 AND 80000 THEN 'Mid Income'
         ELSE 'High Income'
       END AS income_group,
       ROUND(AVG(CASE WHEN f.loan_status IN ('Default','Charged Off') THEN 1 ELSE 0 END),4) AS default_rate
FROM star_schema.fact_loans f
JOIN star_schema.dim_borrower b ON f.borrower_key = b.borrower_key
GROUP BY income_group
ORDER BY income_group;

-- 3.2 Default rate by employment length
SELECT b.emp_length,
       ROUND(AVG(CASE WHEN f.loan_status IN ('Default','Charged Off') THEN 1 ELSE 0 END),4) AS default_rate
FROM star_schema.fact_loans f
JOIN star_schema.dim_borrower b ON f.borrower_key = b.borrower_key
GROUP BY b.emp_length
ORDER BY b.emp_length;

-- 3.3 Loan status by home ownership
SELECT b.home_ownership, 
       COUNT(*) AS total_loans,
       ROUND(AVG(CASE WHEN f.loan_status IN ('Default','Charged Off') THEN 1 ELSE 0 END),4) AS default_rate
FROM star_schema.fact_loans f
JOIN star_schema.dim_borrower b ON f.borrower_key = b.borrower_key
GROUP BY b.home_ownership;

-- 3.4 Default rate by state
SELECT b.addr_state,
       ROUND(AVG(CASE WHEN f.loan_status IN ('Default','Charged Off') THEN 1 ELSE 0 END),4) AS default_rate,
       COUNT(*) AS loan_count
FROM star_schema.fact_loans f
JOIN star_schema.dim_borrower b ON f.borrower_key = b.borrower_key
GROUP BY b.addr_state
ORDER BY default_rate DESC;

-- 4.1 Loan issuance by year/quarter
SELECT d.year, d.quarter,
       COUNT(*) AS loan_count,
       SUM(f.loan_amnt) AS total_volume
FROM star_schema.fact_loans f
JOIN star_schema.dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;

-- 4.2 Default rate by year
SELECT d.year,
       ROUND(AVG(CASE WHEN f.loan_status IN ('Default','Charged Off') THEN 1 ELSE 0 END),4) AS default_rate
FROM star_schema.fact_loans f
JOIN star_schema.dim_date d ON f.date_key = d.date_key
GROUP BY d.year
ORDER BY d.year;

-- 4.3 Loan grade distribution by year
SELECT d.year, l.grade,
       COUNT(*) AS loan_count
FROM star_schema.fact_loans f
JOIN star_schema.dim_loan l ON f.loan_key = l.loan_key
JOIN star_schema.dim_date d ON f.date_key = d.date_key
GROUP BY d.year, l.grade
ORDER BY d.year, l.grade;

-- 5.1 Average interest rate by grade
SELECT l.grade, ROUND(AVG(l.int_rate),4) AS avg_rate
FROM star_schema.fact_loans f
JOIN star_schema.dim_loan l ON f.loan_key = l.loan_key
GROUP BY l.grade
ORDER BY l.grade;

-- 5.2 Average investor return by grade
SELECT l.grade,
       ROUND(AVG((f.total_pymnt - f.funded_amnt_inv) / NULLIF(f.funded_amnt_inv,0)),4) AS avg_return
FROM star_schema.fact_loans f
JOIN star_schema.dim_loan l ON f.loan_key = l.loan_key
GROUP BY l.grade
ORDER BY l.grade;

-- 5.3 Loan volume concentration by state (Top 10)
SELECT b.addr_state, SUM(f.loan_amnt) AS total_volume
FROM star_schema.fact_loans f
JOIN star_schema.dim_borrower b ON f.borrower_key = b.borrower_key
GROUP BY b.addr_state
ORDER BY total_volume DESC
LIMIT 10;

-- 5.4 Loan purpose concentration
SELECT l.purpose, SUM(f.loan_amnt) AS total_volume
FROM star_schema.fact_loans f
JOIN star_schema.dim_loan l ON f.loan_key = l.loan_key
GROUP BY l.purpose
ORDER BY total_volume DESC;







