create or replace package s4sa_oauth_pck is
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

gc_revision constant varchar2(100) := 'Revision: 0.1 (build: 20150831221339)';

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

end s4sa_oauth_pck;
/

