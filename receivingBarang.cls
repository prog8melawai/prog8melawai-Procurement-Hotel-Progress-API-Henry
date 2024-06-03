 
 /*------------------------------------------------------------------------
    File        : receivingBarang
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Tue May 07 11:30:39 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.




CLASS receivingBarang INHERITS WebHandler: 
    
/*    DEF TEMP-TABLE temp  LIKE receiving-d.*/
/*    DEF TEMP-TABLE temp-poh LIKE po-h.    */
/*    DEF TEMP-TABLE temp-pod LIKE po-d.    */

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
        
        DEFINE VARIABLE itoken    AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE aReceiving AS JsonArray      NO-UNDO.
        DEFINE VARIABLE oReceiving AS JsonObject     NO-UNDO.
        DEFINE VARIABLE aItems AS JsonArray      NO-UNDO.
        DEFINE VARIABLE oItems AS JsonObject      NO-UNDO.
        
        DEFINE VARIABLE lString AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE ix AS INTEGER NO-UNDO.
        DEFINE VARIABLE sortUrl AS CHARACTER NO-UNDO.
        
        itoken = poRequest:GetPathParameter('token').
        sortUrl = poRequest:GetPathParameter('sort').
          
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
        END.
        /*Validation end*/
        
        aReceiving = NEW JsonArray().
        message "sorturl :".
        message sortUrl.
        IF sortUrl = "ASC" THEN DO:
               FOR EACH receiving-h NO-LOCK BY receiving-h.tgl-karcis :
                   oReceiving = NEW JsonObject().
                oReceiving:Add("no_karcis", receiving-h.no-karcis).
                oReceiving:Add("tgl_karcis", STRING(receiving-h.tgl-karcis, "99/99/9999")).
                oReceiving:Add("no_sj", receiving-h.no-sj).
                oReceiving:Add("tgl_sj", STRING(receiving-h.tgl-sj, "99/99/9999")).

                FIND FIRST holding.t-sup WHERE t-sup.sup-kd = receiving-h.sup-kd NO-LOCK NO-ERROR.
                IF AVAIL holding.t-sup THEN DO :
                    oReceiving:Add("sup_kode", t-sup.sup-kd).
                    oReceiving:Add("sup_kd", t-sup.sup-nm).
                END.
/*                oReceiving:Add("group_type", receiving-h.group-type).*/
                FIND FIRST holding.divisi WHERE divisi.divisi-kd = receiving-h.divisi-kd  NO-LOCK NO-ERROR.
                IF AVAIL holding.divisi THEN DO:
                    oReceiving:Add("divisi_kode", divisi.divisi-kd).
                    oReceiving:Add("divisi_kd", divisi.divisi-nm).
                END.
                FIND FIRST holding.sub-divisi WHERE sub-divisi.subdiv-kd = receiving-h.subdiv-kd NO-LOCK NO-ERROR.
                IF AVAIL holding.sub-divisi THEN DO:
                    oReceiving:Add("subdiv_kode", sub-divisi.subdiv-kd).
                    oReceiving:Add("subdiv_kd", sub-divisi.subdiv-nm).
                END.
                FIND FIRST holding.dept WHERE dept.dept-kd = receiving-h.dept-kd NO-LOCK NO-ERROR.
                IF AVAIL holding.dept THEN DO :
                    oReceiving:Add("dept_kode", dept.dept-kd).
                    oReceiving:Add("dept_kd", dept.dept-nm).
                END.
                FIND FIRST lokasi WHERE lokasi.lok-kd = receiving-h.lok-kd NO-LOCK NO-ERROR.
                IF AVAIL lokasi THEN DO :
                    oReceiving:Add("lok_kode", lokasi.lok-kd).
                    oReceiving:Add("lok_kd", lokasi.lok-nm).
                END.

