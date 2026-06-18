-- ================================================================
-- ECOMMIFY - Transformación desde staging al modelo E-R final
-- Base de datos: Ecommify
-- Propósito:
--   Convertir datos staging al modelo relacional final.
--   Corrige categorías sin traducción y productos con valores cero.
-- ================================================================

BEGIN;

-- ================================================================
-- 0. AJUSTE DE CONSTRAINTS COMPATIBLES CON DATASET REAL
-- ================================================================

ALTER TABLE ecommify.products DROP CONSTRAINT IF EXISTS ck_products_weight;
ALTER TABLE ecommify.products DROP CONSTRAINT IF EXISTS ck_products_length;
ALTER TABLE ecommify.products DROP CONSTRAINT IF EXISTS ck_products_height;
ALTER TABLE ecommify.products DROP CONSTRAINT IF EXISTS ck_products_width;
ALTER TABLE ecommify.products DROP CONSTRAINT IF EXISTS ck_products_name_length;
ALTER TABLE ecommify.products DROP CONSTRAINT IF EXISTS ck_products_description_length;
ALTER TABLE ecommify.products DROP CONSTRAINT IF EXISTS ck_products_photos_qty;

ALTER TABLE ecommify.products
ADD CONSTRAINT ck_products_weight CHECK (product_weight_g IS NULL OR product_weight_g >= 0);

ALTER TABLE ecommify.products
ADD CONSTRAINT ck_products_length CHECK (product_length_cm IS NULL OR product_length_cm >= 0);

ALTER TABLE ecommify.products
ADD CONSTRAINT ck_products_height CHECK (product_height_cm IS NULL OR product_height_cm >= 0);

ALTER TABLE ecommify.products
ADD CONSTRAINT ck_products_width CHECK (product_width_cm IS NULL OR product_width_cm >= 0);

ALTER TABLE ecommify.products
ADD CONSTRAINT ck_products_name_length CHECK (product_name_length IS NULL OR product_name_length >= 0);

ALTER TABLE ecommify.products
ADD CONSTRAINT ck_products_description_length CHECK (product_description_length IS NULL OR product_description_length >= 0);

ALTER TABLE ecommify.products
ADD CONSTRAINT ck_products_photos_qty CHECK (product_photos_qty IS NULL OR product_photos_qty >= 0);

-- ================================================================
-- 1. LIMPIEZA PARA REEJECUCIÓN
-- ================================================================

TRUNCATE TABLE ecommify.order_reviews RESTART IDENTITY CASCADE;
TRUNCATE TABLE ecommify.order_payments RESTART IDENTITY CASCADE;
TRUNCATE TABLE ecommify.order_items RESTART IDENTITY CASCADE;
TRUNCATE TABLE ecommify.orders RESTART IDENTITY CASCADE;
TRUNCATE TABLE ecommify.products RESTART IDENTITY CASCADE;
TRUNCATE TABLE ecommify.geolocations RESTART IDENTITY CASCADE;
TRUNCATE TABLE ecommify.sellers RESTART IDENTITY CASCADE;
TRUNCATE TABLE ecommify.customers RESTART IDENTITY CASCADE;
TRUNCATE TABLE ecommify.product_categories RESTART IDENTITY CASCADE;

-- ================================================================
-- 2. CATEGORÍAS CON TRADUCCIÓN
-- ================================================================

INSERT INTO ecommify.product_categories (
    product_category_name,
    product_category_name_english
)
SELECT DISTINCT
    NULLIF(BTRIM(REPLACE(product_category_name, CHR(65279), '')), ''),
    COALESCE(
        NULLIF(BTRIM(product_category_name_english), ''),
        NULLIF(BTRIM(REPLACE(product_category_name, CHR(65279), '')), '')
    )
FROM ecommify_stg.product_category_translation_raw
WHERE NULLIF(BTRIM(REPLACE(product_category_name, CHR(65279), '')), '') IS NOT NULL
ON CONFLICT (product_category_name) DO UPDATE
SET product_category_name_english = EXCLUDED.product_category_name_english;

-- Categorías que aparecen en productos, pero no existen en traducciones.
-- Se usa el mismo nombre técnico como fallback para evitar violar NOT NULL.
INSERT INTO ecommify.product_categories (
    product_category_name,
    product_category_name_english
)
SELECT DISTINCT
    NULLIF(BTRIM(p.product_category_name), ''),
    NULLIF(BTRIM(p.product_category_name), '')
FROM ecommify_stg.products_raw p
WHERE NULLIF(BTRIM(p.product_category_name), '') IS NOT NULL
ON CONFLICT (product_category_name) DO NOTHING;

-- ================================================================
-- 3. CLIENTES
-- ================================================================

