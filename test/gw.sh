# Info  from https://www.xmodulo.com/tcp-udp-socket-bash-shell.html
# Writing CMD_BROADCAST 0x12 to GW port 46000
# https://brendanzagaeski.appspot.com/0006.html - hexdump examples

GW=10.42.0.180
UDP_PORT=46000
TCP_PORT=45000
FD_UDP=3
FD_TCP=4
HEADER='\xff\xff'

echo GW $GW
#echo Current shell PID $$

#open file descriptors to UDP/TCP port on GW
exec 3<>/dev/udp/$GW/$UDP_PORT
exec 4<>/dev/tcp/$GW/$TCP_PORT
netstat -tunp | grep "$$"
#https://til.hashrocket.com/posts/cc130fc50e-pid-of-the-current-shell


#https://linuxize.com/post/bash-functions/
function command()
{
  echo -ne "$HEADER$1" >&$2 && dd bs=1024 count=1 status=none<&$2 | hexdump -C    
}

echo CMD_BROADCAST
command '\x12\x00\x04\x15' $FD_UDP

echo CMD_READ_MAC
command '\x26\x03\x29' $FD_TCP

echo CMD_READ_VERSION
command '\x50\x03\x53' $FD_TCP
