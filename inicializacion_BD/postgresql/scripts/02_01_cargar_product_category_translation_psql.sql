-- Ejecutar con psql desde la carpeta raíz del entregable.
\copy ecommify_stg.product_category_translation_raw (product_category_name, product_category_name_english) FROM 'csv/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
