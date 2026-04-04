CREATE OR REPLACE PROCEDURE SPINGESTACAPACIDADESCP(
    PA_IDPAIS           IN NUMBER,
    PA_IDCANAL          IN NUMBER,
    PA_IDSUCURSAL       IN NUMBER,
    PA_IDFOLIO          IN NUMBER,
    PA_STSID_INTERNO    IN NUMBER,
    PA_GESTCANALID      IN NUMBER,
    PA_GESTSUCURSALID   IN NUMBER,
    PA_CAPACIDADESPGO   IN VARCHAR2,
    PA_FIDIAPAGOUNICO   IN NUMBER,
    PA_FILOCALIZACION   IN NUMBER,
    PA_FILISTANEGRA     IN NUMBER,
    PA_FIRMD            IN NUMBER,
    PA_FILEGAL          IN NUMBER,
    PA_FIDIFICILCOBRO   IN NUMBER,
    PA_FIPCJ            IN NUMBER
)
IS
    VL_CADENACDP VARCHAR2(4000);
    VL_ARRXPRODUCTO VARCHAR2(200);
    VL_PRODUCTOID NUMBER(5);
    VL_CAPTOTAL NUMBER(15, 2);
    VL_CAPDISP NUMBER(15, 2);
    VL_CONSEQCDP NUMBER := 1;
    VL_ORIGEN NUMBER(3);
BEGIN
    VL_CADENACDP := REPLACE(REPLACE(PA_CAPACIDADESPGO, '{', ''), '}', '');

    LOOP
        VL_ARRXPRODUCTO := REGEXP_SUBSTR(VL_CADENACDP, '[^|]+', 1, VL_CONSEQCDP);
        EXIT WHEN VL_ARRXPRODUCTO IS NULL;

        VL_PRODUCTOID := TO_NUMBER(REGEXP_SUBSTR(VL_ARRXPRODUCTO, '[^,]+', 1, 1));
        VL_CAPTOTAL := TO_NUMBER(REGEXP_SUBSTR(VL_ARRXPRODUCTO, '[^,]+', 1, 2));
        VL_CAPDISP := TO_NUMBER(REGEXP_SUBSTR(VL_ARRXPRODUCTO, '[^,]+', 1, 3));

        CASE VL_PRODUCTOID
            WHEN 21 THEN VL_ORIGEN := 1;
            WHEN 22 THEN VL_ORIGEN := 4;
            WHEN 23 THEN VL_ORIGEN := 5;
            WHEN 24 THEN VL_ORIGEN := 2;
            WHEN 25 THEN VL_ORIGEN := 3;
            WHEN 10 THEN VL_ORIGEN := 10;
            WHEN 34 THEN VL_ORIGEN := 34;
        END CASE;

        IF VL_ORIGEN = 2 THEN
            UPDATE RCREDITO.CREDLINEADECREDITO
               SET FNCAPACIDADPAGO = VL_CAPTOTAL,
                   FNCAPACIDADPAGODISP = VL_CAPDISP,
                   FIDIAPAGOUNICO = PA_FIDIAPAGOUNICO,
                   FDFECHAULTACT = SYSDATE,
                   FISTATUS = PA_STSID_INTERNO,
                   FILISTANEGRA = PA_FILISTANEGRA,
                   FILOCALIZACION = PA_FILOCALIZACION,
                   FIRMD = PA_FIRMD,
                   FILEGAL = PA_FILEGAL,
                   FIDIFICILCOBRO = PA_FIDIFICILCOBRO,
                   FIPCJ = PA_FIPCJ
             WHERE FIPAIS = PA_IDPAIS
               AND FICANAL = PA_IDCANAL
               AND FISUCURSAL = PA_IDSUCURSAL
               AND FIFOLIO = PA_IDFOLIO;

            IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO RCREDITO.CREDLINEADECREDITO (
                    FIPAIS,
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
                    FIPCJ
                )
                VALUES (
                    PA_IDPAIS,
                    PA_IDCANAL,
                    PA_IDSUCURSAL,
                    PA_IDFOLIO,
                    VL_CAPTOTAL,
                    VL_CAPDISP,
                    0,
                    0,
                    0,
                    PA_FIDIAPAGOUNICO,
                    0,
                    SYSDATE,
                    SYSDATE,
                    PA_STSID_INTERNO,
                    0,
                    PA_FILISTANEGRA,
                    PA_FILOCALIZACION,
                    PA_FIRMD,
                    PA_FILEGAL,
                    PA_FIDIFICILCOBRO,
                    0,
                    0,
                    0,
                    SYSDATE,
                    PA_FIPCJ
                );
            END IF;
        END IF;

        UPDATE RCREDITO.TACRCAPMAXPROD
           SET FICAPACIDAD = VL_CAPTOTAL,
               FDULTIMA_MODIFICACION = SYSDATE,
               FCUSUARIO_MODIFICO = USER
         WHERE FIPAIS = PA_IDPAIS
           AND FICANAL = PA_IDCANAL
           AND FISUCURSAL = PA_IDSUCURSAL
           AND FIFOLIO = PA_IDFOLIO
           AND FIORIGENID = VL_ORIGEN;

        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO RCREDITO.TACRCAPMAXPROD (
                FIPAIS,
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
                FCUSUARIO_MODIFICO
            )
            VALUES (
                PA_IDPAIS,
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
                USER
            );
        END IF;

        VL_CONSEQCDP := VL_CONSEQCDP + 1;
    END LOOP;
EXCEPTION
    WHEN VALUE_ERROR THEN
        RAISE_APPLICATION_ERROR(-20507, 'FORMATO_INVALIDO_CAPACIDADES');
    WHEN OTHERS THEN
        IF SQLCODE BETWEEN -20999 AND -20000 THEN
            RAISE;
        END IF;

        RAISE_APPLICATION_ERROR(-20512, SUBSTR(SQLERRM, 1, 200));
END SPINGESTACAPACIDADESCP;
/