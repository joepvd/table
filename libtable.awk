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
    # Define some arrays containing special characters. 
    split("┌─┬┐", _table_psql_head, "")
    split("├─┼┤", _table_psql_sep,  "")
    split("│ ││", _table_psql_row,  "")
    split("└─┴┘", _table_psql_foot, "")

    split("+-++", _table_rst_head, "")
    split("+=++", _table_rst_sep, "")
    split("| ||", _table_rst_row, "")
    split("+-++", _table_rst_foot, "")
}

function make_table(contents,       i,j) {
    # The only user entry point for this library.  Takes one array as argument. 
    # Returns a string containing the whole table. 
    if (! isarray(contents)) {
        printf "libtable: Need to receive an array with contents to" >"/dev/stderr"
        printf "function `make_table()'\nExiting.\n" >"/dev/stderr"
        _assert_exit = 1
        exit
    }
    _table_analyze(contents)
    return _table_styler(contents)
}

function _table_analyze(contents,        row, col) {
    if (style == "") { style = "psql" }
    if (style == "rst") { _table_left_margin = "    " }

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
        if (style=="rst" && ( i>2 || i==2 && header == "no"))
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
                    line_str, glyph, i, cell, 
                    left, fill, middle, right) {
    # Variable initialization for character retrieval:
    left=1; fill=2; middle=3; right=4;

    glyph = "_table_"style"_"role

    # And construct string:
    for (i=1; i<=contents["col_count"]; i++) {
        cell = line[i]
        # Remove trailing newlines (needed for `--rs`):
        sub(/[\r\n]+$/, "", cell)
        cell = _table_pad(cell, contents["len"][i], SYMTAB[glyph][fill])
        if (i == 1) 
            line_str = _table_left_margin SYMTAB[glyph][left] cell
        else
            line_str = line_str SYMTAB[glyph][middle] cell
    }
    return line_str SYMTAB[glyph][right] "\n"
}

function _table_pad(string, width, padchar,        _s) {
    if ( length(string) > width )
        string = substr(string, 1, width)
    _s = padchar string
    while ( length(_s) <= width )
        _s = _s padchar
    return _s padchar
}

function _table_max(x, y) {
    return x>y?x:y
}

END {
    if (length(_assert_exit) > 0)
        exit _assert_exit
}
