xquery version "1.0" encoding "UTF-8";

import module namespace emissions = 'http://converters.eionet.europa.eu/wise/emissions/emissions' at 'qcs.xquery';

declare variable $source_url as xs:string external;

emissions:run-checks($source_url)
