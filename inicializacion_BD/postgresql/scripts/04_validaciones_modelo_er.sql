-- ================================================================
-- ECOMMIFY - Validaciones técnicas del modelo E-R
-- Base de datos: Ecommify
-- Propósito: Confirmar volumen, llaves primarias, llaves foráneas y
-- calidad básica de datos después de la carga.
-- ================================================================

-- Conteo por entidad.
SELECT 'customers' AS entidad, COUNT(*) AS registros FROM ecommify.customers
UNION ALL SELECT 'sellers', COUNT(*) FROM ecommify.sellers
UNION ALL SELECT 'product_categories', COUNT(*) FROM ecommify.product_categories
UNION ALL SELECT 'products', COUNT(*) FROM ecommify.products
UNION ALL SELECT 'geolocations', COUNT(*) FROM ecommify.geolocations
UNION ALL SELECT 'orders', COUNT(*) FROM ecommify.orders
UNION ALL SELECT 'order_items', COUNT(*) FROM ecommify.order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM ecommify.order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM ecommify.order_reviews
ORDER BY entidad;

-- Validación de órdenes sin cliente. Debe devolver 0 registros.
SELECT COUNT(*) AS ordenes_sin_cliente
FROM ecommify.orders o
LEFT JOIN ecommify.customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

-- Validación de ítems sin producto o vendedor. Debe devolver 0 registros.
SELECT COUNT(*) AS items_con_referencias_invalidas
FROM ecommify.order_items oi
LEFT JOIN ecommify.products p ON p.product_id = oi.product_id
LEFT JOIN ecommify.sellers s ON s.seller_id = oi.seller_id
WHERE p.product_id IS NULL OR s.seller_id IS NULL;

-- Validación de pagos sin orden. Debe devolver 0 registros.
SELECT COUNT(*) AS pagos_sin_orden
FROM ecommify.order_payments op
LEFT JOIN ecommify.orders o ON o.order_id = op.order_id
WHERE o.order_id IS NULL;

-- Validación de reseñas sin orden. Debe devolver 0 registros.
SELECT COUNT(*) AS resenas_sin_orden
FROM ecommify.order_reviews r
LEFT JOIN ecommify.orders o ON o.order_id = r.order_id
WHERE o.order_id IS NULL;

-- Validación de cardinalidad principal del modelo.
SELECT
    o.order_id,
    COUNT(DISTINCT oi.order_item_id) AS total_items,
    COUNT(DISTINCT op.payment_sequential) AS total_pagos,
    COUNT(DISTINCT r.review_id) AS total_resenas
FROM ecommify.orders o
LEFT JOIN ecommify.order_items oi ON oi.order_id = o.order_id
LEFT JOIN ecommify.order_payments op ON op.order_id = o.order_id
LEFT JOIN ecommify.order_reviews r ON r.order_id = o.order_id
GROUP BY o.order_id
ORDER BY total_items DESC, total_pagos DESC
LIMIT 20;
