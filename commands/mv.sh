#!/bin/bash

# If you got this error:
# mv ./ijortengab/gallery/2024/07/h264_found -T ./ijortengab/h264_found
# mv: cannot move './ijortengab/gallery/2024/07/h264_found' to './ijortengab/h264_found': Directory not empty
# 
# The solution is just change `mv` to `mv.sh`. Example:
# Before:
# mv    ./ijortengab/gallery/2024/07/h264_found -T ./ijortengab/h264_found
# After:
# mv.sh ./ijortengab/gallery/2024/07/h264_found -T ./ijortengab/h264_found
#
if [ $# -eq 0 ];then
	echo Select method.
	echo '1)' SOURCE -t DEST
	echo '  ' move all SOURCE arguments into DEST directory 
	echo '2)' SOURCE -T DEST
	echo '  ' treat DEST as a normal file/directory
	read -p 'Select: ' __o
	case "$__o" in
		1) _o='-t' ;;
		2) _o='-T' ;;
		*) echo error 1; exit 1
	esac
	read -p 'SOURCE: ' _a
	read -p 'DEST: ' _b
	set -- "$_a" "$_o" "$_b"
fi

a="$1"; shift
o="$1"; shift
b="$1"; shift

case "$o" in
-T|-t) ;;
*) echo error 2; exit 2
esac


if [[ $o == '-T' ]];then
	real_a=$(realpath "$a")
	echo 'SOURCE="'"$real_a"'"'	
	if [ -d "$real_a" ];then
		rmdir --ignore-fail-on-non-empty "$real_a"
	fi
	if [ -d "$real_a" ];then
		# Berarti move dan merge direktori tree.
		# a=$(realpath "$a")
		# echo '$a' "$a"
		real_b=$(realpath "$b")
		echo 'DEST="'"$real_b"'"'
		cd "$real_a"
		old_log_line=
		while read -r line; do
			dirname=$(dirname "$line")
			target_dir="${real_b}"
			_target_dir="${b}"
			if [[ ! "$dirname" == '.' ]];then
				target_dir+="/${dirname}"
				_target_dir+="/${dirname}"
			fi
			log_line="mkdir -p \"$_target_dir\""
			if [ -z "old_log_line" ];then
				echo "$log_line"
				mkdir -p "$target_dir"
			elif [[ ! "$log_line" == "$old_log_line" ]];then
				echo "$log_line"
				mkdir -p "$target_dir"
			fi
			old_log_line="$log_line"
			echo mv "${a}/${line}" -t "$_target_dir"
			mv "${real_a}/${line}" -t "$target_dir"
		done <<< `find * -type f`
		echo 'find . -type d -empty -delete'
		find . -type d -empty
		find . -type d -empty -delete
		dirname=$(dirname "$real_a")
		echo rmdir "$a"
		cd "$dirname" && rmdir --ignore-fail-on-non-empty "$real_a"
	fi
fi
