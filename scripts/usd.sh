#!/bin/bash

URL=http://s.cympfh.cc/usd/jpy
DAT=/tmp/usd_jpy.dat
PLOT_DATA=/tmp/usd_jpy.plot.data
IM=./static/usd.png
SINCE=
TAIL=1000

# UCD -> JST
date-convert() {
    while read dt; do
        date --date "$dt" "+%Y-%m-%dT%H:%M"
    done
}

# data
curl -sL "$URL" | tail -n "$TAIL" >$DAT
paste <( awk '{print $1}' $DAT | date-convert ) <( awk 'BEGIN{FS="\t"} {print $2}' $DAT | jq -r .bid ) <( awk 'BEGIN{FS="\t"}{print $2}' $DAT |jq -r .ask ) >$PLOT_DATA

# plot
gnuplot <<EOM

set terminal pngcairo size 1600,800
set output '${IM}'

set timefmt '%Y-%m-%dT%H:%M'
set xdata time
set format x '%Y-%m-%d %H:%M'
set xtics left rotate by -45
set ylabel 'JPY' tc '#808080'

set style line 11 lc rgb '#808080' lt 1 lw 2
set border 0 back ls 11
set tics out nomirror
set key below right

# Standard grid
set style line 12 lc rgb '#808080' lt 0 lw 1
set grid back ls 12

# main line
set style line 1 pt 6 lw 2 lc rgb "#00aaaa" ps 1
set style line 2 pt 6 lw 2 lc rgb "#ddaaaa" ps 1

plot '$PLOT_DATA' u 1:2 w points ls 1 title 'bid', '' u 1:2 smooth bezier ls 1 notitle, '' u 1:3 w points ls 2 title 'ask', '' u 1:3 ls 2 smooth bezier notitle
EOM

echo "<img src=./static/usd.png />"
