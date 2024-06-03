 
 /*------------------------------------------------------------------------
    File        : masterBarang
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Thu Apr 18 08:08:50 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS masterBarang INHERITS WebHandler: 



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
     
        DEFINE VARIABLE oResponse   AS OpenEdge.Net.HTTP.IHttpResponse  NO-UNDO.
        DEFINE VARIABLE oWriter     AS OpenEdge.Web.WebResponseWriter   NO-UNDO.
        DEFINE VARIABLE oBody       AS OpenEdge.Core.String             NO-UNDO.
        
        DEFINE VARIABLE aBarang     AS JsonArray                        NO-UNDO.
        DEFINE VARIABLE oBarang     AS JsonObject                       NO-UNDO.
        DEFINE VARIABLE jsRequest   AS JsonObject                       NO-UNDO.
        DEFINE VARIABLE lcString    AS LONGCHAR                         NO-UNDO.
        DEFINE VARIABLE itoken      AS CHARACTER                        NO-UNDO.
        DEFINE VARIABLE ikdjns      AS CHARACTER                        NO-UNDO.
         
        ikdjns = poRequest:GetPathParameter('kdjns').
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
         
        MESSAGE ikdjns.
        aBarang = NEW JsonArray().
        IF ikdjns = "all" THEN DO:
            FOR EACH masbar WHERE masbar.kdjns <> "01" NO-LOCK:
                oBarang = NEW JsonObject().
                oBarang:Add("kdbar", masbar.kdbar).
                oBarang:Add("nmbar", masbar.nmbar).
                oBarang:Add("nmbar2", masbar.nmbar2).
                oBarang:Add("qmin", masbar.qmin).
                FIND FIRST msjns WHERE masbar.kdjns = msjns.kdjns NO-LOCK NO-ERROR.
                IF AVAIL msjns THEN DO:
                    oBarang:Add("kode_jenis", msjns.kdjns). 
                    oBarang:Add("nm_jenis", msjns.nmjns).    
                END.
                
                oBarang:Add("koderest", masbar.koderest).
                oBarang:Add("f_kvrs", masbar.f-kvrs).
                oBarang:Add("f_prod", masbar.f-prod).
                oBarang:Add("f_stok", masbar.f-stok).
                FIND FIRST satuan WHERE satuan.kdstn = masbar.kdstn-krm NO-ERROR.
                IF AVAIL satuan THEN DO:
                    oBarang:Add("kdstn_krm", satuan.kdstn).
                    oBarang:Add("nm_kirim", satuan.ket).   
                END.
                
                FIND FIRST satuan WHERE satuan.kdstn = masbar.kdstn-stok NO-ERROR.
                IF AVAIL satuan THEN DO:
                    oBarang:Add("kdstn_stok", satuan.kdstn). 
                    oBarang:Add("nm_stok", satuan.ket). 
                END.
                oBarang:Add("kdstn_prod", masbar.kdstn-prod).
                oBarang:Add("f_aktif", masbar.f-aktif).
                oBarang:Add("batas_exp", masbar.batas-exp).
                oBarang:Add("kdgdg", masbar.kdgdg).
                oBarang:Add("lok_kd", masbar.lok-kd).
                oBarang:Add("qmax", masbar.qmax).
                oBarang:Add("oldkdbar", masbar.oldkdbar).
                oBarang:Add("kddiv", masbar.kddiv).
                oBarang:Add("f_audit", masbar.f-audit).
                oBarang:Add("f_pcab", masbar.f-pcab).
                oBarang:Add("bufprod", masbar.bufprod).
                oBarang:Add("gambar", masbar.gambar).
                oBarang:Add("f_waste", masbar.f-waste).
                oBarang:Add("subdiv_kd", masbar.subdiv-kd).
                oBarang:Add("f_updhrg", masbar.f-updhrg).
                oBarang:Add("f_updkvr", masbar.f-updkvr).
                oBarang:Add("aliaskdbar", masbar.aliaskdbar).
                oBarang:Add("kdktgr", masbar.kdktgr).
                oBarang:Add("f_jual", masbar.f-jual).
                oBarang:Add("perhjual", masbar.perhjual).
                aBarang:ADD(oBarang).        
            END.
        END.
        ELSE DO:
            FOR EACH masbar WHERE masbar.kdjns = ikdjns NO-LOCK:
                oBarang = NEW JsonObject().
                oBarang:Add("kdbar", masbar.kdbar).
                oBarang:Add("nmbar", masbar.nmbar).
                oBarang:Add("nmbar2", masbar.nmbar2).
                oBarang:Add("qmin", masbar.qmin).
                FIND FIRST msjns WHERE masbar.kdjns = msjns.kdjns NO-LOCK NO-ERROR.
                IF AVAIL msjns THEN DO:
                    oBarang:Add("kode_jenis", msjns.kdjns). 
                    oBarang:Add("nm_jenis", msjns.nmjns).    
                END.
                
                oBarang:Add("koderest", masbar.koderest).
                oBarang:Add("f_kvrs", masbar.f-kvrs).
                oBarang:Add("f_prod", masbar.f-prod).
                oBarang:Add("f_stok", masbar.f-stok).
                FIND FIRST satuan WHERE satuan.kdstn = masbar.kdstn-krm NO-ERROR.
                IF AVAIL satuan THEN DO:
                    oBarang:Add("kdstn_krm", satuan.kdstn).
                    oBarang:Add("nm_kirim", satuan.ket).   
                END.
                
                FIND FIRST satuan WHERE satuan.kdstn = masbar.kdstn-stok NO-ERROR.
                IF AVAIL satuan THEN DO:
                    oBarang:Add("kdstn_stok", satuan.kdstn). 
                    oBarang:Add("nm_stok", satuan.ket). 
                END.
                oBarang:Add("kdstn_prod", masbar.kdstn-prod).
                oBarang:Add("f_aktif", masbar.f-aktif).
                oBarang:Add("batas_exp", masbar.batas-exp).
                oBarang:Add("kdgdg", masbar.kdgdg).
                oBarang:Add("lok_kd", masbar.lok-kd).
                oBarang:Add("qmax", masbar.qmax).
                oBarang:Add("oldkdbar", masbar.oldkdbar).
                oBarang:Add("kddiv", masbar.kddiv).
                oBarang:Add("f_audit", masbar.f-audit).
                oBarang:Add("f_pcab", masbar.f-pcab).
                oBarang:Add("bufprod", masbar.bufprod).
                oBarang:Add("gambar", masbar.gambar).
                oBarang:Add("f_waste", masbar.f-waste).
                oBarang:Add("subdiv_kd", masbar.subdiv-kd).
                oBarang:Add("f_updhrg", masbar.f-updhrg).
                oBarang:Add("f_updkvr", masbar.f-updkvr).
                oBarang:Add("aliaskdbar", masbar.aliaskdbar).
                oBarang:Add("kdktgr", masbar.kdktgr).
                oBarang:Add("f_jual", masbar.f-jual).
                oBarang:Add("perhjual", masbar.perhjual).
                aBarang:ADD(oBarang).        
            END.
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