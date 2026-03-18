create FUNCTION          FNINGESTACDPCP(
    PA_IDPAIS  IN NUMBER,
    PA_IDCANAL  IN NUMBER,
    PA_IDSUCURSAL  IN NUMBER,
    PA_IDFOLIO  IN NUMBER,
    PA_STSID IN NUMBER,
    PA_BLOQUEOS IN VARCHAR2,
    PA_GESTPAISID IN NUMBER,
    PA_GESTCANALID IN NUMBER,
    PA_GESTSUCURSALID IN NUMBER,
    PA_PERPAGOID  IN NUMBER,
    PA_PERPAGOSDIAS IN VARCHAR2,
    PA_CAPACIDADESPGO IN VARCHAR2)

RETURN SYS_REFCURSOR
IS
    /***************************************************************************
    Proyecto: TAZ CP
    Descripción: Inserta datos de la capacidad de pago
    Creador: Yovani Bahena
    Fecha creado: 18/02/2026
    ***************************************************************************/

    -- CONSTANTES
    CSL_0                CONSTANT SIMPLE_INTEGER    := 0;
    CSL_1                CONSTANT SIMPLE_INTEGER    := 1;

    -- VARIABLES
    VL_FIDIAPAGOUNICO NUMBER(1,0) := 0;
    VL_FILOCALIZACION NUMBER(1,0) := 0;
    VL_FILISTANEGRA   NUMBER(1,0) := 0;
    VL_FIRMD          NUMBER(1,0) := 0;
    VL_FILEGAL        NUMBER(1,0) := 0;
    VL_FIDIFICILCOBRO NUMBER(1,0) := 0;
    VL_FIPCJ          NUMBER(1,0) := 0;

    VL_STSID             NUMBER(1,0);
    VL_FINGCIOID         NUMBER(5,0);
    VL_FINOTIENDA        NUMBER(5,0);
    VL_FICTEID           NUMBER(10,0);
    VL_FIDIGITOVER       NUMBER(5,0);
    VL_CODE  NUMBER :=0;
    VL_MESSAGE  VARCHAR(300) :='ÉXITO';
    VL_CODERR  NUMBER :=1;
    VL_MESSAGERR  VARCHAR(200);
    VL_MESSAGERRNF VARCHAR(20) :='NOT_FOUND';
    CUR_SALIDA  SYS_REFCURSOR;

    --TYPE PARA EL LISTADO DE DÍAS DE PAGO
    V_CADENADP           VARCHAR2(50) := PA_PERPAGOSDIAS;

    VL_DIA1DP NUMBER;
    VL_DIA2DP NUMBER;
    VL_DIAMDP NUMBER;

    --TYPE PARA LISTADO DE VALORES MOTIVOS
    -- Lista valores cadena
    TYPE TYP_LISTAMOTBLQ IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    VL_LISTAMOTBLQ TYP_LISTAMOTBLQ;
    VL_COUNTBLOQUEO PLS_INTEGER := 0;

    -- TABLAS PARA GUARDADO DE MOTIVOS Y STATUS DE BLOQUEO
    --TABLA PARA GUARDAR BLOQUEOS
    TYPE TYP_VALORES IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    --TABLA PARA GUARDAR STATUS
    TYPE TYP_STATUS  IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

    --DECLARA VARIABLE TIPO TABLA DE VALORES BLOQUEO
    VL_VLRBLQORIG TYP_VALORES;
    --DECLARA VARIABLE TIPO TABLA DE STATUS BLOQUEO
    VL_STATUSORIG  TYP_STATUS;
    --VARIABLE PARA GUARDAR EL TOTAL DE DATOS EN EL ARREGLO
    VL_COUNTORIG PLS_INTEGER := 0;

    VL_BLOQUEO NUMBER;
    VL_POSICION   NUMBER := 1;
    VL_CADENABLQS VARCHAR2(4000):=PA_BLOQUEOS;

    --LECTURA DE CADENA DE CAPACIDADES DE PAGO
    VL_CADENACDP   VARCHAR2(4000);
    VL_ARRXPRODUCTO    VARCHAR2(200);
    VL_PRODUCTOID NUMBER(5);
    VL_CAPTOTAL NUMBER(15,2);
    VL_CAPDISP NUMBER(15,2);
    VL_CONSEQCDP NUMBER := 1;
    VL_ORIGEN NUMBER(3);

    -- Devuelve último status o NULL si no existe
    FUNCTION FNULTIMOSTSBLQ(p_valor NUMBER) RETURN NUMBER IS
    BEGIN
        FOR i IN 1 .. VL_COUNTORIG LOOP
            IF VL_VLRBLQORIG(i) = p_valor THEN
                RETURN VL_STATUSORIG(i);
            END IF;
        END LOOP;
        RETURN NULL;
    END;

    -- Valida si valor viene en cadena
    FUNCTION FNVALIDAEXISTBLQ(p_valor NUMBER) RETURN BOOLEAN IS
    BEGIN
        FOR i IN 1 .. VL_COUNTBLOQUEO LOOP
            IF VL_LISTAMOTBLQ(i) = p_valor THEN
                RETURN TRUE;
            END IF;
        END LOOP;
        RETURN FALSE;
    END;

