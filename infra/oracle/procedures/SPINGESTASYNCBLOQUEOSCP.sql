CREATE OR REPLACE PROCEDURE SPINGESTASYNCBLOQUEOSCP(
    PA_IDPAIS           IN NUMBER,
    PA_IDCANAL          IN NUMBER,
    PA_IDSUCURSAL       IN NUMBER,
    PA_IDFOLIO          IN NUMBER,
    PA_STSID_EXTERNO    IN NUMBER,
    PA_STSID_INTERNO    IN NUMBER,
    PA_BLOQUEOS         IN VARCHAR2,
    PO_FIDIAPAGOUNICO   OUT NUMBER,
    PO_FILOCALIZACION   OUT NUMBER,
    PO_FILISTANEGRA     OUT NUMBER,
    PO_FIRMD            OUT NUMBER,
    PO_FILEGAL          OUT NUMBER,
    PO_FIDIFICILCOBRO   OUT NUMBER,
    PO_FIPCJ            OUT NUMBER
)
IS
    TYPE TYP_LISTAMOTBLQ IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    TYPE TYP_VALORES IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    TYPE TYP_STATUS IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

    VL_LISTAMOTBLQ TYP_LISTAMOTBLQ;
    VL_VLRBLQORIG TYP_VALORES;
    VL_STATUSORIG TYP_STATUS;

    VL_COUNTBLOQUEO PLS_INTEGER := 0;
    VL_COUNTORIG PLS_INTEGER := 0;
    VL_POSICION NUMBER := 1;
    VL_BLOQUEO NUMBER;
    VL_CADENABLQS VARCHAR2(4000) := PA_BLOQUEOS;

    FUNCTION FNULTIMOSTSBLQ(p_valor NUMBER) RETURN NUMBER IS
    BEGIN
        FOR i IN 1 .. VL_COUNTORIG LOOP
            IF VL_VLRBLQORIG(i) = p_valor THEN
                RETURN VL_STATUSORIG(i);
            END IF;
        END LOOP;

        RETURN NULL;
    END;

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
    PO_FIDIAPAGOUNICO := 0;
    PO_FILOCALIZACION := 0;
    PO_FILISTANEGRA := 0;
    PO_FIRMD := 0;
    PO_FILEGAL := 0;
    PO_FIDIFICILCOBRO := 0;
    PO_FIPCJ := 0;

    LOOP
        VL_BLOQUEO := TO_NUMBER(REGEXP_SUBSTR(VL_CADENABLQS, '[^,]+', 1, VL_POSICION));
        EXIT WHEN VL_BLOQUEO IS NULL;

        VL_COUNTBLOQUEO := VL_COUNTBLOQUEO + 1;
        VL_LISTAMOTBLQ(VL_COUNTBLOQUEO) := VL_BLOQUEO;
        VL_POSICION := VL_POSICION + 1;
    END LOOP;

    FOR i IN 1 .. VL_LISTAMOTBLQ.COUNT LOOP
        CASE VL_LISTAMOTBLQ(i)
            WHEN 104 THEN PO_FIDIAPAGOUNICO := 1;
            WHEN 115 THEN PO_FILOCALIZACION := 1;
            WHEN 114 THEN PO_FILISTANEGRA := 1;
            WHEN 116 THEN PO_FIRMD := 1;
            WHEN 117 THEN PO_FILEGAL := 1;
            WHEN 118 THEN PO_FIDIFICILCOBRO := 1;
            WHEN 119 THEN PO_FIPCJ := 1;
        END CASE;
    END LOOP;

    FOR r IN (
        SELECT FIIDBLOQUEO, FIIDSTATUS
          FROM (
            SELECT FIIDBLOQUEO,
                   FIIDSTATUS,
                   ROW_NUMBER() OVER (PARTITION BY FIIDBLOQUEO ORDER BY FDPROCESO DESC) rn
              FROM RCREDITO.TACRBITCAMBIOSLCR
             WHERE FIPAIS = PA_IDPAIS
               AND FICANAL = PA_IDCANAL
               AND FISUCURSAL = PA_IDSUCURSAL
               AND FIFOLIO = PA_IDFOLIO
        )
         WHERE rn = 1
    ) LOOP
        VL_COUNTORIG := VL_COUNTORIG + 1;
        VL_VLRBLQORIG(VL_COUNTORIG) := r.FIIDBLOQUEO;
        VL_STATUSORIG(VL_COUNTORIG) := r.FIIDSTATUS;
    END LOOP;

    FOR i IN 1 .. VL_COUNTBLOQUEO LOOP
        DECLARE
            VL_STATUS NUMBER;
        BEGIN
            VL_STATUS := FNULTIMOSTSBLQ(VL_LISTAMOTBLQ(i));

            IF VL_STATUS IS NULL OR VL_STATUS = 0 THEN
                INSERT INTO RCREDITO.TACRBITCAMBIOSLCR (
                    FIPAIS,
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
                    FCAPLICACION
                )
                VALUES (
                    PA_IDPAIS,
                    PA_IDCANAL,
                    PA_IDSUCURSAL,
                    PA_IDFOLIO,
                    VL_LISTAMOTBLQ(i),
                    1,
                    SYSDATE,
                    PA_STSID_INTERNO,
                    PA_STSID_EXTERNO,
                    0,
                    USER,
                    'SYS',
                    0,
                    'SERVER',
                    USER,
                    'SERVER'
                );
            END IF;
        END;
    END LOOP;

    FOR i IN 1 .. VL_COUNTORIG LOOP
        IF VL_STATUSORIG(i) = 1 THEN
            IF NOT FNVALIDAEXISTBLQ(VL_VLRBLQORIG(i)) THEN
                INSERT INTO RCREDITO.TACRBITCAMBIOSLCR (
                    FIPAIS,
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
                    FCAPLICACION
                )
                VALUES (
                    PA_IDPAIS,
                    PA_IDCANAL,
                    PA_IDSUCURSAL,
                    PA_IDFOLIO,
                    VL_VLRBLQORIG(i),
                    1,
                    SYSDATE,
                    PA_STSID_INTERNO,
                    PA_STSID_EXTERNO,
                    0,
                    USER,
                    'SYS',
                    0,
                    'SERVER',
                    USER,
                    'SERVER'
                );
            END IF;
        END IF;
    END LOOP;
EXCEPTION
    WHEN VALUE_ERROR THEN
        RAISE_APPLICATION_ERROR(-20503, 'FORMATO_INVALIDO_BLOQUEOS');
    WHEN OTHERS THEN
        IF SQLCODE BETWEEN -20999 AND -20000 THEN
            RAISE;
        END IF;

        RAISE_APPLICATION_ERROR(-20509, SUBSTR(SQLERRM, 1, 200));
END SPINGESTASYNCBLOQUEOSCP;
/