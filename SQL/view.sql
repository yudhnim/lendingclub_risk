CREATE OR REPLACE VIEW star_schema.vw_portfolio_overview AS
SELECT
    fl.loan_status,
    COUNT(*) AS total_loans,
    SUM(fl.loan_amnt) AS total_issued,
    SUM(fl.total_pymnt) AS total_repaid,
    SUM(fl.loan_amnt) - SUM(fl.total_pymnt) AS outstanding_balance
FROM star_schema.fact_loans fl
GROUP BY fl.loan_status;


CREATE OR REPLACE VIEW star_schema.vw_yearly_growth AS
SELECT
    dd.year,
    COUNT(*) AS total_loans,
    SUM(fl.loan_amnt) AS total_issued,
    SUM(fl.total_pymnt) AS total_repaid
FROM star_schema.fact_loans fl
JOIN star_schema.dim_date dd ON fl.date_key = dd.date_key
GROUP BY dd.year
ORDER BY dd.year;


CREATE OR REPLACE VIEW star_schema.vw_performance_by_grade AS
SELECT
    dl.grade,
    COUNT(*) AS loan_count,
    AVG(dl.int_rate) AS avg_interest_rate,
    SUM(fl.loan_amnt) AS total_issued,
    SUM(fl.total_pymnt) AS total_repaid
FROM star_schema.fact_loans fl
JOIN star_schema.dim_loan dl ON fl.loan_key = dl.loan_key
GROUP BY dl.grade
ORDER BY dl.grade;

CREATE OR REPLACE VIEW star_schema.vw_default_rate_by_grade AS
SELECT
    dl.grade,
    COUNT(*) FILTER (WHERE fl.loan_status = 'Default')::DECIMAL / COUNT(*) AS default_rate,
    COUNT(*) AS loan_count
FROM star_schema.fact_loans fl
JOIN star_schema.dim_loan dl ON fl.loan_key = dl.loan_key
GROUP BY dl.grade
ORDER BY dl.grade;

CREATE OR REPLACE VIEW star_schema.vw_performance_by_purpose AS
SELECT
    dl.purpose,
    COUNT(*) AS loan_count,
    AVG(dl.int_rate) AS avg_interest_rate,
    SUM(fl.loan_amnt) AS total_issued,
    SUM(fl.total_pymnt) AS total_repaid
FROM star_schema.fact_loans fl
JOIN star_schema.dim_loan dl ON fl.loan_key = dl.loan_key
GROUP BY dl.purpose
ORDER BY total_issued DESC;

CREATE OR REPLACE VIEW star_schema.vw_monthly_issuance AS
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    COUNT(*) AS total_loans,
    SUM(fl.loan_amnt) AS total_issued
FROM star_schema.fact_loans fl
JOIN star_schema.dim_date dd ON fl.date_key = dd.date_key
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;

CREATE OR REPLACE VIEW star_schema.vw_income_vs_loans AS
SELECT
    db.annual_inc,
    AVG(fl.loan_amnt) AS avg_loan_amount,
    COUNT(*) AS loan_count
FROM star_schema.fact_loans fl
JOIN star_schema.dim_borrower db ON fl.borrower_key = db.borrower_key
GROUP BY db.annual_inc
ORDER BY db.annual_inc;

CREATE OR REPLACE VIEW star_schema.vw_employment_impact AS
SELECT
    db.emp_length,
    AVG(fl.loan_amnt) AS avg_loan_amount,
    AVG(dl.int_rate) AS avg_interest_rate,
    COUNT(*) AS loan_count
FROM star_schema.fact_loans fl
JOIN star_schema.dim_borrower db ON fl.borrower_key = db.borrower_key
JOIN star_schema.dim_loan dl ON fl.loan_key = dl.loan_key
GROUP BY db.emp_length
ORDER BY db.emp_length;

CREATE OR REPLACE VIEW star_schema.vw_home_ownership_impact AS
SELECT
    db.home_ownership,
    COUNT(*) AS loan_count,
    AVG(fl.loan_amnt) AS avg_loan_amount,
    AVG(dl.int_rate) AS avg_interest_rate,
    SUM(fl.total_pymnt) AS total_repaid
FROM star_schema.fact_loans fl
JOIN star_schema.dim_borrower db ON fl.borrower_key = db.borrower_key
JOIN star_schema.dim_loan dl ON fl.loan_key = dl.loan_key
GROUP BY db.home_ownership
ORDER BY loan_count DESC;

CREATE OR REPLACE VIEW star_schema.vw_delinquency_by_grade AS
SELECT
    dl.grade,
    COUNT(*) FILTER (WHERE fl.loan_status LIKE '%Late%') AS late_loans,
    COUNT(*) AS total_loans,
    (COUNT(*) FILTER (WHERE fl.loan_status LIKE '%Late%')::DECIMAL / COUNT(*)) AS delinquency_rate
FROM star_schema.fact_loans fl
JOIN star_schema.dim_loan dl ON fl.loan_key = dl.loan_key
GROUP BY dl.grade
ORDER BY dl.grade;

CREATE OR REPLACE VIEW star_schema.vw_recovery_rate AS
SELECT
    fl.loan_status,
    SUM(fl.total_pymnt) / NULLIF(SUM(fl.loan_amnt),0) AS recovery_rate,
    COUNT(*) AS loan_count
FROM star_schema.fact_loans fl
GROUP BY fl.loan_status
ORDER BY recovery_rate DESC;

CREATE OR REPLACE VIEW star_schema.vw_geographic_risk AS
SELECT
    br.addr_state,
    COUNT(*) AS loan_count,
    SUM(fl.loan_amnt) AS total_issued,
    SUM(fl.total_pymnt) AS total_repaid,
    (SUM(fl.total_pymnt) / NULLIF(SUM(fl.loan_amnt),0)) AS repayment_ratio
FROM star_schema.fact_loans fl
JOIN star_schema.dim_borrower br ON fl.borrower_key = br.borrower_key
GROUP BY br.addr_state
ORDER BY repayment_ratio ASC;








