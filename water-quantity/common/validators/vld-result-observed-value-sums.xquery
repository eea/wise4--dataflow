xquery version "1.0" encoding "UTF-8";

module namespace vldwqnrovs = "http://converters.eionet.europa.eu/wise/waterQuantity/common/validators/resultObservedValueSums";

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../../common/data.xquery';
import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace util = 'http://converters.eionet.europa.eu/common/util' at '../../../common/util.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';

declare function vldwqnrovs:validate-result-observed-value-sums(
    $columnSpUnitId as element(column),
    $columnSpUnitIdScheme as element(column),
    $columnTimePeriod as element(column),
    $columnParameter as element(column),
    $columnResultValue as element(column),
    $allowableParameterValues as xs:string*,
    $totalParameterValue as xs:string, 
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $allowableParameterValuesLowerCase := util:lower-case($allowableParameterValues)
    let $totalParameterValueLowerCase := lower-case($totalParameterValue)
    let $groups := vldwqnrovs:_group-data-rows(
        $columnSpUnitId, $columnSpUnitIdScheme, $columnTimePeriod, $columnParameter,
        $allowableParameterValuesLowerCase, $totalParameterValueLowerCase, $dataRows
    )
    let $sortingColumns := ($columnSpUnitId, $columnSpUnitIdScheme, $columnTimePeriod, $columnParameter)
    let $resultRows := vldwqnrovs:_validate-groups(
        $columnParameter, $columnResultValue, $sortingColumns, 
        $allowableParameterValuesLowerCase, $totalParameterValueLowerCase, $groups, 1, ()
    )
    return vldres:create-result($resultRows)
};

declare function vldwqnrovs:_validate-groups(
    $columnParameter as element(column),
    $columnResultValue as element(column),
    $sortingColumns as element(column)*,
    $allowableParameterValuesLowerCase as xs:string*, 
    $totalParameterValueLowerCase as xs:string,
    $groups as element(group)*,
    $groupIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    if ($groupIndex > count($groups)) then
        $resultRows
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $group := $groups[$groupIndex]
        let $groupRows := $group/rows/*
        let $isValidGroup := vldwqnrovs:_is-valid-group(
            $columnParameter, $columnResultValue, $allowableParameterValuesLowerCase, $totalParameterValueLowerCase, $groupRows
        )
        let $newResultRows := 
            if ($isValidGroup) then
                $resultRows
            else
                let $groupRowsOrdered :=
                    for $groupRow in $groupRows
                    let $sortingKey := data:get-row-key($groupRow, $sortingColumns)
                    order by $sortingKey
                    return $groupRow
                return vldwqnrovs:_validate-group-rows($columnResultValue, $groupRowsOrdered, 1, $resultRows)
        return vldwqnrovs:_validate-groups(
            $columnParameter, $columnResultValue, $sortingColumns, $allowableParameterValuesLowerCase, 
            $totalParameterValueLowerCase, $groups, $groupIndex + 1, $newResultRows
        )
};

declare function vldwqnrovs:_validate-group-rows(
    $columnResultValue as element(column),
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
        let $flaggedColumn := vldres:create-flagged-column($columnResultValue, $qclevels:BLOCKER)
        let $newResultRows := ($resultRows, vldres:create-result-row($dataRow, $flaggedColumn))
        return vldwqnrovs:_validate-group-rows($columnResultValue, $dataRows, $dataRowIndex + 1, $newResultRows)
};

declare function vldwqnrovs:_group-data-rows(
    $columnSpUnitId as element(column),
    $columnSpUnitIdScheme as element(column),
    $columnTimePeriod as element(column),
    $columnParameter as element(column),
    $allowableParameterValuesLowerCase as xs:string*,
    $totalParameterValueLowerCase as xs:string,
    $dataRows as element(dataRow)*
)
as element(group)*
{
    let $workingRows := vldwqnrovs:_filter-data-rows($columnSpUnitId, $columnSpUnitIdScheme, $columnTimePeriod, $columnParameter,
        $allowableParameterValuesLowerCase, $totalParameterValueLowerCase, $dataRows
    )
    let $groupColumns := ($columnSpUnitId, $columnSpUnitIdScheme, $columnTimePeriod)
    return data:group-by($workingRows, $groupColumns, data:create-group-aggregate())
};

declare function vldwqnrovs:_filter-data-rows(
    $columnSpUnitId as element(column),
    $columnSpUnitIdScheme as element(column),
    $columnTimePeriod as element(column),
    $columnParameter as element(column),
    $allowableParameterValuesLowerCase as xs:string*,
    $totalParameterValueLowerCase as xs:string,
    $dataRows as element(dataRow)*
)
as element(dataRow)*
{
    for $dataRow in $dataRows
    let $spUnitId := datax:get-row-value($dataRow, $columnSpUnitId)
    let $spUnitIdScheme := datax:get-row-value($dataRow, $columnSpUnitIdScheme)
    let $timePeriod := datax:get-row-value($dataRow, $columnTimePeriod)
    let $parameter := datax:get-row-value($dataRow, $columnParameter)
    where not(empty($spUnitId)) and not(empty($spUnitIdScheme)) and not(empty($timePeriod)) and not(empty($parameter))
            and (vldwqnrovs:_is-allowable-parameter-value($parameter, $allowableParameterValuesLowerCase) 
                    or vldwqnrovs:_is-total-parameter-value($parameter, $totalParameterValueLowerCase))
    return $dataRow
};

declare function vldwqnrovs:_is-allowable-parameter-value(
    $parameterValue as xs:string, 
    $allowableParameterValuesLowerCase as xs:string*
)
as xs:boolean
{
    lower-case($parameterValue) = $allowableParameterValuesLowerCase
};

declare function vldwqnrovs:_is-total-parameter-value($parameterValue as xs:string, $totalParameterValueLowerCase as xs:string)
as xs:boolean
{
    lower-case($parameterValue) = $totalParameterValueLowerCase
};

declare function vldwqnrovs:_is-valid-group(
    $columnParameter as element(column), 
    $columnResultValue as element(column),
    $allowableParameterValuesLowerCase as xs:string*,
    $totalParameterValueLowerCase as xs:string,
    $rows as element(dataRow)*
)
as xs:boolean
{
    let $total := max(
        for $row in $rows
        let $parameter := datax:get-row-value($row, $columnParameter)
        where vldwqnrovs:_is-total-parameter-value($parameter, $totalParameterValueLowerCase)
        return datax:get-row-float-value($row, $columnResultValue)
    )
    let $sum := sum(
        for $row in $rows
        let $parameter := datax:get-row-value($row, $columnParameter)
        where vldwqnrovs:_is-allowable-parameter-value($parameter, $allowableParameterValuesLowerCase)
        return datax:get-row-float-value($row, $columnResultValue)
    )
    return empty($total) or $sum <= 1.001 * $total
};
