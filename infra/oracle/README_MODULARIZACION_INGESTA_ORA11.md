# Modularizacion FNINGESTACDPCP Oracle 11

## Versiones objetivo

### V1.0_COMPAT_ORA11

Objetivo:
- modularizar la funcion sin romper el contrato actual
- conservar `SYS_REFCURSOR` con `CODIGO` y `MENSAJE`
- mantener `COMMIT` y `ROLLBACK` solo en `FNINGESTACDPCP`
- no usar `PACKAGE`
- no usar features de Oracle 12c+

Componentes incluidos:
- `SPINGESTASYNCBLOQUEOSCP`
- `SPINGESTALINEAGESTORACP`
- `SPINGESTADIASPAGOCP`
- `SPINGESTACAPACIDADESCP`
- `FNINGESTACDPCP`

### V1.1_CORRECTIVA_ORA11

Objetivo:
- corregir hallazgos funcionales ya detectados
- hacerlo solo despues de validar reglas con negocio

Hallazgos previstos para V1.1:
- discrepancia en bitacora de bloqueos al desactivar
- producto sin mapeo de origen
- reinicio explicito de origen por iteracion
- validacion fuerte de periodicidades no soportadas
- decision sobre actualizacion de sucursal gestora en registros existentes
- sustitucion del literal `'USER'` por `USER`

## Restricciones tecnicas obligatorias

- Compatible con Oracle 11g
- No crear `PACKAGE`
- No mover el control transaccional a los SPs
- No usar `MERGE` en esta version
- No cambiar la firma publica de `FNINGESTACDPCP`
- No cambiar el contrato de consumo de `SPBITACORABNPL` ni `FNATPRLS0432`

## Flujo exacto de ejecucion

1. Validar parametros base en `FNINGESTACDPCP`
2. Mapear `PA_STSID` a status interno
3. Ejecutar `SPINGESTASYNCBLOQUEOSCP`
4. Ejecutar `SPINGESTALINEAGESTORACP`
5. Si `PA_PERPAGOID` viene informado, ejecutar `SPINGESTADIASPAGOCP`
6. Si `PA_CAPACIDADESPGO` viene informado, ejecutar `SPINGESTACAPACIDADESCP`
7. Ejecutar `COMMIT` en `FNINGESTACDPCP`
8. Retornar cursor con `CODIGO = 0`
9. Si hay error, ejecutar `ROLLBACK` en `FNINGESTACDPCP`
10. Retornar cursor con `CODIGO = 1`

## Archivos de implementacion

- [infra/oracle/procedures/SPINGESTASYNCBLOQUEOSCP.sql](infra/oracle/procedures/SPINGESTASYNCBLOQUEOSCP.sql)
- [infra/oracle/procedures/SPINGESTALINEAGESTORACP.sql](infra/oracle/procedures/SPINGESTALINEAGESTORACP.sql)
- [infra/oracle/procedures/SPINGESTADIASPAGOCP.sql](infra/oracle/procedures/SPINGESTADIASPAGOCP.sql)
- [infra/oracle/procedures/SPINGESTACAPACIDADESCP.sql](infra/oracle/procedures/SPINGESTACAPACIDADESCP.sql)
- [infra/oracle/fuctions/FNINGESTACDPCP.sql](infra/oracle/fuctions/FNINGESTACDPCP.sql)
- [infra/oracle/setup/04_compile_program_units.sql](infra/oracle/setup/04_compile_program_units.sql)
- [infra/oracle/setup/05_grants_for_testing.sql](infra/oracle/setup/05_grants_for_testing.sql)
- [infra/oracle/test/01_test_fningestacdpcp.sql](infra/oracle/test/01_test_fningestacdpcp.sql)

## Instrucciones de despliegue

Ejecutar en este orden:

1. `infra/oracle/setup/00_drop_local_env.sql`
2. `infra/oracle/setup/01_create_local_users.sql`
3. `infra/oracle/setup/02_create_support_objects.sql`
4. `infra/oracle/setup/03_seed_local_data.sql`
5. `infra/oracle/setup/04_compile_program_units.sql`
6. `infra/oracle/setup/05_grants_for_testing.sql`

## Instrucciones de validacion

Despues de compilar, correr en este orden:

1. `infra/oracle/test/01_test_fningestacdpcp.sql`
2. `infra/oracle/test/02_test_spbitacorabnpl.sql`
3. `infra/oracle/test/03_test_fnatprls0432.sql`

Validaciones minimas esperadas:
- caso exitoso con dia unico
- caso de bitacora de bloqueos con comportamiento legacy preservado
- caso sin `CENCLIENTETIENDA` con respuesta `NOT_FOUND`
- caso exitoso con periodicidad quincenal
- caso de capacidades mal formadas
- caso de bloqueos mal formados
- caso puente desde `FNATPRLS0432`

## Politica de errores en V1.0

Los SPs modulares levantan errores con `RAISE_APPLICATION_ERROR` cuando detectan fallas tecnicas o de formato.

Codigos usados:
- `-20503` bloqueos invalidos
- `-20504` informacion previa no encontrada
- `-20506` dias de pago invalidos
- `-20507` capacidades invalidas
- `-20509` error de persistencia de bloqueos
- `-20510` error de persistencia de linea gestora
- `-20511` error de persistencia de dias de pago
- `-20512` error de persistencia de capacidades

La funcion `FNINGESTACDPCP` es la unica que:
- hace `ROLLBACK`
- traduce a `CODIGO/MENSAJE`
- conserva la compatibilidad del contrato final

## Regla operativa para el equipo

- No introducir nuevas validaciones de negocio en `V1.0` si cambian semantica observable
- No corregir hallazgos funcionales sin aprobacion explicita de negocio
- No agregar `COMMIT` o `ROLLBACK` dentro de SPs
- No cambiar el orden de ejecucion de los componentes
- No cambiar el contrato de salida del cursor

## Pendientes para V1.1

Antes de construir `V1.1`, confirmar con negocio:
- si un bloqueo ausente en la cadena debe persistirse con `FIIDSTATUS = 0`
- si producto sin mapeo debe ser error funcional
- si periodicidad distinta de `1`, `13`, `14` debe fallar
- si `CENLINEADECREDITO` debe actualizar sucursal gestora cuando la fila ya existe
- si cadena vacia de bloqueos significa limpiar o no tocar estado