INSERT INTO ecommify.customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT DISTINCT ON (customer_id)
    BTRIM(customer_id),
    BTRIM(customer_unique_id),
    NULLIF(BTRIM(customer_zip_code_prefix), '')::INTEGER,
    LOWER(BTRIM(customer_city)),
    UPPER(BTRIM(customer_state))
FROM ecommify_stg.customers_raw
WHERE NULLIF(BTRIM(customer_id), '') IS NOT NULL
ORDER BY customer_id;

-- ================================================================
-- 4. VENDEDORES
-- ================================================================

INSERT INTO ecommify.sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
SELECT DISTINCT ON (seller_id)
    BTRIM(seller_id),
    NULLIF(BTRIM(seller_zip_code_prefix), '')::INTEGER,
    LOWER(BTRIM(seller_city)),
    UPPER(BTRIM(seller_state))
FROM ecommify_stg.sellers_raw
WHERE NULLIF(BTRIM(seller_id), '') IS NOT NULL
ORDER BY seller_id;

-- ================================================================
-- 5. GEOLOCALIZACIÓN
-- ================================================================

INSERT INTO ecommify.geolocations (
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
)
SELECT DISTINCT
    NULLIF(BTRIM(geolocation_zip_code_prefix), '')::INTEGER,
    NULLIF(BTRIM(geolocation_lat), '')::NUMERIC(10,7),
    NULLIF(BTRIM(geolocation_lng), '')::NUMERIC(10,7),
    LOWER(BTRIM(geolocation_city)),
    UPPER(BTRIM(geolocation_state))
FROM ecommify_stg.geolocation_raw
WHERE NULLIF(BTRIM(geolocation_zip_code_prefix), '') IS NOT NULL
  AND NULLIF(BTRIM(geolocation_lat), '') IS NOT NULL
  AND NULLIF(BTRIM(geolocation_lng), '') IS NOT NULL;

-- ================================================================
-- 6. PRODUCTOS
-- ================================================================

