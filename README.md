# U.S. Medicare Hospital Spending & Benchmark Analysis

## Overview

This project uses PostgreSQL to analyze 2024 Medicare hospital spending data across 2,893 U.S. hospitals.

The analysis compares hospital spending with state and national benchmarks, examines where spending occurs across the episode of care, identifies the claim types driving costs, and highlights hospitals and states with notable spending differences.

The goal of the project was to demonstrate practical SQL skills for answering business and healthcare administration questions.

## Dataset

- 63,646 records
- 2,893 hospitals
- 13 variables
- Reporting period: January 1, 2024 – December 31, 2024
- 49 states plus Washington, D.C.
- 8 claim types
- 4 care periods

The dataset includes hospital-level average Medicare spending as well as state and national average spending benchmarks.

### Data Note

The source documentation indicated nationwide coverage, but Maryland (`MD`) was not present in the downloaded dataset. The analysis therefore contains 49 states plus Washington, D.C., for 50 geographic codes.

## Tools

- PostgreSQL 18
- pgAdmin 4
- SQL
- GitHub

## SQL Skills Demonstrated

- SELECT, WHERE, GROUP BY, and ORDER BY
- Aggregate functions
- CASE WHEN logic
- Common Table Expressions (CTEs)
- JOINs
- Conditional aggregation
- Window functions
- RANK() and PARTITION BY
- Benchmark calculations
- Percentage variance calculations
- PERCENTILE_CONT()
- Data validation and quality checks

## Analysis

The SQL analysis contains 11 business-focused queries covering:

1. Hospital complete-episode spending and benchmark comparisons
2. State spending benchmarks
3. Hospital rankings within states
4. Spending across care periods
5. Claim-type spending composition
6. Post-discharge spending drivers
7. State post-discharge benchmarks
8. Hospital post-discharge spending exceptions
9. Hospital benchmark-status distribution
10. State-level shares of hospitals above benchmarks
11. Executive summary metrics

## Key Findings

- Average complete-episode hospital spending was **$25,692.79**, compared with a **$27,477 national benchmark**.
- The median hospital complete-episode spending amount was **$25,664**.
- **32.42%** of hospitals exceeded the national complete-episode benchmark.
- **27.48%** of hospitals exceeded both their state and national benchmarks.
- **63.95%** of hospitals were at or below both benchmarks.
- Spending was concentrated during and after hospitalization: **49.79%** occurred during admission and **46.30%** within 30 days after discharge.
- Inpatient services represented approximately **59.90%** of complete-episode spending.
- Skilled Nursing Facility spending was the largest post-discharge component, representing approximately **17.30%** of the complete episode.
- New Jersey had the highest observed state post-discharge benchmark at **$14,224**, approximately **15.26% above** the national post-discharge benchmark.
- Several individual hospitals recorded post-discharge spending more than **100% above their state benchmark**, identifying spending exceptions for further investigation.

## Benchmark Distribution

| Benchmark Status | Hospitals | Share |
|---|---:|---:|
| At or Below Both | 1,850 | 63.95% |
| Above State & National | 795 | 27.48% |
| Above National Only | 143 | 4.94% |
| Above State Only | 105 | 3.63% |

## Limitations

This analysis measures Medicare spending, not hospital quality or efficiency.

Higher spending does not necessarily indicate poor performance, inefficient care, or avoidable readmissions. Differences may reflect patient severity, case mix, service utilization, regional costs, or other factors not included in the dataset.

The dataset does not contain sufficient information about clinical outcomes, patient risk, hospital capacity, or quality-adjusted performance.

Results should therefore be interpreted as spending patterns and benchmark exceptions rather than measures of hospital quality.

## Repository Files

- `medicare_hospital_spending_analysis.sql` - complete SQL analysis
- `Medicare_Hospital_Spending_by_Claim.csv` - source dataset
- `README.md` - project documentation

## AI Assistance

ChatGPT was used as a development assistant for SQL query design, debugging, project structure, and analytical interpretation. I executed and validated the queries, reviewed the outputs, and determined the final findings presented in this project.

## Author

Samuel Ibikunle
