 
 /*------------------------------------------------------------------------
    File        : getReceivingDetail
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Wed May 08 14:18:07 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS getReceivingDetail INHERITS WebHandler: 

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
            
        DEFINE VARIABLE itoken      AS CHARACTER      NO-UNDO.
        DEFINE VARIABLE oReceiving  AS JsonObject     NO-UNDO.
        DEFINE VARIABLE aItems      AS JsonArray        NO-UNDO.
        DEFINE VARIABLE oItems      AS JsonObject       NO-UNDO. 
        DEFINE VARIABLE lString     AS LONGCHAR         NO-UNDO.
/*        DEFINE VARIABLE vPoNo   AS CHARACTER        NO-UNDO.*/
        DEFINE VARIABLE vNoKarcis   AS CHARACTER        NO-UNDO.        
        DEFINE VARIABLE ix          AS INTEGER          NO-UNDO.
        DEFINE VARIABLE aItemsNested AS JsonArray       NO-UNDO.
        DEFINE VARIABLE oItemsNested AS JsonObject      NO-UNDO.
        DEFINE VARIABLE idiv        AS CHARACTER        NO-UNDO.
        DEFINE VARIABLE isubdiv     AS CHARACTER        NO-UNDO.
        
        vNoKarcis = poRequest:GetPathParameter("nokarcis").
/*        vPoNo = poRequest:GetPathParameter("pono").*/
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
        
        oReceiving = NEW JsonObject().
        FIND FIRST procurement.receiving-h WHERE receiving-h.no-karcis = vNoKarcis NO-LOCK NO-ERROR.
/*        FIND FIRST receiving-d WHERE receiving-d.no-po = vPoNo NO-LOCK NO-ERROR.*/
        
        IF AVAIL receiving-h THEN DO :
            oReceiving:Add("no_karcis", receiving-h.no-karcis).
            oReceiving:Add("tgl_karcis", STRING(YEAR(receiving-h.tgl-karcis)) + "-" + STRING(MONTH(receiving-h.tgl-karcis)) + "-" + STRING(DAY(receiving-h.tgl-karcis))).
            oReceiving:Add("no_sj", receiving-h.no-sj).
            oReceiving:Add("tgl_sj", STRING(YEAR(receiving-h.tgl-sj)) + "-" + STRING(MONTH(receiving-h.tgl-sj)) + "-" + STRING(DAY(receiving-h.tgl-sj))).
            FIND FIRST holding.t-sup WHERE t-sup.sup-kd = receiving-h.sup-kd NO-LOCK NO-ERROR.
            IF AVAIL holding.t-sup THEN DO :
                oReceiving:Add("sup_kd", t-sup.sup-kd).
                oReceiving:Add("sup_nm", t-sup.sup-nm).
            END.
/*            oReceiving:Add("group_type", receiving-h.group-type).*/
            FIND FIRST holding.divisi WHERE divisi.divisi-kd = receiving-h.divisi-kd  NO-LOCK NO-ERROR.
            IF AVAIL holding.divisi THEN DO:
                oReceiving:Add("divisi_kd", divisi.divisi-kd).
                oReceiving:Add("divisi_nm", divisi.divisi-nm).
            END.
            FIND FIRST holding.sub-divisi WHERE sub-divisi.subdiv-kd = receiving-h.subdiv-kd NO-LOCK NO-ERROR.
            IF AVAIL holding.sub-divisi THEN DO:
                oReceiving:Add("subdiv_kd", sub-divisi.subdiv-kd).
                oReceiving:Add("subdiv_nm", sub-divisi.subdiv-nm).
            END.
            FIND FIRST holding.dept WHERE dept.dept-kd = receiving-h.dept-kd NO-LOCK NO-ERROR.
            IF AVAIL holding.dept THEN DO :
                oReceiving:Add("dept_kd", dept.dept-kd).
                oReceiving:Add("dept_nm", dept.dept-nm).
            END.
            FIND FIRST lokasi WHERE lokasi.lok-kd = receiving-h.lok-kd NO-LOCK NO-ERROR.
            IF AVAIL lokasi THEN DO :
                oReceiving:Add("lok_kd", lokasi.lok-kd).
                oReceiving:Add("lok_nm", lokasi.lok-nm).
            END.