/*                oReceiving:Add("netto", receiving-h.netto).*/
/*                aItems = NEW JsonArray().                            */
/*                DO ix = 1 TO 5 :                                     */
/*                    IF receiving-h.disc[ix] > 0 THEN DO:             */
/*                        oItems = NEW JsonObject().                   */
/*                        oItems:Add("disc", receiving-h.disc[ix]).    */
/*                        aItems:ADD(oItems).                          */
/*                    END.                                             */
/*                END.                                                 */
/*                oReceiving:Add("disc",aItems).                       */
/*                aItems = NEW JsonArray().                            */
/*                DO ix = 1 TO 5 :                                     */
/*                    IF receiving-h.f-disc[ix] = YES THEN DO :        */
/*                        oItems = NEW JsonObject().                   */
/*                        oItems:Add("f_disc", receiving-h.f-disc[ix]).*/
/*                        aItems:ADD(oItems).                          */
/*                    END.                                             */
/*                END.                                                 */
/*                oReceiving:Add("f_disc",aItems).                     */
/*                oReceiving:Add("disc_rp", receiving-h.disc-rp).*/
/*                oReceiving:Add("ppn", receiving-h.ppn).*/
/*                oReceiving:Add("ppn_rp", receiving-h.ppn-rp).*/
/*                oReceiving:Add("gtotal", receiving-h.gtotal).*/
/*                oReceiving:Add("crc_code", receiving-h.crc-code).*/
/*                oReceiving:Add("kd_purch", receiving-h.kd-purch).*/
/*                oReceiving:Add("user_entry_rcv", receiving-h.user-entry-rcv).                        */
/*                oReceiving:Add("tgl_entry_rcv", STRING(receiving-h.tgl-entry-rcv, "99/99/9999")).    */
/*                oReceiving:Add("user_confirm_rcv", receiving-h.user-confirm-rcv).                    */
/*                oReceiving:Add("tgl_confirm_rcv", STRING(receiving-h.tgl-confirm-rcv, "99/99/9999")).*/
/*                oReceiving:Add("user_confirm_byr", receiving-h.user-confirm-byr).                    */
/*                oReceiving:Add("tgl_confirm_byr", STRING(receiving-h.tgl-confirm-byr, "99/99/9999")).*/
/*                oReceiving:Add("cara_bayar", receiving-h.cara-bayar).                                */
/*                oReceiving:Add("f_lengkap", receiving-h.f-lengkap).                                  */
/*                oReceiving:Add("f_match", receiving-h.f-match).                                      */
/*                oReceiving:Add("f_match_ppn", receiving-h.f-match-ppn).                              */
/*                oReceiving:Add("tt_no", receiving-h.tt-no).                                          */
/*                oReceiving:Add("tt_tgl", STRING(receiving-h.tt-tgl, "99/99/9999")).                  */
/*                oReceiving:Add("tt_no_ppn", receiving-h.tt-no-ppn).                                  */
/*                oReceiving:Add("tt_tgl_ppn", STRING(receiving-h.tt-tgl-ppn, "99/99/9999")).          */
/*                oReceiving:Add("due_day", receiving-h.due-day).                                      */
/*                oReceiving:Add("iv_no", receiving-h.iv-no).                                          */
/*                oReceiving:Add("iv_tgl", STRING(receiving-h.iv-tgl, "99/99/9999")).                  */
/*                oReceiving:Add("iv_no_ppn", receiving-h.iv-no-ppn).                                  */
/*                oReceiving:Add("iv_tgl_ppn", STRING(receiving-h.iv-tgl-ppn, "99/99/9999")).          */
                oReceiving:Add("no_kontrak", receiving-h.no-kontrak).
/*                oReceiving:Add("tgl_load", STRING(receiving-h.tgl-load, "99/99/9999")).      */
/*                oReceiving:Add("tgl_lengkap", STRING(receiving-h.tgl-lengkap, "99/99/9999")).*/
/*                oReceiving:Add("user_lengkap", receiving-h.user-lengkap).                    */
                oReceiving:Add("statusacc", receiving-h.statusacc).
/*                oReceiving:Add("rate_beli", receiving-h.rate-beli).*/
                aReceiving:ADD(oReceiving).
                END.
        END.
        ELSE  DO :
                FOR EACH receiving-h NO-LOCK BY receiving-h.tgl-karcis DESCENDING :
                    oReceiving = NEW JsonObject().
                oReceiving:Add("no_karcis", receiving-h.no-karcis).
                oReceiving:Add("tgl_karcis", STRING(receiving-h.tgl-karcis, "99/99/9999")).
                oReceiving:Add("no_sj", receiving-h.no-sj).
                oReceiving:Add("tgl_sj", STRING(receiving-h.tgl-sj, "99/99/9999")).

                FIND FIRST holding.t-sup WHERE t-sup.sup-kd = receiving-h.sup-kd NO-LOCK NO-ERROR.
                IF AVAIL holding.t-sup THEN DO :
                    oReceiving:Add("sup_kode", t-sup.sup-kd).
                    oReceiving:Add("sup_kd", t-sup.sup-nm).
                END.
