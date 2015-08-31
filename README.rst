table
=====

Facts become valuable if they are presented attractively.  Console junkies often need to take refuge to spreadsheet programs to display and present their findings to customers and managers.  ``table`` attempts to obliterate the need to interrupt the console workflow by presenting tabular data in a human digestible form.  

Let the console speak for itself: 

.. code::

    % ps | table 
    ┌─────┬───────┬──────────┬───────┐
    │ PID │ TTY   │ TIME     │ CMD   │
    ├─────┼───────┼──────────┼───────┤
    │ 139 │ pts/3 │ 00:00:00 │ zsh   │
    │ 219 │ pts/3 │ 00:00:00 │ ps    │
    │ 220 │ pts/3 │ 00:00:00 │ table │
    └─────┴───────┴──────────┴───────┘


``table`` receives input on `STDIN` or from file(s), and makes an attractive looking table from this.  A growing number of options and output numbers is supported.  As ``table`` is written in ``gawk`` version 4 or more recent, all goodies like regex support for field splitting are available.  Some highlights (consult `man 1 table` for for an extensive list): 

--rst
    Output a table for reStructuredText

--title STRING
    Set a centered title spanning all the columns.

--field-separator
    Define the AWK-field separator to be used. 

--no-header
    Do not display titles for columns.

libtable.awk
++++++++++++

``table`` is a front end for the included ``gawk`` library ``libtable``.  This is of interest to ``gawk`` programmers, and allows an array to be passed to ``make_table``, after which a properly formatted table will be returned.

As of yet, the library should be considered unstable.  The usage of global variables for configuration is conventient, yet wrong.  Attemps to make this nicer resulted in ugliness.  Suggestions are welcome. 

Installation
++++++++++++

The ``table`` command depends on ``gawk`` version 4 or newer. And the command line processing library ngetopt.awk_.  

.. _ngetopt.awk: https://github.com/joepvd/ngetopt.awk

Make sure that ``libtable.awk`` and ``ngetopt.awk`` are in ``AWKPATH``.  On many distributions, this will be ``/usr/share/awk``, or ``/usr/local/share/awk`` (OS X). You can find out what ``AWKPATH`` is by executing ``gawk 'BEGIN{print ENVIRON["GAWKPATH"]}'``.


Bugs
++++

Probably.  Pull requests or issues welcome over at GitHub_.

.. _GitHub: https://github.com/joepvd/table





