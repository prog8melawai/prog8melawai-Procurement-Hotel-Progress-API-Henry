 
 /*------------------------------------------------------------------------
    File        : loginUser
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Mon Apr 22 14:10:34 ICT 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS loginUser INHERITS WebHandler: 

    METHOD OVERRIDE PROTECTED INTEGER HandleNotAllowedMethod( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    END METHOD.

    METHOD OVERRIDE PROTECTED INTEGER HandleNotImplemented( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        
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
       DEFINE VARIABLE lcString            AS LONGCHAR                        NO-UNDO. 
       
       DEFINE VARIABLE jsRequest           AS JsonObject.
       DEFINE VARIABLE jsResponse          AS JsonObject. 
       
       DEFINE VARIABLE aUser               AS JsonArray                        NO-UNDO.
       DEFINE VARIABLE oUser               AS JsonObject                       NO-UNDO.
               
       DEFINE VARIABLE vusername              AS CHARACTER.
       DEFINE VARIABLE vpassword              AS CHARACTER.
       DEFINE VARIABLE voldpassword           AS CHARACTER.
       
       DEFINE VARIABLE iLength          AS INTEGER NO-UNDO INITIAL 100.
       DEFINE VARIABLE cRandomString    AS CHARACTER NO-UNDO.
       DEFINE VARIABLE i                AS INTEGER NO-UNDO.
       DEFINE VARIABLE cChars           AS CHARACTER NO-UNDO INITIAL "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".
       DEFINE VARIABLE irandom          AS INTEGER NO-UNDO.
       DEFINE VARIABLE iMaxIndex        AS INTEGER NO-UNDO .
       DEFINE VARIABLE vmenu            AS CHARACTER NO-UNDO.
       
       iMaxIndex = LENGTH(cChars).
       DO i = 1 TO iLength.
        irandom = RANDOM(1, iMaxIndex).
        cRandomString = cRandomString + SUBSTRING(cChars, irandom, 1).
       END.
       
       FIND FIRST x-opera WHERE x-opera.token = cRandomString  NO-LOCK NO-ERROR.
       IF AVAIL x-opera THEN DO:
          DO i = 1 TO iLength.
            irandom = RANDOM(1, iMaxIndex).
            cRandomString = cRandomString + SUBSTRING(cChars, irandom, 1).
          END.    
       END.

       jsRequest = CAST(poRequest:Entity, JsonObject).
       ASSIGN 
         vusername       = jsRequest:GetCharacter('username')
         vpassword       = jsRequest:GetCharacter('password').
            
        FIND FIRST _user WHERE _user._userid = vusername NO-LOCK NO-ERROR.
        IF AVAIl _user THEN DO:
            ASSIGN
                voldpassword = _user._password.
                MESSAGE ENCODE(vpassword)
                VIEW-AS ALERT-BOX.
            IF ENCODE(vpassword) = voldpassword THEN DO:
                 FIND FIRST x-opera WHERE x-opera.op-code = vusername NO-ERROR.
                 IF AVAIL x-opera THEN DO:
                   ASSIGN
                   x-opera.token     = cRandomString.
                   x-opera.exp-token = TODAY + 1.
                   oUser = NEW JsonObject().
                   oUser:ADD("userid", x-opera.op-code).
                   oUser:ADD("deptkd", x-opera.dept-kd).
                   oUser:ADD("divkd", x-opera.divisi-kd).
                   oUser:ADD("email", x-opera.email).
                   oUser:ADD("emailfrom", x-opera.email-from).
                   oUser:ADD("exp_date", x-opera.exp-date).
                   oUser:ADD("f_supervisor", x-opera.f-supervisor).
                   oUser:ADD("from_address", x-opera.from-address).
                   oUser:ADD("group_code", x-opera.group-code).
                   oUser:ADD("group_level", x-opera.group-level).
                   oUser:ADD("group_user", x-opera.group-user).
                   oUser:ADD("hak_akses", x-opera.hak-akses).
                   oUser:ADD("initial", x-opera.initial).
                   oUser:ADD("kd_level", x-opera.kd-level).
                   oUser:ADD("lok_kd", x-opera.lok-kd).
                   oUser:ADD("mail_from", x-opera.mail-from).
                   oUser:ADD("smtp_server", x-opera.smtp-server).
                   oUser:ADD("subdiv_kd", x-opera.subdiv-kd).
                   oUser:ADD("to_address", x-opera.to-address).
                   oUser:ADD("token", x-opera.token).
                   oUser:ADD("exp_token", x-opera.exp-token).
                   
                  FIND FIRST x-group WHERE x-group.group-code = x-opera.group-code NO-LOCK NO-ERROR.
                  IF AVAIL x-group THEN DO:
                       oUser:ADD("grpcode", x-group.group-code).
                       oUser:ADD("grpname", x-group.group-name).
                       FOR EACH x-menu WHERE x-menu.m-group MATCHES "*" + x-group.group-code + "*" NO-LOCK:          
                           vmenu = vmenu + x-menu.m-text + ",".
                       END.
                       oUser:ADD("mtext", vmenu).
                  END.
                 END.
            END.
            ELSE DO:
               errorValidation(401,"Unauthorized").
            END.
        END.
        IF NOT AVAIL _user THEN DO:
            errorValidation(401,"Unauthorized").
        END.
        
        RELEASE x-opera.
       ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse().
                       
        ASSIGN 
            lcString = oUser:GetJsonText()
            oBody = NEW OpenEdge.Core.String(lcString).
        
        ASSIGN 
            oResponse:Entity        = oUser
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