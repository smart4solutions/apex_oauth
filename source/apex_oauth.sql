CREATE TABLE  "S4SA_REQUESTS" 
   (	"ID" NUMBER(*,0) NOT NULL ENABLE, 
	"TIJD" TIMESTAMP (6) DEFAULT systimestamp NOT NULL ENABLE, 
	"RESPONSE" CLOB, 
	"REQUEST_SOURCE" VARCHAR2(50) NOT NULL ENABLE, 
	"REQUEST_URI" VARCHAR2(1000) NOT NULL ENABLE, 
	"REQUEST_TYPE" VARCHAR2(100) NOT NULL ENABLE, 
	"REQUEST_HEADERS" VARCHAR2(2000), 
	"REQUEST_BODY" CLOB, 
	"APPLICATION" NUMBER(*,0), 
	"GEBRUIKER" VARCHAR2(255)
   )
/
CREATE TABLE  "S4SA_SETTINGS" 
   (	"CODE" VARCHAR2(255) NOT NULL ENABLE, 
	"MEANING" VARCHAR2(2000), 
	"DESCRIPTION" VARCHAR2(2000), 
	 CONSTRAINT "S4SA_SETTINGS_PK" PRIMARY KEY ("CODE") ENABLE
   )
/
CREATE UNIQUE INDEX  "S4SA_SETTINGS_PK" ON  "S4SA_SETTINGS" ("CODE")
/
CREATE OR REPLACE PACKAGE  "S4SL_AUTH_PCK" is
/*                           __
                         _.-~  )
              _..--~~~~,'   ,-/     _    _____ __  __          _____ _______ 
           .-'. . . .'   ,-','    ,' ) / ____|  \/  |   /\   |  __ \__   __|
         ,'. . . _   ,--~,-'__..-'  ,'| (___ | \  / |  /  \  | |__) | | |
       ,'. . .  (@)' ---~~~~      ,'   \___ \| |\/| | / /\ \ |  _  /  | |
      /. . . . '~~             ,-'     ____) | |  | |/ ____ \| | \ \  | |
     /. . . . .             ,-'   _  _|_____/|_|  |_/_/ _  \_\_|_ \_\ |_|
    ; . . . .  - .        ,'     | || |           | |     | | (_)
   : . . . .       _     /       | || |_ ___  ___ | |_   _| |_ _  ___  _ __  ___
  . . . . .          `-.:        |__   _/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
 . . . ./  - .          )           | | \__ \ (_) | | |_| | |_| | (_) | | | \__ \
.  . . |  _____..---.._/            |_| |___/\___/|_|\__,_|\__|_|\___/|_| |_|___/
-~~----~~~~             ~---~~~~--~~~--~~~---~---~---~~~~----~~~~~---~~~--~~~---~~~---
--
--    NAME
--      s4sg_auth_pck
--
--    DESCRIPTION
--      
--
--    MODIFIED   (DD-MM-YYYY)
--    RICHARD MARTENS   14-3-2015 12:28:59 - Created
--    RICHARD MARTENS   31-08-2015 17:59 - Added revision global
--------------------------------------------------------------------------------
*/

gc_revision constant varchar2(100) := 'Revision: 0 (build: 0)';

g_provider  s4sa_oauth_pck.tp_provider_settings;

function do_request (p_api_uri   in varchar2,
                    p_method    in varchar2                 -- POST or GET
                                           ,
                    p_token     in varchar2 default null,
                    p_body      in clob default null)
  return clob;
  -- *****************************************************************
  -- Description:       LINKEDIN_AUTHENTICATION
  --                    This is the process called by apex to login the user
  --                    results in the user being redirected to the google login-page
  -- Input Parameters:  - p_authentication
  --                    - p_plugin
  --                    - p_password
  -- Output Parameters: - 
  -- Error Conditions Raised: - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************  
procedure authenticate;
  
  -- *****************************************************************
  -- Description:       INVALID_SESSION
  --                    is called by the apex authentication plugin when apex
  --                    detects an invalid session.
  --                    results in the user getting redirected to google again.
  -- Input Parameters:  - 
  -- Output Parameters: - 
  -- Error Conditions Raised: - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************
function invalid_session
  ( p_authentication in apex_plugin.t_authentication
  , p_plugin         in apex_plugin.t_plugin 
  ) return apex_plugin.t_authentication_inval_result;
    
  -- *****************************************************************
  -- Description:       GET_TOKEN
  --                    gets the authentication code from google
  -- Input Parameters:  - p_code           the code as provided by google oauth2callback
  --                    - p_client_id      the clientid as provided in your google developer console
  --                    - p_client_secret  the client secret as provided in your google developer console
  --                    - p_redirect_uri   the redirect uri as you entered it in the call to redirect_oath2
  --                    - p_wallet_path    the path where your wallet is located
  --                    - p_wallet_pwd     the wallet's password
  -- Output Parameters: - po_access_token  the access token
  --                    - po_token_type    the token_type (Bearer)
  --                    - po_expires_in    the seconds when the token expires
  --                    - po_id_token      the token_id
  --                    - po_error         error when occurred
  -- Error Conditions Raised: - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015 16:35:42
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************
  procedure get_token
    ( p_code          in     varchar2
    , po_access_token    out varchar2
    , po_token_type      out varchar2
    , po_expires_in      out number
    , po_id_token        out varchar2
    , po_error           out varchar2
    );
    
  -- *****************************************************************
  -- Description:       GET_GOOGLE_USER
  --                    returns the current loggen-in Google-user
  -- Input Parameters:  - p_token          the authorization token as provided by Google
  -- Output Parameters: 
  -- Error Conditions Raised: - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015 16:35:42
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************
  function get_user(p_token in varchar2)
    return s4sa_oauth_pck.oauth2_user;
  
  -- *****************************************************************
  -- Description:       OAUTH2CALLBACK
  --                    is called by google, contains the actual Apex login process
  -- Input Parameters:  - state              is provided by google redirect
  --                    - code               is provided by google redirect
  --                    - error              is provided by google redirect
  --                    - error_description  is provided by google redirect
  --                    - token              is provided by google redirect
  -- Output Parameters: - 
  --                    - 
  -- Error Conditions Raised: - 
  --                          - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015 16:33:30
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************
  
  procedure oauth2callback
    ( state             in varchar2 default null
    , code              in varchar2 default null
    , error             in varchar2 default null
    , error_description in varchar2 default null
    , token             in varchar2 default null);
    
  -- *****************************************************************
  -- Description:       REDIRECT_OAUTH2
  --                    Redirects the user to the google authentication page.
  --                    Google on it's turn will redirect again to the url provided in P_REDIRECT_URI
  --                    is called from GOOGLE_AUTHENTICATION
  -- Input Parameters:  
  --                    - p_scope           the scope for which to ask Google for permission
  --                    - p_client_id       the client-id as provided in your Google Developer Console
  --                    - p_redirect_uri    the URL to which Google should redirect 
  --                                        ie: http(s)://{yourserver}/ords/{schema}.s4sg_auth_pck.oauth2callback
  --                                        be aware to allow this request in your listener console
  --                    - p_gotopage        the page to which the user should be redirected after successfull login
  --                    - p_force_approval  should we request the grants again and again
  --                    - p_ggl_extras      extra parameters you which to give to google
  -- Output Parameters: 
  -- Error Conditions Raised: 
  -- Author:      Richard Martens
  -- Created:     14-3-2015 16:26:50
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************
  procedure redirect_oauth2
    ( p_gotopage       in varchar2 default null
    );

end s4sl_auth_pck;
/
CREATE OR REPLACE PACKAGE BODY  "S4SL_AUTH_PCK" is

function do_request
  ( p_api_uri in varchar2
  , p_method  in varchar2 -- POST or GET
  , p_token   in varchar2 default null
  , p_body    in clob     default null
  ) return clob
is
  t_method           varchar2(255);
  l_retval           nclob;
  l_token            varchar2(2000) := p_token;
  CrLf      constant varchar2(2)    := chr(10) || chr(13);
  t_request_headers  s4sa_requests.request_headers%type;
  l_api_uri          varchar2(1000) := p_api_uri;
begin
    
  -- get token from apex if not provided
  if l_token is null then
    l_token := s4sa_oauth_pck.oauth_token('LINKEDIN');
  end if;
  
  -- Linkedin doesn't accept header Bearer + token instead we must make sure the token
  -- is in the url using the oauth2_access_token parameter
  if instr(lower(l_api_uri), 'oauth2_access_token') = 0 then
    -- we must add the parameter
    if instr(l_api_uri, '?') > 0 then
      l_api_uri := l_api_uri || '&oauth2_access_token=' || l_token;
    else
      l_api_uri := l_api_uri || '?oauth2_access_token=' || l_token;
    end if;
  end if;
  
  -- reset headers from previous request
  apex_web_service.g_request_headers.delete;
  utl_http.set_body_charset('UTF-8');
    
  case p_method
    -- POST-FORM
    when s4sa_oauth_pck.g_http_method_post_form then
      t_method := 'POST';
      apex_web_service.g_request_headers(1).name  := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/x-www-form-urlencoded; charset=UTF-8';
    -- POST-JSON
    when s4sa_oauth_pck.g_http_method_post_json then
      t_method := 'POST';
      apex_web_service.g_request_headers(1).name  := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/json; charset=UTF-8';
      --apex_web_service.g_request_headers(2).name  := 'Authorization';
      --apex_web_service.g_request_headers(2).value := 'Bearer ' || l_token;
    -- GET
    when s4sa_oauth_pck.g_http_method_get then
      t_method := 'GET';
      --apex_web_service.g_request_headers(1).name  := 'Authorization';
      --apex_web_service.g_request_headers(1).value := 'Bearer ' || l_token;
    -- PUT
    when s4sa_oauth_pck.g_http_method_put then
      t_method := 'PUT';
      --apex_web_service.g_request_headers(1).name  := 'Authorization';
      --apex_web_service.g_request_headers(1).value := 'Bearer ' || l_token;
    -- PUT-JSON
    when s4sa_oauth_pck.g_http_method_put_json then
      t_method := 'PUT';
      apex_web_service.g_request_headers(1).name  := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/json; charset=UTF-8';
      --apex_web_service.g_request_headers(2).name  := 'Authorization';
      --apex_web_service.g_request_headers(2).value := 'Bearer ' || l_token;
    -- DELETE
    when s4sa_oauth_pck.g_http_method_delete then
      t_method := 'DELETE';
      --apex_web_service.g_request_headers(1).name  := 'Authorization';
      --apex_web_service.g_request_headers(1).value := 'Bearer ' || l_token;
    else
      raise s4sa_oauth_pck.e_parameter_check;
  end case;
    
  l_retval := apex_web_service.make_rest_request
                ( p_url         => l_api_uri
                , p_http_method => t_method
                , p_wallet_path => s4sa_oauth_pck.g_settings.wallet_path
                , p_wallet_pwd  => s4sa_oauth_pck.g_settings.wallet_pwd
                , p_body        => p_body
                );
                  
  begin
    for ii in 1..apex_web_service.g_request_headers.count loop
      t_request_headers := t_request_headers 
                        || rpad(apex_web_service.g_request_headers(ii).name, 30) || ' = ' 
                        || apex_web_service.g_request_headers(ii).value || CrLf;
    end loop;
    s4sa_oauth_pck.store_request
      ( p_provider        => 'LINKEDIN'
      , p_request_uri     => l_api_uri
      , p_request_type    => t_method || ' (' || p_method || ')'
      , p_request_headers => t_request_headers
      , p_body            => p_body
      , p_response        => l_retval );
  end;
    
  apex_web_service.g_request_headers.delete;
    
  return l_retval;

exception
  when others then
    for ii in 1..apex_web_service.g_request_headers.count loop
      t_request_headers := t_request_headers 
                        || rpad(apex_web_service.g_request_headers(ii).name, 30) || ' = ' 
                        || apex_web_service.g_request_headers(ii).value || CrLf;
    end loop;
    s4sa_oauth_pck.store_request
      ( p_provider        => 'LINKEDIN'
      , p_request_uri     => l_api_uri
      , p_request_type    => t_method || ' (' || p_method || ')'
      , p_request_headers => t_request_headers
      , p_body            => p_body
      , p_response        => l_retval );
    raise;
end do_request;

/*****************************************************************************
  AUTHENTICATION
  description   : the heart of the authentication plugin
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
*****************************************************************************/
procedure authenticate
is
  t_seconds_left  number;
  cursor c_oauth_user
  is     select c.n001 - ((sysdate - c.d001) * 24 * 60 * 60) as seconds_left
         from   apex_collections c
         where  c.collection_name = s4sa_oauth_pck.g_settings.collection_name
           and  c.c001            = 'LINKEDIN';
begin

  open c_oauth_user;
  fetch c_oauth_user into t_seconds_left;
  close c_oauth_user;
    
  if not nvl(t_seconds_left, 0) > 0 then
    redirect_oauth2(p_gotopage => v('APP_PAGE_ID'));
  end if;
    
end authenticate;
  
/*****************************************************************************
  invalid_session
  description   : invalid session function for the authentication plugin
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
*****************************************************************************/
function invalid_session
  ( p_authentication in apex_plugin.t_authentication
  , p_plugin         in apex_plugin.t_plugin 
  ) return apex_plugin.t_authentication_inval_result
is
  t_retval apex_plugin.t_authentication_inval_result;
begin

  redirect_oauth2(p_gotopage => v('APP_PAGE_ID'));
      
  return t_retval;
end invalid_session;
    
/**************************************************************************************************
  GET_TOKEN
  description   : get the token from google with which we can authorise further google requests
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
**************************************************************************************************/
procedure get_token
  ( p_code          in     varchar2
  , po_access_token    out varchar2
  , po_token_type      out varchar2
  , po_expires_in      out number
  , po_id_token        out varchar2
  , po_error           out varchar2
  )
is
  t_response    s4sa_oauth_pck.response_type;
  t_json        json;
begin
    
  t_response := do_request
                  ( p_api_uri => s4sa_oauth_pck.g_settings.api_prefix || 'www.linkedin.com/uas/oauth2/accessToken'
                  , p_method  => s4sa_oauth_pck.g_http_method_post_form
                  , p_body    => 'code='          || p_code                   || '&'
                              || 'client_id='     || g_provider.client_id     || '&'
                              || 'client_secret=' || g_provider.client_secret || '&'
                              || 'redirect_uri='  || g_provider.redirect_uri  || '&'
                              || 'grant_type='    || 'authorization_code'     || ''
                   );
    
  if nullif (length (t_response), 0) is not null then
    t_json := json(t_response);
  else
    raise_application_error(-20000, 'No response received.');
  end if;
  
  if t_json.exist('error') then
    po_error := json_ext.get_string(t_json, 'error.message');
  else
    po_error        := null;
    po_access_token := json_ext.get_string(t_json, 'access_token');
    po_expires_in   := json_ext.get_number(t_json, 'expires_in'  );
    po_id_token     := json_ext.get_string(t_json, 'id_token'    );
    po_token_type   := json_ext.get_string(t_json, 'token_type'  );      
  end if;

end get_token;

/**************************************************************************************************
  GET_USER
  description   : returns a "user" type that represents the logged-in user
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
**************************************************************************************************/
function get_user(p_token in varchar2)
  return s4sa_oauth_pck.oauth2_user
  is
    t_response s4sa_oauth_pck.response_type;
    t_retval   s4sa_oauth_pck.oauth2_user;
    t_json     json;
  begin
    
    t_response := do_request
                    ( p_api_uri => s4sa_oauth_pck.g_settings.api_prefix || 'api.linkedin.com/v1/people/~:'
                                || '(id,num-connections,picture-url,email-address,firstName,'
                                || 'lastName,formatted-name,api-standard-profile-request,'
                                || 'public-profile-url)?format=json'
                    , p_method  => 'GET'
                    , p_token   => p_token);
    
    s4sa_oauth_pck.check_for_error( t_response );
    
    t_json := json(t_response);
    
    t_retval.id             := json_ext.get_string(t_json, 'id'               );
    t_retval.email          := json_ext.get_string(t_json, 'emailAddress'     );
    t_retval.verified       := json_ext.get_bool  (t_json, 'verified_email'   );
    t_retval.name           := json_ext.get_string(t_json, 'formattedName'    );
    t_retval.given_name     := json_ext.get_string(t_json, 'firstName'        );
    t_retval.family_name    := json_ext.get_string(t_json, 'lastName'         );
    t_retval.link           := json_ext.get_string(t_json, 'publicProfileUrl' );
    t_retval.picture        := json_ext.get_string(t_json, 'pictureUrl'       );
    --t_retval.gender         := json_ext.get_string(t_json, 'gender'           );
    --t_retval.locale         := json_ext.get_string(t_json, 'locale'           );
    --t_retval.hd             := json_ext.get_string(t_json, 'hd'               );
    
    return t_retval;
    
  end get_user;

/**************************************************************************************************
  OAUTH2CALLBACK
  description   : is called by the users' browser after being redirected by google
                  performs the actual login
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
**************************************************************************************************/
procedure oauth2callback
  ( state             in varchar2 default null
  , code              in varchar2 default null
  , error             in varchar2 default null
  , error_description in varchar2 default null
  , token             in varchar2 default null
  )
  is
    t_querystring   wwv_flow_global.vc_arr2;
    t_session       varchar2(255);
    t_workspaceid   varchar2(255);
    t_appid         varchar2(255);
    t_gotopage      varchar2(255);
    t_code          varchar2(32767) := code;
    t_access_token  varchar2(32767);
    t_token_type    varchar2(255);
    t_expires_in    varchar2(255);
    t_id_token      varchar2(32767);
    t_error         varchar2(32767);
    t_oauth_user    s4sa_oauth_pck.oauth2_user;
  begin
    
    if error is not null then
      raise_application_error(-20000, error_description);
    end if;
    
    t_querystring := apex_util.string_to_table(state, ':');
    
    for ii in 1..t_querystring.count loop
      case ii
        when 1 then t_session     := t_querystring(ii);
        when 2 then t_workspaceid := t_querystring(ii);
        when 3 then t_appid       := t_querystring(ii);
        when 4 then t_gotopage    := t_querystring(ii);   
        else null;
      end case;
    end loop;
    
    get_token( p_code          => t_code
             , po_access_token => t_access_token
             , po_token_type   => t_token_type
             , po_expires_in   => t_expires_in
             , po_id_token     => t_id_token
             , po_error        => t_error
             );
      
    t_oauth_user := get_user(p_token => t_access_token);
             
    if t_error is null then
      
       s4sa_oauth_pck.do_oauth_login
       ( p_provider     => 'LINKEDIN'
       , p_session      => t_session
       , p_workspaceid  => t_workspaceid
       , p_appid        => t_appid
       , p_gotopage     => t_gotopage
       , p_code         => t_code
       , p_access_token => t_access_token
       , p_token_type   => t_token_type
       , p_expires_in   => t_expires_in
       , p_id_token     => t_id_token
       , p_error        => t_error
       , p_oauth_user   => t_oauth_user
       );
      
    else
      
      owa_util.redirect_url(v('LOGIN_URL') || '&notification_msg=' || apex_util.url_encode(t_error));  
    
    end if;
    
  end oauth2callback;
  
/**************************************************************************************************
  REDIRECT_OAUTH2
  description   : is called by the plugin to start the login-process
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
**************************************************************************************************/
procedure redirect_oauth2
  ( p_gotopage       in varchar2 default null
  ) 
  is
    t_url     varchar2(32767);
  begin
    
    t_url := 'https://www.linkedin.com/uas/oauth2/authorization'
                        || '?response_type=' || 'code'
                        || '&client_id='     || g_provider.client_id 
                        || '&redirect_uri='  || g_provider.redirect_uri 
                        || '&state='         || v('APP_SESSION') || ':' || v('WORKSPACE_ID') || ':' || v('APP_ID') || ':' || p_gotopage
                        || '&scope='         || apex_util.url_encode(g_provider.scope)
                        || g_provider.extras
                        || case g_provider.force_approval
                             when 'Y' then '&approval_prompt=force'
                             else ''
                           end;
                           
    owa_util.redirect_url ( t_url );
    
    apex_application.stop_apex_engine;
                        
  end redirect_oauth2;
  
begin
  
  g_provider.api_key        := s4sa_oauth_pck.get_setting('S4SA_LDI_API_KEY');
  g_provider.client_id      := s4sa_oauth_pck.get_setting('S4SA_LDI_CLIENT_ID');
  g_provider.client_secret  := s4sa_oauth_pck.get_setting('S4SA_LDI_CLIENT_SECRET');
  g_provider.redirect_uri   := s4sa_oauth_pck.get_setting('S4SA_LDI_REDIRECT_URL');
  g_provider.extras         := s4sa_oauth_pck.get_setting('S4SA_LDI_EXTRAS');
  g_provider.scope          := s4sa_oauth_pck.get_setting('S4SA_LDI_SCOPE');
  g_provider.force_approval := s4sa_oauth_pck.get_setting('S4SA_LDI_FORCE_APPROVAL');
  
end s4sl_auth_pck;
/

CREATE OR REPLACE PACKAGE  "S4SG_AUTH_PCK" is
/*                           __
                         _.-~  )
              _..--~~~~,'   ,-/     _    _____ __  __          _____ _______ 
           .-'. . . .'   ,-','    ,' ) / ____|  \/  |   /\   |  __ \__   __|
         ,'. . . _   ,--~,-'__..-'  ,'| (___ | \  / |  /  \  | |__) | | |
       ,'. . .  (@)' ---~~~~      ,'   \___ \| |\/| | / /\ \ |  _  /  | |
      /. . . . '~~             ,-'     ____) | |  | |/ ____ \| | \ \  | |
     /. . . . .             ,-'   _  _|_____/|_|  |_/_/ _  \_\_|_ \_\ |_|
    ; . . . .  - .        ,'     | || |           | |     | | (_)
   : . . . .       _     /       | || |_ ___  ___ | |_   _| |_ _  ___  _ __  ___
  . . . . .          `-.:        |__   _/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
 . . . ./  - .          )           | | \__ \ (_) | | |_| | |_| | (_) | | | \__ \
.  . . |  _____..---.._/            |_| |___/\___/|_|\__,_|\__|_|\___/|_| |_|___/
-~~----~~~~             ~---~~~~--~~~--~~~---~---~---~~~~----~~~~~---~~~--~~~---~~~---
--
--    NAME
--      s4sg_auth_pck
--
--    DESCRIPTION
--      
--
--    MODIFIED   (DD-MM-YYYY)
--    RICHARD MARTENS   14-3-2015 12:28:59 - Created
--    RICHARD MARTENS   31-08-2015 17:59 - Added revision global
--------------------------------------------------------------------------------
*/

gc_revision constant varchar2(100) := 'Revision: 0 (build: 0)';
g_provider  s4sa_oauth_pck.tp_provider_settings;

function do_request
  ( p_api_uri in varchar2
  , p_method  in varchar2 -- POST or GET
  , p_token   in varchar2 default null
  , p_body    in clob     default null
  )
  return clob;
  
  -- *****************************************************************
  -- Description:       GOOGLE_AUTHENTICATION
  --                    This is the process called by apex to login the user
  --                    results in the user being redirected to the google login-page
  -- Input Parameters:  - p_authentication
  --                    - p_plugin
  --                    - p_password
  -- Output Parameters: - 
  -- Error Conditions Raised: - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************  
procedure authenticate;
  
  -- *****************************************************************
  -- Description:       INVALID_SESSION
  --                    is called by the apex authentication plugin when apex
  --                    detects an invalid session.
  --                    results in the user getting redirected to google again.
  -- Input Parameters:  - 
  -- Output Parameters: - 
  -- Error Conditions Raised: - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************
function invalid_session
  ( p_authentication in apex_plugin.t_authentication
  , p_plugin         in apex_plugin.t_plugin 
  ) return apex_plugin.t_authentication_inval_result;
    
  -- *****************************************************************
  -- Description:       GET_TOKEN
  --                    gets the authentication code from google
  -- Input Parameters:  - p_code           the code as provided by google oauth2callback
  --                    - p_client_id      the clientid as provided in your google developer console
  --                    - p_client_secret  the client secret as provided in your google developer console
  --                    - p_redirect_uri   the redirect uri as you entered it in the call to redirect_oath2
  --                    - p_wallet_path    the path where your wallet is located
  --                    - p_wallet_pwd     the wallet's password
  -- Output Parameters: - po_access_token  the access token
  --                    - po_token_type    the token_type (Bearer)
  --                    - po_expires_in    the seconds when the token expires
  --                    - po_id_token      the token_id
  --                    - po_error         error when occurred
  -- Error Conditions Raised: - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015 16:35:42
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************
  procedure get_token
    ( p_code          in     varchar2
    , po_access_token    out varchar2
    , po_token_type      out varchar2
    , po_expires_in      out number
    , po_id_token        out varchar2
    , po_error           out varchar2
    );
    
  -- *****************************************************************
  -- Description:       GET_USER
  --                    returns the current loggen-in Google-user
  -- Input Parameters:  - p_token          the authorization token as provided by Google
  -- Output Parameters: 
  -- Error Conditions Raised: - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015 16:35:42
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************
  function get_user(p_token in varchar2)
    return s4sa_oauth_pck.oauth2_user;
  
  -- *****************************************************************
  -- Description:       OAUTH2CALLBACK
  --                    is called by google, contains the actual Apex login process
  -- Input Parameters:  - state              is provided by google redirect
  --                    - code               is provided by google redirect
  --                    - error              is provided by google redirect
  --                    - error_description  is provided by google redirect
  --                    - token              is provided by google redirect
  -- Output Parameters: - 
  --                    - 
  -- Error Conditions Raised: - 
  --                          - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015 16:33:30
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************  
  procedure oauth2callback
    ( state             in varchar2 default null
    , code              in varchar2 default null
    , error             in varchar2 default null
    , error_description in varchar2 default null
    , token             in varchar2 default null);
    
  -- *****************************************************************
  -- Description:       REDIRECT_OAUTH2
  --                    Redirects the user to the google authentication page.
  --                    Google on it's turn will redirect again to the url provided in P_REDIRECT_URI
  --                    is called from GOOGLE_AUTHENTICATION
  -- Input Parameters:  
  --                    - p_scope           the scope for which to ask Google for permission
  --                    - p_client_id       the client-id as provided in your Google Developer Console
  --                    - p_redirect_uri    the URL to which Google should redirect 
  --                                        ie: http(s)://{yourserver}/ords/{schema}.s4sg_auth_pck.oauth2callback
  --                                        be aware to allow this request in your listener console
  --                    - p_gotopage        the page to which the user should be redirected after successfull login
  --                    - p_force_approval  should we request the grants again and again
  --                    - p_ggl_extras      extra parameters you which to give to google
  -- Output Parameters: 
  -- Error Conditions Raised: 
  -- Author:      Richard Martens
  -- Created:     14-3-2015 16:26:50
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************
  procedure redirect_oauth2
    ( p_gotopage       in varchar2 default null
    );

