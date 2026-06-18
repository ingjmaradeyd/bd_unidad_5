-- Ejecutar con psql desde la carpeta raíz del entregable.
\copy ecommify_stg.orders_raw (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date) FROM 'csv/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
