SELECT 'product_category_translation_raw' AS tabla, COUNT(*) AS registros FROM ecommify_stg.product_category_translation_raw UNION ALL
SELECT 'customers_raw', COUNT(*) FROM ecommify_stg.customers_raw UNION ALL
SELECT 'sellers_raw', COUNT(*) FROM ecommify_stg.sellers_raw UNION ALL
SELECT 'products_raw', COUNT(*) FROM ecommify_stg.products_raw UNION ALL
SELECT 'orders_raw', COUNT(*) FROM ecommify_stg.orders_raw UNION ALL
SELECT 'order_items_raw', COUNT(*) FROM ecommify_stg.order_items_raw UNION ALL
SELECT 'order_payments_raw', COUNT(*) FROM ecommify_stg.order_payments_raw UNION ALL
SELECT 'order_reviews_raw', COUNT(*) FROM ecommify_stg.order_reviews_raw UNION ALL
SELECT 'geolocation_raw', COUNT(*) FROM ecommify_stg.geolocation_raw
ORDER BY tabla;
