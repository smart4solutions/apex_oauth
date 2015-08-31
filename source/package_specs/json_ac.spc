create or replace package json_ac as
  --json type methods

  procedure object_remove(p_self in out nocopy json, pair_name varchar2);
  procedure object_put(p_self in out nocopy json, pair_name varchar2, pair_value json_value, position pls_integer default null);
  procedure object_put(p_self in out nocopy json, pair_name varchar2, pair_value varchar2, position pls_integer default null);
  procedure object_put(p_self in out nocopy json, pair_name varchar2, pair_value number, position pls_integer default null);
  procedure object_put(p_self in out nocopy json, pair_name varchar2, pair_value boolean, position pls_integer default null);
  procedure object_check_duplicate(p_self in out nocopy json, v_set boolean);
  procedure object_remove_duplicates(p_self in out nocopy json);

  procedure object_put(p_self in out nocopy json, pair_name varchar2, pair_value json, position pls_integer default null);
  procedure object_put(p_self in out nocopy json, pair_name varchar2, pair_value json_list, position pls_integer default null);

  function object_count(p_self in json) return number;
  function object_get(p_self in json, pair_name varchar2) return json_value;
  function object_get(p_self in json, position pls_integer) return json_value;
  function object_index_of(p_self in json, pair_name varchar2) return number;
  function object_exist(p_self in json, pair_name varchar2) return boolean;

  function object_to_char(p_self in json, spaces boolean default true, chars_per_line number default 0) return varchar2;
  procedure object_to_clob(p_self in json, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true);
  procedure object_print(p_self in json, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null);
  procedure object_htp(p_self in json, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null);

  function object_to_json_value(p_self in json) return json_value;
  function object_path(p_self in json, json_path varchar2, base number default 1) return json_value;

  procedure object_path_put(p_self in out nocopy json, json_path varchar2, elem json_value, base number default 1);
  procedure object_path_put(p_self in out nocopy json, json_path varchar2, elem varchar2  , base number default 1);
  procedure object_path_put(p_self in out nocopy json, json_path varchar2, elem number    , base number default 1);
  procedure object_path_put(p_self in out nocopy json, json_path varchar2, elem boolean   , base number default 1);
  procedure object_path_put(p_self in out nocopy json, json_path varchar2, elem json_list , base number default 1);
  procedure object_path_put(p_self in out nocopy json, json_path varchar2, elem json      , base number default 1);

  procedure object_path_remove(p_self in out nocopy json, json_path varchar2, base number default 1);

  function object_get_values(p_self in json) return json_list;
  function object_get_keys(p_self in json) return json_list;

  --json_list type methods
  procedure array_append(p_self in out nocopy json_list, elem json_value, position pls_integer default null);
  procedure array_append(p_self in out nocopy json_list, elem varchar2, position pls_integer default null);
  procedure array_append(p_self in out nocopy json_list, elem number, position pls_integer default null);
  procedure array_append(p_self in out nocopy json_list, elem boolean, position pls_integer default null);
  procedure array_append(p_self in out nocopy json_list, elem json_list, position pls_integer default null);

  procedure array_replace(p_self in out nocopy json_list, position pls_integer, elem json_value);
  procedure array_replace(p_self in out nocopy json_list, position pls_integer, elem varchar2);
  procedure array_replace(p_self in out nocopy json_list, position pls_integer, elem number);
  procedure array_replace(p_self in out nocopy json_list, position pls_integer, elem boolean);
  procedure array_replace(p_self in out nocopy json_list, position pls_integer, elem json_list);

  function array_count(p_self in json_list) return number;
  procedure array_remove(p_self in out nocopy json_list, position pls_integer);
  procedure array_remove_first(p_self in out nocopy json_list);
  procedure array_remove_last(p_self in out nocopy json_list);
  function array_get(p_self in json_list, position pls_integer) return json_value;
  function array_head(p_self in json_list) return json_value;
  function array_last(p_self in json_list) return json_value;
  function array_tail(p_self in json_list) return json_list;

  function array_to_char(p_self in json_list, spaces boolean default true, chars_per_line number default 0) return varchar2;
  procedure array_to_clob(p_self in json_list, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true);
  procedure array_print(p_self in json_list, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null);
  procedure array_htp(p_self in json_list, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null);

  function array_path(p_self in json_list, json_path varchar2, base number default 1) return json_value;
  procedure array_path_put(p_self in out nocopy json_list, json_path varchar2, elem json_value, base number default 1);
  procedure array_path_put(p_self in out nocopy json_list, json_path varchar2, elem varchar2  , base number default 1);
  procedure array_path_put(p_self in out nocopy json_list, json_path varchar2, elem number    , base number default 1);
  procedure array_path_put(p_self in out nocopy json_list, json_path varchar2, elem boolean   , base number default 1);
  procedure array_path_put(p_self in out nocopy json_list, json_path varchar2, elem json_list , base number default 1);

  procedure array_path_remove(p_self in out nocopy json_list, json_path varchar2, base number default 1);

  function array_to_json_value(p_self in json_list) return json_value;

  --json_value


  function jv_get_type(p_self in json_value) return varchar2;
  function jv_get_string(p_self in json_value, max_byte_size number default null, max_char_size number default null) return varchar2;
  procedure jv_get_string(p_self in json_value, buf in out nocopy clob);
  function jv_get_number(p_self in json_value) return number;
  function jv_get_bool(p_self in json_value) return boolean;
  function jv_get_null(p_self in json_value) return varchar2;

  function jv_is_object(p_self in json_value) return boolean;
  function jv_is_array(p_self in json_value) return boolean;
  function jv_is_string(p_self in json_value) return boolean;
  function jv_is_number(p_self in json_value) return boolean;
  function jv_is_bool(p_self in json_value) return boolean;
  function jv_is_null(p_self in json_value) return boolean;

  function jv_to_char(p_self in json_value, spaces boolean default true, chars_per_line number default 0) return varchar2;
  procedure jv_to_clob(p_self in json_value, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true);
  procedure jv_print(p_self in json_value, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null);
  procedure jv_htp(p_self in json_value, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null);

  function jv_value_of(p_self in json_value, max_byte_size number default null, max_char_size number default null) return varchar2;


end json_ac;
/

