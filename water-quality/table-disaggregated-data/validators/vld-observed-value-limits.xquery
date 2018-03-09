xquery version "1.0" encoding "UTF-8";

module namespace vldwqldisobsvallim = "http://converters.eionet.europa.eu/wise/waterQuality/disaggregatedData/validators/observedValueLimits";

import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';
import module namespace vldwqlvallim = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/valueLimits" at "../../common/validators/vld-value-limits.xquery";

declare function vldwqldisobsvallim:validate-observed-value-limits(
    $model as element(model),
    $limitsList as element(limits)*,
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $columnResultObservedValue := meta:get-column-by-name($model, "resultObservedValue")
    let $columnObservedPropertyDeterminandCode := meta:get-column-by-name($model, "observedPropertyDeterminandCode")
    let $columnResultObservationStatus := meta:get-column-by-name($model, "resultObservationStatus")
    let $mixedResultRows := vldwqldisobsvallim:_validate(
        $columnResultObservedValue, $columnObservedPropertyDeterminandCode,
        $columnResultObservationStatus, $limitsList,
        $dataRows, 1, 1, ()
    )
    let $resultRows := vldres:filter-max-qc-level-by-flagged-columns($mixedResultRows)
    return vldres:create-result($resultRows)
};

declare function vldwqldisobsvallim:_validate(
    $columnResultObservedValue as element(column),
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
    let $blocker :=
        (for $row in $dataRows
        let $currentQclevel := qclevels:list-flag-levels-desc()[1]
        return vldwqldisobsvallim:_validate-row(
                $columnResultObservedValue, $columnObservedPropertyDeterminandCode,
                $columnResultObservationStatus, $limitsList, $currentQclevel, $row
        ))[position() = 1 to $vldres:MAX_RECORD_RESULTS]
    let $error :=
        (for $row in $dataRows
        let $currentQclevel := qclevels:list-flag-levels-desc()[2]
        return vldwqldisobsvallim:_validate-row(
                $columnResultObservedValue, $columnObservedPropertyDeterminandCode,
                $columnResultObservationStatus, $limitsList, $currentQclevel, $row
        ))[position() = 1 to $vldres:MAX_RECORD_RESULTS]
    let $warning :=
        (for $row in $dataRows
        let $currentQclevel := qclevels:list-flag-levels-desc()[3]
        return vldwqldisobsvallim:_validate-row(
                $columnResultObservedValue, $columnObservedPropertyDeterminandCode,
                $columnResultObservationStatus, $limitsList, $currentQclevel, $row
        ))[position() = 1 to $vldres:MAX_RECORD_RESULTS]
    let $info :=
        (for $row in $dataRows
        let $currentQclevel := qclevels:list-flag-levels-desc()[4]
        return vldwqldisobsvallim:_validate-row(
                $columnResultObservedValue, $columnObservedPropertyDeterminandCode,
                $columnResultObservationStatus, $limitsList, $currentQclevel, $row
        ))[position() = 1 to $vldres:MAX_RECORD_RESULTS]
    return ($blocker, $error, $warning, $info)
(:if ($qclevelIndex > count(qclevels:list-flag-levels-desc())) then
        $resultRows
    else if ($dataRowIndex > count($dataRows)) then
        if ($qclevelIndex > count(qclevels:list-flag-levels-desc())) then
            $resultRows
        else
            vldwqldisobsvallim:_validate(
                $columnResultObservedValue, $columnObservedPropertyDeterminandCode, $columnResultObservationStatus,
                $limitsList, $dataRows, 1, $qclevelIndex + 1, $resultRows
            )
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $currentQclevel := qclevels:list-flag-levels-desc()[$qclevelIndex]
        let $rowResult := vldwqldisobsvallim:_validate-row(
            $columnResultObservedValue, $columnObservedPropertyDeterminandCode, 
            $columnResultObservationStatus, $limitsList, $currentQclevel, $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwqldisobsvallim:_validate(
            $columnResultObservedValue, $columnObservedPropertyDeterminandCode, $columnResultObservationStatus,
            $limitsList, $dataRows, $dataRowIndex + 1, $qclevelIndex, $newResultRows
        ):)
};

declare function vldwqldisobsvallim:_validate-row(
    $columnResultObservedValue as element(column),
    $columnObservedPropertyDeterminandCode as element(column),
    $columnResultObservationStatus as element(column),
    $limitsList as element(limits)*,
    $acceptedQcLevel as xs:integer,
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $determinand := datax:get-row-value($dataRow, $columnObservedPropertyDeterminandCode)
        let $observedValue := datax:get-row-decimal-value($dataRow, $columnResultObservedValue)
        return 
            if (empty($determinand) or empty($observedValue)) then
                ()
            else
                let $limits := $limitsList[lower-case(@determinand) = lower-case($determinand)]
                let $qcResult := vldwqlvallim:validate-value-limit($observedValue, $limits)
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

