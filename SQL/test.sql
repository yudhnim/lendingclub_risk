-- ROW COUNT
SELECT COUNT(*) FROM star_schema.fact_loans;
SELECT COUNT(DISTINCT member_id) FROM star_schema.dim_borrower;
SELECT COUNT(DISTINCT loan_id) FROM star_schema.dim_loan;
SELECT COUNT(DISTINCT date_value) FROM star_schema.dim_date;

-- DATA QUALITY CHECK
--- Key Integrity Checks
---- Fact and Dimension consistency
SELECT COUNT(*) 
FROM star_schema.dim_loan dl
LEFT JOIN star_schema.fact_loans f ON dl.loan_key = f.loan_key
WHERE f.loan_key IS NULL;
---- Borrowers in fact but missing in dim_borrower
SELECT COUNT(*) 
FROM star_schema.dim_borrower db
LEFT JOIN star_schema.fact_loans f ON db.borrower_key = f.borrower_key
WHERE f.borrower_key IS NULL;
---- Dates in fact but missing in dim_date
SELECT COUNT(*) 
FROM star_schema.dim_date dd
LEFT JOIN star_schema.fact_loans f ON dd.date_key = f.date_key
WHERE f.date_key IS NULL;
-- END OF DATA QUALITY CHECK  (expected 0 for all)

-- UNIQUENESS CHECK
---- CHECK DUPLICATE BORROWER
SELECT member_id, COUNT(*)
FROM star_schema.dim_borrower
GROUP BY member_id
HAVING COUNT(*) > 1;
---- CHECK DUPLICATE LOANS
SELECT loan_id, COUNT(*)
FROM star_schema.dim_loan
GROUP BY loan_id
HAVING COUNT(*) > 1;
-- END OF UNIQUE CHECK

-- BUSINESS LOGIC CHECK
---- Total payments never exceed loan amount (sanity)
SELECT COUNT(*)
FROM star_schema.fact_loans
WHERE total_pymnt > loan_amnt * 1.5;
---- Outstanding principal not greater than funded amount
SELECT COUNT(*)
FROM star_schema.fact_loans
WHERE out_prncp > funded_amnt;
---- Recoveries should not be negative
SELECT COUNT(*)
FROM star_schema.fact_loans
WHERE recoveries < 0;
-- DATE LOGIC CHECK
---- Last payment date should be after issue date
SELECT COUNT(*)
FROM star_schema.fact_loans
WHERE last_pymnt_date < issue_date;
---- Next payment date should be after last payment date
SELECT COUNT(*)
FROM star_schema.fact_loans
WHERE next_pymnt_date < last_pymnt_date;



-- Spot check joins
SELECT f.loan_id, d.year, b.emp_length
FROM star_schema.fact_loans f
JOIN star_schema.dim_date d ON f.issue_date = d.date_value
JOIN star_schema.dim_borrower b ON f.member_id = b.member_id
LIMIT 10;


-- Average annual income of borrowers by loan grade
SELECT l.grade, AVG(b.annual_inc) AS avg_income
FROM star_schema.fact_loans f
JOIN star_schema.dim_loan l ON f.loan_id = l.loan_id
JOIN star_schema.dim_borrower b ON f.member_id = b.member_id
GROUP BY l.grade
ORDER BY l.grade;

-- Total payments vs funded amount by purpose
SELECT l.purpose,
       SUM(f.total_pymnt) AS total_payments,
       SUM(f.funded_amnt) AS total_funded
FROM star_schema.fact_loans f
JOIN star_schema.dim_loan l ON f.loan_id = l.loan_id
GROUP BY l.purpose
ORDER BY total_funded DESC;

-- Distribution of loan status across employment lengths
SELECT b.emp_length, f.loan_status, COUNT(*) AS loan_count
FROM star_schema.fact_loans f
JOIN star_schema.dim_borrower b ON f.member_id = b.member_id
GROUP BY b.emp_length, f.loan_status
ORDER BY b.emp_length, loan_count DESC;

-- Check that fact table matches dimensions
SELECT COUNT(*) AS fact_count FROM star_schema.fact_loans;
SELECT COUNT(DISTINCT loan_id) AS dim_loan_count FROM star_schema.dim_loan;
SELECT COUNT(DISTINCT member_id) AS dim_borrower_count FROM star_schema.dim_borrower;

SELECT d.year, d.month, d.month_name,
       COUNT(f.loan_id) AS loan_count
FROM star_schema.fact_loans f
JOIN star_schema.dim_date d ON f.issue_date = d.date_value
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

SELECT COUNT(*) AS missing_loans
FROM star_schema.clean_loans cl
LEFT JOIN star_schema.dim_loan dl ON cl.id = dl.loan_id
LEFT JOIN star_schema.fact_loans f ON dl.loan_key = f.loan_key
WHERE f.loan_key IS NULL;

SELECT cl.id, cl.member_id, cl.issue_d, cl.loan_amnt
FROM star_schema.clean_loans cl
LEFT JOIN star_schema.fact_loans f 
    ON cl.id = f.loan_key
WHERE f.loan_key IS NULL
LIMIT 50;

SELECT
    COUNT(*) AS total_clean,
    SUM(CASE WHEN dl.loan_key IS NULL THEN 1 ELSE 0 END) AS missing_in_dim_loan,
    SUM(CASE WHEN db.borrower_key IS NULL THEN 1 ELSE 0 END) AS missing_in_dim_borrower,
    SUM(CASE WHEN dd.date_key IS NULL THEN 1 ELSE 0 END) AS missing_in_dim_date
FROM star_schema.clean_loans cl
LEFT JOIN star_schema.dim_loan dl 
    ON cl.id = dl.loan_id
LEFT JOIN star_schema.dim_borrower db 
    ON cl.member_id = db.member_id
LEFT JOIN star_schema.dim_date dd 
    ON cl.issue_d = dd.date_value;

SELECT COUNT(*), issue_d
FROM star_schema.clean_loans
WHERE issue_d IS NULL
GROUP BY issue_d;

SELECT COUNT(*) 
FROM star_schema.clean_loans
WHERE issue_d IS NULL;

SELECT cl.id, cl.issue_d
FROM star_schema.clean_loans cl
LEFT JOIN star_schema.dim_date d 
    ON cl.issue_d = d.date_value
WHERE d.date_value IS NULL;



