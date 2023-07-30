SELECT
	device_type
	,transactions
,100*RATIO_TO_REPORT(transactions) OVER () AS transaction_percentage
FROM
	(SELECT
		d.type as device_type
		,COUNT(t.id) AS transactions
	FROM {{source('curated_data_shared', 'device’')}} d
	JOIN {{source('curated_data_shared', 'transaction’')}} t
		ON d.id = t.device_id
	GROUP BY 1) AS device_transactions
;
# or without legacy functions
SELECT
	device_type
	,transactions
	,100 * transactions / SUM(transactions) OVER () as transaction_percentage
FROM
	(SELECT
		d.type as device_type
		,COUNT(t.id) AS transactions
	FROM {{source('curated_data_shared', 'device’')}} d
	JOIN {{source('curated_data_shared', 'transaction’')}} t
		ON d.id = t.device_id
	GROUP BY 1) AS device_transactions
