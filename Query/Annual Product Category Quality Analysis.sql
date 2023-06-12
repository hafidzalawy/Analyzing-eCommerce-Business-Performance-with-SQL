--1) Create a table that contains information on annual revenue
CREATE TABLE annual_revenue AS
	SELECT
		date_part('year', od.order_purchase_timestamp) AS year,
		ROUND(SUM(revenue_per_order)::numeric, 2) AS revenue
	FROM(
		SELECT order_id,
		SUM(price + freight_value) AS revenue_per_order
		FROM order_items_dataset
		GROUP BY order_id
		) AS sub
	JOIN orders_dataset AS od
		ON sub.order_id = od.order_id
	WHERE od.order_status = 'delivered'
	GROUP BY 1
	ORDER BY 1;

--2) Create a table that contains information on the total number of canceled orders per year
CREATE TABLE annual_canceled_order AS
	SELECT
		date_part('year', order_purchase_timestamp) AS year,
		COUNT(order_status) AS canceled
	FROM orders_dataset
	WHERE order_status = 'canceled'
	GROUP BY 1
	ORDER BY 1;

--3) Create a table containing information on product categories that provide the highest total revenue per year
CREATE TABLE top_product_category AS
	SELECT
		year,
		product_category_name,
		product_revenue
	FROM (
			SELECT
				date_part('year', od.order_purchase_timestamp) AS year,
				pd.product_category_name,
				ROUND(SUM(oid.price + oid.freight_value)::numeric, 2) AS product_revenue,
			RANK() OVER (PARTITION BY date_part('year', od.order_purchase_timestamp)
			ORDER BY SUM(oid.price + oid.freight_value) DESC) AS ranking
			FROM order_items_dataset AS oid
			JOIN orders_dataset AS od
				ON od.order_id = oid.order_id
			JOIN product_dataset AS pd
				ON pd.product_id = oid.product_id
			WHERE od.order_status = 'delivered'
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
		WHERE od.order_status = 'canceled'
		GROUP BY 1, 2
		ORDER BY 1
		) AS sub
	WHERE ranking = 1;

-- Additional - Removed the year data anomaly
DELETE FROM top_product_category WHERE year = 2020;
DELETE FROM canceled_category WHERE year = 2020;

-- Displaying all
SELECT
	ar.year,
	ar.revenue AS annual_revenue,
	tp.product_category_name AS top_product_category,
	tp.product_revenue AS total_revenue_top_product,
	aco.canceled AS annual_canceled_order,
	cc.most_canceled AS top_canceled_product,
	cc.total_canceled AS total_top_canceled_product
FROM annual_revenue AS ar
JOIN top_product_category AS tp
	ON ar.year = tp.year
JOIN annual_canceled_order AS aco
	ON tp.year = aco.year
JOIN canceled_category AS cc
	ON aco.year = cc.year
GROUP BY ar.year, ar.revenue, tp.product_category_name, tp.product_revenue, aco.canceled, cc.most_canceled, cc.total_canceled;