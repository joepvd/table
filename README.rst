=====
table
=====

-----------------------
display text in a table
-----------------------

:Author: joepvd
:Date: 2015-03-29
:Copyright: GPLv2
:Version: 0.1
:Manual section: 1
:Manual group: Text processing

SYNOPSIS
========


table [-h|--help] [-F|--field-separator] [-H|--no-header] [-d|--debug]
[-s|--style [rst|psql]|--rst|psql] [files]


OPTIONS
=======

-h|--help
    display usage info

-s|--style
    Select a table formatting style. Currently available are **rst** and **psql** (default).  

--rst
    Short for ``--style rst``

--psql
    Short for ``--style psql``

-F|--field-separator
    Equivalent to ``awk``. Set the field separator. Default is ``[ \t\n]+``. Example: ``-F,`` separates on comma's. 

-H|--no-header
    Do not consider the first line of input as the table header. 

-d|--debug
    Output debugging info.

DESCRIPTION
===========

``table`` reads files on ``STDIN`` or from the command line, and tries to output a table in the terminal. Inspiration has been taken from the excellent capabilities of ``psql``, the default query tool of PostgreSQL.   

DEPENDENCIES
============

``table`` depends on the ``gawk`` command line option processing library ``ngetopt.awk``, available from https://github.com/joepvd/ngetopt.awk.


BUGS
====

Please send a pull request or open a ticket on https://github.com/joepvd/table. 
