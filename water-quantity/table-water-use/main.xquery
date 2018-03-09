xquery version "1.0" encoding "UTF-8";

import module namespace wqnwateruse = 'http://converters.eionet.europa.eu/wise/waterQuantity/waterUse' at 'qcs.xquery';

declare variable $source_url as xs:string external;

wqnwateruse:run-checks($source_url)