/*                oReceiving:Add("group_type", receiving-h.group-type).*/
                FIND FIRST holding.divisi WHERE divisi.divisi-kd = receiving-h.divisi-kd  NO-LOCK NO-ERROR.
                IF AVAIL holding.divisi THEN DO:
                    oReceiving:Add("divisi_kode", divisi.divisi-kd).
                    oReceiving:Add("divisi_kd", divisi.divisi-nm).
                END.
                FIND FIRST holding.sub-divisi WHERE sub-divisi.subdiv-kd = receiving-h.subdiv-kd NO-LOCK NO-ERROR.
                IF AVAIL holding.sub-divisi THEN DO:
                    oReceiving:Add("subdiv_kode", sub-divisi.subdiv-kd).
                    oReceiving:Add("subdiv_kd", sub-divisi.subdiv-nm).
                END.
                FIND FIRST holding.dept WHERE dept.dept-kd = receiving-h.dept-kd NO-LOCK NO-ERROR.
                IF AVAIL holding.dept THEN DO :
                    oReceiving:Add("dept_kode", dept.dept-kd).
                    oReceiving:Add("dept_kd", dept.dept-nm).
                END.
                FIND FIRST lokasi WHERE lokasi.lok-kd = receiving-h.lok-kd NO-LOCK NO-ERROR.
                IF AVAIL lokasi THEN DO :
                    oReceiving:Add("lok_kode", lokasi.lok-kd).
                    oReceiving:Add("lok_kd", lokasi.lok-nm).
                END.

/*                oReceiving:Add("netto", receiving-h.netto).*/
/*                aItems = NEW JsonArray().                            */
/*                DO ix = 1 TO 5 :                                     */
/*                    IF receiving-h.disc[ix] > 0 THEN DO:             */
/*                        oItems = NEW JsonObject().                   */
/*                        oItems:Add("disc", receiving-h.disc[ix]).    */
/*                        aItems:ADD(oItems).                          */
/*                    END.                                             */
/*                END.                                                 */
/*                oReceiving:Add("disc",aItems).                       */
/*                aItems = NEW JsonArray().                            */
/*                DO ix = 1 TO 5 :                                     */
/*                    IF receiving-h.f-disc[ix] = YES THEN DO :        */
/*                        oItems = NEW JsonObject().                   */
/*                        oItems:Add("f_disc", receiving-h.f-disc[ix]).*/
/*                        aItems:ADD(oItems).                          */
/*                    END.                                             */
/*                END.                                                 */
/*                oReceiving:Add("f_disc",aItems).                     */
/*                oReceiving:Add("disc_rp", receiving-h.disc-rp).                                      */
/*                oReceiving:Add("ppn", receiving-h.ppn).                                              */
/*                oReceiving:Add("ppn_rp", receiving-h.ppn-rp).                                        */
/*                oReceiving:Add("gtotal", receiving-h.gtotal).                                        */
/*                oReceiving:Add("crc_code", receiving-h.crc-code).                                    */
/*                oReceiving:Add("kd_purch", receiving-h.kd-purch).                                    */
/*                oReceiving:Add("user_entry_rcv", receiving-h.user-entry-rcv).                        */
/*                oReceiving:Add("tgl_entry_rcv", STRING(receiving-h.tgl-entry-rcv, "99/99/9999")).    */
/*                oReceiving:Add("user_confirm_rcv", receiving-h.user-confirm-rcv).                    */
/*                oReceiving:Add("tgl_confirm_rcv", STRING(receiving-h.tgl-confirm-rcv, "99/99/9999")).*/
/*                oReceiving:Add("user_confirm_byr", receiving-h.user-confirm-byr).                    */
/*                oReceiving:Add("tgl_confirm_byr", STRING(receiving-h.tgl-confirm-byr, "99/99/9999")).*/
/*                oReceiving:Add("cara_bayar", receiving-h.cara-bayar).                                */
/*                oReceiving:Add("f_lengkap", receiving-h.f-lengkap).                                  */
/*                oReceiving:Add("f_match", receiving-h.f-match).                                      */
/*                oReceiving:Add("f_match_ppn", receiving-h.f-match-ppn).                              */
/*                oReceiving:Add("tt_no", receiving-h.tt-no).                                          */
/*                oReceiving:Add("tt_tgl", STRING(receiving-h.tt-tgl, "99/99/9999")).                  */
/*                oReceiving:Add("tt_no_ppn", receiving-h.tt-no-ppn).                                  */
/*                oReceiving:Add("tt_tgl_ppn", STRING(receiving-h.tt-tgl-ppn, "99/99/9999")).          */
/*                oReceiving:Add("due_day", receiving-h.due-day).                                      */
/*                oReceiving:Add("iv_no", receiving-h.iv-no).                                          */
/*                oReceiving:Add("iv_tgl", STRING(receiving-h.iv-tgl, "99/99/9999")).                  */
/*                oReceiving:Add("iv_no_ppn", receiving-h.iv-no-ppn).                                  */
/*                oReceiving:Add("iv_tgl_ppn", STRING(receiving-h.iv-tgl-ppn, "99/99/9999")).          */
                oReceiving:Add("no_kontrak", receiving-h.no-kontrak).
