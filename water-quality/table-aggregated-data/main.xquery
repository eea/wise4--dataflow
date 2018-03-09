xquery version "1.0" encoding "UTF-8";

import module namespace wqlagg = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedData' at 'qcs.xquery';

declare variable $source_url as xs:string external;

wqlagg:run-checks($source_url)
