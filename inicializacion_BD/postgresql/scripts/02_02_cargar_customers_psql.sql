-- Ejecutar con psql desde la carpeta raíz del entregable.
\copy ecommify_stg.customers_raw (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state) FROM 'csv/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
