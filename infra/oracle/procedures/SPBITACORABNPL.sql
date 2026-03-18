create PROCEDURE SPBITACORABNPL(
	PA_TIPOMENSAJE IN VARCHAR2,
	PA_PAISCTE           IN    NUMBER, -- PA_IDPAIS IN NUMBER,
	PA_CANALCTE          IN    NUMBER, -- PA_IDCANAL IN NUMBER,
	PA_SUCURSALCTE       IN    NUMBER, -- PA_IDSUCURSAL  IN NUMBER,
	PA_FOLIOCTE          IN    NUMBER, -- PA_IDFOLIO  IN NUMBER,
	PA_CODFECHA          IN    VARCHAR2,
	PA_PLATFORMID        IN    VARCHAR2,
	PA_SUBPLATFORMID     IN    VARCHAR2,
	PA_SICU              IN    VARCHAR2,
	PA_PAISHEAD          IN    NUMBER, 	-- PA_GESTPAISID IN NUMBER,
	PA_CANALHEAD         IN    NUMBER, 	-- PA_GESTCANALID IN NUMBER,
	PA_SUCURSALHEAD      IN    NUMBER, 	-- PA_GESTSUCURSALID IN NUMBER,
	PA_IP                IN    VARCHAR2,
	PA_USER              IN    VARCHAR2,
	PA_COMERNAME         IN    VARCHAR2,
	PA_COMERAFIL         IN    VARCHAR2,
	PA_COMERGIRO         IN    VARCHAR2,
	PA_COMERSKU          IN    VARCHAR2,
	PA_TARJETA           IN    VARCHAR2,
	PA_OFERID            IN    NUMBER,
	PA_OFERPLAZO         IN    NUMBER,
	PA_OFERMONTO         IN    NUMBER,
	PA_OFERINTERES       IN    NUMBER,
	PA_OFERABONOP        IN    NUMBER,
	PA_OFERABONON        IN    NUMBER,
	PA_OFERABONOD        IN    NUMBER,
	PA_DEPCUENTA         IN    VARCHAR2,
	PA_DEPCODIGO         IN    VARCHAR2,
	PA_DEPDIVISA         IN    VARCHAR2,
	PA_DEPMONTO          IN    NUMBER,
	PA_DEPFOLIO          IN    VARCHAR2,
	PA_DEPREFERENCIA     IN    VARCHAR2,
	PA_DEPOBS            IN    VARCHAR2,
	PA_DEPFECHA          IN    VARCHAR2,
	PA_DEPLATITUD        IN    VARCHAR2,
	PA_DEPLONGITUD       IN    VARCHAR2,
	PA_DOCEMP            IN    VARCHAR2,
	PA_DOCTELEMISOR      IN    VARCHAR2,
	PA_DOCTELRECEPTOR    IN    VARCHAR2,
	PA_DOCNOMBRE         IN    VARCHAR2,
	PA_DOCAPELLIDOP      IN    VARCHAR2,
	PA_DOCAPELLIDOM      IN    VARCHAR2,
	PA_AUTORIZACION      IN    VARCHAR2,
	PA_PEDPAIS           IN    NUMBER,
	PA_PEDCANAL          IN    NUMBER,
	PA_PEDSUCURSAL       IN    NUMBER,
	PA_PEDPEDIDO         IN    NUMBER,
	PA_IDBLOQC           IN    NUMBER,
	PA_IDBLOQD           IN    NUMBER,
	PA_IDBLOQE           IN    NUMBER,
	PA_RUTATICKET        IN    VARCHAR2,
	PA_RUTAAMORT         IN    VARCHAR2,
	PA_DOCTICKET         IN    CLOB,
	PA_DOCAMORT          IN    CLOB,
	PA_CAT               IN    NUMBER,
	PA_RESPCOBRANZA      IN    VARCHAR2,
	PA_DESCRESPCOBRANZA  IN    VARCHAR2,
	
    --Parametro de ingesta para CDP
    PA_STSID            IN    NUMBER DEFAULT NULL,
    PA_BLOQUEOS         IN    VARCHAR2 DEFAULT NULL,
    PA_PERPAGOID        IN    NUMBER DEFAULT NULL,
    PA_PERPAGOSDIAS     IN    VARCHAR2 DEFAULT NULL,
    PA_CAPACIDADESPGO   IN    VARCHAR2 DEFAULT NULL,

	PA_RESPUESTA         OUT   VARCHAR2
)

