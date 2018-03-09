xquery version "1.0" encoding "UTF-8";

module namespace vldwqlagwbrvlim = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedDataByWaterBody/validators/resultValuesLimits';

import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';
import module namespace vldwqlvallim = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/valueLimits" at "../../common/validators/vld-value-limits.xquery";

declare function vldwqlagwbrvlim:validate-result-values-limits(
    $model as element(model), 
    $limitsList as element(limits)*, 
    $dataRows as element(dataRow)*
)
as element(result)
{ 
    let $columnsToValidate := (
        meta:get-column-by-name($model, "resultMinimumValue"),
        meta:get-column-by-name($model, "resultMeanValue"),
        meta:get-column-by-name($model, "resultMaximumValue"),
        meta:get-column-by-name($model, "resultMedianValue")
    )
    let $columnObservedPropertyDeterminandCode := meta:get-column-by-name($model, "observedPropertyDeterminandCode")
    let $mixedResultRows := vldwqlagwbrvlim:_validate(
        $columnsToValidate, $columnObservedPropertyDeterminandCode, $limitsList, $dataRows, 1, 1, ()
    )
    let $resultRows := vldres:filter-max-qc-level-by-flagged-columns($mixedResultRows)
    return vldres:create-result($resultRows)
};

declare function vldwqlagwbrvlim:_validate(
    $columnsToValidate as element(column)*,
    $columnObservedPropertyDeterminandCode as element(column),
    $limitsList as element(limits)*, 
    $dataRows as element(dataRow)*,
    $dataRowIndex as xs:integer,
    $qclevelIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    if ($qclevelIndex > count(qclevels:list-flag-levels-desc())) then
        $resultRows
    else if ($dataRowIndex > count($dataRows)) then
        if ($qclevelIndex > count(qclevels:list-flag-levels-desc())) then
            $resultRows
        else
            vldwqlagwbrvlim:_validate(
                $columnsToValidate, $columnObservedPropertyDeterminandCode, $limitsList,
                $dataRows, 1, $qclevelIndex + 1, $resultRows
            )
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $currentQclevel := qclevels:list-flag-levels-desc()[$qclevelIndex]
        let $rowResult := vldwqlagwbrvlim:_validate-row(
            $columnsToValidate, $columnObservedPropertyDeterminandCode, $limitsList, $currentQclevel, $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwqlagwbrvlim:_validate(
            $columnsToValidate, $columnObservedPropertyDeterminandCode, $limitsList,
            $dataRows, $dataRowIndex + 1, $qclevelIndex, $newResultRows
        )
};

declare function vldwqlagwbrvlim:_validate-row(
    $columnsToValidate as element(column)*,
    $columnObservedPropertyDeterminandCode as element(column),
    $limitsList as element(limits)*,
    $acceptedQcLevel as xs:integer,
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $determinand := datax:get-row-value($dataRow, $columnObservedPropertyDeterminandCode)
    return
        if (empty($determinand)) then
            ()
        else
            let $limits := $limitsList[lower-case(@determinand) = lower-case($determinand)]
            let $flaggedColumns :=
                for $column in $columnsToValidate
                let $resultValue := xs:decimal(datax:get-row-float-value($dataRow, $column))
                let $vldResult := vldwqlvallim:validate-value-limit($resultValue, $limits)
                return 
                    if ($vldResult = $qclevels:OK or $vldResult != $acceptedQcLevel) then
                        ()
                    else
                        vldres:create-flagged-column($column, $vldResult)
            return
                if (empty($flaggedColumns)) then
                    ()
                else
                    vldres:create-result-row($dataRow, $flaggedColumns)
};
