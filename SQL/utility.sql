-- DROP
DROP TABLE IF EXISTS star_schema.fact_loans;
DROP TABLE IF EXISTS star_schema.dim_borrower;
DROP TABLE IF EXISTS star_schema.dim_loan;
DROP TABLE IF EXISTS star_schema.dim_date;
------------------------------------------

-- INIT INDEX
CREATE INDEX idx_fact_borrower_key 
    ON star_schema.fact_loans (borrower_key);
CREATE INDEX idx_fact_loan_key 
    ON star_schema.fact_loans (loan_key);
CREATE INDEX idx_fact_date_key 
    ON star_schema.fact_loans (date_key);
-- Filtering by loan status
CREATE INDEX idx_fact_loan_status 
    ON star_schema.fact_loans (loan_status);
-- Filtering by issue date
CREATE INDEX idx_fact_issue_date 
    ON star_schema.fact_loans (issue_date);
------------------------------------------

-- DROP INDEX
DROP INDEX IF EXISTS star_schema.idx_fact_date_key;
DROP INDEX IF EXISTS star_schema.idx_fact_loan_status;
DROP INDEX IF EXISTS star_schema.idx_fact_borrower_key;
DROP INDEX IF EXISTS star_schema.idx_fact_loan_key;
DROP INDEX IF EXISTS star_schema.idx_fact_issue_date;
------------------------------------------------------
