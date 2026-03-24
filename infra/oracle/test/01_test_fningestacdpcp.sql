set serveroutput on

prompt =====================================
prompt CASO 1: INGESTA EXITOSA CON DIA UNICO
prompt =====================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_codigo NUMBER;
    v_mensaje VARCHAR2(300);
BEGIN
    v_cursor := RCREDITO.FNINGESTACDPCP(
        1,
        1,
        10,
        1001,
        3,
        '104,115,119',
        1,
        99,
        999,
        1,
        '15',
        '{24,1500,900|21,500,250}'
    );

    FETCH v_cursor INTO v_codigo, v_mensaje;
    CLOSE v_cursor;

    DBMS_OUTPUT.PUT_LINE('CASO 1 CODIGO=' || v_codigo || ' MENSAJE=' || v_mensaje);
END;
/

SELECT FIPAIS, FICANAL, FISUCURSAL, FIFOLIO, FNCAPACIDADPAGO, FNCAPACIDADPAGODISP, FIDIAPAGOUNICO, FILOCALIZACION, FIPCJ
  FROM RCREDITO.CREDLINEADECREDITO
 WHERE FIPAIS = 1 AND FICANAL = 1 AND FISUCURSAL = 10 AND FIFOLIO = 1001;

SELECT FIPAIS, FICANAL, FISUCURSAL, FIFOLIO, FIDIAPAGO
  FROM RCREDITO.TARCLLINFOCUENTACLIENTE
 WHERE FIPAIS = 1 AND FICANAL = 1 AND FISUCURSAL = 10 AND FIFOLIO = 1001;

SELECT FIORIGENID, FICAPACIDAD
  FROM RCREDITO.TACRCAPMAXPROD
 WHERE FIPAIS = 1 AND FICANAL = 1 AND FISUCURSAL = 10 AND FIFOLIO = 1001
 ORDER BY FIORIGENID;

prompt ======================================================
prompt CASO 2: VALIDACION DE BLOQUEO NO RECIBIDO EN CADENA
prompt ESPERADO SEGUN COMENTARIO: STATUS 0
prompt RESULTADO ACTUAL DEL CODIGO: INSERTA 1
prompt ======================================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_codigo NUMBER;
    v_mensaje VARCHAR2(300);
BEGIN
    v_cursor := RCREDITO.FNINGESTACDPCP(
        1,
        1,
        10,
        1002,
        3,
        '104',
        1,
        99,
        999,
        14,
        '28',
        '{24,1800,1200}'
    );

    FETCH v_cursor INTO v_codigo, v_mensaje;
    CLOSE v_cursor;

    DBMS_OUTPUT.PUT_LINE('CASO 2 CODIGO=' || v_codigo || ' MENSAJE=' || v_mensaje);
END;
/

SELECT FIIDBLOQUEO, FIIDSTATUS, FDPROCESO
  FROM RCREDITO.TACRBITCAMBIOSLCR
 WHERE FIPAIS = 1 AND FICANAL = 1 AND FISUCURSAL = 10 AND FIFOLIO = 1002
 ORDER BY FDPROCESO DESC;

prompt =====================================
prompt CASO 3: CLIENTE SIN CENCLIENTETIENDA
prompt =====================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_codigo NUMBER;
    v_mensaje VARCHAR2(300);
BEGIN
    v_cursor := RCREDITO.FNINGESTACDPCP(
        1,
        1,
        10,
        9999,
        3,
        '104',
        1,
        99,
        999,
        1,
        '15',
        '{24,100,50}'
    );

    FETCH v_cursor INTO v_codigo, v_mensaje;
    CLOSE v_cursor;

    DBMS_OUTPUT.PUT_LINE('CASO 3 CODIGO=' || v_codigo || ' MENSAJE=' || v_mensaje);
END;
/