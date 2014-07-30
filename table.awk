#!/usr/bin/gawk

BEGIN {
    array[1]="qed"
    delete array

    if (id == "psql" || id == "") {
        if (debug == "y") print "selecting style psql"
        style["fill"]["head"]    = "─" 
        style["fill"]["row"]     = " " 
        style["fill"]["sep"]     = "─" 
        style["fill"]["foot"]    = "─" 
        style["left"]["head"]    = "┌"
        style["left"]["row"]     = "│"
        style["left"]["sep"]     = "├"
        style["left"]["foot"]    = "└"
        style["middle"]["head"]  = "┬"
        style["middle"]["row"]   = "│"
        style["middle"]["sep"]   = "┼"
        style["middle"]["foot"]  = "┴"
        style["right"]["head"]   = "┐"
        style["right"]["row"]    = "│"
        style["right"]["sep"]    = "┤"
        style["right"]["foot"]   = "┘"
    }
}

function max(x, y) {
    if (x > y) return x
    else return y
}

function format_line(to_print, stype) {
    printf "%s%s", style["left"][role], to_print[1]
    for(k=2; k<=length(to_print); k++) {
        printf "%s%s", style["middle"][role], to_print[k]
    }
    printf "%s\n", style["right"][role]
}

function pad(string, width, padchar) {
    # put character `padchar` around `string` so the result is `width + 2` long. 
    # `width + 2`, because there should always be a pad char to the left and to the 
    # right. 
    if ( length(padchar) != 1 ) {
        print "padding character should be a single character!"
        exit 1
    }
    if ( length(string) > width )
        string = substr(string, 1, width)
    _s = padchar string
    while ( length(_s) <= width )
        _s = _s padchar
    return _s padchar
}

function format_table(contents) {
    row_count = length(contents)
    col_count = length(contents[1])
    if (debug == "y") {
        printf "Dimension of table: [%s x %s] ([rows x columns])\n", row_count, col_count
    }
    
    # Establishing the maximum size of the column contents, 
    # store in contents["len"]: 
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

    for (i=1; i<=row_count; i++) {
        if (debug == "y") { printf "Formatting row %s.\n", i }
        if (i == 1) {
            role="head"
            for (j=1;j<=col_count;j++) {
                to_print[j] = pad("", contents["len"][j], style["fill"][role])
            }
            format_line(to_print, role)
        }
        role="row"
        for (j=1; j<=col_count; j++) {
            to_print[j] = pad(contents[i][j], contents["len"][j], style["fill"][role])
        }
        format_line(to_print, role)
        if ( i == 1 ) {
            role="sep"
            for (j=1; j<=col_count; j++) {
                to_print[j] = pad("", contents["len"][j], style["fill"][role])
            }
            format_line(to_print, role)
        }
        if ( i == row_count) {
            role="foot"
            for (j=1; j<= col_count; j++) {
                to_print[j] = pad("", contents["len"][j], style["fill"][role])
            }
            format_line(to_print, role)
        }
    }
}

{
    split($0, _tmp)
    for (i=1; i<=length(_tmp); i++) {
        contents[NR][i] = _tmp[i]
    }
}

ENDFILE {
    if (debug=="y") { for (i in contents) { for (j in contents[i]) { print i, j, contents[i][j] } } }
    format_table(contents)
}