/*            oReceiving:Add("netto", receiving-h.netto).*/
/*            aItems = NEW JsonArray().                            */
/*            DO ix = 1 TO 5 :                                     */
/*                    oItems = NEW JsonObject().                   */
/*                    oItems:Add("disc", receiving-h.disc[ix]).    */
/*                    aItems:ADD(oItems).                          */
/*            END.                                                 */
/*            oReceiving:Add("disc",aItems).                       */
/*            aItems = NEW JsonArray().                            */
/*            DO ix = 1 TO 5 :                                     */
/*                    oItems = NEW JsonObject().                   */
/*                    oItems:Add("f_disc", receiving-h.f-disc[ix]).*/
/*                    aItems:ADD(oItems).                          */
/*            END.                                                 */
/*            oReceiving:Add("f_disc",aItems).                     */
/*            oReceiving:Add("disc_rp", receiving-h.disc-rp).*/
/*            oReceiving:Add("ppn", receiving-h.ppn).*/
/*            oReceiving:Add("ppn_rp", receiving-h.ppn-rp).    */
/*            oReceiving:Add("gtotal", receiving-h.gtotal).    */
/*            oReceiving:Add("crc_code", receiving-h.crc-code).*/
            /*CEK LAGI UNTUK KODE PURCHASE, bisa berhubungan ke pr-h*/
/*            FIND FIRST po-h WHERE po-h.po-no = receiving-h.kd-purch NO-LOCK NO-ERROR.*/
/*            IF AVAIL po-h THEN DO :                                                  */
/*                oReceiving:Add("kd_purch", po-h.po-no).                              */
/*            END.                                                                     */
/*            oReceiving:Add("user_entry_rcv", receiving-h.user-entry-rcv).                        */
/*            oReceiving:Add("tgl_entry_rcv", STRING(receiving-h.tgl-entry-rcv, "99/99/9999")).    */
/*            oReceiving:Add("user_confirm_rcv", receiving-h.user-confirm-rcv).                    */
/*            oReceiving:Add("tgl_confirm_rcv", STRING(receiving-h.tgl-confirm-rcv, "99/99/9999")).*/
/*            oReceiving:Add("user_confirm_byr", receiving-h.user-confirm-byr).                    */
/*            oReceiving:Add("tgl_confirm_byr", STRING(receiving-h.tgl-confirm-byr, "99/99/9999")).*/
/*            oReceiving:Add("cara_bayar", receiving-h.cara-bayar).                                */
/*            oReceiving:Add("f_lengkap", receiving-h.f-lengkap).                                  */
/*            oReceiving:Add("f_match", receiving-h.f-match).                                      */
/*            oReceiving:Add("f_match_ppn", receiving-h.f-match-ppn).                              */
/*            oReceiving:Add("tt_no", receiving-h.tt-no).                                          */
/*            oReceiving:Add("tt_tgl", STRING(receiving-h.tt-tgl, "99/99/9999")).                  */
/*            oReceiving:Add("tt_no_ppn", receiving-h.tt-no-ppn).                                  */
/*            oReceiving:Add("tt_tgl_ppn", STRING(receiving-h.tt-tgl-ppn, "99/99/9999")).          */
/*            oReceiving:Add("due_day", receiving-h.due-day).                                      */
/*            oReceiving:Add("iv_no", receiving-h.iv-no).                                          */
/*            oReceiving:Add("iv_tgl", STRING(receiving-h.iv-tgl, "99/99/9999")).                  */
/*            oReceiving:Add("iv_no_ppn", receiving-h.iv-no-ppn).                                  */
/*            oReceiving:Add("iv_tgl_ppn", STRING(receiving-h.iv-tgl-ppn, "99/99/9999")).          */
/*            oReceiving:Add("no_kontrak", receiving-h.no-kontrak).                                */
/*            oReceiving:Add("tgl_load", STRING(receiving-h.tgl-load, "99/99/9999")).              */
/*            oReceiving:Add("tgl_lengkap", STRING(receiving-h.tgl-lengkap, "99/99/9999")).        */
            oReceiving:Add("user_lengkap", receiving-h.user-lengkap).
/*            oReceiving:Add("statusacc", receiving-h.statusacc).*/
/*            oReceiving:Add("rate_beli", receiving-h.rate-beli).*/
            
            aItems = NEW JsonArray().
            FOR EACH receiving-d WHERE receiving-d.no-karcis = receiving-h.no-karcis NO-LOCK:
                oItems = NEW JsonObject().
