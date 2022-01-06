#!/usr/bin/ksh


function afunc
{

     typeset diffvar 
     typeset -i testvar
     testvar=4
     samevar=funcvalue 
     diffvar=funcvalue 
     echo "samevar is $samevar"
     echo "diffvar is $diffvar" 
}

samevar=globvalue 
diffvar=globvalue 
echo "samevar is $samevar"
echo "diffvar is $diffvar"
afunc 
echo "samevar is $samevar" 
echo "diffvar is $diffvar" 
echo "testvar is $testvar"

#expected output
#samevar is globvalue 
#diffvar is globvalue 
#samevar is funcvalue 
#diffvar is funcvalue 
#samevar is funcvalue 
#diffvar is globvalue 
#docstore.mik.ua/orelly/unix3/korn/ch06_05.htm

#ksh93 - works with function keyword, but not {fname} () syntax
#henning@ideapadpro:/mnt/c/Users/hksko/OneDrive/Documents/github/gw$ ksh ./test/test-kshtypeset.sh 
#samevar is globvalue
#diffvar is globvalue
#samevar is funcvalue
#diffvar is funcvalue
#samevar is funcvalue
#diffvar is funcvalue

