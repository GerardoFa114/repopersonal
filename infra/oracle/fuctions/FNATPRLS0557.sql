create or replace FUNCTION RCREDITO.FNATPRLS0557(PA_PAIS      IN NUMBER,
                                                PA_CANAL      IN NUMBER,
                                                PA_SUCURSAL   IN NUMBER,
                                                PA_FOLIO      IN NUMBER,
                                                PA_USR        IN VARCHAR2)
RETURN SYS_REFCURSOR
IS
    /***************************************************************************
    *
    * PROYECTO:: [BAZ CREDITO - PRODUCTO]
    * DESCRIPCION:: ESTA FUNCION VALIDA SI EL CLIENTE ES SE LE PUEDE HACER UNA OFERTA O NO.
    *               para que una oferta sea valida el pedido debe ser de taz y debe estar en
    *               estatus de cancelado (2,3 O 1) con saldo en cero o no debe ser un cliente de rescate.
    *               para que una oferta sea rechazada es cuando un pedido de taz esta en un estatus
    *               activo/pendiente (1,5) el saldo de estos pedidos debera ser mayor A 0 de igual modo
    *               se rechaza la oferta cuando es un cliente de rescate.
    * Modificacion 1: Se anade una validacion la cual discrimina la marca mas actual del cliente y dependiendo
    *                de esta, decide si el cliente es rojo o no, en dado caso que sea un cliente rojo no se
    *                brindara una oferta.
    * Modificacion 2: Validacion de lcr, solo si esta liberada se brinda oferta.
    *
    * CREADOR:: HECTOR ADRIAN CORDOVA NOGUEZ. (HADEZ)
    * FECHA :: 07/10/2022
    *
    * Actualiza: Martha Perez Raygoza.
    * Fecha: 23/04/2025
    *
    * Cambio: Se agrega validacion para no dar oferta a clientes con marcas de autos.
    *
    */

    Rcl_Cursor                 SYS_REFCURSOR;
    Vl_Validacion              NUMBER := 0;
    Vl_Pedtaz                  NUMBER := 0;                       --VALIDA PED
    Vl_Valped                  NUMBER := 0;             --VALIDA NUMERO DE PED
    Vl_Valcte                  NUMBER := 0;                       --VALIDA CTE
    Vl_Limped                  NUMBER := 0;         --VALIDA LIMITE DE PEDIDOS
    Vl_Onped                   NUMBER := 0;
    Vl_Oncte                   NUMBER := 0;
    Vl_Onctered                NUMBER := 0;
    Vl_Vred                    NUMBER := 0;
    Vl_StatusCen               NUMBER;
    Vl_StatusCred              NUMBER;
    Vl_1                       NUMBER := 1;
    Vl_2                       NUMBER := 2;
    Vl_3                       NUMBER := 3;
    Vl_4                       NUMBER := 4;
    Vl_9                       NUMBER := 9;
    Vl_6                       NUMBER := 6;
    Vl_5                       NUMBER := 5;
    Vl_8                       NUMBER := 8;
    Vl_24                      NUMBER := 24;
    Vl_76                      NUMBER := 76;
    Vl_120                     NUMBER := 120;
    Vl_721                     NUMBER := 721;
    Vl_722                     NUMBER := 722;
    Vl_172                     NUMBER := 172;
    Vl_836                     NUMBER := 836;
    Vl_1000                    NUMBER := 1000;
    Vl_0                       NUMBER := 0;
    Vl_01                      VARCHAR2 (2) := '01';
    Vl_00                      VARCHAR2 (2) := '00';
    Vl_Ok                      VARCHAR2 (40) := 'OFERTA VALIDA';
    Vl_Nook                    VARCHAR2 (40) := 'OFERTA NO VALIDA';
    Vl_Nopedtaz                VARCHAR2 (38) := 'LA OFERTA NO ES VALIDA, PEDIDOS DE TAZ';
    Vl_Nopedlim                VARCHAR2 (42)
                                   := 'LA OFERTA NO ES VALIDA, MAX COMPRA POR DIA';
    Vl_Nookcte                 VARCHAR2 (80) := 'LA OFERTA NO ES VALIDA, CTE RESCATE';
    Vl_NookpedRed              VARCHAR2 (54)
        := 'LA OFERTA NO ES VALIDA, HAY UN PEDIDO DE TAZ Y ES ROJO';
    Vl_NookpedRes              VARCHAR2 (68)
        := 'LA OFERTA NO ES VALIDA, HAY UN PEDIDO DE TAZ Y EL CLIENTE ES RESCATE';
    Vl_Nookctered              VARCHAR2 (80)
        := 'LA OFERTA NO ES VALIDA, EL CLIENTE ES RESCATE Y ES ROJO';
    Vl_Ctered                  VARCHAR2 (42)
                                   := 'LA OFERTA NO ES VALIDA, EL CLIENTE ES ROJO';
    Vl_Nacte                   VARCHAR2 (40) := 'CLIENTE SIN LINEA DE CREDITO';
    Vl_Errgnrl                 VARCHAR2 (120);
    Vl_LcrCancel               VARCHAR2 (120) := '[LCR] - CANCELADA';
    Vl_LcrRecha                VARCHAR2 (120) := '[LCR] - RECHAZADA';
    Vl_LcrInv                  VARCHAR2 (120) := '[LCR] - EN INVESTIGACION';
    Vl_LcrBlock                VARCHAR2 (120) := '[LCR] - BLOQUEADA';
    Vl_LcrAutoSL               VARCHAR2 (120) := '[LCR] - AUTORIZADA SIN LIBERAR';
    VL_NOOFERMARCAAUTO         VARCHAR2 (120) := 'LA OFERNA NO ES VALIDA, CLIENTE CON MARCA DE AUTOS';
    Exc_Sistema                EXCEPTION;
    Exc_Ofnolim                EXCEPTION;
    Exc_LcrCancel              EXCEPTION;
    Exc_LcrRecha               EXCEPTION;
    Exc_LcrInves               EXCEPTION;
    Exc_LCRBlock               EXCEPTION;
    Exc_LCRAutoSL              EXCEPTION;
    EXC_OFNOAUTOS              EXCEPTION;

    CSL_ROJO          CONSTANT VARCHAR2 (4) := 'ROJO';

    CSL_CLIENT_ROJO   CONSTANT NUMBER (1) := 1;
    CSL_NOCLIE_ROJO   CONSTANT NUMBER (1) := 0;
    
    VL_CLIENTEGRADUADO         NUMBER;
    VL_EXISTCLIENTEG           NUMBER:= 0;
    CSL_355           CONSTANT NUMBER:= 355;
    CSL_939           CONSTANT NUMBER:= 939;
    VL_BANMARCAAUTOS           NUMBER:= 0;
    VL_COUNTMARCA5204          NUMBER:= 0;
    CSL_5204           CONSTANT NUMBER:= 5204;
    