/*                oItems:Add("group_type", receiving-d.group-type).*/
                oItems:Add("no_karcis", receiving-d.no-karcis).
                oItems:Add("tgl_karcis", STRING(YEAR(receiving-d.tgl-karcis)) + "-" + STRING(MONTH(receiving-d.tgl-karcis)) + "-" + STRING(DAY(receiving-d.tgl-karcis))).
                oItems:Add("no_po", receiving-d.no-po).
                oItems:Add("tgl_po", STRING(YEAR(receiving-d.tgl-po)) + "-" + STRING(MONTH(receiving-d.tgl-po)) + "-" + STRING(DAY(receiving-d.tgl-po))).
                FIND FIRST divisi WHERE divisi.divisi-kd = receiving-d.divisi-kd NO-ERROR.
                IF AVAIL divisi THEN DO :
                    oItems:Add("divisi_kd", divisi.divisi-kd).
                    oItems:Add("divisi_nm", divisi.divisi-nm).
                END.
                
                FIND FIRST sub-divisi WHERE sub-divisi.subdiv-kd = receiving-d.subdiv-kd NO-ERROR.
                IF AVAIL sub-divisi THEN DO :
                    oItems:Add("subdiv_kd", sub-divisi.subdiv-kd).
                    oItems:Add("subdiv_nm", sub-divisi.subdiv-nm).
                END.
                
                FIND FIRST dept WHERE dept.dept-kd = receiving-d.dept-kd NO-ERROR.
                IF AVAIL dept THEN DO : 
                    oItems:Add("dept_kd", dept.dept-kd).
                    oItems:Add("dept_nm", dept.dept-nm).
                END.
                
                FIND FIRST lokasi WHERE lokasi.lok-kd = receiving-d.lok-kd NO-ERROR.
                IF AVAIL lokasi THEN DO :
                    oItems:Add("lok_kd", lokasi.lok-kd).
                    oItems:Add("lok_nm", lokasi.lok-nm).
                END.
/*                oItems:Add("due_day", receiving-d.due-day).*/

                FIND FIRST masbar-sdiv WHERE masbar-sdiv.kdbar = receiving-d.kd-barang AND 
                                                masbar-sdiv.divisi-kd = idiv AND
                                                masbar-sdiv.subdiv-kd = isubdiv NO-ERROR.
                IF AVAIL masbar-sdiv THEN DO :
                     oItems:Add("kd_barang", masbar-sdiv.kdbar).
                     oItems:Add("nm_barang", masbar-sdiv.nmbar).
                END.

                oItems:Add("qty", receiving-d.qty).
                oItems:Add("qty_bonus", receiving-d.qty-bonus).
/*                oItems:Add("harga", receiving-d.harga).*/
                
                FIND FIRST satuan WHERE satuan.kdstn = receiving-d.satuan NO-ERROR.
                IF AVAIL satuan THEN DO:  
                oItems:Add("satuan", satuan.kdstn).
                oItems:Add("nmstn", satuan.ket).
                END.
                
/*                oItems:Add("konversi", receiving-d.konversi).*/
/*                oItems:Add("uom", receiving-d.uom).*/
/*                oItems:Add("sub_total", receiving-d.sub-total).*/
/*                aItemsNested = NEW JsonArray().                        */
/*                DO ix = 1 TO 5 :                                       */
/*                    oItemsNested = NEW JsonObject().                   */
/*                    oItemsNested:Add("disc", receiving-d.disc[ix]).    */
/*                    aItemsNested:ADD(oItemsNested).                    */
/*                END.                                                   */
/*                                                                       */
/*                oItems:Add("disc",aItemsNested).                       */
/*                                                                       */
/*                aItemsNested = NEW JsonArray().                        */
/*                DO ix = 1 TO 5 :                                       */
/*                    oItemsNested = NEW JsonObject().                   */
/*                    oItemsNested:Add("f_disc", receiving-d.f-disc[ix]).*/
/*                    aItemsNested:ADD(oItemsNested).                    */
/*                END.                                                   */
/*                oItems:Add("f_disc",aItemsNested).                     */
/*                oItems:Add("disc_rp", receiving-d.disc-rp).            */
/*                oItems:Add("ppn_bm", receiving-d.ppn-bm).              */
/*                oItems:Add("ppn_bm_rp", receiving-d.ppn-bm-rp).        */
/*                oItems:Add("gtotal", receiving-d.gtotal).              */
/*                oItems:Add("harga_po", receiving-d.harga_po).          */
/*                                                                       */
                FIND FIRST masbar-jenis WHERE masbar-jenis.kdjns = receiving-d.kd-jenis NO-ERROR.
                IF AVAIL masbar-jenis THEN DO:
                    oItems:Add("kd_jenis", masbar-jenis.kdjns).
                    oItems:Add("nm_jenis", masbar-jenis.nmjns).
                END.
                
/*                oItems:Add("acc_no", receiving-d.acc-no).                                    */
/*                oItems:Add("pos_budget_kd", receiving-d.pos-budget-kd).                      */
/*                oItems:Add("kd_jenis_old", receiving-d.kd-jenis-old).                        */
/*                oItems:Add("alasan_beda_harga", receiving-d.alasan-beda-harga).              */
/*                oItems:Add("user_cek_harga", receiving-d.user-cek-harga).                    */
/*                oItems:Add("tgl_cek_harga", STRING(receiving-d.tgl-cek-harga, "99/99/9999")).*/
                oItems:Add("statusacc", receiving-d.statusacc).
                aItems:ADD(oItems).

                END.
                oReceiving:Add("items", aItems).
            END.
        
        
        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse() 
            .               
        ASSIGN 
            lString = oReceiving:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lString)
            .
        
        ASSIGN 
            oResponse:Entity        = oReceiving
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