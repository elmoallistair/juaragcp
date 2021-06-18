-- Insights from Data with BigQuery: Challenge Lab 
-- https://www.qwiklabs.com/focuses/11988?parent=catalog

-- Setup: 
    -- Open BigQuery
    -- Click ADD DATA
    -- Choose Explore public dataset 
    -- Search for "COVID-19 Open Data" 
    -- View dataset

-- Query 1: Total Confirmed Cases
-- What was the total count of confirmed cases on Apr 15, 2020?
SELECT SUM(cumulative_confirmed) AS total_cases_worldwide 
FROM `bigquery-public-data.covid19_open_data.covid19_open_data` 
WHERE date='2020-04-15'

-- Expected:
-- Row 	    total_cases_worldwide 	
-- 1	    5141591
	

-- Query 2: Worst Affected Areas
-- How many states in the US had more than 100 deaths on Apr 10, 2020?
SELECT COUNT(*) AS count_of_states
FROM (
    SELECT 
        subregion1_name AS state, 
        SUM(cumulative_deceased) AS death_count
    FROM `bigquery-public-data.covid19_open_data.covid19_open_data` 
    WHERE country_name="United States of America" AND date='2020-04-10' AND subregion1_name IS NOT NULL
    GROUP BY subregion1_name
)
WHERE death_count > 100

-- Expected:
-- Row 	    count_of_states 	
-- 1	    30


-- Query 3: Identifying Hotspots
-- "List all the states in the United States of America that had more than 1000 confirmed cases on Apr 10, 2020?" 
SELECT 
    subregion1_name AS state,
    SUM(cumulative_confirmed) AS total_confirmed_cases
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE country_name="United States of America" AND date='2020-04-10' AND subregion1_name IS NOT NULL
GROUP BY subregion1_name
HAVING total_confirmed_cases > 1000
ORDER BY total_confirmed_cases DESC

-- Expected:
-- Row 	    state 	    total_confirmed_cases 	
-- 1	    null            501560
-- 2	    New York        485750
-- 3	    New Jersey      108527
-- ...      ...             ...	


-- Query 4: Fatality Ratio
-- "What was the case-fatality ratio in Italy for the month of April 2020?"
SELECT 
    SUM(cumulative_confirmed) AS total_confirmed_cases,
    SUM(cumulative_deceased) AS total_deaths,
    (SUM(cumulative_deceased)/SUM(cumulative_confirmed))*100 AS case_fatality_ratio
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE country_name="Italy" AND date BETWEEN "2020-04-01" AND "2020-04-30"

-- Expected:
-- Row 	    total_confirmed_cases 	total_deaths 	case_fatality_ratio 	
-- 1	    14452840                    1288342         8.91410961444256
	

-- Query 5: Identifying specific day
-- "On what day did the total number of deaths cross 10000 in Italy?" 
SELECT date
FROM `bigquery-public-data.covid19_open_data.covid19_open_data` 
WHERE country_name="Italy" AND cumulative_deceased > 10000
ORDER BY date ASC
LIMIT 1

-- Expected:
-- Row 	    date 	
-- 1        2020-03-28
	

-- Query 6: Finding days with zero net new cases
-- Update the query for identify the number of days in India between 21 Feb 2020 and 15 March 2020 when there were zero increases
WITH india_cases_by_date AS (
    SELECT
        date,
        SUM(cumulative_confirmed) AS cases
    FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
    WHERE country_name ="India" AND date BETWEEN '2020-02-21' AND '2020-03-15'
    GROUP BY date
    ORDER BY date ASC 
), 
india_previous_day_comparison AS (
    SELECT
        date,
        cases,
        LAG(cases) OVER(ORDER BY date) AS previous_day,
        cases - LAG(cases) OVER(ORDER BY date) AS net_new_cases
    FROM india_cases_by_date
)

SELECT COUNT(*) AS days_with_zero_increase
FROM india_previous_day_comparison
WHERE net_new_cases=0

-- Expected:
-- Row 	    days_with_zero_increase
-- 1	    10
	