-- VALIDACION LCR CLIENTE EXISTENTE
BEGIN
   <<ExistLCR>>
    BEGIN
        SELECT COUNT (Vl_1)
          INTO Vl_Validacion
          FROM RCREDITO.CREDLINEADECREDITO  CRED,
               RCREDITO.CENLINEADECREDITO   CEN
         WHERE     CRED.FIPAIS = CEN.FIPAIS
               AND CRED.FICANAL = CEN.FICANAL
               AND CRED.FISUCURSAL = CEN.FISUCURSAL
               AND CRED.FIFOLIO = CEN.FIFOLIO
               AND CRED.FIPAIS = PA_PAIS
               AND CRED.FICANAL = PA_CANAL
               AND CRED.FISUCURSAL = PA_SUCURSAL
               AND CRED.FIFOLIO = PA_FOLIO;

        BEGIN
            IF    Vl_Validacion = Vl_0
               OR PA_PAIS = Vl_0
               OR PA_CANAL = Vl_0
               OR PA_SUCURSAL = Vl_0
               OR PA_FOLIO = Vl_0
            THEN
                RAISE EXC_SISTEMA;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                Vl_Validacion := Vl_0;
                RAISE EXC_SISTEMA;
            WHEN OTHERS
            THEN
                Vl_Validacion := Vl_0;
                RAISE EXC_SISTEMA;
        END;

       <<StatusCred>>
        BEGIN
            SELECT FISTATUS
              INTO Vl_StatusCred
              FROM RCREDITO.CREDLINEADECREDITO
             WHERE (FIPAIS,
                    FICANAL,
                    FISUCURSAL,
                    FIFOLIO) IN ((PA_PAIS,
                                  PA_CANAL,
                                  PA_SUCURSAL,
                                  PA_FOLIO));
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                Vl_StatusCen := Vl_0;
            WHEN OTHERS
            THEN
                Vl_StatusCen := Vl_0;
        END;

       <<StatusCen>>
        BEGIN
            SELECT FISTATUS
              INTO Vl_StatusCen
              FROM RCREDITO.CENLINEADECREDITO
             WHERE (FIPAIS,
                    FICANAL,
                    FISUCURSAL,
                    FIFOLIO) IN ((PA_PAIS,
                                  PA_CANAL,
                                  PA_SUCURSAL,
                                  PA_FOLIO));
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                Vl_StatusCen := Vl_0;
            WHEN OTHERS
            THEN
                Vl_StatusCen := Vl_0;
        END;

       <<LcrCance>>
        BEGIN
            IF Vl_StatusCen = Vl_5 OR Vl_StatusCen = Vl_6
            THEN
                RAISE Exc_LcrCancel;-- LCR CANCELADA. 
            END IF;
        END;

       <<LcrInv>>
        BEGIN
            -- En investigacion.
            IF Vl_StatusCred = Vl_0 AND Vl_StatusCen = Vl_3
            THEN
                RAISE Exc_LcrInves;
            END IF;
        END;

       <<ValLcr>>
        BEGIN
            IF Vl_StatusCred != Vl_0 AND Vl_StatusCen != Vl_1
            THEN
                -- Cuenta cancelada
                IF Vl_StatusCred = Vl_9 AND Vl_StatusCen = Vl_3
                THEN
                    RAISE Exc_LcrCancel;
                ELSIF Vl_StatusCred = Vl_1 AND Vl_StatusCen = Vl_3
                THEN
                    RAISE Exc_LCRBlock;-- LCR BLOQUEADA.
                ELSIF Vl_StatusCred = Vl_3 AND Vl_StatusCen = Vl_4
                THEN
                    RAISE Exc_LcrRecha;-- LCR RECHAZADA.
                ELSIF Vl_StatusCred = Vl_9 AND Vl_StatusCen = Vl_2
                THEN
                    RAISE Exc_LCRAutoSL;-- LCR AUTORIZADA SIN LIBERAR. 
                ELSE
                    RAISE Exc_LCRBlock;-- DEFAULT LCR BLOQUEADA.
                END IF;
            END IF;
        END;
    END;

    -- BANDERAS
    BEGIN
        -- CTE CON MARCA AUTO
        SELECT FIMONTOMIN
        INTO VL_BANMARCAAUTOS
        FROM RCREDITO.TAMECRETATM
        WHERE FIIDPARAM = CSL_939 AND FIPAISID = VL_1;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            VL_BANMARCAAUTOS := VL_0;      
    END;
    
    BEGIN
        -- PEDIDO TAZ
        SELECT FIMONTOMIN
          INTO Vl_Onped
          FROM RCREDITO.TAMECRETATM
         WHERE FIIDPARAM = VL_722 AND FIPAISID = Vl_1;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            Vl_Onped := Vl_0;
        WHEN OTHERS
        THEN
            Vl_Onped := Vl_0;
    END;

    BEGIN
        -- CTE RESCATE
        SELECT FIMONTOMIN
          INTO Vl_Oncte
          FROM RCREDITO.TAMECRETATM
         WHERE FIIDPARAM = VL_722 AND FIPAISID = VL_2;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            Vl_Oncte := Vl_0;
        WHEN OTHERS
        THEN
            Vl_Oncte := Vl_0;
    END;

    BEGIN
        -- CTE RED
        SELECT FIMONTOMIN
          INTO Vl_Onctered
          FROM RCREDITO.TAMECRETATM
         WHERE FIIDPARAM = VL_722 AND FIPAISID = VL_3;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            Vl_Onctered := Vl_0;
        WHEN OTHERS
        THEN
            Vl_Onctered := Vl_0;
    END;

    BEGIN
        -- LIMITE DE PEDIDOS
        SELECT FIMONTOMIN
          INTO Vl_Limped
          FROM RCREDITO.TAMECRETATM
         WHERE FIIDPARAM = VL_836;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            -- OFERTA VALIDA
            Vl_Limped := VL_1000;
        WHEN OTHERS
        THEN
            -- OFERTA VALIDA
            Vl_Limped := VL_1000;
    END;

    -- Limite de pedidos de BAZ
    BEGIN
        SELECT COUNT (PED.FINOPEDIDO)
          INTO Vl_Valped
          FROM RCREDITO.CENCLIENTETIENDA CEN, RCREDITO.PEDIDOS_CREDITO PED
         WHERE     CEN.FINGCIOID = PED.FINGCIOID
               AND CEN.FINOTIENDA = PED.FINOTIENDA
               AND CEN.FICTEID = PED.FICTEID
               AND CEN.FIDIGITOVER = PED.FIDIGITOVER
               AND CEN.FIPAIS = PA_PAIS
               AND CEN.FICANAL = PA_CANAL
               AND CEN.FISUCURSAL = PA_SUCURSAL
               AND CEN.FIFOLIO = PA_FOLIO
               AND PED.FIPEDSTATUS = Vl_1
               AND FDFECHASURT = TRUNC (SYSDATE);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            Vl_Valped := Vl_0;
        WHEN OTHERS
        THEN
            Vl_Valped := Vl_0;
    END;

    -- Validacion Bandera Limit
    IF Vl_Valped >= Vl_Limped
    THEN
        BEGIN
            RAISE EXC_OFNOLIM;
        END;
    END IF;

    -- Pedidos de TAZ
    BEGIN
        -- Validacion Bandera Pedidos Taz
        IF Vl_Onped = Vl_1
        THEN
            BEGIN
                SELECT COUNT (Vl_1)
                  INTO Vl_Pedtaz
                  FROM RCREDITO.PEDIDOS_CREDITO    PED,
                       RCREDITO.CENLINEADECREDITO  CEN
                 WHERE     PED.FINGCIOID = CEN.FINGCIOID
                       AND PED.FINOTIENDA = CEN.FINOTIENDA
                       AND PED.FICTEID = CEN.FICTEID
                       AND PED.FIDIGITOVER = CEN.FIDIGITOVER
                       AND CEN.FIPAIS = PA_PAIS
                       AND CEN.FICANAL = PA_CANAL
                       AND CEN.FISUCURSAL = PA_SUCURSAL
                       AND CEN.FIFOLIO = PA_FOLIO
                       AND PED.FIUNIDADNEGOCIO IN
                               (SELECT FIMONTOMIN
                                  FROM RCREDITO.TAMECRETATM
                                 WHERE     FIIDPARAM = VL_721
                                       AND FCUSUARIO = UPPER (PA_USR))
                       AND PED.FIPEDSTATUS NOT IN (VL_2, VL_3) --NO SEAN CANCELADOS
                       AND PED.FNSALDO > Vl_0;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    Vl_Pedtaz := Vl_0;
                WHEN OTHERS
                THEN
                    Vl_Pedtaz := Vl_0;
            END;

            IF Vl_Pedtaz > Vl_0
            THEN
                BEGIN
                    -- No Oferta
                    Vl_Pedtaz := Vl_1;
                END;
            END IF;
        END IF;

        -- Validacion Bandera CTE_Rescate
        IF Vl_Oncte = Vl_1
        THEN
            BEGIN
                  SELECT COUNT (Vl_1)
                    INTO Vl_Valcte
                    FROM RCREDITO.TACRMARCASOL      MSOL,
                         RCREDITO.CREDSOLICITUD     SOL,
                         RCREDITO.CREDCLIENTECLIENTE CT,
                         RCREDITO.CENLINEADECREDITO CN
                   WHERE     MSOL.FIPAIS = SOL.FIPAISID
                         AND MSOL.FICANAL = SOL.FICANALID
                         AND MSOL.FISUCURSALID = SOL.FISUCURSALID
                         AND MSOL.FISOLICITUDID = SOL.FISOLICITUDID
                         AND SOL.FIIDTIENDA = CT.FIIDTIENDA
                         AND SOL.FIIDCLIENTE = CT.FIIDCLIENTE
                         AND SOL.FIIDNEGOCIO = CT.FIIDNEGOCIO
                         AND SOL.FISUCURSALID = CT.FISUCURSALID
                         AND CT.FINGCIOID = CN.FINGCIOID
                         AND CT.FINOTIENDA = CN.FINOTIENDA
                         AND CT.FICTEID = CN.FICTEID
                         AND CT.FIDIGITOVER = CN.FIDIGITOVER
                         AND SOL.FITIPOSOLICITUD IN (VL_8, VL_76)
                         AND SOL.FISUBSTAT = VL_6       -- Solicitudes activas
                         AND MSOL.FIMARCAID IN (SELECT FIPAISID
                                                  FROM RCREDITO.TAMECRETATM
                                                 WHERE FIIDPARAM = Vl_172) -- Solicitud autorizada
                         AND CN.FIPAIS = PA_PAIS
                         AND CN.FICANAL = PA_CANAL
                         AND CN.FISUCURSAL = PA_SUCURSAL
                         AND CN.FIFOLIO = PA_FOLIO
                         AND ROWNUM < VL_2 -- Solo recupero la solicitud mas reciente
                ORDER BY SOL.FDFECSOL DESC;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    Vl_Valcte := Vl_0;
                WHEN OTHERS
                THEN
                    Vl_Valcte := Vl_0;
            END;

            IF Vl_Valcte >= Vl_1
            THEN
                BEGIN
                    Vl_Valcte := Vl_1;                            -- No Oferta
                END;
            ELSE
                BEGIN
                    Vl_Valcte := Vl_0;
                END;
            END IF;
        END IF;

        IF Vl_Onctered = Vl_1
        THEN
                      
            BEGIN
                SELECT COUNT(FIMARCA) 
                INTO VL_EXISTCLIENTEG
                FROM RCREDITO.TACONSOLIDADO
                WHERE FIPAIS    = PA_PAIS
                AND FICANAL     = PA_CANAL
                AND FISUCURSAL  = PA_SUCURSAL
                AND FIFOLIO     = PA_FOLIO
                AND FIMARCA     IN (CSL_355);
                
                IF VL_EXISTCLIENTEG > VL_0 THEN
                    VL_CLIENTEGRADUADO := VL_1;
                END IF;
                    
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    VL_CLIENTEGRADUADO := VL_0;
            END;
            
            BEGIN
                SELECT CASE C.FCCOLOR
                             WHEN CSL_ROJO THEN CSL_CLIENT_ROJO
                             ELSE CSL_NOCLIE_ROJO
                         END    AS BANDERA
                    INTO VL_VRED
                    FROM (SELECT TRIM (N.FCCOLOR)     AS FCCOLOR
                            FROM RCREDITO.TANIVELRIESGMOC N
                           WHERE     N.FIPAIS = PA_PAIS
                                 AND N.FICANAL = PA_CANAL
                                 AND N.FISUCURSAL = PA_SUCURSAL
                                 AND N.FIFOLIO = PA_FOLIO
                                 AND N.FIPRODUCTOID IN (VL_24)
                          UNION ALL
                          SELECT TRIM (H.FCCOLOR)     AS FCCOLOR
                            FROM RCREDITO.TANIVELRGMOCH H
                           WHERE     H.FIPAIS = PA_PAIS
                                 AND H.FICANAL = PA_CANAL
                                 AND H.FISUCURSAL = PA_SUCURSAL
                                 AND H.FIFOLIO = PA_FOLIO
                                 AND H.FIPRODUCTOID IN (VL_24)) C
                GROUP BY C.FCCOLOR;
                
                IF VL_CLIENTEGRADUADO = VL_1 AND VL_VRED = CSL_ROJO THEN
                    VL_VRED := VL_0;
                END IF;
                
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    VL_VRED := VL_0;
                WHEN OTHERS
                THEN
                    VL_VRED := VL_0;
            END;
        END IF;
    END;
    
    IF VL_BANMARCAAUTOS = VL_1
    THEN       
        BEGIN
            SELECT COUNT(TC.FIMARCA)  
            INTO    VL_COUNTMARCA5204
            FROM    RCREDITO.TACONSOLIDADO TC
            WHERE   TC.FIPAIS =PA_PAIS
            AND     TC.FICANAL=PA_CANAL
            AND     TC.FISUCURSAL=PA_SUCURSAL
            AND     TC.FIFOLIO=PA_FOLIO
            AND     TC.FIMARCA = CSL_5204;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                VL_COUNTMARCA5204 := VL_0;
            WHEN OTHERS
            THEN
                VL_COUNTMARCA5204 := VL_0;
        END;
        
        IF VL_COUNTMARCA5204 > VL_0 
        THEN
            RAISE EXC_OFNOAUTOS;-- SIN OFERTA POR TENER MARCA AUTOS.
        END IF;
    END IF;
    

    BEGIN
        -- Oferta valida
        IF Vl_Valcte = Vl_0 AND Vl_Pedtaz = Vl_0 AND Vl_Vred = Vl_0
        THEN
            BEGIN
                OPEN Rcl_Cursor FOR
                    SELECT VL_00 CODIGO, VL_OK DESCRIPCION FROM DUAL;

                RETURN Rcl_Cursor;
            END;
        -- Pedido de taz
        ELSIF Vl_Pedtaz = Vl_1 AND Vl_Valcte = Vl_0 AND Vl_Vred = Vl_0
        THEN
            BEGIN
                OPEN Rcl_Cursor FOR
                    SELECT Vl_01 CODIGO, Vl_Nopedtaz DESCRIPCION FROM DUAL;

                RETURN Rcl_Cursor;
            END;
        -- 1 Pedido de taz, Cliente rojo pero no es rescate
        ELSIF Vl_Pedtaz = Vl_1 AND Vl_Vred = Vl_1 AND Vl_Valcte = Vl_0
        THEN
            BEGIN
                OPEN Rcl_Cursor FOR
                    SELECT Vl_01 CODIGO, Vl_NookpedRed DESCRIPCION FROM DUAL;

                RETURN Rcl_Cursor;
            END;
        -- 1 Pedido de taz, Cliente es rescate pero no rojo.
        ELSIF Vl_Pedtaz = Vl_1 AND Vl_Valcte = Vl_1 AND Vl_Vred = Vl_0
        THEN
            BEGIN
                OPEN Rcl_Cursor FOR
                    SELECT Vl_01 CODIGO, Vl_NookpedRes DESCRIPCION FROM DUAL;

                RETURN Rcl_Cursor;
            END;
        -- Cliente de rescate
        ELSIF Vl_Valcte = Vl_1 AND Vl_Pedtaz = Vl_0 AND Vl_Vred = Vl_0
        THEN
            BEGIN
                OPEN Rcl_Cursor FOR
                    SELECT Vl_01 CODIGO, vl_nookcte DESCRIPCION FROM DUAL;

                RETURN Rcl_Cursor;
            END;
        -- Cliente de rescate y cliente rojo pero no hay pedido taz
        ELSIF Vl_Valcte = Vl_1 AND Vl_Vred = Vl_1 AND Vl_Pedtaz = Vl_0
        THEN
            BEGIN
                OPEN Rcl_Cursor FOR
                    SELECT Vl_01 CODIGO, Vl_Nookctered DESCRIPCION FROM DUAL;

                RETURN Rcl_Cursor;
            END;
        -- Cliente rojo
        ELSIF Vl_Vred = Vl_1 AND Vl_Pedtaz = Vl_0 AND Vl_Valcte = Vl_0
        THEN
            BEGIN
                OPEN Rcl_Cursor FOR
                    SELECT Vl_01 CODIGO, Vl_Ctered DESCRIPCION --NO VALIDA OFERTA
                                                               FROM DUAL;

                RETURN Rcl_Cursor;
            END;
        ELSIF Vl_Valcte = Vl_1 -- Cliente rescate, pedidos de taz y cliente rojo 
        AND Vl_Pedtaz = Vl_1 AND Vl_Vred = Vl_1
        THEN
            BEGIN
                OPEN Rcl_Cursor FOR
                    SELECT Vl_01 CODIGO, Vl_Nook DESCRIPCION --NO VALIDA OFERTA
                                                             FROM DUAL;
                RETURN Rcl_Cursor;
            END;
        END IF;
    END;
