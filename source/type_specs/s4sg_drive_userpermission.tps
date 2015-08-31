create or replace type s4sg_drive_userpermission force as object
(
/*                           __
                         _.-~  )
              _..--~~~~,'   ,-/     _    _____ __  __          _____ _______
           .-'. . . .'   ,-','    ,' )  / ____|  \/  |   /\   |  __ \__   __|
         ,'. . . _   ,--~,-'__..-'  ,' | (___ | \  / |  /  \  | |__) | | |
       ,'. . .  (@)' ---~~~~      ,'    \___ \| |\/| | / /\ \ |  _  /  | |
      /. . . . '~~             ,-'      ____) | |  | |/ ____ \| | \ \  | |
     /. . . . .             ,-'    _  _|_____/|_|  |_/_/ _  \_\_|_ \_\ |_|
    ; . . . .  - .        ,'      | || |           | |     | | (_)
   : . . . .       _     /        | || |_ ___  ___ | |_   _| |_ _  ___  _ __  ___
  . . . . .          `-.:         |__   _/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
 . . . ./  - .          )            | | \__ \ (_) | | |_| | |_| | (_) | | | \__ \
.  . . |  _____..---.._/             |_| |___/\___/|_|\__,_|\__|_|\___/|_| |_|___/
-~~----~~~~             ~---~~~~--~~~--~~~---~---~---~~~~----~~~~~---~~~--~~~---~~~---
--
--    NAME
--      s4sg_drive_userpermission
--
--    DESCRIPTION
--
--    Revision: 0.1 (build: 20150831221339)
--
--    MODIFIED   (DD-MM-YYYY)
--    RICHARD MARTENS   10-6-2015  - Created
--    RICHARD MARTENS   31-8-2015  - Added Revision
--------------------------------------------------------------------------------
*/
  -- Attributes
  kind            varchar2(255),
  etag            varchar2(255),
  id              varchar2(255),
  selfLink        varchar2(255),
  role            varchar2(255),
  permission_type varchar2(255),

  -- Member functions and procedures
  constructor function s4sg_drive_userpermission return self as result,

  constructor function s4sg_drive_userpermission
    ( p_json in json
    ) return self as result
)
/

