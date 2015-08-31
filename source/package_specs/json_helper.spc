create or replace package json_helper as
  /* Example:
  set serveroutput on;
  declare
    v_a json;
    v_b json;
  begin
    v_a := json('{a:1, b:{a:null}, e:false}');
    v_b := json('{c:3, e:{}, b:{b:2}}');
    json_helper.merge(v_a, v_b).print(false);
  end;
  --
  {"a":1,"b":{"a":null,"b":2},"e":{},"c":3}
  */
  -- Recursive merge
  -- Courtesy of Matt Nolan - edited by Jonas Krogsb¿ll
  function merge( p_a_json json, p_b_json json) return json;

  -- Join two lists
  -- json_helper.join(json_list('[1,2,3]'),json_list('[4,5,6]')) -> [1,2,3,4,5,6]
  function join( p_a_list json_list, p_b_list json_list) return json_list;

  -- keep only specific keys in json object
  -- json_helper.keep(json('{a:1,b:2,c:3,d:4,e:5,f:6}'),json_list('["a","f","c"]')) -> {"a":1,"f":6,"c":3}
  function keep( p_json json, p_keys json_list) return json;

  -- remove specific keys in json object
  -- json_helper.remove(json('{a:1,b:2,c:3,d:4,e:5,f:6}'),json_list('["a","f","c"]')) -> {"b":2,"d":4,"e":5}
  function remove( p_json json, p_keys json_list) return json;

  --equals
  function equals(p_v1 json_value, p_v2 json_value, exact boolean default true) return boolean;
  function equals(p_v1 json_value, p_v2 json, exact boolean default true) return boolean;
  function equals(p_v1 json_value, p_v2 json_list, exact boolean default true) return boolean;
  function equals(p_v1 json_value, p_v2 number) return boolean;
  function equals(p_v1 json_value, p_v2 varchar2) return boolean;
  function equals(p_v1 json_value, p_v2 boolean) return boolean;
  function equals(p_v1 json_value, p_v2 clob) return boolean;
  function equals(p_v1 json, p_v2 json, exact boolean default true) return boolean;
  function equals(p_v1 json_list, p_v2 json_list, exact boolean default true) return boolean;

  --contains json, json_value
  --contains json_list, json_value
  function contains(p_v1 json, p_v2 json_value, exact boolean default false) return boolean;
  function contains(p_v1 json, p_v2 json, exact boolean default false) return boolean;
  function contains(p_v1 json, p_v2 json_list, exact boolean default false) return boolean;
  function contains(p_v1 json, p_v2 number, exact boolean default false) return boolean;
  function contains(p_v1 json, p_v2 varchar2, exact boolean default false) return boolean;
  function contains(p_v1 json, p_v2 boolean, exact boolean default false) return boolean;
  function contains(p_v1 json, p_v2 clob, exact boolean default false) return boolean;

  function contains(p_v1 json_list, p_v2 json_value, exact boolean default false) return boolean;
  function contains(p_v1 json_list, p_v2 json, exact boolean default false) return boolean;
  function contains(p_v1 json_list, p_v2 json_list, exact boolean default false) return boolean;
  function contains(p_v1 json_list, p_v2 number, exact boolean default false) return boolean;
  function contains(p_v1 json_list, p_v2 varchar2, exact boolean default false) return boolean;
  function contains(p_v1 json_list, p_v2 boolean, exact boolean default false) return boolean;
  function contains(p_v1 json_list, p_v2 clob, exact boolean default false) return boolean;

end json_helper;
/

