FILE_NO_EXT=${1%.*}
mips-unknown-linux-gnu-as "${FILE_NO_EXT}.mips" -o $FILE_NO_EXT
mips-unknown-linux-gnu-objcopy -O ihex $FILE_NO_EXT "${FILE_NO_EXT}.hex"
rm $FILE_NO_EXT