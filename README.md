# cf-parser
This is a simple tool used to scrape contest data from codeforces.com.

Given a contest id, it:
- creates a directory for each problem
- writes sample inputs/outputs to files
- creates a solution source files from the given template (optional)

## Example
Running
```
$ cfparser 901 -temp template.cpp
```
results in the following file structure:

```
$ ls 901/*
901/A:
A.cpp  in1  in2  out1  out2

901/B:
B.cpp  in1  in2  out1  out2

901/C:
C.cpp  in1  in2  out1  out2

901/D:
D.cpp  in1  in2  in3  in4  out1  out2  out3  out4

901/E:
E.cpp  in1  in2  in3  out1  out2  out3
```


## Installing
Easiest way to install is through OPAM:
```
$ opam pin add cfparser git@github.com:ikatanic/cfparser.git
```

## Usage help
```
$ cfparser -help
Codeforces contest parser

  cfparser CONTEST_ID

=== flags ===

  [-dir dir]        directory to store problems. ./contest_id by default.
  [-temp filename]  code template to copy for each problem.
  [-build-info]     print info about this build and exit
  [-version]        print the version of this build and exit
  [-help]           print this help text and exit
                    (alias: -?)
```
