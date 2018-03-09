xquery version "1.0" encoding "UTF-8";

import module namespace wqnwaterret = 'http://converters.eionet.europa.eu/wise/waterQuantity/waterReturns' at 'qcs.xquery';

declare variable $source_url as xs:string external;

wqnwaterret:run-checks($source_url)