IS
    VL_COD00              VARCHAR2(4) := '00';
    VL_COD01              VARCHAR2(4) := '01';
    VL_MENSAJE            VARCHAR2(250) := 'REGISTRO DUPLICADO';
    VL_MENSAJE2           VARCHAR2(250) := 'REGISTRO EXITOSO';
    VL_USUARIOACTUALIZA   VARCHAR2(20) := 'URSTAZ';
    VL_TARJETA            VARCHAR2(16) := '0000000000000000';

    --Variables para ingesta CDP
    VL_RESP_ING			  SYS_REFCURSOR;
    VL_ING_CODIGO         NUMBER;
    VL_ING_MENSAJE        VARCHAR2(4000);
	
    EXC_INGESTA_OK		  EXCEPTION;
    EXC_INGESTA_ERROR	  EXCEPTION;
BEGIN
--Validación de ingesta para CDP
	IF PA_CAPACIDADESPGO IS NOT NULL THEN
    --Ejecución de ingesta para CDP
        VL_RESP_ING := RCREDITO.FNINGESTACDPCP (
            PA_PAISCTE, 
            PA_CANALCTE, 
            PA_SUCURSALCTE,
            PA_FOLIOCTE,
			PA_STSID, 
            PA_BLOQUEOS,
			PA_PAISHEAD,
            PA_CANALHEAD,
            PA_SUCURSALHEAD,
			PA_PERPAGOID, 
            PA_PERPAGOSDIAS, 
            PA_CAPACIDADESPGO);

--Captura de respuesta de ingesta
        FETCH VL_RESP_ING INTO VL_ING_CODIGO, VL_ING_MENSAJE;

--Validación de respuesta de ingesta
        IF VL_RESP_ING%NOTFOUND THEN
            VL_ING_CODIGO := 1;
            VL_ING_MENSAJE := 'SIN RESPUESTA DE INGESTA';
        END IF;
--Cierre de cursor de ingesta
        IF VL_RESP_ING%ISOPEN THEN
            CLOSE VL_RESP_ING;
        END IF;
