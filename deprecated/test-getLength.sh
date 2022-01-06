#/usr/bin/dash

getLength()
#get length of tx packet buffer
#$1 string of uint8 integers with space
{
    IFS=' '
    VALUE_LENGTH=0
    for b in $1; do
      VALUE_LENGTH=$(( VALUE_LENGTH + 1 ))
    done
}

getLength "255 255 50 40               30 20 10"
echo "LENGTH $VALUE_LENGTH"