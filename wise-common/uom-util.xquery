xquery version "1.0" encoding "UTF-8";

module namespace uomutil = 'http://converters.eionet.europa.eu/wise/common/uomUtil';

import module namespace rdfutil = "http://converters.eionet.europa.eu/common/rdfutil" at "../common/rdf-util.xquery";
import module namespace util = "http://converters.eionet.europa.eu/common/util" at "../common/util.xquery";

declare function uomutil:has-determinant($concept as element(), $observedPropertyDeterminandUri as xs:string)
as xs:boolean
{
    uomutil:_has-property-with-resource-uri($concept, "hasDeterminand", $observedPropertyDeterminandUri)
};

declare function uomutil:has-uom($concept as element(), $uomUri as xs:string)
as xs:boolean
{
    uomutil:_has-property-with-resource-uri($concept, "hasUom", $uomUri)
};

declare function uomutil:has-table($concept as element(), $tableName as xs:string)
as xs:boolean
{
    uomutil:_has-property-with-resource-uri($concept, "hasTable", $tableName)
};

declare function uomutil:get-determinant-uri($concept as element())
as xs:string?
{
    uomutil:_get-property-resource-uri($concept, "hasDeterminand")
};

declare function uomutil:get-uom-uri($concept as element())
as xs:string?
{
    uomutil:_get-property-resource-uri($concept, "hasUom")
};

declare function uomutil:get-table-uri($concept as element())
as xs:string?
{
    uomutil:_get-property-resource-uri($concept, "hasTable")
};

declare function uomutil:_has-property-with-resource-uri($concept as element(), $propertyName as xs:string, $uri as xs:string)
as xs:boolean
{
    let $propertyUris := uomutil:_get-property-resource-uri($concept, $propertyName)
    return lower-case($uri) = $propertyUris
};

declare function uomutil:_get-property-resource-uri($concept as element(), $propertyName as xs:string)
as xs:string?
{
    let $propertyUris := util:lower-case(data($concept/*[local-name(.) = $propertyName]/rdfutil:resource(.)))
    return if (empty($propertyUris)) then () else $propertyUris[1]
};
