SELECT
happened_at AS report_date,
,product_name
,product_sku
,category_name
,country
,COUNT(DISTINCT t.id) AS transactions
	,SUM(amount) AS transacted_amount
FROM 
	{{source('curated_data_shared', 'transaction’')}} t
JOIN 
	{{source('curated_data_shared', 'device’')}} d
ON d.id = t.device_id
JOIN
	{{source('curated_data_shared', 'store’')}} AS s
	ON s.id = d.store_id
GROUP BY 1, 2, 3, 4, 5
