-- Ejecutar con psql desde la carpeta raíz del entregable.
\copy ecommify_stg.order_reviews_raw (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp) FROM 'csv/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
