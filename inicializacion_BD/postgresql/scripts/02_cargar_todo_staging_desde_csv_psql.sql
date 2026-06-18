-- ================================================================
-- ECOMMIFY - Carga completa de staging desde CSV usando psql
-- IMPORTANTE: este archivo usa \copy, no COPY.
-- \copy lee los CSV desde tu equipo y los envía a Supabase/PostgreSQL.
-- Debes ejecutar psql desde la carpeta raíz del entregable, donde existe /csv.
-- ================================================================

\i scripts/02_00_limpiar_staging_ecommify.sql
\i scripts/02_01_cargar_product_category_translation_psql.sql
\i scripts/02_02_cargar_customers_psql.sql
\i scripts/02_03_cargar_sellers_psql.sql
\i scripts/02_04_cargar_products_psql.sql
\i scripts/02_05_cargar_orders_psql.sql
\i scripts/02_06_cargar_order_items_psql.sql
\i scripts/02_07_cargar_order_payments_psql.sql
\i scripts/02_08_cargar_order_reviews_psql.sql
\i scripts/02_09_cargar_geolocation_psql.sql
