#!/bin/bash

taiju plot >/dev/null
mv /tmp/w.png ./static/

echo "<img src=./static/w.png />"
