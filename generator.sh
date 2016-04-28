# #!/bin/bash 

function gen_beam() {
	echo  'random:seed('$1'). c(randerl). randerl:main("'$1'").' | erl -s init stop 

}

gen_beam $1
erl -compile randprog_${1}_beam  --disable.hipe 
echo -e 'c(randprog_'${1}'_o0,[{hipe,[o0]}]). \n 
         c(randprog_'${1}'_o1,[{hipe,[o1]}]). \n 
         c(randprog_'${1}'_o2,[{hipe,[o2]}]). \n
         c(randprog_'${1}'_o3,[{hipe,[o3]}]). \n ' | erl -s init stop

#### OLD CODE ####

# function generatetest() {
# 	echo 'c(' $1 $3').' > testcommands 
# 	echo 'random:seed('$2').' >> testcommands
# 	echo '[A,B,C,D]=[random:uniform(),random:uniform(1000000),random:uniform(82374237392),random:uniform()].' >> testcommands
# 	echo ${1}':main(A,B,C,D).' >> testcommands 
# }

# function generatecode() {
# 	echo -e 'random:seed(' $2 '). c(randerl). randerl:main("'${1}'").' | 
# 	erl -s init stop > ${1}.erl
# }

# function testt() {
# 	cat testcommands | erl -noinput -s init stop | grep '3>' > ${1} 
# }

# MODULE_NAME='test' 
# SEED_CODE=${RANDOM}
# SEED_TEST=${RANDOM}

# echo 'SEED_CODE= ' $SEED_CODE
# generatecode $MODULE_NAME $SEED_CODE

# echo 'SEED_TEST='  $SEED_TEST
# generatetest $MODULE_NAME $SEED_TEST ',[native,{hipe,o3}]'
# testt ${MODULE_NAME}_o3.output
# generatetest $MODULE_NAME $SEED_TEST ',[native,{hipe,o2}]'
# testt ${MODULE_NAME}_o2.output
# generatetest $MODULE_NAME $SEED_TEST ',[native,{hipe,o1}]'
# testt ${MODULE_NAME}_o1.output 

# diff3 ${MODULE_NAME}_o1.output ${MODULE_NAME}_o2.output ${MODULE_NAME}_o3.output || 
# cp ${MODULE_NAME}.erl bug_code_${SEED_CODE}_test_${SEED_TEST}.erl 