EXCEPTION
    -- No existe el cliente
    WHEN EXC_SISTEMA
    THEN
        OPEN Rcl_Cursor FOR
            SELECT Vl_01 CODIGO, Vl_Nacte DESCRIPCION FROM DUAL;

        RETURN Rcl_Cursor;
    -- Lcr Cancelada
    WHEN Exc_LcrCancel
    THEN
        OPEN Rcl_Cursor FOR
            SELECT Vl_01 CODIGO, Vl_LcrCancel DESCRIPCION FROM DUAL;

        RETURN Rcl_Cursor;
    -- Lcr Rechazada
    WHEN Exc_LcrRecha
    THEN
        OPEN Rcl_Cursor FOR
            SELECT Vl_01 CODIGO, Vl_LcrRecha DESCRIPCION FROM DUAL;

        RETURN Rcl_Cursor;
    -- Lcr Bloqueada
    WHEN Exc_LCRBlock
    THEN
        OPEN Rcl_Cursor FOR
            SELECT Vl_01 CODIGO, Vl_LcrBlock DESCRIPCION FROM DUAL;

        RETURN Rcl_Cursor;
    -- Lcr en investigacion
    WHEN Exc_LcrInves
    THEN
        OPEN Rcl_Cursor FOR
            SELECT Vl_01 CODIGO, Vl_LcrInv DESCRIPCION FROM DUAL;

        RETURN Rcl_Cursor;
    -- Lcr autorizada sin liberar
    WHEN Exc_LCRAutoSL
    THEN
        OPEN Rcl_Cursor FOR
            SELECT Vl_01 CODIGO, Vl_LcrAutoSL DESCRIPCION FROM DUAL;

        RETURN Rcl_Cursor;
    --Limite de pedidos
    WHEN EXC_OFNOLIM
    THEN
        OPEN Rcl_Cursor FOR
            SELECT Vl_01 CODIGO, Vl_Nopedlim DESCRIPCION FROM DUAL;

        RETURN Rcl_Cursor;  
    --CLIENTE CON MARCA AUTOS
    WHEN EXC_OFNOAUTOS
    THEN
        OPEN Rcl_Cursor FOR
            SELECT Vl_01 CODIGO, VL_NOOFERMARCAAUTO DESCRIPCION
                                                        FROM DUAL;
        RETURN Rcl_Cursor; 
    WHEN NO_DATA_FOUND
    THEN
        OPEN Rcl_Cursor FOR SELECT Vl_00 CODIGO, Vl_OK DESCRIPCION -- VALIDA OFERTA
                                                                   FROM DUAL;                                                               
        RETURN Rcl_Cursor;
    WHEN OTHERS
    THEN
        VL_ERRGNRL := SUBSTR (SQLERRM, Vl_1, VL_120);

        OPEN Rcl_Cursor FOR
            SELECT Vl_01 CODIGO, Vl_Errgnrl DESCRIPCION FROM DUAL;

        RETURN Rcl_Cursor;
END FNATPRLS0557;  /* GOLDENGATE_DDL_REPLICATION */