set serveroutput on

prompt =====================================================
prompt CASO 1: INSERTA HEADER Y DETAIL SIN EJECUTAR INGESTA
prompt =====================================================

DECLARE
    v_respuesta VARCHAR2(4000);
BEGIN
    RCREDITO.SPBITACORABNPL(
        PA_TIPOMENSAJE => 'BNPL',
        PA_PAISCTE => 1,
        PA_CANALCTE => 1,
        PA_SUCURSALCTE => 10,
        PA_FOLIOCTE => 1001,
        PA_CODFECHA => '20260323',
        PA_PLATFORMID => 'APP',
        PA_SUBPLATFORMID => 'MOBILE',
        PA_SICU => 'SICU01',
        PA_PAISHEAD => 1,
        PA_CANALHEAD => 99,
        PA_SUCURSALHEAD => 999,
        PA_IP => '127.0.0.1',
        PA_USER => 'LOCALTEST',
        PA_COMERNAME => 'COMERCIO DEMO',
        PA_COMERAFIL => 'AFIL01',
        PA_COMERGIRO => 'RETAIL',
        PA_COMERSKU => 'SKU001',
        PA_TARJETA => '4111111111111111',
        PA_OFERID => 10,
        PA_OFERPLAZO => 12,
        PA_OFERMONTO => 1200,
        PA_OFERINTERES => 15,
        PA_OFERABONOP => 100,
        PA_OFERABONON => 100,
        PA_OFERABONOD => 0,
        PA_DEPCUENTA => '123456',
        PA_DEPCODIGO => 'COD01',
        PA_DEPDIVISA => 'MXN',
        PA_DEPMONTO => 500,
        PA_DEPFOLIO => 'DEP001',
        PA_DEPREFERENCIA => 'REF001',
        PA_DEPOBS => 'PRUEBA LOCAL',
        PA_DEPFECHA => '23/03/2026',
        PA_DEPLATITUD => '19.4326',
        PA_DEPLONGITUD => '-99.1332',
        PA_DOCEMP => 'EMP01',
        PA_DOCTELEMISOR => '5551112222',
        PA_DOCTELRECEPTOR => '5553334444',
        PA_DOCNOMBRE => 'JUAN',
        PA_DOCAPELLIDOP => 'PEREZ',
        PA_DOCAPELLIDOM => 'LOPEZ',
        PA_AUTORIZACION => 'AUTH01',
        PA_PEDPAIS => 1,
        PA_PEDCANAL => 1,
        PA_PEDSUCURSAL => 10,
        PA_PEDPEDIDO => 5001,
        PA_IDBLOQC => 1,
        PA_IDBLOQD => 2,
        PA_IDBLOQE => 3,
        PA_RUTATICKET => '/tmp/ticket.pdf',
        PA_RUTAAMORT => '/tmp/amort.pdf',
        PA_DOCTICKET => 'TICKET',
        PA_DOCAMORT => 'AMORT',
        PA_CAT => 1,
        PA_RESPCOBRANZA => 'RESP',
        PA_DESCRESPCOBRANZA => 'DESC',
        PA_RESPUESTA => v_respuesta
    );

    DBMS_OUTPUT.PUT_LINE('CASO 1 RESPUESTA=' || v_respuesta);
END;
/

SELECT COUNT(*) AS HEADER_INSERTADOS
  FROM RCREDITO.TABNPLHEADER
 WHERE FCTIPOMENSAJE = 'BNPL'
   AND FIPAISCTE = 1
   AND FICANALCTE = 1
   AND FISUCURSALCTE = 10
   AND FIFOLIOCTE = 1001
   AND FCCODFECHA = '20260323';

SELECT COUNT(*) AS DETAIL_INSERTADOS
  FROM RCREDITO.TABNPLDETAIL
 WHERE FCTIPOMENSAJE = 'BNPL'
   AND FIPAISCTE = 1
   AND FICANALCTE = 1
   AND FISUCURSALCTE = 10
   AND FIFOLIOCTE = 1001
   AND FCCODFECHA = '20260323';

prompt =========================================================
prompt CASO 2: CON INGESTA EXITOSA EL PROCEDIMIENTO SALE ANTES
prompt HALLAZGO: NO INSERTA HEADER/DETAIL SI LA INGESTA ES OK
prompt =========================================================

DECLARE
    v_respuesta VARCHAR2(4000);
