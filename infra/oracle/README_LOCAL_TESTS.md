# Pruebas locales Oracle

Estos scripts dejan un ambiente minimo para probar localmente los objetos PL/SQL compartidos:

- RCREDITO.FNINGESTACDPCP
- RCREDITO.SPBITACORABNPL
- RCREDITO.FNATPRLS0432

## Alcance

Se crea un esquema local RCREDITO con tablas minimas para compilar y ejecutar pruebas funcionales.
Tambien se crea el esquema USRATRZBAZ con un stub de SPREGISTRAERROR_ATRZ porque FNATPRLS0432 lo invoca de forma calificada por esquema.

## Orden de ejecucion

Ejecuta como SYS o SYSDBA, en modo script:

1. infra/oracle/setup/00_drop_local_env.sql
2. infra/oracle/setup/01_create_local_users.sql
3. infra/oracle/setup/02_create_support_objects.sql
4. infra/oracle/setup/03_seed_local_data.sql
5. infra/oracle/setup/04_compile_program_units.sql
6. infra/oracle/setup/05_grants_for_testing.sql

Despues corre los casos de prueba:

1. infra/oracle/test/01_test_fningestacdpcp.sql
2. infra/oracle/test/02_test_spbitacorabnpl.sql
3. infra/oracle/test/03_test_fnatprls0432.sql

## Hallazgos cubiertos por las pruebas

1. En FNINGESTACDPCP hay un bloque comentado como insercion de estatus 0 para bloqueos no recibidos, pero el codigo inserta FIIDSTATUS = 1.
2. En SPBITACORABNPL, cuando la ingesta devuelve exito, se lanza EXC_INGESTA_OK antes de insertar en TABNPLHEADER y TABNPLDETAIL. El caso de prueba 2 lo deja visible.
3. FNATPRLS0432 depende de RCREDITO.TANIVELCLIENTE y RCREDITO.TANIVELINTERES al compilar por el uso de %TYPE y por consultas directas.

## Notas practicas

- Los scripts usan datos de prueba controlados con pais 1, canal 1, sucursal 10.
- La password por defecto de RCREDITO es RCREDITO_123 y la de USRATRZBAZ es USRATRZBAZ_123.
- Si quieres otorgar permisos a otro usuario de pruebas distinto de SYS, cambia la variable TEST_USER en infra/oracle/setup/05_grants_for_testing.sql.
- Las tablas creadas aqui son un stub funcional, no el modelo productivo completo.