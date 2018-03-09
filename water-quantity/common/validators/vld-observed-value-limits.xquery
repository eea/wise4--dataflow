xquery version "1.0" encoding "UTF-8";

module namespace vldwqnobsvallim = "http://converters.eionet.europa.eu/wise/waterQuantity/common/validators/observedValueLimits";

import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';
import module namespace vldvallim = "http://converters.eionet.europa.eu/wise/common/validators/valueLimits" at "../../../wise-common/validators/vld-value-limits.xquery";

declare function vldwqnobsvallim:validate-observed-value-limits(
    $columnResultObservedValue as element(column),
    $columnObservedProperty as element(column),
    $columnResultObservationStatus as element(column),
    $limitsList as element(limits)*,
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $mixedResultRows := vldwqnobsvallim:_validate(
        $columnResultObservedValue, $columnObservedProperty,
        $columnResultObservationStatus, $limitsList,
        $dataRows, 1, 1, ()
    )
    let $resultRows := vldres:filter-max-qc-level-by-flagged-columns($mixedResultRows)
    return vldres:create-result($resultRows)
};

declare function vldwqnobsvallim:_validate(
    $columnResultObservedValue as element(column),
    $columnObservedProperty as element(column),
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
            vldwqnobsvallim:_validate(
                $columnResultObservedValue, $columnObservedProperty, $columnResultObservationStatus,
                $limitsList, $dataRows, 1, $qclevelIndex + 1, $resultRows
            )
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $currentQclevel := qclevels:list-flag-levels-desc()[$qclevelIndex]
        let $rowResult := vldwqnobsvallim:_validate-row(
            $columnResultObservedValue, $columnObservedProperty, 
            $columnResultObservationStatus, $limitsList, $currentQclevel, $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwqnobsvallim:_validate(
            $columnResultObservedValue, $columnObservedProperty, $columnResultObservationStatus,
            $limitsList, $dataRows, $dataRowIndex + 1, $qclevelIndex, $newResultRows
        )
};

declare function vldwqnobsvallim:_validate-row(
    $columnResultObservedValue as element(column),
    $columnObservedProperty as element(column),
    $columnResultObservationStatus as element(column),
    $limitsList as element(limits)*,
    $acceptedQcLevel as xs:integer,
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $determinand := datax:get-row-value($dataRow, $columnObservedProperty)
        let $observedValue := datax:get-row-decimal-value($dataRow, $columnResultObservedValue)
        return 
            if (empty($determinand) or empty($observedValue)) then
                ()
            else
                let $limits := $limitsList[lower-case(@determinand) = lower-case($determinand)]
                let $qcResult := vldvallim:validate-value-limit($observedValue, $limits)
                return
                    if ($qcResult = $qclevels:OK) then
                        ()
                    else
                        let $finalQcResult :=
                            if ($qcResult = $qclevels:WARNING and upper-case(datax:get-row-value($dataRow, $columnResultObservationStatus)) = "A") then
                                $qclevels:INFO
                            else
                                $qcResult
                        return
                            if ($finalQcResult != $acceptedQcLevel) then
                                ()
                            else
                                let $flaggedColumn := vldres:create-flagged-column($columnResultObservedValue, $finalQcResult)
                                return vldres:create-result-row($dataRow, $flaggedColumn)
};
