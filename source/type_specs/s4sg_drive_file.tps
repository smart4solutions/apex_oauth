create or replace type s4sg_drive_file force as object
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
--      s4sg_drive_file
--
--    DESCRIPTION
--
--    Revision: 0.1 (build: 20150831221339)
--
--    MODIFIED   (DD-MM-YYYY)
--    RICHARD MARTENS   10-6-2015  - Created
--    RICHARD MARTENS   31-8-2015 - Added Revision
--------------------------------------------------------------------------------
*/

  -- Attributes
  kind                    varchar2(255),
  id                      varchar2(255),
  etag                    varchar2(255),
  selfLink                varchar2(255),
  alternateLink           varchar2(255),
  embedLink               varchar2(255),
  iconLink                varchar2(255),
  thumbnailLink           varchar2(255),
  title                   varchar2(255),
  mimeType                varchar2(255),
  labels                  s4sg_drive_label,
  createdDate             timestamp,
  modifiedDate            timestamp,
  modifiedByMeDate        timestamp,
  lastViewedByMeDate      timestamp,
  markedViewedByMeDate    timestamp,
  version                 varchar2(255),
  parents                 s4sg_drive_file_parent_list,
  exportLinks             s4sg_drive_export_link,
  userPermission          s4sg_drive_userpermission,
  quotaBytes_used         varchar2(255),
  owners                  s4sg_drive_user_list,
  lastModifyingUserName   varchar2(255),
  lastModifyingUser       s4sg_drive_user,
  editable                char(1),
  copyable                char(1),
  writersCanShare         char(1),
  shared                  char(1),
  appDataContents         char(1),
  filecontents            blob,


  -- Member functions and procedures
  constructor function s4sg_drive_file return self as result,

  constructor function s4sg_drive_file
    ( p_json in json
    ) return self as result,

  constructor function s4sg_drive_file
    ( p_file_id in varchar2
    ) return self as result
)
/

