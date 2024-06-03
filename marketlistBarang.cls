 
 /*------------------------------------------------------------------------
    File        : marketlistBarang
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Wed Apr 17 16:11:04 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS marketlistBarang INHERITS WebHandler: 

    METHOD OVERRIDE PROTECTED INTEGER HandleNotAllowedMethod( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    END METHOD.

    METHOD OVERRIDE PROTECTED INTEGER HandleNotImplemented( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    END METHOD.

    
    
    /*------------------------------------------------------------------------------
            Purpose: Default handler for the HTTP GET method. The request being 
                     serviced and an optional status code is returned. A zero or 
                     null value means this method will deal with all errors.                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
     METHOD OVERRIDE PROTECTED INTEGER HandleGet( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
     
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oBody     AS OpenEdge.Core.String            NO-UNDO.
            
        DEFINE VARIABLE aBarang     AS JsonArray                        NO-UNDO.
        DEFINE VARIABLE oBarang     AS JsonObject                       NO-UNDO.
        DEFINE VARIABLE jsRequest   AS JsonObject                       NO-UNDO.
        DEFINE VARIABLE lcString    AS LONGCHAR                         NO-UNDO.
        DEFINE VARIABLE itoken      AS CHARACTER                        NO-UNDO.
        
        jsRequest = CAST(poRequest:Entity, JsonObject).
        itoken = poRequest:GetPathParameter('token').
         
        IF NOT CONNECTED ('xtdb') THEN DO:
            errorValidation(503, "Database Not Connected").
        END.
        IF NOT CONNECTED ('procurement') THEN DO:
            errorValidation(503, "Database Not Connected").
        END.
        
        FIND FIRST x-opera WHERE x-opera.token = itoken NO-LOCK NO-ERROR.
        IF NOT AVAIL x-opera THEN DO:
           errorValidation(401, "Unauthorized"). 
        END.
        ELSE DO:
            IF x-opera.exp-token < TODAY THEN DO:
                errorValidation(401, "Unauthorized").    
            END.
        END.
        
        aBarang = NEW JsonArray().
        FOR EACH marketlist NO-LOCK:
            oBarang = NEW JsonObject().
            oBarang:Add("kdbar", marketlist.kdbar).
            oBarang:Add("nmbar", marketlist.nmbar).
            oBarang:Add("nmbar2", marketlist.nmbar2).
            oBarang:Add("qmin", marketlist.qmin).
            FIND FIRST msjns WHERE marketlist.kdjns = msjns.kdjns NO-LOCK NO-ERROR.
            IF AVAIL msjns THEN DO:
                oBarang:Add("kode_jenis", msjns.kdjns). 
                oBarang:Add("nm_jenis", msjns.nmjns).    
            END.
            
            oBarang:Add("koderest", marketlist.koderest).
            oBarang:Add("f_kvrs", marketlist.f-kvrs).
            oBarang:Add("f_prod", marketlist.f-prod).
            oBarang:Add("f_stok", marketlist.f-stok).
            FIND FIRST satuan WHERE satuan.kdstn = marketlist.kdstn-krm NO-ERROR.
            IF AVAIL satuan THEN DO:
                oBarang:Add("kdstn_krm", satuan.kdstn). 
                oBarang:Add("nm_kirim", satuan.ket). 
            END.
            
            FIND FIRST satuan WHERE satuan.kdstn = marketlist.kdstn-stok NO-ERROR.
            IF AVAIL satuan THEN DO:
                oBarang:Add("kdstn_stok", satuan.kdstn). 
                oBarang:Add("nm_stok", satuan.ket). 
            END.
            oBarang:Add("kdstn_prod", marketlist.kdstn-prod).
            oBarang:Add("f_aktif", marketlist.f-aktif).
            oBarang:Add("batas_exp", marketlist.batas-exp).
            oBarang:Add("kdgdg", marketlist.kdgdg).
            oBarang:Add("lok_kd", marketlist.lok-kd).
            oBarang:Add("qmax", marketlist.qmax).
            oBarang:Add("oldkdbar", marketlist.oldkdbar).
            oBarang:Add("kddiv", marketlist.kddiv).
            oBarang:Add("f_audit", marketlist.f-audit).
            oBarang:Add("f_pcab", marketlist.f-pcab).
            oBarang:Add("bufprod", marketlist.bufprod).
            oBarang:Add("gambar", marketlist.gambar).
            oBarang:Add("f_waste", marketlist.f-waste).
            oBarang:Add("subdiv_kd", marketlist.subdiv-kd).
            oBarang:Add("f_updhrg", marketlist.f-updhrg).
            oBarang:Add("f_updkvr", marketlist.f-updkvr).
            oBarang:Add("aliaskdbar", marketlist.aliaskdbar).
            oBarang:Add("kdktgr", marketlist.kdktgr).
            oBarang:Add("f_jual", marketlist.f-jual).
            oBarang:Add("perhjual", marketlist.perhjual).
            aBarang:ADD(oBarang).        
        END.    
        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse().
                       
        ASSIGN 
            lcString = aBarang:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lcString).
        
        ASSIGN 
            oResponse:Entity        = aBarang
            oResponse:ContentType   = 'application/json':u
            oResponse:ContentLength = oBody:Size
            oResponse:StatusCode    = INTEGER(200).
        
        ASSIGN 
            oWriter = NEW WebResponseWriter(oResponse).
            oWriter:Open().
            oWriter:Close().
        
        RETURN 0.
        
     END METHOD.
     
     
      /*------------------------------------------------------------------------------
            Purpose:                                                                
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
      METHOD OVERRIDE PROTECTED INTEGER HandlePut( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").      
      END METHOD.
      
       
     /*------------------------------------------------------------------------------
            Purpose:                                                                
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
     METHOD OVERRIDE PROTECTED INTEGER HandlePost( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
        DEFINE VARIABLE oResponse           AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter             AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oBody               AS OpenEdge.Core.String            NO-UNDO.
        
        DEFINE VARIABLE itipe                AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE ikdbar               AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE inmbar               AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE ikdjns               AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE inmbar2              AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE iqmin                AS DECIMAL                   NO-UNDO.
        DEFINE VARIABLE ikoderest            AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE if_kvrs              AS LOGICAL                   NO-UNDO.
        DEFINE VARIABLE if_prod              AS LOGICAL                   NO-UNDO.
        DEFINE VARIABLE if_stok              AS LOGICAL                   NO-UNDO.
        DEFINE VARIABLE ikdstn_prod          AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE ikdstn-stok          AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE ikdstn-krm           AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE if_aktif             AS LOGICAL                   NO-UNDO.
        DEFINE VARIABLE ibatas_exp           AS INTEGER                   NO-UNDO.
        DEFINE VARIABLE ikdgdg               AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE ilok_kd              AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE iqmax                AS DECIMAL                   NO-UNDO.
        DEFINE VARIABLE ioldkdbar            AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE ikddiv               AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE if_audit             AS LOGICAL                   NO-UNDO.
        DEFINE VARIABLE if_pcab              AS LOGICAL                   NO-UNDO.
        DEFINE VARIABLE ibufprod             AS DECIMAL                   NO-UNDO.
        DEFINE VARIABLE igambar              AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE if_waste             AS LOGICAL                   NO-UNDO.
        DEFINE VARIABLE isubdiv_kd           AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE if_updhrg            AS LOGICAL                   NO-UNDO.
        DEFINE VARIABLE If_updkvr            AS LOGICAL                   NO-UNDO.
        DEFINE VARIABLE ialiaskdbar          AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE ikdktgr              AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE if_jual              AS LOGICAL                   NO-UNDO.
        DEFINE VARIABLE iperhjual             AS INTEGER                   NO-UNDO.
        DEFINE VARIABLE ix                   AS INTEGER                   NO-UNDO.
           
        DEFINE VARIABLE iUserId             AS CHARACTER                 NO-UNDO.  
        DEFINE VARIABLE aItems              AS JsonArray                 NO-UNDO.
        DEFINE VARIABLE oItems              AS JsonObject                NO-UNDO.
        DEFINE VARIABLE vStatusCode         AS INTEGER                   NO-UNDO.
        DEFINE VARIABLE lcString            AS LONGCHAR                  NO-UNDO.
        DEFINE VARIABLE jsonRequest         AS JsonObject                NO-UNDO.
        DEFINE VARIABLE jsonResponse        AS JsonObject                NO-UNDO.
        DEFINE VARIABLE iToken              AS CHARACTER                 NO-UNDO.       
        
        DEFINE VARIABLE tmpint              AS INT.
        DEFINE VARIABLE nourut              AS CHARACTER.
        
        iToken = poRequest:GetPathParameter('access_token').
          
        aItems = CAST(poRequest:Entity, JsonArray).
         

         FIND LAST marketlist NO-LOCK NO-ERROR.
         IF AVAIL  marketlist THEN DO:
             tmpint = INT(marketlist.kdbar) + 1.   
         END.
         ELSE
             tmpint = 1.
         
          nourut = STRING(tmpint,'9999').
          
          RELEASE marketlist NO-ERROR.
         
       DO ix = 1 TO aItems:Length :
            oItems = aItems:GetJsonObject(ix).
            ASSIGN 
            ikdbar       = oItems:GetCharacter('kode_barang')
            inmbar       = oItems:GetCharacter('nama_barang')
            itipe        = oItems:GetCharacter('type')
            ikdjns       = oItems:GetCharacter('kd_jenis')
            inmbar2      = oItems:GetCharacter('nama_barang2')
            iqmin        = oItems:GetDecimal('qmin')
            ikoderest    = oItems:GetCharacter('koderest')
            if_kvrs      = LOGICAL(oItems:GetCharacter('f_kvrs'))
            if_prod      = LOGICAL(oItems:GetCharacter('f_prod'))
            if_stok      = LOGICAL(oItems:GetCharacter('f_stok'))
            ikdstn_prod  = oItems:GetCharacter('kdstn_prod')
            ikdstn-stok  = oItems:GetCharacter('kdstn_stok')
            ikdstn-krm   = oItems:GetCharacter('kdstn_krm')
            if_aktif     = LOGICAL(oItems:GetCharacter('f_aktif'))
            ibatas_exp   = oItems:GetInteger('batas_exp')
            ikdgdg       = oItems:GetCharacter('kdgdg')
            ilok_kd      = oItems:GetCharacter('lok_kd')
            iqmax        = oItems:GetDecimal('qmax')
            ioldkdbar    = oItems:GetCharacter('oldkdbar')
            ikddiv       = oItems:GetCharacter('kddiv')
            if_audit     = LOGICAL(oItems:GetCharacter('f_audit'))
            if_pcab      = LOGICAL(oItems:GetCharacter('f_pcab'))
            ibufprod     = oItems:GetDecimal('bufprod')
            igambar      = oItems:GetCharacter('gambar')
            if_waste     = LOGICAL(oItems:GetCharacter('f_waste'))
            isubdiv_kd   = oItems:GetCharacter('subdiv_kd')
            if_updhrg    = LOGICAL(oItems:GetCharacter('f_updhrg'))
            If_updkvr    = LOGICAL(oItems:GetCharacter('f_updkvr'))
            ialiaskdbar  = oItems:GetCharacter('aliaskdbar')
            ikdktgr      = oItems:GetCharacter('kdktgr')
            if_jual      = LOGICAL(oItems:GetCharacter('f_jual'))
            iperhjual     = oItems:GetInteger('perhjual').

      IF itipe = 'm' THEN DO:
          FIND FIRST marketlist WHERE marketlist.kdbar = nourut NO-ERROR.
              IF NOT AVAIL marketlist THEN DO:
                 CREATE marketlist.
                 ASSIGN
                 marketlist.kdbar       = ikdbar
                 marketlist.nmbar       = inmbar
                 marketlist.kdjns       = ikdjns
                 marketlist.nmbar2      = inmbar2
                 marketlist.qmin        = iqmin
                 marketlist.koderest    = ikoderest
                 marketlist.f-kvrs      = if_kvrs
                 marketlist.f-prod      = if_prod
                 marketlist.f-stok      = if_stok
                 marketlist.kdstn-prod  = ikdstn_prod
                 marketlist.kdstn-stok  = ikdstn-stok
                 marketlist.kdstn-krm   = ikdstn-krm
                 marketlist.f-aktif     = if_aktif
                 marketlist.batas-exp   = ibatas_exp
                 marketlist.kdgdg       = ikdgdg
                 marketlist.lok-kd      = ilok_kd
                 marketlist.qmax        = iqmax
                 marketlist.oldkdbar    = ioldkdbar
                 marketlist.kddiv       = ikddiv
                 marketlist.f-audit     = if_audit
                 marketlist.f-pcab      = if_pcab
                 marketlist.bufprod     = ibufprod
                 marketlist.gambar      = igambar
                 marketlist.f-waste     = if_waste
                 marketlist.subdiv-kd   = isubdiv_kd
                 marketlist.f-updhrg    = if_updhrg
                 marketlist.f-updkvr    = If_updkvr
                 marketlist.aliaskdbar  = ialiaskdbar
                 marketlist.kdktgr      = ikdktgr
                 marketlist.f-jual      = if_jual
                 marketlist.perhjual    = perhjual. 
              END.
          END.
          ELSE IF itipe = 's' THEN DO:
              FIND FIRST stockfinance WHERE stockfinance.kdbar = nourut NO-ERROR.
              IF NOT AVAIL stockfinance THEN DO:
                 CREATE stockfinance.
                 ASSIGN
                 stockfinance.kdbar       = ikdbar
                 stockfinance.nmbar       = inmbar
                 stockfinance.kdjns       = ikdjns
                 stockfinance.nmbar2      = inmbar2
                 stockfinance.qmin        = iqmin
                 stockfinance.koderest    = ikoderest
                 stockfinance.f-kvrs      = if_kvrs
                 stockfinance.f-prod      = if_prod
                 stockfinance.f-stok      = if_stok
                 stockfinance.kdstn-prod  = ikdstn_prod
                 stockfinance.kdstn-stok  = ikdstn-stok
                 stockfinance.kdstn-krm   = ikdstn-krm
                 stockfinance.f-aktif     = if_aktif
                 stockfinance.batas-exp   = ibatas_exp
                 stockfinance.kdgdg       = ikdgdg
                 stockfinance.lok-kd      = ilok_kd
                 stockfinance.qmax        = iqmax
                 stockfinance.oldkdbar    = ioldkdbar
                 stockfinance.kddiv       = ikddiv
                 stockfinance.f-audit     = if_audit
                 stockfinance.f-pcab      = if_pcab
                 stockfinance.bufprod     = ibufprod
                 stockfinance.gambar      = igambar
                 stockfinance.f-waste     = if_waste
                 stockfinance.subdiv-kd   = isubdiv_kd
                 stockfinance.f-updhrg    = if_updhrg
                 stockfinance.f-updkvr    = If_updkvr
                 stockfinance.aliaskdbar  = ialiaskdbar
                 stockfinance.kdktgr      = ikdktgr
                 stockfinance.f-jual      = if_jual
                 stockfinance.perhjual    = iperhjual. 
              END.
          END.
        END.
       
        
        vStatusCode  = 200.
        JsonResponse = NEW JsonObject().
        JsonResponse:Add('message', 'PR Created Successfull').  
        
        ASSIGN 
           oResponse = NEW OpenEdge.Web.WebResponse().
                           
        ASSIGN 
            lcString = JsonResponse:GetJsonText().
            oBody = NEW OpenEdge.Core.String(lcString).
        
        ASSIGN 
            oResponse:Entity        = JsonResponse
            oResponse:ContentType   = 'application/json':u
            oResponse:ContentLength = oBody:Size
            oResponse:StatusCode    = vStatusCode.
        
        ASSIGN 
            oWriter = NEW WebResponseWriter(oResponse).
            oWriter:Open().
            oWriter:Close().                           
        
                      
      END METHOD.
      
      /*------------------------------------------------------------------------------
            Purpose:                                                                
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
       METHOD OVERRIDE PROTECTED INTEGER HandleDelete( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
          
      END METHOD.
      
      METHOD PUBLIC CHARACTER errorValidation(INPUT errorCode AS INTEGER, INPUT errorMessage AS CHARACTER) :
        
        DEFINE VARIABLE oResponse       AS OpenEdge.Net.HTTP.IHttpResponse      NO-UNDO.
        DEFINE VARIABLE oRequest        AS OpenEdge.Net.HTTP.IHttpRequest       NO-UNDO.
        DEFINE VARIABLE oWriter         AS OpenEdge.Web.WebResponseWriter       NO-UNDO.
        DEFINE VARIABLE oBody           AS OpenEdge.Core.String                 NO-UNDO.
        DEFINE VARIABLE oJsonObject     AS JsonObject                           NO-UNDO.
        DEFINE VARIABLE lcJsonObject    AS LONGCHAR                             NO-UNDO.      
        
        ASSIGN
            oResponse   = NEW OpenEdge.Web.WebResponse().
            
            oJsonObject = NEW JsonObject().
            oJsonObject:Add('success', FALSE).
            oJsonObject:Add('errorMessage', errorMessage).
            
        ASSIGN
            lcJsonObject    = oJsonObject:GetJsonText().
            oBody           = NEW OpenEdge.Core.String(lcJsonObject).
        
        ASSIGN 
            oResponse:Entity        = oJsonObject
            oResponse:ContentType   = 'application/json':u
            oResponse:ContentLength = oBody:Size
            oResponse:StatusCode    = errorCode.
            
        ASSIGN
            oWriter = NEW WebResponseWriter(oResponse).
            oWriter:Open().
            oWriter:Close().
        
        STOP.
    END METHOD.
    
END CLASS.