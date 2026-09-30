-- ============================================================
-- U.S. MEDICARE HOSPITAL SPENDING & BENCHMARK ANALYSIS
-- PostgreSQL Portfolio Project
-- Dataset: Medicare Hospital Spending by Claim (2024)
-- Table: medicare_spending
-- ============================================================


-- BUSINESS QUESTION 1

SELECT
    facility_name,
    facility_id,
    state,
    hospital_avg_spending,
    state_avg_spending,
    national_avg_spending,

    hospital_avg_spending - state_avg_spending
        AS difference_from_state,

    hospital_avg_spending - national_avg_spending
        AS difference_from_national,

    ROUND(
        ((hospital_avg_spending - state_avg_spending)
        / NULLIF(state_avg_spending, 0)) * 100,
        2
    ) AS pct_difference_from_state,

    ROUND(
        ((hospital_avg_spending - national_avg_spending)
        / NULLIF(national_avg_spending, 0)) * 100,
        2
    ) AS pct_difference_from_national,

    CASE
        WHEN hospital_avg_spending > state_avg_spending
         AND hospital_avg_spending > national_avg_spending
            THEN 'Above State & National'

        WHEN hospital_avg_spending > state_avg_spending
            THEN 'Above State Only'

        WHEN hospital_avg_spending > national_avg_spending
            THEN 'Above National Only'

        ELSE 'At or Below Both'
    END AS benchmark_status

FROM medicare_spending

WHERE period = 'Complete Episode'
  AND claim_type = 'Total'

ORDER BY hospital_avg_spending DESC

LIMIT 20;



-- BUSINESS QUESTION 2


SELECT
    state,

    COUNT(DISTINCT facility_id)
        AS hospital_count,

    MAX(state_avg_spending)
        AS state_avg_spending,

    MAX(national_avg_spending)
        AS national_avg_spending,

    MAX(state_avg_spending)
        - MAX(national_avg_spending)
        AS difference_from_national,

    ROUND(
        (
            (MAX(state_avg_spending)
            - MAX(national_avg_spending))
            / NULLIF(MAX(national_avg_spending), 0)
        ) * 100,
        2
    ) AS pct_difference_from_national

FROM medicare_spending

WHERE period = 'Complete Episode'
  AND claim_type = 'Total'

GROUP BY state

ORDER BY state_avg_spending DESC;



-- BUSINESS QUESTION 3

WITH hospital_benchmarks AS (

    SELECT
        facility_name,
        facility_id,
        state,
        hospital_avg_spending,
        state_avg_spending,

        hospital_avg_spending - state_avg_spending
            AS difference_from_state,

        ROUND(
            (
                (hospital_avg_spending - state_avg_spending)
                / NULLIF(state_avg_spending, 0)
            ) * 100,
            2
        ) AS pct_difference_from_state

    FROM medicare_spending

    WHERE period = 'Complete Episode'
      AND claim_type = 'Total'
      AND hospital_avg_spending > state_avg_spending
),

ranked_hospitals AS (

    SELECT
        *,

        RANK() OVER (
            PARTITION BY state
            ORDER BY difference_from_state DESC
        ) AS state_rank

    FROM hospital_benchmarks
)

SELECT
    facility_name,
    facility_id,
    state,
    hospital_avg_spending,
    state_avg_spending,
    difference_from_state,
    pct_difference_from_state,
    state_rank

FROM ranked_hospitals

WHERE state_rank <= 3

ORDER BY state, state_rank;



-- BUSINESS QUESTION 4

WITH period_spending AS (

    SELECT
        facility_id,
        period,

        SUM(hospital_avg_spending)
            AS period_spending

    FROM medicare_spending

    WHERE period <> 'Complete Episode'

    GROUP BY
        facility_id,
        period
),

episode_spending AS (

    SELECT
        facility_id,

        hospital_avg_spending
            AS complete_episode_spending

    FROM medicare_spending

    WHERE period = 'Complete Episode'
      AND claim_type = 'Total'
)

SELECT
    p.period,

    ROUND(
        AVG(p.period_spending),
        2
    ) AS avg_spending_per_hospital,

    ROUND(
        AVG(
            (p.period_spending
            / NULLIF(e.complete_episode_spending, 0)) * 100
        ),
        2
    ) AS avg_pct_of_complete_episode

FROM period_spending p

JOIN episode_spending e
    ON p.facility_id = e.facility_id

