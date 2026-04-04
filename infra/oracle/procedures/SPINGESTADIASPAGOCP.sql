CREATE OR REPLACE PROCEDURE SPINGESTADIASPAGOCP(
    PA_IDPAIS           IN NUMBER,
    PA_IDCANAL          IN NUMBER,
    PA_IDSUCURSAL       IN NUMBER,
    PA_IDFOLIO          IN NUMBER,
    PA_STSID_EXTERNO    IN NUMBER,
    PA_PERPAGOID        IN NUMBER,
    PA_PERPAGOSDIAS     IN VARCHAR2
)
IS
    VL_DIA1DP NUMBER;
    VL_DIA2DP NUMBER;
    VL_DIAMDP NUMBER;
    VL_CADENADP VARCHAR2(50) := PA_PERPAGOSDIAS;
BEGIN
    IF PA_PERPAGOID = 1 THEN
        VL_DIA1DP := TO_NUMBER(TRIM(VL_CADENADP));

        UPDATE RCREDITO.TARCLLINFOCUENTACLIENTE
           SET FIDIAPAGO = VL_DIA1DP
         WHERE FIPAIS = PA_IDPAIS
           AND FICANAL = PA_IDCANAL
           AND FISUCURSAL = PA_IDSUCURSAL
           AND FIFOLIO = PA_IDFOLIO;

        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO RCREDITO.TARCLLINFOCUENTACLIENTE (
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
            VALUES (
                PA_IDPAIS,
                PA_IDCANAL,
                PA_IDSUCURSAL,
                PA_IDFOLIO,
                ' ',
                0,
                VL_DIA1DP,
                0,
                ' ',
                ' ',
                SYSDATE
            );
        END IF;
    ELSIF PA_PERPAGOID = 13 THEN
        VL_DIA1DP := TO_NUMBER(TRIM(REGEXP_SUBSTR(VL_CADENADP, '[^,]+', 1, 1)));
        VL_DIA2DP := TO_NUMBER(TRIM(REGEXP_SUBSTR(VL_CADENADP, '[^,]+', 1, 2)));

        UPDATE RCREDITO.TADIAPAGOQM
           SET FNPERIODO = PA_PERPAGOID,
               FNDIAQ1 = VL_DIA1DP,
               FNDIAQ2 = VL_DIA2DP,
               FNDIAM = 0,
               FISTATUS = PA_STSID_EXTERNO,
               FCUSUARIOACTUALIZA = USER,
               FDFECHAACTUALIZA = SYSDATE
         WHERE FIPAIS = PA_IDPAIS
           AND FICANAL = PA_IDCANAL
           AND FISUCURSAL = PA_IDSUCURSAL
           AND FIFOLIO = PA_IDFOLIO;

        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO RCREDITO.TADIAPAGOQM (
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
            VALUES (
                PA_IDPAIS,
                PA_IDCANAL,
                PA_IDSUCURSAL,
                PA_IDFOLIO,
                PA_PERPAGOID,
                VL_DIA1DP,
                VL_DIA2DP,
                0,
                SYSDATE,
                PA_STSID_EXTERNO,
                USER,
                SYSDATE,
                NULL,
                NULL
            );
        END IF;
    ELSIF PA_PERPAGOID = 14 THEN
        VL_DIAMDP := TO_NUMBER(TRIM(VL_CADENADP));

        UPDATE RCREDITO.TADIAPAGOQM
           SET FNPERIODO = PA_PERPAGOID,
               FNDIAQ1 = 0,
               FNDIAQ2 = 0,
               FNDIAM = VL_DIAMDP,
               FISTATUS = PA_STSID_EXTERNO,
               FCUSUARIOACTUALIZA = USER,
               FDFECHAACTUALIZA = SYSDATE
         WHERE FIPAIS = PA_IDPAIS
           AND FICANAL = PA_IDCANAL
           AND FISUCURSAL = PA_IDSUCURSAL
           AND FIFOLIO = PA_IDFOLIO;

        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO RCREDITO.TADIAPAGOQM (
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
            VALUES (
                PA_IDPAIS,
                PA_IDCANAL,
                PA_IDSUCURSAL,
                PA_IDFOLIO,
                PA_PERPAGOID,
                0,
                0,
                VL_DIAMDP,
                SYSDATE,
                PA_STSID_EXTERNO,
                'USER',
                SYSDATE,
                NULL,
                NULL
            );
        END IF;
    END IF;
EXCEPTION
    WHEN VALUE_ERROR THEN
        RAISE_APPLICATION_ERROR(-20506, 'FORMATO_INVALIDO_DIAS_PAGO');
    WHEN OTHERS THEN
        IF SQLCODE BETWEEN -20999 AND -20000 THEN
            RAISE;
        END IF;

        RAISE_APPLICATION_ERROR(-20511, SUBSTR(SQLERRM, 1, 200));
END SPINGESTADIASPAGOCP;
/