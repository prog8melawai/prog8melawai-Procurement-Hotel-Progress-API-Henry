 
 /*------------------------------------------------------------------------
    File        : getSupplierWithPO
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Fri May 31 10:24:18 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS getSupplierWithPO INHERITS WebHandler: 

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
        
        DEFINE VARIABLE aSup         AS JsonArray      NO-UNDO.
        DEFINE VARIABLE oSup       AS JsonObject    NO-UNDO.
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
        
        
        
        DEFINE VARIABLE itoken      AS CHARACTER     NO-UNDO. 
        DEFINE VARIABLE lString     AS LONGCHAR      NO-UNDO.
        DEFINE VARIABLE idiv        AS CHARACTER        NO-UNDO.
        DEFINE VARIABLE isubdiv     AS CHARACTER        NO-UNDO.
        DEFINE VARIABLE ix          AS INTEGER NO-UNDO.
        DEFINE VARIABLE errorCount    AS INTEGER NO-UNDO.
        DEFINE VARIABLE counter     AS INTEGER NO-UNDO.
            
        itoken  = poRequest:GetPathParameter("token").
        
        /*VALIDATE TOKEN & CONNECTION*/
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
        /*VALIDATION END*/
        
        aSup = NEW JsonArray().
        
        
        
        
        
        FOR EACH t-sup-d WHERE t-sup-d.divisi-kd = '11' AND
                               t-sup-d.subdiv-kd = 'P' NO-LOCK.
            FIND FIRST t-sup WHERE t-sup.sup-kd = t-sup-d.sup-kd AND 
                                   t-sup.f-aktif = YES NO-LOCK NO-ERROR.
            IF AVAIL t-sup THEN DO:                
            counter = 0.                     
            errorCount = 0.       
            
            FOR EACH po-h WHERE po-h.sup-kd = t-sup.sup-kd NO-LOCK : 
                FOR EACH po-d WHERE po-d.po-no = po-h.po-no NO-LOCK : 
                    errorCount = po-d.qty - po-d.qty-terima.
                    IF errorCount <> 0 THEN counter = counter + 1.
                END.
            END.  
            
            IF errorCount = 0 THEN NEXT.
                   
            oSup = NEW JsonObject().
            oSup:Add("sup_kd", t-sup.sup-kd).
            oSup:Add("sup_kd1", t-sup.sup-kd1).
            oSup:Add("sup_kd2", t-sup.sup-kd2).
            oSup:Add("sup_nm", t-sup.sup-nm).
            oSup:Add("sup_acc", t-sup.sup-acc).
            oSup:Add("sup_ab", t-sup.ab).
            aAlamat = NEW JsonArray().
            DO ix = 1 TO 3 :
                oAlamat = NEW JsonObject().
                IF t-sup.alamat[ix] <> "" THEN DO:
                    oAlamat:Add("sup_alamat",t-sup.alamat[ix]).
                END.
                aAlamat:ADD(oAlamat).
            END.
            oSup:Add("sup_alamat", aAlamat).
            oSup:Add("sup_almnpwp", t-sup.alm-npwp).
            aContactperson = NEW JsonArray().
             DO ix = 1 TO 3 :
                oContactperson = NEW JsonObject().
                IF t-sup.cont-person[ix] <> "" THEN DO:
                    oContactperson:Add("sup_contperson",t-sup.cont-person[ix]).
                END.
                aContactperson:ADD(oContactperson).
            END.

            oSup:Add("sup_contperson", aContactperson).
            oSup:Add("sup_countrykd", t-sup.country-kd).
            oSup:Add("sup_divisikd", t-sup.divisi-kd).
            aEmail = NEW JsonArray().
            DO ix = 1 TO 3 :
                oEmail = NEW JsonObject().
                IF t-sup.alamat[ix] <> "" THEN DO:
                    oEmail:Add("sup_email",t-sup.e-mail[ix]).
                END.
                aEmail:ADD(oEmail).
            END.

            oSup:Add("sup_email", aEmail).
            oSup:Add("sup_faktif", t-sup.f-aktif).
            oSup:Add("sup_fbadanhukum", t-sup.f-badan-hukum).
            oSup:Add("sup_finternal", t-sup.f-internal).
            oSup:Add("sup_flain", t-sup.f-lain).
            oSup:Add("sup_flokal", t-sup.f-lokal).
            oSup:Add("sup_fonline", t-sup.f-online).
            oSup:Add("sup_frekening", t-sup.f-rekening).
            oSup:Add("sup_ftransfer", t-sup.f-transfer).
            oSup:Add("sup_fpdoklain", t-sup.fp-dok-lain).
            oSup:Add("sup_grouptype", t-sup.group-type).
            aHp = NEW JsonArray().
            DO ix = 1 TO 3 :
                oHp = NEW JsonObject().
                IF t-sup.hp[ix] <> "" THEN DO:
                    oHp:Add("sup_alamat", t-sup.hp[ix]).
                END.
                aHp:ADD(oHp).
            END.

            oSup:Add("sup_hp", aHp).
            oSup:Add("sup_kdbadanhukum", t-sup.kd-badan-hukum).
            oSup:Add("sup_kdjenis", t-sup.kd-jenis).
            oSup:Add("sup_kdpurch", t-sup.kd-purch).
            oSup:Add("sup_kdwilayah", t-sup.kd-wilayah).
            oSup:Add("sup_kecamatan", t-sup.kecamatan).
            oSup:Add("sup_kelurahan", t-sup.kelurahan).
            oSup:Add("sup_kodepos", t-sup.kodepos).
            oSup:Add("sup_kota", t-sup.kota).
            oSup:Add("sup_nik", t-sup.nik).
            oSup:Add("sup_nofax", t-sup.no-fax).
            oSup:Add("sup_nofds", t-sup.no-fds).
            oSup:Add("sup_noseri", t-sup.no-seri).
            aTelp = NEW JsonArray().
            DO ix = 1 TO 3 :
                oTelp = NEW JsonObject().
                IF t-sup.no-telp[ix] <> "" THEN DO:
                    oTelp:Add("sup_alamat",t-sup.no-telp[ix]).
                END.
                aTelp:ADD(oTelp).
            END.
            oSup:Add("sup_notelp", aTelp).
            oSup:Add("sup_npkp", t-sup.npkp).
            oSup:Add("sup_npwp", t-sup.npwp).
            oSup:Add("sup_propinsi", t-sup.propinsi).
            oSup:Add("sup_subtype", t-sup.sub-type).
            oSup:Add("sup_subdivkd", t-sup.subdiv-kd).
            oSup:Add("sup_supacc", t-sup.sup-acc).
            oSup:Add("sup_tglberlakudoklain", t-sup.tgl-berlaku-dok-lain).
            oSup:Add("sup_tglconfirm", t-sup.tgl-confirm).
            oSup:Add("sup_tglcreated", t-sup.tgl-created).
            oSup:Add("sup_tglmodified", t-sup.tgl-modified).
            oSup:Add("sup_tglnonaktif", t-sup.tgl-non-aktif).
            oSup:Add("sup_tglnonaktifold", t-sup.tgl-non-aktif-old).
            oSup:Add("sup_userconfirm", t-sup.user-confirm).
            oSup:Add("sup_usercreated", t-sup.user-created).
            oSup:Add("sup_user-modified", t-sup.user-modified).
            oSup:Add("sup_usernonaktif", t-sup.user-non-aktif).
            oSup:Add("sup_usernonaktifold", t-sup.user-non-aktif-old).
            
            aSup:ADD(oSup).   
                   
        END.
       END. 
        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse()
            .          
        ASSIGN 
            lstring = aSup:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lString).
        
        ASSIGN 
            oResponse:Entity        = aSup
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