-- ================================================================
-- ECOMMIFY - Modelo Entidad Relación en PostgreSQL
-- Base de datos: Ecommify
-- Propósito: Crear el modelo relacional normalizado a partir del
-- modelo operacional de comercio electrónico de Ecommify.
-- Motor objetivo: PostgreSQL / Supabase
-- ================================================================

-- Recomendado ejecutar conectado a la base de datos Ecommify.
-- CREATE DATABASE ecommify; -- Ejecutar solo si se administra PostgreSQL local.

BEGIN;

CREATE SCHEMA IF NOT EXISTS ecommify;
CREATE SCHEMA IF NOT EXISTS ecommify_stg;

-- Extensiones útiles para búsquedas, georreferenciación e identificadores.
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Limpieza ordenada para re-ejecución controlada en ambientes académicos.
DROP TABLE IF EXISTS ecommify.order_reviews CASCADE;
DROP TABLE IF EXISTS ecommify.order_payments CASCADE;
DROP TABLE IF EXISTS ecommify.order_items CASCADE;
DROP TABLE IF EXISTS ecommify.orders CASCADE;
DROP TABLE IF EXISTS ecommify.products CASCADE;
DROP TABLE IF EXISTS ecommify.product_categories CASCADE;
DROP TABLE IF EXISTS ecommify.sellers CASCADE;
DROP TABLE IF EXISTS ecommify.customers CASCADE;
DROP TABLE IF EXISTS ecommify.geolocations CASCADE;

-- ================================================================
-- 1. Entidades maestras
-- ================================================================

CREATE TABLE ecommify.customers (
    customer_id              VARCHAR(32) PRIMARY KEY,
    customer_unique_id       VARCHAR(32) NOT NULL,
    customer_zip_code_prefix INTEGER NOT NULL,
    customer_city            VARCHAR(120) NOT NULL,
    customer_state           CHAR(2) NOT NULL,
    CONSTRAINT ck_customers_state_len CHECK (customer_state ~ '^[A-Z]{2}$'),
    CONSTRAINT ck_customers_zip_positive CHECK (customer_zip_code_prefix > 0)
);

COMMENT ON TABLE ecommify.customers IS 'Clientes de Ecommify. customer_id identifica la compra; customer_unique_id agrupa clientes recurrentes.';
COMMENT ON COLUMN ecommify.customers.customer_unique_id IS 'Identificador lógico de cliente recurrente. No es PK porque un mismo cliente puede tener varias compras.';

CREATE TABLE ecommify.sellers (
    seller_id              VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix INTEGER NOT NULL,
    seller_city            VARCHAR(120) NOT NULL,
    seller_state           CHAR(2) NOT NULL,
    CONSTRAINT ck_sellers_state_len CHECK (seller_state ~ '^[A-Z]{2}$'),
    CONSTRAINT ck_sellers_zip_positive CHECK (seller_zip_code_prefix > 0)
);

COMMENT ON TABLE ecommify.sellers IS 'Vendedores o comercios aliados que ofertan productos en Ecommify.';

CREATE TABLE ecommify.product_categories (
    product_category_name         VARCHAR(120) PRIMARY KEY,
    product_category_name_english VARCHAR(120) NOT NULL UNIQUE
);

COMMENT ON TABLE ecommify.product_categories IS 'Catálogo de categorías de producto. Mantiene el nombre original y su equivalencia en inglés.';

