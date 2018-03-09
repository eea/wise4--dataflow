xquery version "1.0" encoding "UTF-8";

import module namespace emissions_directdischarges = 'http://converters.eionet.europa.eu/wise/emissions/directdischarges' at 'qcs.xquery';

declare variable $source_url as xs:string external;

emissions_directdischarges:run-checks($source_url)
