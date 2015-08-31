create or replace package body s4sg_drive_pck is

  g_folder_id   varchar2(255);
  g_oauth_token s4sa_oauth_pck.token_type;

function g_collname$ return apex_collections.collection_name%type
is
begin
  return g_collname;
end;

function set_drive_search
  ( p_folder_id   in varchar2
  , p_oauth_token in s4sa_oauth_pck.token_type
  ) return number
is
begin
  g_folder_id   := nvl(p_folder_id, 'root');
  g_oauth_token := p_oauth_token;
  return 1;
end set_drive_search;

/*****************************************************************************/
function file_list
  ( p_oauth_token in s4sa_oauth_pck.token_type default null
  , p_folder_id   in varchar2                  default null
  ) return s4sg_drive_file_list pipelined
is
  t_token     s4sa_oauth_pck.token_type := coalesce(p_oauth_token, g_oauth_token, s4sa_oauth_pck.oauth_token('GOOGLE'));
  t_folder_id varchar2(255)             := coalesce(p_folder_id, g_folder_id, 'root');
  t_uri       s4sa_oauth_pck.uri_type   := s4sa_oauth_pck.g_settings.api_prefix || 'www.googleapis.com/drive/v2/files';
  t_response  s4sa_oauth_pck.response_type;
  t_retval    s4sg_drive_file;
  j_list      json_list;
  --t_itemcount pls_integer;
begin

  if t_token is null then
    return;
  end if;

  t_response := s4sg_auth_pck.do_request
                ( p_api_uri => t_uri || '?q=' || apex_util.url_encode('''' || t_folder_id || ''' in parents and trashed = false')
                , p_method  => 'GET'
                , p_token   => t_token);

  s4sa_oauth_pck.check_for_error(t_response);

  j_list := json_ext.get_json_list
            ( obj  => json(t_response)
            , path => 'items'
            );
  --t_itemcount := j_list.count;

  for ii in 1..j_list.count loop
    t_retval := new s4sg_drive_file(p_json => json( j_list.get(ii) ));
    pipe row (t_retval);
  end loop;

  return;

end file_list;

procedure set_current_folder
  ( p_folder_id in varchar2
  , p_folder_name in varchar2)
is
  cursor c_stack
    is  (select ac.c001   as folder_id
         ,      ac.c002   as folder_name
         ,      ac.seq_id as seq_id
         from   apex_collections ac
         where  ac.collection_name = g_collname);
  type r_stack_type is table of c_stack%rowtype index by pls_integer;
  t_stack     r_stack_type;
  ii          pls_integer;
  t_folder_id varchar2(255) := coalesce(p_folder_id, 'root');
begin

  if apex_collection.collection_exists(p_collection_name => g_collname) then

    open c_stack;
    fetch c_stack bulk collect into t_stack;
    close c_stack;

    for ii in 1.. t_stack.count loop
      if t_stack(ii).folder_id = t_folder_id then
        for jj in ii..t_stack.count loop
          apex_collection.delete_member(p_collection_name => g_collname, p_seq => t_stack(jj).seq_id);
        end loop;
        exit;
      end if;
    end loop;

  else
    apex_collection.create_or_truncate_collection(g_collname);

  end if;

  apex_collection.add_member( p_collection_name => g_collname
                              , p_c001 => t_folder_id
                              , p_c002 => p_folder_name);

end set_current_folder;

end s4sg_drive_pck;
/

