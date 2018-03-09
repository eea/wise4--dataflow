xquery version "1.0" encoding "UTF-8";

import module namespace wqlmdis = 'http://converters.eionet.europa.eu/wise/waterQualityMarine/disaggregatedData' at 'qcs.xquery';

declare variable $source_url as xs:string external;

wqlmdis:run-checks($source_url)
