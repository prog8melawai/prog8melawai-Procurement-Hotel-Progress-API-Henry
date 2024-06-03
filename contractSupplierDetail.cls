 
 /*------------------------------------------------------------------------
    File        : contractSupplierDetail
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Wed Apr 24 14:15:00 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS contractSupplierDetail INHERITS WebHandler: 

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
            
        DEFINE VARIABLE lcString      AS LONGCHAR                        NO-UNDO.
        DEFINE VARIABLE oPr           AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE aBarang       AS JsonArray                       NO-UNDO.
        DEFINE VARIABLE oBarang       AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE vkontrakno    AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE itoken        AS CHARACTER                       NO-UNDO.
              
        vkontrakno = poRequest:GetPathParameter("kontrakno").
        itoken = poRequest:GetPathParameter('token').
        
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
        END.
        
        oPr = NEW JsonObject().
        FIND FIRST kontrak-h WHERE kontrak-h.kontrakno = vkontrakno NO-LOCK NO-ERROR.
        IF AVAIL kontrak-h THEN DO:
             oPr:Add("kontrakno", kontrak-h.kontrakno).
             oPr:Add("kontrak_date", STRING(YEAR(kontrak-h.kontrak-date)) + "-" + STRING(MONTH(kontrak-h.kontrak-date)) + "-" + STRING(DAY(kontrak-h.kontrak-date))).
             oPr:Add("crdate",  STRING(kontrak-h.crdate,"9999/99/99")).
             oPr:Add("crtime", kontrak-h.crtime).
             oPr:Add("cruser", kontrak-h.cruser).
             oPr:Add("catatan", kontrak-h.catatan).
             oPr:Add("currency", kontrak-h.currency).
             FIND FIRST dept WHERE dept.dept-kd = kontrak-h.dept-kd NO-LOCK NO-ERROR.
             IF AVAIL dept THEN DO:
                oPr:Add("dept_kd", dept.dept-nm).    
             END.
             
             FIND FIRST divisi WHERE divisi.divisi-kd = kontrak-h.divisi-kd NO-LOCK NO-ERROR.
             IF AVAIL divisi THEN DO:
                oPr:Add("div_kd", divisi.divisi-nm).    
             END.
             
             FIND FIRST sub-divisi WHERE sub-divisi.subdiv-kd = kontrak-h.subdiv-kd NO-LOCK NO-ERROR.
             IF AVAIL sub-divisi THEN DO:
                oPr:Add("subdiv_kd", sub-divisi.subdiv-nm).    
             END.
             
             oPr:Add("end_kontrakdate", kontrak-h.end-kontrak-date).
             oPr:Add("lok_kd", kontrak-h.lok-kd).
             oPr:Add("rate", kontrak-h.rate).
             oPr:Add("sup_kd", kontrak-h.sup-kd).
             oPr:Add("tglconf", kontrak-h.tglconf).
             oPr:Add("top", kontrak-h.top).
             oPr:Add("user_confirm", kontrak-h.user-confirm).
             oPr:Add("user_batal", kontrak-h.user-batal).
             oPr:Add("tglbatal", kontrak-h.tgl-batal).
             
            aBarang = NEW JsonArray().
            FOR EACH kontrak-d WHERE kontrak-d.kontrakno = kontrak-h.kontrakno NO-LOCK:
            oBarang = NEW JsonObject().
            oBarang:Add("kontrakno", kontrak-d.kontrakno).
            
            FIND FIRST masbar WHERE masbar.kdbar = kontrak-d.kdbar NO-ERROR.
            IF AVAIL masbar THEN DO:
                oBarang:Add("kdbar", masbar.kdbar).
                oBarang:Add("nm_bar", masbar.nmbar).   
            END.

            FIND FIRST satuan WHERE satuan.kdstn = kontrak-d.kdstn NO-ERROR.
            IF AVAIL satuan THEN DO:
                oBarang:Add("kdstn", satuan.kdstn).
                oBarang:Add("nm_satuan", satuan.ket).   
            END.
            oBarang:Add("disc", kontrak-d.disc).
            oBarang:Add("disc_rp", kontrak-d.disc-rp).
            oBarang:Add("harga", kontrak-d.harga).
            oBarang:Add("crdate", kontrak-d.crdate).
            oBarang:Add("crtime", kontrak-d.crtime).
            oBarang:Add("cruser", kontrak-d.cruser).
            oBarang:Add("lok_kd", kontrak-d.lok-kd).
            
            FIND FIRST vat WHERE dr-tgl <= TODAY AND sd-tgl = ? NO-ERROR .
            IF AVAIL vat THEN DO:
                oBarang:Add("tarif", vat.tarif).
            END.
            IF NOT  AVAIL vat THEN DO:
                oBarang:Add("tarif", 11) .
            END.
            
            oBarang:Add("ppn_rp", kontrak-d.ppn-rp).
            aBarang:ADD(oBarang).
            END.
            oPr:ADD("items",aBarang).
        END.
        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse().
                          
        ASSIGN 
            lcString = oPr:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lcString).
        
        ASSIGN 
            oResponse:Entity        = oPr
            oResponse:ContentType   = 'application/json':u
            oResponse:ContentLength = oBody:Size
            oResponse:StatusCode    = INTEGER(200)
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