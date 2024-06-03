 
 /*------------------------------------------------------------------------
    File        : putReceiving
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Mon May 13 09:46:26 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS putReceiving INHERITS WebHandler: 

    METHOD OVERRIDE PROTECTED INTEGER HandleNotAllowedMethod( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    END METHOD.

    METHOD OVERRIDE PROTECTED INTEGER HandleNotImplemented( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    END METHOD.

    
    
     
      /*------------------------------------------------------------------------------
            Purpose:                                                                
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
      METHOD OVERRIDE PROTECTED INTEGER HandlePut( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
        DEFINE VARIABLE oResponse           AS OpenEdge.Net.HTTP.IHttpResponse  NO-UNDO.
        DEFINE VARIABLE oWriter             AS OpenEdge.Web.WebResponseWriter   NO-UNDO.
        DEFINE VARIABLE oBody               AS OpenEdge.Core.String             NO-UNDO.
        DEFINE VARIABLE lString             AS LONGCHAR                         NO-UNDO.
        
        DEFINE VARIABLE jsResponse          AS JsonObject                       NO-UNDO.
        DEFINE VARIABLE jsRequest           AS JsonObject                       NO-UNDO.
        DEFINE VARIABLE itoken              AS CHARACTER                        NO-UNDO.
        DEFINE VARIABLE vNoKarcis           AS CHARACTER                        NO-UNDO.
        DEFINE VARIABLE vQty                AS DECIMAL                          NO-UNDO.
        DEFINE VARIABLE aItems              AS JsonArray                NO-UNDO.
        DEFINE VARIABLE oItems              AS JsonObject               NO-UNDO.
        DEFINE VARIABLE ix                  AS INTEGER                  NO-UNDO.
        DEFINE VARIABLE iuserid             AS CHARACTER                NO-UNDO.
        
        /*VALIDATION*/
        vNoKarcis = poRequest:GetPathParameter("nokarcis").
        itoken = poRequest:GetPathParameter('token').
          
        IF NOT CONNECTED ('xtdb') THEN DO:
            errorValidation(503, "Database Not Connected").
        END.
        IF NOT CONNECTED ('procurement') THEN DO:
            errorValidation(503, "Database Not Connected").
        END.
        IF NOT CONNECTED ('holding') THEN DO:
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
            iuserid = x-opera.op-code.
        END.
        /*====END VALIDATION====*/
        
        jsRequest = CAST(poRequest:Entity, JsonObject).
        aItems = jsRequest:GetJsonArray("items").
        
        FIND FIRST receiving-h WHERE receiving-h.no-karcis = vNoKarcis NO-LOCK NO-ERROR. 
        IF AVAIL receiving-h THEN DO :
            DO ix = 1 TO aItems:Length : 
                oItems = aItems:GetJsonObject(ix).
                vQty = oItems:GetDecimal('qty').
                FIND FIRST receiving-d WHERE    receiving-d.no-karcis = vNoKarcis NO-WAIT NO-ERROR.
/*KRITERIA UNTUK SEARCH DETAILNYA DISINI!!!*/
/*                 receiving-d.tgl-karcis = TODAY*/
                IF AVAIL receiving-d THEN DO:
                    ASSIGN 
                        receiving-d.qty = vQty.
                        
                        END.
                    END.
                END.
                
                RELEASE receiving-h.
                RELEASE receiving-d.
                jsResponse = NEW JsonObject().
                jsResponse:Add('message', 'Receiving Quantity Revised successfully!').
                 
        /**/
            ASSIGN 
                oResponse            = NEW OpenEdge.Web.WebResponse().
                              
            ASSIGN 
                lString = jsResponse:GetJsonText()
                oBody = NEW OpenEdge.Core.String(lString).
            
            ASSIGN 
                oResponse:Entity        = jsResponse
                oResponse:ContentType   = 'application/json':u
                oResponse:ContentLength = oBody:Size
                oResponse:StatusCode = INTEGER(200).
    
            ASSIGN 
                oWriter = NEW WebResponseWriter(oResponse).
                oWriter:Open().
                oWriter:Close().
            
            RETURN 0.
     
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
            oJsonObject:Add('message', errorMessage).
            
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