/*                oReceiving:Add("tgl_load", STRING(receiving-h.tgl-load, "99/99/9999")).              */
/*                oReceiving:Add("tgl_lengkap", STRING(receiving-h.tgl-lengkap, "99/99/9999")).        */
/*                oReceiving:Add("user_lengkap", receiving-h.user-lengkap).                            */
                oReceiving:Add("statusacc", receiving-h.statusacc).
/*                oReceiving:Add("rate_beli", receiving-h.rate-beli).*/
                aReceiving:ADD(oReceiving).
                END.
         END.
  
           
        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse()
            
            .    
        ASSIGN 
            lString = aReceiving:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lString)
            .
        
        ASSIGN 
            oResponse:Entity        = aReceiving
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
      METHOD OVERRIDE PROTECTED INTEGER HandlePut( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
     UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").      
      END METHOD.
      
       
     /*------------------------------------------------------------------------------
            Purpose:                                                                
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
     METHOD OVERRIDE PROTECTED INTEGER HandlePost( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
        DEFINE VARIABLE oResponse           AS OpenEdge.Net.HTTP.IHttpResponse  NO-UNDO.
        DEFINE VARIABLE oWriter             AS OpenEdge.Web.WebResponseWriter   NO-UNDO.
        DEFINE VARIABLE oBody               AS OpenEdge.Core.String             NO-UNDO.
        DEFINE VARIABLE lString             AS LONGCHAR                         NO-UNDO.
        DEFINE VARIABLE jsResponse          AS JsonObject                       NO-UNDO.
        DEFINE VARIABLE jsRequest           AS JsonObject                       NO-UNDO.
        DEFINE VARIABLE oUser               AS JsonObject                NO-UNDO.
        DEFINE VARIABLE vStatusCode         AS INTEGER                   NO-UNDO.
        
        DEFINE VARIABLE iqty              AS DECIMAL NO-UNDO.
        DEFINE VARIABLE ikdbarang         AS CHARACTER NO-UNDO.
        DEFINE VARIABLE inopo             AS CHARACTER NO-UNDO.
        DEFINE VARIABLE isupkd            AS CHARACTER NO-UNDO.


        
        /*UTIL*/
        DEFINE VARIABLE iToken              AS CHARACTER                NO-UNDO.      
        DEFINE VARIABLE aItems              AS JsonArray                NO-UNDO.
        DEFINE VARIABLE oItems              AS JsonObject               NO-UNDO.
        DEFINE VARIABLE ix                  AS INTEGER                  NO-UNDO.
        DEFINE VARIABLE iitoken             AS CHARACTER                NO-UNDO.
        DEFINE VARIABLE nourut              AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iuserid             AS CHARACTER    NO-UNDO.
        DEFINE VARIABLE temp_int            AS INT NO-UNDO.
        DEFINE VARIABLE fItems              AS JsonObject   NO-UNDO.
        DEFINE VARIABLE errorcnt            AS LOGICAL      NO-UNDO.
        DEFINE VARIABLE fnopo               AS CHARACTER    NO-UNDO.
        DEFINE VARIABLE errormessages       AS CHARACTER    NO-UNDO.
        DEFINE VARIABLE fkdbar              AS CHARACTER     NO-UNDO.
        DEFINE VARIABLE vQty                AS DECIMAL  NO-UNDO.
        DEFINE VARIABLE vSelisih            AS DECIMAL  NO-UNDO.
        
        /*VALIDATION TOKEN*/
        iToken = poRequest:GetPathParameter('token').
        
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
        END.        
        /*====END VALIDATION====*/
        
        jsRequest = CAST(poRequest:Entity, JsonObject).
        aItems = jsRequest:GetJsonArray("items").
        
        /*GENERATE NO KARCIS*/
         FIND LAST receiving-h NO-LOCK NO-ERROR. 
        IF AVAIL receiving-h THEN DO: 
            temp_int = INT(receiving-h.no-karcis) + 1.
        END.
        ELSE
            temp_int = 1.
        
        nourut = STRING(temp_int,'9999999999').
        RELEASE receiving-h NO-ERROR.
         
       p:
           DO TRANSACTION ON ERROR UNDO p, LEAVE p:
               DO ix = 1 TO aItems:Length :
                        message "DEBUG ix = ".
                        message ix.
                        oItems = aItems:GetJsonObject(ix).
                        ASSIGN
                            inopo       = oItems:GetCharacter('no_po')
                            iqty        = oItems:GetDecimal('qty')
                            ikdbarang   = oItems:GetCharacter('kd_barang')
                            .
                          /*VALIDATE IQTY CANNOT BE 0*/
                         IF iqty = 0 THEN DO :
                             message "Item Skipped : Qty 0".
                             END.
                         IF iqty = 0 THEN NEXT.
/*                             errorcnt = YES.                                         */
/*                             errormessages = "input receiving quantity cannot be 0!".*/
/*                             UNDO p, LEAVE p.*/
                         
                        /*VALIDATION END*/
                        FIND FIRST po-h WHERE po-h.po-no = inopo NO-ERROR.
                            IF AVAIL po-h THEN DO:
                                message "DEBUG FOUND MATCH PO-H".

                                FIND FIRST po-d WHERE   po-d.po-no = inopo AND
                                                        po-d.kdbar = ikdbarang  NO-ERROR.
                                    IF AVAIL po-d THEN DO:
                                        message "DEBUG FOUND MATCH PO-D".

                                        FIND FIRST masbar-sdiv WHERE    masbar-sdiv.kdbar = po-d.kdbar AND
                                                                        masbar-sdiv.divisi-kd = po-h.divisi-kd AND
                                                                        masbar-sdiv.subdiv-kd = po-h.subdiv-kd NO-LOCK NO-ERROR.
                                            IF AVAIL masbar-sdiv THEN DO :
                                            message "DEBUG FOUND MATCH masbar-sdiv".

                                            /*VALIDATE iqty > (po-d.qty - po-d.qty-terima*/
                                            IF iqty > (po-d.qty - po-d.qty-terima) THEN DO :
                                                errorcnt = YES.
                                                errormessages = "input quantity exceeds remaining PO amount!".
                                                UNDO p, LEAVE p.
                                            END.
                                             /*VALIDATION END.*/
/*                                            IF iqty > pr-d.qty THEN DO :                            */
/*                                                errorcnt = YES.                                     */
/*                                                errormessages = "input quantity exceeds PR amount!".*/
/*                                                UNDO p, LEAVE p.                                    */
/*                                            END.                                                    */
                                            /*VALIDATION END.*/
                                            
                                                FIND FIRST t-sup WHERE po-h.sup-kd = t-sup.sup-kd NO-LOCK NO-ERROR.
                                                    IF AVAIL t-sup THEN DO:
                                                        message "DEBUG FOUND MATCH t-sup supkd".
                                                        

                                                    FIND FIRST receiving-d WHERE    receiving-d.no-karcis = nourut AND
                                                                                    receiving-d.tgl-karcis = TODAY AND
                                                                                    receiving-d.kd-barang = ikdbarang NO-ERROR.
                                                        IF NOT AVAIL receiving-d THEN DO :
                                                            /*VALIDATION*/
                                                            message "DEBUG FOUND NOT AVAIL recv-d".
                                                            IF po-d.qty-terima >= po-d.qty THEN DO :
                                                                errorcnt = YES.
                                                                errormessages = "This PO has already been fulfilled. (Qty-terima exceeds Qty)".
                                                                UNDO p, LEAVE p.
                                                                END.
                                                            /*VALIDATION END*/
                                                        END.
        
                                                        message 'Start create receiving-d'
                                                        vqty = 0. /*vqty = sisa po quantity */
                                                        vSelisih = 0. /*vSelisih = jika vqty lebih kecil dari input, dapat qty bonus*/
        
                                                        vQty = po-d.qty - po-d.qty-terima.
                                                        IF vqty < iqty THEN vSelisih = ABSOLUTE(vqty - iqty).
        
                                                        CREATE receiving-d.
                                                        ASSIGN
                                                                    receiving-d.no-karcis   = nourut
                                                                    receiving-d.group-type = "TODO INSERT"
                                                                    receiving-d.tgl-karcis  = TODAY
                                                                    receiving-d.no-po       = inopo
                                                                    receiving-d.tgl-po      = po-d.po-date
                                                                    receiving-d.divisi-kd     = po-h.divisi-kd
                                                                    receiving-d.subdiv-kd   = po-h.subdiv-kd
                                                                    receiving-d.dept-kd     = po-h.dept-kd
                                                                    receiving-d.lok-kd      = po-d.lok-kd
                                                                    receiving-d.due-day     = 1
                                                                    receiving-d.kd-barang   = ikdbarang
                                                                    receiving-d.nm-barang   =  masbar-sdiv.nmbar
                                                                    receiving-d.qty         = iqty - vSelisih
                                                                    receiving-d.qty-bonus   = vSelisih
                                                                    receiving-d.harga       = po-d.harga
                                                                    receiving-d.satuan      = po-d.kdstn-beli
                                                                    receiving-d.konversi    = 1
                                                                    receiving-d.uom         = "TODO INSERT"
                                                                    receiving-d.sub-total   = 1
                                                                    receiving-d.disc        = po-d.disc
                                                                    receiving-d.f-disc      = false
                                                                    receiving-d.disc-rp     = po-d.disc-rp
                                                                    receiving-d.ppn-bm      = po-d.ppn
                                                                    receiving-d.ppn-bm-rp   = po-d.ppn-rp
                                                                    receiving-d.gtotal      = 1
                                                                    receiving-d.harga_po    = po-d.harga
                                                                    receiving-d.kd-jenis    = po-d.kdjns
                                                                    receiving-d.acc-no      = "TODO INSERT"
                                                                    receiving-d.pos-budget-kd   = "TODO INSERT"
                                                                    receiving-d.kd-jenis-old      = po-d.kdjns
                                                                    receiving-d.alasan-beda-harga      = "TODO INSERT"
                                                                    receiving-d.user-cek-harga      = "TODO INSERT"
                                                                    receiving-d.tgl-cek-harga      = TODAY
                                                                    receiving-d.statusacc      = "APPROVED"
        
                                                                    po-d.qty-terima = po-d.qty-terima + iqty
                                                                    .
                                                                    message ' DEBUG RECEIVING-D CREATE SUCCESS!'.
                                                END.
                                                IF NOT AVAIL t-sup THEN DO :
                                                    errorcnt = YES.
                                                    errormessages = "Supplier Not Found!".
                                                    UNDO p, LEAVE p.
                                                END.
                                            END.
                                        /*VALIDATION*/
                                        IF NOT AVAIL masbar-sdiv THEN DO :
                                            errorcnt = YES.
                                            errormessages = "Item with matching kdbarang and division / subdiv Not Found!".
                                            UNDO p, LEAVE p.
                                        END.
                                        /*VALIDATION END*/
                                END.
                                /*VALIDATION*/
                                IF NOT AVAIL po-d THEN DO :
                                    errorcnt = YES.
                                    errormessages = "PO with number " + inopo + " and item code " + ikdbarang + " not found!".
                                    UNDO p, LEAVE p.
                                END.
                                /*VALIDATION END*/
                            END.
                            /*VALIDATION*/
                            IF NOT AVAIL po-h THEN DO :
                                 errorcnt = YES.
                                 errormessages = "PO Number not found!".
                                 UNDO p, LEAVE p.
                            END.
                            /*VALIDATION END*/
                        END.

                        FIND FIRST po-h WHERE po-h.po-no = inopo NO-ERROR.
                            IF AVAIL po-h THEN DO :
                                message 'DEBUG ASSIGN HEADERS START'.

                                FIND FIRST receiving-h WHERE receiving-h.no-karcis = nourut NO-LOCK NO-ERROR.
                                    IF NOT AVAIL receiving-h THEN DO:
                                    message 'DEBUG receiving-h not found'.
                                    CREATE receiving-h.
                                         ASSIGN
                                            receiving-h.no-karcis = nourut
                                            receiving-h.tgl-karcis = TODAY
                                            receiving-h.no-sj = "TODO INSERT"
                                            receiving-h.tgl-sj = TODAY
                                            receiving-h.sup-kd = po-h.sup-kd
                                            receiving-h.group-type = "TODO INSERT"
                                            receiving-h.divisi-kd = po-h.divisi-kd
                                            receiving-h.subdiv-kd = po-h.subdiv-kd
                                            receiving-h.dept-kd = po-h.dept-kd
                                            receiving-h.lok-kd = "TODO INSERT"
                                            receiving-h.netto = po-h.netto
                                            receiving-h.disc[1] = po-h.disc
                                            receiving-h.f-disc[1] = false
                                            receiving-h.disc-rp = po-h.disc-rp
                                            receiving-h.ppn = 1
                                            receiving-h.ppn-rp = po-h.tppn-rp
                                            receiving-h.gtotal = po-h.grand-total
                                            receiving-h.crc-code = "TODO INSERT"
                                            receiving-h.kd-purch = "TODO INSERT"
                                            receiving-h.user-entry-rcv = iuserid
                                            receiving-h.tgl-entry-rcv = TODAY
                                            receiving-h.user-confirm-rcv = ""
                                            receiving-h.tgl-confirm-rcv = ?
                                            receiving-h.user-confirm-byr = ""
                                            receiving-h.tgl-confirm-byr = TODAY
                                            receiving-h.cara-bayar = "TODO INSERT"
                                            receiving-h.f-lengkap = false
                                            receiving-h.f-match = false
                                            receiving-h.f-match-ppn = false
                                            receiving-h.tt-no = "TODO INSERT"
                                            receiving-h.tt-tgl = TODAY
                                            receiving-h.tt-no-ppn = "TODO INSERT"
                                            receiving-h.tt-tgl-ppn = TODAY
                                            receiving-h.due-day = 1
                                            receiving-h.iv-no = "TODO INSERT"
                                            receiving-h.iv-tgl = TODAY
                                            receiving-h.iv-no-ppn = "TODO INSERT"
                                            receiving-h.iv-tgl-ppn = TODAY
                                            receiving-h.no-kontrak = "TODO INSERT"
                                            receiving-h.tgl-load = TODAY
                                            receiving-h.tgl-lengkap = TODAY
                                            receiving-h.user-lengkap = iuserid
                                            receiving-h.statusacc = "WAITING"
                                            receiving-h.rate-beli = 1.
                                            message 'RECEIVING H CREATE SUCCESS!'.
                                        END.
                                    END.
                    END.
          /*VALIDATION BLOCK*/
            IF errorcnt THEN
            DO:
                errorValidation(400, errormessages).
            END. 

         jsResponse = NEW JsonObject().
         jsResponse:Add('message', 'receiving note created successfully!').
         jsResponse:Add('DEBUG nourut', nourut).
         jsResponse:Add('DEBUG aItems length',aItems:LENGTH).
        
            ASSIGN 
                oResponse            = NEW OpenEdge.Web.WebResponse().
                              
            ASSIGN 
/*                lString = aItems:GetJsonText()            */
/*                oBody = NEW OpenEdge.Core.String(lString).*/
                lString = jsResponse:GetJsonText()
                oBody = NEW OpenEdge.Core.String(lString).
            
            ASSIGN 
/*            oResponse:Entity        = aitems*/
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
      
      

/*===========================================================*/
        
      
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
    
    METHOD PUBLIC CHARACTER tempawal    (INPUT ipono AS CHARACTER,
                                         INPUT nourut AS CHARACTER) :
                                             
/*        DEFINE VARIABLE oResponse           AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.*/
/*        DEFINE VARIABLE oWriter             AS OpenEdge.Web.WebResponseWriter  NO-UNDO.*/
/*        DEFINE VARIABLE oBody               AS OpenEdge.Core.String            NO-UNDO.*/
/*        DEFINE VARIABLE lcString            AS LONGCHAR                        NO-UNDO.*/
/*                                                                                       */
/*        DEFINE VARIABLE jsonRequest         AS JsonObject                NO-UNDO.      */
/*        DEFINE VARIABLE JsonResponse        AS JsonObject                NO-UNDO.      */
    
        
        RETURN "ok".
    END METHOD.
    
END CLASS.