BEGIN
    RCREDITO.SPBITACORABNPL(
        PA_TIPOMENSAJE => 'BNPL',
        PA_PAISCTE => 1,
        PA_CANALCTE => 1,
        PA_SUCURSALCTE => 10,
        PA_FOLIOCTE => 1002,
        PA_CODFECHA => '20260324',
        PA_PLATFORMID => 'APP',
        PA_SUBPLATFORMID => 'MOBILE',
        PA_SICU => 'SICU02',
        PA_PAISHEAD => 1,
        PA_CANALHEAD => 99,
        PA_SUCURSALHEAD => 999,
        PA_IP => '127.0.0.1',
        PA_USER => 'LOCALTEST',
        PA_COMERNAME => 'COMERCIO DEMO',
        PA_COMERAFIL => 'AFIL02',
        PA_COMERGIRO => 'RETAIL',
        PA_COMERSKU => 'SKU002',
        PA_TARJETA => '4111111111111111',
        PA_OFERID => 11,
        PA_OFERPLAZO => 18,
        PA_OFERMONTO => 2400,
        PA_OFERINTERES => 20,
        PA_OFERABONOP => 150,
        PA_OFERABONON => 150,
        PA_OFERABONOD => 0,
        PA_DEPCUENTA => '456789',
        PA_DEPCODIGO => 'COD02',
        PA_DEPDIVISA => 'MXN',
        PA_DEPMONTO => 900,
        PA_DEPFOLIO => 'DEP002',
        PA_DEPREFERENCIA => 'REF002',
        PA_DEPOBS => 'PRUEBA CON INGESTA',
        PA_DEPFECHA => '24/03/2026',
        PA_DEPLATITUD => '19.4326',
        PA_DEPLONGITUD => '-99.1332',
        PA_DOCEMP => 'EMP02',
        PA_DOCTELEMISOR => '5551112222',
        PA_DOCTELRECEPTOR => '5553334444',
        PA_DOCNOMBRE => 'MARIA',
        PA_DOCAPELLIDOP => 'HERNANDEZ',
        PA_DOCAPELLIDOM => 'GARCIA',
        PA_AUTORIZACION => 'AUTH02',
        PA_PEDPAIS => 1,
        PA_PEDCANAL => 1,
        PA_PEDSUCURSAL => 10,
        PA_PEDPEDIDO => 5002,
        PA_IDBLOQC => 1,
        PA_IDBLOQD => 2,
        PA_IDBLOQE => 3,
        PA_RUTATICKET => '/tmp/ticket2.pdf',
        PA_RUTAAMORT => '/tmp/amort2.pdf',
        PA_DOCTICKET => 'TICKET2',
        PA_DOCAMORT => 'AMORT2',
        PA_CAT => 1,
        PA_RESPCOBRANZA => 'RESP',
        PA_DESCRESPCOBRANZA => 'DESC',
        PA_STSID => 3,
        PA_BLOQUEOS => '104,115',
        PA_PERPAGOID => 13,
        PA_PERPAGOSDIAS => '15,30',
        PA_CAPACIDADESPGO => '{24,2000,1500|21,600,300}',
        PA_RESPUESTA => v_respuesta
    );

    DBMS_OUTPUT.PUT_LINE('CASO 2 RESPUESTA=' || v_respuesta);
END;
/

SELECT COUNT(*) AS HEADER_POST_INGESTA
  FROM RCREDITO.TABNPLHEADER
 WHERE FCTIPOMENSAJE = 'BNPL'
   AND FIPAISCTE = 1
   AND FICANALCTE = 1
   AND FISUCURSALCTE = 10
   AND FIFOLIOCTE = 1002
   AND FCCODFECHA = '20260324';

prompt ==========================================
prompt CASO 3: DUPLICADO EN HEADER O DETAIL
prompt ==========================================

DECLARE
    v_respuesta VARCHAR2(4000);
BEGIN
    RCREDITO.SPBITACORABNPL(
        PA_TIPOMENSAJE => 'BNPL',
        PA_PAISCTE => 1,
        PA_CANALCTE => 1,
        PA_SUCURSALCTE => 10,
        PA_FOLIOCTE => 1001,
        PA_CODFECHA => '20260323',
        PA_PLATFORMID => 'APP',
        PA_SUBPLATFORMID => 'MOBILE',
        PA_SICU => 'SICU01',
        PA_PAISHEAD => 1,
        PA_CANALHEAD => 99,
        PA_SUCURSALHEAD => 999,
        PA_IP => '127.0.0.1',
        PA_USER => 'LOCALTEST',
        PA_COMERNAME => 'COMERCIO DEMO',
        PA_COMERAFIL => 'AFIL01',
        PA_COMERGIRO => 'RETAIL',
        PA_COMERSKU => 'SKU001',
        PA_TARJETA => '4111111111111111',
        PA_OFERID => 10,
        PA_OFERPLAZO => 12,
        PA_OFERMONTO => 1200,
        PA_OFERINTERES => 15,
        PA_OFERABONOP => 100,
        PA_OFERABONON => 100,
        PA_OFERABONOD => 0,
        PA_DEPCUENTA => '123456',
        PA_DEPCODIGO => 'COD01',
        PA_DEPDIVISA => 'MXN',
        PA_DEPMONTO => 500,
        PA_DEPFOLIO => 'DEP001',
        PA_DEPREFERENCIA => 'REF001',
        PA_DEPOBS => 'PRUEBA LOCAL',
        PA_DEPFECHA => '23/03/2026',
        PA_DEPLATITUD => '19.4326',
        PA_DEPLONGITUD => '-99.1332',
        PA_DOCEMP => 'EMP01',
        PA_DOCTELEMISOR => '5551112222',
        PA_DOCTELRECEPTOR => '5553334444',
        PA_DOCNOMBRE => 'JUAN',
        PA_DOCAPELLIDOP => 'PEREZ',
        PA_DOCAPELLIDOM => 'LOPEZ',
        PA_AUTORIZACION => 'AUTH01',
        PA_PEDPAIS => 1,
        PA_PEDCANAL => 1,
        PA_PEDSUCURSAL => 10,
        PA_PEDPEDIDO => 5001,
        PA_IDBLOQC => 1,
        PA_IDBLOQD => 2,
        PA_IDBLOQE => 3,
        PA_RUTATICKET => '/tmp/ticket.pdf',
        PA_RUTAAMORT => '/tmp/amort.pdf',
        PA_DOCTICKET => 'TICKET',
        PA_DOCAMORT => 'AMORT',
        PA_CAT => 1,
        PA_RESPCOBRANZA => 'RESP',
        PA_DESCRESPCOBRANZA => 'DESC',
        PA_RESPUESTA => v_respuesta
    );

    DBMS_OUTPUT.PUT_LINE('CASO 3 RESPUESTA=' || v_respuesta);
END;
/