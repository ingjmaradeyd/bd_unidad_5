-- ================================================================
-- ECOMMIFY - Tablas staging para carga inicial
-- Base de datos: Ecommify
-- Propósito: Recibir los archivos fuente sin restricciones fuertes,
-- permitiendo limpiar, convertir tipos y poblar el modelo E-R final.
-- ================================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS ecommify_stg;

DROP TABLE IF EXISTS ecommify_stg.customers_raw;
DROP TABLE IF EXISTS ecommify_stg.geolocation_raw;
DROP TABLE IF EXISTS ecommify_stg.order_items_raw;
DROP TABLE IF EXISTS ecommify_stg.order_payments_raw;
DROP TABLE IF EXISTS ecommify_stg.order_reviews_raw;
DROP TABLE IF EXISTS ecommify_stg.orders_raw;
DROP TABLE IF EXISTS ecommify_stg.products_raw;
DROP TABLE IF EXISTS ecommify_stg.sellers_raw;
DROP TABLE IF EXISTS ecommify_stg.product_category_translation_raw;

CREATE TABLE ecommify_stg.customers_raw (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix TEXT,
    customer_city TEXT,
    customer_state TEXT
);

CREATE TABLE ecommify_stg.geolocation_raw (
    geolocation_zip_code_prefix TEXT,
    geolocation_lat TEXT,
    geolocation_lng TEXT,
    geolocation_city TEXT,
    geolocation_state TEXT
);

CREATE TABLE ecommify_stg.order_items_raw (
    order_id TEXT,
    order_item_id TEXT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TEXT,
    price TEXT,
    freight_value TEXT
);

CREATE TABLE ecommify_stg.order_payments_raw (
    order_id TEXT,
    payment_sequential TEXT,
    payment_type TEXT,
    payment_installments TEXT,
    payment_value TEXT
);

CREATE TABLE ecommify_stg.order_reviews_raw (
    review_id TEXT,
    order_id TEXT,
    review_score TEXT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TEXT,
    review_answer_timestamp TEXT
);

CREATE TABLE ecommify_stg.orders_raw (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TEXT,
    order_approved_at TEXT,
    order_delivered_carrier_date TEXT,
    order_delivered_customer_date TEXT,
    order_estimated_delivery_date TEXT
);

CREATE TABLE ecommify_stg.products_raw (
    product_id TEXT,
    product_category_name TEXT,
    product_name_lenght TEXT,
    product_description_lenght TEXT,
    product_photos_qty TEXT,
    product_weight_g TEXT,
    product_length_cm TEXT,
    product_height_cm TEXT,
    product_width_cm TEXT
);

CREATE TABLE ecommify_stg.sellers_raw (
    seller_id TEXT,
    seller_zip_code_prefix TEXT,
    seller_city TEXT,
    seller_state TEXT
);

CREATE TABLE ecommify_stg.product_category_translation_raw (
    product_category_name TEXT,
    product_category_name_english TEXT
);

COMMIT;
