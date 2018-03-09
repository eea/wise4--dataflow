xquery version "1.0" encoding "UTF-8";

import module namespace wqlagwb = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedDataByWaterBody' at 'qcs.xquery';

declare variable $source_url as xs:string external;

wqlagwb:run-checks($source_url)
