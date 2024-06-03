 
 /*------------------------------------------------------------------------
    File        : getSupplier
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Wed Apr 24 15:58:05 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.

USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS getSupplier INHERITS WebHandler: 

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
        
        DEFINE VARIABLE aSupplier     AS JsonArray                      NO-UNDO.
        DEFINE VARIABLE oSupplier     AS JsonObject                     NO-UNDO.
        DEFINE VARIABLE aAlamat       AS JsonArray                      NO-UNDO.
        DEFINE VARIABLE oAlamat       AS JsonObject                     NO-UNDO.
        DEFINE VARIABLE aContactperson       AS JsonArray                      NO-UNDO.
        DEFINE VARIABLE oContactperson       AS JsonObject                     NO-UNDO.
        DEFINE VARIABLE aEmail       AS JsonArray                      NO-UNDO.
        DEFINE VARIABLE oEmail       AS JsonObject                     NO-UNDO.
        DEFINE VARIABLE aTelp        AS JsonArray                      NO-UNDO.
        DEFINE VARIABLE oTelp        AS JsonObject                     NO-UNDO.
        DEFINE VARIABLE aHp          AS JsonArray                      NO-UNDO.
        DEFINE VARIABLE oHp          AS JsonObject                     NO-UNDO.
        DEFINE VARIABLE lcString      AS LONGCHAR                       NO-UNDO.
        DEFINE VARIABLE itoken        AS CHARACTER                      NO-UNDO.
        DEFINE VARIABLE vdiv          AS CHARACTER                     NO-UNDO.
        DEFINE VARIABLE vsubdiv       AS CHARACTER                     NO-UNDO.
        DEFINE VARIABLE varx          AS INTEGER                        NO-UNDO.
        DEFINE VARIABLE vary          AS INTEGER                        NO-UNDO. 
        DEFINE VARIABLE varz          AS INTEGER                        NO-UNDO. 
        DEFINE VARIABLE vara          AS INTEGER                        NO-UNDO. 
        DEFINE VARIABLE varb          AS INTEGER                        NO-UNDO.
        
         DEFINE VARIABLE idiv        AS CHARACTER        NO-UNDO.
        DEFINE VARIABLE isubdiv     AS CHARACTER        NO-UNDO.
        DEFINE VARIABLE ix          AS INTEGER NO-UNDO.
        
         vdiv    = poRequest:GetPathParameter('divisi').
         vsubdiv = poRequest:GetPathParameter('subdivisi').
         itoken  = poRequest:GetPathParameter('token').
         
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
            idiv = x-opera.divisi-kd.
            isubdiv = x-opera.subdiv-kd.
        END.
        /*Validation end*/
        
        aSupplier = NEW JsonArray().
       FOR EACH t-sup-d WHERE t-sup-d.divisi-kd = vdiv AND
                                 t-sup-d.subdiv-kd = vsubdiv NO-LOCK.
            FIND FIRST t-sup WHERE t-sup.sup-kd = t-sup-d.sup-kd AND 
                                   t-sup.f-aktif = YES NO-ERROR.
            IF AVAIL t-sup THEN DO:
/*            IF AVAIL t-sup THEN DO:*/
                oSupplier = NEW JsonObject().
                oSupplier:Add("sup_kd", t-sup.sup-kd).
                oSupplier:Add("sup_kd1", t-sup.sup-kd1).
                oSupplier:Add("sup_kd2", t-sup.sup-kd2).
                oSupplier:Add("sup_nm", t-sup.sup-nm).
