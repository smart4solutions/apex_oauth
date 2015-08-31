create or replace package body s4sa_oauth_pck as

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

