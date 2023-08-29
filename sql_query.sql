WITH ranked_cte AS (
    SELECT
        intended_procedure,
        year,
        peer_group,
        SUM(number_of_surgeries) AS total_surg,
        RANK() OVER (PARTITION BY year, peer_group ORDER BY SUM(number_of_surgeries) DESC) AS procedure_rank
    FROM public.intended_procedure
    WHERE state = 'Qld'
    GROUP BY intended_procedure, year, peer_group
)

SELECT
    intended_procedure,
    year,
    peer_group,
    total_surg,
	procedure_rank
FROM ranked_cte
WHERE procedure_rank <= 5;

Top 5 procedures peergroup












SELECT sum(number_of_surgeries), year, peer_group
FROM public.intended_procedure
WHERE state = 'Qld' AND peer_group IS NOT NULL AND peer_group != 'National'
GROUP BY peer_group, year
ORDER BY year, peer_group

Total surge by peer 











SELECT 
    year, 
    state, 
    surgical_category, 
    peer_group, 
    ROUND(((median_waiting_time - peer_group_median_wait)* 100::decimal / peer_group_median_wait),2) AS percent_difference_from_peer_group_median
FROM public.surgical_specialty
WHERE state != 'NAT' AND peer_group_median_wait IS NOT NULL
ORDER BY state, year, peer_group;

percent_difference_from_peer_group_median












SELECT 
    year, 
    state, 
    urgency_category, 
    ROUND(AVG(median_wait_time) 
          OVER(PARTITION BY year, state, urgency_category), 2) AS avg_median_waiting_time
FROM public.urgency;

Avg_wait_time_urgency















WITH ranked_cte AS (
    SELECT
        intended_procedure,
        year,
        state,
        SUM(number_of_surgeries) AS total_surg,
        RANK() OVER (PARTITION BY year, state ORDER BY SUM(number_of_surgeries) DESC) AS procedure_rank
    FROM public.intended_procedure
    WHERE state != 'NAT'
    GROUP BY intended_procedure, year, state
)

SELECT
    intended_procedure,
    year,
    state,
    total_surg
FROM ranked_cte
WHERE procedure_rank <= 5;

Top 5 procedures by state








SELECT 
    year, 
    state, 
    surgical_category, 
    peer_group, 
    peer_group_median_wait, 
    median_waiting_time,
    ROUND(((median_waiting_time - peer_group_median_wait) * 100::decimal / peer_group_median_wait), 2) AS percent_difference
FROM public.surgical_specialty
WHERE state != 'NAT' AND peer_group_median_wait IS NOT NULL
ORDER BY state, year, peer_group;

Percent difference waiting times















WITH cte AS (
    SELECT 
        year, 
        peer_group,
        sum(number_of_surgeries) as total_surgeries,
        ROUND(avg(median_waiting_time_days),2) as wait_time_avg
    FROM public.intended_procedure
    WHERE state = 'Qld' AND peer_group IS NOT NULL AND peer_group != 'National'
    GROUP BY peer_group, year
)

SELECT 
    year,
    peer_group,
    total_surgeries,
    wait_time_avg,
    ROUND(
        100.0 * (total_surgeries - LAG(total_surgeries) OVER (PARTITION BY peer_group ORDER BY year)) / 
        LAG(total_surgeries) OVER (PARTITION BY peer_group ORDER BY year),
        2
    ) AS percent_change_surgeries,
	 ROUND(
        100.0 * (wait_time_avg- LAG(wait_time_avg) OVER (PARTITION BY peer_group ORDER BY year)) / 
        LAG(wait_time_avg) OVER (PARTITION BY peer_group ORDER BY year),
        2) as perecent_change_wait
FROM cte
ORDER BY year, peer_group;


YoY change qld















SELECT year, peer_group, surgical_category, ROUND(avg(percent_more_than_1y)::decimal,3) AS avg_percent_waiting_longer_than_1y, peer_group_percent_more_than_1y
FROM public.surgical_specialty
WHERE state = 'Qld' AND peer_group != 'Unpeered'
GROUP BY year, peer_group, surgical_category, peer_group_percent_more_than_1y 
ORDER BY year, surgical_category

Surgical_category >1y
