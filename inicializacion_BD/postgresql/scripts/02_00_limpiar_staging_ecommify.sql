-- ================================================================
-- ECOMMIFY - Limpieza de staging antes de cargar desde CSV
-- Base de datos: Ecommify
-- ================================================================

TRUNCATE TABLE
    ecommify_stg.product_category_translation_raw,
    ecommify_stg.customers_raw,
    ecommify_stg.sellers_raw,
    ecommify_stg.products_raw,
    ecommify_stg.orders_raw,
    ecommify_stg.order_items_raw,
    ecommify_stg.order_payments_raw,
    ecommify_stg.order_reviews_raw,
    ecommify_stg.geolocation_raw;
