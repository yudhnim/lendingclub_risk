CREATE TABLE star_schema.dim_borrower AS
SELECT DISTINCT
    member_id,
    emp_length,
    home_ownership,
    annual_inc,
    verification_status,
    zip_code,
    addr_state,
    earliest_cr_line
FROM star_schema.clean_loans
WHERE member_id IS NOT NULL;

ALTER TABLE star_schema.dim_borrower
    ADD COLUMN borrower_key SERIAL PRIMARY KEY;
----------------------------------------------
CREATE TABLE star_schema.dim_loan AS
SELECT DISTINCT
    id AS loan_id,
    term,
    int_rate,
    installment,
    grade,
    sub_grade,
    purpose,
    title,
    dti,
    initial_list_status
FROM star_schema.clean_loans
WHERE id IS NOT NULL;

ALTER TABLE star_schema.dim_loan
    ADD COLUMN loan_key SERIAL PRIMARY KEY;
----------------------------------------------
CREATE TABLE star_schema.dim_date AS
SELECT DISTINCT
    issue_d AS date_value,
    EXTRACT(YEAR FROM issue_d)::INT AS year,
    EXTRACT(MONTH FROM issue_d)::INT AS month,
    TO_CHAR(issue_d, 'Month') AS month_name,
    EXTRACT(QUARTER FROM issue_d)::INT AS quarter
FROM star_schema.clean_loans
WHERE issue_d IS NOT NULL;

ALTER TABLE star_schema.dim_date
    ADD COLUMN date_key SERIAL PRIMARY KEY;
----------------------------------------------
CREATE TABLE star_schema.fact_loans AS
SELECT
    b.borrower_key,
    l.loan_key,
    d.date_key,

    -- Dates (keep raw if needed for reference)
    cl.issue_d AS issue_date,
    cl.last_pymnt_d AS last_pymnt_date,
    cl.next_pymnt_d AS next_pymnt_date,
    cl.last_credit_pull_d AS last_credit_pull_date,

    -- Measures
    cl.loan_amnt,
    cl.funded_amnt,
    cl.funded_amnt_inv,
    cl.out_prncp,
    cl.out_prncp_inv,
    cl.total_pymnt,
    cl.total_pymnt_inv,
    cl.total_rec_prncp,
    cl.total_rec_int,
    cl.total_rec_late_fee,
    cl.recoveries,
    cl.collection_recovery_fee,
    cl.last_pymnt_amnt,

    -- Status
    cl.loan_status
FROM star_schema.clean_loans cl
JOIN star_schema.dim_borrower b 
    ON cl.member_id = b.member_id
JOIN star_schema.dim_loan l 
    ON cl.id = l.loan_id
JOIN star_schema.dim_date d 
    ON cl.issue_d = d.date_value
WHERE cl.id IS NOT NULL;


ALTER TABLE star_schema.fact_loans
    ADD CONSTRAINT fk_fact_borrower FOREIGN KEY (borrower_key) 
        REFERENCES star_schema.dim_borrower(borrower_key),
    ADD CONSTRAINT fk_fact_loan FOREIGN KEY (loan_key) 
        REFERENCES star_schema.dim_loan(loan_key),
    ADD CONSTRAINT fk_fact_date FOREIGN KEY (date_key) 
        REFERENCES star_schema.dim_date(date_key);
----------------------------------------------



