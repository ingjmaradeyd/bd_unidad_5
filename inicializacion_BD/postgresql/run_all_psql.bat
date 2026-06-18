@echo off
IF "%~1"=="" (
  echo Uso: run_all_psql.bat "connection_string"
  echo Ejemplo: run_all_psql.bat "postgresql://postgres.xxxxx:TU_PASSWORD@aws-0-xxxx.pooler.supabase.com:6543/postgres?sslmode=require"
  exit /b 1
)
set CONN=%~1
cd /d %~dp0
psql "%CONN%" -v ON_ERROR_STOP=1 -f scripts/00_crear_modelo_er_ecommify.sql || exit /b 1
psql "%CONN%" -v ON_ERROR_STOP=1 -f scripts/01_crear_staging_ecommify.sql || exit /b 1
psql "%CONN%" -v ON_ERROR_STOP=1 -f scripts/02_cargar_todo_staging_desde_csv_psql.sql || exit /b 1
psql "%CONN%" -v ON_ERROR_STOP=1 -f scripts/99_reconteo_staging.sql || exit /b 1
psql "%CONN%" -v ON_ERROR_STOP=1 -f scripts/03_transformar_staging_a_modelo_er.sql || exit /b 1
psql "%CONN%" -v ON_ERROR_STOP=1 -f scripts/04_validaciones_modelo_er.sql || exit /b 1
