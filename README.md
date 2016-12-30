# cf-parser
Inspiration: https://github.com/lovrop/codeforces-scraper.

Creates directory for each problem in given contest. 
Parses problem statements and extracts sample inputs/outputs which are then written to files in problem directories.
Optionally, creates source files for each problem and fills them with given code template.

```
$ ./main -help
Codeforces contest parser

  main CONTEST_ID

=== flags ===

  [-dir dir]        directory to store problems. ./contest_id by default.
  [-temp filename]  code template to copy for each problem.
  [-build-info]     print info about this build and exit
  [-version]        print the version of this build and exit
  [-help]           print this help text and exit
                    (alias: -?)

```
