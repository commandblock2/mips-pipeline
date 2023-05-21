FILE_NO_EXT=${1%.*}
mips-unknown-linux-gnu-as "${FILE_NO_EXT}.mips" -O0 -o $FILE_NO_EXT
mips-unknown-linux-gnu-objdump -d $FILE_NO_EXT | awk '{print $2}' | grep -v -e '^$' -e '^<.text>:' -e 'file' -e 'of' > "${FILE_NO_EXT}.hex"
rm $FILE_NO_EXT