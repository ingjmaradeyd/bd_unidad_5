
# README.md
## Optimización y Rendimiento en Bases de Datos – Ecommify
### Unidad 5 – PostgreSQL y MongoDB

# Integrantes del Equipo

| Nombre Completo | Rol |
|-----------------|------|
| Abdul Mauricio Reyes Parra | Integrante |
| Wilmer Ricardo Castro Delgadillo | Integrante |
| Jorge Rolando Maradey Durán | Integrante |

# Información General

| Atributo | Valor |
|-----------|--------|
| Asignatura | Bases de Datos Avanzadas |
| Unidad | Unidad 5 |
| Actividad | Optimización y Rendimiento en Bases de Datos |
| Caso de Estudio | Ecommify |
| Modalidad | Grupal |
| Motores Implementados | PostgreSQL y MongoDB |
| Herramientas Utilizadas | Supabase, MongoDB, Google Colab, Python, Pandas |
| Dataset Utilizado | Olist E-Commerce Dataset |


Este repositorio contiene el desarrollo de la **Unidad 5 - Optimización de rendimiento en bases de datos**, aplicado al caso **Ecommify**, una plataforma de comercio electrónico basada en datos transaccionales, catálogo de productos, pagos, reseñas, vendedores, clientes y geolocalización.

El entregable está organizado para demostrar dos líneas de implementación:

1. **PostgreSQL / Supabase**, como motor relacional transaccional y analítico, usando modelo entidad-relación, staging, llaves primarias, llaves foráneas, validaciones, índices y consultas optimizadas.
2. **MongoDB / Google Colab**, como motor NoSQL documental, usando colecciones, carga documental, índices compuestos, índices parciales, índices full-text, aggregation pipelines, `explain("executionStats")`, reportes automáticos y simulación de sharding.

---

## 1. Arquitectura general de la solución

```mermaid
flowchart LR
    A[Fuentes Ecommify / Olist CSV] --> B[Zona de carga PostgreSQL ecommify_stg]
    B --> C[Transformación y limpieza SQL]
    C --> D[Modelo relacional PostgreSQL ecommify]
    D --> E[Consultas analíticas SQL]
    D --> F[Evidencias EXPLAIN ANALYZE]

    A --> G[Google Drive]
    G --> H[Google Colab Notebook]
    H --> I[MongoDB local en Colab]
    I --> J[Colecciones documentales]
    J --> K[Índices ESR / parciales / full-text]
    K --> L[Aggregation Pipelines]
    L --> M[Reportes HTML y CSV]

    E --> N[Informe técnico PostgreSQL]
    M --> O[Informe técnico MongoDB]
```

La solución utiliza PostgreSQL para demostrar consistencia transaccional, normalización e integridad referencial, mientras que MongoDB se utiliza para demostrar flexibilidad documental, optimización por patrones de consulta y procesamiento analítico mediante agregaciones.

---

## 2. Estructura del repositorio

```mermaid
flowchart TD
    ROOT[DesarrolloActividad]

    ROOT --> DOC[documentos]
    DOC --> DOC1[Informe_Tecnico_Ecommify_postgres.docx]
    DOC --> DOC2[Informe_Tecnico_Ecommify_mongodb.docx]

    ROOT --> INIT[inicializacion_BD]
    INIT --> PG_INIT[postgresql]
    INIT --> MONGO_INIT[mongodb]

    PG_INIT --> CSV[csv]
    PG_INIT --> SCRIPTS[scripts]
    PG_INIT --> RUNSH[run_all_psql.sh]
    PG_INIT --> RUNBAT[run_all_psql.bat]
    PG_INIT --> PGREADME[README_EJECUCION_CSV.md]

    MONGO_INIT --> COLAB[Ecommify_MongoDB_Local_Colab.ipynb]

    ROOT --> ACT1[Actividad_1]
    ACT1 --> PG_ACT[postgresql]
    ACT1 --> MONGO_ACT[mongodb]

    PG_ACT --> SQL_EVID[Scripts SQL de evidencia]
    MONGO_ACT --> REPORTS[ecommify_reportes_mongodb_local]
```

---

## 3. Descripción de carpetas

