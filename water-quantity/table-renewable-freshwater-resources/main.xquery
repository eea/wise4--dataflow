xquery version "1.0" encoding "UTF-8";

import module namespace wqnrenfresh = 'http://converters.eionet.europa.eu/wise/waterQuantity/renewableFreshwaterResources' at 'qcs.xquery';

declare variable $source_url as xs:string external;

wqnrenfresh:run-checks($source_url)
