 
 /*------------------------------------------------------------------------
    File        : getPOBySupplier
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Wed May 29 09:34:32 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.
USING OpenEdge.Web.DataObject.Writer.JsonObjectValueWriter FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS getPOBySupplier INHERITS WebHandler: 

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
        
        DEFINE VARIABLE aPO         AS JsonArray      NO-UNDO.
        DEFINE VARIABLE oPO       AS JsonObject    NO-UNDO.
        DEFINE VARIABLE aItems    AS JsonArray     NO-UNDO.
        DEFINE VARIABLE oItems    AS JsonObject    NO-UNDO.
        
        DEFINE VARIABLE itoken      AS CHARACTER     NO-UNDO.
        DEFINE VARIABLE vsup        AS CHARACTER     NO-UNDO.    
        DEFINE VARIABLE lString     AS LONGCHAR      NO-UNDO.
        DEFINE VARIABLE idiv        AS CHARACTER        NO-UNDO.
        DEFINE VARIABLE isubdiv     AS CHARACTER        NO-UNDO.
        DEFINE VARIABLE ix          AS INTEGER NO-UNDO.
        DEFINE VARIABLE errorCount    AS INTEGER NO-UNDO.
        DEFINE VARIABLE counter     AS INTEGER NO-UNDO.
            
        vsup    = poRequest:GetPathParameter("supkd").
        itoken  = poRequest:GetPathParameter("token").
        
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
            idiv = x-opera.divisi-kd.
            isubdiv = x-opera.subdiv-kd.
        END.
        /*Validation end*/
        
        
        
        aPO = NEW JsonArray().
        FOR EACH po-h WHERE po-h.sup-kd = vsup NO-LOCK BY po-h.po-date DESCENDING:
            errorCount = 0.
            counter = 0.
            
            FOR EACH po-d WHERE po-d.po-no = po-h.po-no NO-LOCK : 
            errorCount = po-d.qty - po-d.qty-terima.
            IF errorCount <> 0 THEN counter = counter + 1.
            END.
            
            if counter = 0 THEN NEXT.

            oPO = NEW JsonObject().
            oPO:Add("po_no", po-h.po-no).
            oPO:Add("po_date", STRING(YEAR(po-h.po-date)) + "-" + STRING(MONTH(po-h.po-date)) + "-" + STRING(DAY(po-h.po-date))).
            oPO:Add("pr_no", po-h.pr-no).
            oPO:Add("pr_date", STRING(YEAR(po-h.pr-date)) + "-" + STRING(MONTH(po-h.pr-date)) + "-" + STRING(DAY(po-h.pr-date))).
            oPo:Add("sup_kode", po-h.sup-kd).
            FIND FIRST t-sup WHERE t-sup.sup-kd = po-h.sup-kd NO-LOCK NO-ERROR.
            IF AVAIL t-sup THEN DO:     
                oPO:Add("sup_kd", t-sup.sup-kd).
                oPO:Add("sup_nm", t-sup.sup-nm).
            END.
/*            oPO:Add("netto",po-h.netto).                                      */
/*            oPO:Add("disc",po-h.disc).                                        */
/*            oPO:Add("disc_type", po-h.disc-type).                             */
/*            oPO:Add("disc_rp", po-h.disc-rp).                                 */
/*            oPO:Add("tppn_rp", po-h.tppn-rp).                                 */
/*            oPO:Add("grand_total", po-h.grand-total).                         */
/*            oPO:Add("crdate", STRING(po-h.crdate,"99/99/9999")).              */
/*            oPO:Add("crtime", po-h.crtime).                                   */
/*            oPO:Add("cruser", po-h.cruser).                                   */
/*            oPO:Add("upddate", STRING(po-h.upddate,"99/99/9999")).            */
/*            oPO:Add("upduser", po-h.upduser).                                 */
/*            oPO:Add("f_status", po-h.f-status).                               */
/*            oPO:Add("user_batal", po-h.user-batal).                           */
/*            oPO:Add("tgl_batal", STRING(po-h.tgl-batal,"99/99/9999")).        */
/*            oPO:Add("expired_date", STRING(po-h.expired-date,"99/99/9999")).  */
/*            oPO:Add("expected_date", STRING(po-h.expected-date,"99/99/9999")).*/
            FIND FIRST holding.dept WHERE dept.dept-kd = po-h.dept-kd NO-LOCK NO-ERROR.
            IF AVAIL holding.dept THEN DO:     
                oPO:Add("dept_kd", dept.dept-nm).
            END.
            FIND FIRST holding.divisi WHERE divisi.divisi-kd = po-h.divisi-kd  NO-LOCK NO-ERROR.
            IF AVAIL holding.divisi THEN DO:
                oPO:Add("divisi_kd", divisi.divisi-nm).
            END.
            FIND FIRST holding.sub-divisi WHERE sub-divisi.subdiv-kd = po-h.subdiv-kd NO-LOCK NO-ERROR.
            IF AVAIL holding.sub-divisi THEN DO:
            oPO:Add("subdiv_kd", sub-divisi.subdiv-nm).
            END.
            oPO:Add("kontrakno", po-h.kontrakno).
            oPO:Add("kontrak_date", STRING(po-h.kontrak-date,"99/99/9999")).
/*            oPO:Add("f-complete", po-h.f-complete).                 */
/*            oPO:Add("user_conf", po-h.user-conf).                   */
/*            oPO:Add("tgl_conf", STRING(po-h.tgl-conf,"99/99/9999")).*/
            aPO:Add(oPO).
        END.
        
        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse()
            .          
        ASSIGN 
            lstring = aPO:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lString).
        
        ASSIGN 
            oResponse:Entity        = aPO
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