GROUP BY p.period

ORDER BY
    CASE p.period

        WHEN '1 to 3 days Prior to Index Hospital Admission'
            THEN 1

        WHEN 'During Index Hospital Admission'
            THEN 2

        WHEN '1 through 30 days After Discharge from Index Hospital Admission'
            THEN 3

    END;




-- BUSINESS QUESTION 5

WITH claim_spending AS (

    SELECT
        facility_id,
        claim_type,

        SUM(hospital_avg_spending)
            AS claim_type_spending

    FROM medicare_spending

    WHERE period <> 'Complete Episode'

    GROUP BY
        facility_id,
        claim_type
),

episode_spending AS (

    SELECT
        facility_id,

        hospital_avg_spending
            AS complete_episode_spending

    FROM medicare_spending

    WHERE period = 'Complete Episode'
      AND claim_type = 'Total'
)

SELECT
    c.claim_type,

    ROUND(
        AVG(c.claim_type_spending),
        2
    ) AS avg_spending_per_hospital,

    ROUND(
        AVG(
            (c.claim_type_spending
            / NULLIF(e.complete_episode_spending, 0)) * 100
        ),
        2
    ) AS avg_pct_of_complete_episode

FROM claim_spending c

JOIN episode_spending e
    ON c.facility_id = e.facility_id

GROUP BY c.claim_type

ORDER BY avg_spending_per_hospital DESC;



-- BUSINESS QUESTION 6

SELECT
    claim_type,

    ROUND(
        AVG(hospital_avg_spending),
        2
    ) AS avg_post_discharge_spending,

    ROUND(
        AVG(hospital_spending_pct),
        2
    ) AS avg_post_discharge_pct

FROM medicare_spending

WHERE period =
    '1 through 30 days After Discharge from Index Hospital Admission'

GROUP BY claim_type

ORDER BY avg_post_discharge_spending DESC;



-- BUSINESS QUESTION 7

WITH state_claim_benchmarks AS (

    SELECT
        state,
        claim_type,

        MAX(state_avg_spending)
            AS state_claim_spending,

        MAX(national_avg_spending)
            AS national_claim_spending

    FROM medicare_spending

    WHERE period =
        '1 through 30 days After Discharge from Index Hospital Admission'

    GROUP BY
        state,
        claim_type
),

state_post_discharge AS (

    SELECT
        state,

        SUM(state_claim_spending)
            AS state_post_discharge_spending,

        SUM(national_claim_spending)
            AS national_post_discharge_spending

    FROM state_claim_benchmarks

    GROUP BY state
)

SELECT
    state,
    state_post_discharge_spending,
    national_post_discharge_spending,

    state_post_discharge_spending
        - national_post_discharge_spending
        AS difference_from_national,

    ROUND(
        (
            (state_post_discharge_spending
            - national_post_discharge_spending)
            / NULLIF(national_post_discharge_spending, 0)
        ) * 100,
        2
    ) AS pct_difference_from_national,

    RANK() OVER (
        ORDER BY state_post_discharge_spending DESC
    ) AS spending_rank

FROM state_post_discharge

ORDER BY spending_rank;



-- BUSINESS QUESTION 8

WITH hospital_post_discharge AS (

    SELECT
        facility_name,
        facility_id,
        state,

        SUM(hospital_avg_spending)
            AS hospital_post_discharge_spending,

        SUM(state_avg_spending)
            AS state_post_discharge_benchmark

    FROM medicare_spending

    WHERE period =
        '1 through 30 days After Discharge from Index Hospital Admission'

    GROUP BY
        facility_name,
        facility_id,
        state
),

benchmark_gaps AS (

    SELECT
        *,

        hospital_post_discharge_spending
            - state_post_discharge_benchmark
            AS difference_from_state,

        ROUND(
            (
                (hospital_post_discharge_spending
                - state_post_discharge_benchmark)
                / NULLIF(state_post_discharge_benchmark, 0)
            ) * 100,
            2
        ) AS pct_difference_from_state

    FROM hospital_post_discharge
)

SELECT
    facility_name,
    facility_id,
    state,
    hospital_post_discharge_spending,
    state_post_discharge_benchmark,
    difference_from_state,
    pct_difference_from_state

FROM benchmark_gaps

WHERE hospital_post_discharge_spending
      > state_post_discharge_benchmark

ORDER BY pct_difference_from_state DESC

LIMIT 20;



