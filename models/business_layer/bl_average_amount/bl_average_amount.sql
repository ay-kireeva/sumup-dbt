SELECT
	country
	,typology
	,AVG(transacted_amount) AS average_transacted_amount
FROM {{source('curated_data_shared', 'store’')}} AS s
JOIN {{source('curated_data_shared', 'device’')}} AS d
ON s.id = d.store_id
JOIN {{source('curated_data_shared', 'transaction’')}} AS t
ON d.id = t.device_id
WHERE {% if is_incremental() %}
happened_at >= date_trunc(date_sub(current_date(), interval 1 week), week) 
AND
happened_at <= date_sub(current_date(), interval 1 day)
            {% else %}
            happened_at >= date_trunc(date_sub(current_date(), interval 13 month), month) AND
             happened_at <= date_sub(current_date(), interval 1 day)
            {% endif %}
GROUP BY 1,2
