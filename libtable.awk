# libtable.awk
#
# gawk library to generate good looking tables from text data, Comes 
# with the `table' user command. Depends on ngetopt.awk for command 
# line option parsing. 
#
# Written by Joep van Delft, 2014, 2015.
#
# Released under GPLv2, see LICENSE.
# 
# https://joepvd.github.com/table

BEGIN {
}

# The following functions return the glyph for a certain style, role and place
# tuple. 

function _table_psql_head(p, t){split("┌─┬┐", t, "");return t[p]}
function _table_psql_sep(p,  t){split("├─┼┤", t, "");return t[p]}
function _table_psql_row(p,  t){split("│ ││", t, "");return t[p]}
function _table_psql_foot(p, t){split("└─┴┘", t, "");return t[p]}

function _table_rst_head(p,  t){split("+-++", t, "");return p==1?"    "t[p]:t[p]}
function _table_rst_sep(p,   t){split("+=++", t, "");return p==1?"    "t[p]:t[p]}
function _table_rst_row(p,   t){split("| ||", t, "");return p==1?"    "t[p]:t[p]}
function _table_rst_foot(p,  t){split("+-++", t, "");return p==1?"    "t[p]:t[p]}

function _table_max(x, y) {
    return x>y?x:y
}

function make_table(contents,       i,j) {
    # The only user entry point for this library.  Takes one array as argument. 
    # Returns a string containing the whole table. 
    if (! isarray(contents)) {
        printf "libtable: Need to receive an array with contents to" >"/dev/stderr"
        printf "function `make_table()'\nExiting.\n"
        _assert_exit = 1
        exit
    }
    _table_analyze(contents)
    return _table_styler(contents)
}

function _table_analyze(contents,        row, col) {
    if (style == "") { style = "psql" }

    # Adds some meta data to the array `contents'. 
    if (! ("row_count" in contents)) {
        contents["row_count"] = length(contents)
    }
    # Warning: O(n^2)
    for (row=1; row in contents; row++) {
        contents["col_count"] = _table_max(contents["col_count"],
                                    length(contents[row]))
        for (col=1; col in contents[row]; col++) {
            contents["len"][col] = _table_max(contents["len"][col],
                                       length(contents[row][col]))
        }
    }
}

function _table_styler(contents,                string, i, j, empty) {
    for (j=1; j<=contents["col_count"]; j++) 
        empty[j] = ""
    for (i=1; i<=contents["row_count"]; i++) {
        if (i == 1)
            string = string _table_format_line(empty, "head", contents)
        if (style=="rst" && i>2)
            string = string _table_format_line(empty, "foot", contents) # Semantic bug
        string = string _table_format_line(contents[i], "row", contents)
        if (i==1 && header~/^(y|)$/)
            string = string _table_format_line(empty, "sep", contents)
        if (i==contents["row_count"])
            string = string _table_format_line(empty, "foot", contents)
    }
    return string
}

function _table_format_line(line, role, contents,            
                    string, glyph, i, cell, 
                    left, fill, middle, right) {
    # Variable initialization for character retrieval:
    left=1; fill=2; middle=3; right=4;

    glyph = "_table_"style"_"role

    # And construct string:
    for(i=1; i<=contents["col_count"]; i++) {
        cell = line[i]
        # For funny record separators and implicit newlines:
        sub(/[\r\n]+$/, "", cell)
        cell = _table_pad(cell, contents["len"][i], @glyph(fill))
        if (i == 1) 
            string = @glyph(left) cell
        else
            string = string @glyph(middle) cell
    }
    return string @glyph(right) "\n"
}

function _table_pad(string, width, padchar,        _s) {
    if ( length(string) > width )
        string = substr(string, 1, width)
    _s = padchar string
    while ( length(_s) <= width )
        _s = _s padchar
    return _s padchar
}

END {
    if (length(_assert_exit) > 0)
        exit _assert_exit
}