end s4sg_auth_pck;
/
CREATE OR REPLACE PACKAGE BODY  "S4SG_AUTH_PCK" is

function do_request
  ( p_api_uri in varchar2
  , p_method  in varchar2 -- POST or GET
  , p_token   in varchar2 default null
  , p_body    in clob     default null
  ) return clob
is
  t_method           varchar2(255);
  l_retval           nclob;
  l_token            varchar2(2000) := p_token;
  CrLf      constant varchar2(2)    := chr(10) || chr(13);
  t_request_headers  s4sa_requests.request_headers%type;
  l_api_uri          varchar2(1000) := p_api_uri;
begin
    
  -- get token from apex if not provided
  if l_token is null then
    l_token := s4sa_oauth_pck.oauth_token('GOOGLE');
  end if;
    
  -- reset headers from previous request
  apex_web_service.g_request_headers.delete;
  utl_http.set_body_charset('UTF-8');
    
  case p_method
    -- POST-FORM
    when s4sa_oauth_pck.g_http_method_post_form then
      t_method := 'POST';
      apex_web_service.g_request_headers(1).name  := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/x-www-form-urlencoded; charset=UTF-8';
    -- POST-MAIL
    when s4sa_oauth_pck.g_http_method_post_mail then
      t_method := 'POST';
      apex_web_service.g_request_headers(1).name  := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/json; charset=UTF-8';
      apex_web_service.g_request_headers(2).name  := 'Authorization';
      apex_web_service.g_request_headers(2).value := 'Bearer ' || l_token;
    -- POST-JSON
    when s4sa_oauth_pck.g_http_method_post_json then
      t_method := 'POST';
      apex_web_service.g_request_headers(1).name  := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/json; charset=UTF-8';
      apex_web_service.g_request_headers(2).name  := 'Authorization';
      apex_web_service.g_request_headers(2).value := 'Bearer ' || l_token;
    -- GET
    when s4sa_oauth_pck.g_http_method_get then
      t_method := 'GET';
      apex_web_service.g_request_headers(1).name  := 'Authorization';
      apex_web_service.g_request_headers(1).value := 'Bearer ' || l_token;
    -- PUT
    when s4sa_oauth_pck.g_http_method_put then
      t_method := 'PUT';
      apex_web_service.g_request_headers(1).name  := 'Authorization';
      apex_web_service.g_request_headers(1).value := 'Bearer ' || l_token;
    -- PUT-JSON
    when s4sa_oauth_pck.g_http_method_put_json then
      t_method := 'PUT';
      apex_web_service.g_request_headers(1).name  := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/json; charset=UTF-8';
      apex_web_service.g_request_headers(2).name  := 'Authorization';
      apex_web_service.g_request_headers(2).value := 'Bearer ' || l_token;
    -- DELETE
    when s4sa_oauth_pck.g_http_method_delete then
      t_method := 'DELETE';
      apex_web_service.g_request_headers(1).name  := 'Authorization';
      apex_web_service.g_request_headers(1).value := 'Bearer ' || l_token;
    else
      raise s4sa_oauth_pck.e_parameter_check;
  end case;
  
  --rae(l_api_uri);
    
  l_retval := apex_web_service.make_rest_request
                ( p_url         => l_api_uri
                , p_http_method => t_method
                , p_wallet_path => s4sa_oauth_pck.g_settings.wallet_path
                , p_wallet_pwd  => s4sa_oauth_pck.g_settings.wallet_pwd
                , p_body        => p_body
                );
                  
  begin
    for ii in 1..apex_web_service.g_request_headers.count loop
      t_request_headers := t_request_headers 
                        || rpad(apex_web_service.g_request_headers(ii).name, 30) || ' = ' 
                        || apex_web_service.g_request_headers(ii).value || CrLf;
    end loop;
    s4sa_oauth_pck.store_request
      ( p_provider        => 'GOOGLE'
      , p_request_uri     => l_api_uri
      , p_request_type    => t_method || ' (' || p_method || ')'
      , p_request_headers => t_request_headers
      , p_body            => p_body
      , p_response        => l_retval );
  end;
    
    
  apex_web_service.g_request_headers.delete;
    
  return l_retval;
exception
  when others then
    raise_application_error(-20000, p_api_uri);
end do_request;
  
/*****************************************************************************
  GOOGLE_AUTHENTICATION
  description   : the heart of the authentication plugin
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
*****************************************************************************/
procedure authenticate
is
  t_seconds_left  number;
  cursor c_oauth_user
  is     select c.n001 - ((sysdate - c.d001) * 24 * 60 * 60) as seconds_left
         from   apex_collections c
         where  c.collection_name = s4sa_oauth_pck.g_settings.collection_name
           and  c.c001            = 'GOOGLE';
begin

  open c_oauth_user;
  fetch c_oauth_user into t_seconds_left;
  close c_oauth_user;
    
  if not nvl(t_seconds_left, 0) > 0 then
    redirect_oauth2(p_gotopage => v('APP_PAGE_ID'));
  end if;
    
end authenticate;
  
/*****************************************************************************
  invalid_session
  description   : invalid session function for the authentication plugin
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
*****************************************************************************/
function invalid_session
  ( p_authentication in apex_plugin.t_authentication
  , p_plugin         in apex_plugin.t_plugin 
  ) return apex_plugin.t_authentication_inval_result
is
  t_retval apex_plugin.t_authentication_inval_result;
begin

  redirect_oauth2(p_gotopage => v('APP_PAGE_ID'));
      
  return t_retval;
end invalid_session;
    
/**************************************************************************************************
  GET_TOKEN
  description   : get the token from google with which we can authorise further google requests
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
**************************************************************************************************/
procedure get_token
  ( p_code          in     varchar2
  , po_access_token    out varchar2
  , po_token_type      out varchar2
  , po_expires_in      out number
  , po_id_token        out varchar2
  , po_error           out varchar2
  )
is
  t_response    s4sa_oauth_pck.response_type;
  t_json        json;
begin
    
  t_response := do_request
                  ( p_api_uri => s4sa_oauth_pck.g_settings.api_prefix || 'accounts.google.com/o/oauth2/token'
                  , p_method  => s4sa_oauth_pck.g_http_method_post_form
                  , p_body    => 'code='          || p_code                  || '&'
                              || 'client_id='     || g_provider.client_id     || '&'
                              || 'client_secret=' || g_provider.client_secret || '&'
                              || 'redirect_uri='  || g_provider.redirect_uri  || '&'
                              || 'grant_type='    || 'authorization_code'    || ''
                   );
    
  if nullif (length (t_response), 0) is not null then
    t_json := json(t_response);
  else
    raise_application_error(-20000, 'No response received.');
  end if;
  
  if t_json.exist('error') then
    po_error := json_ext.get_string(t_json, 'error.message');
  else
    po_error        := null;
    po_access_token := json_ext.get_string(t_json, 'access_token');
    po_expires_in   := json_ext.get_number(t_json, 'expires_in'  );
    po_id_token     := json_ext.get_string(t_json, 'id_token'    );
    po_token_type   := json_ext.get_string(t_json, 'token_type'  );      
  end if;

end get_token;

/**************************************************************************************************
  GET_USER
  description   : returns a "google user" type that represents the logged-in user
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
**************************************************************************************************/
function get_user(p_token in varchar2)
  return s4sa_oauth_pck.oauth2_user
  is
    t_response s4sa_oauth_pck.response_type;
    t_retval   s4sa_oauth_pck.oauth2_user;
    t_json     json;
  begin
    
    t_response := do_request
                    ( p_api_uri => s4sa_oauth_pck.g_settings.api_prefix || 'www.googleapis.com/oauth2/v2/userinfo'
                    , p_method  => 'GET'
                    , p_token   => p_token);
    
    s4sa_oauth_pck.check_for_error( t_response );
    
    t_json := json(t_response);
    
    t_retval.id             := json_ext.get_string(t_json, 'id'            );
    t_retval.email          := json_ext.get_string(t_json, 'email'         );
    t_retval.verified       := json_ext.get_bool  (t_json, 'verified_email');
    t_retval.name           := json_ext.get_string(t_json, 'name'          );
    t_retval.given_name     := json_ext.get_string(t_json, 'given_name'    );
    t_retval.family_name    := json_ext.get_string(t_json, 'family_name'   );
    t_retval.link           := json_ext.get_string(t_json, 'link'          );
    t_retval.picture        := json_ext.get_string(t_json, 'picture'       );
    t_retval.gender         := json_ext.get_string(t_json, 'gender'        );
    t_retval.locale         := json_ext.get_string(t_json, 'locale'        );
    t_retval.hd             := json_ext.get_string(t_json, 'hd'            );
    
    return t_retval;
    
  end get_user;

/**************************************************************************************************
  OAUTH2CALLBACK
  description   : is called by the users' browser after being redirected by google
                  performs the actual login
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
**************************************************************************************************/
procedure oauth2callback
  ( state             in varchar2 default null
  , code              in varchar2 default null
  , error             in varchar2 default null
  , error_description in varchar2 default null
  , token             in varchar2 default null
  )
  is
    t_querystring   wwv_flow_global.vc_arr2;
    t_session       varchar2(255);
    t_workspaceid   varchar2(255);
    t_appid         varchar2(255);
    t_gotopage      varchar2(255);
    t_code          varchar2(32767) := code;
    t_access_token  varchar2(32767);
    t_token_type    varchar2(255);
    t_expires_in    varchar2(255);
    t_id_token      varchar2(32767);
    t_error         varchar2(32767);
    t_oauth_user    s4sa_oauth_pck.oauth2_user;
  begin
    
    -- demo
    --raise_application_error(-20000, 'stop');
    
    -- read state parameter in the querystring
    t_querystring := apex_util.string_to_table(state, ':');
    -- put querystring into variables
    for ii in 1..t_querystring.count loop
      case ii
        when 1 then t_session     := t_querystring(ii);
        when 2 then t_workspaceid := t_querystring(ii);
        when 3 then t_appid       := t_querystring(ii);
        when 4 then t_gotopage    := t_querystring(ii);   
        else null;
      end case;
    end loop;
    -- check for error
    if error is not null then
      s4sa_oauth_pck.present_error
        ( p_workspaceid => t_workspaceid
        , p_appid       => t_appid
        , p_gotopage    => t_gotopage
        , p_session     => t_session
        , p_errormsg    => error
        );
    else
      
      -- get the token (STEP 2)
      get_token( p_code          => t_code  -- <== this is the code used for requesting an access token
               , po_access_token => t_access_token
               , po_token_type   => t_token_type
               , po_expires_in   => t_expires_in
               , po_id_token     => t_id_token
               , po_error        => t_error
               );
      
      -- using the token we can now ask google who logged in.  
      t_oauth_user := get_user(p_token => t_access_token);
      
      -- if no error is received we can log in the user in our apex application
      if t_error is null then
        
         s4sa_oauth_pck.do_oauth_login
         ( p_provider     => 'GOOGLE'
         , p_session      => t_session
         , p_workspaceid  => t_workspaceid
         , p_appid        => t_appid
         , p_gotopage     => t_gotopage
         , p_code         => t_code
         , p_access_token => t_access_token
         , p_token_type   => t_token_type
         , p_expires_in   => t_expires_in
         , p_id_token     => t_id_token
         , p_error        => t_error
         , p_oauth_user   => t_oauth_user
         );
        
      else -- we did receive an error, go back to the loginpage and show the message.
        
        owa_util.redirect_url(v('LOGIN_URL') || '&notification_msg=' || apex_util.url_encode(t_error));  
        
      end if;
    end if;
        
  end oauth2callback;
  
/**************************************************************************************************
  REDIRECT_OAUTH2
  description   : is called by the plugin to start the login-process
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
**************************************************************************************************/
procedure redirect_oauth2
  ( p_gotopage       in varchar2 default null
  ) 
  is
    t_url     varchar2(32767);
  begin
  
    t_url := 'https://accounts.google.com/o/oauth2/auth?client_id=' || g_provider.client_id 
                        || '&redirect_uri='  || g_provider.redirect_uri 
                        || '&scope='         || apex_util.url_encode(g_provider.scope)
                        || '&state='         || v('APP_SESSION') || ':' || v('WORKSPACE_ID') || ':' || v('APP_ID') || ':' || p_gotopage
                        || '&response_type=' || 'code'  -- mandatory for google
                        || g_provider.extras
                        || case g_provider.force_approval
                             when 'Y' then '&approval_prompt=force'
                             else ''
                           end
                        ;
                           
    owa_util.redirect_url ( t_url );
    
    apex_application.stop_apex_engine;
                        
  end redirect_oauth2;
  
begin
  
  g_provider.api_key        := s4sa_oauth_pck.get_setting('S4SA_GGL_API_KEY');
  g_provider.client_id      := s4sa_oauth_pck.get_setting('S4SA_GGL_CLIENT_ID');
  g_provider.client_secret  := s4sa_oauth_pck.get_setting('S4SA_GGL_CLIENT_SECRET');
  g_provider.redirect_uri   := s4sa_oauth_pck.get_setting('S4SA_GGL_REDIRECT_URL');
  g_provider.extras         := s4sa_oauth_pck.get_setting('S4SA_GGL_EXTRAS');
  g_provider.scope          := s4sa_oauth_pck.get_setting('S4SA_GGL_SCOPE');
  g_provider.force_approval := s4sa_oauth_pck.get_setting('S4SA_GGL_FORCE_APPROVAL');
  
end s4sg_auth_pck;
/

CREATE OR REPLACE PACKAGE  "S4SF_AUTH_PCK" is
/*                           __
                         _.-~  )
              _..--~~~~,'   ,-/     _    _____ __  __          _____ _______ 
           .-'. . . .'   ,-','    ,' ) / ____|  \/  |   /\   |  __ \__   __|
         ,'. . . _   ,--~,-'__..-'  ,'| (___ | \  / |  /  \  | |__) | | |
       ,'. . .  (@)' ---~~~~      ,'   \___ \| |\/| | / /\ \ |  _  /  | |
      /. . . . '~~             ,-'     ____) | |  | |/ ____ \| | \ \  | |
     /. . . . .             ,-'   _  _|_____/|_|  |_/_/ _  \_\_|_ \_\ |_|
    ; . . . .  - .        ,'     | || |           | |     | | (_)
   : . . . .       _     /       | || |_ ___  ___ | |_   _| |_ _  ___  _ __  ___
  . . . . .          `-.:        |__   _/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
 . . . ./  - .          )           | | \__ \ (_) | | |_| | |_| | (_) | | | \__ \
.  . . |  _____..---.._/            |_| |___/\___/|_|\__,_|\__|_|\___/|_| |_|___/
-~~----~~~~             ~---~~~~--~~~--~~~---~---~---~~~~----~~~~~---~~~--~~~---~~~---
--
--    NAME
--      s4sf_auth_pck
--
--    DESCRIPTION
--      
--
--    MODIFIED   (DD-MM-YYYY)
--    RICHARD MARTENS   14-3-2015 12:28:59 - Created
--    RICHARD MARTENS   31-08-2015 17:59 - Added revision global
--------------------------------------------------------------------------------
*/

gc_revision constant varchar2(100) := 'Revision: 0 (build: 0)';
g_provider  s4sa_oauth_pck.tp_provider_settings;

function do_request
  ( p_api_uri in varchar2
  , p_method  in varchar2 -- POST or GET
  , p_token   in varchar2 default null
  , p_body    in clob     default null
  )
  return clob;
  
  -- *****************************************************************
  -- Description:       AUTHENTICATE
  --                    This is the process called by apex to login the user
  --                    results in the user being redirected to the google login-page
  -- Input Parameters:  - p_authentication
  --                    - p_plugin
  --                    - p_password
  -- Output Parameters: - 
  -- Error Conditions Raised: - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************  
procedure authenticate;
  
  -- *****************************************************************
  -- Description:       INVALID_SESSION
  --                    is called by the apex authentication plugin when apex
  --                    detects an invalid session.
  --                    results in the user getting redirected to google again.
  -- Input Parameters:  - 
  -- Output Parameters: - 
  -- Error Conditions Raised: - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************
function invalid_session
  ( p_authentication in apex_plugin.t_authentication
  , p_plugin         in apex_plugin.t_plugin 
  ) return apex_plugin.t_authentication_inval_result;
    
  -- *****************************************************************
  -- Description:       GET_TOKEN
  --                    gets the authentication code from google
  -- Input Parameters:  - p_code           the code as provided by google oauth2callback
  --                    - p_client_id      the clientid as provided in your google developer console
  --                    - p_client_secret  the client secret as provided in your google developer console
  --                    - p_redirect_uri   the redirect uri as you entered it in the call to redirect_oath2
  --                    - p_wallet_path    the path where your wallet is located
  --                    - p_wallet_pwd     the wallet's password
  -- Output Parameters: - po_access_token  the access token
  --                    - po_token_type    the token_type (Bearer)
  --                    - po_expires_in    the seconds when the token expires
  --                    - po_id_token      the token_id
  --                    - po_error         error when occurred
  -- Error Conditions Raised: - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015 16:35:42
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************
  procedure get_token
    ( p_code          in     varchar2
    , po_access_token    out varchar2
    , po_token_type      out varchar2
    , po_expires_in      out number
    , po_id_token        out varchar2
    , po_error           out varchar2
    );
    
  -- *****************************************************************
  -- Description:       GET_GOOGLE_USER
  --                    returns the current loggen-in Google-user
  -- Input Parameters:  - p_token          the authorization token as provided by Google
  -- Output Parameters: 
  -- Error Conditions Raised: - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015 16:35:42
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************
  function get_user(p_token in varchar2)
    return s4sa_oauth_pck.oauth2_user;
  
  -- *****************************************************************
  -- Description:       OAUTH2CALLBACK
  --                    is called by google, contains the actual Apex login process
  -- Input Parameters:  - state              is provided by facebook redirect
  --                    - code               is provided by facebook redirect
  --                    - error_code         is provided by facebook redirect
  --                    - error_message      is provided by facebook redirect
  --                    - token              is provided by facebook redirect
  -- Output Parameters: - 
  --                    - 
  -- Error Conditions Raised: - 
  --                          - 
  -- Author:      Richard Martens
  -- Created:     14-3-2015 16:33:30
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************
procedure oauth2callback
  ( state             in varchar2 default null
  , access_token      in varchar2 default null
  , expires_in        in varchar2 default null
  , code              in varchar2 default null
  , error_code        in varchar2 default null
  , error_message     in varchar2 default null
  );
    
  -- *****************************************************************
  -- Description:       REDIRECT_OAUTH2
  --                    Redirects the user to the google authentication page.
  --                    Google on it's turn will redirect again to the url provided in P_REDIRECT_URI
  --                    is called from GOOGLE_AUTHENTICATION
  -- Input Parameters:  
  --                    - p_scope           the scope for which to ask Google for permission
  --                    - p_client_id       the client-id as provided in your Google Developer Console
  --                    - p_redirect_uri    the URL to which Google should redirect 
  --                                        ie: http(s)://{yourserver}/ords/{schema}.s4sg_auth_pck.oauth2callback
  --                                        be aware to allow this request in your listener console
  --                    - p_gotopage        the page to which the user should be redirected after successfull login
  --                    - p_force_approval  should we request the grants again and again
  --                    - p_ggl_extras      extra parameters you which to give to google
  -- Output Parameters: 
  -- Error Conditions Raised: 
  -- Author:      Richard Martens
  -- Created:     14-3-2015 16:26:50
  -- Revision History
  -- Date            Author       Reason for Change
  -- ----------------------------------------------------------------
  -- 14-3-2015     RICHARD MARTENS     Created.
  -- *****************************************************************
  procedure redirect_oauth2
    ( p_gotopage       in varchar2 default null
    );

end s4sf_auth_pck;
/
CREATE OR REPLACE PACKAGE BODY  "S4SF_AUTH_PCK" is

function do_request
  ( p_api_uri in varchar2
  , p_method  in varchar2 -- POST or GET
  , p_token   in varchar2 default null
  , p_body    in clob     default null
  ) return clob
is
  t_method           varchar2(255);
  l_retval           nclob;
  l_token            varchar2(2000) := p_token;
  CrLf      constant varchar2(2)    := chr(10) || chr(13);
  t_request_headers  s4sa_requests.request_headers%type;
  l_api_uri          varchar2(1000) := p_api_uri;
begin
    
  -- get token from apex if not provided
  if l_token is null then
    l_token := s4sa_oauth_pck.oauth_token('FACEBOOK');
  end if;
    
  -- reset headers from previous request
  apex_web_service.g_request_headers.delete;
  utl_http.set_body_charset('UTF-8');
    
  case p_method
    -- POST-FORM
    when s4sa_oauth_pck.g_http_method_post_form then
      t_method := 'POST';
    -- POST-JSON
    when s4sa_oauth_pck.g_http_method_post_json then
      t_method := 'POST';
    when s4sa_oauth_pck.g_http_method_get_init  then
      t_method := 'GET';
    -- GET
    when s4sa_oauth_pck.g_http_method_get       then
      t_method := 'GET';
      l_api_uri := l_api_uri || case when instr(l_api_uri, '?') = 0 
                                  then '?'
                                  else '&'
                                end;
      l_api_uri := l_api_uri
                || 'access_token=' || l_token
                || '&debug='        || 'all'
                || '&format='       || 'json'
                || '&method='       || 'get'
                || '&pretty='       || '1'
                || '&suppress_http_code=1';
    -- PUT
    when s4sa_oauth_pck.g_http_method_put       then
      t_method := 'PUT';
    -- PUT-JSON
    when s4sa_oauth_pck.g_http_method_put_json  then
      t_method := 'PUT';
    -- DELETE
    when s4sa_oauth_pck.g_http_method_delete    then
      t_method := 'DELETE';
    else
      raise s4sa_oauth_pck.e_parameter_check;
  end case;
    
  l_retval := apex_web_service.make_rest_request
                ( p_url         => l_api_uri
                , p_http_method => t_method
                , p_wallet_path => s4sa_oauth_pck.g_settings.wallet_path
                , p_wallet_pwd  => s4sa_oauth_pck.g_settings.wallet_pwd
                , p_body        => p_body
                );
                  
  begin
    for ii in 1..apex_web_service.g_request_headers.count loop
      t_request_headers := t_request_headers 
                        || rpad(apex_web_service.g_request_headers(ii).name, 30) || ' = ' 
                        || apex_web_service.g_request_headers(ii).value || CrLf;
    end loop;
    s4sa_oauth_pck.store_request
      ( p_provider        => 'FACEBOOK'
      , p_request_uri     => l_api_uri
      , p_request_type    => t_method || ' (' || p_method || ')'
      , p_request_headers => t_request_headers
      , p_body            => p_body
      , p_response        => l_retval );
  end;
    
    
  apex_web_service.g_request_headers.delete;
    
  return l_retval;
end do_request;

/*****************************************************************************
  FACEBOOK_AUTHENTICATION
  description   : the heart of the authentication plugin
  change history:
  date          name         remarks
  may 2015      R.Martens    Initial version
*****************************************************************************/
procedure authenticate
is
  t_seconds_left  number;
  cursor c_oauth_user
  is     select c.n001 - ((sysdate - c.d001) * 24 * 60 * 60) as seconds_left
         from   apex_collections c
         where  c.collection_name = s4sa_oauth_pck.g_settings.collection_name
           and  c.c001            = 'FACEBOOK';
begin

  open c_oauth_user;
  fetch c_oauth_user into t_seconds_left;
  close c_oauth_user;
    
  if not nvl(t_seconds_left, 0) > 0 then
    redirect_oauth2(p_gotopage => v('APP_PAGE_ID'));
  end if;
    
end authenticate;
  
/*****************************************************************************
  invalid_session
  description   : invalid session function for the authentication plugin
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
*****************************************************************************/
function invalid_session
  ( p_authentication in apex_plugin.t_authentication
  , p_plugin         in apex_plugin.t_plugin 
  ) return apex_plugin.t_authentication_inval_result
is
  t_retval apex_plugin.t_authentication_inval_result;
begin

  redirect_oauth2(p_gotopage => v('APP_PAGE_ID'));
      
  return t_retval;
end invalid_session;
    
/**************************************************************************************************
  GET_TOKEN
  description   : get the token from google with which we can authorise further google requests
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
**************************************************************************************************/
procedure get_token
  ( p_code          in     varchar2
  , po_access_token    out varchar2
  , po_token_type      out varchar2
  , po_expires_in      out number
  , po_id_token        out varchar2
  , po_error           out varchar2
  )
is
  t_response    s4sa_oauth_pck.response_type;
  t_tbl_resp    wwv_flow_global.vc_arr2;
  t_tbl_var     wwv_flow_global.vc_arr2;
