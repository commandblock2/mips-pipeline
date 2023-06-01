FILE_NO_EXT=${1%.*}
mips-unknown-linux-gnu-as "${FILE_NO_EXT}.mips" -O3 -o $FILE_NO_EXT
mips-unknown-linux-gnu-objdump -d $FILE_NO_EXT | awk '/^[[:space:]]*[0-9a-f]+:/ {print $2}' > "${FILE_NO_EXT}.hex"
rm $FILE_NO_EXT