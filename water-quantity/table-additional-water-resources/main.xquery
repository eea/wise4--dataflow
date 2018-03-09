xquery version "1.0" encoding "UTF-8";

import module namespace wqnadwaterres = 'http://converters.eionet.europa.eu/wise/waterQuantity/additionalWaterResources' at 'qcs.xquery';

declare variable $source_url as xs:string external;

wqnadwaterres:run-checks($source_url)
