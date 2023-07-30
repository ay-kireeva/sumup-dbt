SELECT
happened_at AS report_date,
,d.id AS device_id
,device_type
,country
,city
,COUNT(DISTINCT t.id) AS transactions
	,SUM(amount) AS transacted_amount
	,COUNT(DISTINCT card_number) AS customers
FROM 
{{source('curated_data_shared', 'device’')}} d
JOIN 
{{source('curated_data_shared', 'transaction’')}} t
ON d.id = t.device_id
JOIN
	{{source('curated_data_shared', 'store’')}} AS s
	ON s.id = d.store_id
GROUP BY 1, 2, 3, 4, 5
