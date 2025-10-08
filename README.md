
# Lending Club - Risk Analytics

> Comprehensive data warehouse and BI report analyzing risk and return dynamics in U.S. peer-to-peer lending.

This project models LendingClub loan performance from 2007–2014 through a full **star schema** in PostgreSQL and visualizes insights with Power BI. Highlighting relationships between borrower profiles, loan grades, default behavior, and investor returns.

## 📘 Project Overview

Peer-to-peer lending offers a unique view into credit markets beyond traditional banks.  
This project aims to uncover how borrower characteristics and loan quality interact to shape credit risk and investment outcomes.

**Main objectives:**
- Quantify loan portfolio structure and performance  
- Measure default and recovery dynamics  
- Identify risk segmentation by borrower and loan features  
- Evaluate investor returns across risk tiers  
- Present results in an accessible BI dashboard

## 🏗️ Architecture

**Data Flow:**

Raw Data → Staging (staging.sql) → Star Schema (dim_*, fact_loans)
→ Analytical Queries (analyze.sql) → Power BI Dashboard

**Schema Design:**
- `dim_borrower` — borrower demographics and financials  
- `dim_loan` — loan attributes (grade, term, interest rate, purpose)  
- `dim_date` — issue date, quarter, and year structure  
- `fact_loans` — central transactional table linking dimensions  

## 🧮 Analytics

SQL-driven metrics developed and validated before BI visualization:

| Category | Key Indicators |
|-----------|----------------|
| **Portfolio Overview** | Total Loans, Volume, Funding Efficiency |
| **Performance & Risk** | Default Rate, Recovery, Repayment Ratio |
| **Borrower Insights** | Income Group Risk, Home Ownership, State Default |
| **Time-Series** | Issuance & Defaults over Years |
| **Investor View** | Average Interest, Return, Concentration by Purpose/State |

---

## 📊 Power BI Dashboard

The interactive dashboard includes:
- **Dynamic filters** by year, grade, and purpose  
- **KPI cards** summarizing portfolio and performance metrics  
- **Geospatial** and **time-series** visuals for trend analysis  
- **Executive Summary Page** consolidating key insights  

**Theme:**  
LendingClub-inspired corporate palette  
![#113B5E](https://placehold.co/15x15/113B5E/113B5E.png) `#113B5E` (navy), ![#EA4224](https://placehold.co/15x15/EA4224/EA4224.png) `#EA4224` (orange-red)


---
## ⚙️ Technical Stack

| Layer | Tool / Language |
|-------|-----------------|
| Data Warehouse | PostgreSQL |
| Data Modeling | Star Schema Design |
| ETL Scripts | SQL (staging.sql, utility.sql) |
| Analysis | SQL (analyze.sql, cte_experiments.sql) |
| Visualization | Power BI |

---

## 📈 Key Insights

- Default rates rise exponentially from **Grade A (3.4%) → Grade G (22.4%)**
- **Debt consolidation** loans dominate with **>60%** of total volume
- **High-income borrowers** show lowest default risk (~6.7%)
- Issuance surged post-2012 while **defaults fell to 6% by 2014**
- **Investor return** averaged around **–0.19**, showing negative yield post-fee

---

# About me
Find me at <https://www.linkedin.com/in/minhduyngn/>

