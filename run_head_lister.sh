# Set the python script called from this shell wrapper 
head_lister=head_lister.py

################################################
#                                              #
#  Place run_head_lister.sh and head_lister.py #
#  in same dir, as the script references the   #
#  head_lister.py with that assumption.        #
#                                              #
#  Run the run_head_lister.sh from the dir     #
#  where the .txt files are located, unless    #
#  passing a file with list of .txt files.     #
#                                              #
#  To view man page, from directory where      #
#  the man page run_head_lister.1 is located,  #
#  man ./run_head_lister.1                     #
#                                              #
################################################

if [ $# -lt 1 ] || [ $1 == '-h' ] || [ $1 == '-help' ] 
then
   echo "Usage: run_head_lister.sh lines_per_file [number_of_files] [-l min_line_length] [-i input_file] [-o output_file] [-ls-f]"
   echo ""
   echo "-ls-f creates file list unsorted,  man ./run_head_lister.1 for greater detail on options"
   exit
fi

# The one required argument
lines_per_file=$1

# Set default values
min_line_length=0
number_of_files=1
output_file="stdout"
input_file="stdin"
ls_op=""

# Issue WARNING if any numeric parameters, as in    run_head_lister.sh 3 4 2
num_flag=0

while [ "$2" != "" ]; do
    case $2 in
        -l | --len )  shift;  min_line_length=$2; echo "set min_line_length=$2";;
        -i | --in )   shift;  input_file=$2;      echo "set input_file=$2";;
        -o | --out )  shift;  output_file=$2;     echo "set output_file=$2";;
        -ls-f )       shift;  ls_op='-f';           echo "set ls_op=-f";;
        * ) if [ $num_flag -ne 0 ]
            then
                 echo "WARNING: Illegal extra positional option passed to wrapper run_head_lister.sh, ignored."
            else
                number_of_files=$2; num_flag=1;echo "set number_of_files=$2"
            fi;;
    esac
    shift
done

# Print arguments and mas or estimated lines (files may be shorter than files per line
# and if threshold length used and met, no more lines read after threshold reached)
total_lines_to_read=$(($lines_per_file  * $number_of_files))

echo "lines_per_file  $lines_per_file"
echo "number_of_files $number_of_files"
echo "min_line_length $min_line_length"
echo "input_file      $input_file"



if [ $input_file = 'stdin' ]
then
    file_count=`ls -f|grep "\.txt$"|wc -l`
else
    file_count=`cat $input_file|grep -v ^#|wc -l`
fi

if [ $file_count -eq 0 ]
then
   echo "No *.txt files found."
   exit
fi

# On MacOS, python 2.7 is default, need to point to 3.x version 
if [ -d /Library/Frameworks/Python.framework/Versions ]
then 
     latest_python=`ls /Library/Frameworks/Python.framework/Versions|sort -nr|head -1`
     python=/Library/Frameworks/Python.framework/Versions/$latest_python/bin/python3
else
     python=python
fi

# Assume python in same directory as this script
# TODO: Check if found in python path or otherwise accessible
dir=$(dirname "$0")
echo "scripts dir=$dir"
# default dir is current directory
txt_dir=`pwd`

if [ $input_file = 'stdin' ]
then
    if [ $number_of_files = '--all' ] || [ $number_of_files = '-a' ]
    then
       # use 0 as flag not to limit number of files, 0 used as a pythonic False
       number_of_files=0 
       echo "total lines attempted to_read $total_lines_to_read"
       if [ $file_count -gt 1000 ] 
       then 
          echo "Process all $file_count files?"
          if [ "$ls_op" = "" ]
          then
              echo "Use of '-ls-f' option for ls -f recommended for very large numbers of files (at least 100,000 or more)."
          fi
          echo "Enter y or yes to proceed"
          read file_count_check
       fi
       if [ $file_count_check == 'y' ] || [ $file_count_check == 'yes' ]
       then
          for file in `ls $ls_op $txt_dir|grep "\.txt$"`; do echo "$file"; done| \
          $python $dir/$head_lister $input_file $lines_per_file $min_line_length $output_file
          echo ""
          echo "for file in \`ls $ls_op $txt_dir|grep \"\.txt$\"\`; do echo \"\$file\"; done| \ "
          echo "$python $dir/$head_lister $input_file $lines_per_file $min_line_length $output_file"
          echo ""
          echo "for file in \`ls $ls_op txt_dir|grep \"\.txt$\"\`; do echo \"\$file\"; done| \ "
          echo "python3 dir/$head_lister $input_file $lines_per_file $min_line_length $output_file"
        fi
    else
       echo "total lines attempted to_read $total_lines_to_read"
       for file in `ls $ls_op $txt_dir|grep "\.txt$"`; do echo "$file"; done|head -$number_of_files| \
       $python $dir/$head_lister $input_file $lines_per_file $min_line_length $output_file
       echo "" # https://stackoverflow.com/questions/8467424/echo-newline-in-bash-prints-literal-n  printf "Hello\nWorld";echo -e "Hello\nworld";echo -e 'Hello\nworld';echo Hello$'\n'world;echo Hello ; echo world 
       echo "for file in \`ls $ls_op $txt_dir|grep \"\.txt$\"\`; do echo \"\$file\"; done|head -$number_of_files| \ "
       echo "$python $dir/$head_lister $input_file $lines_per_file $min_line_length $output_file"
       echo ""
       echo "for file in \`ls $ls_op txt_dir|grep \"\.txt$\"\`; do echo \"\$file\"; done|head -$number_of_files| \ "
       echo "python3 dir/$head_lister $input_file $lines_per_file $min_line_length $output_file"
    fi
else
   $python $dir/$head_lister $input_file $lines_per_file $min_line_length $output_file
   echo "$python $dir/$head_lister $input_file $lines_per_file $min_line_length $output_file"
   echo "python3 dir/$head_lister input_file $lines_per_file $min_line_length output_file"
fi

# Two versions of commands executed are echoed for reference, the first with full paths, the second with variable names for paths and files.
