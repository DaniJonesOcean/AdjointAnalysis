#!/bin/sh
ls -1 ADJtheta.000000*.data | grep -o '[0-9]\+' | sed 's/^0*//' > its_ad.txt