| Carpeta | Propósito | Contenido principal |
|---|---|---|
| `documentos/` | Contiene los informes técnicos finales del entregable. | Informes Word de PostgreSQL y MongoDB. |
| `inicializacion_BD/postgresql/` | Contiene todo lo necesario para crear y cargar la base relacional en PostgreSQL/Supabase. | Scripts SQL, CSV, ejecutables `.sh` y `.bat`. |
| `inicializacion_BD/postgresql/csv/` | Contiene los archivos fuente del dataset Ecommify/Olist. | Clientes, órdenes, productos, vendedores, pagos, reseñas, geolocalización y traducciones. |
| `inicializacion_BD/postgresql/scripts/` | Contiene los scripts SQL ordenados para crear, cargar, transformar y validar PostgreSQL. | Scripts `00` a `05` y scripts auxiliares `02_*` y `99`. |
| `inicializacion_BD/mongodb/` | Contiene el notebook de Google Colab para MongoDB local. | `Ecommify_MongoDB_Local_Colab.ipynb`. |
| `Actividad_1/postgresql/` | Contiene scripts de evidencia para la etapa de validación y análisis en PostgreSQL. | Conteos, PK/FK, integridad referencial, consultas analíticas y `EXPLAIN ANALYZE`. |
| `Actividad_1/mongodb/ecommify_reportes_mongodb_local/` | Contiene reportes generados por el notebook MongoDB. | CSV de conteos, índices, métricas, ventas por categoría, sharding e informe HTML. |

---

## 4. Flujo PostgreSQL

```mermaid
sequenceDiagram
    participant U as Usuario
    participant PSQL as psql / Supabase
    participant STG as ecommify_stg
    participant ER as ecommify
    participant EV as Evidencias SQL

    U->>PSQL: Ejecuta run_all_psql.sh o run_all_psql.bat
    PSQL->>ER: 00_crear_modelo_er_ecommify.sql
    PSQL->>STG: 01_crear_staging_ecommify.sql
    PSQL->>STG: 02_cargar_todo_staging_desde_csv_psql.sql
    PSQL->>STG: 99_reconteo_staging.sql
    PSQL->>ER: 03_transformar_staging_a_modelo_er.sql
    PSQL->>ER: 04_validaciones_modelo_er.sql
    U->>EV: Ejecuta scripts 06_01 a 06_05
    EV->>U: Evidencias de conteo, relaciones, integridad y rendimiento
```

---

## 5. Modelo relacional PostgreSQL

```mermaid
erDiagram
    CUSTOMERS ||--o{ ORDERS : realiza
    ORDERS ||--o{ ORDER_ITEMS : contiene
    ORDERS ||--o{ ORDER_PAYMENTS : registra
    ORDERS ||--o{ ORDER_REVIEWS : recibe
    PRODUCTS ||--o{ ORDER_ITEMS : vendido_en
    SELLERS ||--o{ ORDER_ITEMS : vende
    PRODUCT_CATEGORIES ||--o{ PRODUCTS : clasifica

    CUSTOMERS {
        varchar customer_id PK
        varchar customer_unique_id
        int customer_zip_code_prefix
        varchar customer_city
        char customer_state
    }

    ORDERS {
        varchar order_id PK
        varchar customer_id FK
        varchar order_status
        timestamp order_purchase_timestamp
        timestamp order_approved_at
        timestamp order_delivered_carrier_date
        timestamp order_delivered_customer_date
        timestamp order_estimated_delivery_date
    }

    ORDER_ITEMS {
        varchar order_id PK, FK
        int order_item_id PK
        varchar product_id FK
        varchar seller_id FK
        timestamp shipping_limit_date
        numeric price
        numeric freight_value
    }

    PRODUCTS {
        varchar product_id PK
        varchar product_category_name FK
        int product_name_length
        int product_description_length
        int product_photos_qty
        int product_weight_g
        int product_length_cm
        int product_height_cm
        int product_width_cm
    }

    SELLERS {
        varchar seller_id PK
        int seller_zip_code_prefix
        varchar seller_city
        char seller_state
    }

    PRODUCT_CATEGORIES {
        varchar product_category_name PK
        varchar product_category_name_english
    }

    ORDER_PAYMENTS {
        varchar order_id PK, FK
        int payment_sequential PK
        varchar payment_type
        int payment_installments
        numeric payment_value
    }

    ORDER_REVIEWS {
        varchar review_id PK
        varchar order_id PK, FK
        int review_score
        text review_comment_title
        text review_comment_message
        timestamp review_creation_date
        timestamp review_answer_timestamp
    }
```

---

## 6. Carga PostgreSQL desde CSV

### 6.1 Ubicación de los CSV

Los CSV ya están incluidos en:

```text
inicializacion_BD/postgresql/csv/
```

Archivos esperados:

| Archivo | Tabla staging destino |
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

### 6.2 Ejecución en Mac/Linux

Desde la raíz del proyecto:

```bash
cd inicializacion_BD/postgresql
chmod +x run_all_psql.sh
./run_all_psql.sh "postgresql://USUARIO:PASSWORD@HOST:PUERTO/postgres?sslmode=require"
```

Para Supabase se recomienda usar el **Transaction Pooler**:

```bash
./run_all_psql.sh "postgresql://postgres.xxxxx:TU_PASSWORD@aws-0-xxxx.pooler.supabase.com:6543/postgres?sslmode=require"
```

El host real se obtiene en:

```text
Supabase → Project Settings → Database → Connection string → Transaction Pooler
```

### 6.3 Ejecución en Windows

```bat
cd inicializacion_BD\postgresql
run_all_psql.bat "postgresql://USUARIO:PASSWORD@HOST:PUERTO/postgres?sslmode=require"
```

### 6.4 Ejecución manual desde DataGrip o DBeaver

Si no se usa `psql`, ejecutar en este orden:

| Orden | Script | Descripción |
|---:|---|---|
| 1 | `00_crear_modelo_er_ecommify.sql` | Crea el esquema final `ecommify`, tablas, PK, FK, constraints, extensiones e índices. |
| 2 | `01_crear_staging_ecommify.sql` | Crea el esquema `ecommify_stg` y las tablas crudas para recibir los CSV. |
| 3 | `02_00_limpiar_staging_ecommify.sql` | Limpia staging antes de importar. |
| 4 | Importación manual CSV | Importar cada CSV sobre su tabla staging correspondiente. |
| 5 | `99_reconteo_staging.sql` | Verifica conteos cargados en staging. |
| 6 | `03_transformar_staging_a_modelo_er.sql` | Limpia, transforma y migra los datos al modelo E-R final. |
| 7 | `04_validaciones_modelo_er.sql` | Valida integridad, conteos y relaciones. |
| 8 | `05_consultas_analiticas_base.sql` | Ejecuta consultas analíticas base. |

---

## 7. Scripts PostgreSQL incluidos

| Script | Ubicación | Función técnica |
|---|---|---|
| `00_crear_modelo_er_ecommify.sql` | `inicializacion_BD/postgresql/scripts/` | Crea esquemas, extensiones, tablas finales, PK, FK, constraints e índices base. |
| `01_crear_staging_ecommify.sql` | `inicializacion_BD/postgresql/scripts/` | Crea tablas raw en `ecommify_stg` para recibir los CSV sin pérdida de datos por conversión temprana. |
| `02_cargar_todo_staging_desde_csv_psql.sql` | `inicializacion_BD/postgresql/scripts/` | Ejecuta la carga usando `\copy`, leyendo archivos locales desde la carpeta `csv/`. |
| `02_01` a `02_09` | `inicializacion_BD/postgresql/scripts/` | Cargas individuales por dataset, útiles para depuración o ejecución parcial. |
| `99_reconteo_staging.sql` | `inicializacion_BD/postgresql/scripts/` | Genera conteos de control sobre staging. |
| `03_transformar_staging_a_modelo_er.sql` | `inicializacion_BD/postgresql/scripts/` | Convierte tipos, normaliza textos, corrige constraints compatibles con el dataset y carga el modelo final. |
| `04_validaciones_modelo_er.sql` | `inicializacion_BD/postgresql/scripts/` | Valida integridad referencial y calidad básica. |
| `05_consultas_analiticas_base.sql` | `inicializacion_BD/postgresql/scripts/` | Consultas analíticas iniciales para negocio. |

---

## 8. Evidencias PostgreSQL - Actividad 1

Los scripts de evidencia están en:

```text
Actividad_1/postgresql/
```

| Script | Evidencia generada |
|---|---|
| `06_01_evidencia_modelo_y_conteos.sql` | Lista esquemas, tablas y conteos finales por entidad. |
| `06_02_evidencia_llaves_y_relaciones.sql` | Muestra llaves primarias, foráneas y constraints del modelo. |
| `06_03_evidencia_integridad_referencial.sql` | Valida registros huérfanos entre órdenes, clientes, productos, vendedores, pagos y reseñas. El resultado esperado es cero registros inválidos. |
| `06_04_evidencia_consultas_analiticas.sql` | Ejecuta consultas de negocio: ventas por categoría, ventas por estado y calificación promedio por categoría. |
| `06_05_evidencia_explain_analyze.sql` | Ejecuta `EXPLAIN ANALYZE` para demostrar comportamiento de rendimiento. |