begin
  
  po_access_token := null;
  po_token_type   := null;
  po_expires_in   := null;
  po_id_token     := null;
  po_error        := null;
    
  t_response := do_request
                  ( p_api_uri => s4sa_oauth_pck.g_settings.api_prefix || 'graph.facebook.com/oauth/access_token'
                               || '?client_id='     || g_provider.client_id
                               || '&redirect_uri='  || g_provider.redirect_uri
                               || '&client_secret=' || g_provider.client_secret
                               || '&code='          || p_code
                  , p_method  => s4sa_oauth_pck.g_http_method_get_init
                   );
                   
  if nullif (length (t_response), 0) is not null then
    t_json := json(t_response);
  else
    raise_application_error(-20000, 'No response received.');
  end if;
   
  if t_json.exist('error') then
    po_error := json_ext.get_string(t_json, 'error.message');
  else
    po_error        := null;
    po_access_token := json_ext.get_string(t_json, 'access_token');
    po_expires_in   := json_ext.get_number(t_json, 'expires_in'  );
    po_id_token     := json_ext.get_string(t_json, 'id_token'    );
    po_token_type   := json_ext.get_string(t_json, 'token_type'  );     
  end if;

end get_token;

/**************************************************************************************************
  GET_USER
  description   : returns a "google user" type that represents the logged-in user
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
**************************************************************************************************/
function get_user(p_token in varchar2)
  return s4sa_oauth_pck.oauth2_user
  is
    t_response s4sa_oauth_pck.response_type;
    t_retval   s4sa_oauth_pck.oauth2_user;
    t_json     json;
  begin
    
    t_response := do_request
                    ( p_api_uri => s4sa_oauth_pck.g_settings.api_prefix || 'graph.facebook.com/' 
                                || g_provider.api_version 
                                || '/me'
                    , p_token   => p_token
                    , p_method  => s4sa_oauth_pck.g_http_method_get);
    
    s4sa_oauth_pck.check_for_error( t_response );
    
    t_json := json(t_response);
    
    t_retval.id             := json_ext.get_string(t_json, 'id'            );
    t_retval.name           := json_ext.get_string(t_json, 'name'          );
    t_retval.email          := json_ext.get_string(t_json, 'email'         );
    t_retval.given_name     := json_ext.get_string(t_json, 'first_name'    );
    t_retval.family_name    := json_ext.get_string(t_json, 'last_name'     );
    t_retval.gender         := json_ext.get_string(t_json, 'gender'        );
    t_retval.link           := json_ext.get_string(t_json, 'link'          );
    t_retval.locale         := json_ext.get_string(t_json, 'locale'        );
    t_retval.time_zone      := json_ext.get_number(t_json, 'time_zone'     );
    t_retval.hd             := null;
    --t_retval.picture        := '//graph.facebook.com/' || t_retval.id || '/picture';
    t_retval.updated_time   := s4sa_oauth_pck.to_ts_tz
                                 ( json_ext.get_string(t_json, 'updated_time') );
    t_retval.verified       := json_ext.get_bool  (t_json, 'verified'      );
    
    -- get picture in separate request
    t_response := do_request
                    ( p_api_uri => s4sa_oauth_pck.g_settings.api_prefix || 'graph.facebook.com/' 
                                || t_retval.id || '/picture'
                                || '?redirect=false'                                
                    , p_method  => s4sa_oauth_pck.g_http_method_get);
    s4sa_oauth_pck.check_for_error( t_response );
    t_json := json( t_response );
    t_retval.picture := json_ext.get_string(t_json, 'data.url');
    
    return t_retval;
    
  end get_user;
  
/**************************************************************************************************
  OAUTH2CALLBACK
  description   : is called by the users' browser after being redirected by google
                  performs the actual login
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
**************************************************************************************************/
procedure oauth2callback
  ( state             in varchar2 default null
  , access_token      in varchar2 default null
  , expires_in        in varchar2 default null
  , code              in varchar2 default null
  , error_code        in varchar2 default null
  , error_message     in varchar2 default null
  )
  is
    t_querystring   wwv_flow_global.vc_arr2;
    t_session       varchar2(255);
    t_workspaceid   varchar2(255);
    t_appid         varchar2(255);
    t_gotopage      varchar2(255);
    t_code          varchar2(32767) := code;
    t_access_token  varchar2(32767);
    t_token_type    varchar2(255);
    t_expires_in    varchar2(255);
    t_id_token      varchar2(32767);
    t_error         varchar2(32767);
    t_oauth_user    s4sa_oauth_pck.oauth2_user;
    t_uri           varchar2(32767);
  begin
    
    --if not s4sa_oauth_pck.is_plsqldev then
    --  return;
    --end if;
    
    t_querystring := apex_util.string_to_table(utl_url.unescape(state), ':');
    
    for ii in 1..t_querystring.count loop
      case ii
        when 1 then t_session     := t_querystring(ii);
        when 2 then t_workspaceid := t_querystring(ii);
        when 3 then t_appid       := t_querystring(ii);
        when 4 then t_gotopage    := t_querystring(ii);   
        else null;
      end case;
    end loop;
    
    if error_code is not null then
      s4sa_oauth_pck.present_error
        ( p_workspaceid => t_workspaceid
        , p_appid       => t_appid
        , p_gotopage    => t_gotopage
        , p_session     => t_session
        , p_errormsg    => error_message
        );
    else
    
      get_token( p_code          => t_code
               , po_access_token => t_access_token
               , po_token_type   => t_token_type
               , po_expires_in   => t_expires_in
               , po_id_token     => t_id_token
               , po_error        => t_error
               );
               
      if t_error is not null then
        s4sa_oauth_pck.check_for_error(t_error);
      end if;
        
      t_oauth_user := get_user(p_token => t_access_token);
          
      if t_error is null then
        
        s4sa_oauth_pck.do_oauth_login
         ( p_provider     => 'FACEBOOK'
         , p_session      => t_session
         , p_workspaceid  => t_workspaceid
         , p_appid        => t_appid
         , p_gotopage     => t_gotopage
         , p_code         => t_code
         , p_access_token => t_access_token
         , p_token_type   => t_token_type
         , p_expires_in   => t_expires_in
         , p_id_token     => t_id_token
         , p_error        => t_error
         , p_oauth_user   => t_oauth_user
         );
        
      else
        
        owa_util.redirect_url(v('LOGIN_URL') || '&notification_msg=' || apex_util.url_encode(t_error));  
      
      end if;
    end if;
        
  end oauth2callback;
  
/**************************************************************************************************
  REDIRECT_OAUTH2
  description   : is called by the plugin to start the login-process
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
**************************************************************************************************/
procedure redirect_oauth2
  ( p_gotopage       in varchar2 default null
  ) 
  is
    t_url     varchar2(32767);
  begin
    t_url := 'https://www.facebook.com/dialog/oauth?'
                        || 'client_id='      || g_provider.client_id
                        || '&redirect_uri='  || g_provider.redirect_uri 
                        || '&scope='         || apex_util.url_encode(g_provider.scope)
                        || '&state='         || v('APP_SESSION') || ':' || v('WORKSPACE_ID') || ':' || v('APP_ID') || ':' || p_gotopage
                        || '&response_type=' || 'code'
                        || g_provider.extras
                        || '&approval_prompt=force'
                        --|| case p_force_approval
                        --     when 'Y' then '&approval_prompt=force'
                        --     else ''
                        --   end
                        ;
                          
    owa_util.redirect_url ( t_url );
    
    apex_application.stop_apex_engine;
                        
  end redirect_oauth2;

begin
  
  g_provider.client_id      := s4sa_oauth_pck.get_setting('S4SA_FCB_CLIENT_ID');
  g_provider.client_secret  := s4sa_oauth_pck.get_setting('S4SA_FCB_CLIENT_SECRET');
  g_provider.redirect_uri   := s4sa_oauth_pck.get_setting('S4SA_FCB_REDIRECT_URL');
  g_provider.api_version    := s4sa_oauth_pck.get_setting('S4SA_FCB_API_VERSION');
  g_provider.extras         := s4sa_oauth_pck.get_setting('S4SA_FCB_EXTRAS');
  g_provider.scope          := s4sa_oauth_pck.get_setting('S4SA_FCB_SCOPE');
  g_provider.force_approval := s4sa_oauth_pck.get_setting('S4SA_FCB_FORCE_APPROVAL');
  
end s4sf_auth_pck;
/

CREATE OR REPLACE PACKAGE  "S4SA_OAUTH_PCK" is
/*                           __
                         _.-~  )
              _..--~~~~,'   ,-/     _    _____ __  __          _____ _______ 
           .-'. . . .'   ,-','    ,' ) / ____|  \/  |   /\   |  __ \__   __|
         ,'. . . _   ,--~,-'__..-'  ,'| (___ | \  / |  /  \  | |__) | | |
       ,'. . .  (@)' ---~~~~      ,'   \___ \| |\/| | / /\ \ |  _  /  | |
      /. . . . '~~             ,-'     ____) | |  | |/ ____ \| | \ \  | |
     /. . . . .             ,-'   _  _|_____/|_|  |_/_/ _  \_\_|_ \_\ |_|
    ; . . . .  - .        ,'     | || |           | |     | | (_)
   : . . . .       _     /       | || |_ ___  ___ | |_   _| |_ _  ___  _ __  ___
  . . . . .          `-.:        |__   _/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
 . . . ./  - .          )           | | \__ \ (_) | | |_| | |_| | (_) | | | \__ \
.  . . |  _____..---.._/            |_| |___/\___/|_|\__,_|\__|_|\___/|_| |_|___/
-~~----~~~~             ~---~~~~--~~~--~~~---~---~---~~~~----~~~~~---~~~--~~~---~~~---
--
--    NAME
--      s4sa_auth_pck
--
--    DESCRIPTION
--      This package contains generic procedures and functions for the social-logins
--      It for example exposes the function to login into the separate social providers:
--      - Google
--      - Facebook
--      - Linked-in
--      - Twitter
--      You need to set the globals according to your specific situation in their
--      specific util-packages
--
--    MODIFIED   (DD-MM-YYYY)
--    RICHARD MARTENS   18-5-2015  10:05 - Created
--    RICHARD MARTENS   31-08-2015 17:59 - Added revision global
--------------------------------------------------------------------------------
*/

gc_revision constant varchar2(100) := 'Revision: 0 (build: 0)';

type tp_settings is record
  ( grace_period           pls_integer             -- the number of seconds that the "time_left" can have before actually logging the user off
  , wallet_path            varchar2(1000)          -- the location of your Oracle Wallet
  , wallet_pwd             varchar2(1000)          -- the Oracle Wallet password
  , collection_name        apex_collections.collection_name%type -- the collection-name in which to store the users details
  , login_request_google   varchar2(10)            -- 'GGL_LOGIN'
  , login_request_facebook varchar2(10)            -- 'FCB_LOGIN';
  , login_request_linkedin varchar2(10)            -- 'LDI_LOGIN';
  , login_request_twitter  varchar2(10)            -- 'TWT_LOGIN';
  , api_prefix             varchar2(200)            -- 'https://' or 'http://revprox.local/ 
  );
g_settings tp_settings;

type tp_provider_settings is record
  ( api_key        varchar2(1000)
  , api_version    varchar2(1000)
  , client_id      varchar2(1000)
  , client_secret  varchar2(1000)
  , redirect_uri   varchar2(1000)
  , extras         varchar2(1000)
  , scope          varchar2(1000)
  , force_approval varchar2(1000)
   );

g_yesno_yes      constant char(1)        := 'Y';  -- used to populate booleans in types
g_yesno_no       constant char(1)        := 'N';  -- used to populate booleans in types
g_sexe_male      constant char(1)        := 'M';  -- used for male/female
g_sexe_female    constant char(1)        := 'F';  -- used for male/female

subtype uri_type      is varchar2(32767);
subtype response_type is clob;
subtype token_type    is varchar2(100);
subtype userid_type   is varchar2(255);

type oauth2_user is record(
  provider       varchar2(255)
, id             varchar2(255)
, email          varchar2(255)
, name           varchar2(255)
, given_name     varchar2(255)
, family_name    varchar2(255)
, picture        varchar2(255)
, gender         varchar2(255)
, link           varchar2(255)
, locale         varchar2(255)
, time_zone      number
, updated_time   timestamp with time zone
, verified       boolean
, hd             varchar2(255)
);

-- used for http-requests.
subtype method_type is varchar2(30);
g_http_method_post_form constant method_type := 'POST-FORM';
g_http_method_post_json constant method_type := 'POST-JSON';
g_http_method_post_mail constant method_type := 'POST_MAIL';
g_http_method_get       constant method_type := 'GET';
g_http_method_get_init  constant method_type := 'GET-INIT';
g_http_method_put       constant method_type := 'PUT';
g_http_method_put_json  constant method_type := 'PUT-JSON';
g_http_method_delete    constant method_type := 'DELETE';

e_parameter_check exception;
e_json_error      exception;

function g_collname$ return apex_collections.collection_name%type;
function oauth_email       ( p_provider in apex_collections.c001%type ) return varchar2;
function oauth_token       ( p_provider in apex_collections.c001%type ) return varchar2;
function oauth_user_pic    ( p_provider in apex_collections.c001%type ) return varchar2;
function oauth_user_name   ( p_provider in apex_collections.c001%type ) return varchar2;
function oauth_user_locale ( p_provider in apex_collections.c001%type ) return varchar2;
-- *****************************************************************
-- Description:       AUTH_SENTRY
--                    Sentry function to check is user is still loged in
--                    This function uses the S4SG_UTIL_PCK.G_GRACE_PERIOD constant
--                    to determine if we must set up a new session
-- Input Parameters:  - 
-- Output Parameters: - 
-- Error Conditions Raised: - 
-- Author:      Richard Martens
-- Created:     14-3-2015
-- Revision History
-- Date            Author       Reason for Change
-- ----------------------------------------------------------------
-- 14-3-2015     RICHARD MARTENS     Created.
-- *****************************************************************
function auth_sentry
  ( p_authentication in apex_plugin.t_authentication
  , p_plugin         in apex_plugin.t_plugin
  , p_is_public_page in boolean 
  ) return apex_plugin.t_authentication_sentry_result;

-- *****************************************************************
-- Description:       AUTHENTICATE
--                    Function that apex executes to start the login-process
--                    This function on its turn checks the type of request
--                    to see what provider-procedure must be started.
-- Input Parameters:  - 
-- Output Parameters: - 
-- Error Conditions Raised: - 
-- Author:      Richard Martens
-- Created:     18-5-2015
-- Revision History
-- Date            Author       Reason for Change
-- ----------------------------------------------------------------
-- 18-5-2015     RICHARD MARTENS     Created.
-- *****************************************************************
function authenticate (
    p_authentication in apex_plugin.t_authentication,
    p_plugin         in apex_plugin.t_plugin,
    p_password       in varchar2 )
    return apex_plugin.t_authentication_auth_result;
-- used to add an extra "login" to the current user
procedure authenticate
  ( p_request in varchar2 );
  
-- *****************************************************************
-- Description:       DO_OAUTH_LOGIN
--                    
-- Input Parameters:  - 
-- Output Parameters: - 
-- Error Conditions Raised: - 
-- Author:      Richard Martens
-- Created:     30-5-2015
-- Revision History
-- Date            Author       Reason for Change
-- ----------------------------------------------------------------
-- 14-3-2015     RICHARD MARTENS     Created.
-- *****************************************************************
procedure do_oauth_login
  ( p_provider     in varchar2 
  , p_session      in varchar2
  , p_workspaceid  in varchar2
  , p_appid        in varchar2
  , p_gotopage     in varchar2
  , p_code         in varchar2
  , p_access_token in varchar2
  , p_token_type   in varchar2
  , p_expires_in   in varchar2
  , p_id_token     in varchar2
  , p_error        in varchar2
  , p_oauth_user   in s4sa_oauth_pck.oauth2_user
  );

-- *****************************************************************
-- Description:       SORE_REQUEST
--                    
-- Input Parameters:  - 
-- Output Parameters: - 
-- Error Conditions Raised: - 
-- Author:      Richard Martens
-- Created:     14-3-2015
-- Revision History
-- Date            Author       Reason for Change
-- ----------------------------------------------------------------
-- 14-3-2015     RICHARD MARTENS     Created.
-- *****************************************************************
procedure store_request
  ( p_provider        in s4sa_requests.request_source%type
  , p_request_uri     in s4sa_requests.request_uri%type
  , p_request_type    in s4sa_requests.request_type%type
  , p_request_headers in s4sa_requests.request_headers%type
  , p_body            in s4sa_requests.request_body%type
  , p_response        in s4sa_requests.response%type
  );

/******************************************************************************/
function to_ts
  ( p_string in varchar2
  , p_format in varchar2 default null
  ) return timestamp;
  
/******************************************************************************/
function to_ts_tz
  ( p_string in varchar2
  , p_format in varchar2 default null
  ) return timestamp with time zone;
  
/******************************************************************************/
function boolconvert
  ( p_boolean in boolean
  ) return varchar2;
function boolconvert
  ( p_varchar in varchar2
  ) return varchar2;

/******************************************************************************/
function check_for_error
  ( p_json        in json
  , p_raise_error in boolean default true
  ) return boolean;

/******************************************************************************/
function check_for_error
  ( p_response    in clob
  , p_raise_error in boolean default true
  ) return boolean;

/******************************************************************************/
procedure check_for_error
  ( p_json        in json
  );
procedure check_for_error
  ( p_response     in clob
  , p_null_err_msg in varchar2 default 'No response received where expected.'
  );  
  
function trim
  ( p_haystack in varchar2
  , p_needle   in varchar2
  ) return varchar2;
  
function addslashes
  ( p_string in clob 
  ) return clob;

function addslashes
  ( p_string in varchar2
  ) return varchar2;
  
function get_setting
  ( p_code in s4sa_settings.code%type
  ) return s4sa_settings.meaning%type deterministic;
  
procedure present_error
  ( p_workspaceid in number
  , p_appid       in number
  , p_gotopage    in varchar2
  , p_session     in varchar2
  , p_errormsg    in varchar2
  );
  
function replace_newline
  ( p_value in varchar2
  ) return varchar2;

end s4sa_oauth_pck;
/
CREATE OR REPLACE PACKAGE BODY  "S4SA_OAUTH_PCK" as

cursor c_oauth_user(p_provider in apex_collections.c001%type)
  is   select c.c001   as provider
       ,      c.c002   as session_id
       ,      c.c003   as gotopage
       ,      c.c004   as code
       ,      c.c005   as access_token
       ,      c.c006   as token_type
       ,      c.c007   as id_token
       ,      c.c008   as error
       ,      c.c009   as provider_id
       ,      c.c010   as email
       ,      c.c011   as verified
       ,      c.c012   as user_name
       ,      c.c013   as given_name
       ,      c.c014   as family_name
       ,      c.c015   as link
       ,      c.c016   as picture
       ,      c.c017   as gender
       ,      c.c018   as locale
       ,      c.c019   as hd
       ,      c.c020   as user_session_id
       ,      c.n001   as expires_in
       ,      c.d001   as logindate
       from   apex_collections c
       where  c.collection_name = g_settings.collection_name
         and  c.c001            = p_provider;
r_oauth_user c_oauth_user%rowtype;
         
function oauth_email
  ( p_provider in apex_collections.c001%type
  ) return varchar2
is
begin
  open c_oauth_user(p_provider);
  fetch c_oauth_user into r_oauth_user;
  close c_oauth_user;
  return r_oauth_user.email;
end oauth_email;
         
function oauth_token
  ( p_provider in apex_collections.c001%type
  ) return varchar2
is
begin
  open c_oauth_user(p_provider);
  fetch c_oauth_user into r_oauth_user;
  close c_oauth_user;
  return r_oauth_user.access_token;
end oauth_token;
         
function oauth_user_pic
  ( p_provider in apex_collections.c001%type
  ) return varchar2
is
begin
  open c_oauth_user(p_provider);
  fetch c_oauth_user into r_oauth_user;
  close c_oauth_user;
  return r_oauth_user.picture;
end oauth_user_pic;
         
function oauth_user_name
  ( p_provider in apex_collections.c001%type
  ) return varchar2
is
begin
  open c_oauth_user(p_provider);
  fetch c_oauth_user into r_oauth_user;
  close c_oauth_user;
  return r_oauth_user.user_name;
end oauth_user_name;
         
function oauth_user_locale
  ( p_provider in apex_collections.c001%type
  ) return varchar2
is
begin
  open c_oauth_user(p_provider);
  fetch c_oauth_user into r_oauth_user;
  close c_oauth_user;
  return r_oauth_user.locale;
end oauth_user_locale;
  

function g_collname$ return apex_collections.collection_name%type is begin return g_settings.collection_name; end;

/*****************************************************************************
  AUTH_SENTRY
  description   : sentry function for the authentication plugin
                  is executed before every page.
                  checks if google session is still valid
  change history:
  date          name         remarks
  februari 2015 R.Martens    Initial version
*****************************************************************************/
function auth_sentry
  ( p_authentication in apex_plugin.t_authentication
  , p_plugin         in apex_plugin.t_plugin
  , p_is_public_page in boolean 
  ) return apex_plugin.t_authentication_sentry_result
is
  t_retval         apex_plugin.t_authentication_sentry_result;
  t_seconds_left   number;
  cursor c_oauth_user
  is     select c.n001 - ((sysdate - c.d001) * 24 * 60 * 60) as seconds_left
         from   apex_collections c
         where  c.collection_name = g_settings.collection_name;
begin
    
  open c_oauth_user;
  fetch c_oauth_user into t_seconds_left;
  close c_oauth_user;
    
  t_retval.is_valid := t_seconds_left > g_settings.grace_period;
    
  -- we could greatly improve usability when we can get a new token from google instead of just returning false here.
  if not t_retval.is_valid then
    -- get a new token
    null;
  end if;
    
  return t_retval;
    
end auth_sentry;

/*****************************************************************************
  AUTHENTICATE
  description   : 
  change history:
  date          name         remarks
  18-5-2015     R.Martens    Initial version
*****************************************************************************/
function authenticate
  ( p_authentication in apex_plugin.t_authentication
  , p_plugin         in apex_plugin.t_plugin
  , p_password       in varchar2
  ) return apex_plugin.t_authentication_auth_result
is
  t_retval  apex_plugin.t_authentication_auth_result;
  t_request varchar2(255) := v('REQUEST');
begin
  
  case t_request
    when g_settings.login_request_google then
      s4sg_auth_pck.authenticate;
    when g_settings.login_request_facebook then
      s4sf_auth_pck.authenticate;
    when g_settings.login_request_linkedin then
      s4sl_auth_pck.authenticate;
    else
      return null;
  end case;
  
  t_retval.is_authenticated := true;
  return t_retval;

  return null;
end;

-- used to add an extra "login" to the current user
procedure authenticate
  ( p_request in varchar2 
  )
is
begin
  case p_request
    when g_settings.login_request_google then
      s4sg_auth_pck.authenticate;
    when g_settings.login_request_facebook then
      s4sf_auth_pck.authenticate;
    when g_settings.login_request_linkedin then
      s4sl_auth_pck.authenticate;
    else
      null;
  end case;
  
end authenticate;
    
procedure do_oauth_login
  ( p_provider     in varchar2 
  , p_session      in varchar2
  , p_workspaceid  in varchar2
  , p_appid        in varchar2
  , p_gotopage     in varchar2
  , p_code         in varchar2
  , p_access_token in varchar2
  , p_token_type   in varchar2
  , p_expires_in   in varchar2
  , p_id_token     in varchar2
  , p_error        in varchar2
  , p_oauth_user   in s4sa_oauth_pck.oauth2_user
  )
is
  t_coll_seq_id   apex_collections.seq_id%type;
  t_reccount      pls_integer;
  l_username      varchar2(100) := p_provider || ':' || p_oauth_user.id || ':' || p_oauth_user.email;
  l_goto          varchar2(100) := 'f?p=' || p_appid    || ':' || p_gotopage      || ':' || p_session;
  cursor c_coll_member_id
  is         select c.seq_id
             --into   t_coll_seq_id
             from   apex_collections c
             where  c.collection_name = g_settings.collection_name
               and  c.c001            = p_provider;
