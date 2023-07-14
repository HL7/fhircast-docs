This folder holds the "Railroad Diagram Generator" (see below) and a set of shell scripts
that allow generation of EBNF railroad diagrams based on EBNF input files.

Files and folders:
  _createAllEbnfPng.sh
    Shell script that runs _createEbnfPng.sh on all ebnf files in input and copies the resulting png files to input/images
  _createEbnfPng.sh
    Shell script that takes an ebnf file as input and generates an png file in the diagram directory
  input/
    directory that holds the ebnf files
  diagram/
    directory that holds the generated png files
  rr.war
    The Railroad Diagram Generator
  LICENSE/
    directory that holds the Railroad Diagram Generator license information.


===============================


RR - Railroad Diagram Generator

  version 1.63
  released Mar 13, 2021
  from https://bottlecaps.de/rr

Usage: java -jar rr.war {-suppressebnf|-keeprecursion|-nofactoring|-noinline|-noepsilon|-color:COLOR|-offset:OFFSET|-png|-md|-out:FILE|width:PIXELS}... GRAMMAR
    or java -jar rr.war -gui [-port:PORT]

  -suppressebnf    do not show EBNF next to generated diagrams
  -keeprecursion   no direct recursion elimination
  -nofactoring     no left or right factoring
  -noinline        do not inline nonterminals that derive to single literals
  -noepsilon       remove nonterminal references that derive to epsilon only
  -color:COLOR     use COLOR as base color, pattern: #[0-9a-fA-F]{6}
  -offset:OFFSET   hue offset to secondary color in degrees
  -png             create HTML+PNG in a ZIP file, rather than XHTML+SVG output
  -out:FILE        create FILE, rather than writing result to standard output
  -width:PIXELS    try to break graphics into multiple lines, when width exceeds PIXELS (default 992)

  GRAMMAR          path of grammar, in W3C style EBNF, default encoding (use '-' for stdin)

  -gui             run GUI on http://localhost:8080/
  -port:PORT       use PORT rather than 8080

rr.war is an executable war file. It can be run with "java -jar" as shown
above, but it can also be deployed in servlet containers like Tomcat or Jetty.
