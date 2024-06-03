 
 /*------------------------------------------------------------------------
    File        : getPODetail
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Wed May 08 09:26:29 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS getPODetail INHERITS WebHandler: 

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
        
        DEFINE VARIABLE itoken    AS CHARACTER     NO-UNDO.
        DEFINE VARIABLE oPO       AS JsonObject    NO-UNDO.
        DEFINE VARIABLE aItems    AS JsonArray     NO-UNDO.
        DEFINE VARIABLE oItems    AS JsonObject    NO-UNDO.
        DEFINE VARIABLE vPoNo     AS CHARACTER     NO-UNDO.    
        DEFINE VARIABLE lString   AS LONGCHAR      NO-UNDO.
        DEFINE VARIABLE idiv        AS CHARACTER        NO-UNDO.
        DEFINE VARIABLE isubdiv     AS CHARACTER        NO-UNDO.
        
        vPoNo = poRequest:GetPathParameter("pono").
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
            idiv = x-opera.divisi-kd.
            isubdiv = x-opera.subdiv-kd.
        END.
        /*Validation end*/
        
        oPO = NEW JsonObject().
        FIND FIRST po-h WHERE po-h.po-no = vPoNo NO-LOCK NO-ERROR.
        IF AVAIL po-h THEN DO:     
            
            oPO:Add("po_no", po-h.po-no).
            oPO:Add("po_date", STRING(po-h.po-date, "99/99/9999")).
/*            oPO:Add("pr_no", po-h.pr-no).                         */
/*            oPO:Add("pr_date", STRING(po-h.pr-date,"99/99/9999")).*/
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
/*            FIND FIRST holding.dept WHERE dept.dept-kd = po-h.dept-kd NO-LOCK NO-ERROR.                */
/*            IF AVAIL holding.dept THEN DO:                                                             */
/*                oPO:Add("dept_kd", dept.dept-nm).                                                      */
/*            END.                                                                                       */
/*                                                                                                       */
/*            FIND FIRST holding.divisi WHERE divisi.divisi-kd = po-h.divisi-kd  NO-LOCK NO-ERROR.       */
/*            IF AVAIL holding.divisi THEN DO:                                                           */
/*                oPO:Add("divisi_kd", divisi.divisi-nm).                                                */
/*            END.                                                                                       */
/*            FIND FIRST holding.sub-divisi WHERE sub-divisi.subdiv-kd = po-h.subdiv-kd NO-LOCK NO-ERROR.*/
/*            IF AVAIL holding.sub-divisi THEN DO:                                                       */
/*            oPO:Add("subdiv_kd", sub-divisi.subdiv-nm).                                                */
/*            END.                                                                                       */
/*                                                                                                       */
/*            oPO:Add("kontrakno", po-h.kontrakno).                                                      */
/*            oPO:Add("kontrak_date", STRING(po-h.kontrak-date,"99/99/9999")).                           */
/*            oPO:Add("f_complete", po-h.f-complete).                 */
/*            oPO:Add("user_conf", po-h.user-conf).                   */
/*            oPO:Add("tgl_conf", STRING(po-h.tgl-conf,"99/99/9999")).*/
            
            aItems = NEW JsonArray().
            FOR EACH po-d WHERE po-d.po-no = po-h.po-no NO-LOCK: 
                oItems = NEW JsonObject().
                oItems:Add("po_no", po-d.po-no).
                oItems:Add("po_date", STRING(po-d.po-date, "99/99/9999")).
                
                FIND FIRST masbar-sdiv WHERE masbar-sdiv.kdbar = po-d.kdbar AND 
                                                masbar-sdiv.divisi-kd = idiv AND
                                                masbar-sdiv.subdiv-kd = isubdiv NO-ERROR.
                IF AVAIL masbar-sdiv THEN DO :
                     oItems:Add("kdbar", masbar-sdiv.kdbar).
                     oItems:Add("nmbar", masbar-sdiv.nmbar).
                END.
                
                FIND FIRST masbar-jenis WHERE masbar-jenis.kdjns = po-d.kdjns NO-ERROR.
                IF AVAIL masbar-jenis THEN DO:
                    oItems:Add("kdjns", masbar-jenis.kdjns).
                    oItems:Add("nmjns", masbar-jenis.nmjns).
                END.
/*                oItems:Add("kdstn_stok", po-d.kdstn-stok).*/
/*                FIND FIRST holding.masbar WHERE masbar.kdbar = po-d.kdbar NO-ERROR.*/
/*                IF AVAIL holding.masbar THEN DO:                                   */
/*                    oItems:Add("kdbar", masbar.kdbar).                             */
/*                END.                                                               */

/*                FIND FIRST holding.masbar WHERE masbar.kdjns = po-d.kdjns NO-ERROR.*/
/*                IF AVAIL holding.masbar THEN DO:                                   */
/*                    oItems:Add("kdjns", masbar.kdjns).                             */
/*                END.                                                               */

/*                FIND FIRST holding.masbar WHERE masbar.kdstn-stok = po-d.kdstn-stok NO-ERROR.*/
/*                IF AVAIL holding.masbar THEN DO:                                             */
/*                    oItems:Add("kdstn_stok", masbar.kdstn-stok).                             */
/*                END.                                                                         */

/*                oItems:Add("kdstn_krm", po-d.kdstn-krm).*/
                oItems:Add("qty", po-d.qty).
/*                oItems:Add("disc_type", po-d.disc-type).*/
/*                oItems:Add("disc", po-d.disc).          */
/*                oItems:Add("disc_rp", po-d.disc-rp).    */
/*                oItems:Add("ppn", po-d.ppn).            */
/*                oItems:Add("ppn_rp", po-d.ppn-rp).      */
/*                oItems:Add("qty_trm", po-d.qty-trm).    */
/*                FIND FIRST lokasi WHERE lokasi.lok-kd = po-d.lok-kd NO-ERROR.*/
/*                IF AVAIL lokasi THEN DO :                                    */
/*                    oItems:Add("lok_kd", lokasi.lok-nm).                     */
/*                END.                                                         */
/*                oItems:Add("harga", po-d.harga).*/
                oItems:Add("qty_terima", po-d.qty-terima).
                FIND FIRST satuan WHERE satuan.kdstn = po-d.kdstn-beli NO-ERROR.
                IF AVAIL satuan THEN DO:  
                oItems:Add("kdstn_beli", satuan.kdstn).
                oItems:Add("nmstn_beli", satuan.ket).
                END.
                aItems:ADD(oItems).
                END.
                oPo:ADD("items", aItems).
        END.
            
       ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse() 
            .
        ASSIGN 
            lstring = oPO:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lString)
            .
        
        ASSIGN 
            oResponse:Entity        = oPO
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