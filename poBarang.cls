 
 /*------------------------------------------------------------------------
    File        : poBarang
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Mon Apr 29 15:58:09 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.
USING OpenEdge.Web.DataObject.Writer.JsonObjectValueWriter FROM PROPATH.


BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS poBarang INHERITS WebHandler: 
    DEF TEMP-TABLE ttemp LIKE kontrak-d
        FIELD sup-kd AS CHARACTER.
        
    DEF BUFFER bttemp FOR ttemp.
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
                           + 'This message was returned by HandleGet in poBarang.'
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
        DEFINE VARIABLE lcString            AS LONGCHAR                        NO-UNDO.
            
        DEFINE VARIABLE vStatusCode         AS INTEGER                   NO-UNDO.
        
        /*HEADER*/
        DEFINE VARIABLE iprno               AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE iexpireddate        AS DATE                      NO-UNDO.
        DEFINE VARIABLE iexpectedddate      AS DATE                      NO-UNDO.        
         /*DETAIL*/  
        DEFINE VARIABLE ikdbar              AS CHARACTER                 NO-UNDO.
       
        /*HEADER*/
        DEFINE VARIABLE jsonRequest         AS JsonObject                NO-UNDO.
        DEFINE VARIABLE JsonResponse        AS JsonObject                NO-UNDO.    
         /*DETAIL*/ 
        DEFINE VARIABLE aItems              AS JsonArray                 NO-UNDO.
        DEFINE VARIABLE oItems              AS JsonObject                NO-UNDO.
        
        DEFINE VARIABLE tmpint              AS INT.
        DEFINE VARIABLE nourut              AS CHARACTER.
        DEFINE VARIABLE vkontrakno          AS CHARACTER.
        
        DEFINE VARIABLE ix                  AS INTEGER                   NO-UNDO.       
        DEFINE VARIABLE itoken              AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE iuserid             AS CHARACTER                 NO-UNDO.
        
        itoken = poRequest:GetPathParameter('token').
        
        jsonRequest = CAST(poRequest:Entity, JsonObject).
        iprno = jsonRequest:GetCharacter('pr_no').
        iexpireddate = jsonRequest:GetDate('expired_date').
        iexpectedddate = jsonRequest:GetDate('expected_date').
        
        EMPTY TEMP-TABLE ttemp.
        IF NOT CONNECTED ('xtdb') THEN DO:
            errorValidation(503, "Database Not Connected").
        END.
        IF NOT CONNECTED ('procurement') THEN DO:
            errorValidation(503, "Database Not Connected").
        END.
        
        FIND FIRST x-opera WHERE x-opera.token = iToken NO-LOCK NO-ERROR.
        IF NOT AVAIL x-opera THEN DO:
           errorValidation(401, "Unauthorized"). 
        END.
        ELSE DO:
            IF x-opera.exp-token < TODAY THEN DO:
                errorValidation(401, "Unauthorized").    
            END.
            iuserid = x-opera.op-code.
        END.
        
        FIND LAST po-h NO-LOCK NO-ERROR.
         IF AVAIL  po-h THEN DO:
             tmpint = INT(po-h.po-no) + 1.   
         END.
         ELSE
             tmpint = 1.
         
          nourut = STRING(tmpint,'9999999999').
          
          RELEASE po-h NO-ERROR.
        
        FIND FIRST pr-h WHERE pr-h.pr-no = iprno NO-ERROR.
        IF AVAIL pr-h THEN DO:
            FOR EACH pr-d NO-LOCK:
                FOR EACH kontrak-d WHERE kontrak-d.kdbar = pr-d.kdbar NO-LOCK BREAK BY kontrak-d.harga.
                    IF FIRST-OF(kontrak-d.harga) THEN DO:
                        CREATE ttemp.
                        BUFFER-COPY kontrak-d TO ttemp.
                        FIND FIRST kontrak-h WHERE kontrak-h.kontrakno = kontrak-h.kontrakno NO-LOCK.
                        IF AVAIL kontrak-h THEN DO:
                            ASSIGN
                            ttemp.sup-kd = kontrak-h.sup-kd.
                        END.
                    END. 
                END.  
            END.
            
            FOR EACH ttemp NO-LOCK BREAK BY ttemp.sup-kd:
                IF FIRST-OF(ttemp.sup-kd) THEN DO:
                    CREATE po-h.
                    ASSIGN
                        po-h.po-no           = nourut
                        po-h.po-date         = TODAY 
                        po-h.pr-no           = pr-h.pr-no
                        po-h.pr-date         = pr-h.pr-date
                        po-h.expected-date   = iexpectedddate
                        po-h.expired-date    = iexpireddate
                        po-h.netto           = 0
                        po-h.disc            = 0
                        po-h.disc-type       = "flat" 
                        po-h.disc-rp         = 0
                        po-h.grand-total     = 0
                        po-h.crdate          = TODAY
                        po-h.crtime          = STRING(TIME,"HH:MM:SS")
                        po-h.cruser          = iuserid
                        po-h.dept-kd         = pr-h.dept-kd
                        po-h.divisi-kd       = pr-h.divisi-kd
                        po-h.subdiv-kd       = pr-h.subdiv-kd. 
                        
                     FOR EACH bttemp WHERE bttemp.sup-kd = ttemp.sup-kd NO-LOCK:
                        FIND FIRST pr-d WHERE pr-d.kdbar = bttemp.kdbar NO-LOCK NO-ERROR.
                        IF AVAIL pr-d THEN DO:
                            CREATE po-d.
                            ASSIGN
                            po-d.disc           = bttemp.disc.
                            po-d.disc-rp        = bttemp.disc-rp.
                            po-d.harga          = bttemp.harga.
                            FIND FIRST vat WHERE dr-tgl <= TODAY AND sd-tgl = ? NO-ERROR .
                            IF AVAIL vat THEN DO:
                                po-d.ppn = vat.tarif.
                                po-d.ppn-rp = (bttemp.harga * vat.tarif) / 100.
                            END.
                            ELSE DO:
                                po-d.ppn = 11 .
                                po-d.ppn-rp = (bttemp.harga * 11) / 100.
                            END.
                            po-d.kdbar          = pr-d.kdbar.
                            po-d.kdjns          = pr-d.kdjns.
                            po-d.kdstn-beli     = bttemp.kdstn.
                            po-d.kdstn-stok     = pr-d.kdstn-stok.
                            po-d.lok-kd         = "".
                            po-d.po-date        = TODAY.
                            po-d.po-no          = nourut.
                            po-d.qty            = pr-d.qty.
                            po-d.qty-terima     = 0 .
                            po-d.qty-trm        = 0.
                        END.  
                     END.
                END.
            END.
        END.
        
        JsonResponse = NEW JsonObject().
        JsonResponse:Add('message', 'PO Created Successfull').  
        
        ASSIGN 
           oResponse = NEW OpenEdge.Web.WebResponse().
                           
        ASSIGN 
            lcString = JsonResponse:GetJsonText().
            oBody = NEW OpenEdge.Core.String(lcString).
        
        ASSIGN 
            oResponse:Entity        = JsonResponse
            oResponse:ContentType   = 'application/json':u
            oResponse:ContentLength = oBody:Size
            oResponse:StatusCode    = INTEGER(201).
        
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