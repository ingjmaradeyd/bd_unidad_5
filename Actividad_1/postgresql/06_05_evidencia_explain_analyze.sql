-- ============================================================
-- ECOMMIFY - Evidencias de rendimiento con EXPLAIN ANALYZE
-- Ejecutar y tomar capturas del plan.
-- ============================================================

EXPLAIN ANALYZE
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS ordenes,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS valor_total
FROM ecommify.orders o
JOIN ecommify.customers c ON c.customer_id = o.customer_id
JOIN ecommify.order_items oi ON oi.order_id = o.order_id
WHERE o.order_purchase_timestamp >= DATE '2018-01-01'
GROUP BY c.customer_state
ORDER BY valor_total DESC;

EXPLAIN ANALYZE
SELECT
    p.product_category_name,
    COUNT(*) AS items_vendidos,
    ROUND(SUM(oi.price), 2) AS venta_total
FROM ecommify.order_items oi
JOIN ecommify.products p ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY venta_total DESC
LIMIT 10;

EXPLAIN ANALYZE
SELECT
    r.review_score,
    COUNT(*) AS total_reviews
FROM ecommify.order_reviews r
JOIN ecommify.orders o ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY r.review_score
ORDER BY r.review_score;