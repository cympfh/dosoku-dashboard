#!/bin/bash

bun taiju-plot >/dev/null
mv /tmp/bun.taiju.png ./static/

echo "<img src=./dashboard/static/bun.taiju.png />"
