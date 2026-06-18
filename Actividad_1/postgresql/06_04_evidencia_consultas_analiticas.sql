-- ============================================================
-- ECOMMIFY - Consultas analíticas para evidencia funcional
-- ============================================================

-- 1. Ventas por categoría
SELECT
    pc.product_category_name_english AS categoria,
    COUNT(DISTINCT oi.order_id) AS ordenes,
    COUNT(*) AS items_vendidos,
    ROUND(SUM(oi.price), 2) AS venta_total,
    ROUND(AVG(oi.price), 2) AS ticket_promedio
FROM ecommify.order_items oi
JOIN ecommify.products p ON p.product_id = oi.product_id
LEFT JOIN ecommify.product_categories pc 
    ON pc.product_category_name = p.product_category_name
GROUP BY pc.product_category_name_english
ORDER BY venta_total DESC
LIMIT 20;

-- 2. Ventas por estado del cliente
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS ordenes,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS valor_total
FROM ecommify.orders o
JOIN ecommify.customers c ON c.customer_id = o.customer_id
JOIN ecommify.order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_state
ORDER BY valor_total DESC;

-- 3. Calificación promedio por categoría
SELECT
    pc.product_category_name_english AS categoria,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.review_score), 2) AS promedio_review
FROM ecommify.order_reviews r
JOIN ecommify.orders o ON o.order_id = r.order_id
JOIN ecommify.order_items oi ON oi.order_id = o.order_id
JOIN ecommify.products p ON p.product_id = oi.product_id
LEFT JOIN ecommify.product_categories pc 
    ON pc.product_category_name = p.product_category_name
GROUP BY pc.product_category_name_english
HAVING COUNT(r.review_id) >= 10
ORDER BY promedio_review DESC, total_reviews DESC
LIMIT 20;