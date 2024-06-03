 
 /*------------------------------------------------------------------------
    File        : PODetailBySupplier
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Wed May 29 19:23:43 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS PODetailBySupplier INHERITS WebHandler: 
    
    DEF TEMP-TABLE temp-poh LIKE po-h.
    DEF TEMP-TABLE temp-pod LIKE po-d
        FIELD sup-kd AS CHAR.

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
            
        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse()
            oResponse:StatusCode = INTEGER(StatusCodeEnum:OK)
            .
            
        ASSIGN 
            oBody = NEW OpenEdge.Core.String(
                             'Hello user'
                           + '~r~n':u   /*CRLF */
                           + 'This message was returned by HandleGet in PODetailBySupplier.'
                           ).
        
        ASSIGN 
            oResponse:Entity        = oBody
            oResponse:ContentType   = 'text/plain':u
            oResponse:ContentLength = oBody:Size
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
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oBody     AS OpenEdge.Core.String            NO-UNDO.
        DEFINE VARIABLE lString   AS LONGCHAR      NO-UNDO.
        DEFINE VARIABLE jsonRequest         AS JsonObject                NO-UNDO.
        DEFINE VARIABLE JsonResponse        AS JsonObject                NO-UNDO.   

        /*INPUT HEADER*/
        DEFINE VARIABLE ipono       AS CHARACTER    NO-UNDO.
        DEFINE VARIABLE apono       AS JsonArray    NO-UNDO.
        DEFINE VARIABLE itoken    AS CHARACTER     NO-UNDO.
        
        DEFINE VARIABLE aItems    AS JsonArray     NO-UNDO.
        DEFINE VARIABLE oItems    AS JsonObject    NO-UNDO.
        
        DEFINE VARIABLE iuserid             AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE idiv        AS CHARACTER        NO-UNDO.
        DEFINE VARIABLE isdiv     AS CHARACTER        NO-UNDO.
         DEFINE VARIABLE ix                  AS INTEGER                  NO-UNDO.
       
        /*VALIDATION TOKEN*/
        iToken = poRequest:GetPathParameter('token').
        jsonRequest = CAST(poRequest:Entity, JsonObject).
        apono = jsonRequest:GetJsonArray("po_no").

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
            idiv = x-opera.divisi-kd.
            isdiv = x-opera.subdiv-kd.
        END.        
        /*====END VALIDATION====*/
        EMPTY TEMP-TABLE temp-pod.
       
        p:
            DO TRANSACTION ON ERROR UNDO p, LEAVE p:
                DO ix = 1 TO apono:LENGTH:
                    ipono = apono:GetCharacter(ix).
                    tempawal(ipono).                     
                END. 
                
                aItems = NEW JsonArray(). 
                
                FOR EACH temp-pod NO-LOCK by temp-pod.po-no : 
                        message "start foreach temp pod".
                        oItems = NEW JsonObject().
                        oItems:Add("po_no", temp-pod.po-no).
                        oItems:Add("po_date", STRING(temp-pod.po-date, "99/99/9999")).
                        
                        FIND FIRST masbar-sdiv WHERE masbar-sdiv.kdbar = temp-pod.kdbar AND 
                                                        masbar-sdiv.divisi-kd = idiv AND
                                                        masbar-sdiv.subdiv-kd = isdiv NO-ERROR.
                        IF AVAIL masbar-sdiv THEN DO :
                             oItems:Add("kdbar", masbar-sdiv.kdbar).
                             oItems:Add("nmbar", masbar-sdiv.nmbar).
                        END.
                        
                        FIND FIRST masbar-jenis WHERE masbar-jenis.kdjns = temp-pod.kdjns NO-ERROR.
                        IF AVAIL masbar-jenis THEN DO:
                            oItems:Add("kdjns", masbar-jenis.kdjns).
                            oItems:Add("nmjns", masbar-jenis.nmjns).
                        END.
                        oItems:Add("qty", temp-pod.qty).
                        oItems:Add("qty_terima", temp-pod.qty-terima).
                        FIND FIRST satuan WHERE satuan.kdstn = temp-pod.kdstn-beli NO-ERROR.
                        IF AVAIL satuan THEN DO:  
                        oItems:Add("kdstn_beli", satuan.kdstn).
                        oItems:Add("nmstn_beli", satuan.ket).
                        oItems:Add("sup_kd", temp-pod.sup-kd).
                        END.
                        
                        aItems:ADD(oItems).
                    END.
                END.
        
        
       ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse() 
            .
        ASSIGN 
            lstring = aItems:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lString)
            .
        
        ASSIGN 
            oResponse:Entity        = aItems
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
    
    METHOD PUBLIC CHARACTER  tempawal (INPUT ipono AS CHARACTER) :    
        MESSAGE ipono. 
        p:
            DO TRANSACTION:
                    FIND FIRST po-h WHERE   po-h.po-no = ipono NO-ERROR.
                        IF AVAIL po-h THEN DO:
                            FOR EACH po-d WHERE po-d.po-no = po-h.po-no NO-LOCK :
                                  IF po-d.qty - po-d.qty-terima = 0 THEN NEXT.
/*                                FIND FIRST temp-pod WHERE temp-pod.po-no = po-d.po-no NO-ERROR.*/
/*                                IF NOT AVAIL temp-pod THEN DO:*/
                                    CREATE temp-pod.
                                    BUFFER-COPY po-d TO temp-pod. 
                                    ASSIGN temp-pod.sup-kd = po-h.sup-kd.
/*                                END.*/
/*                                ELSE DO:*/
/*                                END.*/
                            END.
                    END.
            END.
    MESSAGE "TEMP TABLES OK." .    
    END METHOD.
END CLASS.