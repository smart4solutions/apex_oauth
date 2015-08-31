create or replace type body s4sg_drive_file is

constructor function s4sg_drive_file return self as result
is
begin
  return;
end s4sg_drive_file;

constructor function s4sg_drive_file
  ( p_json in json
  ) return self as result
is
begin

  self.kind                    := json_ext.get_string(p_json, 'kind');                                       -- varchar2(100),
  self.id                      := json_ext.get_string(p_json, 'id');                                         -- varchar2(100),
  self.etag                    := json_ext.get_string(p_json, 'etag');                                       -- varchar2(100),
  self.selfLink                := json_ext.get_string(p_json, 'selfLink');                                   -- varchar2(100),
  self.alternateLink           := json_ext.get_string(p_json, 'alternateLink');                              -- varchar2(100),
  self.embedLink               := json_ext.get_string(p_json, 'embedLink');                                  -- varchar2(100),
  self.iconLink                := json_ext.get_string(p_json, 'iconLink');                                   -- varchar2(100),
  self.thumbnailLink           := json_ext.get_string(p_json, 'thumbnailLink');                              -- varchar2(100),
  self.title                   := json_ext.get_string(p_json, 'title');                                      -- varchar2(100),
  self.mimeType                := json_ext.get_string(p_json, 'mimeType');                                   -- varchar2(100),

  self.labels                  := new s4sg_drive_label( p_json => json_ext.get_json(p_json, 'labels' ));

  self.createdDate             := s4sa_oauth_pck.to_ts(json_ext.get_string(p_json, 'createdDate'));          -- timestamp,
  self.modifiedDate            := s4sa_oauth_pck.to_ts(json_ext.get_string(p_json, 'modifiedDate'));         -- timestamp,
  self.modifiedByMeDate        := s4sa_oauth_pck.to_ts(json_ext.get_string(p_json, 'modifiedByMeDate'));     -- timestamp,
  self.lastViewedByMeDate      := s4sa_oauth_pck.to_ts(json_ext.get_string(p_json, 'lastViewedByMeDate'));   -- timestamp,
  self.markedViewedByMeDate    := s4sa_oauth_pck.to_ts(json_ext.get_string(p_json, 'markedViewedByMeDate')); -- timestamp,
  self.version                 := json_ext.get_string(p_json, 'version');                                    -- varchar2(100),

--  parents                      := new s4sg_drive_file_parent_list(p_json => json_ext.get_json(l_json, 'parents'       ));
  exportLinks                  := new s4sg_drive_export_link( p_json => json_ext.get_json(p_json, 'exportLinks' ));
  userPermission               := new s4sg_drive_userpermission( p_json => json_ext.get_json(p_json, 'userPermission' ));

  self.quotaBytes_used         := json_ext.get_string(p_json, 'quotaBytes_used');                            -- varchar2(100),

--  owners                       := new s4sg_drive_user_list(       p_json => json_ext.get_json(l_json, 'owners'        ));

  self.lastModifyingUserName   := json_ext.get_string(p_json, 'lastModifyingUserName');                      -- varchar2(100),

  lastModifyingUser            := new s4sg_drive_user( p_json => json_ext.get_json(p_json, 'lastModifyingUser' ));

  self.editable                := s4sa_oauth_pck.boolconvert(json_ext.get_bool(p_json, 'editable'));         -- char(1),
  self.copyable                := s4sa_oauth_pck.boolconvert(json_ext.get_bool(p_json, 'copyable'));         -- char(1),
  self.writersCanShare         := s4sa_oauth_pck.boolconvert(json_ext.get_bool(p_json, 'writersCanShare'));  -- char(1),
  self.shared                  := s4sa_oauth_pck.boolconvert(json_ext.get_bool(p_json, 'shared'));           -- char(1),
  self.appDataContents         := s4sa_oauth_pck.boolconvert(json_ext.get_bool(p_json, 'appDataContents'));  -- char(1),

  return;
end s4sg_drive_file;

constructor function s4sg_drive_file
  ( p_file_id in varchar2
  ) return self as result
is
  t_resp json;
begin
  t_resp := json( s4sg_auth_pck.do_request
                    ( p_api_uri => s4sa_oauth_pck.g_settings.api_prefix || 'www.googleapis.com/drive/v2/files/' || p_file_id
                    , p_method  => 'GET'));

  s4sa_oauth_pck.check_for_error(t_resp);

  self := s4sg_drive_file( p_json => t_resp );

  return;

end;

end;
/

