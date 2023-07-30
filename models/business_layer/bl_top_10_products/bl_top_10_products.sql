SELECT
	TOP(product_sku,10) AS product
,COUNT(*) AS products_sold
FROM
	{{source('curated_data_shared', 'transaction’')}}
;
– or similar to the one above (TOP is a legacy function)
SELECT
	product_name
	,product_sku
	,products_sold
FROM
	(SELECT
		product_name
		,product_sku
	,COUNT(id) AS products_sold
	,ROW_NUMBER() OVER (ORDER BY COUNT(id) DESC) AS product_rank
FROM {{ source('curated_data_shared', 'transaction’')}}
WHERE {% if is_incremental() %}
                happened_at >= date_trunc(date_sub(current_date(), interval 1 week), week) 
AND
                happened_at <= date_sub(current_date(), interval 1 day)
            {% else %}
            	happened_at >= date_trunc(date_sub(current_date(), interval 13 month), month) AND
                happened_at <= date_sub(current_date(), interval 1 day)
            {% endif %}
GROUP BY 1, 2) AS products
WHERE product_rank <= 10
ORDER BY 3 DESC