begin
    
  wwv_flow_api.set_security_group_id(p_workspaceid);
  apex_application.g_flow_id  := p_appid;
      
  apex_custom_auth.set_session_id(p_session_id => p_session);
  apex_custom_auth.define_user_session(p_oauth_user.id, p_session);
      
  if apex_collection.collection_exists(p_collection_name => g_settings.collection_name) then
    open c_coll_member_id;
    fetch c_coll_member_id into t_coll_seq_id;
    close c_coll_member_id;
        
  else
    apex_collection.create_or_truncate_collection(g_settings.collection_name);
    t_coll_seq_id := null;
    
  end if;
  
  if t_coll_seq_id is null then
    apex_collection.add_member(
        p_collection_name => g_settings.collection_name
      , p_c001            => p_provider
      , p_c002            => apex_custom_auth.get_session_id
      , p_c003            => p_gotopage
      , p_c004            => p_code
      , p_c005            => p_access_token
      , p_c006            => p_token_type
      , p_c007            => p_id_token
      , p_c008            => p_error
      , p_c009            => p_oauth_user.id
      , p_c010            => p_oauth_user.email
      , p_c011            => case when p_oauth_user.verified then 'TRUE' else 'FALSE' end
      , p_c012            => p_oauth_user.name
      , p_c013            => p_oauth_user.given_name
      , p_c014            => p_oauth_user.family_name
      , p_c015            => p_oauth_user.link
      , p_c016            => p_oauth_user.picture
      , p_c017            => p_oauth_user.gender
      , p_c018            => p_oauth_user.locale
      , p_c019            => p_oauth_user.hd
      , p_c020            => p_session
      , p_n001            => p_expires_in
      , p_d001            => sysdate
      );
  else
    apex_collection.update_member(
        p_collection_name => g_settings.collection_name
      , p_seq             => t_coll_seq_id
      , p_c001            => p_provider
      , p_c002            => apex_custom_auth.get_session_id
      , p_c003            => p_gotopage
      , p_c004            => p_code
      , p_c005            => p_access_token
      , p_c006            => p_token_type
      , p_c007            => p_id_token
      , p_c008            => p_error
      , p_c009            => p_oauth_user.id
      , p_c010            => p_oauth_user.email
      , p_c011            => case when p_oauth_user.verified then 'TRUE' else 'FALSE' end
      , p_c012            => p_oauth_user.name
      , p_c013            => p_oauth_user.given_name
      , p_c014            => p_oauth_user.family_name
      , p_c015            => p_oauth_user.link
      , p_c016            => p_oauth_user.picture
      , p_c017            => p_oauth_user.gender
      , p_c018            => p_oauth_user.locale
      , p_c019            => p_oauth_user.hd
      , p_c020            => p_session
      , p_n001            => p_expires_in
      , p_d001            => sysdate
      );
  end if;
  
  select count(*)
  into   t_reccount
  from   apex_collections c
  where  c.collection_name = g_settings.collection_name;
  
  if t_reccount = 1 then
    
    apex_custom_auth.login
      ( p_uname         => l_username
      , p_password      => p_access_token
      , p_session_id    => p_session
      , p_app_page      => p_appid || ':' || p_gotopage
      );
      
    apex_authentication.send_login_username_cookie
      ( p_username    => l_username
      , p_cookie_name => 'ORA_WWV_APP_' || p_appid );
  
  else
    
    owa_util.redirect_url(curl => l_goto);
    
  end if;
  
  apex_util.set_authentication_result( p_code => 0 );
  
end do_oauth_login;

/******************************************************************************/
procedure store_request
  ( p_provider        in s4sa_requests.request_source%type
  , p_request_uri     in s4sa_requests.request_uri%type
  , p_request_type    in s4sa_requests.request_type%type
  , p_request_headers in s4sa_requests.request_headers%type
  , p_body            in s4sa_requests.request_body%type
  , p_response        in s4sa_requests.response%type)
  is
    pragma autonomous_transaction;
  begin
    insert into s4sa_requests
        (request_source, request_uri, request_type, request_headers, request_body, response)
      values
        (p_provider, p_request_uri, p_request_type, p_request_headers, p_body, p_response);
    commit;
  end store_request;
  
/******************************************************************************/
function to_ts
  ( p_string in varchar2
  , p_format in varchar2 default null
  ) return timestamp
  is
    t_format   varchar2(30) := nvl(p_format, 'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"');
  begin
    return to_timestamp(p_string, t_format);
  end to_ts;

