SELECT
	store_id
	,store_name
	,transacted_amount
FROM
	(SELECT
		s.id AS store_id
		,store_name
		,SUM(amount) AS transacted_amount
		,ROW_NUMBER() OVER (ORDER BY SUM(amount) DESC) AS store_rank
	FROM {{source('curated_data_shared', 'store’')}} AS s
	JOIN {{source('curated_data_shared', 'device’')}} AS d
	ON s.id = d.store_id
	JOIN {{source('curated_data_shared', 'transaction’')}} AS t
	ON d.id = t.device_id
	GROUP BY 1, 2) AS store_amount
WHERE store_rank <= 10
AND {% if is_incremental() %}
                happened_at >= date_trunc(date_sub(current_date(), interval 1 week), week) AND
                happened_at <= date_sub(current_date(), interval 1 day)
            {% else %}
              happened_at >= date_trunc(date_sub(current_date(), interval 13 month), month) AND
                happened_at <= date_sub(current_date(), interval 1 day)
            {% endif %}

ORDER BY 3 DESC
