#!/usr/bin/dash

 initTimezonesHeredoc ()
{
  if [ "$SHELL_SUPPORT_TYPESET" -eq 1 ]; then
     #shellcheck disable=SC3044
     typeset n  
  else
    local n
  fi
  #zsh read -A assigns to array, #bash -a assigns to array ?! -> do a while loop over heredoc
  #https://stackoverflow.com/questions/2337616/can-i-read-line-from-a-heredoc-in-bash
  #echo "(UTC-12:00)International Date Line West", "(UTC-11:00)Samoa", "(UTC-11:00)Coordinated Universal Time-11", "(UTC-10:00)Aleutian Islands", "(UTC-10:00)Hawaii", "(UTC-09:30)Marquesas Islands", "(UTC-09:00)Alaska", "(UTC-09:00)Coordinated Universal Time-9", "(UTC-08:00)Pacific Time (US & Canada)", "(UTC-08:00)Baja California", "(UTC-08:00)Coordinated Universal Time-8", "(UTC-07:00)Chihuahua,La Paz,Mazatlan", "(UTC-07:00)Mountain Time (US & Canada)", "(UTC-07:00)Arizona", "(UTC-06:00)Guadalajara,Mexico City,Monterrey", "(UTC-06:00)Saskatchewan", "(UTC-06:00)Central Time (US & Canada)", "(UTC-06:00)Central America", "(UTC-05:00)Bogota,Lima,Quito", "(UTC-05:00)Eastern Time (US & Canada)", "(UTC-05:00)Havana", "(UTC-05:00)Hayti", "(UTC-05:00)Chetumal", "(UTC-05:00)Indiana (East)", "(UTC-04:30)Caracas", "(UTC-04:00)Atlantic Time (Canada)", "(UTC-04:00)Cuiaba", "(UTC-04:00)Georgetown,La Paz,Manaus,San Juan", "(UTC-04:00)Santiago", "(UTC-04:00)Asuncion", "(UTC-03:30)Newfoundland", "(UTC-03:00)Brasilia", "(UTC-03:00)Buenos Aires", "(UTC-03:00)Greenland", "(UTC-03:00)Cayenne,Fortaleza", "(UTC-03:00)Montevideo", "(UTC-02:00)Coordinated Universal Time-02", "(UTC-01:00)Cape Verde Is.", "(UTC-01:00)Azores", "(UTC)Dublin,Edinburgh,Lisbon,London", "(UTC)Casablanca", "(UTC)Monrovia,Reykjavik", "(UTC)Coordinated Universal Time", "(UTC+01:00)Amsterdam,Berlin,Bern,Rome,Stockholm,Vienna", "(UTC+01:00)Belgrade,Bratislava,Budapest,Ljubljana,Prague", "(UTC+01:00)Brussels,Copenhagen,Madrid,Paris", "(UTC+01:00)Sarajevo,Skopje,Warsaw,Zagreb", "(UTC+01:00)Windhoek", "(UTC+01:00)West Central Africa", "(UTC+02:00)Amman", "(UTC+02:00)Beirut", "(UTC+02:00)Damascus", "(UTC+02:00)Harare,Pretoria", "(UTC+02:00)Helsinki,Kyiv,Riga,Sofia,Talinn,Vilnius", "(UTC+02:00)Cairo", "(UTC+02:00)Athens,Bucharest,Istanbul", "(UTC+02:00)Jerusalem", "(UTC+03:00)Baghdad", "(UTC+03:00)Kuwait,Riyadh", "(UTC+03:00)Minsk", "(UTC+03:00)Moscow,St.Petersburg,Volgograd", "(UTC+03:00)Nairobi", "(UTC+03:30)Tehran", "(UTC+04:00)Abu Dhabi,Muscat", "(UTC+04:00)Yerevan", "(UTC+04:00)Baku", "(UTC+04:00)Tbilisi", "(UTC+04:00)Port Louis", "(UTC+04:30)Kabul", "(UTC+05:00)Tashkent", "(UTC+05:00)Ekaterinburg", "(UTC+05:00)Islamabad,Karachi", "(UTC+05:30)Chennai,Kolkata,Mumbai,New Delhi", "(UTC+05:30)Sri Jayawardenepura", "(UTC+05:45)Kathmandu", "(UTC+06:00)Astana", "(UTC+06:00)Dhaka", "(UTC+06:00)Novosibirsk", "(UTC+06:30)Yangon (Rangoon)", "(UTC+07:00)Kobdo", "(UTC+07:00)Krasnoyarsk", "(UTC+07:00)Bangkok,Hanoi,Jakarta", "(UTC+08:00)Beijing,Chongqing,Hong Kong,Urumqi", "(UTC+08:00)Kuala Lumpur,Singapore", "(UTC+08:00)Perth", "(UTC+08:00)Taipei", "(UTC+08:00)Ulaanbaatar", "(UTC+08:00)Irkutsk", "(UTC+09:00)Pyongyang", "(UTC+09:00)Osaka,Sapporo,Tokyo", "(UTC+09:00)Seoul", "(UTC+09:00)Yakutsk", "(UTC+09:30)Adelaide", "(UTC+09:30)Darwin", "(UTC+10:00)Brisbane", "(UTC+10:00)Vladivostok", "(UTC+10:00)Guam,Port Moresby", "(UTC+10:00)Hobart", "(UTC+10:00)Canberra,Melbourne,Sydney", "(UTC+10:30)Lord Howe Island", "(UTC+11:00)Magadan", "(UTC+11:00)Solomon Is.,New Caledonia", "(UTC+12:00)Auckland,Wellington", "(UTC+12:00)Fiji", "(UTC+12:00)Coordinated Universal Time+12", "(UTC+12:45)Chatham Islands", "(UTC+13:00)Nuku'alofa", "(UTC+14:00)Christmas Island" | cut -d ',' -f 1- --output-delimiter=$'\n'
#Based on decompiled /WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/Fragment/SystemFragment.java
    n=0
    while read  -r line; do
        eval "SYSTEM_TIMEZONE_$n='$line'"
        n=$(( n + 1 ))
    done <<EOF
(UTC-12:00) International Date Line West
(UTC-11:00) Samoa
(UTC-11:00) Coordinated Universal Time-11
(UTC-10:00) Aleutian Islands
(UTC-10:00) Hawaii
(UTC-09:30) Marquesas Islands
(UTC-09:00) Alaska
(UTC-09:00) Coordinated Universal Time-9
(UTC-08:00) Pacific Time (US & Canada)
(UTC-08:00) Baja California
(UTC-08:00) Coordinated Universal Time-8
(UTC-07:00) Chihuahua, La Paz, Mazatlan
(UTC-07:00) Mountain Time (US & Canada)
(UTC-07:00) Arizona
(UTC-06:00) Guadalajara, Mexico City,Monterrey
(UTC-06:00) Saskatchewan
(UTC-06:00) Central Time (US & Canada)
(UTC-06:00) Central America
(UTC-05:00) Bogota, Lima, Quito
(UTC-05:00) Eastern Time (US & Canada)
(UTC-05:00) Havana
(UTC-05:00) Hayti
(UTC-05:00) Chetumal
(UTC-05:00) Indiana (East)
(UTC-04:30) Caracas
(UTC-04:00) Atlantic Time (Canada)
(UTC-04:00) Cuiaba
(UTC-04:00) Georgetown, La Paz, Manaus, San Juan
(UTC-04:00) Santiago
(UTC-04:00) Asuncion
(UTC-03:30) Newfoundland
(UTC-03:00) Brasilia
(UTC-03:00) Buenos Aires
(UTC-03:00) Greenland
(UTC-03:00) Cayenne, Fortaleza
(UTC-03:00) Montevideo
(UTC-02:00) Coordinated Universal Time-02
(UTC-01:00) Cape Verde Is.
(UTC-01:00) Azores
(UTC) Dublin, Edinburgh, Lisbon, London
(UTC) Casablanca
(UTC) Monrovia, Reykjavik
(UTC) Coordinated Universal Time
(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna
(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague
(UTC+01:00) Brussels, Copenhagen, Madrid, Paris
(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb
(UTC+01:00) Windhoek
(UTC+01:00) West Central Africa
(UTC+02:00) Amman
(UTC+02:00) Beirut
(UTC+02:00) Damascus
(UTC+02:00) Harare, Pretoria
(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Talinn, Vilnius
(UTC+02:00) Cairo
(UTC+02:00) Athens, Bucharest, Istanbul
(UTC+02:00) Jerusalem
(UTC+03:00) Baghdad
(UTC+03:00) Kuwait, Riyadh
(UTC+03:00) Minsk
(UTC+03:00) Moscow, St.Petersburg, Volgograd
(UTC+03:00) Nairobi
(UTC+03:30) Tehran
(UTC+04:00) Abu Dhabi, Muscat
(UTC+04:00) Yerevan
(UTC+04:00) Baku
(UTC+04:00) Tbilisi
(UTC+04:00) Port Louis
(UTC+04:30) Kabul
(UTC+05:00) Tashkent
(UTC+05:00) Ekaterinburg
(UTC+05:00) Islamabad, Karachi
(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi
(UTC+05:30) Sri Jayawardenepura
(UTC+05:45) Kathmandu
(UTC+06:00) Astana
(UTC+06:00) Dhaka
(UTC+06:00) Novosibirsk
(UTC+06:30) Yangon (Rangoon)
(UTC+07:00) Kobdo
(UTC+07:00) Krasnoyarsk
(UTC+07:00) Bangkok, Hanoi, Jakarta
(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi
(UTC+08:00) Kuala Lumpur, Singapore
(UTC+08:00) Perth
(UTC+08:00) Taipei
(UTC+08:00) Ulaanbaatar
(UTC+08:00) Irkutsk
(UTC+09:00) Pyongyang
(UTC+09:00) Osaka, Sapporo, Tokyo
(UTC+09:00) Seoul
(UTC+09:00) Yakutsk
(UTC+09:30) Adelaide
(UTC+09:30) Darwin
(UTC+10:00) Brisbane
(UTC+10:00) Vladivostok
(UTC+10:00) GuamPort Moresby
(UTC+10:00) Hobart
(UTC+10:00) Canberra, Melbourne, Sydney
(UTC+10:30) Lord Howe Island
(UTC+11:00) Magadan
(UTC+11:00) Solomon Is., New Caledonia
(UTC+12:00) Auckland, Wellington
(UTC+12:00) Fiji
(UTC+12:00) Coordinated Universal Time+12
(UTC+12:45) Chatham Islands
(UTC+13:00) Nukualofa
(UTC+14:00) Christmas Island
EOF
}

initTimezonesVar ()
{
  #dash: read only 1 byte each time from pipe/here document, not entire line
  #bash: creates /tmp/sh-thd file
  #tool: strace -f dash -c "./gw -h 192.168.3.80 -c system &>strace-log"
 # if [ "$SHELL_SUPPORT_TYPESET" -eq 1 ]; then
     #shellcheck disable=SC3044
 #    typeset n  
 # else
 #   local n
 # fi
  #zsh read -A assigns to array, #bash -a assigns to array ?! -> do a while loop over heredoc
  #https://stackoverflow.com/questions/2337616/can-i-read-line-from-a-heredoc-in-bash
  #echo "(UTC-12:00)International Date Line West", "(UTC-11:00)Samoa", "(UTC-11:00)Coordinated Universal Time-11", "(UTC-10:00)Aleutian Islands", "(UTC-10:00)Hawaii", "(UTC-09:30)Marquesas Islands", "(UTC-09:00)Alaska", "(UTC-09:00)Coordinated Universal Time-9", "(UTC-08:00)Pacific Time (US & Canada)", "(UTC-08:00)Baja California", "(UTC-08:00)Coordinated Universal Time-8", "(UTC-07:00)Chihuahua,La Paz,Mazatlan", "(UTC-07:00)Mountain Time (US & Canada)", "(UTC-07:00)Arizona", "(UTC-06:00)Guadalajara,Mexico City,Monterrey", "(UTC-06:00)Saskatchewan", "(UTC-06:00)Central Time (US & Canada)", "(UTC-06:00)Central America", "(UTC-05:00)Bogota,Lima,Quito", "(UTC-05:00)Eastern Time (US & Canada)", "(UTC-05:00)Havana", "(UTC-05:00)Hayti", "(UTC-05:00)Chetumal", "(UTC-05:00)Indiana (East)", "(UTC-04:30)Caracas", "(UTC-04:00)Atlantic Time (Canada)", "(UTC-04:00)Cuiaba", "(UTC-04:00)Georgetown,La Paz,Manaus,San Juan", "(UTC-04:00)Santiago", "(UTC-04:00)Asuncion", "(UTC-03:30)Newfoundland", "(UTC-03:00)Brasilia", "(UTC-03:00)Buenos Aires", "(UTC-03:00)Greenland", "(UTC-03:00)Cayenne,Fortaleza", "(UTC-03:00)Montevideo", "(UTC-02:00)Coordinated Universal Time-02", "(UTC-01:00)Cape Verde Is.", "(UTC-01:00)Azores", "(UTC)Dublin,Edinburgh,Lisbon,London", "(UTC)Casablanca", "(UTC)Monrovia,Reykjavik", "(UTC)Coordinated Universal Time", "(UTC+01:00)Amsterdam,Berlin,Bern,Rome,Stockholm,Vienna", "(UTC+01:00)Belgrade,Bratislava,Budapest,Ljubljana,Prague", "(UTC+01:00)Brussels,Copenhagen,Madrid,Paris", "(UTC+01:00)Sarajevo,Skopje,Warsaw,Zagreb", "(UTC+01:00)Windhoek", "(UTC+01:00)West Central Africa", "(UTC+02:00)Amman", "(UTC+02:00)Beirut", "(UTC+02:00)Damascus", "(UTC+02:00)Harare,Pretoria", "(UTC+02:00)Helsinki,Kyiv,Riga,Sofia,Talinn,Vilnius", "(UTC+02:00)Cairo", "(UTC+02:00)Athens,Bucharest,Istanbul", "(UTC+02:00)Jerusalem", "(UTC+03:00)Baghdad", "(UTC+03:00)Kuwait,Riyadh", "(UTC+03:00)Minsk", "(UTC+03:00)Moscow,St.Petersburg,Volgograd", "(UTC+03:00)Nairobi", "(UTC+03:30)Tehran", "(UTC+04:00)Abu Dhabi,Muscat", "(UTC+04:00)Yerevan", "(UTC+04:00)Baku", "(UTC+04:00)Tbilisi", "(UTC+04:00)Port Louis", "(UTC+04:30)Kabul", "(UTC+05:00)Tashkent", "(UTC+05:00)Ekaterinburg", "(UTC+05:00)Islamabad,Karachi", "(UTC+05:30)Chennai,Kolkata,Mumbai,New Delhi", "(UTC+05:30)Sri Jayawardenepura", "(UTC+05:45)Kathmandu", "(UTC+06:00)Astana", "(UTC+06:00)Dhaka", "(UTC+06:00)Novosibirsk", "(UTC+06:30)Yangon (Rangoon)", "(UTC+07:00)Kobdo", "(UTC+07:00)Krasnoyarsk", "(UTC+07:00)Bangkok,Hanoi,Jakarta", "(UTC+08:00)Beijing,Chongqing,Hong Kong,Urumqi", "(UTC+08:00)Kuala Lumpur,Singapore", "(UTC+08:00)Perth", "(UTC+08:00)Taipei", "(UTC+08:00)Ulaanbaatar", "(UTC+08:00)Irkutsk", "(UTC+09:00)Pyongyang", "(UTC+09:00)Osaka,Sapporo,Tokyo", "(UTC+09:00)Seoul", "(UTC+09:00)Yakutsk", "(UTC+09:30)Adelaide", "(UTC+09:30)Darwin", "(UTC+10:00)Brisbane", "(UTC+10:00)Vladivostok", "(UTC+10:00)Guam,Port Moresby", "(UTC+10:00)Hobart", "(UTC+10:00)Canberra,Melbourne,Sydney", "(UTC+10:30)Lord Howe Island", "(UTC+11:00)Magadan", "(UTC+11:00)Solomon Is.,New Caledonia", "(UTC+12:00)Auckland,Wellington", "(UTC+12:00)Fiji", "(UTC+12:00)Coordinated Universal Time+12", "(UTC+12:45)Chatham Islands", "(UTC+13:00)Nuku'alofa", "(UTC+14:00)Christmas Island" | cut -d ',' -f 1- --output-delimiter=$'\n'
#Based on decompiled /WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/Fragment/SystemFragment.java
   # n=0
   # while read -r line; do
   #     eval "SYSTEM_TIMEZONE_$n='$line'"
   #     n=$(( n + 1 ))
   # done <<EOF
   #shellcheck disable=SC2034
   {
SYSTEM_TIMEZONE_1='(UTC-12:00) International Date Line West'
SYSTEM_TIMEZONE_2='(UTC-11:00) Samoa'
SYSTEM_TIMEZONE_3='(UTC-11:00) Coordinated Universal Time-11'
SYSTEM_TIMEZONE_4='(UTC-10:00) Aleutian Islands'
SYSTEM_TIMEZONE_5='(UTC-10:00) Hawaii'
SYSTEM_TIMEZONE_6='(UTC-09:30) Marquesas Islands'
SYSTEM_TIMEZONE_7='(UTC-09:00) Alaska'
SYSTEM_TIMEZONE_8='(UTC-09:00) Coordinated Universal Time-9'
SYSTEM_TIMEZONE_9='(UTC-08:00) Pacific Time (US & Canada)'
SYSTEM_TIMEZONE_10='(UTC-08:00) Baja California'
SYSTEM_TIMEZONE_11='(UTC-08:00) Coordinated Universal Time-8'
SYSTEM_TIMEZONE_12='(UTC-07:00) Chihuahua, La Paz, Mazatlan'
SYSTEM_TIMEZONE_13='(UTC-07:00) Mountain Time (US & Canada)'
SYSTEM_TIMEZONE_14='(UTC-07:00) Arizona'
SYSTEM_TIMEZONE_15='(UTC-06:00) Guadalajara, Mexico City,Monterrey'
SYSTEM_TIMEZONE_16='(UTC-06:00) Saskatchewan'
SYSTEM_TIMEZONE_17='(UTC-06:00) Central Time (US & Canada)'
SYSTEM_TIMEZONE_18='(UTC-06:00) Central America'
SYSTEM_TIMEZONE_19='(UTC-05:00) Bogota, Lima, Quito'
SYSTEM_TIMEZONE_20='(UTC-05:00) Eastern Time (US & Canada)'
SYSTEM_TIMEZONE_21='(UTC-05:00) Havana'
SYSTEM_TIMEZONE_22='(UTC-05:00) Hayti'
SYSTEM_TIMEZONE_23='(UTC-05:00) Chetumal'
SYSTEM_TIMEZONE_24='(UTC-05:00) Indiana (East)'
SYSTEM_TIMEZONE_25='(UTC-04:30) Caracas'
SYSTEM_TIMEZONE_26='(UTC-04:00) Atlantic Time (Canada)'
SYSTEM_TIMEZONE_27='(UTC-04:00) Cuiaba'
SYSTEM_TIMEZONE_28='(UTC-04:00) Georgetown, La Paz, Manaus, San Juan'
SYSTEM_TIMEZONE_29='(UTC-04:00) Santiago'
SYSTEM_TIMEZONE_30='(UTC-04:00) Asuncion'
SYSTEM_TIMEZONE_31='(UTC-03:30) Newfoundland'
SYSTEM_TIMEZONE_32='(UTC-03:00) Brasilia'
SYSTEM_TIMEZONE_33='(UTC-03:00) Buenos Aires'
SYSTEM_TIMEZONE_34='(UTC-03:00) Greenland'
SYSTEM_TIMEZONE_35='(UTC-03:00) Cayenne, Fortaleza'
SYSTEM_TIMEZONE_36='(UTC-03:00) Montevideo'
SYSTEM_TIMEZONE_37='(UTC-02:00) Coordinated Universal Time-02'
SYSTEM_TIMEZONE_38='UTC-01:00) Cape Verde Is.'
SYSTEM_TIMEZONE_39='(UTC-01:00) Azores'
SYSTEM_TIMEZONE_40='(UTC) Dublin, Edinburgh, Lisbon, London'
SYSTEM_TIMEZONE_41='(UTC) Casablanca'
SYSTEM_TIMEZONE_42='(UTC) Monrovia, Reykjavik'
SYSTEM_TIMEZONE_43='(UTC) Coordinated Universal Time'
SYSTEM_TIMEZONE_44='(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna'
SYSTEM_TIMEZONE_45='(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague'
SYSTEM_TIMEZONE_46='(UTC+01:00) Brussels, Copenhagen, Madrid, Paris'
SYSTEM_TIMEZONE_47='(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb'
SYSTEM_TIMEZONE_48='(UTC+01:00) Windhoek'
SYSTEM_TIMEZONE_49='(UTC+01:00) West Central Africa'
SYSTEM_TIMEZONE_50='(UTC+02:00) Amman'
SYSTEM_TIMEZONE_51='(UTC+02:00) Beirut'
SYSTEM_TIMEZONE_52='(UTC+02:00) Damascus'
SYSTEM_TIMEZONE_53='(UTC+02:00) Harare, Pretoria'
SYSTEM_TIMEZONE_54='(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Talinn, Vilnius'
SYSTEM_TIMEZONE_55='(UTC+02:00) Cairo'
SYSTEM_TIMEZONE_56='(UTC+02:00) Athens, Bucharest, Istanbul'
SYSTEM_TIMEZONE_57='(UTC+02:00) Jerusalem'
SYSTEM_TIMEZONE_58='(UTC+03:00) Baghdad'
SYSTEM_TIMEZONE_59='(UTC+03:00) Kuwait, Riyadh'
SYSTEM_TIMEZONE_60='(UTC+03:00) Minsk'
SYSTEM_TIMEZONE_61='(UTC+03:00) Moscow, St.Petersburg, Volgograd'
SYSTEM_TIMEZONE_62='(UTC+03:00) Nairobi'
SYSTEM_TIMEZONE_63='(UTC+03:30) Tehran'
SYSTEM_TIMEZONE_64='(UTC+04:00) Abu Dhabi, Muscat'
SYSTEM_TIMEZONE_65='(UTC+04:00) Yerevan'
SYSTEM_TIMEZONE_66='(UTC+04:00) Baku'
SYSTEM_TIMEZONE_67='(UTC+04:00) Tbilisi'
SYSTEM_TIMEZONE_68='(UTC+04:00) Port Louis'
SYSTEM_TIMEZONE_69='(UTC+04:30) Kabul'
SYSTEM_TIMEZONE_70='(UTC+05:00) Tashkent'
SYSTEM_TIMEZONE_71='(UTC+05:00) Ekaterinburg'
SYSTEM_TIMEZONE_72='(UTC+05:00) Islamabad, Karachi'
SYSTEM_TIMEZONE_73='(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi'
SYSTEM_TIMEZONE_74='(UTC+05:30) Sri Jayawardenepura'
SYSTEM_TIMEZONE_75='(UTC+05:45) Kathmandu'
SYSTEM_TIMEZONE_76='(UTC+06:00) Astana'
SYSTEM_TIMEZONE_77='(UTC+06:00) Dhaka'
SYSTEM_TIMEZONE_78='(UTC+06:00) Novosibirsk'
SYSTEM_TIMEZONE_79='(UTC+06:30) Yangon (Rangoon)'
SYSTEM_TIMEZONE_80='(UTC+07:00) Kobdo'
SYSTEM_TIMEZONE_81='(UTC+07:00) Krasnoyarsk'
SYSTEM_TIMEZONE_82='(UTC+07:00) Bangkok, Hanoi, Jakarta'
SYSTEM_TIMEZONE_83='(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi'
SYSTEM_TIMEZONE_84='(UTC+08:00) Kuala Lumpur, Singapore'
SYSTEM_TIMEZONE_85='(UTC+08:00) Perth'
SYSTEM_TIMEZONE_86='(UTC+08:00) Taipei'
SYSTEM_TIMEZONE_87='(UTC+08:00) Ulaanbaatar'
SYSTEM_TIMEZONE_88='(UTC+08:00) Irkutsk'
SYSTEM_TIMEZONE_89='(UTC+09:00) Pyongyang'
SYSTEM_TIMEZONE_90='(UTC+09:00) Osaka, Sapporo, Tokyo'
SYSTEM_TIMEZONE_91='(UTC+09:00) Seoul'
SYSTEM_TIMEZONE_92='(UTC+09:00) Yakutsk'
SYSTEM_TIMEZONE_93='(UTC+09:30) Adelaide'
SYSTEM_TIMEZONE_94='(UTC+09:30) Darwin'
SYSTEM_TIMEZONE_95='(UTC+10:00) Brisbane'
SYSTEM_TIMEZONE_96='(UTC+10:00) Vladivostok'
SYSTEM_TIMEZONE_97='(UTC+10:00) GuamPort Moresby'
SYSTEM_TIMEZONE_98='(UTC+10:00) Hobart'
SYSTEM_TIMEZONE_99='(UTC+10:00) Canberra, Melbourne, Sydney'
SYSTEM_TIMEZONE_100='(UTC+10:30) Lord Howe Island'
SYSTEM_TIMEZONE_101='(UTC+11:00) Magadan'
SYSTEM_TIMEZONE_102='(UTC+11:00) Solomon Is., New Caledonia'
SYSTEM_TIMEZONE_103='(UTC+12:00) Auckland, Wellington'
SYSTEM_TIMEZONE_104='(UTC+12:00) Fiji'
SYSTEM_TIMEZONE_105='(UTC+12:00) Coordinated Universal Time+12'
SYSTEM_TIMEZONE_106='(UTC+12:45) Chatham Islands'
SYSTEM_TIMEZONE_107='(UTC+13:00) Nuku'\''alofa'
SYSTEM_TIMEZONE_108='(UTC+14:00) Christmas Island' 
   }
#EOF
}

SHELL_SUPPORT_TYPESET=0
#initTimezonesHeredoc

#strace: Process 492 attached
#% time     seconds  usecs/call     calls    errors syscall
#------ ----------- ----------- --------- --------- ----------------
# 66.67    0.095606       95606         1           wait4
# 33.30    0.047750          15      3075           read
#  0.02    0.000023          11         2           dup2
#  0.01    0.000015           1         9           close
#  0.00    0.000000           0         1           write
##  0.00    0.000000           0         4           stat
#  0.00    0.000000           0         4           fstat
#  0.00    0.000000           0        14           mmap
#  0.00    0.000000           0         8           mprotect
#  0.00    0.000000           0         2           munmap
#  0.00    0.000000           0         6           brk
#  0.00    0.000000           0        14           rt_sigaction
#  0.00    0.000000           0         1           rt_sigreturn
#  0.00    0.000000           0        12           pread64
#  0.00    0.000000           0         2         2 access
##  0.00    0.000000           0         1           pipe
 # 0.00    0.000000           0         2           getpid
#  0.00    0.000000           0         1           clone
#  0.00    0.000000           0         2           execve
#  0.00    0.000000           0         4           fcntl
#  0.00    0.000000           0         2           getuid
#  0.00    0.000000           0         2           getgid
#  0.00    0.000000           0         4           geteuid
#  0.00    0.000000           0         2           getegid
#  0.00    0.000000           0         2           getppid
#  0.00    0.000000           0         4         2 arch_prctl
#  0.00    0.000000           0         5           openat
#------ ----------- ----------- --------- --------- ----------------
#100.00    0.143394                  3186         4 total


initTimezonesVar


#strace: Process 507 attached
#% time     seconds  usecs/call     calls    errors syscall
#------ ----------- ----------- --------- --------- ----------------
#  0.00    0.000000           0         6           read
#  0.00    0.000000           0         5           close
#  0.00    0.000000           0         4           stat
#  0.00    0.000000           0         4           fstat
###  0.00    0.000000           0        14           mmap
#  0.00    0.000000           0         8           mprotect
#  0.00    0.000000           0         2           munmap
##  0.00    0.000000           0         6           brk
#  0.00    0.000000           0        14           rt_sigaction
#  0.00    0.000000           0         1           rt_sigreturn
#  0.00    0.000000           0        12           pread64
#  0.00    0.000000           0         2         2 access
#  0.00    0.000000           0         2           getpid
#  0.00    0.000000           0         1           clone
#  0.00    0.000000           0         2           execve
#  0.00    0.000000           0         1           wait4
#  0.00    0.000000           0         2           fcntl
#  0.00    0.000000           0         2           getuid
#  0.00    0.000000           0         2           getgid
#  0.00    0.000000           0         4           geteuid
#  0.00    0.000000           0         2           getegid
#  0.00    0.000000           0         2           getppid
#  0.00    0.000000           0         4         2 arch_prctl
#  0.00    0.000000           0         5           openat
#------ ----------- ----------- --------- --------- ----------------
#100.00    0.000000                   107         4 total