-- BUSINESS QUESTION 9

WITH hospital_status AS (

    SELECT
        facility_id,
        facility_name,
        state,
        hospital_avg_spending,
        state_avg_spending,
        national_avg_spending,

        CASE
            WHEN hospital_avg_spending > state_avg_spending
             AND hospital_avg_spending > national_avg_spending
                THEN 'Above State & National'

            WHEN hospital_avg_spending > state_avg_spending
                THEN 'Above State Only'

            WHEN hospital_avg_spending > national_avg_spending
                THEN 'Above National Only'

            ELSE 'At or Below Both'

        END AS benchmark_status

    FROM medicare_spending

    WHERE period = 'Complete Episode'
      AND claim_type = 'Total'
)

SELECT
    benchmark_status,

    COUNT(*)
        AS hospital_count,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_hospitals

FROM hospital_status

GROUP BY benchmark_status

ORDER BY hospital_count DESC;



-- BUSINESS QUESTION 10

WITH hospital_status AS (

    SELECT
        facility_id,
        state,

        CASE
            WHEN hospital_avg_spending > state_avg_spending
             AND hospital_avg_spending > national_avg_spending
                THEN 1

            ELSE 0

        END AS above_both

    FROM medicare_spending

    WHERE period = 'Complete Episode'
      AND claim_type = 'Total'
)

SELECT
    state,

    COUNT(*)
        AS hospital_count,

    SUM(above_both)
        AS hospitals_above_both,

    ROUND(
        SUM(above_both) * 100.0
        / COUNT(*),
        2
    ) AS pct_hospitals_above_both,

    RANK() OVER (
        ORDER BY
            SUM(above_both) * 100.0
            / COUNT(*) DESC
    ) AS state_rank

FROM hospital_status

GROUP BY state

ORDER BY state_rank;



-- BUSINESS QUESTION 11

WITH complete_episode AS (

    SELECT
        facility_id,
        facility_name,
        state,
        hospital_avg_spending,
        state_avg_spending,
        national_avg_spending

    FROM medicare_spending

    WHERE period = 'Complete Episode'
      AND claim_type = 'Total'
)

SELECT
    COUNT(*)
        AS total_hospitals,

    COUNT(DISTINCT state)
        AS states_and_dc,

    MAX(national_avg_spending)
        AS national_complete_episode_benchmark,

    ROUND(
        AVG(hospital_avg_spending),
        2
    ) AS avg_hospital_complete_episode_spending,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY hospital_avg_spending
        )::NUMERIC,
        2
    ) AS median_hospital_complete_episode_spending,

    SUM(
        CASE
            WHEN hospital_avg_spending > national_avg_spending
                THEN 1
            ELSE 0
        END
    ) AS hospitals_above_national,

    ROUND(
        SUM(
            CASE
                WHEN hospital_avg_spending > national_avg_spending
                    THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS pct_hospitals_above_national,

    SUM(
        CASE
            WHEN hospital_avg_spending > state_avg_spending
             AND hospital_avg_spending > national_avg_spending
                THEN 1
            ELSE 0
        END
    ) AS hospitals_above_state_and_national,

    ROUND(
        SUM(
            CASE
                WHEN hospital_avg_spending > state_avg_spending
                 AND hospital_avg_spending > national_avg_spending
                    THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS pct_above_state_and_national

FROM complete_episode;



-- ============================================================
-- FINAL VALIDATION CHECK
-- ============================================================

SELECT
    SUM(
        CASE
            WHEN hospital_avg_spending > state_avg_spending
             AND hospital_avg_spending > national_avg_spending
                THEN 1
            ELSE 0
        END
    ) AS above_both,

    SUM(
        CASE
            WHEN hospital_avg_spending > state_avg_spending
             AND hospital_avg_spending <= national_avg_spending
                THEN 1
            ELSE 0
        END
    ) AS above_state_only,

    SUM(
        CASE
            WHEN hospital_avg_spending <= state_avg_spending
             AND hospital_avg_spending > national_avg_spending
                THEN 1
            ELSE 0
        END
    ) AS above_national_only,

    SUM(
        CASE
            WHEN hospital_avg_spending <= state_avg_spending
             AND hospital_avg_spending <= national_avg_spending
                THEN 1
            ELSE 0
        END
    ) AS at_or_below_both

FROM medicare_spending

WHERE period = 'Complete Episode'
  AND claim_type = 'Total';