xquery version "1.0" encoding "UTF-8";

module namespace util = 'http://converters.eionet.europa.eu/common/util';

declare function util:lower-case($values as xs:string*)
as xs:string*
{
    for $value in $values
    return lower-case($value)
};

declare function util:sort($values as xs:string*)
as xs:string*
{
    for $value in $values
    order by $value
    return $value
};
