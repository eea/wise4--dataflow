xquery version "1.0" encoding "UTF-8";

module namespace vldmandatory = 'http://converters.eionet.europa.eu/common/validators/mandatory';

import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../qclevels.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../meta.xquery';
import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../data.xquery';
import module namespace util = 'http://converters.eionet.europa.eu/common/util' at '../util.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at 'validation-result.xquery';

declare function vldmandatory:validate-mandatory-columns(
    $model as element(model),
    $columnExceptions as element(columnException)*,
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    return vldmandatory:validate-mandatory-columns($model, $mandatoryColumns, $columnExceptions, $dataRows)
};

declare function vldmandatory:validate-mandatory-columns(
    $model as element(model),
    $mandatoryColumns as element(column)*,
    $columnExceptions as element(columnException)*,
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $mixedResultRows := vldmandatory:_validate($model, $mandatoryColumns, $columnExceptions, $dataRows)
    (:let $asd := trace($mixedResultRows, "mixedResultRows"):)
    let $resultRows := vldres:filter-max-qc-level-by-flagged-columns($mixedResultRows)
    let $columnCounts := vldres:calculate-column-counts($resultRows, $mandatoryColumns)
    return vldres:create-result($resultRows, $columnCounts)
};

declare function vldmandatory:_validate(
    $model as element(model),
    $mandatoryColumns as element(column)*,
    $columnExceptions as element(columnException)*,
    $dataRows as element(dataRow)*
)
as element(row)*
{
    vldmandatory:_validate($model, $mandatoryColumns, $columnExceptions, $dataRows, 1, 1, ())
};

declare function vldmandatory:_validate(
    $model as element(model),
    $mandatoryColumns as element(column)*,
    $columnExceptions as element(columnException)*,
    $dataRows as element(dataRow)*,
    $dataRowIndex as xs:integer,
    $qclevelIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    vldres:mark_trunkated(
    (for $x in $dataRows
    let $currentQclevel := qclevels:list-flag-levels-desc()[$qclevelIndex]
    return vldmandatory:_validate-row($model, $mandatoryColumns, $columnExceptions, $x, $currentQclevel)), $vldres:MAX_RECORD_RESULTS)

(:if ($qclevelIndex > count(qclevels:list-flag-levels-desc())) then
        $resultRows
    else if ($dataRowIndex > count($dataRows)) then
        if ($qclevelIndex > count(qclevels:list-flag-levels-desc())) then
            $resultRows
        else
            vldmandatory:_validate($model, $mandatoryColumns, $columnExceptions, $dataRows, 1, $qclevelIndex + 1, $resultRows)
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $currentQclevel := qclevels:list-flag-levels-desc()[$qclevelIndex]
        let $rowResult := vldmandatory:_validate-row($model, $mandatoryColumns, $columnExceptions, $dataRow, $currentQclevel)
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldmandatory:_validate($model, $mandatoryColumns, $columnExceptions, $dataRows, $dataRowIndex + 1, $qclevelIndex, $newResultRows):)
};

declare function vldmandatory:_validate-row(
    $model as element(model),
    $mandatoryColumns as element(column)*,
    $columnExceptions as element(columnException)*,
    $dataRow as element(dataRow),
    $acceptableQcLevel as xs:integer
)
as element(row)?
{
    let $flaggedColumns :=
        for $mandatoryColumn in $mandatoryColumns
        return
            if (not(data:is-empty-value(data:get-row-values($dataRow, $mandatoryColumn)))) then
                ()
            else
                let $qcLevel := vldmandatory:_resolve-column-qc-level($model ,$mandatoryColumn, $columnExceptions, $dataRow)
                (:let $asd := trace($qcLevel, "qcLevel: "):)
                return
                    if ($qcLevel = $qclevels:OK or $qcLevel < $acceptableQcLevel - 3) then
                        ()
                    else
                        vldres:create-flagged-column($mandatoryColumn, $qcLevel)
    return
        if (empty($flaggedColumns)) then
            ()
        else
            vldres:create-result-row($dataRow, $flaggedColumns)
};

declare function vldmandatory:_resolve-column-qc-level(
    $model as element(model),
    $mandatoryColumn as element(column),
    $columnExceptions as element(columnException)*,
    $dataRow as element(dataRow)
)
as xs:integer
{
    let $mandatoryColumnName := meta:get-column-name($mandatoryColumn)
    let $mandatoryColumnExceptions := $columnExceptions[@columnName = $mandatoryColumnName]
    return
        if (empty($mandatoryColumnExceptions)) then
            $qclevels:BLOCKER
        else
            let $exception := $mandatoryColumnExceptions[1]
            return
                if (vldmandatory:_is-exception-satisfied($model, $dataRow, $exception)) then
                    xs:integer($exception/@onMatch)
                else
                    if (empty($exception/@onMissmatch)) then
                        $qclevels:BLOCKER
                    else
                        xs:integer($exception/@onMissmatch)
};

declare function vldmandatory:_is-exception-satisfied($model as element(model), $row as element(dataRow), $exception as element(columnException))
as xs:boolean
{
    let $dependencies := $exception/dependencies/dependency
    return
        if (empty($dependencies)) then
            true()
        else
            let $satisfiedDependencies :=
                for $dependency in $exception/dependencies/dependency
                let $negate := not(empty($dependency/acceptedValues[@not = true()]))
                let $acceptedValues := util:lower-case(data($dependency/acceptedValues/value))
                let $dependencyColumn := meta:get-column-by-name($model, string($dependency/@columnName))
                let $dependencyValues := util:lower-case(data:get-row-values($row, $dependencyColumn))
                let $acceptedDependency :=
                    if (empty($acceptedValues)) then
                        if (data:is-empty-value($dependencyValues)) then () else $dependency
                    else
                        let $satisfiedDependencyValues :=
                            for $dependencyValue in $dependencyValues
                            where $dependencyValue = $acceptedValues
                            return $dependencyValue
                        return
                            if (empty($satisfiedDependencyValues)) then () else $dependency
                return
                    if (empty($acceptedDependency)) then
                        if ($negate) then $dependency else ()
                    else
                        if ($negate) then () else $dependency
            return not(empty(($satisfiedDependencies)))
};
