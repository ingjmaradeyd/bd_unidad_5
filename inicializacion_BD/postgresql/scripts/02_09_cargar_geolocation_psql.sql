-- Ejecutar con psql desde la carpeta raíz del entregable.
-- Este es el archivo más grande; puede tardar varios minutos en Supabase.
\copy ecommify_stg.geolocation_raw (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state) FROM 'csv/olist_geolocation_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
