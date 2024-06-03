 
 /*------------------------------------------------------------------------
    File        : satuanBeli
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Thu May 02 09:50:41 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS satuanBeli INHERITS WebHandler: 

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
        
        DEFINE VARIABLE aSatuan     AS JsonArray                        NO-UNDO.
        DEFINE VARIABLE oSatuan     AS JsonObject                       NO-UNDO.
        DEFINE VARIABLE lcString    AS LONGCHAR                         NO-UNDO.
        DEFINE VARIABLE itoken      AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE ikdbar      AS CHARACTER                       NO-UNDO.
         
        itoken = poRequest:GetPathParameter('token').
        ikdbar = poRequest:GetPathParameter('kdbar'). 
        
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
        
        aSatuan = NEW JsonArray().
        FOR EACH msatuan-beli WHERE msatuan-beli.kdbar = ikdbar NO-LOCK:
            oSatuan = NEW JsonObject().
            oSatuan:Add("kdbar", msatuan-beli.kdbar).
            FIND FIRST satuan WHERE satuan.kdstn = msatuan-beli.kdstn NO-LOCK NO-ERROR.
                 IF AVAIL satuan THEN DO:
                    oSatuan:Add("kdstn", satuan.kdstn). 
                    oSatuan:Add("nm_stn", satuan.ket).    
            END.


            aSatuan:ADD(oSatuan).        
        END.    
        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse().
                       
        ASSIGN 
            lcString = aSatuan:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lcString).
        
        ASSIGN 
            oResponse:Entity        = aSatuan
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