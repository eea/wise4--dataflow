xquery version "1.0" encoding "UTF-8";

module namespace vldwqlaggrvlim = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedData/validators/resultValuesLimits';

import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';
import module namespace vldwqlvallim = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/valueLimits" at "../../common/validators/vld-value-limits.xquery";

declare function vldwqlaggrvlim:validate-result-values-limits(
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
    let $columnResultObservationStatus := meta:get-column-by-name($model, "resultObservationStatus")
    let $mixedResultRows := vldwqlaggrvlim:_validate(
        $columnsToValidate, $columnObservedPropertyDeterminandCode, $columnResultObservationStatus,
        $limitsList, $dataRows, 1, 1, ()
    )
    let $resultRows := vldres:filter-max-qc-level-by-flagged-columns($mixedResultRows)
    return vldres:create-result($resultRows)
};

declare function vldwqlaggrvlim:_validate(
    $columnsToValidate as element(column)*,
    $columnObservedPropertyDeterminandCode as element(column),
    $columnResultObservationStatus as element(column),
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
            vldwqlaggrvlim:_validate(
                $columnsToValidate, $columnObservedPropertyDeterminandCode, $columnResultObservationStatus,
                $limitsList, $dataRows, 1, $qclevelIndex + 1, $resultRows
            )
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $currentQclevel := qclevels:list-flag-levels-desc()[$qclevelIndex]
        let $rowResult := vldwqlaggrvlim:_validate-row(
            $columnsToValidate, $columnObservedPropertyDeterminandCode, $columnResultObservationStatus,
            $limitsList, $currentQclevel, $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwqlaggrvlim:_validate(
            $columnsToValidate, $columnObservedPropertyDeterminandCode, $columnResultObservationStatus,
            $limitsList, $dataRows, $dataRowIndex + 1, $qclevelIndex, $newResultRows
        )
};

declare function vldwqlaggrvlim:_validate-row(
    $columnsToValidate as element(column)*,
    $columnObservedPropertyDeterminandCode as element(column),
    $columnResultObservationStatus as element(column),
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
                    if ($vldResult = $qclevels:OK) then
                        ()
                    else
                        let $finalVldResult :=
                            if ($vldResult = $qclevels:WARNING and upper-case(datax:get-row-value($dataRow, $columnResultObservationStatus)) = "A") then
                                $qclevels:INFO
                            else
                                $vldResult
                        return
                            if ($finalVldResult = $acceptedQcLevel) then
                                vldres:create-flagged-column($column, $finalVldResult)
                            else
                                ()
            return
                if (empty($flaggedColumns)) then
                    ()
                else
                    vldres:create-result-row($dataRow, $flaggedColumns)
};

