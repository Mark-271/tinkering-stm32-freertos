#!/bin/bash

set -e

# --------------------------------- Variables ----------------------------------

PROJECT_DIR=/home/marksunhurov/educ/tinkering-stm32
cscope_dir=/home/marksunhurov/educ/tinkering-stm32/cscope_data_base
src_dir=
dpd_dir=

# --------------------------------- Functions ----------------------------------

print_usage() {
	echo "Usage: $0 [dpd_path]"
	echo
	echo "If dpd_path is not specified, we'll try to use"
	echo "DPD_DIR environment variable"
}

check_tools() {
	realpath --version &>/dev/null
	if [ $? -ne 0 ]; then
		echo '"realpath" tool seems to be missing' >&2
		echo "You can install it as follows:" >&2
		echo "    sudo aptitude install realpath"
		exit 1
	fi
}

check_dir() {
	if [ ! -d "$1" ]; then
		echo "Error: \"$1\" directory doesn't exist" >&2
		exit 1
	fi
}

check_dirs() {
	echo "---> Checking dirs..."

	check_dir $src_dir
	check_dir $proj_dir
}

prepare() {
	echo "---> Prepare..."

	if [ $# -eq 0 ]; then
		# Trying to use DPD_DIR
		if [ -n "$PROJECT_DIR" ]; then
			src_dir="$PROJECT_DIR"
			proj_dir="$PROJECT_DIR"
            echo $src_dir
            echo $proj_dir
		else
			echo "Error: dpd must be specified" >&2
			print_usage
			exit 1
		fi
	elif [ $# -eq 1 ]; then
		src_dir="$1"
		proj_dir="$src_dir"
	else
		echo "Error: Wrong arguments count" >&2
		print_usage
		exit 1
	fi
	check_tools
	check_dirs

	rm -f cscope.files
	touch cscope.files
}

list_files() {
	echo "---> Listing files..."

	echo "  Listing project files..."
    find "$PROJECT_DIR" \( -name '*.c' -o -name '*.cpp' -o -name '*.h' -o -name '*.lds' \) -exec readlink -f {} \; > cscope.files
}

create_cscope_db() {
	echo "---> Creating cscope DB..."
	/usr/bin/cscope -b -q -k

    if [ "$(realpath "$cscope_dir")" != "$(pwd)" ]; then
        echo "$cscope_dir"
		echo "---> Moving to the right dir..."
		rm -rf $cscope_dir
		mkdir $cscope_dir
		mv cscope.* $cscope_dir
	fi
}

create_ctags_db() {
	echo "---> Create CTags DB..."
	ctags -L $cscope_dir/cscope.files -f $cscope_dir/tags
}

cleanup() {
	echo "---> Clean garbage..."
	rm $cscope_dir/cscope.files
	rm $cscope_dir/cscope.*
	rm $cscope_dir/tags
	#rm $DPD_DIR/tags
}

# -------------------------------- Entry point ---------------------------------

#cleanup
prepare "$@"
list_files
create_cscope_db
create_ctags_db
echo 'Done!'