INSERT INTO ecommify.products (
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT DISTINCT ON (p.product_id)
    BTRIM(p.product_id),
    NULLIF(BTRIM(p.product_category_name), ''),
    NULLIF(BTRIM(p.product_name_lenght), '')::INTEGER,
    NULLIF(BTRIM(p.product_description_lenght), '')::INTEGER,
    NULLIF(BTRIM(p.product_photos_qty), '')::INTEGER,
    NULLIF(BTRIM(p.product_weight_g), '')::INTEGER,
    NULLIF(BTRIM(p.product_length_cm), '')::INTEGER,
    NULLIF(BTRIM(p.product_height_cm), '')::INTEGER,
    NULLIF(BTRIM(p.product_width_cm), '')::INTEGER
FROM ecommify_stg.products_raw p
WHERE NULLIF(BTRIM(p.product_id), '') IS NOT NULL
ORDER BY p.product_id;

-- ================================================================
-- 7. ÓRDENES
-- ================================================================

INSERT INTO ecommify.orders (
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
)
SELECT DISTINCT ON (o.order_id)
    BTRIM(o.order_id),
    BTRIM(o.customer_id),
    BTRIM(o.order_status),
    NULLIF(BTRIM(o.order_purchase_timestamp), '')::TIMESTAMP,
    NULLIF(BTRIM(o.order_approved_at), '')::TIMESTAMP,
    NULLIF(BTRIM(o.order_delivered_carrier_date), '')::TIMESTAMP,
    NULLIF(BTRIM(o.order_delivered_customer_date), '')::TIMESTAMP,
    NULLIF(BTRIM(o.order_estimated_delivery_date), '')::TIMESTAMP
FROM ecommify_stg.orders_raw o
WHERE NULLIF(BTRIM(o.order_id), '') IS NOT NULL
  AND EXISTS (
      SELECT 1
      FROM ecommify.customers c
      WHERE c.customer_id = BTRIM(o.customer_id)
  )
ORDER BY o.order_id;

-- ================================================================
-- 8. ÍTEMS DE ÓRDENES
-- ================================================================

INSERT INTO ecommify.order_items (
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
)
SELECT DISTINCT ON (
    BTRIM(oi.order_id),
    NULLIF(BTRIM(oi.order_item_id), '')::INTEGER
)
    BTRIM(oi.order_id),
    NULLIF(BTRIM(oi.order_item_id), '')::INTEGER,
    BTRIM(oi.product_id),
    BTRIM(oi.seller_id),
    NULLIF(BTRIM(oi.shipping_limit_date), '')::TIMESTAMP,
    NULLIF(BTRIM(oi.price), '')::NUMERIC(12,2),
    NULLIF(BTRIM(oi.freight_value), '')::NUMERIC(12,2)
FROM ecommify_stg.order_items_raw oi
WHERE NULLIF(BTRIM(oi.order_id), '') IS NOT NULL
  AND NULLIF(BTRIM(oi.order_item_id), '') IS NOT NULL
  AND EXISTS (SELECT 1 FROM ecommify.orders o WHERE o.order_id = BTRIM(oi.order_id))
  AND EXISTS (SELECT 1 FROM ecommify.products p WHERE p.product_id = BTRIM(oi.product_id))
  AND EXISTS (SELECT 1 FROM ecommify.sellers s WHERE s.seller_id = BTRIM(oi.seller_id))
ORDER BY
    BTRIM(oi.order_id),
    NULLIF(BTRIM(oi.order_item_id), '')::INTEGER;

-- ================================================================
-- 9. PAGOS
-- ================================================================

INSERT INTO ecommify.order_payments (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
SELECT DISTINCT ON (
    BTRIM(op.order_id),
    NULLIF(BTRIM(op.payment_sequential), '')::INTEGER
)
    BTRIM(op.order_id),
    NULLIF(BTRIM(op.payment_sequential), '')::INTEGER,
    BTRIM(op.payment_type),
    NULLIF(BTRIM(op.payment_installments), '')::INTEGER,
    NULLIF(BTRIM(op.payment_value), '')::NUMERIC(12,2)
FROM ecommify_stg.order_payments_raw op
WHERE NULLIF(BTRIM(op.order_id), '') IS NOT NULL
  AND NULLIF(BTRIM(op.payment_sequential), '') IS NOT NULL
  AND EXISTS (
      SELECT 1
      FROM ecommify.orders o
      WHERE o.order_id = BTRIM(op.order_id)
  )
ORDER BY
    BTRIM(op.order_id),
    NULLIF(BTRIM(op.payment_sequential), '')::INTEGER;

-- ================================================================
-- 10. RESEÑAS
-- ================================================================

INSERT INTO ecommify.order_reviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
)
SELECT DISTINCT ON (BTRIM(orv.review_id))
    BTRIM(orv.review_id),
    BTRIM(orv.order_id),
    NULLIF(BTRIM(orv.review_score), '')::INTEGER,
    NULLIF(BTRIM(orv.review_comment_title), ''),
    NULLIF(BTRIM(orv.review_comment_message), ''),
    NULLIF(BTRIM(orv.review_creation_date), '')::TIMESTAMP,
    NULLIF(BTRIM(orv.review_answer_timestamp), '')::TIMESTAMP
FROM ecommify_stg.order_reviews_raw orv
WHERE NULLIF(BTRIM(orv.review_id), '') IS NOT NULL
  AND NULLIF(BTRIM(orv.order_id), '') IS NOT NULL
  AND EXISTS (
      SELECT 1
      FROM ecommify.orders o
      WHERE o.order_id = BTRIM(orv.order_id)
  )
ORDER BY
    BTRIM(orv.review_id),
    NULLIF(BTRIM(orv.review_answer_timestamp), '')::TIMESTAMP DESC NULLS LAST;

-- ================================================================
-- 11. VALIDACIÓN FINAL
-- ================================================================

DO $$
DECLARE
    v_categories BIGINT;
    v_customers BIGINT;
    v_sellers BIGINT;
    v_geolocations BIGINT;
    v_products BIGINT;
    v_orders BIGINT;
    v_items BIGINT;
    v_payments BIGINT;
    v_reviews BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_categories FROM ecommify.product_categories;
    SELECT COUNT(*) INTO v_customers FROM ecommify.customers;
    SELECT COUNT(*) INTO v_sellers FROM ecommify.sellers;
    SELECT COUNT(*) INTO v_geolocations FROM ecommify.geolocations;
    SELECT COUNT(*) INTO v_products FROM ecommify.products;
    SELECT COUNT(*) INTO v_orders FROM ecommify.orders;
    SELECT COUNT(*) INTO v_items FROM ecommify.order_items;
    SELECT COUNT(*) INTO v_payments FROM ecommify.order_payments;
    SELECT COUNT(*) INTO v_reviews FROM ecommify.order_reviews;

    RAISE NOTICE 'Carga final Ecommify completada.';
    RAISE NOTICE 'product_categories: %', v_categories;
    RAISE NOTICE 'customers: %', v_customers;
    RAISE NOTICE 'sellers: %', v_sellers;
    RAISE NOTICE 'geolocations: %', v_geolocations;
    RAISE NOTICE 'products: %', v_products;
    RAISE NOTICE 'orders: %', v_orders;
    RAISE NOTICE 'order_items: %', v_items;
    RAISE NOTICE 'order_payments: %', v_payments;
    RAISE NOTICE 'order_reviews: %', v_reviews;
END $$;

COMMIT;