/******************************************************************************/
function to_ts_tz
    ( p_string in varchar2
    , p_format in varchar2 default null
    ) return timestamp with time zone
  is
    t_format   varchar2(30) := nvl(p_format, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM');
  begin
    return to_timestamp_tz(p_string, t_format);
  end to_ts_tz;
  
/******************************************************************************/
function boolconvert
  ( p_boolean in boolean
  ) return varchar2
  is
  begin
    return case when p_boolean then 'Y' else 'N' end;
  end boolconvert;
  
  function boolconvert
    ( p_varchar in varchar2
    ) return varchar2
  is
  begin
    return case when p_varchar = 'Y' then 'true' else 'false' end;
  end boolconvert;
  
/******************************************************************************/
function check_for_error
  ( p_json        in json
  , p_raise_error in boolean default true
  ) return boolean
  is
    t_error          varchar2(32767);
    t_error_code     number;
  begin
    
    --if p_json.to_char(spaces => false, chars_per_line => 100) = 'Not Found' then
    --  t_error      := 'Not Found';
    --  t_error_code := 0;
    --else
      t_error      := json_ext.get_string(p_json, 'error.message');
      t_error_code := json_ext.get_number(p_json, 'error.code');
    --end if;
      
    if t_error is null then
      t_error_code := json_ext.get_number(p_json, 'errorCode');
      if t_error_code is not null then
        t_error  := json_ext.get_string(p_json, 'message');
      end if;
    end if;
    
    case
      when t_error is null then
        return true;
      when p_raise_error   then
        raise_application_error(-20000 - t_error_code, t_error);
      else
        return false;
    end case;
    
  end check_for_error;
  
/******************************************************************************/
function check_for_error
  ( p_response    in clob
  , p_raise_error in boolean default true
  ) return boolean
  is
  begin
    if nullif (length (p_response), 0) is not null then
      return check_for_error( p_json        => json(p_response)
                            , p_raise_error => p_raise_error);
    else
      return true;
    end if;
  end;
  
  procedure check_for_error
    ( p_json        in json
    )
  is
  begin
    
    if check_for_error(p_json => p_json, p_raise_error => true)
    then
      null;
    end if;
    
  end check_for_error;
  
/******************************************************************************/
procedure check_for_error
  ( p_response     in clob
  , p_null_err_msg in varchar2 default 'No response received where expected.'
  )
  is
  begin
    if nullif (length (p_response), 0) is not null then
      if check_for_error(p_json => json(p_response), p_raise_error => true) then
        null;
      end if;
    elsif p_null_err_msg is not null then
      raise_application_error(-20000, p_null_err_msg);
    end if;
  end check_for_error;
  
  function object_to_xml
    ( p_object anytype
    , p_root_element varchar2
    ) return xmltype
  is
    l_retval xmltype;
  begin
    select sys_xmlgen(p_object,xmlformat(p_root_element)) into l_retval from dual;
    return l_retval;
  end object_to_xml;

/******************************************************************************/
function is_plsqldev
  return boolean
  is
  begin
    return sys_context('USERENV', 'MODULE')='PL/SQL Developer';
  end;

function trim
  ( p_haystack in varchar2
  , p_needle   in varchar2
  ) return varchar2
is
  t_retval varchar(32767) := p_haystack;
begin
  for ii in 1..length(p_needle) loop
    t_retval := trim(substr(p_needle, ii, 1) from t_retval);
  end loop;
  return t_retval;
end trim;

function addslashes
  ( p_string in clob 
  ) return clob
is
  l_retval clob := p_string;
begin
  l_retval := replace(l_retval, '\', '\\');
  l_retval := replace(l_retval, '"', '\"');
  l_retval := replace(l_retval, '''', '\''');
  return l_retval;
end addslashes;

function addslashes
  ( p_string in varchar2
  ) return varchar2
is
begin
  return substr(addslashes(to_clob(p_string)), 1, 32767);
end addslashes;

function get_setting
  ( p_code in s4sa_settings.code%type
  ) return s4sa_settings.meaning%type deterministic
is
  cursor c_setting
  is select s.meaning
     from   s4sa_settings s
     where  s.code = p_code;
  l_retval s4sa_settings.meaning%type;
begin
  open c_setting;
  fetch c_setting into l_retval;
  close c_setting;
  return l_retval;
end get_setting;

procedure present_error
  ( p_workspaceid in number
  , p_appid       in number
  , p_gotopage    in varchar2
  , p_session     in varchar2
  , p_errormsg    in varchar2
  )
is
  t_error varchar2(32767);
  t_uri   varchar2(32767);
begin
  
  wwv_flow_api.set_security_group_id(p_workspaceid);
  apex_application.g_flow_id  := p_appid;
  apex_custom_auth.set_session_id(p_session_id => p_session);
  apex_custom_auth.define_user_session(null, p_session);
        
  t_error := p_errormsg;
  --t_error := 'test error';
        
  t_uri := '/ords/f?p=#APPID#:#PAGEID#:#SESSION#::::::';
  t_uri := replace(t_uri, '#APPID#'  , p_appid);
  t_uri := replace(t_uri, '#PAGEID#' , p_gotopage);
  t_uri := replace(t_uri, '#SESSION#', p_session);
  t_uri := t_uri || '&notification_msg=' || t_error || '/';
  t_uri := apex_util.prepare_url(t_uri);
  apex_application.g_print_success_message := t_error;
  owa_util.redirect_url(curl => t_uri);
end present_error;

function replace_newline
  ( p_value in varchar2
  ) return varchar2
is
  l_js_newline varchar2(2) := '\n';
begin
  return replace( replace( replace( replace( p_value
                                           , chr(10)||chr(13), l_js_newline)
                                  , chr(13) || chr(10), l_js_newline)
                         , chr(10), l_js_newline)
                , chr(13), l_js_newline);
end replace_newline;

begin
  -- initialise the settings table
  g_settings.grace_period           := get_setting('S4SA_GRACE_PERIOD');
  g_settings.wallet_path            := get_setting('S4SA_WALLET_PATH');
  g_settings.wallet_pwd             := get_setting('S4SA_WALLET_PWD');
  g_settings.collection_name        := get_setting('S4SA_COLLECTION_NAME');
  g_settings.login_request_google   := get_setting('S4SA_GGL_LOGIN_REQUEST');
  g_settings.login_request_facebook := get_setting('S4SA_FCB_LOGIN_REQUEST');
  g_settings.login_request_linkedin := get_setting('S4SA_LDI_LOGIN_REQUEST');
  g_settings.login_request_twitter  := get_setting('S4SA_TWT_LOGIN_REQUEST');
  g_settings.api_prefix             := get_setting('S4SA_API_PREFIX');
  
end s4sa_oauth_pck;
/

CREATE OR REPLACE PACKAGE  "JSON_PRINTER" as
  /*
  Copyright (c) 2010 Jonas Krogsboell

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  */
  indent_string varchar2(10 char) := '  '; --chr(9); for tab
  newline_char varchar2(2 char)   := chr(13)||chr(10); -- Windows style
  --newline_char varchar2(2) := chr(10); -- Mac style
  --newline_char varchar2(2) := chr(13); -- Linux style
  ascii_output boolean    not null := true;
  escape_solidus boolean  not null := false;

  function pretty_print(obj json, spaces boolean default true, line_length number default 0) return varchar2;
  function pretty_print_list(obj json_list, spaces boolean default true, line_length number default 0) return varchar2;
  function pretty_print_any(json_part json_value, spaces boolean default true, line_length number default 0) return varchar2;
  procedure pretty_print(obj json, spaces boolean default true, buf in out nocopy clob, line_length number default 0, erase_clob boolean default true);
  procedure pretty_print_list(obj json_list, spaces boolean default true, buf in out nocopy clob, line_length number default 0, erase_clob boolean default true);
  procedure pretty_print_any(json_part json_value, spaces boolean default true, buf in out nocopy clob, line_length number default 0, erase_clob boolean default true);

  procedure dbms_output_clob(my_clob clob, delim varchar2, jsonp varchar2 default null);
  procedure htp_output_clob(my_clob clob, jsonp varchar2 default null);
  -- made public just for testing/profiling...
  function escapeString(str varchar2) return varchar2;

end json_printer;
/
CREATE OR REPLACE PACKAGE BODY  "JSON_PRINTER" as
  max_line_len number := 0;
  cur_line_len number := 0;


  -- associative array used inside escapeString to cache the escaped version of every character
  -- escaped so far  (example: char_map('"') contains the  '\"' string)
  -- (if the character does not need to be escaped, the character is stored unchanged in the array itself)
  type Tmap_char_string is table of varchar2(40) index by varchar2(1);
       char_map Tmap_char_string;
       -- since char_map the associative array is a global variable reused across multiple calls to escapeString,
       -- i need to be able to detect that the escape_solidus or ascii_output global parameters have been changed,
       -- in order to clear it and avoid using escape sequences that have been cached using the previous values
       char_map_escape_solidus boolean := escape_solidus;
       char_map_ascii_output boolean := ascii_output;


  function llcheck(str in varchar2) return varchar2 as
  begin
    --dbms_output.put_line(cur_line_len || ' : '|| str);
    if(max_line_len > 0 and length(str)+cur_line_len > max_line_len) then
      cur_line_len := length(str);
      return newline_char || str;
    else
      cur_line_len := cur_line_len + length(str);
      return str;
    end if;
  end llcheck;

  -- escapes a single character.
  function escapeChar(ch char) return varchar2 deterministic is
     result varchar2(20);
  begin
      --backspace b = U+0008
      --formfeed  f = U+000C
      --newline   n = U+000A
      --carret    r = U+000D
      --tabulator t = U+0009
      result := ch;

      case ch
      when chr( 8) then result := '\b';
      when chr( 9) then result := '\t';
      when chr(10) then result := '\n';
      when chr(12) then result := '\f';
      when chr(13) then result := '\r';
      when chr(34) then result := '\"';
      when chr(47) then if(escape_solidus) then result := '\/'; end if;
      when chr(92) then result := '\\';
      else if(ascii(ch) < 32) then
             result :=  '\u'||replace(substr(to_char(ascii(ch), 'XXXX'),2,4), ' ', '0');
        elsif (ascii_output) then
             result := replace(asciistr(ch), '\', '\u');
        end if;
      end case;
      return result;
  end;



  function escapeString(str varchar2) return varchar2 as
    sb varchar2(32000) := '';
    buf varchar2(40);
    ch char(1);
  begin
    if(str is null) then return ''; end if;

    -- clear the cache if global parameters have been changed
    if char_map_escape_solidus <> escape_solidus or
       char_map_ascii_output   <> ascii_output
    then
       char_map.delete;
       char_map_escape_solidus := escape_solidus;
       char_map_ascii_output := ascii_output;
    end if;

    for i in 1 .. length(str) loop
      ch := substr(str, i, 1 ) ;

      begin
         -- it this char has already been processed, I have cached its escaped value
         buf := char_map(ch);
      exception when no_Data_found then
         -- otherwise, i convert the value and add it to the cache
         buf := escapeChar(ch);
         char_map(ch) := buf;
      end;

      sb := sb || buf;
    end loop;
    return sb;
  end escapeString;

  function newline(spaces boolean) return varchar2 as
  begin
    cur_line_len := 0;
    if(spaces) then return newline_char; else return ''; end if;
  end;

/*  function get_schema return varchar2 as
  begin
    return sys_context('userenv', 'current_schema');
  end;
*/
  function tab(indent number, spaces boolean) return varchar2 as
    i varchar(200) := '';
  begin
    if(not spaces) then return ''; end if;
    for x in 1 .. indent loop i := i || indent_string; end loop;
    return i;
  end;

  function getCommaSep(spaces boolean) return varchar2 as
  begin
    if(spaces) then return ', '; else return ','; end if;
  end;

  function getMemName(mem json_value, spaces boolean) return varchar2 as
  begin
    if(spaces) then
      return llcheck('"'||escapeString(mem.mapname)||'"') || llcheck(' : ');
    else
      return llcheck('"'||escapeString(mem.mapname)||'"') || llcheck(':');
    end if;
  end;

/* Clob method start here */
  procedure add_to_clob(buf_lob in out nocopy clob, buf_str in out nocopy varchar2, str varchar2) as
  begin
    if(lengthb(str) > 32767 - lengthb(buf_str)) then
--      dbms_lob.append(buf_lob, buf_str);
      dbms_lob.writeappend(buf_lob, length(buf_str), buf_str);
      buf_str := str;
    else
      buf_str := buf_str || str;
    end if;
  end add_to_clob;

  procedure flush_clob(buf_lob in out nocopy clob, buf_str in out nocopy varchar2) as
  begin
--    dbms_lob.append(buf_lob, buf_str);
    dbms_lob.writeappend(buf_lob, length(buf_str), buf_str);
  end flush_clob;

  procedure ppObj(obj json, indent number, buf in out nocopy clob, spaces boolean, buf_str in out nocopy varchar2);

  procedure ppEA(input json_list, indent number, buf in out nocopy clob, spaces boolean, buf_str in out nocopy varchar2) as
    elem json_value;
    arr json_value_array := input.list_data;
    numbuf varchar2(4000);
  begin
    for y in 1 .. arr.count loop
      elem := arr(y);
      if(elem is not null) then
      case elem.get_type
        when 'number' then
          numbuf := '';
          if (elem.get_number < 1 and elem.get_number > 0) then numbuf := '0'; end if;
          if (elem.get_number < 0 and elem.get_number > -1) then
            numbuf := '-0';
            numbuf := numbuf || substr(to_char(elem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''),2);
          else
            numbuf := numbuf || to_char(elem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
          end if;
          add_to_clob(buf, buf_str, llcheck(numbuf));
        when 'string' then
          if(elem.extended_str is not null) then --clob implementation
            add_to_clob(buf, buf_str, case when elem.num = 1 then '"' else '/**/' end);
            declare
              offset number := 1;
              v_str varchar(32767);
              amount number := 32767;
            begin
              while(offset <= dbms_lob.getlength(elem.extended_str)) loop
                dbms_lob.read(elem.extended_str, amount, offset, v_str);
                if(elem.num = 1) then
                  add_to_clob(buf, buf_str, escapeString(v_str));
                else
                  add_to_clob(buf, buf_str, v_str);
                end if;
                offset := offset + amount;
              end loop;
            end;
            add_to_clob(buf, buf_str, case when elem.num = 1 then '"' else '/**/' end || newline_char);
          else
            if(elem.num = 1) then
              add_to_clob(buf, buf_str, llcheck('"'||escapeString(elem.get_string)||'"'));
            else
              add_to_clob(buf, buf_str, llcheck('/**/'||elem.get_string||'/**/'));
            end if;
          end if;
        when 'bool' then
          if(elem.get_bool) then
            add_to_clob(buf, buf_str, llcheck('true'));
          else
            add_to_clob(buf, buf_str, llcheck('false'));
          end if;
        when 'null' then
          add_to_clob(buf, buf_str, llcheck('null'));
        when 'array' then
          add_to_clob(buf, buf_str, llcheck('['));
          ppEA(json_list(elem), indent, buf, spaces, buf_str);
          add_to_clob(buf, buf_str, llcheck(']'));
        when 'object' then
          ppObj(json(elem), indent, buf, spaces, buf_str);
        else add_to_clob(buf, buf_str, llcheck(elem.get_type));
      end case;
      end if;
      if(y != arr.count) then add_to_clob(buf, buf_str, llcheck(getCommaSep(spaces))); end if;
    end loop;
  end ppEA;

  procedure ppMem(mem json_value, indent number, buf in out nocopy clob, spaces boolean, buf_str in out nocopy varchar2) as
    numbuf varchar2(4000);
  begin
    add_to_clob(buf, buf_str, llcheck(tab(indent, spaces)) || llcheck(getMemName(mem, spaces)));
    case mem.get_type
      when 'number' then
        if (mem.get_number < 1 and mem.get_number > 0) then numbuf := '0'; end if;
        if (mem.get_number < 0 and mem.get_number > -1) then
          numbuf := '-0';
          numbuf := numbuf || substr(to_char(mem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''),2);
        else
          numbuf := numbuf || to_char(mem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
        end if;
        add_to_clob(buf, buf_str, llcheck(numbuf));
      when 'string' then
        if(mem.extended_str is not null) then --clob implementation
          add_to_clob(buf, buf_str, case when mem.num = 1 then '"' else '/**/' end);
          declare
            offset number := 1;
            v_str varchar(32767);
            amount number := 32767;
          begin
--            dbms_output.put_line('SIZE:'||dbms_lob.getlength(mem.extended_str));
            while(offset <= dbms_lob.getlength(mem.extended_str)) loop
--            dbms_output.put_line('OFFSET:'||offset);
 --             v_str := dbms_lob.substr(mem.extended_str, 8192, offset);
              dbms_lob.read(mem.extended_str, amount, offset, v_str);
--            dbms_output.put_line('VSTR_SIZE:'||length(v_str));
              if(mem.num = 1) then
                add_to_clob(buf, buf_str, escapeString(v_str));
              else
                add_to_clob(buf, buf_str, v_str);
              end if;
              offset := offset + amount;
            end loop;
          end;
          add_to_clob(buf, buf_str, case when mem.num = 1 then '"' else '/**/' end || newline_char);
        else
          if(mem.num = 1) then
            add_to_clob(buf, buf_str, llcheck('"'||escapeString(mem.get_string)||'"'));
          else
            add_to_clob(buf, buf_str, llcheck('/**/'||mem.get_string||'/**/'));
          end if;
        end if;
      when 'bool' then
        if(mem.get_bool) then
          add_to_clob(buf, buf_str, llcheck('true'));
        else
          add_to_clob(buf, buf_str, llcheck('false'));
        end if;
      when 'null' then
        add_to_clob(buf, buf_str, llcheck('null'));
      when 'array' then
        add_to_clob(buf, buf_str, llcheck('['));
        ppEA(json_list(mem), indent, buf, spaces, buf_str);
        add_to_clob(buf, buf_str, llcheck(']'));
      when 'object' then
        ppObj(json(mem), indent, buf, spaces, buf_str);
      else add_to_clob(buf, buf_str, llcheck(mem.get_type));
    end case;
  end ppMem;

  procedure ppObj(obj json, indent number, buf in out nocopy clob, spaces boolean, buf_str in out nocopy varchar2) as
  begin
    add_to_clob(buf, buf_str, llcheck('{') || newline(spaces));
    for m in 1 .. obj.json_data.count loop
      ppMem(obj.json_data(m), indent+1, buf, spaces, buf_str);
      if(m != obj.json_data.count) then
        add_to_clob(buf, buf_str, llcheck(',') || newline(spaces));
      else
        add_to_clob(buf, buf_str, newline(spaces));
      end if;
    end loop;
    add_to_clob(buf, buf_str, llcheck(tab(indent, spaces)) || llcheck('}')); -- || chr(13);
  end ppObj;

  procedure pretty_print(obj json, spaces boolean default true, buf in out nocopy clob, line_length number default 0, erase_clob boolean default true) as
    buf_str varchar2(32767);
    amount number := dbms_lob.getlength(buf);
  begin
    if(erase_clob and amount > 0) then dbms_lob.trim(buf, 0); dbms_lob.erase(buf, amount); end if;

    max_line_len := line_length;
    cur_line_len := 0;
    ppObj(obj, 0, buf, spaces, buf_str);
    flush_clob(buf, buf_str);
  end;

  procedure pretty_print_list(obj json_list, spaces boolean default true, buf in out nocopy clob, line_length number default 0, erase_clob boolean default true) as
    buf_str varchar2(32767);
    amount number := dbms_lob.getlength(buf);
  begin
    if(erase_clob and amount > 0) then dbms_lob.trim(buf, 0); dbms_lob.erase(buf, amount); end if;

    max_line_len := line_length;
    cur_line_len := 0;
    add_to_clob(buf, buf_str, llcheck('['));
    ppEA(obj, 0, buf, spaces, buf_str);
    add_to_clob(buf, buf_str, llcheck(']'));
    flush_clob(buf, buf_str);
  end;

  procedure pretty_print_any(json_part json_value, spaces boolean default true, buf in out nocopy clob, line_length number default 0, erase_clob boolean default true) as
    buf_str varchar2(32767) := '';
    numbuf varchar2(4000);
    amount number := dbms_lob.getlength(buf);
  begin
    if(erase_clob and amount > 0) then dbms_lob.trim(buf, 0); dbms_lob.erase(buf, amount); end if;

    case json_part.get_type
      when 'number' then
        if (json_part.get_number < 1 and json_part.get_number > 0) then numbuf := '0'; end if;
        if (json_part.get_number < 0 and json_part.get_number > -1) then
          numbuf := '-0';
          numbuf := numbuf || substr(to_char(json_part.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''),2);
        else
          numbuf := numbuf || to_char(json_part.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
        end if;
        add_to_clob(buf, buf_str, numbuf);
      when 'string' then
        if(json_part.extended_str is not null) then --clob implementation
          add_to_clob(buf, buf_str, case when json_part.num = 1 then '"' else '/**/' end);
          declare
            offset number := 1;
            v_str varchar(32767);
            amount number := 32767;
          begin
            while(offset <= dbms_lob.getlength(json_part.extended_str)) loop
              dbms_lob.read(json_part.extended_str, amount, offset, v_str);
              if(json_part.num = 1) then
                add_to_clob(buf, buf_str, escapeString(v_str));
              else
                add_to_clob(buf, buf_str, v_str);
              end if;
              offset := offset + amount;
            end loop;
          end;
          add_to_clob(buf, buf_str, case when json_part.num = 1 then '"' else '/**/' end);
        else
          if(json_part.num = 1) then
            add_to_clob(buf, buf_str, llcheck('"'||escapeString(json_part.get_string)||'"'));
          else
            add_to_clob(buf, buf_str, llcheck('/**/'||json_part.get_string||'/**/'));
          end if;
        end if;
      when 'bool' then
	      if(json_part.get_bool) then
          add_to_clob(buf, buf_str, 'true');
        else
          add_to_clob(buf, buf_str, 'false');
        end if;
      when 'null' then
        add_to_clob(buf, buf_str, 'null');
      when 'array' then
        pretty_print_list(json_list(json_part), spaces, buf, line_length);
        return;
      when 'object' then
        pretty_print(json(json_part), spaces, buf, line_length);
        return;
      else add_to_clob(buf, buf_str, 'unknown type:'|| json_part.get_type);
    end case;
    flush_clob(buf, buf_str);
  end;

/* Clob method end here */

/* Varchar2 method start here */

  procedure ppObj(obj json, indent number, buf in out nocopy varchar2, spaces boolean);

  procedure ppEA(input json_list, indent number, buf in out varchar2, spaces boolean) as
    elem json_value;
    arr json_value_array := input.list_data;
    str varchar2(400);
  begin
    for y in 1 .. arr.count loop
      elem := arr(y);
      if(elem is not null) then
      case elem.get_type
        when 'number' then
          str := '';
          if (elem.get_number < 1 and elem.get_number > 0) then str := '0'; end if;
          if (elem.get_number < 0 and elem.get_number > -1) then
            str := '-0' || substr(to_char(elem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''),2);
          else
            str := str || to_char(elem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
          end if;
          buf := buf || llcheck(str);
        when 'string' then
          if(elem.num = 1) then
            buf := buf || llcheck('"'||escapeString(elem.get_string)||'"');
          else
            buf := buf || llcheck('/**/'||elem.get_string||'/**/');
          end if;
        when 'bool' then
          if(elem.get_bool) then
            buf := buf || llcheck('true');
          else
            buf := buf || llcheck('false');
          end if;
        when 'null' then
          buf := buf || llcheck('null');
        when 'array' then
          buf := buf || llcheck('[');
          ppEA(json_list(elem), indent, buf, spaces);
          buf := buf || llcheck(']');
        when 'object' then
          ppObj(json(elem), indent, buf, spaces);
        else buf := buf || llcheck(elem.get_type); /* should never happen */
      end case;
      end if;
      if(y != arr.count) then buf := buf || llcheck(getCommaSep(spaces)); end if;
    end loop;
  end ppEA;

  procedure ppMem(mem json_value, indent number, buf in out nocopy varchar2, spaces boolean) as
    str varchar2(400) := '';
  begin
    buf := buf || llcheck(tab(indent, spaces)) || getMemName(mem, spaces);
    case mem.get_type
      when 'number' then
        if (mem.get_number < 1 and mem.get_number > 0) then str := '0'; end if;
        if (mem.get_number < 0 and mem.get_number > -1) then
          str := '-0' || substr(to_char(mem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''),2);
        else
          str := str || to_char(mem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
        end if;
        buf := buf || llcheck(str);
      when 'string' then
        if(mem.num = 1) then
          buf := buf || llcheck('"'||escapeString(mem.get_string)||'"');
        else
          buf := buf || llcheck('/**/'||mem.get_string||'/**/');
        end if;
      when 'bool' then
        if(mem.get_bool) then
          buf := buf || llcheck('true');
        else
          buf := buf || llcheck('false');
        end if;
      when 'null' then
        buf := buf || llcheck('null');
      when 'array' then
        buf := buf || llcheck('[');
        ppEA(json_list(mem), indent, buf, spaces);
        buf := buf || llcheck(']');
      when 'object' then
        ppObj(json(mem), indent, buf, spaces);
      else buf := buf || llcheck(mem.get_type); /* should never happen */
    end case;
  end ppMem;

  procedure ppObj(obj json, indent number, buf in out nocopy varchar2, spaces boolean) as
  begin
    buf := buf || llcheck('{') || newline(spaces);
    for m in 1 .. obj.json_data.count loop
      ppMem(obj.json_data(m), indent+1, buf, spaces);
      if(m != obj.json_data.count) then buf := buf || llcheck(',') || newline(spaces);
      else buf := buf || newline(spaces); end if;
    end loop;
    buf := buf || llcheck(tab(indent, spaces)) || llcheck('}'); -- || chr(13);
  end ppObj;

  function pretty_print(obj json, spaces boolean default true, line_length number default 0) return varchar2 as
    buf varchar2(32767) := '';
  begin
    max_line_len := line_length;
    cur_line_len := 0;
    ppObj(obj, 0, buf, spaces);
    return buf;
  end pretty_print;

  function pretty_print_list(obj json_list, spaces boolean default true, line_length number default 0) return varchar2 as
    buf varchar2(32767);
  begin
    max_line_len := line_length;
    cur_line_len := 0;
    buf := llcheck('[');
    ppEA(obj, 0, buf, spaces);
    buf := buf || llcheck(']');
    return buf;
  end;

  function pretty_print_any(json_part json_value, spaces boolean default true, line_length number default 0) return varchar2 as
    buf varchar2(32767) := '';
  begin
    case json_part.get_type
      when 'number' then
        if (json_part.get_number() < 1 and json_part.get_number() > 0) then buf := buf || '0'; end if;
        if (json_part.get_number() < 0 and json_part.get_number() > -1) then
          buf := buf || '-0';
          buf := buf || substr(to_char(json_part.get_number(), 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''),2);
        else
          buf := buf || to_char(json_part.get_number(), 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
        end if;
      when 'string' then
        if(json_part.num = 1) then
          buf := buf || '"'||escapeString(json_part.get_string)||'"';
        else
          buf := buf || '/**/'||json_part.get_string||'/**/';
        end if;
      when 'bool' then
      	if(json_part.get_bool) then buf := 'true'; else buf := 'false'; end if;
      when 'null' then
        buf := 'null';
      when 'array' then
        buf := pretty_print_list(json_list(json_part), spaces, line_length);
      when 'object' then
        buf := pretty_print(json(json_part), spaces, line_length);
      else buf := 'weird error: '|| json_part.get_type;
    end case;
    return buf;
  end;

  procedure dbms_output_clob(my_clob clob, delim varchar2, jsonp varchar2 default null) as
    prev number := 1;
    indx number := 1;
    size_of_nl number := lengthb(delim);
    v_str varchar2(32767);
    amount number := 32767;
  begin
    if(jsonp is not null) then dbms_output.put_line(jsonp||'('); end if;
    while(indx != 0) loop
      --read every line
      indx := dbms_lob.instr(my_clob, delim, prev+1);
 --     dbms_output.put_line(prev || ' to ' || indx);

      if(indx = 0) then
        --emit from prev to end;
        amount := 32767;
 --       dbms_output.put_line(' mycloblen ' || dbms_lob.getlength(my_clob));
        loop
          dbms_lob.read(my_clob, amount, prev, v_str);
          dbms_output.put_line(v_str);
          prev := prev+amount-1;
          exit when prev >= dbms_lob.getlength(my_clob);
        end loop;
      else
        amount := indx - prev;
        if(amount > 32767) then
          amount := 32767;
--          dbms_output.put_line(' mycloblen ' || dbms_lob.getlength(my_clob));
          loop
            dbms_lob.read(my_clob, amount, prev, v_str);
            dbms_output.put_line(v_str);
            prev := prev+amount-1;
            amount := indx - prev;
            exit when prev >= indx - 1;
            if(amount > 32767) then amount := 32767; end if;
          end loop;
          prev := indx + size_of_nl;
        else
          dbms_lob.read(my_clob, amount, prev, v_str);
          dbms_output.put_line(v_str);
          prev := indx + size_of_nl;
        end if;
      end if;

    end loop;
    if(jsonp is not null) then dbms_output.put_line(')'); end if;

/*    while (amount != 0) loop
      indx := dbms_lob.instr(my_clob, delim, prev+1);

--      dbms_output.put_line(prev || ' to ' || indx);
      if(indx = 0) then
        indx := dbms_lob.getlength(my_clob)+1;
      end if;

      if(indx-prev > 32767) then
        indx := prev+32767;
      end if;
--      dbms_output.put_line(prev || ' to ' || indx);
      --substr doesnt work properly on all platforms! (come on oracle - error on Oracle VM for virtualbox)
--        dbms_output.put_line(dbms_lob.substr(my_clob, indx-prev, prev));
      amount := indx-prev;
--        dbms_output.put_line('amount'||amount);
      dbms_lob.read(my_clob, amount, prev, v_str);
      dbms_output.put_line(v_str);
      prev := indx+size_of_nl;
      if(amount = 32767) then prev := prev-size_of_nl-1; end if;
    end loop;
    if(jsonp is not null) then dbms_output.put_line(')'); end if;*/
  end;


/*  procedure dbms_output_clob(my_clob clob, delim varchar2, jsonp varchar2 default null) as
    prev number := 1;
    indx number := 1;
    size_of_nl number := lengthb(delim);
    v_str varchar2(32767);
    amount number;
  begin
    if(jsonp is not null) then dbms_output.put_line(jsonp||'('); end if;
    while (indx != 0) loop
      indx := dbms_lob.instr(my_clob, delim, prev+1);

--      dbms_output.put_line(prev || ' to ' || indx);
      if(indx-prev > 32767) then
        indx := prev+32767;
      end if;
--      dbms_output.put_line(prev || ' to ' || indx);
      --substr doesnt work properly on all platforms! (come on oracle - error on Oracle VM for virtualbox)
      if(indx = 0) then
--        dbms_output.put_line(dbms_lob.substr(my_clob, dbms_lob.getlength(my_clob)-prev+size_of_nl, prev));
        amount := dbms_lob.getlength(my_clob)-prev+size_of_nl;
        dbms_lob.read(my_clob, amount, prev, v_str);
      else
--        dbms_output.put_line(dbms_lob.substr(my_clob, indx-prev, prev));
        amount := indx-prev;
--        dbms_output.put_line('amount'||amount);
        dbms_lob.read(my_clob, amount, prev, v_str);
      end if;
      dbms_output.put_line(v_str);
      prev := indx+size_of_nl;
      if(amount = 32767) then prev := prev-size_of_nl-1; end if;
    end loop;
    if(jsonp is not null) then dbms_output.put_line(')'); end if;
  end;
*/
  procedure htp_output_clob(my_clob clob, jsonp varchar2 default null) as
    /*amount number := 4096;
    pos number := 1;
    len number;
    */
    l_amt    number default 30;
    l_off   number default 1;
    l_str   varchar2(4096);

  begin
    if(jsonp is not null) then htp.prn(jsonp||'('); end if;

    begin
      loop
        dbms_lob.read( my_clob, l_amt, l_off, l_str );

        -- it is vital to use htp.PRN to avoid
        -- spurious line feeds getting added to your
        -- document
        htp.prn( l_str  );
        l_off := l_off+l_amt;
        l_amt := 4096;
      end loop;
    exception
      when no_data_found then NULL;
    end;

    /*
    len := dbms_lob.getlength(my_clob);

    while(pos < len) loop
      htp.prn(dbms_lob.substr(my_clob, amount, pos)); -- should I replace substr with dbms_lob.read?
      --dbms_output.put_line(dbms_lob.substr(my_clob, amount, pos));
      pos := pos + amount;
    end loop;
    */
    if(jsonp is not null) then htp.prn(')'); end if;
  end;

end json_printer;
/

CREATE OR REPLACE PACKAGE  "JSON_PARSER" as
  /*
  Copyright (c) 2010 Jonas Krogsboell

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  */
  /* scanner tokens:
    '{', '}', ',', ':', '[', ']', STRING, NUMBER, TRUE, FALSE, NULL
  */
  type rToken IS RECORD (
    type_name VARCHAR2(7),
    line PLS_INTEGER,
    col PLS_INTEGER,
    data VARCHAR2(32767),
    data_overflow clob); -- max_string_size

  type lTokens is table of rToken index by pls_integer;
  type json_src is record (len number, offset number, src varchar2(32767), s_clob clob);

  json_strict boolean not null := false;

  function next_char(indx number, s in out nocopy json_src) return varchar2;
  function next_char2(indx number, s in out nocopy json_src, amount number default 1) return varchar2;

  function prepareClob(buf in clob) return json_parser.json_src;
  function prepareVarchar2(buf in varchar2) return json_parser.json_src;
  function lexer(jsrc in out nocopy json_src) return lTokens;
  procedure print_token(t rToken);

  function parser(str varchar2) return json;
  function parse_list(str varchar2) return json_list;
  function parse_any(str varchar2) return json_value;
  function parser(str clob) return json;
  function parse_list(str clob) return json_list;
  function parse_any(str clob) return json_value;
  procedure remove_duplicates(obj in out nocopy json);
  function get_version return varchar2;

end json_parser;
/
CREATE OR REPLACE PACKAGE BODY  "JSON_PARSER" as
  /*
  Copyright (c) 2009 Jonas Krogsboell

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  */

  decimalpoint varchar2(1 char) := '.';

  procedure updateDecimalPoint as
  begin
    SELECT substr(VALUE,1,1) into decimalpoint FROM NLS_SESSION_PARAMETERS WHERE PARAMETER = 'NLS_NUMERIC_CHARACTERS';
  end updateDecimalPoint;

  /*type json_src is record (len number, offset number, src varchar2(10), s_clob clob); */
  function next_char(indx number, s in out nocopy json_src) return varchar2 as
  begin
    if(indx > s.len) then return null; end if;
    --right offset?
    if(indx > 4000 + s.offset or indx < s.offset) then
    --load right offset
      s.offset := indx - (indx mod 4000);
      s.src := dbms_lob.substr(s.s_clob, 4000, s.offset+1);
    end if;
    --read from s.src
    return substr(s.src, indx-s.offset, 1);
  end;

  function next_char2(indx number, s in out nocopy json_src, amount number default 1) return varchar2 as
    buf varchar2(32767) := '';
  begin
    for i in 1..amount loop
      buf := buf || next_char(indx-1+i,s);
    end loop;
    return buf;
  end;

  function prepareClob(buf clob) return json_parser.json_src as
    temp json_parser.json_src;
  begin
    temp.s_clob := buf;
    temp.offset := 0;
    temp.src := dbms_lob.substr(buf, 4000, temp.offset+1);
    temp.len := dbms_lob.getlength(buf);
    return temp;
  end;

  function prepareVarchar2(buf varchar2) return json_parser.json_src as
    temp json_parser.json_src;
  begin
    temp.s_clob := buf;
    temp.offset := 0;
    temp.src := substr(buf, 1, 4000);
    temp.len := length(buf);
    return temp;
  end;

  procedure debug(text varchar2) as
  begin
    dbms_output.put_line(text);
  end;

  procedure print_token(t rToken) as
  begin
    dbms_output.put_line('Line: '||t.line||' - Column: '||t.col||' - Type: '||t.type_name||' - Content: '||t.data);
  end print_token;

  /* SCANNER FUNCTIONS START */
  procedure s_error(text varchar2, line number, col number) as
  begin
    raise_application_error(-20100, 'JSON Scanner exception @ line: '||line||' column: '||col||' - '||text);
  end;

  procedure s_error(text varchar2, tok rToken) as
  begin
    raise_application_error(-20100, 'JSON Scanner exception @ line: '||tok.line||' column: '||tok.col||' - '||text);
  end;

  function mt(t varchar2, l pls_integer, c pls_integer, d varchar2) return rToken as
    token rToken;
  begin
    token.type_name := t;
    token.line := l;
    token.col := c;
    token.data := d;
    return token;
  end;

  function lexNumber(jsrc in out nocopy json_src, tok in out nocopy rToken, indx in out nocopy pls_integer) return pls_integer as
    numbuf varchar2(4000) := '';
    buf varchar2(4);
    checkLoop boolean;
  begin
    buf := next_char(indx, jsrc);
    if(buf = '-') then numbuf := '-'; indx := indx + 1; end if;
    buf := next_char(indx, jsrc);
    --0 or [1-9]([0-9])*
    if(buf = '0') then
      numbuf := numbuf || '0'; indx := indx + 1;
      buf := next_char(indx, jsrc);
    elsif(buf >= '1' and buf <= '9') then
      numbuf := numbuf || buf; indx := indx + 1;
      --read digits
      buf := next_char(indx, jsrc);
      while(buf >= '0' and buf <= '9') loop
        numbuf := numbuf || buf; indx := indx + 1;
        buf := next_char(indx, jsrc);
      end loop;
    end if;
    --fraction
    if(buf = '.') then
      numbuf := numbuf || buf; indx := indx + 1;
      buf := next_char(indx, jsrc);
      checkLoop := FALSE;
      while(buf >= '0' and buf <= '9') loop
        checkLoop := TRUE;
        numbuf := numbuf || buf; indx := indx + 1;
        buf := next_char(indx, jsrc);
      end loop;
      if(not checkLoop) then
        s_error('Expected: digits in fraction', tok);
      end if;
    end if;
    --exp part
    if(buf in ('e', 'E')) then
      numbuf := numbuf || buf; indx := indx + 1;
      buf := next_char(indx, jsrc);
      if(buf = '+' or buf = '-') then
        numbuf := numbuf || buf; indx := indx + 1;
        buf := next_char(indx, jsrc);
      end if;
      checkLoop := FALSE;
      while(buf >= '0' and buf <= '9') loop
        checkLoop := TRUE;
        numbuf := numbuf || buf; indx := indx + 1;
        buf := next_char(indx, jsrc);
      end loop;
      if(not checkLoop) then
        s_error('Expected: digits in exp', tok);
      end if;
    end if;

    tok.data := numbuf;
    return indx;
  end lexNumber;

  -- [a-zA-Z]([a-zA-Z0-9])*
  function lexName(jsrc in out nocopy json_src, tok in out nocopy rToken, indx in out nocopy pls_integer) return pls_integer as
    varbuf varchar2(32767) := '';
    buf varchar(4);
    num number;
  begin
    buf := next_char(indx, jsrc);
    while(REGEXP_LIKE(buf, '^[[:alnum:]\_]$', 'i')) loop
      varbuf := varbuf || buf;
      indx := indx + 1;
      buf := next_char(indx, jsrc);
      if (buf is null) then
        goto retname;
        --debug('Premature string ending');
      end if;
    end loop;
    <<retname>>

    --could check for reserved keywords here

    --debug(varbuf);
    tok.data := varbuf;
    return indx-1;
  end lexName;

  procedure updateClob(v_extended in out nocopy clob, v_str varchar2) as
  begin
    dbms_lob.writeappend(v_extended, length(v_str), v_str);
  end updateClob;

  function lexString(jsrc in out nocopy json_src, tok in out nocopy rToken, indx in out nocopy pls_integer, endChar char) return pls_integer as
    v_extended clob := null; v_count number := 0;
    varbuf varchar2(32767) := '';
    buf varchar(4);
    wrong boolean;
  begin
    indx := indx +1;
    buf := next_char(indx, jsrc);
    while(buf != endChar) loop
      --clob control
      if(v_count > 8191) then --crazy oracle error (16383 is the highest working length with unistr - 8192 choosen to be safe)
        if(v_extended is null) then
          v_extended := empty_clob();
          dbms_lob.createtemporary(v_extended, true);
        end if;
        updateClob(v_extended, unistr(varbuf));
        varbuf := ''; v_count := 0;
      end if;
      if(buf = Chr(13) or buf = CHR(9) or buf = CHR(10)) then
        s_error('Control characters not allowed (CHR(9),CHR(10)CHR(13))', tok);
      end if;
      if(buf = '\') then
        --varbuf := varbuf || buf;
        indx := indx + 1;
        buf := next_char(indx, jsrc);
        case
          when buf in ('\') then
            varbuf := varbuf || buf || buf; v_count := v_count + 2;
            indx := indx + 1;
            buf := next_char(indx, jsrc);
          when buf in ('"', '/') then
            varbuf := varbuf || buf; v_count := v_count + 1;
            indx := indx + 1;
            buf := next_char(indx, jsrc);
          when buf = '''' then
            if(json_strict = false) then
              varbuf := varbuf || buf; v_count := v_count + 1;
              indx := indx + 1;
              buf := next_char(indx, jsrc);
            else
              s_error('strictmode - expected: " \ / b f n r t u ', tok);
            end if;
          when buf in ('b', 'f', 'n', 'r', 't') then
            --backspace b = U+0008
            --formfeed  f = U+000C
            --newline   n = U+000A
            --carret    r = U+000D
            --tabulator t = U+0009
            case buf
            when 'b' then varbuf := varbuf || chr(8);
            when 'f' then varbuf := varbuf || chr(12);
            when 'n' then varbuf := varbuf || chr(10);
            when 'r' then varbuf := varbuf || chr(13);
            when 't' then varbuf := varbuf || chr(9);
            end case;
            --varbuf := varbuf || buf;
            v_count := v_count + 1;
            indx := indx + 1;
            buf := next_char(indx, jsrc);
          when buf = 'u' then
            --four hexidecimal chars
            declare
              four varchar2(4);
            begin
              four := next_char2(indx+1, jsrc, 4);
              wrong := FALSE;
              if(upper(substr(four, 1,1)) not in ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','a','b','c','d','e','f')) then wrong := TRUE; end if;
              if(upper(substr(four, 2,1)) not in ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','a','b','c','d','e','f')) then wrong := TRUE; end if;
              if(upper(substr(four, 3,1)) not in ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','a','b','c','d','e','f')) then wrong := TRUE; end if;
              if(upper(substr(four, 4,1)) not in ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','a','b','c','d','e','f')) then wrong := TRUE; end if;
              if(wrong) then
                s_error('expected: " \u([0-9][A-F]){4}', tok);
              end if;
--              varbuf := varbuf || buf || four;
              varbuf := varbuf || '\'||four;--chr(to_number(four,'XXXX'));
               v_count := v_count + 5;
              indx := indx + 5;
              buf := next_char(indx, jsrc);
              end;
          else
            s_error('expected: " \ / b f n r t u ', tok);
        end case;
      else
        varbuf := varbuf || buf; v_count := v_count + 1;
        indx := indx + 1;
        buf := next_char(indx, jsrc);
      end if;
    end loop;

    if (buf is null) then
      s_error('string ending not found', tok);
      --debug('Premature string ending');
    end if;

    --debug(varbuf);
    --dbms_output.put_line(varbuf);
    if(v_extended is not null) then
      updateClob(v_extended, unistr(varbuf));
      tok.data_overflow := v_extended;
      tok.data := dbms_lob.substr(v_extended, 1, 32767);
    else
      tok.data := unistr(varbuf);
    end if;
    return indx;
  end lexString;

  /* scanner tokens:
    '{', '}', ',', ':', '[', ']', STRING, NUMBER, TRUE, FALSE, NULL
  */
  function lexer(jsrc in out nocopy json_src) return lTokens as
    tokens lTokens;
    indx pls_integer := 1;
    tok_indx pls_integer := 1;
    buf varchar2(4);
    lin_no number := 1;
    col_no number := 0;
  begin
    while (indx <= jsrc.len) loop
      --read into buf
      buf := next_char(indx, jsrc);
      col_no := col_no + 1;
      --convert to switch case
      case
        when buf = '{' then tokens(tok_indx) := mt('{', lin_no, col_no, null); tok_indx := tok_indx + 1;
        when buf = '}' then tokens(tok_indx) := mt('}', lin_no, col_no, null); tok_indx := tok_indx + 1;
        when buf = ',' then tokens(tok_indx) := mt(',', lin_no, col_no, null); tok_indx := tok_indx + 1;
        when buf = ':' then tokens(tok_indx) := mt(':', lin_no, col_no, null); tok_indx := tok_indx + 1;
        when buf = '[' then tokens(tok_indx) := mt('[', lin_no, col_no, null); tok_indx := tok_indx + 1;
        when buf = ']' then tokens(tok_indx) := mt(']', lin_no, col_no, null); tok_indx := tok_indx + 1;
        when buf = 't' then
          if(next_char2(indx, jsrc, 4) != 'true') then
            if(json_strict = false and REGEXP_LIKE(buf, '^[[:alpha:]]$', 'i')) then
              tokens(tok_indx) := mt('STRING', lin_no, col_no, null);
              indx := lexName(jsrc, tokens(tok_indx), indx);
              col_no := col_no + length(tokens(tok_indx).data) + 1;
              tok_indx := tok_indx + 1;
            else
              s_error('Expected: ''true''', lin_no, col_no);
            end if;
          else
            tokens(tok_indx) := mt('TRUE', lin_no, col_no, null); tok_indx := tok_indx + 1;
            indx := indx + 3;
            col_no := col_no + 3;
          end if;
        when buf = 'n' then
          if(next_char2(indx, jsrc, 4) != 'null') then
            if(json_strict = false and REGEXP_LIKE(buf, '^[[:alpha:]]$', 'i')) then
              tokens(tok_indx) := mt('STRING', lin_no, col_no, null);
              indx := lexName(jsrc, tokens(tok_indx), indx);
              col_no := col_no + length(tokens(tok_indx).data) + 1;
              tok_indx := tok_indx + 1;
            else
              s_error('Expected: ''null''', lin_no, col_no);
            end if;
          else
            tokens(tok_indx) := mt('NULL', lin_no, col_no, null); tok_indx := tok_indx + 1;
            indx := indx + 3;
            col_no := col_no + 3;
          end if;
        when buf = 'f' then
          if(next_char2(indx, jsrc, 5) != 'false') then
            if(json_strict = false and REGEXP_LIKE(buf, '^[[:alpha:]]$', 'i')) then
              tokens(tok_indx) := mt('STRING', lin_no, col_no, null);
              indx := lexName(jsrc, tokens(tok_indx), indx);
              col_no := col_no + length(tokens(tok_indx).data) + 1;
              tok_indx := tok_indx + 1;
            else
              s_error('Expected: ''false''', lin_no, col_no);
            end if;
          else
            tokens(tok_indx) := mt('FALSE', lin_no, col_no, null); tok_indx := tok_indx + 1;
            indx := indx + 4;
            col_no := col_no + 4;
          end if;
        /*   -- 9 = TAB, 10 = \n, 13 = \r (Linux = \n, Windows = \r\n, Mac = \r */
        when (buf = Chr(10)) then --linux newlines
          lin_no := lin_no + 1;
          col_no := 0;

        when (buf = Chr(13)) then --Windows or Mac way
          lin_no := lin_no + 1;
          col_no := 0;
          if(jsrc.len >= indx +1) then -- better safe than sorry
            buf := next_char(indx+1, jsrc);
            if(buf = Chr(10)) then --\r\n
              indx := indx + 1;
            end if;
          end if;

        when (buf = CHR(9)) then null; --tabbing
        when (buf in ('-', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')) then --number
          tokens(tok_indx) := mt('NUMBER', lin_no, col_no, null);
          indx := lexNumber(jsrc, tokens(tok_indx), indx)-1;
          col_no := col_no + length(tokens(tok_indx).data);
          tok_indx := tok_indx + 1;
        when buf = '"' then --number
          tokens(tok_indx) := mt('STRING', lin_no, col_no, null);
          indx := lexString(jsrc, tokens(tok_indx), indx, '"');
          col_no := col_no + length(tokens(tok_indx).data) + 1;
          tok_indx := tok_indx + 1;
        when buf = '''' and json_strict = false then --number
          tokens(tok_indx) := mt('STRING', lin_no, col_no, null);
          indx := lexString(jsrc, tokens(tok_indx), indx, '''');
          col_no := col_no + length(tokens(tok_indx).data) + 1; --hovsa her
          tok_indx := tok_indx + 1;
        when json_strict = false and REGEXP_LIKE(buf, '^[[:alpha:]]$', 'i') then
          tokens(tok_indx) := mt('STRING', lin_no, col_no, null);
          indx := lexName(jsrc, tokens(tok_indx), indx);
          if(tokens(tok_indx).data_overflow is not null) then
            col_no := col_no + dbms_lob.getlength(tokens(tok_indx).data_overflow) + 1;
          else
            col_no := col_no + length(tokens(tok_indx).data) + 1;
          end if;
          tok_indx := tok_indx + 1;
        when json_strict = false and buf||next_char(indx+1, jsrc) = '/*' then --strip comments
          declare
            saveindx number := indx;
            un_esc clob;
          begin
            indx := indx + 1;
            loop
              indx := indx + 1;
              buf := next_char(indx, jsrc)||next_char(indx+1, jsrc);
              exit when buf = '*/';
              exit when buf is null;
            end loop;

            if(indx = saveindx+2) then
              --enter unescaped mode
              --dbms_output.put_line('Entering unescaped mode');
              un_esc := empty_clob();
              dbms_lob.createtemporary(un_esc, true);
              indx := indx + 1;
              loop
                indx := indx + 1;
                buf := next_char(indx, jsrc)||next_char(indx+1, jsrc)||next_char(indx+2, jsrc)||next_char(indx+3, jsrc);
                exit when buf = '/**/';
                if buf is null then
                  s_error('Unexpected sequence /**/ to end unescaped data: '||buf, lin_no, col_no);
                end if;
                buf := next_char(indx, jsrc);
                dbms_lob.writeappend(un_esc, length(buf), buf);
              end loop;
              tokens(tok_indx) := mt('ESTRING', lin_no, col_no, null);
              tokens(tok_indx).data_overflow := un_esc;
              col_no := col_no + dbms_lob.getlength(un_esc) + 1; --note: line count won't work properly
              tok_indx := tok_indx + 1;
              indx := indx + 2;
            end if;

            indx := indx + 1;
          end;
        when buf = ' ' then null; --space
        else
          s_error('Unexpected char: '||buf, lin_no, col_no);
      end case;

      indx := indx + 1;
    end loop;

    return tokens;
  end lexer;

  /* SCANNER END */

  /* PARSER FUNCTIONS START*/
  procedure p_error(text varchar2, tok rToken) as
  begin
    raise_application_error(-20101, 'JSON Parser exception @ line: '||tok.line||' column: '||tok.col||' - '||text);
  end;

  function parseObj(tokens lTokens, indx in out nocopy pls_integer) return json;

  function parseArr(tokens lTokens, indx in out nocopy pls_integer) return json_list as
    e_arr json_value_array := json_value_array();
    ret_list json_list := json_list();
    v_count number := 0;
    tok rToken;
  begin
    --value, value, value ]
    if(indx > tokens.count) then p_error('more elements in array was excepted', tok); end if;
    tok := tokens(indx);
    while(tok.type_name != ']') loop
      e_arr.extend;
      v_count := v_count + 1;
      case tok.type_name
        when 'TRUE' then e_arr(v_count) := json_value(true);
        when 'FALSE' then e_arr(v_count) := json_value(false);
        when 'NULL' then e_arr(v_count) := json_value;
        when 'STRING' then e_arr(v_count) := case when tok.data_overflow is not null then json_value(tok.data_overflow) else json_value(tok.data) end;
        when 'ESTRING' then e_arr(v_count) := json_value(tok.data_overflow, false);
        when 'NUMBER' then e_arr(v_count) := json_value(to_number(replace(tok.data, '.', decimalpoint)));
        when '[' then
          declare e_list json_list; begin
            indx := indx + 1;
            e_list := parseArr(tokens, indx);
            e_arr(v_count) := e_list.to_json_value;
          end;
        when '{' then
          indx := indx + 1;
          e_arr(v_count) := parseObj(tokens, indx).to_json_value;
        else
          p_error('Expected a value', tok);
      end case;
      indx := indx + 1;
      if(indx > tokens.count) then p_error('] not found', tok); end if;
      tok := tokens(indx);
      if(tok.type_name = ',') then --advance
        indx := indx + 1;
        if(indx > tokens.count) then p_error('more elements in array was excepted', tok); end if;
        tok := tokens(indx);
        if(tok.type_name = ']') then --premature exit
          p_error('Premature exit in array', tok);
        end if;
      elsif(tok.type_name != ']') then --error
        p_error('Expected , or ]', tok);
      end if;

    end loop;
    ret_list.list_data := e_arr;
    return ret_list;
  end parseArr;

  function parseMem(tokens lTokens, indx in out pls_integer, mem_name varchar2, mem_indx number) return json_value as
    mem json_value;
    tok rToken;
  begin
    tok := tokens(indx);
    case tok.type_name
      when 'TRUE' then mem := json_value(true);
      when 'FALSE' then mem := json_value(false);
      when 'NULL' then mem := json_value;
      when 'STRING' then mem := case when tok.data_overflow is not null then json_value(tok.data_overflow) else json_value(tok.data) end;
      when 'ESTRING' then mem := json_value(tok.data_overflow, false);
      when 'NUMBER' then mem := json_value(to_number(replace(tok.data, '.', decimalpoint)));
      when '[' then
        declare
          e_list json_list;
        begin
          indx := indx + 1;
          e_list := parseArr(tokens, indx);
          mem := e_list.to_json_value;
        end;
      when '{' then
        indx := indx + 1;
        mem := parseObj(tokens, indx).to_json_value;
      else
        p_error('Found '||tok.type_name, tok);
    end case;
    mem.mapname := mem_name;
    mem.mapindx := mem_indx;

    indx := indx + 1;
    return mem;
  end parseMem;

  /*procedure test_duplicate_members(arr in json_member_array, mem_name in varchar2, wheretok rToken) as
  begin
    for i in 1 .. arr.count loop
      if(arr(i).member_name = mem_name) then
        p_error('Duplicate member name', wheretok);
      end if;
    end loop;
  end test_duplicate_members;*/

  function parseObj(tokens lTokens, indx in out nocopy pls_integer) return json as
    type memmap is table of number index by varchar2(4000); -- i've read somewhere that this is not possible - but it is!
    mymap memmap;
    nullelemfound boolean := false;

    obj json;
    tok rToken;
    mem_name varchar(4000);
    arr json_value_array := json_value_array();
  begin
    --what to expect?
    while(indx <= tokens.count) loop
      tok := tokens(indx);
      --debug('E: '||tok.type_name);
      case tok.type_name
      when 'STRING' then
        --member
        mem_name := substr(tok.data, 1, 4000);
        begin
          if(mem_name is null) then
            if(nullelemfound) then
              p_error('Duplicate empty member: ', tok);
            else
              nullelemfound := true;
            end if;
          elsif(mymap(mem_name) is not null) then
            p_error('Duplicate member name: '||mem_name, tok);
          end if;
        exception
          when no_data_found then mymap(mem_name) := 1;
        end;

        indx := indx + 1;
        if(indx > tokens.count) then p_error('Unexpected end of input', tok); end if;
        tok := tokens(indx);
        indx := indx + 1;
        if(indx > tokens.count) then p_error('Unexpected end of input', tok); end if;
        if(tok.type_name = ':') then
          --parse
          declare
            jmb json_value;
            x number;
          begin
            x := arr.count + 1;
            jmb := parseMem(tokens, indx, mem_name, x);
            arr.extend;
            arr(x) := jmb;
          end;
        else
          p_error('Expected '':''', tok);
        end if;
        --move indx forward if ',' is found
        if(indx > tokens.count) then p_error('Unexpected end of input', tok); end if;

        tok := tokens(indx);
        if(tok.type_name = ',') then
          --debug('found ,');
          indx := indx + 1;
          tok := tokens(indx);
          if(tok.type_name = '}') then --premature exit
            p_error('Premature exit in json object', tok);
          end if;
        elsif(tok.type_name != '}') then
           p_error('A comma seperator is probably missing', tok);
        end if;
      when '}' then
        obj := json();
        obj.json_data := arr;
        return obj;
      else
        p_error('Expected string or }', tok);
      end case;
    end loop;

    p_error('} not found', tokens(indx-1));

    return obj;

  end;

  function parser(str varchar2) return json as
    tokens lTokens;
    obj json;
    indx pls_integer := 1;
    jsrc json_src;
  begin
    updateDecimalPoint();
    jsrc := prepareVarchar2(str);
    tokens := lexer(jsrc);
    if(tokens(indx).type_name = '{') then
      indx := indx + 1;
      obj := parseObj(tokens, indx);
    else
      raise_application_error(-20101, 'JSON Parser exception - no { start found');
    end if;
    if(tokens.count != indx) then
      p_error('} should end the JSON object', tokens(indx));
    end if;

    return obj;
  end parser;

  function parse_list(str varchar2) return json_list as
    tokens lTokens;
    obj json_list;
    indx pls_integer := 1;
    jsrc json_src;
  begin
    updateDecimalPoint();
    jsrc := prepareVarchar2(str);
    tokens := lexer(jsrc);
    if(tokens(indx).type_name = '[') then
      indx := indx + 1;
      obj := parseArr(tokens, indx);
    else
      raise_application_error(-20101, 'JSON List Parser exception - no [ start found');
    end if;
    if(tokens.count != indx) then
      p_error('] should end the JSON List object', tokens(indx));
    end if;

    return obj;
  end parse_list;

  function parse_list(str clob) return json_list as
    tokens lTokens;
    obj json_list;
    indx pls_integer := 1;
    jsrc json_src;
  begin
    updateDecimalPoint();
    jsrc := prepareClob(str);
    tokens := lexer(jsrc);
    if(tokens(indx).type_name = '[') then
      indx := indx + 1;
      obj := parseArr(tokens, indx);
    else
      raise_application_error(-20101, 'JSON List Parser exception - no [ start found');
    end if;
    if(tokens.count != indx) then
      p_error('] should end the JSON List object', tokens(indx));
    end if;

    return obj;
  end parse_list;

  function parser(str clob) return json as
    tokens lTokens;
    obj json;
    indx pls_integer := 1;
    jsrc json_src;
  begin
    updateDecimalPoint();
    --dbms_output.put_line('Using clob');
    jsrc := prepareClob(str);
    tokens := lexer(jsrc);
    if(tokens(indx).type_name = '{') then
      indx := indx + 1;
      obj := parseObj(tokens, indx);
    else
      raise_application_error(-20101, 'JSON Parser exception - no { start found');
    end if;
    if(tokens.count != indx) then
      p_error('} should end the JSON object', tokens(indx));
    end if;

    return obj;
  end parser;

  function parse_any(str varchar2) return json_value as
    tokens lTokens;
    obj json_list;
    ret json_value;
    indx pls_integer := 1;
    jsrc json_src;
  begin
    updateDecimalPoint();
    jsrc := prepareVarchar2(str);
    tokens := lexer(jsrc);
    tokens(tokens.count+1).type_name := ']';
    obj := parseArr(tokens, indx);
    if(tokens.count != indx) then
      p_error('] should end the JSON List object', tokens(indx));
    end if;

    return obj.head();
  end parse_any;

  function parse_any(str clob) return json_value as
    tokens lTokens;
    obj json_list;
    indx pls_integer := 1;
    jsrc json_src;
  begin
    jsrc := prepareClob(str);
    tokens := lexer(jsrc);
    tokens(tokens.count+1).type_name := ']';
    obj := parseArr(tokens, indx);
    if(tokens.count != indx) then
      p_error('] should end the JSON List object', tokens(indx));
    end if;

    return obj.head();
  end parse_any;

  /* last entry is the one to keep */
  procedure remove_duplicates(obj in out nocopy json) as
    type memberlist is table of json_value index by varchar2(4000);
    members memberlist;
    nulljsonvalue json_value := null;
    validated json := json();
    indx varchar2(4000);
  begin
    for i in 1 .. obj.count loop
      if(obj.get(i).mapname is null) then
        nulljsonvalue := obj.get(i);
      else
        members(obj.get(i).mapname) := obj.get(i);
      end if;
    end loop;

    validated.check_duplicate(false);
    indx := members.first;
    loop
      exit when indx is null;
      validated.put(indx, members(indx));
      indx := members.next(indx);
    end loop;
    if(nulljsonvalue is not null) then
      validated.put('', nulljsonvalue);
    end if;

    validated.check_for_duplicate := obj.check_for_duplicate;

    obj := validated;
  end;

  function get_version return varchar2 as
  begin
    return 'PL/JSON v1.0.4';
  end get_version;

end json_parser;
/

CREATE OR REPLACE PACKAGE  "JSON_EXT" as
  /*
  Copyright (c) 2009 Jonas Krogsboell

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  */

  /* This package contains extra methods to lookup types and
     an easy way of adding date values in json - without changing the structure */
  function parsePath(json_path varchar2, base number default 1) return json_list;

  --JSON Path getters
  function get_json_value(obj json, v_path varchar2, base number default 1) return json_value;
  function get_string(obj json, path varchar2,       base number default 1) return varchar2;
  function get_number(obj json, path varchar2,       base number default 1) return number;
  function get_json(obj json, path varchar2,         base number default 1) return json;
  function get_json_list(obj json, path varchar2,    base number default 1) return json_list;
  function get_bool(obj json, path varchar2,         base number default 1) return boolean;

  --JSON Path putters
  procedure put(obj in out nocopy json, path varchar2, elem varchar2,   base number default 1);
  procedure put(obj in out nocopy json, path varchar2, elem number,     base number default 1);
  procedure put(obj in out nocopy json, path varchar2, elem json,       base number default 1);
  procedure put(obj in out nocopy json, path varchar2, elem json_list,  base number default 1);
  procedure put(obj in out nocopy json, path varchar2, elem boolean,    base number default 1);
  procedure put(obj in out nocopy json, path varchar2, elem json_value, base number default 1);

  procedure remove(obj in out nocopy json, path varchar2, base number default 1);

  --Pretty print with JSON Path - obsolete in 0.9.4 - obj.path(v_path).(to_char,print,htp)
  function pp(obj json, v_path varchar2) return varchar2;
  procedure pp(obj json, v_path varchar2); --using dbms_output.put_line
  procedure pp_htp(obj json, v_path varchar2); --using htp.print

  --extra function checks if number has no fraction
  function is_integer(v json_value) return boolean;

  format_string varchar2(30 char) := 'yyyy-mm-dd hh24:mi:ss';
  --extension enables json to store dates without comprimising the implementation
  function to_json_value(d date) return json_value;
  --notice that a date type in json is also a varchar2
  function is_date(v json_value) return boolean;
  --convertion is needed to extract dates
  --(json_ext.to_date will not work along with the normal to_date function - any fix will be appreciated)
  function to_date2(v json_value) return date;
  --JSON Path with date
  function get_date(obj json, path varchar2, base number default 1) return date;
  procedure put(obj in out nocopy json, path varchar2, elem date, base number default 1);

  --experimental support of binary data with base64
  function base64(binarydata blob) return json_list;
  function base64(l json_list) return blob;

  function encode(binarydata blob) return json_value;
  function decode(v json_value) return blob;

end json_ext;
/
CREATE OR REPLACE PACKAGE BODY  "JSON_EXT" as
  scanner_exception exception;
  pragma exception_init(scanner_exception, -20100);
  parser_exception exception;
  pragma exception_init(parser_exception, -20101);
  jext_exception exception;
  pragma exception_init(jext_exception, -20110);

  --extra function checks if number has no fraction
  function is_integer(v json_value) return boolean as
    myint number(38); --the oracle way to specify an integer
  begin
    if(v.is_number) then
      myint := v.get_number;
      return (myint = v.get_number); --no rounding errors?
    else
      return false;
    end if;
  end;

  --extension enables json to store dates without comprimising the implementation
  function to_json_value(d date) return json_value as
  begin
    return json_value(to_char(d, format_string));
  end;

  --notice that a date type in json is also a varchar2
  function is_date(v json_value) return boolean as
    temp date;
  begin
    temp := json_ext.to_date2(v);
    return true;
  exception
    when others then
      return false;
  end;

  --convertion is needed to extract dates
  function to_date2(v json_value) return date as
  begin
    if(v.is_string) then
      return to_date(v.get_string, format_string);
    else
      raise_application_error(-20110, 'Anydata did not contain a date-value');
    end if;
  exception
    when others then
      raise_application_error(-20110, 'Anydata did not contain a date on the format: '||format_string);
  end;

  --Json Path parser
  function parsePath(json_path varchar2, base number default 1) return json_list as
    build_path varchar2(32767) := '[';
    buf varchar2(4);
    endstring varchar2(1);
    indx number := 1;
    ret json_list;

    procedure next_char as
    begin
      if(indx <= length(json_path)) then
        buf := substr(json_path, indx, 1);
        indx := indx + 1;
      else
        buf := null;
      end if;
    end;
    --skip ws
    procedure skipws as begin while(buf in (chr(9),chr(10),chr(13),' ')) loop next_char; end loop; end;

  begin
    next_char();
    while(buf is not null) loop
      if(buf = '.') then
        next_char();
        if(buf is null) then raise_application_error(-20110, 'JSON Path parse error: . is not a valid json_path end'); end if;
        if(not regexp_like(buf, '^[[:alnum:]\_ ]+', 'c') ) then
          raise_application_error(-20110, 'JSON Path parse error: alpha-numeric character or space expected at position '||indx);
        end if;

        if(build_path != '[') then build_path := build_path || ','; end if;
        build_path := build_path || '"';
        while(regexp_like(buf, '^[[:alnum:]\_ ]+', 'c') ) loop
          build_path := build_path || buf;
          next_char();
        end loop;
        build_path := build_path || '"';
      elsif(buf = '[') then
        next_char();
        skipws();
        if(buf is null) then raise_application_error(-20110, 'JSON Path parse error: [ is not a valid json_path end'); end if;
        if(buf in ('1','2','3','4','5','6','7','8','9') or (buf = '0' and base = 0)) then
          if(build_path != '[') then build_path := build_path || ','; end if;
          while(buf in ('0','1','2','3','4','5','6','7','8','9')) loop
            build_path := build_path || buf;
            next_char();
          end loop;
        elsif (regexp_like(buf, '^(\"|\'')', 'c')) then
          endstring := buf;
          if(build_path != '[') then build_path := build_path || ','; end if;
          build_path := build_path || '"';
          next_char();
          if(buf is null) then raise_application_error(-20110, 'JSON Path parse error: premature json_path end'); end if;
          while(buf != endstring) loop
            build_path := build_path || buf;
            next_char();
            if(buf is null) then raise_application_error(-20110, 'JSON Path parse error: premature json_path end'); end if;
            if(buf = '\') then
              next_char();
              build_path := build_path || '\' || buf;
              next_char();
            end if;
          end loop;
          build_path := build_path || '"';
          next_char();
        else
          raise_application_error(-20110, 'JSON Path parse error: expected a string or an positive integer at '||indx);
        end if;
        skipws();
        if(buf is null) then raise_application_error(-20110, 'JSON Path parse error: premature json_path end'); end if;
        if(buf != ']') then raise_application_error(-20110, 'JSON Path parse error: no array ending found. found: '|| buf); end if;
        next_char();
        skipws();
      elsif(build_path = '[') then
        if(not regexp_like(buf, '^[[:alnum:]\_ ]+', 'c') ) then
          raise_application_error(-20110, 'JSON Path parse error: alpha-numeric character or space expected at position '||indx);
        end if;
        build_path := build_path || '"';
        while(regexp_like(buf, '^[[:alnum:]\_ ]+', 'c') ) loop
          build_path := build_path || buf;
          next_char();
        end loop;
        build_path := build_path || '"';
      else
        raise_application_error(-20110, 'JSON Path parse error: expected . or [ found '|| buf || ' at position '|| indx);
      end if;

    end loop;

    build_path := build_path || ']';
    build_path := replace(replace(replace(replace(replace(build_path, chr(9), '\t'), chr(10), '\n'), chr(13), '\f'), chr(8), '\b'), chr(14), '\r');

    ret := json_list(build_path);
    if(base != 1) then
      --fix base 0 to base 1
      declare
        elem json_value;
      begin
        for i in 1 .. ret.count loop
          elem := ret.get(i);
          if(elem.is_number) then
            ret.replace(i,elem.get_number()+1);
          end if;
        end loop;
      end;
    end if;

    return ret;
  end parsePath;

  --JSON Path getters
  function get_json_value(obj json, v_path varchar2, base number default 1) return json_value as
    path json_list;
    ret json_value;
    o json; l json_list;
  begin
    path := parsePath(v_path, base);
    ret := obj.to_json_value;
    if(path.count = 0) then return ret; end if;

    for i in 1 .. path.count loop
      if(path.get(i).is_string()) then
        --string fetch only on json
        o := json(ret);
        ret := o.get(path.get(i).get_string());
      else
        --number fetch on json and json_list
        if(ret.is_array()) then
          l := json_list(ret);
          ret := l.get(path.get(i).get_number());
        else
          o := json(ret);
          l := o.get_values();
          ret := l.get(path.get(i).get_number());
        end if;
      end if;
    end loop;

    return ret;
  exception
    when scanner_exception then raise;
    when parser_exception then raise;
    when jext_exception then raise;
    when others then return null;
  end get_json_value;

  --JSON Path getters
  function get_string(obj json, path varchar2, base number default 1) return varchar2 as
    temp json_value;
  begin
    temp := get_json_value(obj, path, base);
    if(temp is null or not temp.is_string) then
      return null;
    else
      return temp.get_string;
    end if;
  end;

  function get_number(obj json, path varchar2, base number default 1) return number as
    temp json_value;
  begin
    temp := get_json_value(obj, path, base);
    if(temp is null or not temp.is_number) then
      return null;
    else
      return temp.get_number;
    end if;
  end;

  function get_json(obj json, path varchar2, base number default 1) return json as
    temp json_value;
  begin
    temp := get_json_value(obj, path, base);
    if(temp is null or not temp.is_object) then
      return null;
    else
      return json(temp);
    end if;
  end;

  function get_json_list(obj json, path varchar2, base number default 1) return json_list as
    temp json_value;
  begin
    temp := get_json_value(obj, path, base);
    if(temp is null or not temp.is_array) then
      return null;
    else
      return json_list(temp);
    end if;
  end;

  function get_bool(obj json, path varchar2, base number default 1) return boolean as
    temp json_value;
  begin
    temp := get_json_value(obj, path, base);
    if(temp is null or not temp.is_bool) then
      return null;
    else
      return temp.get_bool;
    end if;
  end;

  function get_date(obj json, path varchar2, base number default 1) return date as
    temp json_value;
  begin
    temp := get_json_value(obj, path, base);
    if(temp is null or not is_date(temp)) then
      return null;
    else
      return json_ext.to_date2(temp);
    end if;
  end;

  /* JSON Path putter internal function */
  procedure put_internal(obj in out nocopy json, v_path varchar2, elem json_value, base number) as
    val json_value := elem;
    path json_list;
    backreference json_list := json_list();

    keyval json_value; keynum number; keystring varchar2(4000);
    temp json_value := obj.to_json_value;
    obj_temp  json;
    list_temp json_list;
    inserter json_value;
  begin
    path := json_ext.parsePath(v_path, base);
    if(path.count = 0) then raise_application_error(-20110, 'JSON_EXT put error: cannot put with empty string.'); end if;

    --build backreference
    for i in 1 .. path.count loop
      --backreference.print(false);
      keyval := path.get(i);
      if (keyval.is_number()) then
        --nummer index
        keynum := keyval.get_number();
        if((not temp.is_object()) and (not temp.is_array())) then
          if(val is null) then return; end if;
          backreference.remove_last;
          temp := json_list().to_json_value();
          backreference.append(temp);
        end if;

        if(temp.is_object()) then
          obj_temp := json(temp);
          if(obj_temp.count < keynum) then
            if(val is null) then return; end if;
            raise_application_error(-20110, 'JSON_EXT put error: access object with to few members.');
          end if;
          temp := obj_temp.get(keynum);
        else
          list_temp := json_list(temp);
          if(list_temp.count < keynum) then
            if(val is null) then return; end if;
            --raise error or quit if val is null
            for i in list_temp.count+1 .. keynum loop
              list_temp.append(json_value.makenull);
            end loop;
            backreference.remove_last;
            backreference.append(list_temp);
          end if;

          temp := list_temp.get(keynum);
        end if;
      else
        --streng index
        keystring := keyval.get_string();
        if(not temp.is_object()) then
          --backreference.print;
          if(val is null) then return; end if;
          backreference.remove_last;
          temp := json().to_json_value();
          backreference.append(temp);
          --raise_application_error(-20110, 'JSON_ext put error: trying to access a non object with a string.');
        end if;
        obj_temp := json(temp);
        temp := obj_temp.get(keystring);
      end if;

      if(temp is null) then
        if(val is null) then return; end if;
        --what to expect?
        keyval := path.get(i+1);
        if(keyval is not null and keyval.is_number()) then
          temp := json_list().to_json_value;
        else
          temp := json().to_json_value;
        end if;
      end if;
      backreference.append(temp);
    end loop;

  --  backreference.print(false);
  --  path.print(false);

    --use backreference and path together
    inserter := val;
    for i in reverse 1 .. backreference.count loop
  --    inserter.print(false);
      if( i = 1 ) then
        keyval := path.get(1);
        if(keyval.is_string()) then
          keystring := keyval.get_string();
        else
          keynum := keyval.get_number();
          declare
            t1 json_value := obj.get(keynum);
          begin
            keystring := t1.mapname;
          end;
        end if;
        if(inserter is null) then obj.remove(keystring); else obj.put(keystring, inserter); end if;
      else
        temp := backreference.get(i-1);
        if(temp.is_object()) then
          keyval := path.get(i);
          obj_temp := json(temp);
          if(keyval.is_string()) then
            keystring := keyval.get_string();
          else
            keynum := keyval.get_number();
            declare
              t1 json_value := obj_temp.get(keynum);
            begin
              keystring := t1.mapname;
            end;
          end if;
          if(inserter is null) then
            obj_temp.remove(keystring);
            if(obj_temp.count > 0) then inserter := obj_temp.to_json_value; end if;
          else
            obj_temp.put(keystring, inserter);
            inserter := obj_temp.to_json_value;
          end if;
        else
          --array only number
          keynum := path.get(i).get_number();
          list_temp := json_list(temp);
          list_temp.remove(keynum);
          if(not inserter is null) then
            list_temp.append(inserter, keynum);
            inserter := list_temp.to_json_value;
          else
            if(list_temp.count > 0) then inserter := list_temp.to_json_value; end if;
          end if;
        end if;
      end if;

    end loop;

  end put_internal;

  /* JSON Path putters */
  procedure put(obj in out nocopy json, path varchar2, elem varchar2, base number default 1) as
  begin
    put_internal(obj, path, json_value(elem), base);
  end;

  procedure put(obj in out nocopy json, path varchar2, elem number, base number default 1) as
  begin
    if(elem is null) then raise_application_error(-20110, 'Cannot put null-value'); end if;
    put_internal(obj, path, json_value(elem), base);
  end;

  procedure put(obj in out nocopy json, path varchar2, elem json, base number default 1) as
  begin
    if(elem is null) then raise_application_error(-20110, 'Cannot put null-value'); end if;
    put_internal(obj, path, elem.to_json_value, base);
  end;

  procedure put(obj in out nocopy json, path varchar2, elem json_list, base number default 1) as
  begin
    if(elem is null) then raise_application_error(-20110, 'Cannot put null-value'); end if;
    put_internal(obj, path, elem.to_json_value, base);
  end;

  procedure put(obj in out nocopy json, path varchar2, elem boolean, base number default 1) as
  begin
    if(elem is null) then raise_application_error(-20110, 'Cannot put null-value'); end if;
    put_internal(obj, path, json_value(elem), base);
  end;

  procedure put(obj in out nocopy json, path varchar2, elem json_value, base number default 1) as
  begin
    if(elem is null) then raise_application_error(-20110, 'Cannot put null-value'); end if;
    put_internal(obj, path, elem, base);
  end;

  procedure put(obj in out nocopy json, path varchar2, elem date, base number default 1) as
  begin
    if(elem is null) then raise_application_error(-20110, 'Cannot put null-value'); end if;
    put_internal(obj, path, json_ext.to_json_value(elem), base);
  end;

  procedure remove(obj in out nocopy json, path varchar2, base number default 1) as
  begin
    json_ext.put_internal(obj,path,null,base);
--    if(json_ext.get_json_value(obj,path) is not null) then
--    end if;
  end remove;

    --Pretty print with JSON Path
  function pp(obj json, v_path varchar2) return varchar2 as
    json_part json_value;
  begin
    json_part := json_ext.get_json_value(obj, v_path);
    if(json_part is null) then
      return '';
    else
      return json_printer.pretty_print_any(json_part); --escapes a possible internal string
    end if;
  end pp;

  procedure pp(obj json, v_path varchar2) as --using dbms_output.put_line
  begin
    dbms_output.put_line(pp(obj, v_path));
  end pp;

  -- spaces = false!
  procedure pp_htp(obj json, v_path varchar2) as --using htp.print
    json_part json_value;
  begin
    json_part := json_ext.get_json_value(obj, v_path);
    if(json_part is null) then htp.print; else
      htp.print(json_printer.pretty_print_any(json_part, false));
    end if;
  end pp_htp;

  function base64(binarydata blob) return json_list as
    obj json_list := json_list();
    c clob := empty_clob();
    benc blob;

    v_blob_offset NUMBER := 1;
    v_clob_offset NUMBER := 1;
    v_lang_context NUMBER := DBMS_LOB.DEFAULT_LANG_CTX;
    v_warning NUMBER;
    v_amount PLS_INTEGER;
--    temp varchar2(32767);

    FUNCTION encodeBlob2Base64(pBlobIn IN BLOB) RETURN BLOB IS
      vAmount NUMBER := 45;
      vBlobEnc BLOB := empty_blob();
      vBlobEncLen NUMBER := 0;
      vBlobInLen NUMBER := 0;
      vBuffer RAW(45);
      vOffset NUMBER := 1;
    BEGIN
--      dbms_output.put_line('Start base64 encoding.');
      vBlobInLen := dbms_lob.getlength(pBlobIn);
--      dbms_output.put_line('<BlobInLength>' || vBlobInLen);
      dbms_lob.createtemporary(vBlobEnc, TRUE);
      LOOP
        IF vOffset >= vBlobInLen THEN
          EXIT;
        END IF;
        dbms_lob.read(pBlobIn, vAmount, vOffset, vBuffer);
        BEGIN
          dbms_lob.append(vBlobEnc, utl_encode.base64_encode(vBuffer));
        EXCEPTION
          WHEN OTHERS THEN
          dbms_output.put_line('<vAmount>' || vAmount || '<vOffset>' || vOffset || '<vBuffer>' || vBuffer);
          dbms_output.put_line('ERROR IN append: ' || SQLERRM);
          RAISE;
        END;
        vOffset := vOffset + vAmount;
      END LOOP;
      vBlobEncLen := dbms_lob.getlength(vBlobEnc);
--      dbms_output.put_line('<BlobEncLength>' || vBlobEncLen);
--      dbms_output.put_line('Finshed base64 encoding.');
      RETURN vBlobEnc;
    END encodeBlob2Base64;
  begin
    benc := encodeBlob2Base64(binarydata);
    dbms_lob.createtemporary(c, TRUE);
    v_amount := DBMS_LOB.GETLENGTH(benc);
    DBMS_LOB.CONVERTTOCLOB(c, benc, v_amount, v_clob_offset, v_blob_offset, 1, v_lang_context, v_warning);

    v_amount := DBMS_LOB.GETLENGTH(c);
    v_clob_offset := 1;
    --dbms_output.put_line('V amount: '||v_amount);
    while(v_clob_offset < v_amount) loop
      --dbms_output.put_line(v_offset);
      --temp := ;
      --dbms_output.put_line('size: '||length(temp));
      obj.append(dbms_lob.SUBSTR(c, 4000,v_clob_offset));
      v_clob_offset := v_clob_offset + 4000;
    end loop;
    dbms_lob.freetemporary(benc);
    dbms_lob.freetemporary(c);
  --dbms_output.put_line(obj.count);
  --dbms_output.put_line(obj.get_last().to_char);
    return obj;

  end base64;


  function base64(l json_list) return blob as
    c clob := empty_clob();
    b blob := empty_blob();
    bret blob;

    v_blob_offset NUMBER := 1;
    v_clob_offset NUMBER := 1;
    v_lang_context NUMBER := 0; --DBMS_LOB.DEFAULT_LANG_CTX;
    v_warning NUMBER;
    v_amount PLS_INTEGER;

    FUNCTION decodeBase642Blob(pBlobIn IN BLOB) RETURN BLOB IS
      vAmount NUMBER := 256;--32;
      vBlobDec BLOB := empty_blob();
      vBlobDecLen NUMBER := 0;
      vBlobInLen NUMBER := 0;
      vBuffer RAW(256);--32);
      vOffset NUMBER := 1;
    BEGIN
--      dbms_output.put_line('Start base64 decoding.');
      vBlobInLen := dbms_lob.getlength(pBlobIn);
--      dbms_output.put_line('<BlobInLength>' || vBlobInLen);
      dbms_lob.createtemporary(vBlobDec, TRUE);
      LOOP
        IF vOffset >= vBlobInLen THEN
          EXIT;
        END IF;
        dbms_lob.read(pBlobIn, vAmount, vOffset, vBuffer);
        BEGIN
          dbms_lob.append(vBlobDec, utl_encode.base64_decode(vBuffer));
        EXCEPTION
          WHEN OTHERS THEN
          dbms_output.put_line('<vAmount>' || vAmount || '<vOffset>' || vOffset || '<vBuffer>' || vBuffer);
          dbms_output.put_line('ERROR IN append: ' || SQLERRM);
          RAISE;
        END;
        vOffset := vOffset + vAmount;
      END LOOP;
      vBlobDecLen := dbms_lob.getlength(vBlobDec);
--      dbms_output.put_line('<BlobDecLength>' || vBlobDecLen);
--      dbms_output.put_line('Finshed base64 decoding.');
      RETURN vBlobDec;
    END decodeBase642Blob;
  begin
    dbms_lob.createtemporary(c, TRUE);
    for i in 1 .. l.count loop
      dbms_lob.append(c, l.get(i).get_string());
    end loop;
    v_amount := DBMS_LOB.GETLENGTH(c);
--    dbms_output.put_line('L C'||v_amount);

    dbms_lob.createtemporary(b, TRUE);
    DBMS_LOB.CONVERTTOBLOB(b, c, dbms_lob.lobmaxsize, v_clob_offset, v_blob_offset, 1, v_lang_context, v_warning);
    dbms_lob.freetemporary(c);
    v_amount := DBMS_LOB.GETLENGTH(b);
--    dbms_output.put_line('L B'||v_amount);

    bret := decodeBase642Blob(b);
    dbms_lob.freetemporary(b);
    return bret;

  end base64;

  function encode(binarydata blob) return json_value as
    obj json_value;
    c clob := empty_clob();
    benc blob;

    v_blob_offset NUMBER := 1;
    v_clob_offset NUMBER := 1;
    v_lang_context NUMBER := DBMS_LOB.DEFAULT_LANG_CTX;
    v_warning NUMBER;
    v_amount PLS_INTEGER;
--    temp varchar2(32767);

    FUNCTION encodeBlob2Base64(pBlobIn IN BLOB) RETURN BLOB IS
      vAmount NUMBER := 45;
      vBlobEnc BLOB := empty_blob();
      vBlobEncLen NUMBER := 0;
      vBlobInLen NUMBER := 0;
      vBuffer RAW(45);
      vOffset NUMBER := 1;
    BEGIN
--      dbms_output.put_line('Start base64 encoding.');
      vBlobInLen := dbms_lob.getlength(pBlobIn);
--      dbms_output.put_line('<BlobInLength>' || vBlobInLen);
      dbms_lob.createtemporary(vBlobEnc, TRUE);
      LOOP
        IF vOffset >= vBlobInLen THEN
          EXIT;
        END IF;
        dbms_lob.read(pBlobIn, vAmount, vOffset, vBuffer);
        BEGIN
          dbms_lob.append(vBlobEnc, utl_encode.base64_encode(vBuffer));
        EXCEPTION
          WHEN OTHERS THEN
          dbms_output.put_line('<vAmount>' || vAmount || '<vOffset>' || vOffset || '<vBuffer>' || vBuffer);
          dbms_output.put_line('ERROR IN append: ' || SQLERRM);
          RAISE;
        END;
        vOffset := vOffset + vAmount;
      END LOOP;
      vBlobEncLen := dbms_lob.getlength(vBlobEnc);
--      dbms_output.put_line('<BlobEncLength>' || vBlobEncLen);
--      dbms_output.put_line('Finshed base64 encoding.');
      RETURN vBlobEnc;
    END encodeBlob2Base64;
  begin
    benc := encodeBlob2Base64(binarydata);
    dbms_lob.createtemporary(c, TRUE);
    v_amount := DBMS_LOB.GETLENGTH(benc);
    DBMS_LOB.CONVERTTOCLOB(c, benc, v_amount, v_clob_offset, v_blob_offset, 1, v_lang_context, v_warning);

    obj := json_value(c);

    dbms_lob.freetemporary(benc);
    dbms_lob.freetemporary(c);
  --dbms_output.put_line(obj.count);
  --dbms_output.put_line(obj.get_last().to_char);
    return obj;

  end encode;

  function decode(v json_value) return blob as
    c clob := empty_clob();
    b blob := empty_blob();
    bret blob;

    v_blob_offset NUMBER := 1;
    v_clob_offset NUMBER := 1;
    v_lang_context NUMBER := 0; --DBMS_LOB.DEFAULT_LANG_CTX;
    v_warning NUMBER;
    v_amount PLS_INTEGER;

    FUNCTION decodeBase642Blob(pBlobIn IN BLOB) RETURN BLOB IS
      vAmount NUMBER := 256;--32;
      vBlobDec BLOB := empty_blob();
      vBlobDecLen NUMBER := 0;
      vBlobInLen NUMBER := 0;
      vBuffer RAW(256);--32);
      vOffset NUMBER := 1;
    BEGIN
--      dbms_output.put_line('Start base64 decoding.');
      vBlobInLen := dbms_lob.getlength(pBlobIn);
--      dbms_output.put_line('<BlobInLength>' || vBlobInLen);
      dbms_lob.createtemporary(vBlobDec, TRUE);
      LOOP
        IF vOffset >= vBlobInLen THEN
          EXIT;
        END IF;
        dbms_lob.read(pBlobIn, vAmount, vOffset, vBuffer);
        BEGIN
          dbms_lob.append(vBlobDec, utl_encode.base64_decode(vBuffer));
        EXCEPTION
          WHEN OTHERS THEN
          dbms_output.put_line('<vAmount>' || vAmount || '<vOffset>' || vOffset || '<vBuffer>' || vBuffer);
          dbms_output.put_line('ERROR IN append: ' || SQLERRM);
          RAISE;
        END;
        vOffset := vOffset + vAmount;
      END LOOP;
      vBlobDecLen := dbms_lob.getlength(vBlobDec);
--      dbms_output.put_line('<BlobDecLength>' || vBlobDecLen);
--      dbms_output.put_line('Finshed base64 decoding.');
      RETURN vBlobDec;
    END decodeBase642Blob;
  begin
    dbms_lob.createtemporary(c, TRUE);
    v.get_string(c);
    v_amount := DBMS_LOB.GETLENGTH(c);
--    dbms_output.put_line('L C'||v_amount);

    dbms_lob.createtemporary(b, TRUE);
    DBMS_LOB.CONVERTTOBLOB(b, c, dbms_lob.lobmaxsize, v_clob_offset, v_blob_offset, 1, v_lang_context, v_warning);
    dbms_lob.freetemporary(c);
    v_amount := DBMS_LOB.GETLENGTH(b);
--    dbms_output.put_line('L B'||v_amount);

    bret := decodeBase642Blob(b);
    dbms_lob.freetemporary(b);
    return bret;

  end decode;


end json_ext;
/

 CREATE SEQUENCE   "S4SA_REQ_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 4537 NOCACHE  ORDER  NOCYCLE
/
CREATE OR REPLACE TRIGGER  "S4SA_REQ_BIR_TRG" 
  before insert
  on s4sa_requests 
  for each row
declare
  -- local variables here
begin
  :new.id := s4sa_req_seq.nextval;
end s4sa_REQ_BIR_TRG;

/
ALTER TRIGGER  "S4SA_REQ_BIR_TRG" ENABLE
/
CREATE OR REPLACE FORCE VIEW  "S4SA_REQUESTS_VW" ("ID", "TIJD", "RESPONSE", "REQUEST_SOURCE", "REQUEST_URI", "REQUEST_TYPE", "REQUEST_HEADERS", "REQUEST_BODY", "APPLICATION", "GEBRUIKER") AS 
  select req.ID
,      req.TIJD
,      req.RESPONSE
,      req.REQUEST_SOURCE
,      req.REQUEST_URI
,      req.REQUEST_TYPE
,      req.REQUEST_HEADERS
,      req.REQUEST_BODY
, req.application
, req.gebruiker
from   s4sa_requests req
order by req.id desc
/
CREATE OR REPLACE FORCE VIEW  "S4SG_OAUTH_USER_VW" ("PROVIDER", "REFRESH_TOKEN", "GOTOPAGE", "PROVIDER_CODE", "ACCESS_TOKEN", "TOKEN_TYPE", "EXPIRES_IN", "ID_TOKEN", "SESSION_START", "TIME_LEFT", "PROVIDER_ERROR", "PROVIDER_USER_ID", "PROVIDER_USER_EMAIL", "PROVIDER_USER_VERIFIED_EMAIL", "PROVIDER_USER_NAME", "PROVIDER_USER_GIVEN_NAME", "PROVIDER_USER_FAMILY_NAME", "PROVIDER_USER_LINK", "PROVIDER_USER_PICTURE", "PROVIDER_USER_GENDER", "PROVIDER_USER_LOCALE", "PROVIDER_USER_HD") AS 
  select c.c001            as provider
,      c.c002            as refresh_token
,      c.c003            as gotopage
,      c.c004            as provider_code
,      c.c005            as access_token
,      c.c006            as token_type
,      c.n001            as expires_in
,      c.c007            as id_token
,      c.d001            as session_start
,      c.n001 - trunc((sysdate - c.d001) * 24 * 60 * 60) as time_left
,      c.c008            as provider_error
,      c.c009            as provider_user_id
,      c.c010            as provider_user_email
,      c.c011            as provider_user_verified_email
,      c.c012            as provider_user_name
,      c.c013            as provider_user_given_name
,      c.c014            as provider_user_family_name
,      c.c015            as provider_user_link
,      c.c016            as provider_user_picture
,      c.c017            as provider_user_gender
,      c.c018            as provider_user_locale
,      c.c019            as provider_user_hd
from apex_collections c
where c.collection_name = s4sa_oauth_pck.g_collname$
/
CREATE OR REPLACE TYPE  "JSON_VALUE_ARRAY" force as table of json_value;
/
CREATE OR REPLACE TYPE  "JSON_VALUE" force as object
( 
  /*
  Copyright (c) 2010 Jonas Krogsboell

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  */

  typeval number(1), /* 1 = object, 2 = array, 3 = string, 4 = number, 5 = bool, 6 = null */
  str varchar2(32767),
  num number, /* store 1 as true, 0 as false */
  object_or_array sys.anydata, /* object or array in here */
  extended_str clob,
  
  /* mapping */
  mapname varchar2(4000),
  mapindx number(32),  
  
  constructor function json_value(object_or_array sys.anydata) return self as result,
  constructor function json_value(str varchar2, esc boolean default true) return self as result,
  constructor function json_value(str clob, esc boolean default true) return self as result,
  constructor function json_value(num number) return self as result,
  constructor function json_value(b boolean) return self as result,
  constructor function json_value return self as result,
  static function makenull return json_value,
  
  member function get_type return varchar2,
  member function get_string(max_byte_size number default null, max_char_size number default null) return varchar2,
  member procedure get_string(self in json_value, buf in out nocopy clob),
  member function get_number return number,
  member function get_bool return boolean,
  member function get_null return varchar2,
  
  member function is_object return boolean,
  member function is_array return boolean,
  member function is_string return boolean,
  member function is_number return boolean,
  member function is_bool return boolean,
  member function is_null return boolean,
  
  /* Output methods */ 
  member function to_char(spaces boolean default true, chars_per_line number default 0) return varchar2,
  member procedure to_clob(self in json_value, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true),
  member procedure print(self in json_value, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null), --32512 is maximum
  member procedure htp(self in json_value, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null),
  
  member function value_of(self in json_value, max_byte_size number default null, max_char_size number default null) return varchar2
  
) not final;
/
CREATE OR REPLACE TYPE BODY  "JSON_VALUE" as

  constructor function json_value(object_or_array sys.anydata) return self as result as
  begin
    case object_or_array.gettypename
      when sys_context('userenv', 'current_schema')||'.JSON_LIST' then self.typeval := 2;
      when sys_context('userenv', 'current_schema')||'.JSON' then self.typeval := 1;
      else raise_application_error(-20102, 'JSON_Value init error (JSON or JSON\_List allowed)');
    end case;
    self.object_or_array := object_or_array;
    if(self.object_or_array is null) then self.typeval := 6; end if;
    
    return;
  end json_value;

  constructor function json_value(str varchar2, esc boolean default true) return self as result as
  begin
    self.typeval := 3;
    if(esc) then self.num := 1; else self.num := 0; end if; --message to pretty printer
    self.str := str;
    return;
  end json_value;

  constructor function json_value(str clob, esc boolean default true) return self as result as
    amount number := 32767;
  begin
    self.typeval := 3;
    if(esc) then self.num := 1; else self.num := 0; end if; --message to pretty printer
    if(dbms_lob.getlength(str) > 32767) then
      extended_str := str;
    end if;
    -- GHS 20120615: Added IF structure to handle null clobs
    if dbms_lob.getlength(str) > 0 then
      dbms_lob.read(str, amount, 1, self.str);
    end if;
    return;
  end json_value;

  constructor function json_value(num number) return self as result as
  begin
    self.typeval := 4;
    self.num := num;
    if(self.num is null) then self.typeval := 6; end if;
    return;
  end json_value;

  constructor function json_value(b boolean) return self as result as
  begin
    self.typeval := 5;
    self.num := 0;
    if(b) then self.num := 1; end if;
    if(b is null) then self.typeval := 6; end if;
    return;
  end json_value;

  constructor function json_value return self as result as
  begin
    self.typeval := 6; /* for JSON null */
    return;
  end json_value;

  static function makenull return json_value as
  begin
    return json_value;
  end makenull;

  member function get_type return varchar2 as
  begin
    case self.typeval
    when 1 then return 'object';
    when 2 then return 'array';
    when 3 then return 'string';
    when 4 then return 'number';
    when 5 then return 'bool';
    when 6 then return 'null';
    end case;
    
    return 'unknown type';
  end get_type;

  member function get_string(max_byte_size number default null, max_char_size number default null) return varchar2 as
  begin
    if(self.typeval = 3) then 
      if(max_byte_size is not null) then 
        return substrb(self.str,1,max_byte_size);
      elsif (max_char_size is not null) then
        return substr(self.str,1,max_char_size);
      else
        return self.str;
      end if;
    end if;
    return null;
  end get_string;
  
  member procedure get_string(self in json_value, buf in out nocopy clob) as
  begin
    if(self.typeval = 3) then 
      if(extended_str is not null) then
        dbms_lob.copy(buf, extended_str, dbms_lob.getlength(extended_str));
      else
        dbms_lob.writeappend(buf, length(self.str), self.str);      
      end if;
    end if;
  end get_string;


  member function get_number return number as
  begin
    if(self.typeval = 4) then 
      return self.num;
    end if;
    return null;
  end get_number;

  member function get_bool return boolean as
  begin
    if(self.typeval = 5) then 
      return self.num = 1;
    end if;
    return null;
  end get_bool;

  member function get_null return varchar2 as
  begin
    if(self.typeval = 6) then 
      return 'null';
    end if;
    return null;
  end get_null;

  member function is_object return boolean as begin return self.typeval = 1; end;
  member function is_array return boolean as begin return self.typeval = 2; end;
  member function is_string return boolean as begin return self.typeval = 3; end;
  member function is_number return boolean as begin return self.typeval = 4; end;
  member function is_bool return boolean as begin return self.typeval = 5; end;
  member function is_null return boolean as begin return self.typeval = 6; end;

  /* Output methods */  
  member function to_char(spaces boolean default true, chars_per_line number default 0) return varchar2 as
  begin
    if(spaces is null) then
      return json_printer.pretty_print_any(self, line_length => chars_per_line);
    else 
      return json_printer.pretty_print_any(self, spaces, line_length => chars_per_line);
    end if;
  end;

  member procedure to_clob(self in json_value, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true) as
  begin
    if(spaces is null) then	
      json_printer.pretty_print_any(self, false, buf, line_length => chars_per_line, erase_clob => erase_clob);
    else 
      json_printer.pretty_print_any(self, spaces, buf, line_length => chars_per_line, erase_clob => erase_clob);
    end if;
  end;

  member procedure print(self in json_value, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null) as --32512 is the real maximum in sqldeveloper
    my_clob clob;
  begin
    my_clob := empty_clob();
    dbms_lob.createtemporary(my_clob, true);
    json_printer.pretty_print_any(self, spaces, my_clob, case when (chars_per_line>32512) then 32512 else chars_per_line end);
    json_printer.dbms_output_clob(my_clob, json_printer.newline_char, jsonp);
    dbms_lob.freetemporary(my_clob);  
  end;
  
  member procedure htp(self in json_value, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null) as 
    my_clob clob;
  begin
    my_clob := empty_clob();
    dbms_lob.createtemporary(my_clob, true);
    json_printer.pretty_print_any(self, spaces, my_clob, chars_per_line);
    json_printer.htp_output_clob(my_clob, jsonp);
    dbms_lob.freetemporary(my_clob);  
  end;

  member function value_of(self in json_value, max_byte_size number default null, max_char_size number default null) return varchar2 as
  begin
    case self.typeval
    when 1 then return 'json object';
    when 2 then return 'json array';
    when 3 then return self.get_string(max_byte_size,max_char_size);
    when 4 then return self.get_number();
    when 5 then if(self.get_bool()) then return 'true'; else return 'false'; end if;
    else return null;
    end case;
  end;

end;
/

CREATE OR REPLACE TYPE  "JSON_LIST" force as object (
  /*
  Copyright (c) 2010 Jonas Krogsboell

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  */

  list_data json_value_array,
  constructor function json_list return self as result,
  constructor function json_list(str varchar2) return self as result,
  constructor function json_list(str clob) return self as result,
  constructor function json_list(cast json_value) return self as result,
  
  member procedure append(self in out nocopy json_list, elem json_value, position pls_integer default null),
  member procedure append(self in out nocopy json_list, elem varchar2, position pls_integer default null),
  member procedure append(self in out nocopy json_list, elem number, position pls_integer default null),
  member procedure append(self in out nocopy json_list, elem boolean, position pls_integer default null),
  member procedure append(self in out nocopy json_list, elem json_list, position pls_integer default null),

  member procedure replace(self in out nocopy json_list, position pls_integer, elem json_value),
  member procedure replace(self in out nocopy json_list, position pls_integer, elem varchar2),
  member procedure replace(self in out nocopy json_list, position pls_integer, elem number),
  member procedure replace(self in out nocopy json_list, position pls_integer, elem boolean),
  member procedure replace(self in out nocopy json_list, position pls_integer, elem json_list),

  member function count return number,
  member procedure remove(self in out nocopy json_list, position pls_integer),
  member procedure remove_first(self in out nocopy json_list),
  member procedure remove_last(self in out nocopy json_list),
  member function get(position pls_integer) return json_value,
  member function head return json_value,
  member function last return json_value,
  member function tail return json_list,

  /* Output methods */ 
  member function to_char(spaces boolean default true, chars_per_line number default 0) return varchar2,
  member procedure to_clob(self in json_list, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true),
  member procedure print(self in json_list, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null), --32512 is maximum
  member procedure htp(self in json_list, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null),

  /* json path */
  member function path(json_path varchar2, base number default 1) return json_value,
  /* json path_put */
  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem json_value, base number default 1),
  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem varchar2  , base number default 1),
  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem number    , base number default 1),
  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem boolean   , base number default 1),
  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem json_list , base number default 1),

  /* json path_remove */
  member procedure path_remove(self in out nocopy json_list, json_path varchar2, base number default 1),

  member function to_json_value return json_value
  /* --backwards compatibility
  ,
  member procedure add_elem(self in out nocopy json_list, elem json_value, position pls_integer default null),
  member procedure add_elem(self in out nocopy json_list, elem varchar2, position pls_integer default null),
  member procedure add_elem(self in out nocopy json_list, elem number, position pls_integer default null),
  member procedure add_elem(self in out nocopy json_list, elem boolean, position pls_integer default null),
  member procedure add_elem(self in out nocopy json_list, elem json_list, position pls_integer default null),

  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem json_value),
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem varchar2),
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem number),
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem boolean),
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem json_list),
  
  member procedure remove_elem(self in out nocopy json_list, position pls_integer),
  member function get_elem(position pls_integer) return json_value,
  member function get_first return json_value,
  member function get_last return json_value
--  */
  
) not final;
/
CREATE OR REPLACE TYPE BODY  "JSON_LIST" as

  constructor function json_list return self as result as
  begin
    self.list_data := json_value_array();
    return;
  end;

  constructor function json_list(str varchar2) return self as result as
  begin
    self := json_parser.parse_list(str);
    return;
  end;
  
  constructor function json_list(str clob) return self as result as
  begin
    self := json_parser.parse_list(str);
    return;
  end;

  constructor function json_list(cast json_value) return self as result as
    x number;
  begin
    x := cast.object_or_array.getobject(self);
    return;
  end;


  member procedure append(self in out nocopy json_list, elem json_value, position pls_integer default null) as
    indx pls_integer;
    insert_value json_value := NVL(elem, json_value);
  begin
    if(position is null or position > self.count) then --end of list
      indx := self.count + 1;
      self.list_data.extend(1);
      self.list_data(indx) := insert_value;
    elsif(position < 1) then --new first
      indx := self.count;
      self.list_data.extend(1);
      for x in reverse 1 .. indx loop
        self.list_data(x+1) := self.list_data(x);
      end loop;
      self.list_data(1) := insert_value;
    else
      indx := self.count;
      self.list_data.extend(1);
      for x in reverse position .. indx loop
        self.list_data(x+1) := self.list_data(x);
      end loop;
      self.list_data(position) := insert_value;
    end if;

  end;

  member procedure append(self in out nocopy json_list, elem varchar2, position pls_integer default null) as
  begin
    append(json_value(elem), position);
  end;
  
  member procedure append(self in out nocopy json_list, elem number, position pls_integer default null) as
  begin
    if(elem is null) then
      append(json_value(), position);
    else
      append(json_value(elem), position);
    end if;
  end;
  
  member procedure append(self in out nocopy json_list, elem boolean, position pls_integer default null) as
  begin
    if(elem is null) then
      append(json_value(), position);
    else
      append(json_value(elem), position);
    end if;
  end;

  member procedure append(self in out nocopy json_list, elem json_list, position pls_integer default null) as
  begin
    if(elem is null) then
      append(json_value(), position);
    else
      append(elem.to_json_value, position);
    end if;
  end;
  
 member procedure replace(self in out nocopy json_list, position pls_integer, elem json_value) as
    insert_value json_value := NVL(elem, json_value);
    indx number;
  begin
    if(position > self.count) then --end of list
      indx := self.count + 1;
      self.list_data.extend(1);
      self.list_data(indx) := insert_value;
    elsif(position < 1) then --maybe an error message here
      null;
    else
      self.list_data(position) := insert_value;
    end if;
  end;
  
  member procedure replace(self in out nocopy json_list, position pls_integer, elem varchar2) as
  begin
    replace(position, json_value(elem));
  end;
  
  member procedure replace(self in out nocopy json_list, position pls_integer, elem number) as
  begin
    if(elem is null) then
      replace(position, json_value());
    else
      replace(position, json_value(elem));
    end if;
  end;
  
  member procedure replace(self in out nocopy json_list, position pls_integer, elem boolean) as 
  begin
    if(elem is null) then
      replace(position, json_value());
    else
      replace(position, json_value(elem));
    end if;
  end;
  
  member procedure replace(self in out nocopy json_list, position pls_integer, elem json_list) as 
  begin
    if(elem is null) then
      replace(position, json_value());
    else
      replace(position, elem.to_json_value);
    end if;
  end;

  member function count return number as
  begin
    return self.list_data.count;
  end;
  
  member procedure remove(self in out nocopy json_list, position pls_integer) as
  begin
    if(position is null or position < 1 or position > self.count) then return; end if;
    for x in (position+1) .. self.count loop
      self.list_data(x-1) := self.list_data(x);
    end loop;
    self.list_data.trim(1);
  end;
  
  member procedure remove_first(self in out nocopy json_list) as 
  begin
    for x in 2 .. self.count loop
      self.list_data(x-1) := self.list_data(x);
    end loop;
    if(self.count > 0) then 
      self.list_data.trim(1);
    end if;
  end;
  
  member procedure remove_last(self in out nocopy json_list) as
  begin
    if(self.count > 0) then 
      self.list_data.trim(1);
    end if;
  end;
  
  member function get(position pls_integer) return json_value as
  begin
    if(self.count >= position and position > 0) then
      return self.list_data(position);
    end if;
    return null; -- do not throw error, just return null
  end;
  
  member function head return json_value as
  begin
    if(self.count > 0) then
      return self.list_data(self.list_data.first);
    end if;
    return null; -- do not throw error, just return null
  end;
  
  member function last return json_value as
  begin
    if(self.count > 0) then
      return self.list_data(self.list_data.last);
    end if;
    return null; -- do not throw error, just return null
  end;
  
  member function tail return json_list as
    t json_list;
  begin
    if(self.count > 0) then
      t := json_list(self.list_data);
      t.remove(1);
      return t;
    else return json_list(); end if;
  end;

  member function to_char(spaces boolean default true, chars_per_line number default 0) return varchar2 as
  begin
    if(spaces is null) then
      return json_printer.pretty_print_list(self, line_length => chars_per_line);
    else 
      return json_printer.pretty_print_list(self, spaces, line_length => chars_per_line);
    end if;
  end;

  member procedure to_clob(self in json_list, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true) as
  begin
    if(spaces is null) then	
      json_printer.pretty_print_list(self, false, buf, line_length => chars_per_line, erase_clob => erase_clob);
    else 
      json_printer.pretty_print_list(self, spaces, buf, line_length => chars_per_line, erase_clob => erase_clob);
    end if;
  end;

  member procedure print(self in json_list, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null) as --32512 is the real maximum in sqldeveloper
    my_clob clob;
  begin
    my_clob := empty_clob();
    dbms_lob.createtemporary(my_clob, true);
    json_printer.pretty_print_list(self, spaces, my_clob, case when (chars_per_line>32512) then 32512 else chars_per_line end);
    json_printer.dbms_output_clob(my_clob, json_printer.newline_char, jsonp);
    dbms_lob.freetemporary(my_clob);  
  end;
  
  member procedure htp(self in json_list, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null) as 
    my_clob clob;
  begin
    my_clob := empty_clob();
    dbms_lob.createtemporary(my_clob, true);
    json_printer.pretty_print_list(self, spaces, my_clob, chars_per_line);
    json_printer.htp_output_clob(my_clob, jsonp);
    dbms_lob.freetemporary(my_clob);  
  end;

  /* json path */
  member function path(json_path varchar2, base number default 1) return json_value as
    cp json_list := self;
  begin
    return json_ext.get_json_value(json(cp), json_path, base);
  end path;


  /* json path_put */
  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem json_value, base number default 1) as
    objlist json;
    jp json_list := json_ext.parsePath(json_path, base); 
  begin
    while(jp.head().get_number() > self.count) loop
      self.append(json_value());
    end loop;
    
    objlist := json(self);
    json_ext.put(objlist, json_path, elem, base);
    self := objlist.get_values;
  end path_put;
  
  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem varchar2, base number default 1) as
    objlist json;
    jp json_list := json_ext.parsePath(json_path, base); 
  begin
    while(jp.head().get_number() > self.count) loop
      self.append(json_value());
    end loop;
    
    objlist := json(self);
    json_ext.put(objlist, json_path, elem, base);
    self := objlist.get_values;
  end path_put;
  
  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem number, base number default 1) as
    objlist json;
    jp json_list := json_ext.parsePath(json_path, base); 
  begin
    while(jp.head().get_number() > self.count) loop
      self.append(json_value());
    end loop;
    
    objlist := json(self);
  
    if(elem is null) then 
      json_ext.put(objlist, json_path, json_value, base);
    else 
      json_ext.put(objlist, json_path, elem, base);
    end if;
    self := objlist.get_values;
  end path_put;

  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem boolean, base number default 1) as
    objlist json;
    jp json_list := json_ext.parsePath(json_path, base); 
  begin
    while(jp.head().get_number() > self.count) loop
      self.append(json_value());
    end loop;
    
    objlist := json(self);
    if(elem is null) then 
      json_ext.put(objlist, json_path, json_value, base);
    else 
      json_ext.put(objlist, json_path, elem, base);
    end if;
    self := objlist.get_values;
  end path_put;

  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem json_list, base number default 1) as
    objlist json;
    jp json_list := json_ext.parsePath(json_path, base); 
  begin
    while(jp.head().get_number() > self.count) loop
      self.append(json_value());
    end loop;
    
    objlist := json(self);
    if(elem is null) then 
      json_ext.put(objlist, json_path, json_value, base);
    else 
      json_ext.put(objlist, json_path, elem, base);
    end if;
    self := objlist.get_values;
  end path_put;
  
  /* json path_remove */
  member procedure path_remove(self in out nocopy json_list, json_path varchar2, base number default 1) as
    objlist json := json(self);
  begin
    json_ext.remove(objlist, json_path, base);
    self := objlist.get_values;
  end path_remove;
  

  member function to_json_value return json_value as
  begin
    return json_value(sys.anydata.convertobject(self));
  end;

  /*--backwards compatibility
  member procedure add_elem(self in out nocopy json_list, elem json_value, position pls_integer default null) as begin append(elem,position); end;
  member procedure add_elem(self in out nocopy json_list, elem varchar2, position pls_integer default null) as begin append(elem,position); end;
  member procedure add_elem(self in out nocopy json_list, elem number, position pls_integer default null) as begin append(elem,position); end;
  member procedure add_elem(self in out nocopy json_list, elem boolean, position pls_integer default null) as begin append(elem,position); end;
  member procedure add_elem(self in out nocopy json_list, elem json_list, position pls_integer default null) as begin append(elem,position); end;

  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem json_value) as begin replace(position,elem); end;
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem varchar2) as begin replace(position,elem); end;
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem number) as begin replace(position,elem); end;
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem boolean) as begin replace(position,elem); end;
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem json_list) as begin replace(position,elem); end;
  
  member procedure remove_elem(self in out nocopy json_list, position pls_integer) as begin remove(position); end;
  member function get_elem(position pls_integer) return json_value as begin return get(position); end;
  member function get_first return json_value as begin return head(); end;
  member function get_last return json_value as begin return last(); end;
--  */
 
