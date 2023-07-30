SELECT
	happened_at AS report_date,
  ,country
  ,city
  ,store_id
  ,store_name
  ,typology
  ,COUNT(DISTINCT t.id) AS transactions
  ,SUM(amount) AS transacted_amount
FROM 
{{source('curated_data_shared', 'store’')}} AS s
JOIN 
{{source('curated_data_shared', 'device’')}} AS d
ON s.id = d.store_id
JOIN 
{{source('curated_data_shared', 'transaction’')}} AS t
ON d.id = t.device_id
GROUP BY 1, 2, 3, 4, 5, 6
