xquery version "1.0" encoding "UTF-8";

import module namespace wqldis = 'http://converters.eionet.europa.eu/wise/waterQuality/disaggregatedData' at 'qcs.xquery';

declare variable $source_url as xs:string external;

wqldis:run-checks($source_url)
