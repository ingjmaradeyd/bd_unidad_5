-- ============================================================
-- ECOMMIFY - Validación de integridad referencial
-- Debe devolver cero en todos los casos.
-- ============================================================

SELECT 'orders_sin_customer' AS validacion, COUNT(*) AS registros_invalidos
FROM ecommify.orders o
LEFT JOIN ecommify.customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 'order_items_sin_order', COUNT(*)
FROM ecommify.order_items oi
LEFT JOIN ecommify.orders o ON o.order_id = oi.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'order_items_sin_product', COUNT(*)
FROM ecommify.order_items oi
LEFT JOIN ecommify.products p ON p.product_id = oi.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT 'order_items_sin_seller', COUNT(*)
FROM ecommify.order_items oi
LEFT JOIN ecommify.sellers s ON s.seller_id = oi.seller_id
WHERE s.seller_id IS NULL

UNION ALL

SELECT 'payments_sin_order', COUNT(*)
FROM ecommify.order_payments op
LEFT JOIN ecommify.orders o ON o.order_id = op.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'reviews_sin_order', COUNT(*)
FROM ecommify.order_reviews r
LEFT JOIN ecommify.orders o ON o.order_id = r.order_id
WHERE o.order_id IS NULL;