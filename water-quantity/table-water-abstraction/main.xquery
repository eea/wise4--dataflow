xquery version "1.0" encoding "UTF-8";

import module namespace wqnwaterabs = 'http://converters.eionet.europa.eu/wise/waterQuantity/waterAbstraction' at 'qcs.xquery';

declare variable $source_url as xs:string external;

wqnwaterabs:run-checks($source_url)
