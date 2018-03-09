xquery version "1.0" encoding "UTF-8";

module namespace vldspunitid = 'http://converters.eionet.europa.eu/wise/common/validators/spatialUnitIdentifier';

import module namespace datax = "http://converters.eionet.europa.eu/common/dataExtensions" at "../../common/data-extensions.xquery";
import module namespace qclevels = "http://converters.eionet.europa.eu/common/qclevels" at "../../common/qclevels.xquery";
import module namespace util = "http://converters.eionet.europa.eu/common/util" at "../../common/util.xquery";
import module namespace valconv = "http://converters.eionet.europa.eu/common/valueConversion" at "../../common/value-conversion.xquery";
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../common/validators/validation-result.xquery';
import module namespace vldinterid = 'http://converters.eionet.europa.eu/wise/common/validators/internationalIdentifier' at './vld-international-identifier.xquery';

declare function vldspunitid:validate-spatial-unit-identifier-format(
    $columnSpatialUnitIdentifier as element(column),
    $columnSpatialUnitIdentifierScheme as element(column), 
    $envelope as element(envelope), 
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $envelopeCountryCode := lower-case(valconv:convertCountryCode(string($envelope/countrycode)))
    let $resultRows := vldspunitid:_validate-spatial-unit-identifier-format(
        $columnSpatialUnitIdentifier, $columnSpatialUnitIdentifierScheme, $envelopeCountryCode, $dataRows, 1, ()
    )
    let $columnCounts := vldres:calculate-column-counts($resultRows, $columnSpatialUnitIdentifier)
    return
        vldres:create-result($resultRows, $columnCounts)
};

declare function vldspunitid:_validate-spatial-unit-identifier-format(
    $columnSpatialUnitIdentifier as element(column),
    $columnSpatialUnitIdentifierScheme as element(column), 
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
        let $rowResult := vldspunitid:_validate-spatial-unit-identifier-format-row(
            $columnSpatialUnitIdentifier, $columnSpatialUnitIdentifierScheme, $envelopeCountryCode, $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldspunitid:_validate-spatial-unit-identifier-format(
            $columnSpatialUnitIdentifier, $columnSpatialUnitIdentifierScheme, $envelopeCountryCode, $dataRows, $dataRowIndex + 1, $newResultRows
        )
};

declare function vldspunitid:_validate-spatial-unit-identifier-format-row(
    $columnSpatialUnitIdentifier as element(column),
    $columnSpatialUnitIdentifierScheme as element(column), 
    $envelopeCountryCode as xs:string, 
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $siteId := datax:get-row-value($dataRow, $columnSpatialUnitIdentifier)
    let $siteIdScheme := datax:get-row-value($dataRow, $columnSpatialUnitIdentifierScheme)
    let $flaggedValues :=
        if (empty($siteId) or $siteId = "" or empty($siteIdScheme) or $siteIdScheme = "" or 
            vldspunitid:_is-valid-format-identifier($siteId, $siteIdScheme, $envelopeCountryCode)) then
            ()
        else
            vldres:create-flagged-value($qclevels:BLOCKER, $siteId)
    return
        if (empty($flaggedValues)) then
            ()
        else
            vldres:create-result-row($dataRow, vldres:create-flagged-column-by-values($columnSpatialUnitIdentifier, $flaggedValues))
};

declare function vldspunitid:_is-valid-format-identifier(
    $siteId as xs:string, 
    $siteIdScheme as xs:string, 
    $countryCodeLowerCase as xs:string
)
as xs:boolean
{
    if (lower-case($siteIdScheme) = "countrycode") then
        matches($siteId, "^[A-Z]{2}$") and vldinterid:is-country-code-match($siteId, $countryCodeLowerCase)
    else
        vldinterid:is-valid-format-identifier($siteId, $countryCodeLowerCase)
};

declare function vldspunitid:validate-spatial-unit-identifier-reference(
    $columnSpatialUnitIdentifier as element(column),
    $columnSpatialUnitIdentifierScheme as element(column),
    $vocabularySpatialUnits as element(),
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $schemeUrlPrefix := "http://dd.eionet.europa.eu/vocabulary/wise/SpatialUnit/"
    return vldinterid:validate-international-identifier-reference(
        $columnSpatialUnitIdentifier,
        $columnSpatialUnitIdentifierScheme,
        $vocabularySpatialUnits,
        $schemeUrlPrefix,
        $dataRows
    )
};
