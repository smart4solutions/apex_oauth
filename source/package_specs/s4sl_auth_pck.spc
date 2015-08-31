create or replace package s4sl_auth_pck is
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

gc_revision constant varchar2(100) := 'Revision: 0.1 (build: 20150831221339)';

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

