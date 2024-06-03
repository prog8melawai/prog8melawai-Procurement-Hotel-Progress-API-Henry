 
 /*------------------------------------------------------------------------
    File        : prDetailBarang
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Wed Apr 17 13:44:30 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS prDetailBarang INHERITS WebHandler: 

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
            
        DEFINE VARIABLE lcString  AS LONGCHAR                        NO-UNDO.
        DEFINE VARIABLE oPr       AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE aBarang   AS JsonArray                       NO-UNDO.
        DEFINE VARIABLE oBarang   AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE vpr-no    AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE itoken    AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE ifilter       AS CHARACTER                       NO-UNDO.
        
        ifilter = poRequest:GetPathParameter('filter').      
        vpr-no = poRequest:GetPathParameter("pr_no").
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

        FIND FIRST pr-h WHERE pr-h.pr-no = vpr-no NO-LOCK NO-ERROR.
        IF AVAIL pr-h THEN DO:
             oPr:Add("pr_no", pr-h.pr-no).
             oPr:Add("pr_date", STRING(YEAR(pr-h.pr-date)) + "-" + STRING(MONTH(pr-h.pr-date)) + "-" + STRING(DAY(pr-h.pr-date))).
             oPr:Add("crdate",  STRING(pr-h.crdate,"9999/99/99")).
             oPr:Add("crtime", pr-h.crtime).
             oPr:Add("cruser", pr-h.cruser).
             oPr:Add("user_batal", pr-h.user-batal).
             oPr:Add("tgl_batal", pr-h.tgl-batal).
             oPr:Add("f_batal", pr-h.f-batal).
             FIND FIRST dept WHERE dept.dept-kd = pr-h.dept-kd NO-LOCK NO-ERROR.
             IF AVAIL dept THEN DO:
                oPr:Add("dept_kd", dept.dept-nm).    
             END.
             
             FIND FIRST divisi WHERE divisi.divisi-kd = pr-h.divisi-kd NO-LOCK NO-ERROR.
             IF AVAIL divisi THEN DO:
                oPr:Add("div_kd", divisi.divisi-nm).    
             END.
             
             FIND FIRST sub-divisi WHERE sub-divisi.subdiv-kd = pr-h.subdiv-kd NO-LOCK NO-ERROR.
             IF AVAIL sub-divisi THEN DO:
                oPr:Add("subdiv_kd", sub-divisi.subdiv-nm).    
             END.
             
             oPr:Add("f_approve", pr-h.f-approve).
             oPr:Add("f_revise", pr-h.f-revise).
             oPr:Add("f_mark", pr-h.f-mark).
             oPr:Add("revised_user", pr-h.revised-user).
             oPr:Add("revised_tgl", pr-h.revised-date).
             
            aBarang = NEW JsonArray().
            IF ifilter = 'all' THEN DO:
                FOR EACH pr-d WHERE pr-d.pr-no = pr-h.pr-no NO-LOCK BREAK BY pr-d.kdjns :
                oBarang = NEW JsonObject().
                oBarang:Add("pr_no", pr-d.pr-no).
                oBarang:Add("pr_date", STRING(YEAR(pr-d.pr-date)) + "-" + STRING(MONTH(pr-d.pr-date)) + "-" + STRING(DAY(pr-d.pr-date))).
                oBarang:Add("kode_barang", pr-d.kdbar).
                oBarang:Add("nama_barang", pr-d.nmbar).
                FIND FIRST masbar WHERE masbar.kdbar = pr-d.kdbar NO-LOCK NO-ERROR.
                IF AVAIL masbar THEN DO:
                   oBarang:Add("nama_barang2", masbar.nmbar2).  
                END. 
                
                FIND FIRST satuan WHERE satuan.kdstn = pr-d.kdstn-krm NO-ERROR.
                IF AVAIL satuan THEN DO:
                    oBarang:Add("kdstn_kirim", satuan.kdstn).
                    oBarang:Add("nm_kirim", satuan.ket).   
                END.
                
                FIND FIRST satuan WHERE satuan.kdstn = pr-d.kdstn-stok NO-ERROR.
                IF AVAIL satuan THEN DO:
                    oBarang:Add("kdstn_stok", satuan.kdstn).
                    oBarang:Add("nm_stok", satuan.ket).   
                END.
                
                FIND FIRST msjns WHERE pr-d.kdjns = msjns.kdjns NO-LOCK NO-ERROR.
                IF AVAIL msjns THEN DO:
                    oBarang:Add("kd_jenis", msjns.kdjns). 
                    oBarang:Add("nm_jenis", msjns.nmjns).    
                END.
                
                oBarang:Add("qty", pr-d.qty).
                oBarang:Add("qty_old", pr-d.qty-old).
                oBarang:Add("revise_note", pr-d.revise-note).
                aBarang:ADD(oBarang).
                END.
            END.
            ELSE DO:
                FOR EACH pr-d WHERE pr-d.pr-no = pr-h.pr-no  AND pr-d.kdjns = ifilter NO-LOCK:
                oBarang = NEW JsonObject().
                oBarang:Add("pr_no", pr-d.pr-no).
                oBarang:Add("pr_date", STRING(YEAR(pr-d.pr-date)) + "-" + STRING(MONTH(pr-d.pr-date)) + "-" + STRING(DAY(pr-d.pr-date))).
                oBarang:Add("kode_barang", pr-d.kdbar).
                oBarang:Add("nama_barang", pr-d.nmbar).
                FIND FIRST masbar WHERE masbar.kdbar = pr-d.kdbar NO-LOCK NO-ERROR.
                IF AVAIL masbar THEN DO:
                   oBarang:Add("nama_barang2", masbar.nmbar2).  
                END. 
                
                FIND FIRST satuan WHERE satuan.kdstn = pr-d.kdstn-krm NO-ERROR.
                IF AVAIL satuan THEN DO:
                    oBarang:Add("kdstn_kirim", satuan.kdstn).
                    oBarang:Add("nm_kirim", satuan.ket).   
                END.
                
                FIND FIRST satuan WHERE satuan.kdstn = pr-d.kdstn-stok NO-ERROR.
                IF AVAIL satuan THEN DO:
                    oBarang:Add("kdstn_stok", satuan.kdstn).
                    oBarang:Add("nm_stok", satuan.ket).   
                END.
                
                FIND FIRST msjns WHERE pr-d.kdjns = msjns.kdjns NO-LOCK NO-ERROR.
                IF AVAIL msjns THEN DO:
                    oBarang:Add("kd_jenis", msjns.kdjns). 
                    oBarang:Add("nm_jenis", msjns.nmjns).    
                END.
                
                oBarang:Add("qty", pr-d.qty).
                oBarang:Add("qty_old", pr-d.qty-old).
                oBarang:Add("revise_note", pr-d.revise-note).
                aBarang:ADD(oBarang).
                END.
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