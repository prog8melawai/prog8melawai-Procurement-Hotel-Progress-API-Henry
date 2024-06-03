 
 /*------------------------------------------------------------------------
    File        : getDept
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Fri Apr 19 13:05:59 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS getDept INHERITS WebHandler: 

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
            
        DEFINE VARIABLE lcString      AS LONGCHAR                        NO-UNDO.
        DEFINE VARIABLE oPr           AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE aDept         AS JsonArray                       NO-UNDO.
        DEFINE VARIABLE oDept         AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE vsubdiv-no    AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE vdiv-no       AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE itoken        AS CHARACTER                       NO-UNDO.
        
        vdiv-no = poRequest:GetPathParameter("divkd").
        vsubdiv-no = poRequest:GetPathParameter("subdivkd").
        itoken = poRequest:GetPathParameter('token').
        
        MESSAGE vdiv-no.
        MESSAGE vsubdiv-no.
        MESSAGE itoken.
        
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
        
        aDept = NEW JsonArray().  
        FOR EACH dept WHERE dept.divisi-kd = vdiv-no  AND dept.subdiv-kd = vsubdiv-no NO-LOCK:
        oDept = NEW JsonObject().
        oDept:Add("dept_kd", dept.dept-kd).
        oDept:Add("dept_nm", dept.dept-nm).
        oDept:Add("dept_divkd", dept.divisi-kd).
        oDept:Add("dept_faktif", dept.f-aktif).
        oDept:Add("dept_subdivkd", dept.subdiv-kd).
        oDept:Add("dept_tglnonaktif", dept.tgl-nonaktif).
        oDept:Add("dept_usernonaktif", dept.user-nonaktif).
        aDept:ADD(oDept).
        END.

        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse().
                          
        ASSIGN 
            lcString = aDept:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lcString).
        
        ASSIGN 
            oResponse:Entity        = aDept
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