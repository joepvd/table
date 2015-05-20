#!/usr/bin/gawk -E
#
# A small program to generate good looking tables from text data, 
# powered by all the field splitting magic that awk provides. Type
# `table --help` for usage details. 
#
# Depends on ngetopt.awk for command line option parsing. 
#
# Written by Joep van Delft, 2014
#
# TODO: x Put a left margin for rst output. 
#       o Move default values and possible values to the library. 
#       o Think of a more readable way to register the options. 
#       o Provide for a way to include a header from the command line
#         as a string.
#       o Improve usage() in nregopt. 
#       o Write documentation. 
#       - Strict mode. For when column count is not always the same.
#       - Sort data after a key (and preserve the header), or decide
#         that that is the domain of other tools.
#       - Include a title option that describes the whole table. 
#       - Make more styles available. 
#       - Line wrapping. Maximum widths. 
#
# Marked with `o` are to be done before the first release. 

@include "walkarray"

function table_init() {
    #opt_debug="y"
    
    if (style == "") { style = "psql" }
    permissible_styles["psql"]
    permissible_styles["rst"]


    if (! (style in permissible_styles)){
        printf("The selected style <%s> does not exist. Exiting\n",
               style) >"/dev/stderr"
        _assert_exit = 1
        exit 1
    }

    # Some variable initialization for character retrieval. 
    left=1; fill=2; middle=3; right=4;

    if (1 in contents) {} # Voila: contents is an array now.
}

# The following functions return the glyph for a certain style, role and place
# tuple. They are called as indirect functions, where the function name is 
# generated from variables. 

function psql_head(p, t){split("┌─┬┐", t, "");return t[p]}
function psql_sep(p,  t){split("├─┼┤", t, "");return t[p]}
function psql_row(p,  t){split("│ ││", t, "");return t[p]}
function psql_foot(p, t){split("└─┴┘", t, "");return t[p]}

function rst_head(p,  t){split("+-++", t, "");return p==1?"    "t[p]:t[p]}
function rst_sep(p,   t){split("+=++", t, "");return p==1?"    "t[p]:t[p]}
function rst_row(p,   t){split("| ||", t, "");return p==1?"    "t[p]:t[p]}
function rst_foot(p,  t){split("+-++", t, "");return p==1?"    "t[p]:t[p]}

function max(x, y) {
    return x>y?x:y
}

function format_line(line, role, contents,            glyph, i, cell) {
    glyph = style"_"role
    cell = pad(line[1], contents["len"][1], @glyph(fill))
    printf "%s%s", @glyph(left), cell
    for(i=2; i<=contents["col_count"]; i++) {
        cell = pad(line[i], contents["len"][i], @glyph(fill))
        printf "%s%s", @glyph(middle), cell
    }
    printf "%s\n", @glyph(right)
}

function pad(string, width, padchar,        _s) {
    # put character `padchar` around `string` so the result is `width + 2` long. 
    # `width + 2`, because there should always be a pad char to the left and to the 
    # right. 
    if ( length(string) > width )
        string = substr(string, 1, width)
    _s = padchar string
    while ( length(_s) <= width )
        _s = _s padchar
    return _s padchar
}

function colsize(contents,                  i,j,_len,m) {    
    # Establishing the maximum size of the column contents, 
    # store as a list in contents["len"]: 
    for (j=1; j<=contents["col_count"]; j++) {
        _len = 0
        for (i=1; i<=contents["row_count"]; i++)
            _len = max( _len, length(contents[i][j]) )
        contents["len"][j] = _len
    }
    if (debug == "yes") {
        printf "contents[\"len\"]: [%s", contents["len"][1]
        for (m=2; m<=length(contents["len"]); m++)
            printf ", %s", contents["len"][m]
        print "]"
    }
}

function styler(contents,                i, j, empty) {
    for (j=1; j<=contents["col_count"]; j++) 
        empty[j] = ""
    for (i=1; i<=contents["row_count"]; i++) {
        if (i == 1)
            format_line(empty, "head", contents)
        if (style=="rst" && i>2)
            format_line(empty, "foot", contents) # Semantic bug
        format_line(contents[i], "row", contents)
        if (i==1 && header~/^(y|)$/)
            format_line(empty, "sep", contents)
        if (i==contents["row_count"])
            format_line(empty, "foot", contents)
    }
}

function make_table(contents, debug,      i,j) {
    if (! isarray(contents)) {
        printf "libtable: Need to receive an array with contents to the function `make_table()'\nExiting.\n"
        exit 1
    }
    table_init()
    contents["row_count"] = length(contents) - 1    # Dirty hack for demanding "col_count" as part of the array
                                                    # Needs to be a library function. 
    colsize(contents)
    if (debug=="yes") {
        printf("Dimension of table: [%s x %s] ([rows x columns])\n",
               contents["row_count"], contents["col_count"]) >"/dev/stderr"
        for (i in contents) {
            if (i ~ /^(len|row_count|col_count)$/)
                continue
            for (j in contents[i]) {
                printf("table: contents[%s][%s]=%s\n",
                       i, j, contents[i][j]) >"/dev/stderr"
            }
        }
    }
    styler(contents)
}

