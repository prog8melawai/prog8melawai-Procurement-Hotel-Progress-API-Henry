 
 /*------------------------------------------------------------------------
    File        : prBarang
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Wed Apr 17 13:26:48 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS prBarang INHERITS WebHandler: 

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
        
        DEFINE VARIABLE lcString  AS LONGCHAR                        NO-UNDO.
        DEFINE VARIABLE aPr       AS JsonArray                       NO-UNDO.
        DEFINE VARIABLE oPr       AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE aBarang   AS JsonArray                       NO-UNDO.
        DEFINE VARIABLE oBarang   AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE titems    AS DECIMAL                         NO-UNDO.
        DEFINE VARIABLE itoken    AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE jsRequest AS JsonObject                      NO-UNDO.
            
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
        
        aPr = NEW JsonArray().
        FOR EACH pr-h NO-LOCK:
             oPr = NEW JsonObject().
             oPr:Add("pr_no", pr-h.pr-no).
             oPr:Add("pr_date", STRING(pr-h.pr-date,"99/99/9999")).
             oPr:Add("crdate",  STRING(pr-h.crdate,"99/99/9999")).
             oPr:Add("crtime", pr-h.crtime).
             oPr:Add("user_batal", pr-h.user-batal).
             oPr:Add("tgl_batal", pr-h.tgl-batal).
             oPr:Add("f_batal", pr-h.f-batal).
             oPr:Add("dept_kd", pr-h.dept-kd).
             oPr:Add("div_kd", pr-h.divisi-kd).
             oPr:Add("subdiv_kd", pr-h.subdiv-kd).
             
             titems = 0.
             FOR EACH pr-d WHERE pr-h.pr-no = pr-d.pr-no NO-LOCK:
                titems = titems + 1. 
             END.
             oPr:Add("total_item", titems).
             aPr:ADD(oPr).
        END.

        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse().
                          
        ASSIGN 
            lcString = aPr:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lcString).
        
        ASSIGN 
            oResponse:Entity        = aPr
            oResponse:ContentType   = 'application/json':u
            oResponse:ContentLength = oBody:Size
            oResponse:StatusCode = INTEGER(200)
            .

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
        
            DEFINE VARIABLE oResponse   AS OpenEdge.Net.HTTP.IHttpResponse  NO-UNDO.
            DEFINE VARIABLE oWriter     AS OpenEdge.Web.WebResponseWriter   NO-UNDO.
            DEFINE VARIABLE oBody       AS OpenEdge.Core.String             NO-UNDO.
            DEFINE VARIABLE jsResponse  AS JsonObject                       NO-UNDO.
            DEFINE VARIABLE lcString    AS LONGCHAR                         NO-UNDO.
            DEFINE VARIABLE vpr-no      AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE itoken      AS CHARACTER                        NO-UNDO.
            
            vpr-no = poRequest:GetPathParameter('pr_no').
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
            
            FIND FIRST pr-h WHERE pr-h.pr-no = vpr-no NO-ERROR.
            IF AVAIL pr-h THEN DO:
                ASSIGN 
                    pr-h.f-batal = YES
                    pr-h.f-revise = NO
                    pr-h.f-approve = NO
                    pr-h.tgl-batal = TODAY
                    pr-h.user-batal = USERID('xtdb').
            END.
            
            jsResponse = NEW JsonObject().
            jsResponse:Add('message', 'PR Rejected').
            
            ASSIGN 
                oResponse            = NEW OpenEdge.Web.WebResponse().
                              
            ASSIGN 
                lcString = jsResponse:GetJsonText()
                oBody = NEW OpenEdge.Core.String(lcString).
            
            ASSIGN 
                oResponse:Entity        = oResponse
                oResponse:ContentType   = 'application/json':u
                oResponse:ContentLength = oBody:Size
                oResponse:StatusCode = INTEGER(204).
    
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