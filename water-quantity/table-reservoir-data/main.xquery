xquery version "1.0" encoding "UTF-8";

import module namespace wqnresvdata = 'http://converters.eionet.europa.eu/wise/waterQuantity/reservoirData' at 'qcs.xquery';

declare variable $source_url as xs:string external;

wqnresvdata:run-checks($source_url)
