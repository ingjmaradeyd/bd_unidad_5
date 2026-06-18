-- Ejecutar con psql desde la carpeta raíz del entregable.
\copy ecommify_stg.sellers_raw (seller_id, seller_zip_code_prefix, seller_city, seller_state) FROM 'csv/olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
