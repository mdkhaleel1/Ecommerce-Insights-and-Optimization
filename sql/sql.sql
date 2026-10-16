CREATE DATABASE ecommerce_project;
USE ecommerce_project;
SHOW DATABASES;

-- Inspection

SELECT COUNT(*)
FROM order_items;
SELECT COUNT(*)
FROM products_clean;

SELECT * FROM order_items
LIMIT 10;
SELECT * FROM products_clean
LIMIT 10;

DESCRIBE order_items;
DESCRIBE products_clean;

-- Filtering and Sorting

SELECT * FROM order_items
ORDER BY price DESC
LIMIT 10;

SELECT * FROM order_items
WHERE freight_value > 50
ORDER BY freight_value DESC;

-- Revenue by category

SELECT
    COALESCE(
        p.category_from_product,
        oi.category_from_order
    ) AS product_category,
    SUM(oi.price) AS total_sales_value,
    COUNT(*) AS item_records
FROM order_items AS oi
LEFT JOIN products_clean AS p
    ON oi.product_id = p.product_id
GROUP BY product_category
ORDER BY total_sales_value DESC;

-- Top 20 Products by Sales Value

SELECT
    oi.product_id,
    COALESCE(
        p.category_from_product,
        oi.category_from_order
    ) AS product_category,
    SUM(oi.price) AS total_sales_value,
    COUNT(*) AS item_records
FROM order_items AS oi
LEFT JOIN products_clean AS p
    ON oi.product_id = p.product_id
GROUP BY
    oi.product_id,
    COALESCE(
        p.category_from_product,
        oi.category_from_order
    )
ORDER BY total_sales_value DESC
LIMIT 20;

-- Average Selling Price by Category

SELECT
    COALESCE(
        p.category_from_product,
        oi.category_from_order
    ) AS product_category,
    COUNT(*) AS item_records,
    ROUND(AVG(oi.price), 2) AS avg_recorded_price
FROM order_items AS oi
LEFT JOIN products_clean AS p
    ON oi.product_id = p.product_id
GROUP BY product_category
ORDER BY avg_recorded_price DESC;

-- Shipping Costs by Category

SELECT
    COALESCE(
        p.category_from_product,
        oi.category_from_order
    ) AS product_category,
    COUNT(*) AS item_records,
    ROUND(SUM(oi.freight_value), 2) AS total_shipping_cost,
    ROUND(AVG(oi.freight_value), 2) AS avg_shipping_cost
FROM order_items AS oi
LEFT JOIN products_clean AS p
    ON oi.product_id = p.product_id
GROUP BY product_category
ORDER BY total_shipping_cost DESC;

-- Shipping-to-Sales Ratio

SELECT
    COALESCE(
        p.category_from_product,
        oi.category_from_order
    ) AS product_category,
    ROUND(SUM(oi.price), 2) AS total_recorded_price,
    ROUND(SUM(oi.freight_value), 2) AS total_freight_value,
    ROUND(
        100.0 * SUM(oi.freight_value)
        / NULLIF(SUM(oi.price), 0),
        2
    ) AS shipping_to_sales_pct
FROM order_items AS oi
LEFT JOIN products_clean AS p
    ON oi.product_id = p.product_id
GROUP BY
    COALESCE(
        p.category_from_product,
        oi.category_from_order
    )
ORDER BY shipping_to_sales_pct DESC;

-- Top 10 Products by Shipping-to-Sales Ratio

SELECT
    oi.product_id,
    COALESCE(
        p.category_from_product,
        oi.category_from_order
    ) AS product_category,
    COUNT(*) AS item_records,
    ROUND(SUM(oi.price), 2) AS total_recorded_price,
    ROUND(SUM(oi.freight_value), 2) AS total_freight_value,
    ROUND(
        100.0 * SUM(oi.freight_value)
        / NULLIF(SUM(oi.price), 0),
        2
    ) AS shipping_to_sales_pct
FROM order_items AS oi
LEFT JOIN products_clean AS p
    ON oi.product_id = p.product_id
GROUP BY
    oi.product_id,
    COALESCE(
        p.category_from_product,
        oi.category_from_order
    )
HAVING SUM(oi.price) > 0
ORDER BY shipping_to_sales_pct DESC
LIMIT 10;

-- Product Weight vs. Shipping Cost

SELECT
    CASE
        WHEN product_weight_g IS NULL THEN 'Unknown weight'
        WHEN product_weight_g < 500 THEN 'Under 500 g'
        WHEN product_weight_g < 2000 THEN '500 g - 2 kg'
        WHEN product_weight_g < 5000 THEN '2 - 5 kg'
        WHEN product_weight_g < 10000 THEN '5 - 10 kg'
        ELSE '10 kg and above'
    END AS weight_band,
    COUNT(*) AS item_records,
    ROUND(AVG(product_weight_g), 2) AS avg_weight_g,
    ROUND(AVG(freight_value), 2) AS avg_freight_value,
    ROUND(SUM(freight_value), 2) AS total_freight_value
