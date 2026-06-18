-- ============================================================
-- ECOMMIFY - Evidencia de modelo cargado
-- ============================================================

SELECT 
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema IN ('ecommify', 'ecommify_stg')
ORDER BY table_schema, table_name;

SELECT 'product_categories' AS tabla, COUNT(*) AS registros FROM ecommify.product_categories
UNION ALL SELECT 'customers', COUNT(*) FROM ecommify.customers
UNION ALL SELECT 'sellers', COUNT(*) FROM ecommify.sellers
UNION ALL SELECT 'geolocations', COUNT(*) FROM ecommify.geolocations
UNION ALL SELECT 'products', COUNT(*) FROM ecommify.products
UNION ALL SELECT 'orders', COUNT(*) FROM ecommify.orders
UNION ALL SELECT 'order_items', COUNT(*) FROM ecommify.order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM ecommify.order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM ecommify.order_reviews
ORDER BY tabla;