end;
/

CREATE OR REPLACE TYPE  "JSON" force as object (
  /*
  Copyright (c) 2010 Jonas Krogsboell

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  */

  /* Variables */
  json_data json_value_array,
  check_for_duplicate number,
  
  /* Constructors */
  constructor function json return self as result,
  constructor function json(str varchar2) return self as result,
  constructor function json(str in clob) return self as result,
  constructor function json(cast json_value) return self as result,
  constructor function json(l in out nocopy json_list) return self as result,
    
  /* Member setter methods */  
  member procedure remove(pair_name varchar2),
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value json_value, position pls_integer default null),
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value varchar2, position pls_integer default null),
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value number, position pls_integer default null),
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value boolean, position pls_integer default null),
  member procedure check_duplicate(self in out nocopy json, v_set boolean),
  member procedure remove_duplicates(self in out nocopy json),

  /* deprecated putter use json_value */
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value json, position pls_integer default null),
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value json_list, position pls_integer default null),

  /* Member getter methods */ 
  member function count return number,
  member function get(pair_name varchar2) return json_value, 
  member function get(position pls_integer) return json_value,
  member function index_of(pair_name varchar2) return number,
  member function exist(pair_name varchar2) return boolean,

  /* Output methods */ 
  member function to_char(spaces boolean default true, chars_per_line number default 0) return varchar2,
  member procedure to_clob(self in json, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true),
  member procedure print(self in json, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null), --32512 is maximum
  member procedure htp(self in json, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null),
  
  member function to_json_value return json_value,
  /* json path */
  member function path(json_path varchar2, base number default 1) return json_value,

  /* json path_put */
  member procedure path_put(self in out nocopy json, json_path varchar2, elem json_value, base number default 1),
  member procedure path_put(self in out nocopy json, json_path varchar2, elem varchar2  , base number default 1),
  member procedure path_put(self in out nocopy json, json_path varchar2, elem number    , base number default 1),
  member procedure path_put(self in out nocopy json, json_path varchar2, elem boolean   , base number default 1),
  member procedure path_put(self in out nocopy json, json_path varchar2, elem json_list , base number default 1),
  member procedure path_put(self in out nocopy json, json_path varchar2, elem json      , base number default 1),

  /* json path_remove */
  member procedure path_remove(self in out nocopy json, json_path varchar2, base number default 1),

  /* map functions */
  member function get_values return json_list,
  member function get_keys return json_list

) not final;
/
CREATE OR REPLACE TYPE BODY  "JSON" as

  /* Constructors */
  constructor function json return self as result as
  begin
    self.json_data := json_value_array();
    self.check_for_duplicate := 1;
    return;
  end;

  constructor function json(str varchar2) return self as result as
  begin
    self := json_parser.parser(str);
    self.check_for_duplicate := 1;
    return;
  end;
  
  constructor function json(str in clob) return self as result as
  begin
    self := json_parser.parser(str);
    self.check_for_duplicate := 1;
    return;
  end;  

  constructor function json(cast json_value) return self as result as
    x number;
  begin
    x := cast.object_or_array.getobject(self);
    self.check_for_duplicate := 1;
    return;
  end;

  constructor function json(l in out nocopy json_list) return self as result as
  begin
    for i in 1 .. l.list_data.count loop
      if(l.list_data(i).mapname is null or l.list_data(i).mapname like 'row%') then
      l.list_data(i).mapname := 'row'||i;
      end if;
      l.list_data(i).mapindx := i;
    end loop;

    self.json_data := l.list_data;
    self.check_for_duplicate := 1;
    return;
  end;

  /* Member setter methods */  
  member procedure remove(self in out nocopy json, pair_name varchar2) as
    temp json_value;
    indx pls_integer;
    
    function get_member(pair_name varchar2) return json_value as
      indx pls_integer;
    begin
      indx := json_data.first;
      loop
        exit when indx is null;
        if(pair_name is null and json_data(indx).mapname is null) then return json_data(indx); end if;
        if(json_data(indx).mapname = pair_name) then return json_data(indx); end if;
        indx := json_data.next(indx);
      end loop;
      return null;
    end;
  begin
    temp := get_member(pair_name);
    if(temp is null) then return; end if;
    
    indx := json_data.next(temp.mapindx);
    loop 
      exit when indx is null;
      json_data(indx).mapindx := indx - 1;
      json_data(indx-1) := json_data(indx);
      indx := json_data.next(indx);
    end loop;
    json_data.trim(1);
    --num_elements := num_elements - 1;
  end;

  member procedure put(self in out nocopy json, pair_name varchar2, pair_value json_value, position pls_integer default null) as
    insert_value json_value := nvl(pair_value, json_value.makenull);
    indx pls_integer; x number;
    temp json_value;
    function get_member(pair_name varchar2) return json_value as
      indx pls_integer;
    begin
      indx := json_data.first;
      loop
        exit when indx is null;
        if(pair_name is null and json_data(indx).mapname is null) then return json_data(indx); end if;
        if(json_data(indx).mapname = pair_name) then return json_data(indx); end if;
        indx := json_data.next(indx);
      end loop;
      return null;
    end;
  begin
    --dbms_output.put_line('PN '||pair_name);

