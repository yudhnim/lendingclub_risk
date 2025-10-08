CREATE SCHEMA star_schema;
SET search_path TO star_schema;

CREATE TABLE star_schema.staging_loans (
    id TEXT,
    member_id TEXT,
    loan_amnt TEXT,
    funded_amnt TEXT,
    funded_amnt_inv TEXT,
    term TEXT,
    int_rate TEXT,
    installment TEXT,
    grade TEXT,
    sub_grade TEXT,
    emp_title TEXT,
    emp_length TEXT,
    home_ownership TEXT,
    annual_inc TEXT,
    verification_status TEXT,
    issue_d TEXT,
    loan_status TEXT,
    pymnt_plan TEXT,
    url TEXT,
    "desc" TEXT,
    purpose TEXT,
    title TEXT,
    zip_code TEXT,
    addr_state TEXT,
    dti TEXT,
    delinq_2yrs TEXT,
    earliest_cr_line TEXT,
    inq_last_6mths TEXT,
    mths_since_last_delinq TEXT,
    mths_since_last_record TEXT,
    open_acc TEXT,
    pub_rec TEXT,
    revol_bal TEXT,
    revol_util TEXT,
    total_acc TEXT,
    initial_list_status TEXT,
    out_prncp TEXT,
    out_prncp_inv TEXT,
    total_pymnt TEXT,
    total_pymnt_inv TEXT,
    total_rec_prncp TEXT,
    total_rec_int TEXT,
    total_rec_late_fee TEXT,
    recoveries TEXT,
    collection_recovery_fee TEXT,
    last_pymnt_d TEXT,
    last_pymnt_amnt TEXT,
    next_pymnt_d TEXT,
    last_credit_pull_d TEXT,
    collections_12_mths_ex_med TEXT,
    mths_since_last_major_derog TEXT,
    policy_code TEXT,
    application_type TEXT,
    annual_inc_joint TEXT,
    dti_joint TEXT,
    verification_status_joint TEXT,
    acc_now_delinq TEXT,
    tot_coll_amt TEXT,
    tot_cur_bal TEXT,
    open_acc_6m TEXT,
    open_il_6m TEXT,
    open_il_12m TEXT,
    open_il_24m TEXT,
    mths_since_rcnt_il TEXT,
    total_bal_il TEXT,
    il_util TEXT,
    open_rv_12m TEXT,
    open_rv_24m TEXT,
    max_bal_bc TEXT,
    all_util TEXT,
    total_rev_hi_lim TEXT,
    inq_fi TEXT,
    total_cu_tl TEXT,
    inq_last_12m TEXT
);

COPY star_schema.staging_loans
FROM 'E:/build stuff/lending_club_sql/data/loan_data_2007_2014.csv'
DELIMITER ','
CSV HEADER;

SELECT COUNT(*) FROM star_schema.staging_loans;

-- 0) Safety: drop and recreate clean table for re-runs
DROP TABLE IF EXISTS star_schema.clean_loans;