/*                oSupplier:Add("sup_acc", t-sup.sup-acc).                             */
/*                oSupplier:Add("sup_ab", t-sup.ab).                                   */
/*                aAlamat = NEW JsonArray().                                           */
/*                DO varx = 1 TO 3 :                                                   */
/*                    oAlamat = NEW JsonObject().                                      */
/*                    IF t-sup.alamat[varx] <> "" THEN DO:                             */
/*                        oAlamat:Add("sup_alamat",t-sup.alamat[varx]).                */
/*                    END.                                                             */
/*                    aAlamat:ADD(oAlamat).                                            */
/*                END.                                                                 */
/*                oSupplier:Add("sup_alamat", aAlamat).                                */
/*                oSupplier:Add("sup_almnpwp", t-sup.alm-npwp).                        */
/*                aContactperson = NEW JsonArray().                                    */
/*                 DO vary = 1 TO 3 :                                                  */
/*                    oContactperson = NEW JsonObject().                               */
/*                    IF t-sup.cont-person[vary] <> "" THEN DO:                        */
/*                        oContactperson:Add("sup_contperson",t-sup.cont-person[vary]).*/
/*                    END.                                                             */
/*                    aContactperson:ADD(oContactperson).                              */
/*                END.                                                                 */
/*                                                                                     */
/*                oSupplier:Add("sup_contperson", aContactperson).                     */
/*                oSupplier:Add("sup_countrykd", t-sup.country-kd).                    */
/*                oSupplier:Add("sup_divisikd", t-sup.divisi-kd).                      */
/*                aEmail = NEW JsonArray().                                            */
/*                DO varz = 1 TO 3 :                                                   */
/*                    oEmail = NEW JsonObject().                                       */
/*                    IF t-sup.alamat[varz] <> "" THEN DO:                             */
/*                        oEmail:Add("sup_email",t-sup.e-mail[varz]).                  */
/*                    END.                                                             */
/*                    aEmail:ADD(oEmail).                                              */
/*                END.                                                                 */
/*                                                                                     */
/*                oSupplier:Add("sup_email", aEmail).                                  */
/*                oSupplier:Add("sup_faktif", t-sup.f-aktif).                          */
/*                oSupplier:Add("sup_fbadanhukum", t-sup.f-badan-hukum).               */
/*                oSupplier:Add("sup_finternal", t-sup.f-internal).                    */
/*                oSupplier:Add("sup_flain", t-sup.f-lain).                            */
/*                oSupplier:Add("sup_flokal", t-sup.f-lokal).                          */
/*                oSupplier:Add("sup_fonline", t-sup.f-online).                        */
/*                oSupplier:Add("sup_frekening", t-sup.f-rekening).                    */
/*                oSupplier:Add("sup_ftransfer", t-sup.f-transfer).                    */
/*                oSupplier:Add("sup_fpdoklain", t-sup.fp-dok-lain).                   */
/*                oSupplier:Add("sup_grouptype", t-sup.group-type).                    */
/*                aHp = NEW JsonArray().                                               */
/*                DO vara = 1 TO 3 :                                                   */
/*                    oHp = NEW JsonObject().                                          */
/*                    IF t-sup.hp[vara] <> "" THEN DO:                                 */
/*                        oHp:Add("sup_alamat", t-sup.hp[vara]).                       */
/*                    END.                                                             */
/*                    aHp:ADD(oHp).                                                    */
/*                END.                                                                 */
/*                                                                                     */
/*                oSupplier:Add("sup_hp", aHp).                                        */
/*                oSupplier:Add("sup_kdbadanhukum", t-sup.kd-badan-hukum).             */
/*                oSupplier:Add("sup_kdjenis", t-sup.kd-jenis).                        */
/*                oSupplier:Add("sup_kdpurch", t-sup.kd-purch).                        */
/*                oSupplier:Add("sup_kdwilayah", t-sup.kd-wilayah).                    */
/*                oSupplier:Add("sup_kecamatan", t-sup.kecamatan).                     */
/*                oSupplier:Add("sup_kelurahan", t-sup.kelurahan).                     */
/*                oSupplier:Add("sup_kodepos", t-sup.kodepos).                         */
/*                oSupplier:Add("sup_kota", t-sup.kota).                               */
/*                oSupplier:Add("sup_nik", t-sup.nik).                                 */
/*                oSupplier:Add("sup_nofax", t-sup.no-fax).                            */
/*                oSupplier:Add("sup_nofds", t-sup.no-fds).                            */
/*                oSupplier:Add("sup_noseri", t-sup.no-seri).                          */
/*                aTelp = NEW JsonArray().                                             */
/*                DO varb = 1 TO 3 :                                                   */
/*                    oTelp = NEW JsonObject().                                        */
/*                    IF t-sup.no-telp[varb] <> "" THEN DO:                            */
/*                        oTelp:Add("sup_alamat",t-sup.no-telp[varb]).                 */
/*                    END.                                                             */
/*                    aTelp:ADD(oTelp).                                                */
/*                END.                                                                 */
/*                oSupplier:Add("sup_notelp", aTelp).                                  */
/*                oSupplier:Add("sup_npkp", t-sup.npkp).                               */
/*                oSupplier:Add("sup_npwp", t-sup.npwp).                               */
/*                oSupplier:Add("sup_propinsi", t-sup.propinsi).                       */
/*                oSupplier:Add("sup_subtype", t-sup.sub-type).                        */
/*                oSupplier:Add("sup_subdivkd", t-sup.subdiv-kd).                      */
/*                oSupplier:Add("sup_supacc", t-sup.sup-acc).                          */
/*                oSupplier:Add("sup_tglberlakudoklain", t-sup.tgl-berlaku-dok-lain).  */
/*                oSupplier:Add("sup_tglconfirm", t-sup.tgl-confirm).                  */
/*                oSupplier:Add("sup_tglcreated", t-sup.tgl-created).                  */
/*                oSupplier:Add("sup_tglmodified", t-sup.tgl-modified).                */
/*                oSupplier:Add("sup_tglnonaktif", t-sup.tgl-non-aktif).               */
/*                oSupplier:Add("sup_tglnonaktifold", t-sup.tgl-non-aktif-old).        */
/*                oSupplier:Add("sup_userconfirm", t-sup.user-confirm).                */
/*                oSupplier:Add("sup_usercreated", t-sup.user-created).                */
/*                oSupplier:Add("sup_user-modified", t-sup.user-modified).             */
/*                oSupplier:Add("sup_usernonaktif", t-sup.user-non-aktif).             */
/*                oSupplier:Add("sup_usernonaktifold", t-sup.user-non-aktif-old).      */
                   
                aSupplier:ADD(oSupplier).        
            END.
        END.    
        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse().
                       
        ASSIGN 
            lcString = aSupplier:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lcString).
        
        ASSIGN 
            oResponse:Entity        = aSupplier
            oResponse:ContentType   = 'application/json':u
            oResponse:ContentLength = oBody:Size
            oResponse:StatusCode    = INTEGER(200).
        
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