--    if(pair_name is null) then 
--      raise_application_error(-20102, 'JSON put-method type error: name cannot be null');
--    end if;
    insert_value.mapname := pair_name;
--    self.remove(pair_name);
    if(self.check_for_duplicate = 1) then temp := get_member(pair_name); else temp := null; end if;
    if(temp is not null) then
      insert_value.mapindx := temp.mapindx;
      json_data(temp.mapindx) := insert_value; 
      return;
    elsif(position is null or position > self.count) then
      --insert at the end of the list
      --dbms_output.put_line('Test');
--      indx := self.count + 1;
      json_data.extend(1);
      json_data(json_data.count) := insert_value;
--      insert_value.mapindx := json_data.count;
      json_data(json_data.count).mapindx := json_data.count;
--      dbms_output.put_line('Test2'||insert_value.mapindx);
--      dbms_output.put_line('Test2'||insert_value.mapname);
--      insert_value.print(false);
--      self.print;
    elsif(position < 2) then
      --insert at the start of the list
      indx := json_data.last;
      json_data.extend;
      loop
        exit when indx is null;
        temp := json_data(indx);
        temp.mapindx := indx+1;
        json_data(temp.mapindx) := temp;
        indx := json_data.prior(indx);
      end loop;
      json_data(1) := insert_value;
      insert_value.mapindx := 1;
    else 
      --insert somewhere in the list
      indx := json_data.last; 
