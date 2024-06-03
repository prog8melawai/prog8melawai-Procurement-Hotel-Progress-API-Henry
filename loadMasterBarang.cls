 
 /*------------------------------------------------------------------------
    File        : loadMasterBarang
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Wed Apr 17 09:00:56 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING OpenEdge.Web.WebResponse.
USING OpenEdge.Net.MultipartEntity.
USING OpenEdge.Net.*.
USING OpenEdge.Core.*.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Net.HTTP.Filter.Payload.*.
USING OpenEdge.Net.HTTP.Filter.Writer.EntityWriterBuilder.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS loadMasterBarang INHERITS WebHandler: 

            
    DEFINE VARIABLE cFileName AS CHAR NO-UNDO.
    
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
        DEFINE VARIABLE lcString    AS LONGCHAR                         NO-UNDO.
        
        aBarang = NEW JsonArray().
        FOR EACH masbar WHERE masbar.kdjns <> "01" NO-LOCK:
            oBarang = NEW JsonObject().
            oBarang:Add("kdbar", masbar.kdbar).
            oBarang:Add("nmbar", masbar.nmbar).
            oBarang:Add("nmbar2", masbar.nmbar2).
            FIND FIRST msjns WHERE masbar.kdjns = msjns.kdjns NO-LOCK NO-ERROR.
            IF AVAIL msjns THEN DO:
                oBarang:Add("kode_jenis", msjns.kdjns). 
                oBarang:Add("nm_jenis", msjns.nmjns).    
            END.
            FIND FIRST satuan WHERE satuan.kdstn = masbar.kdstn-krm NO-ERROR.
            IF AVAIL satuan THEN DO:
                oBarang:Add("kdstn_krm", satuan.kdstn).
                oBarang:Add("nama_krm", satuan.ket).    
            END.
            FIND FIRST satuan WHERE satuan.kdstn = masbar.kdstn-stok NO-ERROR.
            IF AVAIL satuan THEN DO:
                oBarang:Add("kdstn_stok", satuan.kdstn).
                oBarang:Add("nama_stok", satuan.ket).
            END.
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
        
        DEFINE VARIABLE oResponse           AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter             AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oBody               AS OpenEdge.Core.String            NO-UNDO.
        DEFINE VARIABLE lcString            AS LONGCHAR               NO-UNDO.
        
        DEFINE VARIABLE jsonRequest         AS JsonObject                NO-UNDO.
        DEFINE VARIABLE jsonResponse        AS JsonObject                NO-UNDO.
        DEFINE VARIABLE oUser               AS JsonObject                NO-UNDO.
        DEFINE VARIABLE vStatusCode         AS INTEGER                   NO-UNDO.
        
        /*HEADER*/
        DEFINE VARIABLE ipr-no              AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE ideptkd             AS CHARACTER                 NO-UNDO. 
        DEFINE VARIABLE idivkd              AS CHARACTER                 NO-UNDO. 
        DEFINE VARIABLE isubdivkd           AS CHARACTER                 NO-UNDO.       
                
         /*DETAIL*/  
        DEFINE VARIABLE iprno               AS CHARACTER                 NO-UNDO.      
        DEFINE VARIABLE ikdbar              AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE inmbar              AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE ikdjns              AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE ikdstn-stok         AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE ikdstn-krm          AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE iqty                AS DECIMAL                   NO-UNDO.
        DEFINE VARIABLE irevisenote         AS CHARACTER                 NO-UNDO.
        DEFINE VARIABLE iqtyrevise          AS DECIMAL                   NO-UNDO.
       
       
        DEFINE VARIABLE aItems              AS JsonArray                 NO-UNDO.
        DEFINE VARIABLE oItems              AS JsonObject                NO-UNDO.
        DEFINE VARIABLE ix                  AS INTEGER                   NO-UNDO.
        
        DEFINE VARIABLE iToken              AS CHARACTER                 NO-UNDO.       
        DEFINE VARIABLE jsRequest           AS JsonObject                NO-UNDO.
        DEFINE VARIABLE iitoken             AS CHARACTER                        NO-UNDO.
        DEFINE VARIABLE tmpint              AS INT.
        DEFINE VARIABLE nourut              AS CHARACTER.
        DEFINE VARIABLE fItems              AS JsonObject   NO-UNDO.
        DEFINE VARIABLE fprno               AS CHARACTER    NO-UNDO.
        DEFINE VARIABLE errorcnt            AS LOGICAL      NO-UNDO.
        DEFINE VARIABLE errormessages       AS CHARACTER    NO-UNDO.
        DEFINE VARIABLE iuserid             AS CHARACTER    NO-UNDO.
        
        iToken = poRequest:GetPathParameter('token').
        
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
        
        jsRequest = CAST(poRequest:Entity, JsonObject).
        aItems = jsRequest:GetJsonArray("items").
        
        ASSIGN
            ideptkd   = jsRequest:GetCharacter("deptkd").
            idivkd    = jsRequest:GetCharacter("divkd").
            isubdivkd = jsRequest:GetCharacter("subdivkd").

         FIND LAST procurement.pr-h NO-LOCK NO-ERROR.
         IF AVAIL  pr-h THEN DO:
             tmpint = INT(pr-h.pr-no) + 1.   
         END.
         ELSE
             tmpint = 1.
         
          nourut = STRING(tmpint,'9999999999').
          
          RELEASE pr-h NO-ERROR.
          
          fItems = aItems:GetJsonObject(1).
          fprno = fItems:GetCharacter('pr_no').
          
          //
          p:
          DO TRANSACTION:
              errorcnt = NO.
              DO ix = 1 TO aItems:LENGTH:
              ASSIGN 
                  oItems = aItems:GetJsonObject(ix)
                  ikdbar  = oItems:GetCharacter('kode_barang').
                  
                  FIND FIRST kontrak-d WHERE kontrak-d.kdbar = ikdbar NO-LOCK NO-ERROR.
                  IF NOT AVAIL kontrak-d THEN DO:
                      FIND FIRST masbar WHERE masbar.kdbar = ikdbar NO-ERROR.
                      IF AVAIL masbar THEN DO:
                          errorcnt = YES.
                          errormessages = "Items with id " + masbar.kdbar + " - " + masbar.nmbar + " does not have a contract with any supplier. Please Create Contract First!".  
                          UNDO p, LEAVE p.
                      END.
                  END.
                  IF AVAIL kontrak-d THEN DO:
                      FIND FIRST kontrak-h WHERE kontrak-h.kontrakno = kontrak-d.kontrakno AND
                                                 kontrak-h.user-confirm <> '' AND
                                                 kontrak-h.tglconf <> ? NO-LOCK NO-ERROR.
                      IF NOT AVAIL kontrak-h THEN DO:
                          FIND FIRST masbar WHERE masbar.kdbar = kontrak-d.kdbar NO-ERROR.
                          IF AVAIL masbar THEN DO:
                              errorcnt = YES.
                              errormessages = "Items with id " + masbar.kdbar + " - " + masbar.nmbar + " in Contract " + kontrak-h.kontrakno + " is not approved. Please Approve First!". 
                              UNDO p, LEAVE p.
                          END.
                      END.
                  END.
              END.
          END.
          IF errorcnt THEN
          DO:
            errorValidation(500, errormessages).
          END.
          //Read from here
          FIND FIRST pr-h WHERE pr-h.pr-no = fprno NO-ERROR.
          IF AVAIL pr-h THEN DO:
              ASSIGN
                pr-h.f-revise = NO.
              DO ix = 1 TO aItems:Length :
                    oItems = aItems:GetJsonObject(ix).
                    ASSIGN 
                        iprno       = oItems:GetCharacter('pr_no')   
                        ikdbar      = oItems:GetCharacter('kode_barang')
                        iqty        = oItems:GetDecimal('qty').
                        iqtyrevise  = oItems:GetDecimal('qty_revise').
                FIND FIRST pr-d WHERE pr-d.pr-no = iprno AND
                                      pr-d.kdbar = ikdbar NO-ERROR.
                     IF AVAIL pr-d THEN DO:   
                         IF iqty <> 0 AND iqty <> ?  THEN DO:                
                             ASSIGN
                                 pr-d.qty-old      = iqty
                                 pr-d.qty          = iqtyrevise.
                         END.
                     END.    
                END.   
          END.
          IF NOT AVAIL pr-h THEN DO:

             FIND FIRST x-opera WHERE x-opera.op-code = iuserid NO-LOCK NO-ERROR.
             IF AVAIL x-opera THEN DO:
             /*HEADER*/
             
             CREATE pr-h.
             ASSIGN
                pr-h.pr-no   = nourut
                pr-h.pr-date = TODAY
                pr-h.crdate  = TODAY
                pr-h.cruser  = iuserid
                pr-h.crtime  = STRING(TIME,"HH:MM:SS")
                pr-h.dept-kd = ideptkd
                pr-h.divisi-kd = idivkd
                pr-h.subdiv-kd = isubdivkd.
                        
                DO ix = 1 TO aItems:Length :
                    oItems = aItems:GetJsonObject(ix).
                    ASSIGN 
                        iprno       = oItems:GetCharacter('pr_no')   
                        ikdbar      = oItems:GetCharacter('kode_barang')
                        inmbar      = oItems:GetCharacter('nama_barang')
                        ikdjns      = oItems:GetCharacter('kd_jenis')
                        ikdstn-stok = oItems:GetCharacter('kdstn_stock')
                        ikdstn-krm  = oItems:GetCharacter('kdstn_krm')
                        iqty        = oItems:GetDecimal('qty').
                        iqtyrevise  = oItems:GetDecimal('qty_revise').
                        irevisenote = oItems:GetCharacter('revise_note').
                FIND FIRST pr-d WHERE pr-d.pr-no = nourut AND
                                      pr-d.kdbar = ikdbar AND
                                      pr-d.pr-date = TODAY NO-ERROR.
                     IF NOT AVAIL pr-d THEN DO:   
                         IF iqty <> 0 AND iqty <> ?  THEN DO:                
                             CREATE pr-d.
                             ASSIGN
                                 pr-d.pr-no        = nourut
                                 pr-d.pr-date      = TODAY
                                 pr-d.kdbar        = ikdbar
                                 pr-d.nmbar        = inmbar
                                 pr-d.kdjns        = ikdjns
                                 pr-d.kdstn-stok   = ikdstn-stok
                                 pr-d.kdstn-krm    = ikdstn-krm
                                 pr-d.qty-old      = 0
                                 pr-d.qty          = iqty.
                         END.
                     END.    
                END.
             END.             
          END.
        
       
        
        vStatusCode  = 200.
        JsonResponse = NEW JsonObject().
        JsonResponse:Add('message', 'PR Created Successfull').  
        
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