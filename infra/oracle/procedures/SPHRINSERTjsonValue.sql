CREATE OR REPLACE PROCEDURE SPHRINSERTjsonValue(
    PA_JSON IN CLOB
) AS
BEGIN
insert into REGIONS (
                     REGION_CODE,
                     REGION_NAME,
                     REGIONAL_DIRECTOR,
                     TIMEZONE,
                     CURRENCY_CODE,
                     ACTIVE_FLAG,
                     CREATED_AT,
                     CREATED_BY
                     )
values (
        JSON_VALUE(PA_JSON,'$.region_code'             RETURNING VARCHAR2(10)),
        JSON_VALUE(PA_JSON,'$.region_name'             RETURNING VARCHAR2(100)),
        JSON_VALUE(PA_JSON,'$.regional_director' RETURNING VARCHAR2(100)),
        JSON_VALUE(PA_JSON,'$.timezone '                  RETURNING  VARCHAR2(50)),
        JSON_VALUE(PA_JSON,'$.currency_code'        RETURNING VARCHAR2(3)),
         COALESCE(JSON_VALUE(PA_JSON,'$.active_flag'    RETURNING  CHAR(1)),'Y'),
       JSON_VALUE(PA_JSON,'$.created_at'                RETURNING VARCHAR2 (50)),
       JSON_VALUE(PA_JSON,'$.created_by'                RETURNING VARCHAR2 (50))
       );
         COMMIT;
EXCEPTION
WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20001, 'REGION_CODE YA EXISTE (UNIQUE).');
WHEN VALUE_ERROR THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20002,'JSON INVALIDO O TIPOS INCOMPATIBLES');
WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20099,'ERROR INSERTANDO DESDE JSON:'|| SQLERRM );

END SPHRINSERTjsonValue;
/