--Evaluación de código de ingesta
        IF NVL(VL_ING_CODIGO, 1) = 0 THEN
            VL_MENSAJE := NVL(VL_ING_MENSAJE, 'INGESTA EXITOSA');
            RAISE EXC_INGESTA_OK;
		ELSE
            VL_MENSAJE := NVL(VL_ING_MENSAJE, 'ERROR EN INGESTA');
            RAISE EXC_INGESTA_ERROR;
		END IF;
		
	END IF;
	
    INSERT INTO RCREDITO.TABNPLHEADER(FCTIPOMENSAJE,
                                      FIPAISCTE,
                                      FICANALCTE,
                                      FISUCURSALCTE,
                                      FIFOLIOCTE,
                                      FCCODFECHA,
                                      FCPLATFORMID,
                                      FCSUBPLATFORMID,
                                      FCSICU,
                                      FIPAISHEAD,
                                      FICANALHEAD,
                                      FISUCURSALHEAD,
                                      FDFECHAMOVIMEINTO,
                                      FCIP,
                                      FCUSER,
                                      FCCOMERNAME,
                                      FCCOMERAFIL,
                                      FCCOMERGIRO,
                                      FCCOMERSKU,
                                      FCTARJETA,
                                      FIOFERID,
                                      FIOFERPLAZO,
                                      FIOFERMONTO,
                                      FIOFERINTERES,
                                      FIOFERABONOP,
                                      FIOFERABONON,
                                      FIOFERABONOD,
                                      FDFECHAACTUALIZA,
                                      FCUSUARIOACTUALIZA)
     VALUES(PA_TIPOMENSAJE,
            PA_PAISCTE,
            PA_CANALCTE,
            PA_SUCURSALCTE,
            PA_FOLIOCTE,
            PA_CODFECHA,
            PA_PLATFORMID,
            PA_SUBPLATFORMID,
            PA_SICU,
            PA_PAISHEAD,
            PA_CANALHEAD,
            PA_SUCURSALHEAD,
            SYSDATE,
            PA_IP,
            PA_USER,
            PA_COMERNAME,
            PA_COMERAFIL,
            PA_COMERGIRO,
            PA_COMERSKU,
            NVL(PA_TARJETA,VL_TARJETA),
            PA_OFERID,
            PA_OFERPLAZO,
            PA_OFERMONTO,
            PA_OFERINTERES,
            PA_OFERABONOP,
            PA_OFERABONON,
            PA_OFERABONOD,
            SYSDATE,
            VL_USUARIOACTUALIZA);

    INSERT INTO RCREDITO.TABNPLDETAIL(FCTIPOMENSAJE,
                                      FIPAISCTE,
                                      FICANALCTE,
                                      FISUCURSALCTE,
                                      FIFOLIOCTE,
                                      FCCODFECHA,
                                      FCDEPCUENTA,
                                      FCDEPCODIGO,
                                      FCDEPDIVISA,
                                      FIDEPMONTO,
                                      FCDEPFOLIO,
                                      FCDEPREFERENCIA,
                                      FCDEPOBS,
                                      FDDEPFECHA,
                                      FCDEPLATITUD,
                                      FCDEPLONGITUD,
                                      FCDOCEMP,
                                      FCDOCTELEMISOR,
                                      FCDOCTELRECEPTOR,
                                      FCDOCNOMBRE,
                                      FCDOCAPELLIDOP,
                                      FCDOCAPELLIDOM,
                                      FCAUTORIZACION,
                                      FIPEDPAIS,
                                      FIPEDCANAL,
                                      FIPEDSUCURSAL,
                                      FIPEDPEDIDO,
                                      FIIDBLOQC,
                                      FIIDBLOQD,
                                      FIIDBLOQE,
                                      FCRUTATICKET,
                                      FCRUTAAMORT,
                                      FICAT,
                                      FCRESPCOBRANZA,
                                      FCDESCRESPCOBRANZA,
                                      FDFECHAACTUALIZA,
                                      FCUSUARIOACTUALIZA)
    VALUES( PA_TIPOMENSAJE,
            PA_PAISCTE,
            PA_CANALCTE,
            PA_SUCURSALCTE,
            PA_FOLIOCTE,
            PA_CODFECHA,
            PA_DEPCUENTA,
            PA_DEPCODIGO,
            PA_DEPDIVISA,
            PA_DEPMONTO,
            PA_DEPFOLIO,
            PA_DEPREFERENCIA,
            PA_DEPOBS,
            TO_DATE(PA_DEPFECHA,'DD/MM/YYYY'),
            PA_DEPLATITUD,
            PA_DEPLONGITUD,
            PA_DOCEMP,
            PA_DOCTELEMISOR,
            PA_DOCTELRECEPTOR,
            PA_DOCNOMBRE,
            PA_DOCAPELLIDOP,
            PA_DOCAPELLIDOM,
            PA_AUTORIZACION,
            PA_PEDPAIS,
            PA_PEDCANAL,
            PA_PEDSUCURSAL,
            PA_PEDPEDIDO,
            PA_IDBLOQC,
            PA_IDBLOQD,
            PA_IDBLOQE,
            PA_RUTATICKET,
            PA_RUTAAMORT,
            PA_CAT,
            PA_RESPCOBRANZA,
            PA_DESCRESPCOBRANZA,
            SYSDATE,
            VL_USUARIOACTUALIZA);

COMMIT;
        PA_RESPUESTA := VL_COD00 ||'|'|| VL_MENSAJE2;
EXCEPTION
--Validación de excepciones para ingesta CDP
	WHEN EXC_INGESTA_OK THEN
		PA_RESPUESTA := VL_COD00 ||'|'|| VL_MENSAJE;
--Validación de excepciones para ingesta CDP
	WHEN EXC_INGESTA_ERROR THEN
		PA_RESPUESTA := VL_COD01 ||'|'|| VL_MENSAJE;
        
    WHEN DUP_VAL_ON_INDEX THEN
        PA_RESPUESTA := VL_COD01 ||'|'|| VL_MENSAJE;
        ROLLBACK;
    WHEN OTHERS THEN
		IF VL_RESP_ING%ISOPEN THEN
			CLOSE VL_RESP_ING;
		END IF;
        VL_MENSAJE := SUBSTR(SQLERRM,1,250);
        PA_RESPUESTA := VL_COD01 ||'|'|| VL_MENSAJE;
        ROLLBACK;
END SPBITACORABNPL;
/

