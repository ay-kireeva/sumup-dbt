SELECT
	store_id
,AVG(time_difference) AS average_time
FROM
(SELECT
	store_id
	,DATETIME_DIFF(happened_at, LAG(happened_at,1) OVER (PARTITION BY store_id ORDER BY time_rank DESC), HOUR) AS time_difference
FROM
	(SELECT
		s.id AS store_id
	,t.id AS transaction_id
	,happened_at
	,ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY happened_at DESC
FROM store AS s
JOIN device AS d
ON s.id = d.store_id
JOIN transaction AS t
ON d.id = t.device_id) AS store_transaction
WHERE
	time_rank IN (1,5)) AS time_diff) 
            {% if is_incremental() %}
happened_at >= date_trunc(date_sub(current_date(), interval 1 week), week) 
AND
happened_at <= date_sub(current_date(), interval 1 day)
            {% else %}
            happened_at >= date_trunc(date_sub(current_date(), interval 13 month), month) 
AND
                        happened_at <= date_sub(current_date(), interval 1 day)
            {% endif %}) AS time_rank
GROUP BY 1
