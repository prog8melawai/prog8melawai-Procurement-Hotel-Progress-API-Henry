 
 /*------------------------------------------------------------------------
    File        : contractSupplier
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Wed Apr 24 14:14:20 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS contractSupplier INHERITS WebHandler: 

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
       
        DEFINE VARIABLE aKontrak   AS JsonArray                        NO-UNDO.
        DEFINE VARIABLE oKontrak   AS JsonObject                       NO-UNDO.
        DEFINE VARIABLE lcString   AS LONGCHAR                         NO-UNDO.
        
        DEFINE VARIABLE itoken              AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE iuserid             AS CHARACTER                 NO-UNDO.
        
        itoken = poRequest:GetPathParameter('token').
        
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
        
        aKontrak = NEW JsonArray().
        FOR EACH kontrak-h NO-LOCK:
            oKontrak = NEW JsonObject().
            oKontrak:Add("kontrakno", kontrak-h.kontrakno).
            oKontrak:Add("crdate", kontrak-h.crdate).
            oKontrak:Add("crtime", kontrak-h.crtime).
            oKontrak:Add("cruser", kontrak-h.cruser).
            FIND FIRST dept WHERE kontrak-h.dept-kd  = dept.dept-kd NO-LOCK NO-ERROR.
            IF AVAIL dept THEN DO:
                oKontrak:Add("dept_nm", dept.dept-nm).    
            END.
            
            FIND FIRST divisi WHERE kontrak-h.divisi-kd  = divisi.divisi-kd NO-LOCK NO-ERROR.
            IF AVAIL divisi THEN DO:
                oKontrak:Add("div_nm", divisi.divisi-nm).    
            END.
            
            FIND FIRST sub-divisi WHERE kontrak-h.subdiv-kd  = sub-divisi.subdiv-kd NO-LOCK NO-ERROR.
            IF AVAIL sub-divisi THEN DO:
                oKontrak:Add("subdiv_nm", sub-divisi.subdiv-nm).    
            END.

            oKontrak:Add("kontrak_date", kontrak-h.kontrak-date).
            oKontrak:Add("endkontrak_date", kontrak-h.end-kontrak-date).
            oKontrak:Add("catatan", kontrak-h.catatan).
            oKontrak:Add("currency", kontrak-h.currency).
            oKontrak:Add("lok_kd", kontrak-h.lok-kd).
            oKontrak:Add("rate", kontrak-h.rate).
            FIND FIRST t-sup WHERE kontrak-h.sup-kd  = t-sup.sup-kd NO-LOCK NO-ERROR.
            IF AVAIL t-sup THEN DO:
                oKontrak:Add("sup_nm", t-sup.sup-nm).    
            END.
            
            oKontrak:Add("tglconf", kontrak-h.tglconf).
            oKontrak:Add("top", kontrak-h.top).
            oKontrak:Add("user_confirm", kontrak-h.user-confirm).
            oKontrak:Add("user_batal", kontrak-h.user-batal).
            oKontrak:Add("tglbatal", kontrak-h.tgl-batal).
            aKontrak:ADD(oKontrak).
        END.    
        
         ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse().
                       
        ASSIGN 
            lcString = aKontrak:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lcString).
        
        ASSIGN 
            oResponse:Entity        = aKontrak
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
            DEFINE VARIABLE oResponse   AS OpenEdge.Net.HTTP.IHttpResponse  NO-UNDO.
            DEFINE VARIABLE oWriter     AS OpenEdge.Web.WebResponseWriter   NO-UNDO.
            DEFINE VARIABLE oBody       AS OpenEdge.Core.String             NO-UNDO.
            DEFINE VARIABLE lcString    AS LONGCHAR                         NO-UNDO.
            
            DEFINE VARIABLE jsResponse  AS JsonObject                       NO-UNDO.
            DEFINE VARIABLE jsRequest   AS JsonObject                       NO-UNDO.
            
            DEFINE VARIABLE ikontrakno  AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE iuserid     AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE itoken      AS CHARACTER                        NO-UNDO.
            
            itoken = poRequest:GetPathParameter('token').
            jsRequest = CAST(poRequest:Entity, JsonObject).
            ASSIGN 
            ikontrakno = jsRequest:GetCharacter("kontrakno").
            
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
                iuserid = x-opera.op-code.
            END.
        
            FIND FIRST kontrak-h WHERE kontrak-h.kontrakno = ikontrakno NO-ERROR.
            IF AVAIL kontrak-h THEN DO:
               ASSIGN
               kontrak-h.user-confirm = iuserid
               kontrak-h.tglconf      = TODAY.
            END.
            
            RELEASE kontrak-h.
            jsResponse = NEW JsonObject().
            jsResponse:Add('message', 'Kontrak Approved').
            
            ASSIGN 
                oResponse            = NEW OpenEdge.Web.WebResponse().
                              
            ASSIGN 
                lcString = jsResponse:GetJsonText()
                oBody = NEW OpenEdge.Core.String(lcString).
            
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
        DEFINE VARIABLE isup-kd              AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE idiv-kd              AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE isubdiv-kd           AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE idept-kd             AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE icurrency            AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE irate                AS DECIMAL                   NO-UNDO.
        DEFINE VARIABLE icatatan             AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE ikontrak-date        AS DATE                      NO-UNDO.
        DEFINE VARIABLE iend-kontrak-date    AS DATE                      NO-UNDO.
        DEFINE VARIABLE itop                 AS INTEGER                   NO-UNDO.    
                
         /*DETAIL*/  
        DEFINE VARIABLE ikdbar               AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE ikdstn               AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE idisc                AS DECIMAL                   NO-UNDO.
        DEFINE VARIABLE ippn                 AS DECIMAL                   NO-UNDO.
        DEFINE VARIABLE iharga               AS DECIMAL                   NO-UNDO.
                  
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
        DEFINE VARIABLE iToken              AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE iuserid             AS CHARACTER                 NO-UNDO.  
        
        DEFINE VARIABLE errorcnt            AS LOGICAL                   NO-UNDO.
        DEFINE VARIABLE errormessages       AS CHARACTER                 NO-UNDO.
         
        
        iToken = poRequest:GetPathParameter('token').
        jsonRequest = CAST(poRequest:Entity, JsonObject).
        aItems = jsonRequest:GetJsonArray("items").
        
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
        
        jsonRequest         = CAST(poRequest:Entity, JsonObject).
        isup-kd             = jsonRequest:GetCharacter('sup_kd').
        icurrency           = jsonRequest:GetCharacter('currency').
        irate               = jsonRequest:GetDecimal('rate').
        ikontrak-date       = jsonRequest:GetDate('start_date').
        iend-kontrak-date   = jsonRequest:GetDate('end_date').
        itop                = jsonRequest:GetInteger('top').
        icatatan            = jsonRequest:GetCharacter('note').
        idiv-kd             = jsonRequest:GetCharacter('divisi_kd').
        isubdiv-kd          = jsonRequest:GetCharacter('subdiv_kd').
        aItems              = jsonRequest:GetJsonArray('items').
           
            
        FIND LAST kontrak-h NO-LOCK NO-ERROR.
        IF AVAIL  kontrak-h THEN DO:
            tmpint = INT(kontrak-h.kontrakno) + 1.   
        END.
        ELSE
            tmpint = 1.
         
        nourut = STRING(tmpint,'9999999999').
          
        RELEASE kontrak-h NO-ERROR.

        p:
        DO TRANSACTION :
            errorcnt = NO. 
            FOR EACH kontrak-h WHERE kontrak-h.sup-kd = isup-kd NO-LOCK:
                IF kontrak-h.user-confirm = '' THEN
                DO:
                   DO ix = 1 TO aItems:LENGTH:
                       oItems = aItems:GetJsonObject(ix).
                       ASSIGN 
                           ikdstn    = oItems:GetCharacter('kdstn').
                           idisc     = oItems:GetDecimal('disc').
                           ippn      = oItems:GetDecimal('ppn').
                           ikdbar    = oItems:GetCharacter('kdbar').
                           iharga    = oItems:GetDecimal('price').
                       FIND FIRST kontrak-d WHERE kontrak-d.kontrakno = kontrak-h.kontrakno AND
                                      kontrak-d.kdbar = ikdbar AND
                                      kontrak-d.kdstn = ikdstn NO-LOCK NO-ERROR.
                       IF AVAIL kontrak-d THEN DO:
                            FIND FIRST masbar WHERE masbar.kdbar = kontrak-d.kdbar NO-ERROR.
                            IF AVAIL masbar THEN DO:
                                FIND FIRST satuan WHERE satuan.kdstn = kontrak-d.kdstn NO-ERROR.
                                IF AVAIL satuan THEN DO:
                                    errorcnt = YES.
                                    errormessages = "Items with id '" + masbar.kdbar + " (" + masbar.nmbar + ") - " + satuan.ket + "' already exists in Contract '" + kontrak-h.kontrakno + "' and not approved. Please Approve the Contract First!".
                                    UNDO p, LEAVE p.
                                END.
                            END.
                       END.
                   END.
                END.
                ELSE DO:
                    IF kontrak-h.kontrak-date <= ikontrak-date AND kontrak-h.end-kontrak-date >= iend-kontrak-date THEN
                    DO:
                       DO ix = 1 TO aItems:LENGTH:
                           oItems = aItems:GetJsonObject(ix).
                           ASSIGN 
                               ikdstn    = oItems:GetCharacter('kdstn').
                               idisc     = oItems:GetDecimal('disc').
                               ippn      = oItems:GetDecimal('ppn').
                               ikdbar    = oItems:GetCharacter('kdbar').
                               iharga    = oItems:GetDecimal('price').
                           FIND FIRST kontrak-d WHERE kontrak-d.kontrakno = kontrak-h.kontrakno AND
                                          kontrak-d.kdbar = ikdbar AND
                                          kontrak-d.kdstn = ikdstn NO-LOCK NO-ERROR.
                           IF AVAIL kontrak-d THEN DO:
                                FIND FIRST masbar WHERE masbar.kdbar = kontrak-d.kdbar NO-ERROR.
                                IF AVAIL masbar THEN DO:
                                    errorcnt = YES.
                                    errormessages = "Contract with Items id " + masbar.kdbar + " - " + masbar.nmbar + " already exists with same periode. Please select another Purchase Unit or Remove the Items !".
                                    UNDO p, LEAVE p.
                                END.
                           END.
                       END.
                    END.
                END.
            END.
        END.
        
        
        IF errorcnt THEN
        DO:
            errorValidation(500, errormessages).
        END.
        
        DO ix = 1 TO aItems:LENGTH:
            oItems = aItems:GetJsonObject(ix).
            ASSIGN 
            ikdstn    = oItems:GetCharacter('kdstn').
            idisc     = oItems:GetDecimal('disc').
            ippn      = oItems:GetDecimal('ppn').
            ikdbar    = oItems:GetCharacter('kdbar').
            iharga    = oItems:GetDecimal('price').
            
            IF iharga <> 0 AND iharga <> ?  THEN DO:           
                 CREATE kontrak-d.
                 ASSIGN
                     kontrak-d.kontrakno    = nourut
                     kontrak-d.crdate       = TODAY
                     kontrak-d.crtime       = STRING(TIME,"HH:MM:SS")
                     kontrak-d.cruser       = iuserid
                     kontrak-d.harga        = iharga
                     kontrak-d.disc         = idisc
                     kontrak-d.disc-rp      = (iharga  * idisc) / 100
                     kontrak-d.kdstn        = ikdstn
                     kontrak-d.ppn-rp       = iharga * ippn / 100
                     kontrak-d.kdbar        = ikdbar.
            END.
        END.
         
        CREATE kontrak-h.
        ASSIGN
             kontrak-h.kontrakno        = nourut
             kontrak-h.crdate           = TODAY
             kontrak-h.sup-kd           = isup-kd
             kontrak-h.crtime           = STRING(TIME,"HH:MM:SS")
             kontrak-h.cruser           = iuserid
             kontrak-h.currency         = icurrency
             kontrak-h.rate             = irate
             kontrak-h.catatan          = icatatan
             kontrak-h.kontrak-date     = ikontrak-date
             kontrak-h.end-kontrak-date = iend-kontrak-date
             kontrak-h.top              = itop
             kontrak-h.dept-kd          = "ACC"
             kontrak-h.divisi-kd        = idiv-kd
             kontrak-h.subdiv-kd        = isubdiv-kd.  
          
        vStatusCode  = 200.
        JsonResponse = NEW JsonObject().
        JsonResponse:Add('message', 'Contract Created Successfull').  
        
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
                                      
        RETURN 0. 
         
      END METHOD.
      
      /*------------------------------------------------------------------------------
            Purpose:                                                                
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
       METHOD OVERRIDE PROTECTED INTEGER HandleDelete( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
         DEFINE VARIABLE oResponse   AS OpenEdge.Net.HTTP.IHttpResponse  NO-UNDO.
            DEFINE VARIABLE oWriter     AS OpenEdge.Web.WebResponseWriter   NO-UNDO.
            DEFINE VARIABLE oBody       AS OpenEdge.Core.String             NO-UNDO.
            DEFINE VARIABLE lcString    AS LONGCHAR                         NO-UNDO.
            
            DEFINE VARIABLE jsResponse  AS JsonObject                       NO-UNDO.
            DEFINE VARIABLE jsRequest   AS JsonObject                       NO-UNDO.
            
            DEFINE VARIABLE ikontrakno  AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE iuserid     AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE itoken      AS CHARACTER                        NO-UNDO.
            
            itoken = poRequest:GetPathParameter('token').
            jsRequest = CAST(poRequest:Entity, JsonObject).
            ASSIGN 
            ikontrakno = jsRequest:GetCharacter("kontrakno").
            
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
                iuserid = x-opera.op-code.
            END.
        
            FIND FIRST kontrak-h WHERE kontrak-h.kontrakno = ikontrakno NO-ERROR.
            IF AVAIL kontrak-h THEN DO:
               ASSIGN
               kontrak-h.user-batal = iuserid
               kontrak-h.tgl-batal  = TODAY.
            END.
            
            RELEASE kontrak-h.
            jsResponse = NEW JsonObject().
            jsResponse:Add('message', 'Kontrak Declined').
            
            ASSIGN 
                oResponse            = NEW OpenEdge.Web.WebResponse().
                              
            ASSIGN 
                lcString = jsResponse:GetJsonText()
                oBody = NEW OpenEdge.Core.String(lcString).
            
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