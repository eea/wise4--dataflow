xquery version "1.0" encoding "UTF-8";

import module namespace emissions_riverineinputloads = 'http://converters.eionet.europa.eu/wise/emissions/riverineinputloads' at 'qcs.xquery';

declare variable $source_url as xs:string external;

emissions_riverineinputloads:run-checks($source_url)