-- Query 7: Doubling rate
-- Write a query to find out the dates on which the confirmed cases increased by more than 10% compared to the previous day (indicating doubling rate of ~ 7 days) in the US between the dates March 22, 2020 and April 20, 2020. 
WITH us_cases_by_date AS (
    SELECT
        date,
        SUM( cumulative_confirmed ) AS cases
    FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
    WHERE country_name="United States of America" AND date between '2020-03-22' and '2020-04-20'
    GROUP BY date
    ORDER BY date ASC
), 
us_previous_day_comparison AS (
    SELECT
        date,
        cases,
        LAG(cases) OVER(ORDER BY date) AS previous_day,
        cases - LAG(cases) OVER(ORDER BY date) AS net_new_cases,
       (cases - LAG(cases) OVER(ORDER BY date))*100/LAG(cases) OVER(ORDER BY date) AS percentage_increase
    FROM us_cases_by_date
)
SELECT
    Date,
    cases AS Confirmed_Cases_On_Day,
    previous_day AS Confirmed_Cases_Previous_Day,
    percentage_increase AS Percentage_Increase_In_Cases
FROM us_previous_day_comparison
WHERE percentage_increase > 10


-- Expected:
-- Row 	    Date 	    Confirmed_Cases_On_Day 	Confirmed_Cases_Previous_Day 	Percentage_Increase_In_Cases
-- 1	    2020-03-23      174502                      138993                          25.547329721640658
-- 2	    2020-03-24      210889                      174502                          20.8519100067621
-- 3	    2020-03-25      258482                      210889                          22.567796328874433
-- ...      ...             ...	                        ...                             ...


-- Query 8: Recovery rate
-- List the recovery rates of countries arranged in descending order (limit to 10) on the date May 10, 2020. 
-- Restrict the query to only those countries having more than 50K confirmed cases.
WITH cases_by_country AS (
    SELECT
        country_name AS country,
        SUM(cumulative_confirmed) AS cases,
        SUM(cumulative_recovered) AS recovered_cases
    FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
    WHERE date='2020-05-10'
    GROUP BY country_name
), 
recovered_rate AS (
    SELECT
        country, cases, recovered_cases,
        (recovered_cases * 100)/cases AS recovery_rate
    FROM cases_by_country
)

SELECT country, cases AS confirmed_cases, recovered_cases, recovery_rate
FROM recovered_rate
WHERE cases > 50000
ORDER BY recovery_rate desc
LIMIT 10

-- Expected:
-- Row 	    country 	confirmed_cases     recovered_cases 	recovery_rate 	
-- 1	    France      216270              3035852             1403.7323715725713
-- 2	    China       157738              147983              93.81569437928717
-- 3	    Italy       643471              210372              32.69331485024189
-- ...      ...         ...                 ...                 ...	


-- Query 9: CDGR - Cumulative Daily Growth Rate
-- Calculate the CDGR on May 10, 2020(Cumulative Daily Growth Rate) for France since the day the first case was reported. 
-- The first case was reported on Jan 24, 2020.
WITH
  france_cases AS (
  SELECT
    date,
    SUM(cumulative_confirmed) AS total_cases
  FROM
    `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE
    country_name="France"
    AND date IN ('2020-01-24',
      '2020-05-10')
  GROUP BY
    date
  ORDER BY
    date)
, summary as (
SELECT
  total_cases AS first_day_cases,
  LEAD(total_cases) OVER(ORDER BY date) AS last_day_cases,
  DATE_DIFF(LEAD(date) OVER(ORDER BY date),date, day) AS days_diff
FROM
  france_cases
LIMIT 1
)

select first_day_cases, last_day_cases, days_diff, POW((last_day_cases/first_day_cases),(1/days_diff))-1 as cdgr
from summary

-- Expected
-- Row      first_day_cases      last_day_cases     days_diff 	    cdgr 	
-- 1        3                    216270             107             0.11019866604973183


-- Query 10: Create a Datastudio report
-- Create a Datastudio report that plots the following for the United States:
    -- Number of Confirmed Cases
    -- Number of Deaths
    -- Date range : 2020-03-15 to 2020-04-30

-- Query:
SELECT
    date, SUM(cumulative_confirmed) AS country_cases,
    SUM(cumulative_deceased) AS country_deaths
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE date BETWEEN '2020-03-15' AND '2020-04-30' AND country_name ="United States of America"
GROUP BY date

-- Expected:
-- Row 	    date 	    country_cases 	country_deaths 	
-- 1	    2020-03-15      16708               218
-- 2	    2020-03-16      23563               295
-- 3	    2020-03-17      32882               384

-- After executing:
    -- Click EXPLORE DATA
    -- Select Explore with Data Studio
    -- *in data studio**
        -- Add/drag country_cases and country deaths field to metric
        -- In chart, click Time series chart
    -- Check your progress
