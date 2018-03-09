xquery version "1.0" encoding "UTF-8";

module namespace vldwqlagwbdet = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedDataByWaterBody/validators/determinand';

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../../common/data.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace util = 'http://converters.eionet.europa.eu/common/util' at '../../../common/util.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';
import module namespace vldclist = 'http://converters.eionet.europa.eu/common/validators/codelist' at '../../../common/validators/codelist.xquery';

declare variable $vldwqlagwbdet:_allowable-values-lower-case := util:lower-case(("CAS_14797-55-8", "CAS_14798-03-9","EEA_3132-01-2", "CAS_14797-65-0"));

declare function vldwqlagwbdet:validate-determinand($model as element(model), $dataRows as element(dataRow)*)
as element(result)
{
    let $column := meta:get-column-by-name($model, "observedPropertyDeterminandCode")
    let $resultRows := vldwqlagwbdet:_validate($column, $dataRows, 1, ())
    let $columnCounts := vldres:calculate-column-value-counts($resultRows, $column)
    return vldres:create-result($resultRows, $columnCounts)
};

declare function vldwqlagwbdet:_validate(
    $column as element(column),
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
        let $rowResult := vldwqlagwbdet:_validate-row($column, $dataRow)
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwqlagwbdet:_validate($column, $dataRows, $dataRowIndex + 1, $newResultRows)
};

declare function vldwqlagwbdet:_validate-row($column as element(column), $dataRow as element(dataRow))
as element(row)?
{
    let $determinands := data:get-row-values($dataRow, $column)
    let $flaggedValues :=
        for $determinand in $determinands
        let $skip := $determinand = "" or not(empty(vldclist:validate-codelist($column, $dataRow)))
        return
            if ($skip or lower-case($determinand) = $vldwqlagwbdet:_allowable-values-lower-case) then
                ()
            else
                vldres:create-flagged-value($qclevels:BLOCKER, $determinand)
    return
        if (empty($flaggedValues)) then
            ()
        else
            let $flaggedColumn := vldres:create-flagged-column-by-values($column, $flaggedValues)
            return vldres:create-result-row($dataRow, $flaggedColumn)
};
