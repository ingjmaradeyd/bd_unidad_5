-- Ejecutar con psql desde la carpeta raíz del entregable.
\copy ecommify_stg.order_items_raw (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value) FROM 'csv/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