FROM (
    SELECT
        oi.freight_value,
        COALESCE(
            p.weight_from_product_g,
            oi.weight_from_order_g
        ) AS product_weight_g
    FROM order_items AS oi
    LEFT JOIN products_clean AS p
        ON oi.product_id = p.product_id
) AS shipping_data
GROUP BY weight_band
ORDER BY
    CASE weight_band
        WHEN 'Under 500 g' THEN 1
        WHEN '500 g - 2 kg' THEN 2
        WHEN '2 - 5 kg' THEN 3
        WHEN '5 - 10 kg' THEN 4
        WHEN '10 kg and above' THEN 5
        ELSE 6
    END;
    
    --
    
DESCRIBE order_items;
    
SELECT
    MIN(shipping_limit_date) AS earliest_shipping_deadline,
    MAX(shipping_limit_date) AS latest_shipping_deadline,
    COUNT(*) AS total_records
FROM order_items;

-- Product Price vs. Shipping Cost

SELECT
    CASE
        WHEN price < 50 THEN 'Under 50'
        WHEN price < 100 THEN '50 - 99.99'
        WHEN price < 250 THEN '100 - 249.99'
        WHEN price < 500 THEN '250 - 499.99'
        ELSE '500 and above'
    END AS price_band,
    COUNT(*) AS item_records,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(freight_value), 2) AS avg_freight_value,
    ROUND(
        100.0 * AVG(freight_value)
        / NULLIF(AVG(price), 0),
        2
    ) AS avg_freight_to_price_pct
FROM order_items
GROUP BY price_band
ORDER BY
    CASE price_band
        WHEN 'Under 50' THEN 1
        WHEN '50 - 99.99' THEN 2
        WHEN '100 - 249.99' THEN 3
        WHEN '250 - 499.99' THEN 4
        ELSE 5
    END;
    
    -- Category Performance Scorecard
    
    WITH item_data AS (
    SELECT
        COALESCE(
            p.category_from_product,
            oi.category_from_order,
            'Unknown'
        ) AS product_category,
        oi.order_id,
        oi.price,
        oi.freight_value
    FROM order_items AS oi
    LEFT JOIN products_clean AS p
        ON oi.product_id = p.product_id
),
category_metrics AS (
    SELECT
        product_category,
        COUNT(*) AS item_records,
        COUNT(DISTINCT order_id) AS distinct_order_ids,
        SUM(price) AS total_recorded_price,
        AVG(price) AS avg_recorded_price,
        SUM(freight_value) AS total_freight_value,
        AVG(freight_value) AS avg_freight_value,
        100.0 * SUM(freight_value)
            / NULLIF(SUM(price), 0) AS shipping_to_sales_pct
    FROM item_data
    GROUP BY product_category
)
SELECT
    product_category,
    item_records,
    distinct_order_ids,
    ROUND(total_recorded_price, 2) AS total_recorded_price,
    ROUND(avg_recorded_price, 2) AS avg_recorded_price,
    ROUND(total_freight_value, 2) AS total_freight_value,
    ROUND(avg_freight_value, 2) AS avg_freight_value,
    ROUND(shipping_to_sales_pct, 2) AS shipping_to_sales_pct,
    RANK() OVER (
        ORDER BY total_recorded_price DESC
    ) AS sales_value_rank
FROM category_metrics
ORDER BY sales_value_rank;

-- Product Performance View

CREATE OR REPLACE VIEW product_performance AS
SELECT
    oi.product_id,
    COALESCE(
        p.category_from_product,
        oi.category_from_order,
        'Unknown'
    ) AS product_category,
    COUNT(*) AS item_records,
    ROUND(SUM(oi.price), 2) AS total_recorded_price,
    ROUND(AVG(oi.price), 2) AS avg_recorded_price,
    ROUND(SUM(oi.freight_value), 2) AS total_freight_value,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight_value,
    ROUND(
        100.0 * SUM(oi.freight_value)
        / NULLIF(SUM(oi.price), 0),
        2
    ) AS shipping_to_sales_pct
FROM order_items AS oi
LEFT JOIN products_clean AS p
    ON oi.product_id = p.product_id
GROUP BY
    oi.product_id,
    COALESCE(
        p.category_from_product,
        oi.category_from_order,
        'Unknown'
    );
    
SELECT *
FROM product_performance
ORDER BY total_recorded_price DESC
LIMIT 20;

SELECT *
FROM product_performance
ORDER BY shipping_to_sales_pct DESC
LIMIT 10;

-- Each Product's Contribution to Total Sales Value

WITH product_shares AS (
    SELECT
        product_id,
        product_category,
        total_recorded_price,

        100.0 * total_recorded_price
        / NULLIF(SUM(total_recorded_price) OVER (), 0)
            AS contribution_pct

    FROM product_performance
    WHERE total_recorded_price > 0
),
ranked_products AS (
    SELECT
        product_id,
        product_category,
        total_recorded_price,
        contribution_pct,

        SUM(contribution_pct) OVER (
            ORDER BY total_recorded_price DESC, product_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_contribution_pct

    FROM product_shares
)
SELECT
    product_id,
    product_category,
    ROUND(total_recorded_price, 2) AS total_recorded_price,
    ROUND(contribution_pct, 3) AS contribution_pct,
    ROUND(cumulative_contribution_pct, 3)
        AS cumulative_contribution_pct
FROM ranked_products
ORDER BY total_recorded_price DESC
LIMIT 20;

-- Limitation: there is no actual order_date or quantity column in the supplied files.