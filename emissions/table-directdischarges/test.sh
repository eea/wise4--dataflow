#!/bin/sh
~/work/basex/bin/basex -bsource_url=WISE-SoE_Emissions_newSchema_DirectDischarges.xml main.xquery > out.html && google-chrome-stable out.html