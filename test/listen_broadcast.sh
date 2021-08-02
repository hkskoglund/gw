#Based on https://stackoverflow.com/questions/7696862/strange-behaviour-of-netcat-with-udp
#nc only accept 1 broadcast
#nc   -u -4 -l 59387
#nc -k  -u -4 -l 59387 --sh-exec "cat > /proc/$$/fd/1"
socat UDP-RECV:59387 STDOUT | hexdump -C
#00000000  ff ff 12 00 27 48 3f da  54 14 ec 0a 2a 00 b4 af  |....'H?.T...*...|
#00000010  c8 17 47 57 31 30 30 30  41 2d 57 49 46 49 31 34  |..GW1000A-WIFI14|
#00000020  45 43 20 56 31 2e 36 2e  38 be ff ff 12 00 27 48  |EC V1.6.8.....'H|
#00000030  3f da 55 4d a9 c0 a8 03  cc af c8 17 47 57 31 30  |?.UM........GW10|
#00000040  30 30 41 2d 57 49 46 49  34 44 41 39 20 56 31 2e  |00A-WIFI4DA9 V1.|
#00000050  36 2e 38 09 ff ff 12 00  27 48 3f da 55 4d a9 c0  |6.8.....