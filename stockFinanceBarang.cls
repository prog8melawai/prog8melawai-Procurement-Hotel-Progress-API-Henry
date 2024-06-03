 
 /*------------------------------------------------------------------------
    File        : stockFinanceBarang
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Wed Apr 17 16:11:23 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS stockFinanceBarang INHERITS WebHandler: 

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
        DEFINE VARIABLE lcString    AS LONGCHAR                         NO-UNDO.
        DEFINE VARIABLE jsRequest   AS JsonObject                       NO-UNDO.
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
        FOR EACH stockfinance NO-LOCK:
            oBarang = NEW JsonObject().
            oBarang:Add("kdbar", stockfinance.kdbar).
            oBarang:Add("nmbar", stockfinance.nmbar).
            oBarang:Add("nmbar2", stockfinance.nmbar2).
            oBarang:Add("qmin", stockfinance.qmin).
            FIND FIRST msjns WHERE stockfinance.kdjns = msjns.kdjns NO-LOCK NO-ERROR.
            IF AVAIL msjns THEN DO:
                oBarang:Add("kode_jenis", msjns.kdjns). 
                oBarang:Add("nm_jenis", msjns.nmjns).    
            END.
            
            oBarang:Add("koderest", stockfinance.koderest).
            oBarang:Add("f_kvrs", stockfinance.f-kvrs).
            oBarang:Add("f_prod", stockfinance.f-prod).
            oBarang:Add("f_stok", stockfinance.f-stok).
            FIND FIRST satuan WHERE satuan.kdstn = stockfinance.kdstn-krm NO-ERROR.
            IF AVAIL satuan THEN DO:
                oBarang:Add("kdstn_krm", satuan.kdstn). 
                oBarang:Add("nm_kirim", satuan.ket). 
            END.
            FIND FIRST satuan WHERE satuan.kdstn = stockfinance.kdstn-stok NO-ERROR.
            IF AVAIL satuan THEN DO:
                oBarang:Add("kdstn_stok", satuan.kdstn). 
                oBarang:Add("nm_stok", satuan.ket). 
            END.
            oBarang:Add("kdstn_prod", stockfinance.kdstn-prod).
            oBarang:Add("f_aktif", stockfinance.f-aktif).
            oBarang:Add("batas_exp", stockfinance.batas-exp).
            oBarang:Add("kdgdg", stockfinance.kdgdg).
            oBarang:Add("lok_kd", stockfinance.lok-kd).
            oBarang:Add("qmax", stockfinance.qmax).
            oBarang:Add("oldkdbar", stockfinance.oldkdbar).
            oBarang:Add("kddiv", stockfinance.kddiv).
            oBarang:Add("f_audit", stockfinance.f-audit).
            oBarang:Add("f_pcab", stockfinance.f-pcab).
            oBarang:Add("bufprod", stockfinance.bufprod).
            oBarang:Add("gambar", stockfinance.gambar).
            oBarang:Add("f_waste", stockfinance.f-waste).
            oBarang:Add("subdiv_kd", stockfinance.subdiv-kd).
            oBarang:Add("f_updhrg", stockfinance.f-updhrg).
            oBarang:Add("f_updkvr", stockfinance.f-updkvr).
            oBarang:Add("aliaskdbar", stockfinance.aliaskdbar).
            oBarang:Add("kdktgr", stockfinance.kdktgr).
            oBarang:Add("f_jual", stockfinance.f-jual).
            oBarang:Add("perhjual", stockfinance.perhjual).
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
        
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").      
      END METHOD.
      
      /*------------------------------------------------------------------------------
            Purpose:                                                                
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
       METHOD OVERRIDE PROTECTED INTEGER HandleDelete( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").        
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