### Flujo de evidencias SQL

```mermaid
flowchart TD
    A[Modelo ecommify cargado] --> B[06_01 Conteos]
    A --> C[06_02 PK / FK / Constraints]
    A --> D[06_03 Integridad referencial]
    A --> E[06_04 Consultas analíticas]
    E --> F[06_05 EXPLAIN ANALYZE]
    B --> G[Capturas para informe]
    C --> G
    D --> G
    E --> G
    F --> G
```

---

## 9. Implementación MongoDB en Google Colab

El notebook principal está en:

```text
inicializacion_BD/mongodb/Ecommify_MongoDB_Local_Colab.ipynb
```

Este notebook instala y ejecuta MongoDB local dentro de la sesión temporal de Google Colab. Luego carga los CSV desde Google Drive, crea colecciones, índices y reportes.

> Nota: MongoDB local en Colab es temporal. Al cerrar o reiniciar la sesión, la base se pierde. Para persistencia real se recomienda MongoDB Atlas. Para esta actividad, Colab permite demostrar creación, carga, indexación, `explain` y pipelines.

### 9.1 Ubicación de los CSV en Google Drive

Antes de ejecutar el notebook, colocar los CSV en:

```text
Mi unidad/ecommify/csv/
```

El notebook usa esta ruta:

```python
DRIVE_CSV_DIR = "/content/drive/MyDrive/ecommify/csv"
```

Si se usa otra carpeta, modificar esa variable en el notebook.

---

## 10. Flujo MongoDB en Colab

```mermaid
sequenceDiagram
    participant GD as Google Drive
    participant NB as Notebook Colab
    participant MG as MongoDB local
    participant IX as Índices
    participant AG as Aggregation Pipelines
    participant RP as Reportes

    NB->>GD: Monta Drive y lee CSV
    NB->>NB: Limpia datos y convierte tipos
    NB->>MG: Crea base Ecommify
    NB->>MG: Crea colecciones documentales
    NB->>MG: Inserta documentos por lotes
    NB->>IX: Crea índices ESR, parciales y full-text
    NB->>MG: Ejecuta explain("executionStats")
    NB->>AG: Ejecuta pipelines con allowDiskUse
    NB->>RP: Genera CSV, HTML y ZIP de evidencias
```

---

## 11. Colecciones MongoDB creadas

```mermaid
flowchart TD
    DB[(MongoDB Local - Ecommify)]
    DB --> C1[customers]
    DB --> C2[geolocation]
    DB --> C3[orders]
    DB --> C4[order_items]
    DB --> C5[order_payments]
    DB --> C6[order_reviews]
    DB --> C7[products_catalog]
    DB --> C8[sellers]
    DB --> C9[category_translation]
    DB --> C10[analytics_results]

    C7 --> IDX1[Índice parcial categoría + peso]
    C7 --> IDX2[Índice full-text categoría]
    C3 --> IDX3[Índice ESR estado + compra + entrega estimada]
    C4 --> IDX4[Índice order_id + product_id + seller_id]
    C6 --> IDX5[Índice review_score + review_creation_date]
```

| Colección | Propósito |
|---|---|
| `customers` | Información de clientes. |
| `geolocation` | Datos geográficos por prefijo postal. |
| `orders` | Órdenes de compra. |
| `order_items` | Detalle de productos vendidos por orden. |
| `order_payments` | Pagos asociados a órdenes. |
| `order_reviews` | Reseñas y calificaciones. |
| `products_catalog` | Catálogo enriquecido de productos con traducción de categoría. |
| `sellers` | Información de vendedores. |
| `category_translation` | Traducciones de categorías. |
| `analytics_results` | Colección reservada para persistir resultados derivados. |

---

## 12. Índices MongoDB implementados

```mermaid
flowchart LR
    A[Consulta orders por estado] --> B[idx_orders_esr_status_purchase_estimated]
    B --> C[order_status Equality]
    B --> D[order_purchase_timestamp Sort]
    B --> E[order_estimated_delivery_date Range]

    F[Consulta order_items por orden] --> G[idx_order_items_order_product_seller]
    H[Catálogo por categoría y peso] --> I[idx_products_category_weight_partial]
    J[Búsqueda textual catálogo] --> K[idx_products_full_text_category]
    L[Reviews por score] --> M[idx_reviews_score_creation]
```

