xquery version "1.0" encoding "UTF-8";

module namespace valconv = 'http://converters.eionet.europa.eu/common/valueConversion';

declare function valconv:boolean($value as xs:string?)
as xs:boolean?
{
    let $valueLowerCase := lower-case($value)
    return
        if (empty($value)) then
            ()
        else if ($value = "true" or $value = "1") then
            true()
        else if ($value = "false" or $value = "0") then
            false()
        else
            ()
};

declare function valconv:convertCountryCode($countryCode as xs:string)
as xs:string
{
    let $countryCodeLowerCase := lower-case($countryCode)
    return
        if ($countryCodeLowerCase = "gb") then
            "UK"
        else if ($countryCodeLowerCase = "gr") then
            "EL"
        else 
            $countryCode
};
