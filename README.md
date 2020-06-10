    run_head_lister.sh(1)                                    run_head_lister.sh(1)

    NAME

       run_head_lister.sh  -  output in data structure first lines of multiple
       .txt files until line length meets or exceeds threshold

    SYNOPSIS

       run_head_lister.sh [ -h | -help ] 'lines_per_file' [  'number_of_files'
       |  -a | --all ] [ -l 'min_line_length' ] [ -i 'input_file' ] [ -o 'out-
       put_file' ] [ -ls-f ]

    DESCRIPTION

       run_head_lister.sh displays in a data structure the first lines of mul-
       tiple  .txt  files  until  line length meets or exceeds threshold, each
       record includes the file name, a list of line lengths, and  a  list  of
       the lines. Output can be saved to a file.

       The script generates a list of .txt files in the initialization line  of 
       a for loop, and inside the for loop, echoes the file name to the stream, 
       uses head to limit the number of file names passed in the stream to  the 
       python utility  head_lister.py.  Thus  run_head_lister.sh  functions  as  
       a  wrapper  around  head_lister.py,  interprets args passed and supplies 
       defaults (vs using argparse in python). 

       The  first  and  only required argument controls how many lines per file
       are processed, the  second optional argument controls how many files are
       processed,  use -a or --all to designate all files. The -l option sets a
       minimum  threshold line length per file, which when reached  causes  the
       utility to stop  processing more lines, regardless of the lines per file
       argument.

       run_head_lister.sh calls head_lister.py in three forms:

        1)  If number_of_files is given, it uses head to limit the file list to 
        that number of file names within the for loop piping the file name with 
        echo  first.  The  piped output of the for loop is passed to the python 
        utility head_lister.py which by default reads from stdin.

    for  file  in  `ls   current_directory|grep  ".txt$"`;  do  echo "$file"; done|head -$number_of_files| 
    /Library/Frameworks/Python.framework/Versions/$latest_version/bin/python3 ./head_lister.py stdin 1 0 stdout

    or in more readable form without the python directory of OSX and using the value of $number_of_files=1:

    for  file  in  `ls   txt_dir|grep  ".txt$"`;  do  echo  "$file"; done|head -1|
    python3 dir/head_lister.py stdin 1 0 stdout

       2)  The  second  form  of  script  omits the 'head -1|' or 'head -$number_of_files'

       3) The third form passes a file list

    /Library/Frameworks/Python.framework/Versions/3.6/bin/python3 ./head_lister.py /dir/nput_file 1 0 stdout

    or again as a more readable version:

    python3 dir/head_lister.py input_file 1 0 output_file


       There is a check in the script for the OSX python directory and  latest
       version, if not found, the script just calls python.

       In  the  absence  of  a number_of_files argument, only one file is pro-
       cessed. The min_line_length sets a threshold which after reaching halts
       processing more lines from a file. It is optional and absent that argu-
       ment, all lines as set by lines_per_file will be processed. It  is  the
       head_lister.py  that checks each line to see if it meets or exceeds the
       min_line_length if that option used.

        Using the -ls-f option causes the ls command feeding file names to the
       pipeline  to  pass  an  unsorted list. Very large numbers of files in a
       directory (several hundred thousand) can greatly slow the  script  when
       the list is sorted.

        The  output  of  the  script is a list of dictionaries, one dictionary
       record in the list for each file processed. Each dictionaray contains
        { file_name: name of the file
          lens : [ list of the length of every line saved ]
          lines : [ list containing the text of each line ] }

       If there was a threshold the file lines  didn't  meet,  the  dictionary
       will  contain  an  item with the length and index of the maximum length
       line read:
           short_len:  (31,  0)  If  the  file  contained  less   lines   than
       lines_per_file  to  read,  and reading wasn't interupted by meeting the
       threshold, the dictionary will contain an item with the number of lines
       read:
           short_file: (6)

        Output  will  also include a data strucure of meta data containing the
       parameters lines_per_file, number_of_files,  min_line_length,  and  two
       lists { 'short_files': [ file_name_7, file_name_18, ...], 'short_lens':
       [(file_name_8, 100, 65),(file_name_23, 100, 87),...]} The first list of
       'short_files'  contains  file names that didn't have as many lines that
       head_lister.py was  attempting  to  process  for  each  file,  and  not
       interupted  by  meeting  a  min  threshold  length.  The second list of
       'short_lens' contains the names of files where the threshold length was
       never met, along with the maximum line length that was found. If output
       was saved to a file, this meta data will also be saved to a file,  with
       the  designation  '_meta.data'  added  to end of the file name. (If the
       data structure is saved to  my_output_file,  the  meta  data   will  be
       saved to the file my_output_file_meta.data)

        The  output  file and input file parameters may include the file path,
       as in ~/data/my_input_file or ~/data/my_output_file


    EXAMPLE
       
    $ run_head_lister.sh 3 3 
    
    set number_of_files=3 
    lines_per_file   3  
    number_of_files  3  
    min_line_length  0 
    input_file      stdin 
    scripts dir=.
    total lines attempted to_read 9
     arg[1] lines per file to process: 3
     arg[2] line length threshold to halt saving lines:  no  min  threshold
     
    {'file_name': '0000.txt0, 'lens': [148, 65, 55], 'lines': ['[ Halliburton 
    Oil Well Cementing Co. v. Walker Mr.Earl Babcock, of  Duncan,  Okl. (Harry
    C. Robb, of Washington, D.C., on the brief), for petitioner.0, 'Mr. Harold 
    W. Mattingly, of Los Angeles, Cal., for respondents.0, ' Mr.Justice  BLACK  
    delivered  the  opinion  of the Court.0]} 
    
    {'file_name':'0001.txt0, 'lens': [101, 63, 57], 'lines': ['Rehearing Denied
    Dec. 16, 1946. See . Mr.Claude T. Barnes, of Salt Lake City, Utah, for petition-
    ers.0, ' Mr. Robert M. Hitchcock,  of  Washington,  D.C.,  for  respon-
    dent.0,  '  Mr.  Justice DOUGLAS delivered the opinion of the Court.0]}
    {'file_name': '0002.txt0, 'lens': [31, 7,  179],  'lines':  ['Rehearing
    Denied  Dec.  16,  19460, ' See .0, ' Appeal from the District Court of
    the United States for the  Western  District  of  Oklahoma.  Messrs.Dan
    Moody,  of  Austin,  Tex.,  and  Harry  O. Glasser, of Enid, Okla., for
    appellant.0]}   
    
    meta_data: {'total_lines': 9, 'file_count': 3, 'lines_per_file': 3}

    for  file in `ls  current_dir|grep ".txt$"`; do echo "$file"; done|head -3|       
    /Library/Frameworks/Python.framework/Versions/3.6/bin/python3 ./head_lister.py stdin 3 0 stdout

    for  file in `ls  txt_dir|grep ".txt$"`; do echo "$file"; done|head -3|
    python3 dir/head_lister.py stdin 3 0 stdout



     $  run_head_lister.sh   3   3   -l   60   
     set   number_of_files=3   
     set min_line_length=60  
     lines_per_file  3 
     number_of_files 3 
     min_line_length 60 
     input_file      stdin 
     scripts dir=.  
     total lines attempted to_read 9
      arg[1] lines per file to process: 3
      arg[2]  line  length  threshold to halt saving lines: 60 {'file_name':
     
    '0000.txt0, 'lens': [148], 'threshold_line': 1, 'lines': ['[  Hallibur-
     ton  Oil  Well Cementing Co. v. Walker Mr.Earl Babcock, of Duncan, Okl.
     (Harry C. Robb, of Washington, D.C., on the brief), for  petitioner.0]}
     {'file_name':  '0001.txt0, 'lens': [101], 'threshold_line': 1, 'lines':
     ['Rehearing Denied Dec. 16, 1946. See . Mr.Claude T.  Barnes,  of  Salt
     Lake  City, Utah, for petitioners.0]} 
      
     {'file_name': '0002.txt0, 'lens':[31, 7, 179], 'lines': ['Rehearing 
     Denied Dec. 16, 19460, ' See  .0,  'Appeal  from  the  District  Court 
     of the United States for the Western District of Oklahoma. Messrs.Dan 
     Moody, of Austin, Tex., and  Harry  O. Glasser,  of  Enid, Okla., for 
     appellant.0]} 
       
     meta_data: 5, 'file_count': 3, 'lines_per_file': 3, 'threshold_len': 60}

    for file in `ls  txt_dir|grep ".txt$"`; do echo "$file"; done|head  -3|
    Library/Frameworks/Python.framework/Versions/3.6/bin/python ./head_lister.py stdin 3 60 stdout

    for file in `ls  txt_dir|grep ".txt$"`; do echo "$file"; done|head  -3|
    python3 dir/head_lister.py stdin 3 60 stdout


    SEE ALSO
        
        head (1),

    BUGS
          
          Assumes  on  a  Mac,  python  3  is  located  here:  /Library/Frame-
       works/Python.framework/Versions/3.6/bin/python3  If  it  is  not,   the
       directory must be changed in the run_headlister.sh script.



                                                         run_head_lister.sh(1)