| Índice | Colección | Tipo | Justificación |
|---|---|---|---|
| `idx_orders_esr_status_purchase_estimated` | `orders` | Compuesto ESR | Optimiza filtros por estado, ordenamiento por fecha de compra y rangos temporales de entrega. |
| `idx_order_items_order_product_seller` | `order_items` | Compuesto | Optimiza relaciones lógicas entre órdenes, productos y vendedores. |
| `idx_products_category_weight_partial` | `products_catalog` | Parcial | Indexa solo productos con categoría válida y peso mayor a cero, reduciendo tamaño del índice. |
| `idx_products_full_text_category` | `products_catalog` | Full-text | Habilita búsqueda textual en categorías originales y traducidas. |
| `idx_reviews_score_creation` | `order_reviews` | Compuesto | Optimiza análisis por calificación y fecha de creación. |
| `idx_customers_customer_id` | `customers` | Soporte | Acelera búsquedas por identificador de cliente. |
| `idx_orders_order_id` | `orders` | Soporte | Acelera búsquedas por identificador de orden. |
| `idx_products_product_id` | `products_catalog` | Soporte | Acelera relaciones lógicas con `order_items`. |
| `idx_sellers_seller_id` | `sellers` | Soporte | Acelera consultas por vendedor. |

---

## 13. Aggregation Pipelines MongoDB

El notebook ejecuta pipelines con los operadores requeridos por la actividad:

- `$match`
- `$project`
- `$lookup`
- `$unwind`
- `$group`
- `$sort`
- `$facet`
- `$bucket`

### Pipeline analítico principal

```mermaid
flowchart TD
    A[orders] --> B[$match order_status = delivered]
    B --> C[$project campos mínimos]
    C --> D[$lookup order_items]
    D --> E[$unwind items]
    E --> F[$lookup products_catalog]
    F --> G[$unwind product]
    G --> H[$group por product_category_name_english]
    H --> I[$project métricas de negocio]
    I --> J[$sort gross_value DESC]
    J --> K[$limit Top 20 categorías]
```

### Métricas calculadas

| Métrica | Descripción |
|---|---|
| `orders_count` | Cantidad de órdenes por categoría. |
| `items_sold` | Cantidad de productos vendidos por categoría. |
| `total_sales` | Valor total de venta sin flete. |
| `avg_price` | Precio promedio de venta. |
| `total_freight` | Valor total de flete. |
| `gross_value` | Venta total + flete. |

---

## 14. Reportes MongoDB generados

Los reportes de MongoDB están en:

```text
Actividad_1/mongodb/ecommify_reportes_mongodb_local/
```

| Reporte | Descripción |
|---|---|
| `01_conteos_fuente.csv` | Conteos leídos desde los CSV originales. |
| `02_conteos_mongodb_local.csv` | Conteos cargados en colecciones MongoDB. |
| `03_indices_mongodb_local.csv` | Índices creados por colección. |
| `04_metricas_rendimiento.csv` | Métricas de `explain("executionStats")`. |
| `05_ventas_por_categoria.csv` | Resultado del pipeline analítico principal. |
| `06_simulacion_sharding.csv` | Simulación de distribución de documentos en shards. |
| `Informe_Ecommify_MongoDB_Local_Colab.html` | Informe HTML consolidado. |

---

## 15. Resultados cuantitativos principales

### Volumen de datos fuente

| Fuente | Registros |
|---|---:|
| customers | 99.441 |
| geolocation | 1.000.163 |
| order_items | 112.650 |
| order_payments | 103.886 |
| order_reviews | 99.224 |
| orders | 99.441 |
| products | 32.951 |
| sellers | 3.095 |
| category_translation | 71 |

### Distribución simulada de sharding

```mermaid
pie title Distribución simulada de documentos por shard
    "Shard 0" : 33215
    "Shard 1" : 33217
    "Shard 2" : 33009
```

La simulación evidencia una distribución balanceada cercana al 33% por shard, adecuada para justificar una estrategia de particionamiento horizontal.

---

## 16. Mapa de cumplimiento de la actividad

