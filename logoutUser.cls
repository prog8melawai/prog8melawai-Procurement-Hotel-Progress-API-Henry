 
 /*------------------------------------------------------------------------
    File        : logoutUser
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Mon Apr 22 16:09:07 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS logoutUser INHERITS WebHandler: 

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
            
        /* The WebResponse body is a wrapper around an entire HTTP response message.
           It contains a status code and reason; headers; cookies and a message body.
           
           API-level doc for this and related classes can be found at
           https://documentation.progress.com/output/oehttpclient/      */
        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse()
            oResponse:StatusCode = INTEGER(StatusCodeEnum:OK)
            .
        /* This body object can be a string or something else (JsonObject for instance) */               
        ASSIGN 
            oBody = NEW OpenEdge.Core.String(
                             'Hello user'
                           + '~r~n':u   /*CRLF */
                           + 'This message was returned by HandleGet in logoutUser.'
                           ).
        
        ASSIGN 
            oResponse:Entity        = oBody
            /* HTTP messages require a content type */
            oResponse:ContentType   = 'text/plain':u
            /* ContentLength is good too */
            oResponse:ContentLength = oBody:Size
            .
        
        /* The WebResponseWriter ensures that the status line and
           all headers are writted out before the message body/entity. */
        ASSIGN 
            oWriter = NEW WebResponseWriter(oResponse).
        oWriter:Open().
        
        /* Finish writing the response message */
        oWriter:Close().
        
        /* A response of 0 means that this handler will build the entire response;
           a non-zero value is mapped to a static handler in the webapp's /static/error folder.
           The mappings are maintained in the webapps's WEB-INF/web.xml 
           A predefined set of HTTP status codes is provided in the OpenEdge.Net.HTTP.StatusCodeEnum 
           enumeration */
        RETURN 0.
        
     END METHOD. 
     
     
       
     /*------------------------------------------------------------------------------
            Purpose:                                                                
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
     METHOD OVERRIDE PROTECTED INTEGER HandlePost( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
        DEFINE VARIABLE oResponse           AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter             AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oBody               AS OpenEdge.Core.String            NO-UNDO.
        DEFINE VARIABLE lcString            AS LONGCHAR                        NO-UNDO.
        
        DEFINE VARIABLE jsonRequest         AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE jsonResponse        AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE oUser               AS JsonObject                      NO-UNDO.
        
        DEFINE VARIABLE iID                 AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE iToken              AS CHARACTER                       NO-UNDO.
        
        jsonRequest = CAST(poRequest:Entity, JsonObject).
        
        IF NOT CONNECTED("procurement") THEN DO:
            ErrorValidation(503, "Database is not connected").
        END.
        
        IF NOT CONNECTED('xtdb') THEN DO:
            ErrorValidation(503, "Database is not connected").                
        END.
        
        ASSIGN
            iID = JsonRequest:GetCharacter("userid")
            iToken = JsonRequest:GetCharacter("token").
        
        DO TRANSACTION:
            FIND FIRST x-opera WHERE x-opera.token = iToken NO-ERROR.
            IF NOT AVAIL x-opera THEN DO:
                RELEASE x-opera.
                ErrorValidation(401, "Unauthorized").
            END.
            ELSE DO:
                IF x-opera.op-code <> iID THEN DO:
                    RELEASE x-opera.
                    ErrorValidation(401, "Unauthorized").
                END.
                ELSE DO:
                    ASSIGN
                        x-opera.token = ''
                        x-opera.exp-token = ?.
                END.
            END.
        END.
        
        RELEASE x-opera.
        
        JsonResponse = NEW JsonObject().
        JsonResponse:Add("message", "Logout Successful").
        
        ASSIGN 
           oResponse = NEW OpenEdge.Web.WebResponse().
                           
        ASSIGN 
           lcString = JsonResponse:GetJsonText().
           oBody = NEW OpenEdge.Core.String(lcString).
        
        ASSIGN 
           oResponse:Entity        = JsonResponse
           oResponse:ContentType   = 'application/json':u
           oResponse:ContentLength = oBody:Size
           oResponse:StatusCode    = INTEGER(StatusCodeEnum:OK).
        
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