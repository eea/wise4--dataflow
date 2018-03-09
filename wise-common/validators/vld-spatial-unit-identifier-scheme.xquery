xquery version "1.0" encoding "UTF-8";

module namespace vldspunitidsch = 'http://converters.eionet.europa.eu/wise/common/validators/spatialUnitIdentifierScheme';

import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../common/data.xquery";
import module namespace qclevels = "http://converters.eionet.europa.eu/common/qclevels" at "../../common/qclevels.xquery";
import module namespace util = "http://converters.eionet.europa.eu/common/util" at "../../common/util.xquery";
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../common/validators/validation-result.xquery';

declare variable $vldspunitidsch:_allowable-values := util:lower-case(("countryCode", "euRBDCode", "euSubUnitCode", "eionetRBDCode", "eionetSubUnitCode"));

declare function vldspunitidsch:validate-spatial-unit-identifier-scheme(
    $columnSpatialUnitIdentifierScheme as element(column), 
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $resultRows := vldspunitidsch:_validate($columnSpatialUnitIdentifierScheme, $dataRows, 1, ())
    let $counts := vldres:calculate-column-value-counts($resultRows, $columnSpatialUnitIdentifierScheme)
    return vldres:create-result($resultRows, $counts)
};

declare function vldspunitidsch:_validate(
    $columnSpatialUnitIdentifierScheme as element(column), 
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
        let $rowResult := vldspunitidsch:_validate-row($columnSpatialUnitIdentifierScheme, $dataRow)
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldspunitidsch:_validate($columnSpatialUnitIdentifierScheme, $dataRows, $dataRowIndex + 1, $newResultRows)
};

declare function vldspunitidsch:_validate-row($columnSpatialUnitIdentifierScheme as element(column), $dataRow as element(dataRow))
as element(row)?
{
    let $schemeValues := data:get-row-values($dataRow, $columnSpatialUnitIdentifierScheme)
    return 
        if (data:is-empty-value($schemeValues)) then
            ()
        else
            let $flaggedValues :=
                for $schemeValue in $schemeValues
                let $schemeValueLowerCase := lower-case($schemeValue)
                where not($schemeValueLowerCase = $vldspunitidsch:_allowable-values)
                return vldres:create-flagged-value($qclevels:BLOCKER, $schemeValue)
            return
                if (empty($flaggedValues)) then
                    ()
                else
                    let $flaggedColumn := vldres:create-flagged-column-by-values($columnSpatialUnitIdentifierScheme, $flaggedValues)
                    return vldres:create-result-row($dataRow, $flaggedColumn)
};
