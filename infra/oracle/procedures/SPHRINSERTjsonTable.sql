CREATE OR REPLACE PROCEDURE SPHRINSERTjsonTableRegions(
PA_JSON IN CLOB
)
AS
BEGIN
    INSERT INTO REGIONS ( REGION_CODE
                        , REGION_NAME
                        , REGIONAL_DIRECTOR
                        , TIMEZONE
                        , CURRENCY_CODE
                        , ACTIVE_FLAG
                        , CREATED_BY
                       ) SELECT
                               jt.region_code
                               ,jt.region_name
                               ,jt.regional_director
                               ,jt.timezone
                               ,jt.currency_code
                               ,nvl(jt.active_flag,'Y')
                               ,jt.CREATED_BY
                       FROM JSON_TABLE ( PA_JSON, '$' COLUMNS (    REGION_CODE        VARCHAR2(10) PATH '$.region_code'
                                                                  ,REGION_NAME       VARCHAR2(100) PATH '$.region_name'
                                                                  ,REGIONAL_DIRECTOR VARCHAR2(100) PATH '$.regional_director'
                                                                  ,TIMEZONE          VARCHAR2(50)  PATH '$.timezone'
                                                                  ,CURRENCY_CODE     VARCHAR2(3)   PATH '$.currency_code'
                                                                  ,ACTIVE_FLAG       CHAR(1)       PATH '$.active_flag'
                                                                  ,CREATED_BY        VARCHAR2(50)  PATH '$.created_by'
                       )
    ) jt;
    COMMIT;
EXCEPTION
WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK;
RAISE_APPLICATION_ERROR(-20001, 'REGION_CODE YA EXISTE(UNIQUE');
WHEN OTHERS THEN
     ROLLBACK;
RAISE_APPLICATION_ERROR(-20099, 'ERROR INSERTADO (JSON_TABLE): '|| SQLERRM);
END SPHRINSERTjsonTableRegions;


    ---=====