BEGIN
    --QUITA LLAVES {} DE LA CADENA
    VL_CADENACDP:= REPLACE(REPLACE(PA_CAPACIDADESPGO,'{',''),'}','');

    CASE PA_STSID
        WHEN 0 THEN VL_STSID := 3;
        WHEN 1 THEN VL_STSID := 0;
        WHEN 2 THEN VL_STSID := 9;
        WHEN 3 THEN VL_STSID := 1;
        WHEN 4 THEN VL_STSID := 3;
        WHEN 5 THEN VL_STSID := 9;
    END CASE;

    --SEPARACIÓN DE CADENA 
    LOOP
        VL_BLOQUEO := TO_NUMBER(REGEXP_SUBSTR(VL_CADENABLQS, '[^,]+', 1, VL_POSICION));
        EXIT WHEN VL_BLOQUEO IS NULL;

        VL_COUNTBLOQUEO := VL_COUNTBLOQUEO + 1;
        VL_LISTAMOTBLQ(VL_COUNTBLOQUEO) := VL_BLOQUEO;

        VL_POSICION := VL_POSICION + 1;
    END LOOP;

    --ASIGNA VALORES PARA CREDLINEADECREDITO
    FOR i IN 1 .. VL_LISTAMOTBLQ.COUNT LOOP

        CASE VL_LISTAMOTBLQ(i)
            WHEN 104 THEN vl_fidiapagounico := 1;
            WHEN 115 THEN vl_filocalizacion := 1;
            WHEN 114 THEN vl_filistanegra := 1;
            WHEN 116 THEN vl_firmd := 1;
            WHEN 117 THEN vl_filegal := 1;
            WHEN 118 THEN vl_fidificilcobro := 1;
            WHEN 119 THEN vl_fipcj := 1;
        END CASE;
    END LOOP;

    --RESERVA LOS VALORES ORIGINALES DE LOS MOTIVOS EN LA BITÁCORA

    FOR r IN (
        SELECT FIIDBLOQUEO,FIIDSTATUS
        FROM (
            SELECT FIIDBLOQUEO,
                   FIIDSTATUS,
                   ROW_NUMBER() OVER (PARTITION BY FIIDBLOQUEO ORDER BY FDPROCESO DESC) rn
            FROM RCREDITO.TACRBITCAMBIOSLCR
            WHERE FIPAIS     = PA_IDPAIS
              AND FICANAL    = PA_IDCANAL
              AND FISUCURSAL = PA_IDSUCURSAL
              AND FIFOLIO    = PA_IDFOLIO
        )
        WHERE rn = 1
    ) LOOP
        VL_COUNTORIG := VL_COUNTORIG + 1;
        VL_VLRBLQORIG(VL_COUNTORIG) := r.FIIDBLOQUEO;
        VL_STATUSORIG(VL_COUNTORIG)  := r.FIIDSTATUS;

        DBMS_OUTPUT.PUT_LINE('yyyFIIDBLOQUEO '||VL_STATUSORIG(VL_COUNTORIG));

    END LOOP;

    --INSERTAR EN 1 LOS BLOQUEOS RECIBIDOS SI ESTABAN EN STATUS 0, O SI NO EXISTÍAN
    FOR i IN 1 .. VL_COUNTBLOQUEO LOOP

        DBMS_OUTPUT.PUT_LINE('**VL_COUNTBLOQUEO  '||VL_COUNTBLOQUEO);

        DECLARE
            v_status NUMBER;
        BEGIN
            v_status := FNULTIMOSTSBLQ(VL_LISTAMOTBLQ(i));

            DBMS_OUTPUT.PUT_LINE('$$v_status  '||v_status);
