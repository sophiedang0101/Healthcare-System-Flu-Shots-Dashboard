/*
Objectives
Come up with flu shots dashboard for 2022 that does the following

1.) Total % of patients getting flu shots stratified by
   a.) Age
   b.) Race
   c.) County (On a Map)
   d.) Overall
2.) Running Total of Flu Shots over the course of 2022
3.) Total number of Flu shots given in 2022
4.) A list of Patients that show whether or not they received the flu shots
   
Requirements:

Patients must have been "Active at our hospital"
*/

WITH active_patients AS (
    SELECT DISTINCT patient
    FROM public.encounters AS e
    JOIN patients AS pat ON e.patient = pat.id
    WHERE start BETWEEN '2020-01-01 00:00' AND '2022-12-31 23:59'
    AND pat.deathdate IS NULL
),

flu_shot_2022 AS (
    SELECT
        patient,
        MIN(date) AS earliest_flu_shot_2022
    FROM
        public.immunizations
    WHERE
        code = '5302'
        AND date BETWEEN '2022-01-01 00:00' AND '2022-12-31 23:59'
    GROUP BY
        patient
)


SELECT
    pat.birthdate,
    pat.race,
    pat.county,
    pat.id,
    pat.first,
    pat.last,
    pat.gender,
    EXTRACT(YEAR FROM age('2022-12-31', pat.birthdate)) AS age,
    flu.earliest_flu_shot_2022,
    flu.patient,
    CASE
        WHEN flu.patient IS NOT NULL THEN 1
        ELSE 0
    END AS flu_shot_2022
FROM
    patients AS pat
LEFT JOIN flu_shot_2022 AS flu ON pat.id = flu.patient
WHERE
    pat.id IN (SELECT patient FROM active_patients);



WITH flu_shot_2022 AS (
    SELECT
        patient,
        MIN(date) AS earliest_flu_shot_2022
    FROM
        public.immunizations
    WHERE
        code = '5302'
        AND date BETWEEN '2022-01-01 00:00' AND '2022-12-31 23:59'
    GROUP BY
        patient
)

SELECT
    pat.county,
    COUNT(flu.patient) AS flu_shot_count
FROM
    patients AS pat
LEFT JOIN flu_shot_2022 AS flu ON pat.id = flu.patient
GROUP BY
    pat.county;

