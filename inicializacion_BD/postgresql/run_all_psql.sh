#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Uso: ./run_all_psql.sh '<connection_string>'"
  echo "Ejemplo Supabase pooler:"
  echo "./run_all_psql.sh 'postgresql://postgres.xxxxx:TU_PASSWORD@aws-0-xxxx.pooler.supabase.com:6543/postgres?sslmode=require'"
  exit 1
fi

CONN="$1"
cd "$(dirname "$0")"

psql "$CONN" -v ON_ERROR_STOP=1 -f scripts/00_crear_modelo_er_ecommify.sql
psql "$CONN" -v ON_ERROR_STOP=1 -f scripts/01_crear_staging_ecommify.sql
psql "$CONN" -v ON_ERROR_STOP=1 -f scripts/02_cargar_todo_staging_desde_csv_psql.sql
psql "$CONN" -v ON_ERROR_STOP=1 -f scripts/99_reconteo_staging.sql
psql "$CONN" -v ON_ERROR_STOP=1 -f scripts/03_transformar_staging_a_modelo_er.sql
psql "$CONN" -v ON_ERROR_STOP=1 -f scripts/04_validaciones_modelo_er.sql
