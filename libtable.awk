# gawk library to generate good looking tables from text data, 
#
# Comes with the `table' user command. 
#
# Depends on ngetopt.awk for command line option parsing. 
#
# Written by Joep van Delft, 2014, 2015, 
# 
# https://joepvd.github.com/table
#
# TODO: x Put a left margin for rst output. 
#       o Provide for a way to include a header from the command line
#         as a string.
#       o Write documentation. 
#       - Strict mode. For when column count is not always the same.
#       - Sort data after a key (and preserve the header), or decide
#         that that is the domain of other tools.
#       - Include a title option that describes the whole table. 
#       - Make more styles available. 
#       - Line wrapping. Maximum widths. 

@include "walkarray"

function _table_init(                              permissible_styles) {
    if (style == "") { style = "psql" }
    permissible_styles["psql"]
    permissible_styles["rst"]

    if (! (style in permissible_styles)){
        printf("The selected style <%s> does not exist. Exiting\n",
               style) >"/dev/stderr"
        _assert_exit = 1
        exit
    }

    # Some variable initialization for character retrieval. 
    left=1; fill=2; middle=3; right=4;

    if (1 in contents) {} # Voila: contents is an array now.
}

# The following functions return the glyph for a certain style, role and place
# tuple. They are called as indirect functions, where the function name is 
# generated from variables. 

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

function _table_format_line(line, role, contents,            string, glyph, i, cell) {
    glyph = "_table_"style"_"role
    cell = _table_pad(line[1], contents["len"][1], @glyph(fill))
    string = @glyph(left) cell
    for(i=2; i<=contents["col_count"]; i++) {
        cell = _table_pad(line[i], contents["len"][i], @glyph(fill))
        string = string @glyph(middle) cell
    }
    return string @glyph(right) "\n"
}

function _table_pad(string, width, padchar,        _s) {
    # put character `padchar` around `string` so the result is `width + 2` long. 
    # `width + 2`, because there should always be a _table_padchar to the left and to the 
    # right. 
    if ( length(string) > width )
        string = substr(string, 1, width)
    _s = padchar string
    while ( length(_s) <= width )
        _s = _s padchar
    return _s padchar
}

function _table_analyze(contents,        row, col) {
    # Adds some meta data to the array `contents'. 
    if (! ("row_count" in contents)) {
        contents["row_count"] = length(contents)
    }
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

function make_table(contents, debug,      i,j) {
    if (! isarray(contents)) {
        printf "libtable: Need to receive an array with contents to" >"/dev/stderr"
        printf "function `make_table()'\nExiting.\n"
        _assert_exit = 1
        exit
    }
    _table_init()
    _table_analyze(contents)
    if (debug=="yes") {
        walk_array(contents, "libtable: contents")
    }
    return _table_styler(contents)
}

END {
    if (length(_assert_exit) > 0)
        exit _assert_exit
}