CREATE TABLE ecommify.products (
    product_id                    VARCHAR(32) PRIMARY KEY,
    product_category_name         VARCHAR(120),
    product_name_length           INTEGER,
    product_description_length    INTEGER,
    product_photos_qty            INTEGER,
    product_weight_g              INTEGER,
    product_length_cm             INTEGER,
    product_height_cm             INTEGER,
    product_width_cm              INTEGER,
    CONSTRAINT fk_products_category
        FOREIGN KEY (product_category_name)
        REFERENCES ecommify.product_categories(product_category_name)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT ck_products_name_length CHECK (product_name_length IS NULL OR product_name_length >= 0),
    CONSTRAINT ck_products_description_length CHECK (product_description_length IS NULL OR product_description_length >= 0),
    CONSTRAINT ck_products_photos CHECK (product_photos_qty IS NULL OR product_photos_qty >= 0),
    CONSTRAINT ck_products_weight CHECK (product_weight_g IS NULL OR product_weight_g > 0),
    CONSTRAINT ck_products_dimensions CHECK (
        (product_length_cm IS NULL OR product_length_cm > 0) AND
        (product_height_cm IS NULL OR product_height_cm > 0) AND
        (product_width_cm IS NULL OR product_width_cm > 0)
    )
);

COMMENT ON TABLE ecommify.products IS 'Catálogo de productos de Ecommify con atributos físicos y descriptivos.';

CREATE TABLE ecommify.geolocations (
    geolocation_id              BIGSERIAL PRIMARY KEY,
    geolocation_zip_code_prefix INTEGER NOT NULL,
    geolocation_lat             NUMERIC(10,7) NOT NULL,
    geolocation_lng             NUMERIC(10,7) NOT NULL,
    geolocation_city            VARCHAR(120) NOT NULL,
    geolocation_state           CHAR(2) NOT NULL,
    CONSTRAINT ck_geolocation_state_len CHECK (geolocation_state ~ '^[A-Z]{2}$'),
    CONSTRAINT ck_geolocation_zip_positive CHECK (geolocation_zip_code_prefix > 0),
    CONSTRAINT ck_geolocation_lat CHECK (geolocation_lat BETWEEN -90 AND 90),
    CONSTRAINT ck_geolocation_lng CHECK (geolocation_lng BETWEEN -180 AND 180)
);

COMMENT ON TABLE ecommify.geolocations IS 'Puntos geográficos por prefijo postal. No se usa el prefijo como PK porque existen múltiples coordenadas por prefijo.';

-- ================================================================
-- 2. Entidades transaccionales
-- ================================================================

CREATE TABLE ecommify.orders (
    order_id                         VARCHAR(32) PRIMARY KEY,
    customer_id                      VARCHAR(32) NOT NULL,
    order_status                     VARCHAR(20) NOT NULL,
    order_purchase_timestamp         TIMESTAMP NOT NULL,
    order_approved_at                TIMESTAMP,
    order_delivered_carrier_date     TIMESTAMP,
    order_delivered_customer_date    TIMESTAMP,
    order_estimated_delivery_date    TIMESTAMP NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES ecommify.customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT ck_orders_status CHECK (order_status IN (
        'created','approved','invoiced','processing','shipped','delivered','unavailable','canceled'
    )),
    CONSTRAINT ck_orders_approved_after_purchase CHECK (
        order_approved_at IS NULL OR order_approved_at >= order_purchase_timestamp
    )
);

COMMENT ON TABLE ecommify.orders IS 'Pedidos realizados por los clientes. Es la entidad central del modelo transaccional.';

