#!/usr/bin/dash
cd /tmp/gw/livedata
mkdir /tmp/gw/log
dirModified=0
while true; do 
#stat /tmp/gw/livedata/windspeed /tmp/gw/log/windspeed

        if [ -e "/tmp/gw/log/tempin" ] && [ "tempin"  -nt "/tmp/gw/log/tempin" ] || [ ! -e "/tmp/gw/log/tempin" ]; then
            cp ./* "/tmp/gw/log"
            dirModified=1
        fi

        if [ "$dirModified" -eq 1 ]; then
           read -r tempin < /tmp/gw/log/tempin
           [ -s /tmp/gw/log/tempout ] && read -r tempout </tmp/gw/log/tempout
           #csv format
           echo "$(date),$tempout,$tempin"
           dirModified=0
        fi
        
         sleep 1
done
