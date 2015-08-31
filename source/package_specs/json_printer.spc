create or replace package json_printer as
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