CREATE TABLE ecommify.order_items (
    order_id            VARCHAR(32) NOT NULL,
    order_item_id       INTEGER NOT NULL,
    product_id          VARCHAR(32) NOT NULL,
    seller_id           VARCHAR(32) NOT NULL,
    shipping_limit_date TIMESTAMP NOT NULL,
    price               NUMERIC(12,2) NOT NULL,
    freight_value       NUMERIC(12,2) NOT NULL,
    PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES ecommify.orders(order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES ecommify.products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_items_seller
        FOREIGN KEY (seller_id)
        REFERENCES ecommify.sellers(seller_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT ck_order_items_item_positive CHECK (order_item_id > 0),
    CONSTRAINT ck_order_items_price_nonnegative CHECK (price >= 0),
    CONSTRAINT ck_order_items_freight_nonnegative CHECK (freight_value >= 0)
);

COMMENT ON TABLE ecommify.order_items IS 'Detalle de productos vendidos por pedido. Permite múltiples productos y múltiples vendedores por orden.';

CREATE TABLE ecommify.order_payments (
    order_id              VARCHAR(32) NOT NULL,
    payment_sequential    INTEGER NOT NULL,
    payment_type          VARCHAR(30) NOT NULL,
    payment_installments  INTEGER NOT NULL,
    payment_value         NUMERIC(12,2) NOT NULL,
    PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT fk_order_payments_order
        FOREIGN KEY (order_id)
        REFERENCES ecommify.orders(order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT ck_order_payments_type CHECK (payment_type IN (
        'credit_card','boleto','voucher','debit_card','not_defined'
    )),
    CONSTRAINT ck_order_payments_installments CHECK (payment_installments >= 0),
    CONSTRAINT ck_order_payments_value CHECK (payment_value >= 0)
);

COMMENT ON TABLE ecommify.order_payments IS 'Pagos asociados al pedido. Una orden puede tener uno o más pagos secuenciales.';

CREATE TABLE ecommify.order_reviews (
    review_id                VARCHAR(32) NOT NULL,
    order_id                 VARCHAR(32) NOT NULL,
    review_score             INTEGER NOT NULL,
    review_comment_title     TEXT,
    review_comment_message   TEXT,
    review_creation_date     TIMESTAMP NOT NULL,
    review_answer_timestamp  TIMESTAMP NOT NULL,
    PRIMARY KEY (review_id, order_id),
    CONSTRAINT fk_order_reviews_order
        FOREIGN KEY (order_id)
        REFERENCES ecommify.orders(order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT ck_order_reviews_score CHECK (review_score BETWEEN 1 AND 5),
    CONSTRAINT ck_order_reviews_answer_after_creation CHECK (review_answer_timestamp >= review_creation_date)
);

COMMENT ON TABLE ecommify.order_reviews IS 'Reseñas de clientes sobre pedidos. La PK compuesta evita perder reseñas cuando un review_id aparece en más de una orden.';

-- ================================================================
-- 3. Índices para integridad, navegación y rendimiento analítico
-- ================================================================

CREATE INDEX idx_customers_unique_id ON ecommify.customers(customer_unique_id);
CREATE INDEX idx_customers_location ON ecommify.customers(customer_state, customer_city, customer_zip_code_prefix);
CREATE INDEX idx_sellers_location ON ecommify.sellers(seller_state, seller_city, seller_zip_code_prefix);

CREATE INDEX idx_products_category ON ecommify.products(product_category_name);
CREATE INDEX idx_products_dimensions ON ecommify.products(product_weight_g, product_length_cm, product_height_cm, product_width_cm);

CREATE INDEX idx_orders_customer ON ecommify.orders(customer_id);
CREATE INDEX idx_orders_status_purchase ON ecommify.orders(order_status, order_purchase_timestamp DESC);
CREATE INDEX idx_orders_purchase_date ON ecommify.orders(order_purchase_timestamp DESC);
CREATE INDEX idx_orders_delivered_customer_date ON ecommify.orders(order_delivered_customer_date);

CREATE INDEX idx_order_items_product ON ecommify.order_items(product_id);
CREATE INDEX idx_order_items_seller ON ecommify.order_items(seller_id);
CREATE INDEX idx_order_items_shipping_limit ON ecommify.order_items(shipping_limit_date);
CREATE INDEX idx_order_items_revenue ON ecommify.order_items(price, freight_value);

CREATE INDEX idx_order_payments_type ON ecommify.order_payments(payment_type);
CREATE INDEX idx_order_reviews_score ON ecommify.order_reviews(review_score);
CREATE INDEX idx_order_reviews_creation ON ecommify.order_reviews(review_creation_date DESC);

CREATE INDEX idx_geolocations_zip ON ecommify.geolocations(geolocation_zip_code_prefix);
CREATE INDEX idx_geolocations_state_city ON ecommify.geolocations(geolocation_state, geolocation_city);
CREATE INDEX idx_product_category_trgm ON ecommify.product_categories USING GIN (product_category_name_english gin_trgm_ops);

COMMIT;
