-- ================================================================
-- ECOMMIFY - Consultas base para comprobar uso del modelo E-R
-- Base de datos: Ecommify
-- Propósito: Consultas críticas para análisis comercial y validación
-- con EXPLAIN ANALYZE.
-- ================================================================

-- 1. Ventas por categoría de producto.
EXPLAIN ANALYZE
SELECT
    COALESCE(pc.product_category_name_english, 'without_category') AS categoria,
    COUNT(DISTINCT o.order_id) AS ordenes,
    COUNT(*) AS unidades,
    ROUND(SUM(oi.price), 2) AS venta_producto,
    ROUND(SUM(oi.freight_value), 2) AS flete,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS venta_total
FROM ecommify.orders o
JOIN ecommify.order_items oi ON oi.order_id = o.order_id
JOIN ecommify.products p ON p.product_id = oi.product_id
LEFT JOIN ecommify.product_categories pc ON pc.product_category_name = p.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY COALESCE(pc.product_category_name_english, 'without_category')
ORDER BY venta_total DESC
LIMIT 20;

-- 2. Desempeño de vendedores por estado.
EXPLAIN ANALYZE
SELECT
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS vendedores,
    COUNT(DISTINCT oi.order_id) AS ordenes,
    ROUND(SUM(oi.price), 2) AS ingresos_producto,
    ROUND(AVG(oi.price), 2) AS ticket_promedio_item
FROM ecommify.order_items oi
JOIN ecommify.sellers s ON s.seller_id = oi.seller_id
JOIN ecommify.orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state
ORDER BY ingresos_producto DESC;

-- 3. Satisfacción del cliente por categoría.
EXPLAIN ANALYZE
SELECT
    COALESCE(pc.product_category_name_english, 'without_category') AS categoria,
    COUNT(*) AS total_resenas,
    ROUND(AVG(r.review_score), 2) AS score_promedio,
    SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) AS resenas_negativas,
    SUM(CASE WHEN r.review_score >= 4 THEN 1 ELSE 0 END) AS resenas_positivas
FROM ecommify.order_reviews r
JOIN ecommify.orders o ON o.order_id = r.order_id
JOIN ecommify.order_items oi ON oi.order_id = o.order_id
JOIN ecommify.products p ON p.product_id = oi.product_id
LEFT JOIN ecommify.product_categories pc ON pc.product_category_name = p.product_category_name
GROUP BY COALESCE(pc.product_category_name_english, 'without_category')
HAVING COUNT(*) >= 50
ORDER BY score_promedio ASC, total_resenas DESC
LIMIT 20;

-- 4. Cumplimiento de entrega frente a fecha estimada.
EXPLAIN ANALYZE
SELECT
    DATE_TRUNC('month', order_purchase_timestamp)::DATE AS mes_compra,
    COUNT(*) AS ordenes_entregadas,
    ROUND(AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp)) / 86400), 2) AS dias_promedio_entrega,
    ROUND(AVG(CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1 ELSE 0 END) * 100, 2) AS porcentaje_a_tiempo
FROM ecommify.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)::DATE
ORDER BY mes_compra;
