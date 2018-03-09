xquery version "1.0" encoding "UTF-8";

module namespace vldtmprdvolsum = 'http://converters.eionet.europa.eu/wise/common/validators/timePeriodVolumeSum';

import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../common/data.xquery";
import module namespace datax = "http://converters.eionet.europa.eu/common/dataExtensions" at "../../common/data-extensions.xquery";
import module namespace meta = "http://converters.eionet.europa.eu/common/meta" at "../../common/meta.xquery";
import module namespace qclevels = "http://converters.eionet.europa.eu/common/qclevels" at "../../common/qclevels.xquery";
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../common/validators/validation-result.xquery';

declare function vldtmprdvolsum:validate-time-period-volume-sum(
    $columnSpUnitId as element(column), 
    $columnSpUnitIdScheme as element(column), 
    $columnParameter as element(column),
    $columnPTimePeriod as element(column),
    $columnResultObservedVolume as element(column),
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $rowsToGroup := vldtmprdvolsum:_select-rows-to-group($dataRows, $columnPTimePeriod)
    let $totalRows := vldtmprdvolsum:_select-total-rows($dataRows, $columnPTimePeriod)
    let $groupKeys := vldtmprdvolsum:_get-row-keys($columnSpUnitId, $columnSpUnitIdScheme, $columnParameter, $columnPTimePeriod, $rowsToGroup)

    let $invalidRows :=
        for $groupKey in $groupKeys
        let $groupTotalRows := vldtmprdvolsum:_filter-rows-by-group-key($columnSpUnitId, $columnSpUnitIdScheme, $columnParameter, $columnPTimePeriod, $totalRows, $groupKey)
        return
            if (empty($groupTotalRows)) then
                ()
            else
                let $groupRows := vldtmprdvolsum:_filter-rows-by-group-key($columnSpUnitId, $columnSpUnitIdScheme, $columnParameter, $columnPTimePeriod, $rowsToGroup, $groupKey)
                let $volumeSum := vldtmprdvolsum:_calculate-volume-sum($groupRows, $columnResultObservedVolume)
                let $groupTotal := max(
                    for $groupTotalRow in $groupTotalRows
                    return datax:get-row-float-value($groupTotalRow, $columnResultObservedVolume)
                )
                return
                    if ($volumeSum <= 1.001 * $groupTotal) then
                        ()
                    else
                        ($groupTotalRows, $groupRows)
    
    let $resultRows :=
        for $invalidRow in $invalidRows
        let $flaggedColumn := vldres:create-flagged-column($columnResultObservedVolume, $qclevels:BLOCKER)
        return vldres:create-result-row($invalidRow, $flaggedColumn)
    
    return vldres:create-result($resultRows)
};

declare function vldtmprdvolsum:_validate-groups(
    $columnSpUnitId as element(column),
    $columnSpUnitIdScheme as element(column),
    $columnParameter as element(column),
    $columnPTimePeriod as element(column),
    $columnResultObservedVolume as element(column),
    $rowsToGroup as element(dataRow)*,
    $totalRows as element(dataRow)*,
    $groupKeys as xs:string*,
    $groupKeyIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    if ($groupKeyIndex > count($groupKeys)) then
        $resultRows
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $groupKey := $groupKeys[$groupKeyIndex]
        let $groupTotalRows := vldtmprdvolsum:_filter-rows-by-group-key(
            $columnSpUnitId, $columnSpUnitIdScheme, $columnParameter, $columnPTimePeriod, $totalRows, $groupKey
        )
        let $newResultRows := 
            if (empty($groupTotalRows)) then
                $resultRows
            else
                let $groupRows := vldtmprdvolsum:_filter-rows-by-group-key(
                    $columnSpUnitId, $columnSpUnitIdScheme, $columnParameter, $columnPTimePeriod, $rowsToGroup, $groupKey
                )
                let $volumeSum := vldtmprdvolsum:_calculate-volume-sum($groupRows, $columnResultObservedVolume)
                let $groupTotal := max(
                    for $groupTotalRow in $groupTotalRows
                    return datax:get-row-float-value($groupTotalRow, $columnResultObservedVolume)
                )
                return
                    if ($volumeSum <= 1.001 * $groupTotal) then
                        $resultRows
                    else
                        vldtmprdvolsum:_validate-group-rows($columnResultObservedVolume, ($groupTotalRows, $groupRows), 1, $resultRows)
        return vldtmprdvolsum:_validate-groups(
            $columnSpUnitId, $columnSpUnitIdScheme, $columnParameter, $columnPTimePeriod, $columnResultObservedVolume,
            $rowsToGroup, $totalRows, $groupKeys, $groupKeyIndex + 1, $newResultRows
        )
};

