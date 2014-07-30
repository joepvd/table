#!/usr/bin/gawk -f

BEGIN {
    left=1; fill=2;middle=3;right=4;
    style="rst"
    # header="n"
}

# top
# row
# head
# row
# sep
# row
# bot

function psql_head(place,   tmp) { split("┌─┬┐", tmp, ""); return tmp[place] }
function psql_sep(place,    tmp) { split("├─┼┤", tmp, ""); return tmp[place] }
function psql_row(place,    tmp) { split("│ ││", tmp, ""); return tmp[place] }
function psql_foot(place,   tmp) { split("└─┴┘", tmp, ""); return tmp[place] }

function rst_head(place,    tmp) { split("+-++", tmp, ""); return tmp[place] }
function rst_sep(place,     tmp) { split("+=++", tmp, ""); return tmp[place] }
function rst_row(place,     tmp) { split("| ||", tmp, ""); return tmp[place] }
function rst_foot(place,    tmp) { split("+-++", tmp, ""); return tmp[place] }

function max(x, y) {
    if (x > y) return x
    else return y
}

function format_line(line, role,            glyph, i) {
    glyph = style"_"role
    printf "%s%s", @glyph(left), pad(line[1], contents["len"][1], @glyph(fill))
    for(i=2; i<=length(line); i++)
        printf "%s%s", @glyph(middle), pad(line[i], contents["len"][i], @glyph(fill))
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
    for (j=1; j<=col_count; j++) {
        _len = 0
        for (i=1; i<=row_count; i++) {
            _len = max( _len, length(contents[i][j]) )
        }
        contents["len"][j] = _len
    }
    if (debug == "y") {
        printf "contents[\"len\"]: [%s", contents["len"][1]
        for (m=2; m<=length(contents["len"]); m++) {
            printf ", %s", contents["len"][m]
        }
        print "]"
    }
}

function styler(contents,                   i, j, empty) {
    for (j=1; j<=col_count; j++) 
        empty[j] = ""
    for (i=1; i<=row_count; i++) {
        if (i==1)
            format_line(empty, "head")
        if (style=="rst" && i>2)
            format_line(empty, "foot") # Semantic bug
        format_line(contents[i], "row")
        if (i==1 && header~/^(y|)$/)
            format_line(empty, "sep")
        if (i==row_count)
            format_line(empty, "foot")
    }
}

{
    # Storing the records in a two-dimensional array contents: 
    split($0, tmp)
    for (i=1; i<=length(tmp); i++)
        contents[NR][i] = tmp[i]
    delete tmp
}

ENDFILE {
    if (debug=="y") { for (i in contents) { for (j in contents[i]) { print i, j, contents[i][j] } } }
    row_count = length(contents)
    col_count = length(contents[1])
    colsize(contents)
    if (debug == "y") { printf "Dimension of table: [%s x %s] ([rows x columns])\n", row_count, col_count }
    styler(contents)
}

