#!/bin/bash

bun taiju-plot >/dev/null
mv /tmp/bun.taiju.png ./static/

echo "<img src=./static/bun.taiju.png />"