-- 1) Create cleaned table
CREATE TABLE star_schema.clean_loans AS
WITH cleaned AS (
  SELECT
    -- IDs
    NULLIF(id,'')::BIGINT                                    AS id,
    NULLIF(member_id,'')::BIGINT                             AS member_id,

    -- Core loan amounts
    NULLIF(loan_amnt,'')::NUMERIC                            AS loan_amnt,
    NULLIF(funded_amnt,'')::NUMERIC                          AS funded_amnt,
    NULLIF(funded_amnt_inv,'')::NUMERIC                      AS funded_amnt_inv,

    -- Term: "36 months" -> 36
    CASE
      WHEN term IS NULL OR term = '' THEN NULL
      ELSE REPLACE(term, ' months','')::INT
    END                                                      AS term,

    -- Rates & installment
    CASE WHEN int_rate IS NULL OR int_rate = '' THEN NULL
         ELSE REPLACE(int_rate, '%','')::NUMERIC END         AS int_rate,
    NULLIF(installment,'')::NUMERIC                          AS installment,

    -- Grade
    grade,
    sub_grade,

    -- Borrower
    emp_title,
    CASE
      WHEN emp_length ILIKE '%n/a%' THEN NULL
      WHEN emp_length ILIKE '%10+%' THEN 10
      WHEN emp_length ILIKE '%< 1%' THEN 0
      WHEN emp_length ~ '\d+' THEN REGEXP_REPLACE(emp_length, '\D','','g')::INT
      ELSE NULL
    END                                                      AS emp_length,
    home_ownership,
    NULLIF(annual_inc,'')::NUMERIC                           AS annual_inc,
    verification_status,

    -- Dates (accept YY-Mon, Mon-YY, Mon-YYYY)
    CASE
      WHEN issue_d IS NULL OR issue_d = '' THEN NULL::DATE
	  WHEN issue_d ~ '^\d{1}-[A-Za-z]{3}$' THEN TO_DATE('0' || issue_d, 'YY-Mon')
      WHEN issue_d ~ '^\d{2}-[A-Za-z]{3}$' THEN TO_DATE(issue_d, 'YY-Mon')
      WHEN issue_d ~ '^[A-Za-z]{3}-\d{2}$' THEN TO_DATE(issue_d, 'Mon-YY')
      WHEN issue_d ~ '^[A-Za-z]{3}-\d{4}$' THEN TO_DATE(issue_d, 'Mon-YYYY')
      ELSE NULL::DATE
    END                                                      AS issue_d,

    loan_status,
    purpose,
    title,
    zip_code,
    addr_state,

    -- DTI & credit history
    NULLIF(dti,'')::NUMERIC                                  AS dti,
    NULLIF(delinq_2yrs,'')::INT                              AS delinq_2yrs,

    CASE
      WHEN earliest_cr_line IS NULL OR earliest_cr_line = '' THEN NULL::DATE
      WHEN earliest_cr_line ~ '^\d{2}-[A-Za-z]{3}$' THEN TO_DATE(earliest_cr_line, 'YY-Mon')
      WHEN earliest_cr_line ~ '^[A-Za-z]{3}-\d{2}$' THEN TO_DATE(earliest_cr_line, 'Mon-YY')
      WHEN earliest_cr_line ~ '^[A-Za-z]{3}-\d{4}$' THEN TO_DATE(earliest_cr_line, 'Mon-YYYY')
      ELSE NULL::DATE
    END                                                      AS earliest_cr_line,

    NULLIF(inq_last_6mths,'')::INT                           AS inq_last_6mths,
    NULLIF(mths_since_last_delinq,'')::INT                   AS mths_since_last_delinq,
    NULLIF(mths_since_last_record,'')::INT                   AS mths_since_last_record,
    NULLIF(open_acc,'')::INT                                 AS open_acc,
    NULLIF(pub_rec,'')::INT                                  AS pub_rec,
    NULLIF(revol_bal,'')::NUMERIC                            AS revol_bal,
    CASE WHEN revol_util IS NULL OR revol_util = '' THEN NULL
         ELSE REPLACE(revol_util, '%','')::NUMERIC END       AS revol_util,
    NULLIF(total_acc,'')::INT                                AS total_acc,
    initial_list_status,

    -- Performance / payments
    NULLIF(out_prncp,'')::NUMERIC                            AS out_prncp,
    NULLIF(out_prncp_inv,'')::NUMERIC                        AS out_prncp_inv,
    NULLIF(total_pymnt,'')::NUMERIC                          AS total_pymnt,
    NULLIF(total_pymnt_inv,'')::NUMERIC                      AS total_pymnt_inv,
    NULLIF(total_rec_prncp,'')::NUMERIC                      AS total_rec_prncp,
    NULLIF(total_rec_int,'')::NUMERIC                        AS total_rec_int,
    NULLIF(total_rec_late_fee,'')::NUMERIC                   AS total_rec_late_fee,
    NULLIF(recoveries,'')::NUMERIC                           AS recoveries,
    NULLIF(collection_recovery_fee,'')::NUMERIC              AS collection_recovery_fee,

    CASE
      WHEN last_pymnt_d IS NULL OR last_pymnt_d = '' THEN NULL::DATE
      WHEN last_pymnt_d ~ '^\d{2}-[A-Za-z]{3}$' THEN TO_DATE(last_pymnt_d, 'YY-Mon')
      WHEN last_pymnt_d ~ '^[A-Za-z]{3}-\d{2}$' THEN TO_DATE(last_pymnt_d, 'Mon-YY')
      WHEN last_pymnt_d ~ '^[A-Za-z]{3}-\d{4}$' THEN TO_DATE(last_pymnt_d, 'Mon-YYYY')
      ELSE NULL::DATE
    END                                                      AS last_pymnt_d,
    NULLIF(last_pymnt_amnt,'')::NUMERIC                      AS last_pymnt_amnt,

    CASE
      WHEN next_pymnt_d IS NULL OR next_pymnt_d = '' THEN NULL::DATE
      WHEN next_pymnt_d ~ '^\d{2}-[A-Za-z]{3}$' THEN TO_DATE(next_pymnt_d, 'YY-Mon')
      WHEN next_pymnt_d ~ '^[A-Za-z]{3}-\d{2}$' THEN TO_DATE(next_pymnt_d, 'Mon-YY')
      WHEN next_pymnt_d ~ '^[A-Za-z]{3}-\d{4}$' THEN TO_DATE(next_pymnt_d, 'Mon-YYYY')
      ELSE NULL::DATE
    END                                                      AS next_pymnt_d,

    CASE
      WHEN last_credit_pull_d IS NULL OR last_credit_pull_d = '' THEN NULL::DATE
      WHEN last_credit_pull_d ~ '^\d{2}-[A-Za-z]{3}$' THEN TO_DATE(last_credit_pull_d, 'YY-Mon')
      WHEN last_credit_pull_d ~ '^[A-Za-z]{3}-\d{2}$' THEN TO_DATE(last_credit_pull_d, 'Mon-YY')
      WHEN last_credit_pull_d ~ '^[A-Za-z]{3}-\d{4}$' THEN TO_DATE(last_credit_pull_d, 'Mon-YYYY')
      ELSE NULL::DATE
    END                                                      AS last_credit_pull_d,

    -- Collections / derogatory
    NULLIF(collections_12_mths_ex_med,'')::INT               AS collections_12_mths_ex_med,
    NULLIF(mths_since_last_major_derog,'')::INT              AS mths_since_last_major_derog,

    -- Policy & application (keep – useful slices)
    NULLIF(policy_code,'')::INT                              AS policy_code,
    application_type,

    -- Joint app fields
    NULLIF(annual_inc_joint,'')::NUMERIC                     AS annual_inc_joint,
    NULLIF(dti_joint,'')::NUMERIC                            AS dti_joint,
    verification_status_joint,

    -- More bureau/cur balances
    NULLIF(acc_now_delinq,'')::INT                           AS acc_now_delinq,
    NULLIF(tot_coll_amt,'')::NUMERIC                         AS tot_coll_amt,
    NULLIF(tot_cur_bal,'')::NUMERIC                          AS tot_cur_bal,

    -- Recent openings & utilization
    NULLIF(open_acc_6m,'')::INT                              AS open_acc_6m,
    NULLIF(open_il_6m,'')::INT                               AS open_il_6m,
    NULLIF(open_il_12m,'')::INT                              AS open_il_12m,
    NULLIF(open_il_24m,'')::INT                              AS open_il_24m,
    NULLIF(mths_since_rcnt_il,'')::INT                       AS mths_since_rcnt_il,
    NULLIF(total_bal_il,'')::NUMERIC                         AS total_bal_il,
    NULLIF(il_util,'')::NUMERIC                              AS il_util,
    NULLIF(open_rv_12m,'')::INT                              AS open_rv_12m,
    NULLIF(open_rv_24m,'')::INT                              AS open_rv_24m,
    NULLIF(max_bal_bc,'')::NUMERIC                           AS max_bal_bc,
    NULLIF(all_util,'')::NUMERIC                             AS all_util,
    NULLIF(total_rev_hi_lim,'')::NUMERIC                     AS total_rev_hi_lim,

    -- Inquiries
    NULLIF(inq_fi,'')::INT                                   AS inq_fi,
    NULLIF(total_cu_tl,'')::INT                              AS total_cu_tl,
    NULLIF(inq_last_12m,'')::INT                             AS inq_last_12m

  FROM star_schema.staging_loans
)
SELECT
  -- drop noisy/unneeded fields here (url, desc, member_id, pymnt_plan)
  *
FROM cleaned;

-- Should equal 466,285
SELECT COUNT(*) FROM star_schema.clean_loans;

DROP TABLE IF EXISTS star_schema.staging_loans;
DROP TABLE IF EXISTS star_schema.clean_loans;



















