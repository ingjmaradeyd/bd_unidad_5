# Ecommify - Scripts PostgreSQL con carga desde CSV

Este paquete deja la carga de datos como debe manejarse para el tamaño real de Ecommify: los datos se leen desde archivos CSV mediante `psql` y el comando `\copy`. No se usan `INSERT` masivos ni `COPY FROM STDIN`, porque esos enfoques generan archivos enormes o fallan en IDEs como DataGrip/DBeaver.

## 1. Dónde debes poner los CSV

Los CSV deben estar dentro de la carpeta `csv/`, al mismo nivel de la carpeta `scripts/` y del archivo `run_all_psql.sh`.

La estructura correcta es esta:

```text
ecommify_sql_csv_final/
├── csv/
│   ├── product_category_name_translation.csv
│   ├── olist_customers_dataset.csv
│   ├── olist_sellers_dataset.csv
│   ├── olist_products_dataset.csv
│   ├── olist_orders_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_order_payments_dataset.csv
│   ├── olist_order_reviews_dataset.csv
│   └── olist_geolocation_dataset.csv
├── scripts/
│   ├── 00_crear_modelo_er_ecommify.sql
│   ├── 01_crear_staging_ecommify.sql
│   ├── 02_cargar_todo_staging_desde_csv_psql.sql
│   ├── 03_transformar_staging_a_modelo_er.sql
│   ├── 04_validaciones_modelo_er.sql
│   ├── 05_consultas_analiticas_base.sql
│   └── 99_reconteo_staging.sql
├── run_all_psql.sh
└── run_all_psql.bat
```

En este ZIP ya dejé los CSV incluidos en la carpeta `csv/`. No tienes que moverlos si descomprimes el paquete completo y ejecutas desde la carpeta raíz.

## 2. Cómo ejecutar en Mac/Linux con psql

Abre la terminal dentro de la carpeta del paquete:

```bash
cd ecommify_sql_csv_final
chmod +x run_all_psql.sh
```

Ejecuta el script pasando la cadena de conexión real:

```bash
./run_all_psql.sh "postgresql://USUARIO:PASSWORD@HOST:PUERTO/postgres?sslmode=require"
```

Para Supabase con pooler IPv4, la forma esperada es:

```bash
./run_all_psql.sh "postgresql://postgres.xxxxx:TU_PASSWORD@aws-0-xxxx.pooler.supabase.com:6543/postgres?sslmode=require"
```

Importante: el `HOST` del pooler debes copiarlo exactamente desde Supabase en:

```text
Project Settings → Database → Connection string → Transaction Pooler
```

## 3. Cómo ejecutar en Windows

Desde CMD o PowerShell, entra a la carpeta del paquete y ejecuta:

```bat
run_all_psql.bat "postgresql://USUARIO:PASSWORD@HOST:PUERTO/postgres?sslmode=require"
```

## 4. Qué hace cada script

| Script | Función |
|---|---|
| `00_crear_modelo_er_ecommify.sql` | Crea el modelo relacional final `ecommify`: tablas, llaves primarias, llaves foráneas, restricciones e índices. |
| `01_crear_staging_ecommify.sql` | Crea el esquema `ecommify_stg` con tablas temporales de aterrizaje para recibir los CSV. |
| `02_cargar_todo_staging_desde_csv_psql.sql` | Ejecuta la carga de todos los CSV usando `\copy`. |
| `99_reconteo_staging.sql` | Valida cuántos registros quedaron cargados en staging. |
| `03_transformar_staging_a_modelo_er.sql` | Transforma los datos desde staging al modelo E-R final. |
| `04_validaciones_modelo_er.sql` | Ejecuta validaciones de integridad, conteo y relaciones. |
| `05_consultas_analiticas_base.sql` | Incluye consultas base para análisis de negocio y validación funcional. |

## 5. Por qué se usa `\copy`

`\copy` es un comando de `psql`. Lee los CSV desde tu computador y los envía a PostgreSQL/Supabase. Esto evita dos problemas:

1. El servidor Supabase no puede leer archivos locales de tu máquina con `COPY FROM '/ruta/archivo.csv'`.
2. DataGrip/DBeaver pueden fallar con `COPY FROM STDIN` porque requieren soporte especial de CopyManager.

Por eso, para este taller, la forma más estable es:

```sql
\copy tabla FROM 'csv/archivo.csv' WITH (FORMAT csv, HEADER true);
```

## 6. Mapeo CSV → tabla staging

| Archivo CSV | Tabla staging |
|---|---|
| `product_category_name_translation.csv` | `ecommify_stg.product_category_translation_raw` |
| `olist_customers_dataset.csv` | `ecommify_stg.customers_raw` |
| `olist_sellers_dataset.csv` | `ecommify_stg.sellers_raw` |
| `olist_products_dataset.csv` | `ecommify_stg.products_raw` |
| `olist_orders_dataset.csv` | `ecommify_stg.orders_raw` |
| `olist_order_items_dataset.csv` | `ecommify_stg.order_items_raw` |
| `olist_order_payments_dataset.csv` | `ecommify_stg.order_payments_raw` |
| `olist_order_reviews_dataset.csv` | `ecommify_stg.order_reviews_raw` |
| `olist_geolocation_dataset.csv` | `ecommify_stg.geolocation_raw` |

## 7. Conteos esperados en staging

| Tabla staging | Registros esperados |
|---|---:|
| `product_category_translation_raw` | 70 |
| `customers_raw` | 99.441 |
| `sellers_raw` | 3.095 |
| `products_raw` | 32.951 |
| `orders_raw` | 99.441 |
| `order_items_raw` | 112.650 |
| `order_payments_raw` | 103.886 |
| `order_reviews_raw` | 104.719 |
| `geolocation_raw` | 1.000.163 |

## 8. Si no puedes usar psql

Puedes usar DataGrip así:

1. Ejecuta `00_crear_modelo_er_ecommify.sql`.
2. Ejecuta `01_crear_staging_ecommify.sql`.
3. Ejecuta `02_00_limpiar_staging_ecommify.sql`.
4. Importa manualmente cada CSV sobre su tabla staging correspondiente usando `Import Data from File`.
5. Ejecuta `99_reconteo_staging.sql`.
6. Ejecuta `03_transformar_staging_a_modelo_er.sql`.
7. Ejecuta `04_validaciones_modelo_er.sql`.
8. Ejecuta `05_consultas_analiticas_base.sql`.

## 9. Nota sobre Supabase IPv6

Si usas el endpoint directo:

```text
db.xxxxx.supabase.co:5432
```

puede fallar con `No route to host` porque ese endpoint suele resolver por IPv6. Para evitarlo, usa el Transaction Pooler de Supabase por puerto `6543`, que acepta IPv4.
