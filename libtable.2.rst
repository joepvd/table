========
libtable
========

----------------------------------------------------------
Returns string containing table from two-dimensional array
----------------------------------------------------------


DESCRIPTION
===========

``gawk`` library that converts a two-dimensional array into a string with a nicely formatted table.  Closely tight to the user command ``table``. **WARNING** this library is not yet stable. 


USAGE
=====

.. code:: 

   @include "libtable"
   printf make_table(two_dimensional_array)



gawk library to represent a two dimensional array in a visually attractive table. 

CONFIGURATION
=============

The interface is not stable yet.  Claiming this list of global variables probably is not a good idea.  I have, however, not yet come to an elegant solution. 


Configuration happens through global variables.  The following are listened to: 

style
    The style of the table.  Currently recongnized: ``psql``, ``rst``, and ``md``.

debug
    Put debugging info to STDERR

header
    Default: Yes. Set to ``no`` to disable the header.

_table_left_margin
    String to prepend each table line with.
