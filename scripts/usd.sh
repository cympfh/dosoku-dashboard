#!/bin/bash

URL=http://s.cympfh.cc

IM=./static/usd.png
TAIL=1000

# UCD -> JST
date-convert() {
    while read dt; do
        date --date "$dt" "+%Y-%m-%dT%H:%M"
    done
}

# record
curl -sL https://www.gaitameonline.com/rateaj/getrate | jq -c '.quotes[] | if .currencyPairCode == "AUDUSD" then . else empty end' > /tmp/aud_usd.json
curl -sL https://www.gaitameonline.com/rateaj/getrate | jq -c '.quotes[] | if .currencyPairCode == "EURUSD" then . else empty end' > /tmp/eur_usd.json
curl -sL https://www.gaitameonline.com/rateaj/getrate | jq -c '.quotes[] | if .currencyPairCode == "USDJPY" then . else empty end' > /tmp/usd_jpy.json
curl -sL -H "X-KEY: ${IK_KEY}" -XPOST "${URL}/aud/usd" --data @/tmp/aud_usd.json >/dev/null
curl -sL -H "X-KEY: ${IK_KEY}" -XPOST "${URL}/eur/usd" --data @/tmp/eur_usd.json >/dev/null
curl -sL -H "X-KEY: ${IK_KEY}" -XPOST "${URL}/usd/jpy" --data @/tmp/usd_jpy.json >/dev/null

# data
DAT_AUDUSD=/tmp/aud_usd.dat
PLOT_DATA_AUDUSD=/tmp/aud_usd.plot.data
DAT_EURUSD=/tmp/eur_usd.dat
PLOT_DATA_EURUSD=/tmp/eur_usd.plot.data
DAT_USDJPY=/tmp/usd_jpy.dat
PLOT_DATA_USDJPY=/tmp/usd_jpy.plot.data

curl -sL "$URL/aud/usd" | tail -n "$TAIL" >$DAT_AUDUSD
paste <( awk '{print $1}' $DAT_AUDUSD | date-convert ) <( awk 'BEGIN{FS="\t"} {print $2}' $DAT_AUDUSD | jq -r .bid ) <( awk 'BEGIN{FS="\t"}{print $2}' $DAT_AUDUSD |jq -r .ask ) >$PLOT_DATA_AUDUSD
curl -sL "$URL/eur/usd" | tail -n "$TAIL" >$DAT_EURUSD
paste <( awk '{print $1}' $DAT_EURUSD | date-convert ) <( awk 'BEGIN{FS="\t"} {print $2}' $DAT_EURUSD | jq -r .bid ) <( awk 'BEGIN{FS="\t"}{print $2}' $DAT_EURUSD |jq -r .ask ) >$PLOT_DATA_EURUSD
curl -sL "$URL/usd/jpy" | tail -n "$TAIL" >$DAT_USDJPY
paste <( awk '{print $1}' $DAT_USDJPY | date-convert ) <( awk 'BEGIN{FS="\t"} {print $2}' $DAT_USDJPY | jq -r .bid ) <( awk 'BEGIN{FS="\t"}{print $2}' $DAT_USDJPY |jq -r .ask ) >$PLOT_DATA_USDJPY

# plot
gnuplot <<EOM

set terminal pngcairo size 1600,1600
set output '${IM}'

set timefmt '%Y-%m-%dT%H:%M'
set xdata time
set format x '%Y-%m-%d %H:%M'
set xtics left rotate by -45

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

set multiplot layout 3,1

set ylabel 'AUD/USD' tc '#808080'
plot '$PLOT_DATA_AUDUSD' u 1:2 w points ls 1 title 'bid', '' u 1:2 smooth bezier ls 1 notitle, '' u 1:3 w points ls 2 title 'ask', '' u 1:3 ls 2 smooth bezier notitle
set ylabel 'EUR/USD' tc '#808080'
plot '$PLOT_DATA_EURUSD' u 1:2 w points ls 1 title 'bid', '' u 1:2 smooth bezier ls 1 notitle, '' u 1:3 w points ls 2 title 'ask', '' u 1:3 ls 2 smooth bezier notitle
set ylabel 'USD/JPY' tc '#808080'
plot '$PLOT_DATA_USDJPY' u 1:2 w points ls 1 title 'bid', '' u 1:2 smooth bezier ls 1 notitle, '' u 1:3 w points ls 2 title 'ask', '' u 1:3 ls 2 smooth bezier notitle
EOM

echo "<img src=./static/usd.png />"
