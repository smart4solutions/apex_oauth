create or replace type body s4sg_drive_label is

constructor function s4sg_drive_label return self as result
is
begin
  return;
end s4sg_drive_label;

constructor function s4sg_drive_label
  ( p_json in json
  ) return self as result
is
begin

  self.starred     := s4sa_oauth_pck.boolconvert( json_ext.get_bool(p_json, 'starred')    );
  self.hidden      := s4sa_oauth_pck.boolconvert( json_ext.get_bool(p_json, 'hidden')     );
  self.trashed     := s4sa_oauth_pck.boolconvert( json_ext.get_bool(p_json, 'trashed')    );
  self.restricted  := s4sa_oauth_pck.boolconvert( json_ext.get_bool(p_json, 'restricted') );
  self.viewed      := s4sa_oauth_pck.boolconvert( json_ext.get_bool(p_json, 'viewed')     );

  return;
end s4sg_drive_label;

end;
/