| Requisito de la Unidad 5 | Evidencia en el repositorio |
|---|---|
| Implementación PostgreSQL en Supabase | `inicializacion_BD/postgresql/scripts/` |
| Scripts DDL | `00_crear_modelo_er_ecommify.sql`, `01_crear_staging_ecommify.sql` |
| Carga de datos | `02_cargar_todo_staging_desde_csv_psql.sql` y CSV incluidos |
| Transformación al modelo E-R | `03_transformar_staging_a_modelo_er.sql` |
| Validaciones PostgreSQL | `04_validaciones_modelo_er.sql`, `Actividad_1/postgresql/06_*.sql` |
| Consultas analíticas PostgreSQL | `05_consultas_analiticas_base.sql`, `06_04_evidencia_consultas_analiticas.sql` |
| Evidencia de rendimiento SQL | `06_05_evidencia_explain_analyze.sql` |
| Implementación MongoDB | `inicializacion_BD/mongodb/Ecommify_MongoDB_Local_Colab.ipynb` |
| Índices compuestos ESR | Notebook MongoDB, sección de creación de índices |
| Índices parciales | `idx_products_category_weight_partial` |
| Índices full-text | `idx_products_full_text_category` |
| Aggregation Pipeline complejo | Notebook, pipeline de ventas por categoría |
| `allowDiskUse` | Usado en agregaciones del notebook |
| `explain("executionStats")` | Notebook y `04_metricas_rendimiento.csv` |
| Sharding teórico | Notebook y `06_simulacion_sharding.csv` |
| Informes técnicos | Carpeta `documentos/` |

---

## 17. Recomendaciones para sustentación

Para presentar la actividad, se recomienda seguir este orden:

```mermaid
flowchart TD
    A[1. Mostrar estructura del repositorio] --> B[2. Explicar arquitectura híbrida PostgreSQL + MongoDB]
    B --> C[3. Ejecutar o mostrar carga PostgreSQL]
    C --> D[4. Mostrar modelo E-R y relaciones]
    D --> E[5. Ejecutar evidencias SQL]
    E --> F[6. Abrir notebook MongoDB en Colab]
    F --> G[7. Mostrar colecciones e índices]
    G --> H[8. Mostrar explain executionStats]
    H --> I[9. Mostrar pipelines y reportes]
    I --> J[10. Cerrar con conclusiones y lecciones aprendidas]
```

Capturas sugeridas:

1. Árbol del repositorio.
2. Ejecución exitosa de `run_all_psql.sh` o scripts SQL.
3. Conteos finales PostgreSQL.
4. Relación de PK/FK PostgreSQL.
5. Resultado de `EXPLAIN ANALYZE`.
6. Ejecución del notebook en Colab.
7. Conteos MongoDB.
8. Índices MongoDB.
9. Métricas `executionStats`.
10. Pipeline de ventas por categoría.
11. Simulación de sharding.

---

## 18. Problemas comunes y solución

| Problema | Causa probable | Solución |
|---|---|---|
| `psql: command not found` | Cliente PostgreSQL no instalado. | Instalar PostgreSQL client o ejecutar desde DataGrip/DBeaver. |
| `No route to host` en Supabase | Endpoint directo resolviendo por IPv6. | Usar Transaction Pooler de Supabase puerto `6543`. |
| `COPY from stdin failed` | IDE no soporta `COPY FROM STDIN`. | Usar `psql` con `\copy` o importar CSV manualmente. |
| Error en constraints de productos | Dataset real contiene pesos/dimensiones en cero. | Usar el script `03_transformar_staging_a_modelo_er.sql`, que ajusta constraints a `>= 0`. |
| Categoría sin traducción | Algunas categorías existen en productos pero no en traducciones. | El script `03` usa el nombre técnico como fallback. |
| MongoDB se pierde en Colab | La VM de Colab es temporal. | Reejecutar notebook o migrar a MongoDB Atlas. |
| Error de índice parcial MongoDB con `$ne: null` | MongoDB no permite esa expresión en partial index. | Usar `$type: "string"`, ya corregido en el notebook. |

---

## 19. Conclusión técnica

El proyecto demuestra una implementación completa de persistencia híbrida para Ecommify. PostgreSQL aporta estructura relacional, integridad, normalización y consultas analíticas SQL, mientras que MongoDB permite modelado documental, consultas flexibles, agregaciones avanzadas, índices especializados y simulación de escalabilidad horizontal.

La organización del repositorio facilita la reproducibilidad del ejercicio, separando claramente inicialización de bases de datos, scripts de evidencia, reportes generados e informes técnicos. Esta estructura es adecuada para una entrega académica y también refleja prácticas utilizadas en proyectos reales de arquitectura de datos.
