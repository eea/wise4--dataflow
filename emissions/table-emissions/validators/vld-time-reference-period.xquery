xquery version "1.0" encoding "UTF-8";

module namespace vldemisemistrefprd = "http://converters.eionet.europa.eu/wise/emissions/emissions/validators/timeReferencePeriod";

import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../../common/data.xquery";
import module namespace meta = "http://converters.eionet.europa.eu/common/meta" at "../../../common/meta.xquery";
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';
import module namespace vldtypes = 'http://converters.eionet.europa.eu/common/validators/types' at '../../../common/validators/types.xquery';

declare function vldemisemistrefprd:validate-time-reference-period(
    $model as element(model),
    $dataFlowCycles as element(DataFlows),
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $dataFlowCycle := vldemisemistrefprd:get-data-flow-cycle($dataFlowCycles)
    let $cycleStartYear := vldemisemistrefprd:get-start-year($dataFlowCycle)
    let $cycleEndYear := vldemisemistrefprd:get-end-year($dataFlowCycle)
    let $columnPhenomenonTimeReferencePeriod := meta:get-column-by-name($model, 'phenomenonTimeReferencePeriod')
    let $resultRows := vldemisemistrefprd:_validate(
        $columnPhenomenonTimeReferencePeriod, $cycleStartYear, $cycleEndYear, $dataRows, 1, ()
    ) 
    let $valueCounts := vldres:calculate-column-value-counts($resultRows, $columnPhenomenonTimeReferencePeriod)
    return vldres:create-result($resultRows, $valueCounts)
};   

declare function vldemisemistrefprd:get-data-flow-cycle($dataFlowCycles as element(DataFlows))
as element(DataFlowCycle)
{
    $dataFlowCycles/DataFlow[@RO_ID="632"]/DataFlowCycle[@Identifier="2016"]
};

declare function vldemisemistrefprd:get-start-year($dataFlowCycle as element(DataFlowCycle))
as xs:integer
{
    year-from-date(xs:date($dataFlowCycle/timeValuesLimitDateStart))
};

declare function vldemisemistrefprd:get-end-year($dataFlowCycle as element(DataFlowCycle))
as xs:integer
{
    year-from-date(xs:date($dataFlowCycle/timeValuesLimitDateEnd))
};

declare function vldemisemistrefprd:_validate(
    $columnPhenomenonTimeReferencePeriod as element(column),
    $cycleStartYear as xs:integer,
    $cycleEndYear as xs:integer,
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
        let $rowResult := vldemisemistrefprd:_validate-data-row(
            $columnPhenomenonTimeReferencePeriod, $cycleStartYear, $cycleEndYear, $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldemisemistrefprd:_validate(
            $columnPhenomenonTimeReferencePeriod, $cycleStartYear, $cycleEndYear, $dataRows, $dataRowIndex + 1, $newResultRows
        )
};

declare function vldemisemistrefprd:_validate-data-row(
    $columnPhenomenonTimeReferencePeriod as element(column),
    $cycleStartYear as xs:integer,
    $cycleEndYear as xs:integer,
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $values := data:get-row-values($dataRow, $columnPhenomenonTimeReferencePeriod)
    return
        if (data:is-empty-value($values)) then
            ()
        else
            let $flaggedValues :=
                for $value in $values
                let $dates := vldemisemistrefprd:_parse-period($value)
                let $isValid :=
                    if (empty($dates)) then
                        false()
                    else if (not(vldemisemistrefprd:_is-valid-time-frame($dates))) then
                        false()
                    else if (not(vldemisemistrefprd:_is-valid-by-flow-cycle($dates, $cycleStartYear, $cycleEndYear))) then
                        false()
                    else 
                        true()
                where not($isValid)
                return vldres:create-flagged-value($qclevels:BLOCKER, $value)
            return
                if (empty($flaggedValues)) then
                    ()
                else
                    let $flaggedColumn := vldres:create-flagged-column-by-values($columnPhenomenonTimeReferencePeriod, $flaggedValues)
                    return vldres:create-result-row($dataRow, $flaggedColumn) 
};

declare function vldemisemistrefprd:_parse-period($value as xs:string)
as xs:date*
{
    let $dateTokens := tokenize($value, "\-\-")
    let $tokenCount := count($dateTokens) 
    return
        if ($tokenCount > 2) then
            ()
        else if ($tokenCount = 1) then
            vldemisemistrefprd:_parse-date($dateTokens[1])
        else 
            let $startDate := vldemisemistrefprd:_parse-date($dateTokens[1])
            let $endDate := vldemisemistrefprd:_parse-date($dateTokens[2])
            return 
                if (empty($startDate) or empty($endDate)) then
                    ()
                else
                    ($startDate, $endDate)
};

declare function vldemisemistrefprd:_parse-date($value)
as xs:date?
{
    let $value2 := concat($value, "-01-01")
    return
        if ($value2 castable as xs:date) then
            xs:date($value2)
        else
            ()
};

declare function vldemisemistrefprd:_is-valid-time-frame($dates as xs:date*)
as xs:boolean
{
    if (count($dates) = 1) then
        true()
    else
        $dates[1] <= $dates[2]
};

declare function vldemisemistrefprd:_is-valid-by-flow-cycle($dates as xs:date*, $cycleStartYear as xs:integer, $cycleEndYear as xs:integer)
as xs:boolean
{
    let $invalidYears :=
        for $date in $dates
        let $dateYear := year-from-date($date)
        return
            if ($dateYear >= $cycleStartYear and $dateYear <= $cycleEndYear) then
                ()
            else
                $dateYear
    return empty($invalidYears)
};