DBMS_OUTPUT.PUT_LINE('$$v_status  ZZZZZZZZZZZZZZZZZZZZZZZZZZZ'||v_status);
            -- Caso 1: No existe en bitácora
            IF v_status IS NULL THEN

            DBMS_OUTPUT.PUT_LINE('$$FIIDBLOQUEO NULL  XXXXXXXXXXXXXXXXXXXXXXXXXXX'||VL_LISTAMOTBLQ(i));


                 INSERT INTO RCREDITO.TACRBITCAMBIOSLCR (FIPAIS,
                                                        FICANAL,
                                                        FISUCURSAL,
                                                        FIFOLIO,
                                                        FIIDBLOQUEO,
                                                        FIIDSTATUS,
                                                        FDPROCESO,
                                                        FISTATCRED,
                                                        FISTATCEN,
                                                        FINOPEDIDO,
                                                        FCEMPLEADO,
                                                        FCPUESTO,
                                                        FITRANNO,
                                                        FCTRANWS,
                                                        FCTRANUSR,
                                                        FCAPLICACION)
                VALUES(PA_IDPAIS,
                       PA_IDCANAL,
                       PA_IDSUCURSAL,
                       PA_IDFOLIO,
                       VL_LISTAMOTBLQ(i),
                       1,
                       SYSDATE,
                       VL_STSID,
                       PA_STSID,
                       0,
                       USER,
                       'SYS',
                       0,
                       'SERVER',
                       USER,
                       'SERVER');

            -- Caso 2: Existía pero estaba en 0
            ELSIF v_status = 0 THEN

            DBMS_OUTPUT.PUT_LINE('$$FIIDBLOQUEO CERO  '||VL_LISTAMOTBLQ(i));

                 INSERT INTO RCREDITO.TACRBITCAMBIOSLCR (FIPAIS,
                                                        FICANAL,
                                                        FISUCURSAL,
                                                        FIFOLIO,
                                                        FIIDBLOQUEO,
                                                        FIIDSTATUS,
                                                        FDPROCESO,
                                                        FISTATCRED,
                                                        FISTATCEN,
                                                        FINOPEDIDO,
                                                        FCEMPLEADO,
                                                        FCPUESTO,
                                                        FITRANNO,
                                                        FCTRANWS,
                                                        FCTRANUSR,
                                                        FCAPLICACION)
                VALUES(PA_IDPAIS,
                       PA_IDCANAL,
                       PA_IDSUCURSAL,
                       PA_IDFOLIO,
                       VL_LISTAMOTBLQ(i),
                       1,
                       SYSDATE,
                       VL_STSID,
                       PA_STSID,
                       0,
                       USER,
                       'SYS',
                       0,
                       'SERVER',
                       USER,
                       'SERVER');

            -- Caso 3: Ya estaba en 1, no se procesa
            END IF;

        END;

    END LOOP;

    --INSERTA EN 0 LOS QUE ESTÉN EN STATUS 1 Y NO VENGAN EN LA CADENA
    FOR i IN 1 .. VL_COUNTORIG LOOP

        IF VL_STATUSORIG(i) = 1 THEN

            IF NOT FNVALIDAEXISTBLQ(VL_VLRBLQORIG(i)) THEN
                INSERT INTO RCREDITO.TACRBITCAMBIOSLCR (FIPAIS,
                                                        FICANAL,
                                                        FISUCURSAL,
                                                        FIFOLIO,
                                                        FIIDBLOQUEO,
                                                        FIIDSTATUS,
                                                        FDPROCESO,
                                                        FISTATCRED,
                                                        FISTATCEN,
                                                        FINOPEDIDO,
                                                        FCEMPLEADO,
                                                        FCPUESTO,
                                                        FITRANNO,
                                                        FCTRANWS,
                                                        FCTRANUSR,
                                                        FCAPLICACION)
                VALUES(PA_IDPAIS,
                       PA_IDCANAL,
                       PA_IDSUCURSAL,
                       PA_IDFOLIO,
                       VL_VLRBLQORIG(i),
                       1,
                       SYSDATE,
                       VL_STSID,
                       PA_STSID,
                       0,
                       USER,
                       'SYS',
                       0,
                       'SERVER',
                       USER,
                       'SERVER');
            END IF;

        END IF;

    END LOOP;

    ----------------------------------------------------------------------
    -- INSERTA DATOS DE SUCURSAL GESTORA Y STATUS
    ----------------------------------------------------------------------

   SELECT  FINGCIOID,FINOTIENDA,FICTEID,FIDIGITOVER
    INTO VL_FINGCIOID,VL_FINOTIENDA,VL_FICTEID,VL_FIDIGITOVER
    FROM (SELECT FINGCIOID,FINOTIENDA,FICTEID,FIDIGITOVER
            FROM RCREDITO.CENCLIENTETIENDA
            WHERE FIPAIS = PA_IDPAIS
              AND FICANAL = PA_IDCANAL
              AND FISUCURSAL = PA_IDSUCURSAL
              AND FIFOLIO = PA_IDFOLIO
              ORDER BY FDFECHA DESC)
    WHERE ROWNUM=1;

    UPDATE RCREDITO.CENLINEADECREDITO
        SET FISTATUS = PA_STSID,
            FINGCIOID = VL_FINGCIOID,
            FINOTIENDA = VL_FINOTIENDA,
            FICTEID = VL_FICTEID,
            FIDIGITOVER = VL_FIDIGITOVER,
            FDFECHAACT = SYSDATE
    WHERE FIPAIS     = PA_IDPAIS
          AND FICANAL    = PA_IDCANAL
          AND FISUCURSAL = PA_IDSUCURSAL
          AND FIFOLIO    = PA_IDFOLIO; 

    IF SQL%ROWCOUNT = 0 THEN          
        INSERT INTO RCREDITO.CENLINEADECREDITO (FIPAIS,
                                                FICANAL,
                                                FISUCURSAL,
                                                FIFOLIO ,
                                                FIPAISGESTOR,
                                                FICANALGESTOR,
                                                FISUCURSALGESTORA,
                                                FISTATUS,
                                                FDFECHAALTA,
                                                FDFECHAACT,
                                                FINGCIOID,
                                                FINOTIENDA,
                                                FICTEID,
                                                FIDIGITOVER,
                                                FISTSCU)
        VALUES(PA_IDPAIS,
               PA_IDCANAL,
               PA_IDSUCURSAL,
               PA_IDFOLIO,
               PA_GESTPAISID,
               PA_GESTCANALID,
               PA_GESTSUCURSALID,
               PA_STSID,
               SYSDATE,
               SYSDATE,
               VL_FINGCIOID,
               VL_FINOTIENDA,
               VL_FICTEID,
               VL_FIDIGITOVER,
               0);

    END IF;

    ----------------------------------------------------------------------
    --COMIENZA CICLO PARA EL DÍA DE PAGO   
    ----------------------------------------------------------------------

    IF PA_PERPAGOID = 1 THEN 

        VL_DIA1DP := TO_NUMBER(TRIM(V_CADENADP));

      UPDATE RCREDITO.TARCLLINFOCUENTACLIENTE
        SET FIDIAPAGO = VL_DIA1DP
      WHERE FIPAIS     = PA_IDPAIS
          AND FICANAL    = PA_IDCANAL
          AND FISUCURSAL = PA_IDSUCURSAL
          AND FIFOLIO    = PA_IDFOLIO; 

        IF SQL%ROWCOUNT = 0 THEN   

            INSERT INTO RCREDITO.TARCLLINFOCUENTACLIENTE(
                FIPAIS,
                FICANAL,
                FISUCURSAL,
                FIFOLIO,
                FCTARJETA,
                FIPLAZO,
                FIDIAPAGO,
                FNCAPACIDADPAGO,
                FCCORREO,
                FCNOCELULAR,
                FDFECHA
            )
            VALUES(PA_IDPAIS,
               PA_IDCANAL,
               PA_IDSUCURSAL,
               PA_IDFOLIO,
                ' ',
                0,
                VL_DIA1DP,   -- aquí insertas el valor leído
                0,
                ' ',
                ' ',
                SYSDATE);

        END IF;

    ELSIF PA_PERPAGOID = 13 THEN 

        VL_DIA1DP := TO_NUMBER(TRIM(REGEXP_SUBSTR(V_CADENADP, '[^,]+', 1, 1)));
        VL_DIA2DP := TO_NUMBER(TRIM(REGEXP_SUBSTR(V_CADENADP, '[^,]+', 1, 2)));

        UPDATE RCREDITO.TADIAPAGOQM
         SET FNPERIODO = PA_PERPAGOID,
             FNDIAQ1 = VL_DIA1DP,
             FNDIAQ2 = VL_DIA2DP,
             FNDIAM = 0,
             FISTATUS = PA_STSID,
             FCUSUARIOACTUALIZA = USER,
             FDFECHAACTUALIZA = SYSDATE
        WHERE FIPAIS     = PA_IDPAIS
          AND FICANAL    = PA_IDCANAL
          AND FISUCURSAL = PA_IDSUCURSAL
          AND FIFOLIO    = PA_IDFOLIO; 

        IF SQL%ROWCOUNT = 0 THEN

            INSERT INTO RCREDITO.TADIAPAGOQM(
                FIPAIS,
                FICANAL,
                FISUCURSAL,
                FIFOLIO,
                FNPERIODO,
                FNDIAQ1,
                FNDIAQ2,
                FNDIAM,
                FDFECHAREG,
                FISTATUS,
                FCUSUARIOACTUALIZA,
                FDFECHAACTUALIZA,
                FITIPOPAGOID,
                FIDIAS
            )
            VALUES(
                PA_IDPAIS,
                PA_IDCANAL,
                PA_IDSUCURSAL,
                PA_IDFOLIO,
                PA_PERPAGOID,
                VL_DIA1DP,   -- primer valor
                VL_DIA2DP,   -- segundo valor
                0,
                SYSDATE,
                PA_STSID,
                USER,
                SYSDATE,
                NULL,
                NULL
            );
        END IF;

    ELSIF PA_PERPAGOID = 14 THEN 

        VL_DIAMDP := TO_NUMBER(TRIM(V_CADENADP));

        UPDATE RCREDITO.TADIAPAGOQM
         SET FNPERIODO = PA_PERPAGOID,
             FNDIAQ1 = 0,
             FNDIAQ2 = 0,
             FNDIAM = VL_DIAMDP,
             FISTATUS = PA_STSID,
             FCUSUARIOACTUALIZA = USER,
             FDFECHAACTUALIZA = SYSDATE
        WHERE FIPAIS     = PA_IDPAIS
          AND FICANAL    = PA_IDCANAL
          AND FISUCURSAL = PA_IDSUCURSAL
          AND FIFOLIO    = PA_IDFOLIO;

        IF SQL%ROWCOUNT = 0 THEN

                INSERT INTO RCREDITO.TADIAPAGOQM(
                    FIPAIS,
                    FICANAL,
                    FISUCURSAL,
                    FIFOLIO,
                    FNPERIODO,
                    FNDIAQ1,
                    FNDIAQ2,
                    FNDIAM,
                    FDFECHAREG,
                    FISTATUS,
                    FCUSUARIOACTUALIZA,
                    FDFECHAACTUALIZA,
                    FITIPOPAGOID,
                    FIDIAS
                )
                VALUES(
                    PA_IDPAIS,
                    PA_IDCANAL,
                    PA_IDSUCURSAL,
                    PA_IDFOLIO,
                    PA_PERPAGOID,
                    0,
                    0,
                    VL_DIAMDP,
                    SYSDATE,
                    PA_STSID,
                    'USER',
                    SYSDATE,
                    NULL,
                    NULL);
        END IF;

    END IF;


    ------------------------------------------------------------------------------
    --GUARDADO DE CAPACIDADES DE PAGO POR PRODUCTO
    --LECTURA DE CADENA DE CAPACIDADES DE PAGO
    ------------------------------------------------------------------------------

    LOOP
        -- obtener cada grupo separado por |
        VL_ARRXPRODUCTO := REGEXP_SUBSTR(VL_CADENACDP,'[^|]+',1,VL_CONSEQCDP);
        EXIT WHEN VL_ARRXPRODUCTO IS NULL;

        -- obtener los 3 valores
        VL_PRODUCTOID := REGEXP_SUBSTR(VL_ARRXPRODUCTO,'[^,]+',1,1);
        VL_CAPTOTAL := REGEXP_SUBSTR(VL_ARRXPRODUCTO,'[^,]+',1,2);
        VL_CAPDISP := REGEXP_SUBSTR(VL_ARRXPRODUCTO,'[^,]+',1,3);

        DBMS_OUTPUT.PUT_LINE('VL_PRODUCTOID ANTESSSS '||VL_PRODUCTOID);
        CASE VL_PRODUCTOID
            WHEN 21 THEN VL_ORIGEN := 1;
            WHEN 22 THEN VL_ORIGEN := 4;
            WHEN 23 THEN VL_ORIGEN := 5;
            WHEN 24 THEN VL_ORIGEN := 2;
            WHEN 25 THEN VL_ORIGEN := 3;
            WHEN 10 THEN VL_ORIGEN := 10;
            WHEN 34 THEN VL_ORIGEN := 34;
        END CASE;

        DBMS_OUTPUT.PUT_LINE('VL_ORIGEN DESPUÉSSS '||VL_PRODUCTOID);

        --INSERTA CDP TOTAL Y DISPONIBLE SI EL PRODUCTO ES 24 (ORIGEN=2)
        IF VL_ORIGEN = 2 THEN 

             UPDATE RCREDITO.CREDLINEADECREDITO
              SET FNCAPACIDADPAGO      = VL_CAPTOTAL,
                  FNCAPACIDADPAGODISP  = VL_CAPDISP,
                  FIDIAPAGOUNICO       = VL_FIDIAPAGOUNICO,
                  FDFECHAULTACT        = SYSDATE,
                  FISTATUS             = VL_STSID,
                  FILISTANEGRA         = VL_FILISTANEGRA,
                  FILOCALIZACION       = VL_FILOCALIZACION,
                  FIRMD                = VL_FIRMD,
                  FILEGAL              = VL_FILEGAL,
                  FIDIFICILCOBRO       = VL_FIDIFICILCOBRO,
                  FIPCJ                = VL_FIPCJ
            WHERE FIPAIS     = PA_IDPAIS
              AND FICANAL    = PA_IDCANAL
              AND FISUCURSAL = PA_IDSUCURSAL
              AND FIFOLIO    = PA_IDFOLIO; 

            IF SQL%ROWCOUNT = 0 THEN

                INSERT INTO RCREDITO.CREDLINEADECREDITO (FIPAIS,
                                                        FICANAL,
                                                        FISUCURSAL,
                                                        FIFOLIO,
                                                        FNCAPACIDADPAGO,
                                                        FNCAPACIDADPAGODISP,
                                                        FNMONTOLCR,
                                                        FIPLAZOMAX,
                                                        FNENGANCHE1COMPRA,
                                                        FIDIAPAGOUNICO,
                                                        FISTATUSAUTORIZACION,
                                                        FDFECHAULTACT,
                                                        FDFECHAULTAUT,
                                                        FISTATUS,
                                                        FITRANNO,
                                                        FILISTANEGRA,
                                                        FILOCALIZACION,
                                                        FIRMD,
                                                        FILEGAL,
                                                        FIDIFICILCOBRO,
                                                        FIACEPTAPP,
                                                        FNSUMSALDO,
                                                        FICOMPRAS,
                                                        FDFECHAALTACREDITO,
                                                        FIPCJ)
                VALUES(PA_IDPAIS,
                        PA_IDCANAL,
                        PA_IDSUCURSAL,
                        PA_IDFOLIO,
                        VL_CAPTOTAL,
                        VL_CAPDISP,
                        0,
                        0,
                        0,
                        VL_FIDIAPAGOUNICO,
                        0,
                        SYSDATE,
                        SYSDATE,
                        VL_STSID,
                        0,
                        VL_FILISTANEGRA,
                        VL_FILOCALIZACION,
                        VL_FIRMD,
                        VL_FILEGAL,
                        VL_FIDIFICILCOBRO,
                        0,
                        0,
                        0,
                        SYSDATE,
                        VL_FIPCJ
                        );
            END IF;

        END IF;

        UPDATE RCREDITO.TACRCAPMAXPROD 
             SET FICAPACIDAD = VL_CAPTOTAL,
                 FDULTIMA_MODIFICACION= SYSDATE,
                 FCUSUARIO_MODIFICO = USER
            WHERE FIPAIS     = PA_IDPAIS
                  AND FICANAL    = PA_IDCANAL
                  AND FISUCURSAL = PA_IDSUCURSAL
                  AND FIFOLIO    = PA_IDFOLIO
                  AND FIORIGENID = VL_ORIGEN;

            IF SQL%ROWCOUNT = 0 THEN

                INSERT INTO RCREDITO.TACRCAPMAXPROD (FIPAIS,
                                                    FICANAL,
                                                    FISUCURSAL,
                                                    FIFOLIO,
                                                    FIORIGENID,
                                                    FICAPACIDAD,
                                                    FIESACTIVA,
                                                    FITRANO,
                                                    FICANALTRANO,
                                                    FISUCURSALTRANO,
                                                    FDULTIMA_MODIFICACION,
                                                    FCUSUARIO_MODIFICO)
                VALUES (PA_IDPAIS,
                        PA_IDCANAL,
                        PA_IDSUCURSAL,
                        PA_IDFOLIO,
                        VL_ORIGEN,
                        VL_CAPTOTAL,
                        0,
                        0,
                        PA_GESTCANALID,
                        PA_GESTSUCURSALID,
                        SYSDATE,
                        USER);
            END IF;

        VL_CONSEQCDP := VL_CONSEQCDP + 1;

    END LOOP;

COMMIT;    

    OPEN CUR_SALIDA FOR
            SELECT VL_CODE   CODIGO ,
                   VL_MESSAGE  MENSAJE
              FROM DUAL;

RETURN CUR_SALIDA;
EXCEPTION 
     WHEN NO_DATA_FOUND THEN
     ROLLBACK;

        OPEN CUR_SALIDA FOR
            SELECT VL_CODERR   CODIGO ,
                   VL_MESSAGERRNF  MENSAJE
              FROM DUAL;

    RETURN CUR_SALIDA;
     WHEN OTHERS THEN
        ROLLBACK;
        VL_MESSAGERR:= SUBSTR (SQLERRM ||' - ' ||
                               DBMS_UTILITY.FORMAT_ERROR_BACKTRACE ,1 ,200);
        OPEN CUR_SALIDA FOR
            SELECT VL_CODERR   CODIGO ,
                   VL_MESSAGERR  MENSAJE
              FROM DUAL;

        DBMS_OUTPUT.PUT_LINE('***************************  '||SQLERRM);
    RETURN CUR_SALIDA;
END FNINGESTACDPCP;
/

