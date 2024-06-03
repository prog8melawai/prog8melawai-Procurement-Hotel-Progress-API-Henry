 
 /*------------------------------------------------------------------------
    File        : prBarang2
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Tue Apr 23 07:56:18 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS prBarang2 INHERITS WebHandler: 

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
        DEFINE VARIABLE aPr       AS JsonArray                       NO-UNDO.
        DEFINE VARIABLE oPr       AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE aBarang   AS JsonArray                       NO-UNDO.
        DEFINE VARIABLE oBarang   AS JsonObject                      NO-UNDO.
        DEFINE VARIABLE titems    AS DECIMAL                         NO-UNDO.
        DEFINE VARIABLE vpr       AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE itoken    AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE iuserid      AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE igroupcode   AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE ideptkd    AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE istatuspr AS CHARACTER                       NO-UNDO.
        
        istatuspr = poRequest:GetPathParameter('status').
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
            iuserid = x-opera.op-code.
            igroupcode = x-opera.group-code.
            ideptkd  = x-opera.dept-kd.
        END.
        
        aPr = NEW JsonArray().
        IF igroupcode = "Fin Head" THEN DO:
            IF istatuspr = 'uncompleted' THEN DO:
                FOR EACH pr-h WHERE pr-h.dept-kd = ideptkd AND 
                                    pr-h.f-approve = NO AND
                                    pr-h.f-batal = NO NO-LOCK:
                     oPr = NEW JsonObject().
                     oPr:Add("pr_no", pr-h.pr-no).
                     oPr:Add("pr_date", STRING(pr-h.pr-date,"99/99/9999")).
                     oPr:Add("crdate",  STRING(pr-h.crdate,"99/99/9999")).
                     oPr:Add("crtime", pr-h.crtime).
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
                     
                     titems = 0.
                     FOR EACH pr-d WHERE pr-h.pr-no = pr-d.pr-no NO-LOCK:
                        titems = titems + 1. 
                     END.
                     oPr:Add("total_item", titems).
                     aPr:ADD(oPr).
                END.  
            END.
            ELSE IF istatuspr = 'pending' THEN DO:
                FOR EACH pr-h WHERE pr-h.dept-kd = ideptkd AND 
                                    pr-h.f-approve = NO AND
                                    pr-h.f-batal = NO AND 
                                    pr-h.f-revise = NO NO-LOCK:
                     oPr = NEW JsonObject().
                     oPr:Add("pr_no", pr-h.pr-no).
                     oPr:Add("pr_date", STRING(pr-h.pr-date,"99/99/9999")).
                     oPr:Add("crdate",  STRING(pr-h.crdate,"99/99/9999")).
                     oPr:Add("crtime", pr-h.crtime).
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
                     
                     titems = 0.
                     FOR EACH pr-d WHERE pr-h.pr-no = pr-d.pr-no NO-LOCK:
                        titems = titems + 1. 
                     END.
                     oPr:Add("total_item", titems).
                     aPr:ADD(oPr).
                END. 
            END.
            ELSE IF istatuspr = 'revise' THEN DO:
                FOR EACH pr-h WHERE pr-h.dept-kd = ideptkd AND 
                                    pr-h.f-approve = NO AND
                                    pr-h.f-batal = NO AND 
                                    pr-h.f-revise = YES NO-LOCK:
                     oPr = NEW JsonObject().
                     oPr:Add("pr_no", pr-h.pr-no).
                     oPr:Add("pr_date", STRING(pr-h.pr-date,"99/99/9999")).
                     oPr:Add("crdate",  STRING(pr-h.crdate,"99/99/9999")).
                     oPr:Add("crtime", pr-h.crtime).
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
                     
                     titems = 0.
                     FOR EACH pr-d WHERE pr-h.pr-no = pr-d.pr-no NO-LOCK:
                        titems = titems + 1. 
                     END.
                     oPr:Add("total_item", titems).
                     aPr:ADD(oPr).
                END.
            END.
            ELSE IF istatuspr = 'approve' THEN DO:
                FOR EACH pr-h WHERE pr-h.dept-kd = ideptkd AND 
                                    pr-h.f-approve = YES AND
                                    pr-h.f-batal = NO AND 
                                    pr-h.f-revise = NO NO-LOCK:
                     oPr = NEW JsonObject().
                     oPr:Add("pr_no", pr-h.pr-no).
                     oPr:Add("pr_date", STRING(pr-h.pr-date,"99/99/9999")).
                     oPr:Add("crdate",  STRING(pr-h.crdate,"99/99/9999")).
                     oPr:Add("crtime", pr-h.crtime).
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
                     
                     titems = 0.
                     FOR EACH pr-d WHERE pr-h.pr-no = pr-d.pr-no NO-LOCK:
                        titems = titems + 1. 
                     END.
                     oPr:Add("total_item", titems).
                     aPr:ADD(oPr).
                END.
            END.
            ELSE IF istatuspr = 'reject' THEN DO:
                FOR EACH pr-h WHERE pr-h.dept-kd = ideptkd AND 
                                    pr-h.f-approve = NO AND
                                    pr-h.f-batal = YES AND 
                                    pr-h.f-revise = NO NO-LOCK:
                     oPr = NEW JsonObject().
                     oPr:Add("pr_no", pr-h.pr-no).
                     oPr:Add("pr_date", STRING(pr-h.pr-date,"99/99/9999")).
                     oPr:Add("crdate",  STRING(pr-h.crdate,"99/99/9999")).
                     oPr:Add("crtime", pr-h.crtime).
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
                     
                     titems = 0.
                     FOR EACH pr-d WHERE pr-h.pr-no = pr-d.pr-no NO-LOCK:
                        titems = titems + 1. 
                     END.
                     oPr:Add("total_item", titems).
                     aPr:ADD(oPr).
                END.
            END.
            ELSE DO:
                FOR EACH pr-h WHERE pr-h.dept-kd = ideptkd NO-LOCK:
                     oPr = NEW JsonObject().
                     oPr:Add("pr_no", pr-h.pr-no).
                     oPr:Add("pr_date", STRING(pr-h.pr-date,"99/99/9999")).
                     oPr:Add("crdate",  STRING(pr-h.crdate,"99/99/9999")).
                     oPr:Add("crtime", pr-h.crtime).
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
                     
                     titems = 0.
                     FOR EACH pr-d WHERE pr-h.pr-no = pr-d.pr-no NO-LOCK:
                        titems = titems + 1. 
                     END.
                     oPr:Add("total_item", titems).
                     aPr:ADD(oPr).
                END.
            END.
        END.
        ELSE DO:
            IF istatuspr = 'uncompleted' THEN DO:
                FOR EACH pr-h WHERE pr-h.cruser = iuserid AND 
                                    pr-h.f-approve = NO AND
                                    pr-h.f-batal = NO NO-LOCK:
                     oPr = NEW JsonObject().
                     oPr:Add("pr_no", pr-h.pr-no).
                     oPr:Add("pr_date", STRING(pr-h.pr-date,"99/99/9999")).
                     oPr:Add("crdate",  STRING(pr-h.crdate,"99/99/9999")).
                     oPr:Add("crtime", pr-h.crtime).
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
                     
                     titems = 0.
                     FOR EACH pr-d WHERE pr-h.pr-no = pr-d.pr-no NO-LOCK:
                        titems = titems + 1. 
                     END.
                     oPr:Add("total_item", titems).
                     aPr:ADD(oPr).
                END.
            END.
            ELSE IF istatuspr = 'pending' THEN DO:
                FOR EACH pr-h WHERE pr-h.cruser = iuserid AND 
                                    pr-h.f-approve = NO AND
                                    pr-h.f-batal = NO AND
                                    pr-h.f-revise = NO NO-LOCK:
                     oPr = NEW JsonObject().
                     oPr:Add("pr_no", pr-h.pr-no).
                     oPr:Add("pr_date", STRING(pr-h.pr-date,"99/99/9999")).
                     oPr:Add("crdate",  STRING(pr-h.crdate,"99/99/9999")).
                     oPr:Add("crtime", pr-h.crtime).
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
                     
                     titems = 0.
                     FOR EACH pr-d WHERE pr-h.pr-no = pr-d.pr-no NO-LOCK:
                        titems = titems + 1. 
                     END.
                     oPr:Add("total_item", titems).
                     aPr:ADD(oPr).
                END.
            END.
            ELSE IF istatuspr = 'revise' THEN DO:
                FOR EACH pr-h WHERE pr-h.cruser = iuserid AND 
                                    pr-h.f-approve = NO AND
                                    pr-h.f-batal = NO AND
                                    pr-h.f-revise = YES NO-LOCK:
                     oPr = NEW JsonObject().
                     oPr:Add("pr_no", pr-h.pr-no).
                     oPr:Add("pr_date", STRING(pr-h.pr-date,"99/99/9999")).
                     oPr:Add("crdate",  STRING(pr-h.crdate,"99/99/9999")).
                     oPr:Add("crtime", pr-h.crtime).
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
                     
                     titems = 0.
                     FOR EACH pr-d WHERE pr-h.pr-no = pr-d.pr-no NO-LOCK:
                        titems = titems + 1. 
                     END.
                     oPr:Add("total_item", titems).
                     aPr:ADD(oPr).
                END.
            END.
            ELSE IF istatuspr = 'approve' THEN DO:
                FOR EACH pr-h WHERE pr-h.cruser = iuserid AND 
                                    pr-h.f-approve = YES AND
                                    pr-h.f-batal = NO AND
                                    pr-h.f-revise = NO NO-LOCK:
                     oPr = NEW JsonObject().
                     oPr:Add("pr_no", pr-h.pr-no).
                     oPr:Add("pr_date", STRING(pr-h.pr-date,"99/99/9999")).
                     oPr:Add("crdate",  STRING(pr-h.crdate,"99/99/9999")).
                     oPr:Add("crtime", pr-h.crtime).
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
                     
                     titems = 0.
                     FOR EACH pr-d WHERE pr-h.pr-no = pr-d.pr-no NO-LOCK:
                        titems = titems + 1. 
                     END.
                     oPr:Add("total_item", titems).
                     aPr:ADD(oPr).
                END.
            END.
            ELSE IF istatuspr = 'reject' THEN DO:
                FOR EACH pr-h WHERE pr-h.cruser = iuserid AND 
                                    pr-h.f-approve = NO AND
                                    pr-h.f-batal = YES AND
                                    pr-h.f-revise = NO NO-LOCK:
                     oPr = NEW JsonObject().
                     oPr:Add("pr_no", pr-h.pr-no).
                     oPr:Add("pr_date", STRING(pr-h.pr-date,"99/99/9999")).
                     oPr:Add("crdate",  STRING(pr-h.crdate,"99/99/9999")).
                     oPr:Add("crtime", pr-h.crtime).
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
                     
                     titems = 0.
                     FOR EACH pr-d WHERE pr-h.pr-no = pr-d.pr-no NO-LOCK:
                        titems = titems + 1. 
                     END.
                     oPr:Add("total_item", titems).
                     aPr:ADD(oPr).
                END.
            END.
            ELSE DO:
                FOR EACH pr-h WHERE pr-h.cruser = iuserid NO-LOCK:
                     oPr = NEW JsonObject().
                     oPr:Add("pr_no", pr-h.pr-no).
                     oPr:Add("pr_date", STRING(pr-h.pr-date,"99/99/9999")).
                     oPr:Add("crdate",  STRING(pr-h.crdate,"99/99/9999")).
                     oPr:Add("crtime", pr-h.crtime).
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
                     
                     titems = 0.
                     FOR EACH pr-d WHERE pr-h.pr-no = pr-d.pr-no NO-LOCK:
                        titems = titems + 1. 
                     END.
                     oPr:Add("total_item", titems).
                     aPr:ADD(oPr).
                END.
            END.
        END.
        

        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse().
                          
        ASSIGN 
            lcString = aPr:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lcString).
        
        ASSIGN 
            oResponse:Entity        = aPr
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
            
            DEFINE VARIABLE oResponse   AS OpenEdge.Net.HTTP.IHttpResponse  NO-UNDO.
            DEFINE VARIABLE oWriter     AS OpenEdge.Web.WebResponseWriter   NO-UNDO.
            DEFINE VARIABLE oBody       AS OpenEdge.Core.String             NO-UNDO.
            DEFINE VARIABLE jsResponse  AS JsonObject                       NO-UNDO.
            DEFINE VARIABLE jsRequest   AS JsonObject                       NO-UNDO.
            DEFINE VARIABLE lcString    AS LONGCHAR                         NO-UNDO.
            DEFINE VARIABLE vpr-no      AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE aItems      AS JsonArray                        NO-UNDO.
            DEFINE VARIABLE oItems      AS JsonObject                       NO-UNDO.
            DEFINE VARIABLE itoken      AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE ix          AS INTEGER                          NO-UNDO.
            DEFINE VARIABLE xkdbar      AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE vnote       AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE vuser       AS CHARACTER                        NO-UNDO.
            
            jsRequest = CAST(poRequest:Entity, JsonObject).
            vpr-no = jsRequest:GetCharacter('pr_no').
            aItems = jsRequest:GetJsonArray('items').
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
                vuser = x-opera.op-code.
            END.
            
            FIND FIRST pr-h WHERE pr-h.pr-no = vpr-no EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            IF LOCKED (pr-h) THEN DO:
                prh:
                    REPEAT:
                         FIND FIRST pr-h WHERE pr-h.pr-no = vpr-no EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                         IF AVAIL pr-h THEN LEAVE prh.
                    END.
            END.                
            IF AVAIL pr-h THEN DO:
                ASSIGN 
                    pr-h.f-revise = YES.
                    pr-h.revised-date = TODAY.
                    pr-h.revised-user = vuser.
                DO ix = 1 TO aItems:Length :
                    oItems = aItems:GetJsonObject(ix).
                    vnote = oItems:GetCharacter('revise_note').
                    xkdbar = oItems:GetCharacter('kode_barang').
                    FIND FIRST pr-d WHERE pr-d.pr-no = vpr-no AND 
                                          pr-d.kdbar = xkdbar EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                    IF LOCKED (pr-d) THEN DO:
                        prd:
                            REPEAT:
                                 FIND FIRST pr-d WHERE pr-d.pr-no = vpr-no AND 
                                                       pr-d.kdbar = xkdbar EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                                 IF AVAIL pr-d THEN LEAVE prd. 
                            END.
                    END.
                    IF AVAIL pr-d THEN DO:
                        ASSIGN
                            pr-d.revise-note = vnote.

                    END.
                END.
            END.
            
            RELEASE pr-h.
            RELEASE pr-d.
            jsResponse = NEW JsonObject().
            jsResponse:Add('message', 'PR Revise').
            
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
        DEFINE VARIABLE oResponse   AS OpenEdge.Net.HTTP.IHttpResponse  NO-UNDO.
            DEFINE VARIABLE oWriter     AS OpenEdge.Web.WebResponseWriter   NO-UNDO.
            DEFINE VARIABLE oBody       AS OpenEdge.Core.String             NO-UNDO.
            DEFINE VARIABLE jsResponse  AS JsonObject                       NO-UNDO.
            DEFINE VARIABLE jsRequest   AS JsonObject                       NO-UNDO.
            DEFINE VARIABLE lcString    AS LONGCHAR                         NO-UNDO.
            DEFINE VARIABLE vpr-no      AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE oItems      AS JsonObject                       NO-UNDO.
            DEFINE VARIABLE itoken      AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE ix          AS INTEGER                          NO-UNDO.
            DEFINE VARIABLE xkdbar      AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE vnote       AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE vuser       AS CHARACTER                        NO-UNDO.
            
            jsRequest = CAST(poRequest:Entity, JsonObject).
            vpr-no = jsRequest:GetCharacter('pr_no').
            itoken = jsRequest:GetCharacter('token').
            
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
                vuser = x-opera.op-code.
            END.
            
            FIND FIRST pr-h WHERE pr-h.pr-no = vpr-no EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            IF LOCKED (pr-h) THEN DO:
                prh:
                    REPEAT:
                         FIND FIRST pr-h WHERE pr-h.pr-no = vpr-no EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                         IF AVAIL pr-h THEN LEAVE prh.
                    END.
            END.                
            IF AVAIL pr-h THEN DO:
                ASSIGN 
                    pr-h.f-approve = YES.
                    pr-h.f-batal = NO.
                    pr-h.f-revise = NO.
                    pr-h.f-mark = YES.
                    pr-h.approved-user = vuser.
                    pr-h.approved-date = TODAY.
            END.

            RELEASE pr-h.
            jsResponse = NEW JsonObject().
            jsResponse:Add('message', 'PR Approved').
            
            ASSIGN 
                oResponse            = NEW OpenEdge.Web.WebResponse().
                              
            ASSIGN 
                lcString = jsResponse:GetJsonText()
                oBody = NEW OpenEdge.Core.String(lcString).
            
            ASSIGN 
                oResponse:Entity        = jsResponse
                oResponse:ContentType   = 'application/json':u
                oResponse:ContentLength = oBody:Size
                oResponse:StatusCode = INTEGER(204).
    
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
            DEFINE VARIABLE jsResponse  AS JsonObject                       NO-UNDO.
            DEFINE VARIABLE jsRequest   AS JsonObject                       NO-UNDO.
            DEFINE VARIABLE lcString    AS LONGCHAR                         NO-UNDO.
            DEFINE VARIABLE vpr-no      AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE itoken      AS CHARACTER                        NO-UNDO.
            DEFINE VARIABLE vuser       AS CHARACTER                        NO-UNDO.
            
            jsRequest = CAST(poRequest:Entity, JsonObject).
            vpr-no = jsRequest:GetCharacter('pr_no').
            itoken = jsRequest:GetCharacter('token').
            
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
                vuser = x-opera.op-code.
            END.
            
            FIND FIRST pr-h WHERE pr-h.pr-no = vpr-no EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            IF LOCKED (pr-h) THEN DO:
                prh:
                    REPEAT:
                         FIND FIRST pr-h WHERE pr-h.pr-no = vpr-no EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                         IF AVAIL pr-h THEN LEAVE prh.
                    END.
            END.                
            IF AVAIL pr-h THEN DO:
                MESSAGE "TOLOL".
                MESSAGE vpr-no.
                ASSIGN 
                    pr-h.f-batal = YES
                    pr-h.f-revise = NO
                    pr-h.tgl-batal = TODAY
                    pr-h.f-mark = YES
                    pr-h.user-batal = vuser.
            END.
            
            jsResponse = NEW JsonObject().
            jsResponse:Add('message', 'PR Rejected').
            
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