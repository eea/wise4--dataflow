xquery version "1.0" encoding "UTF-8";

module namespace vldcountrycode = 'http://converters.eionet.europa.eu/wise/common/validators/countryCode';

import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../common/data.xquery";
import module namespace qclevels = "http://converters.eionet.europa.eu/common/qclevels" at "../../common/qclevels.xquery";
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../common/validators/validation-result.xquery';

declare function vldcountrycode:validate-country-code(
    $columnCountryCode as element(column), 
    $envelope as element(envelope), 
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $envelopeCountryCode := lower-case(string($envelope/countrycode))
    let $resultRows := vldcountrycode:_validate($columnCountryCode, $envelopeCountryCode, $dataRows, 1, ())
    let $valueCounts := vldres:calculate-column-value-counts($resultRows, $columnCountryCode)
    return vldres:create-result($resultRows, $valueCounts)
};

declare function vldcountrycode:_validate(
    $columnCountryCode as element(column), 
    $envelopeCountryCode as xs:string,
    $dataRows as element(dataRow)*,
    $dataRowIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    if ($dataRowIndex > count($dataRows)) then
        $resultRows
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $rowResult := vldcountrycode:_validate-row($columnCountryCode, $envelopeCountryCode, $dataRow)
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldcountrycode:_validate($columnCountryCode, $envelopeCountryCode, $dataRows, $dataRowIndex + 1, $newResultRows)
};

declare function vldcountrycode:_validate-row(
    $columnCountryCode as element(column), 
    $envelopeCountryCode as xs:string,
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $countryCodes := data:get-row-values($dataRow, $columnCountryCode)
    let $flaggedValues :=
        for $countryCode in $countryCodes
        return
            if ($countryCode = "" or lower-case($countryCode) = $envelopeCountryCode) then
                ()
            else
                vldres:create-flagged-value($qclevels:BLOCKER, $countryCode)
    return
        if (empty($flaggedValues)) then
            ()
        else
            let $flaggedColumn := vldres:create-flagged-column-by-values($columnCountryCode, $flaggedValues)
            return vldres:create-result-row($dataRow, $flaggedColumn)
};
