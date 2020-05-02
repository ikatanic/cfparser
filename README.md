# cf-parser
This is a simple tool for scraping contest data from codeforces.com.

Given a contest id, it will:
- create a directory for each problem
- write sample inputs/outputs to files
- create a solution source files from the given template (optional)

## Install
Recommended way to install is through OPAM:
```
$ opam pin add cfparser git@github.com:ikatanic/cfparser.git
```

## Usage
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

## Example
```
$ cfparser 901 -temp template.cpp
Found 5 problems.
Problem B: written 2 samples.
Problem D: written 4 samples.
Problem C: written 2 samples.
Problem E: written 3 samples.
Problem A: written 2 samples.

$ tree 901
901
├── A
│   ├── A.cpp
│   ├── in1
│   ├── in2
│   ├── out1
│   └── out2
├── B
│   ├── B.cpp
│   ├── in1
│   ├── in2
│   ├── out1
│   └── out2
...
```