--      dbms_output.put_line('Test '||indx);
      json_data.extend;
--      dbms_output.put_line('Test '||indx);
      loop
--        dbms_output.put_line('Test '||indx);
        temp := json_data(indx);
        temp.mapindx := indx + 1;
        json_data(temp.mapindx) := temp;
        exit when indx = position;
        indx := json_data.prior(indx);
      end loop;
      json_data(position) := insert_value;
      json_data(position).mapindx := position;
    end if;
--    num_elements := num_elements + 1;
  end;
  
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value varchar2, position pls_integer default null) as
  begin
    put(pair_name, json_value(pair_value), position);
  end;
  
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value number, position pls_integer default null) as
  begin
    if(pair_value is null) then
      put(pair_name, json_value(), position);
    else 
      put(pair_name, json_value(pair_value), position);
    end if;
  end;
  
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value boolean, position pls_integer default null) as
  begin
    if(pair_value is null) then
      put(pair_name, json_value(), position);
    else 
      put(pair_name, json_value(pair_value), position);
    end if;
  end;
  
  member procedure check_duplicate(self in out nocopy json, v_set boolean) as
  begin
    if(v_set) then 
      check_for_duplicate := 1;
    else 
      check_for_duplicate := 0;
    end if;
  end; 

  /* deprecated putters */
 
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value json, position pls_integer default null) as
  begin
    if(pair_value is null) then
      put(pair_name, json_value(), position);
    else 
      put(pair_name, pair_value.to_json_value, position);
    end if;
  end;

  member procedure put(self in out nocopy json, pair_name varchar2, pair_value json_list, position pls_integer default null) as
  begin
    if(pair_value is null) then
      put(pair_name, json_value(), position);
    else 
      put(pair_name, pair_value.to_json_value, position);
    end if;
  end;

  /* Member getter methods */ 
  member function count return number as
  begin
    return self.json_data.count;
  end;

  member function get(pair_name varchar2) return json_value as
    indx pls_integer;
  begin
    indx := json_data.first;
    loop
      exit when indx is null;
      if(pair_name is null and json_data(indx).mapname is null) then return json_data(indx); end if;
      if(json_data(indx).mapname = pair_name) then return json_data(indx); end if;
      indx := json_data.next(indx);
    end loop;
    return null;
  end;
  
  member function get(position pls_integer) return json_value as
  begin
    if(self.count >= position and position > 0) then
      return self.json_data(position);
    end if;
    return null; -- do not throw error, just return null
  end;
  
  member function index_of(pair_name varchar2) return number as
    indx pls_integer;
  begin
    indx := json_data.first;
    loop
      exit when indx is null;
      if(pair_name is null and json_data(indx).mapname is null) then return indx; end if;
      if(json_data(indx).mapname = pair_name) then return indx; end if;
      indx := json_data.next(indx);
    end loop;
    return -1;
  end;

  member function exist(pair_name varchar2) return boolean as
  begin
    return (self.get(pair_name) is not null);
  end;
  
  /* Output methods */  
  member function to_char(spaces boolean default true, chars_per_line number default 0) return varchar2 as
  begin
    if(spaces is null) then
      return json_printer.pretty_print(self, line_length => chars_per_line);
    else 
      return json_printer.pretty_print(self, spaces, line_length => chars_per_line);
    end if;
  end;

  member procedure to_clob(self in json, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true) as
  begin
    if(spaces is null) then	
      json_printer.pretty_print(self, false, buf, line_length => chars_per_line, erase_clob => erase_clob);
    else 
      json_printer.pretty_print(self, spaces, buf, line_length => chars_per_line, erase_clob => erase_clob);
    end if;
  end;

  member procedure print(self in json, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null) as --32512 is the real maximum in sqldeveloper
    my_clob clob;
  begin
    my_clob := empty_clob();
    dbms_lob.createtemporary(my_clob, true);
    json_printer.pretty_print(self, spaces, my_clob, case when (chars_per_line>32512) then 32512 else chars_per_line end);
    json_printer.dbms_output_clob(my_clob, json_printer.newline_char, jsonp);
    dbms_lob.freetemporary(my_clob);  
  end;
  
  member procedure htp(self in json, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null) as 
    my_clob clob;
  begin
    my_clob := empty_clob();
    dbms_lob.createtemporary(my_clob, true);
    json_printer.pretty_print(self, spaces, my_clob, chars_per_line);
    json_printer.htp_output_clob(my_clob, jsonp);
    dbms_lob.freetemporary(my_clob);  
  end;

  member function to_json_value return json_value as
  begin
    return json_value(sys.anydata.convertobject(self));
  end;

  /* json path */
  member function path(json_path varchar2, base number default 1) return json_value as
  begin
    return json_ext.get_json_value(self, json_path, base);
  end path;

  /* json path_put */
  member procedure path_put(self in out nocopy json, json_path varchar2, elem json_value, base number default 1) as
  begin
    json_ext.put(self, json_path, elem, base);
  end path_put;
  
  member procedure path_put(self in out nocopy json, json_path varchar2, elem varchar2, base number default 1) as
  begin
    json_ext.put(self, json_path, elem, base);
  end path_put;
  
  member procedure path_put(self in out nocopy json, json_path varchar2, elem number, base number default 1) as
  begin
    if(elem is null) then 
      json_ext.put(self, json_path, json_value(), base);
    else 
      json_ext.put(self, json_path, elem, base);
    end if;
  end path_put;

  member procedure path_put(self in out nocopy json, json_path varchar2, elem boolean, base number default 1) as
  begin
    if(elem is null) then 
      json_ext.put(self, json_path, json_value(), base);
    else 
      json_ext.put(self, json_path, elem, base);
    end if;
  end path_put;

  member procedure path_put(self in out nocopy json, json_path varchar2, elem json_list, base number default 1) as
  begin
    if(elem is null) then 
      json_ext.put(self, json_path, json_value(), base);
    else 
      json_ext.put(self, json_path, elem, base);
    end if;
  end path_put;

  member procedure path_put(self in out nocopy json, json_path varchar2, elem json, base number default 1) as
  begin
    if(elem is null) then 
      json_ext.put(self, json_path, json_value(), base);
    else 
      json_ext.put(self, json_path, elem, base);
    end if;
  end path_put;
  
  member procedure path_remove(self in out nocopy json, json_path varchar2, base number default 1) as
  begin 
    json_ext.remove(self, json_path, base);
  end path_remove;

  /* Thanks to Matt Nolan */
  member function get_keys return json_list as
    keys json_list;
    indx pls_integer;
  begin
    keys := json_list();
    indx := json_data.first;
    loop
      exit when indx is null;
      keys.append(json_data(indx).mapname);
      indx := json_data.next(indx);
    end loop;
    return keys;
  end;
  
  member function get_values return json_list as
    vals json_list := json_list();
  begin
    vals.list_data := self.json_data;
    return vals;
  end;
  
  member procedure remove_duplicates(self in out nocopy json) as
  begin
    json_parser.remove_duplicates(self);
  end remove_duplicates;


end;
/

