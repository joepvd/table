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

function _table_analyze(contents,
                    row, col, left, fill, middle, right) {
    left=1; fill=2; middle=3; right=4;
    if (style == "") 
        style = "psql"
    # Define some arrays containing special characters. 
    if (style == "psql") {
        split("┌─┬┐", _table_head, "")
        split("├─┼┤", _table_sep,  "")
        split("│ ││", _table_row,  "")
        split("└─┴┘", _table_foot, "")
    }
    if (style == "rst") {
        split("+=++", _table_title, "")
        split("+-++", _table_head, "")
        split("+=++", _table_sep,  "")
        split("| ||", _table_row,  "")
        split("+-++", _table_foot, "")
    }
    if (style == "psql" && title != "") {
        split("╒══╕", _table_title, "")
        split("╞═╤╡", _table_head, "")
    }
    if (title != "" && style == "rst") {
        split("+=++", _table_head, "")
    }
    if (style == "rst" && _table_left_margin == "") {
        _table_left_margin = "    " 
    }
    if (style == "md") {
        split("^^^^", _table_title, "") # ^ will be skipped
        split("^^^^", _table_head, "") # ^ will be skipped
        split("| ;-; | ; |", _table_sep, ";")
        split("| ||", _table_row, "")
        split("^^^^", _table_foot, "") # ^ will be skipped
    }
    if (style == "jira") {
        split("^^^^", _table_title, "") # ^ will be skipped
        split("^^^^", _table_head, "") # ^ will be skipped
        split("||; ;||;||", _table_head_row, ";")
        split("^^^^", _table_sep, "") # will be skipped
        split("| ; ;| ; |", _table_row, ";")
        if (header == "no") {
            split("| ||", _table_row, "")
        }
        split("^^^^", _table_foot, "") # ^ will be skipped
    }

    # Adds some meta data to the array `contents'. 
    if (! ("row_count" in contents)) {
        contents["row_count"] = length(contents)
    }
    # Warning: O(n^2)
    for (row=1; row in contents; row++) {
        contents["col_count"] = _table_max(contents["col_count"],
                                    length(contents[row]))
        for (col=1; col in contents[row]; col++) {
            if (style == "md" && row == 1) {
                contents["len"][col] = 3
            }
            contents["len"][col] = _table_max(contents["len"][col],
                                       length(contents[row][col]))
        }
    }
}

function _table_styler(contents,                string, i, j, empty) {
    for (j=1; j<=contents["col_count"]; j++) 
        empty[j] = ""
    for (i=1; i<=contents["row_count"]; i++) {
        if (i == 1) {
            if (style != "jira") {
                string = string _table_format_line(empty, "head", contents)
            }
            if (title != "") {
                string = _table_make_title(title, contents["len"]) string
            }
        }
        if (style=="rst" && ( i>2 || i==2 && header == "no"))
            string = string _table_format_line(empty, "foot", contents) # Semantic bug
        if (i==1 && length( _table_head_row) > 0 && header != "no") {
            # jira formats the table row with contents special
            string = string _table_format_line(contents[i], "head_row", contents)
        } else {
            # The main processor
            string = string _table_format_line(contents[i], "row", contents)
        }
        if (i==1 && header~/^(y|)$/)
            string = string _table_format_line(empty, "sep", contents)
        if (i==contents["row_count"])
            string = string _table_format_line(empty, "foot", contents)
    }
    return string
}

function _table_make_title(title, arr,
                       i, s, len,
                       left, fill, middle, right) {
    left=1; fill=2; middle=3; right=4;

    if (SYMTAB["_table_title"][left] == "^" && SYMTAB["_table_title"][fill] == "^" && SYMTAB["_table_title"][middle] == "^" && SYMTAB["_table_title"][right] == "^") {
        return
    }

    for (c in arr)
        len += arr[c]
    len = len \
           + 2 * ( length(_table_row[left]) + length(_table_row[right]) ) \
           + 3 * ( length(arr) - 1 ) \
           - 4
    # the first line: 
    s = _table_left_margin \
        _table_title[left] \
        _table_pad_left("", len, _table_title[fill]) \
        _table_title[right] "\n"
    # The second line: 
    s = s \
        _table_left_margin \
        _table_row[left] \
        _table_pad_center(title, len, " ") \
        _table_row[right] "\n"
    return s
}

function _table_format_line(line, role, contents,            
                    line_str, glyph, i, cell, len,
                    left, fill, middle, right) {
    # Variable initialization for character retrieval:
    left=1; fill=2; middle=3; right=4;

    glyph = "_table_"role

    if (SYMTAB[glyph][left] == "^" && SYMTAB[glyph][fill] == "^" && SYMTAB[glyph][middle] == "^" && SYMTAB[glyph][right] == "^") {
        return
    }

    # And construct string:
    for (i=1; i<=contents["col_count"]; i++) {
        cell = line[i]
        # Remove trailing newlines (needed for custom record seperator):
        sub(/[\r\n]+$/, "", cell)
        len = contents["len"][i]
        if (role == "sep") {
            len = len - 2 * int(length(SYMTAB[glyph][middle])/2)
        }
        cell = _table_pad_left(cell, len, SYMTAB[glyph][fill])
        if (i == 1) {
            line_str = _table_left_margin SYMTAB[glyph][left] cell
        } else {
            line_str = line_str SYMTAB[glyph][middle] cell
        }
    }
    return line_str SYMTAB[glyph][right] "\n"
}

function _table_pad_left(string, width, padchar,        _s) {
    if ( length(string) > width )
        string = substr(string, 1, width)
    if (length(padchar) == 0) {
        return string
    }
    _s = padchar string
    while ( length(_s) <= width )
        _s = _s padchar
    return _s padchar
}

function _table_pad_right(string, width, padchar,     _s) {
    if ( length(string) > width )
        string = substr(string, 1, width)
    if (length(padchar)==0) {
        return string
    }
    _s = string padchar
    while (length(_s) <= width)
        _s = padchar _s
    return padchar _s
}

function _table_pad_center(string, width, padchar,    _s) {
    if ( length(string) > width )
        string = substr(string, 1, width)
    _s = padchar string
    while (length(_s) <= width) {
        if (length(_s)%2 == 0)
            _s = _s padchar
        else
            _s = padchar _s
    }
    return _s padchar
}

function _table_max(x, y) {
    return x>y?x:y
}

END {
    if (length(_assert_exit) > 0)
        exit _assert_exit
}

# vim: ts=4 sw=4 sts=4 et
