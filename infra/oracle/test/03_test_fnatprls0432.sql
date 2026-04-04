set serveroutput on

prompt =====================================
prompt CASO 1: ALTA EXITOSA
prompt =====================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_resultado VARCHAR2(10);
    v_detalle VARCHAR2(200);
BEGIN
    v_cursor := RCREDITO.FNATPRLS0432(1, 1, 10, 3001, 25, 'LOCALTEST');
    FETCH v_cursor INTO v_resultado, v_detalle;
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('CASO 1 RESULTADO=' || v_resultado || ' DETALLE=' || v_detalle);
END;
/

SELECT FIPAIS, FICANAL, FISUCURSAL, FIFOLIO, FIINTPAGADOS, FINIVEL, FCUSUARIOACTUALIZA
  FROM RCREDITO.TANIVELCLIENTE
 WHERE FIPAIS = 1 AND FICANAL = 1 AND FISUCURSAL = 10 AND FIFOLIO = 3001;

prompt =====================================
prompt CASO 2: MODIFICACION EXITOSA
prompt =====================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_resultado VARCHAR2(10);
    v_detalle VARCHAR2(200);
BEGIN
    v_cursor := RCREDITO.FNATPRLS0432(1, 1, 10, 3001, 65, 'LOCALTEST2');
    FETCH v_cursor INTO v_resultado, v_detalle;
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('CASO 2 RESULTADO=' || v_resultado || ' DETALLE=' || v_detalle);
END;
/

SELECT FIPAIS, FICANAL, FISUCURSAL, FIFOLIO, FIINTPAGADOS, FINIVEL, FCUSUARIOACTUALIZA
  FROM RCREDITO.TANIVELCLIENTE
 WHERE FIPAIS = 1 AND FICANAL = 1 AND FISUCURSAL = 10 AND FIFOLIO = 3001;

prompt =====================================
prompt CASO 3: USUARIO INVALIDO
prompt =====================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_resultado VARCHAR2(10);
    v_detalle VARCHAR2(200);
BEGIN
    v_cursor := RCREDITO.FNATPRLS0432(1, 1, 10, 3002, 10, '0');
    FETCH v_cursor INTO v_resultado, v_detalle;
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('CASO 3 RESULTADO=' || v_resultado || ' DETALLE=' || v_detalle);
END;
/

prompt =====================================
prompt CASO 4: PUENTE A INGESTA SIN IMPACTAR TANIVELCLIENTE
prompt =====================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_resultado VARCHAR2(10);
    v_detalle VARCHAR2(300);
BEGIN
    v_cursor := RCREDITO.FNATPRLS0432(
        1,
        1,
        10,
        1001,
        NULL,
        NULL,
        3,
        '104,115',
        1,
        99,
        999,
        13,
        '15,30',
        '{24,2000,1500|21,600,300}'
    );

    FETCH v_cursor INTO v_resultado, v_detalle;
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('CASO 4 RESULTADO=' || v_resultado || ' DETALLE=' || v_detalle);
END;
/

SELECT COUNT(*) AS TANIVELCLIENTE_1001
    FROM RCREDITO.TANIVELCLIENTE
 WHERE FIPAIS = 1 AND FICANAL = 1 AND FISUCURSAL = 10 AND FIFOLIO = 1001;

SELECT FIPAIS, FICANAL, FISUCURSAL, FIFOLIO, FNCAPACIDADPAGO, FNCAPACIDADPAGODISP
  FROM RCREDITO.CREDLINEADECREDITO
 WHERE FIPAIS = 1 AND FICANAL = 1 AND FISUCURSAL = 10 AND FIFOLIO = 1001;