declare function vldtmprdvolsum:_validate-group-rows(
    $columnResultObservedVolume as element(column),
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
        let $flaggedColumn := vldres:create-flagged-column($columnResultObservedVolume, $qclevels:BLOCKER)
        let $newResultRows := ($resultRows, vldres:create-result-row($dataRow, $flaggedColumn))
        return vldtmprdvolsum:_validate-group-rows($columnResultObservedVolume, $dataRows, $dataRowIndex + 1, $newResultRows)
};

declare function vldtmprdvolsum:_select-rows-to-group($dataRows as element(dataRow)*, $columnPTimePeriod as element(column))
as element(dataRow)*
{
    for $dataRow in $dataRows
    let $timePeriod := datax:get-row-value($dataRow, $columnPTimePeriod)
    return
        if (empty($timePeriod) or not(concat($timePeriod, "-01") castable as xs:date)) then
            ()
        else
            $dataRow
};

declare function vldtmprdvolsum:_select-total-rows($dataRows as element(dataRow)*, $columnPTimePeriod as element(column))
as element(dataRow)*
{
    for $dataRow in $dataRows
    let $timePeriod := datax:get-row-value($dataRow, $columnPTimePeriod)
    return
        if (empty($timePeriod) or not(concat($timePeriod, "-01-01") castable as xs:date)) then
            ()
        else 
            $dataRow
};

declare function vldtmprdvolsum:_get-row-keys(
    $columnSpUnitId as element(column),
    $columnSpUnitIdScheme as element(column),
    $columnParameter as element(column),
    $columnPTimePeriod as element(column),
    $rowsToGroup as element(dataRow)*
)
as xs:string*
{
    let $keys :=
        for $dataRow in $rowsToGroup
        let $key := vldtmprdvolsum:_compose-row-key($columnSpUnitId, $columnSpUnitIdScheme, $columnParameter, $columnPTimePeriod, $dataRow)
        order by $key
        return $key
    return distinct-values($keys)
};

declare function vldtmprdvolsum:_compose-row-key(
    $columnSpUnitId as element(column),
    $columnSpUnitIdScheme as element(column),
    $columnParameter as element(column),
    $columnPTimePeriod as element(column),
    $dataRow as element(dataRow)
)
as xs:string?
{
    let $keyValues := (
        datax:get-row-value($dataRow, $columnSpUnitId),
        datax:get-row-value($dataRow, $columnSpUnitIdScheme),
        datax:get-row-value($dataRow, $columnParameter),
        let $timePeriod := datax:get-row-value($dataRow, $columnPTimePeriod)
        return substring($timePeriod, 1, 4)
    )
    return
        if (count($keyValues) != 4) then
            ()
        else
            string-join($keyValues, $data:ROW-KEY-VALUE-SEPARATOR)
};

declare function vldtmprdvolsum:_filter-rows-by-group-key(
    $columnSpUnitId as element(column),
    $columnSpUnitIdScheme as element(column),
    $columnParameter as element(column),
    $columnPTimePeriod as element(column),
    $dataRows as element(dataRow)*, 
    $groupKey as xs:string
)
as element(dataRow)*
{
    for $dataRow in $dataRows
    let $rowKey := vldtmprdvolsum:_compose-row-key($columnSpUnitId, $columnSpUnitIdScheme, $columnParameter, $columnPTimePeriod, $dataRow)
    where $groupKey = $rowKey
    return $dataRow
};

declare function vldtmprdvolsum:_calculate-volume-sum($groupRows as element(dataRow)*, $columnResultObservedVolume as element(column))
as xs:double?
{
    let $groupVolumes :=
        for $groupRow in $groupRows
        let $volume := datax:get-row-float-value($groupRow, $columnResultObservedVolume)
        where not(empty($volume))
        return $volume
    return
        if (empty($groupVolumes)) then
            0
        else
            sum($groupVolumes)
};
