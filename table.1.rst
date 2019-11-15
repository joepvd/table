=====
table
=====

-----------------------
Display text in a table
-----------------------

:Author: joepvd
:Date: 2015-03-29
:Copyright: GPLv2
:Version: 0.2
:Manual section: 1
:Manual group: Text processing

SYNOPSIS
========


table [-h|--help] [-F|--field-separator] [-R|--record-separator] [-H|--no-header] [-d|--debug]
[-s|--style [rst|psql|md|jira]|--rst|--psql|--md|--jira] [files]

DESCRIPTION
===========

``table`` takes text as fields and records and transforms it as a table.  Inspiration has been taken from the excellent capabilities of ``psql``, the default query tool of PostgreSQL.  Output can be as a ``reStructuredText``-table or with unicode line characters.  Field and record splitting, the facilities of ``awk`` are enabled.


OPTIONS
=======

-h|--help
    display usage info

-s|--style
    Select a table formatting style. Currently available are **md**, **rst**, **jira**, and **psql** (default).

--rst
    Short for ``--style rst``

--psql
    Short for ``--style psql``

--md
   Short for ``--style md``

--jira
   Short for ``--style jira``

-F|--field-separator
    Equivalent to ``awk``. Set the field separator. Default is ``[ \t\n]+``. Example: ``-F,`` separates on comma's.

-R|--record-separator
    Set the record separator for input files.

-H|--no-header
    Do not consider the first line of input as the table header.

-T|--title
    Set a title.  This string will be centered along the width of the whole table. (Not supported for markdown and jira)

-d|--debug
    Output debugging info.

--left-margin
    Prepend the resulting table with an arbitrary string.  Handy for outlining.

DEPENDENCIES
============

``table`` depends on the ``gawk`` version 4 or newer, and the command line option processing library ``ngetopt.awk``, available from https://github.com/joepvd/ngetopt.awk.


BUGS
====

Please send a pull request or open a ticket on https://github.com/joepvd/table.


SEE ALSO
========

``libtable(2)``
