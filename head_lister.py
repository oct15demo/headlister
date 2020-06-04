'''
Created on May 28, 2020

@author: charles
'''
'''
Pass a list of .txt files to stdin or pass a file name with a list of .txt files
'''

# for retrieving argv
import sys
# for os.sep, directory separator
# import os
#TODO: Replace commented out print statements with log.debug
#print (f'sys.argv:{sys.argv}')
#sys.exit(0)

DEFAULT_OUTPUT="stdout"

#TODO: set defaults

if (len(sys.argv) >1 and (sys.argv[1] == '-h' or sys.argv[1] == '-help')) or len(sys.argv) == 1:
    print('\npython3 head_lister.py  input_file | \'stdin\'   lines_per_file    min_line_length | \'0\'    output_file | \'stdout\' ')
    print('\nPass a list of .txt files in current dir to stdin or pass a file name with a list of .txt files.')
    print('Save lines in a data structure until line len equal or greater than min_line_length, set min_line_length=0 for no threshold')
    print('Run from run_head_lister.sh wrapper to use defaults, or added options, man ./run_head_lister.1 for detailed description')
    sys.exit(1)
# Avoiding argparse because args handled in wrapper run_head_liner.sh
# If min_line_len = 0, it is taken to mean there is no minimum.

# Set default no argument to three, assumes only outputting 1 line
lines_per_file = 1

# Set threshold to 0 and code will never break reading a file's lines
threshold_len = 0
# use a False value as default output file to test and print to sys.stdout if False
output_file=""

input_file=sys.argv[1]

if len(sys.argv)>2:
    lines_per_file = int(sys.argv[2])
else:
    print('Using default, 1 line per file')

if len(sys.argv)>3:
    threshold_len = int(sys.argv[3])

if len(sys.argv)>4 and sys.argv[4] != DEFAULT_OUTPUT:
    output_file = sys.argv[4]

def main():
    print(f' arg[1] lines per file to process: {lines_per_file}')
    print(f' arg[2] line length threshold to halt saving lines: {threshold_len if threshold_len else "no min threshold"}')
    process_head_input(lines_per_file, threshold_len, input_file)

def process_head_input(lines_per_file, threshold_len, input_file):
    # groups: a list, each item in this list contains a file's data
    groups = []
    total_lines = 0
    #TODO: to make scalable, need to read in stream, or use generator
    if input_file != 'stdin':
        with open(input_file) as f:
            file_list = f.readlines()
    else:
        file_list = sys.stdin.readlines()

    file_count = len(file_list)
    short_files = []
    short_lens = []
    file_count = 0
    line_shortfall = 0
    line_count = 0
    for file_name in file_list:
        line_count = 0
        group = {}
        lines = []
        lens = []
        is_threshold_len = False
        for line in open(file_name[:-1]): # -1 to remove '\n'
            if (line_count + 1) > lines_per_file:
                break
            line_count += 1
            lines.append(line)
            lens.append(len(line))
            if threshold_len and len(line) >= threshold_len:
                is_threshold_len = True
                break

        group['file_name']=file_name[:-1]
        group['lens']=lens
        
        # Didn't find line => threshold_len, give index and len of max len line  
        if threshold_len and not is_threshold_len:
            max_len = 0
            if lens:
                max_len = max(lens)
            else:
                lens.append(0)
            short_index = lens.index(max_len)
            # https://stackoverflow.com/questions/3989016/how-to-find-all-positions-of-the-maximum-value-in-a-list
            group['short_len']= (max_len, short_index)
            short_lens.append((file_name[:-1], max_len, short_index))
        
        # Number of lines processed less than lines input, give index either as line that met threshold, lines that were read  
        if line_count < lines_per_file:
            if is_threshold_len:
                group['threshold_line'] = line_count
            else:
                short_files.append((file_name[:-1], line_count))
                group['short_lines']=line_count

        group['lines']=lines
        
        groups.append(group)
        total_lines += len(lines)

    if output_file:
        with open(output_file, 'a+') as f:
            for group in groups:
                print(group, file = f)
    else:
        for group in groups:
            print(group) 

    meta_data = {}
    meta_data['total_lines'] = total_lines
    meta_data['file_count'] = len(file_list)
    meta_data['lines_per_file'] = lines_per_file
    if threshold_len:
        meta_data['threshold_len'] = threshold_len
    if len(short_files):
        meta_data['short_file_cnt'] = len(short_files)
        meta_data['short_files'] = short_files
    if len(short_lens):
        meta_data['short_len_cnt'] = len(short_lens)
        meta_data['short_lens'] = short_lens
    if output_file:
        with open(output_file + '_meta.data', 'a+') as f:
            print(meta_data, file = f)
    else:
        print (f'meta_data: {meta_data}')

# https://stackoverflow.com/questions/845058/how-to-get-line-count-of-a-large-file-cheaply-in-python
# Function below from fourth rated answer, neither seems amenable to detecting missing linefeed at end of file
# For head_lister, data is fed in a stream, counting lines here to know when last line reached of file before the lines per file to read is reached.
# Below utils Not needed in current version, but also to note, both count line feeds and are subject to undercount of 1 line, when last line of file omits a line feed. 

def rawrawcount(file_path):
    f = open(file_path,'rb')
    lines = 0
    buf_size = 1024 * 1024
    read_f = f.raw.read

    buf = read_f(buf_size)
    while buf:
        lines += buf.count(b'\n')
        buf = read_f(buf_size)
    return lines

# Above and here too https://docs.python.org/3/tutorial/inputoutput.html
def rawcount(filename):
    lines = 0
    for line in open(filename):
        lines += 1
    return lines

# See also below, outdated but good overview
# https://www.oreilly.com/library/view/python-cookbook/0596001673/ch04s07.html

if __name__ == '__main__':
    main()
