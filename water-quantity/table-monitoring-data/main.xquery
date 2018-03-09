xquery version "1.0" encoding "UTF-8";

import module namespace wqnmndata = 'http://converters.eionet.europa.eu/wise/waterQuantity/monitoringData' at 'qcs.xquery';

declare variable $source_url as xs:string external;

wqnmndata:run-checks($source_url)
