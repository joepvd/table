========
libtable
========

----------------------------------------------------------
Returns string containing table from two-dimensional array
----------------------------------------------------------


DESCRIPTION
===========

``gawk`` library that converts a two-dimensional array into a string with a nicely formatted table.  Closely tight to the user command ``table``.


USAGE
=====

.. code:: 

   @include "libtable"
   printf make_table(two_dimensional_array)



gawk library to represent a two dimensional array in a visually attractive table. 

CONFIGURATION
=============


Configuration happens through global variables.  The following are listened to: 

style
    The style of the table.  Currently recongnized: ``psql`` and ``rst``. 

debug
    Put debugging info to STDERR

header
    Default: Yes. Set to ``no`` to disable the header.

_table_left_margin
    String to prepend each table line with.
