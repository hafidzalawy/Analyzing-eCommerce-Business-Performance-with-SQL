--1) Create a table that contains information on annual revenue
CREATE TABLE annual_revenue AS
	SELECT
		date_part('year', od.order_purchase_timestamp) AS year,
		ROUND(SUM(oid.price + oid.freight_value)::numeric, 2) AS revenue
	FROM order_items_dataset AS oid
	JOIN orders_dataset AS od
		ON oid.order_id = od.order_id
	WHERE od.order_status LIKE 'delivered'
	GROUP BY 1
	ORDER BY 1;

--2) Create a table that contains information on the total number of canceled orders per year
CREATE TABLE annual_canceled_order AS
	SELECT
		date_part('year', order_purchase_timestamp) AS year,
		COUNT(order_status) AS canceled
	FROM orders_dataset
	WHERE order_status LIKE 'canceled'
	GROUP BY 1
	ORDER BY 1;
		
--3) Create a table containing information on product categories that provide the highest total revenue per year
CREATE TABLE top_category AS
	SELECT 
		year,
		top_category,
		ROUND(product_revenue::numeric, 2) AS total_revenue_top_product
	FROM (
		SELECT
			date_part('year', shipping_limit_date) AS year,
			pd.product_category_name AS top_category,
			SUM(oid.price + oid.freight_value) AS product_revenue,
			RANK() OVER (PARTITION BY date_part('year', shipping_limit_date)
					 ORDER BY SUM(oid.price + oid.freight_value) DESC) AS ranking
		FROM orders_dataset AS od 
		JOIN order_items_dataset AS oid
			ON od.order_id = oid.order_id
		JOIN product_dataset AS pd
			ON oid.product_id = pd.product_id
		WHERE od.order_status LIKE 'delivered'
		GROUP BY 1, 2
		ORDER BY 1
		) AS sub
	WHERE ranking = 1;
	
--4) Create a table containing product category names that have the highest number of canceled orders per year
CREATE TABLE canceled_category AS
	SELECT 
		year,
		most_canceled,
		total_canceled
	FROM (
		SELECT
			date_part('year', shipping_limit_date) AS year,
			pd.product_category_name AS most_canceled,
			COUNT(od.order_id) AS total_canceled,
			RANK() OVER (PARTITION BY date_part('year', shipping_limit_date)
					 ORDER BY COUNT(od.order_id) DESC) AS ranking
		FROM orders_dataset AS od 
		JOIN order_items_dataset AS oid
			ON od.order_id = oid.order_id
		JOIN product_dataset AS pd
			ON oid.product_id = pd.product_id
		WHERE od.order_status LIKE 'canceled'
		GROUP BY 1, 2
		ORDER BY 1
		) AS sub
	WHERE ranking = 1;
	
-- Addition - Removed the year data anomaly
DELETE FROM top_category WHERE year = 2020;
DELETE FROM canceled_category WHERE year = 2020;

-- Showing all
SELECT 
	ar.year,
	ar.revenue AS annual_revenue,
	tp.top_category AS top_product,
	tp.total_revenue_top_product AS total_revenue_top_product,
	aco.canceled AS annual_canceled_order,
	cc.most_canceled AS top_canceled_product,
	cc.total_canceled AS total_top_canceled_product
FROM annual_revenue AS ar
JOIN top_category AS tp
	ON ar.year = tp.year
JOIN annual_canceled_order AS aco
	ON tp.year = aco.year
JOIN canceled_category AS cc
	ON aco.year = cc.year
GROUP BY 1, 2, 3, 4, 5, 6, 7;