-- Ejecutar con psql desde la carpeta raíz del entregable.
\copy ecommify_stg.order_payments_raw (order_id, payment_sequential, payment_type, payment_installments, payment_value) FROM 'csv/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
