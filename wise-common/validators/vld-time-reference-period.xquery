xquery version "1.0" encoding "UTF-8";

module namespace vldtrefperiod = 'http://converters.eionet.europa.eu/wise/common/validators/timeReferencePeriod';

import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../common/data.xquery";
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../common/validators/validation-result.xquery';
import module namespace vldtypes = 'http://converters.eionet.europa.eu/common/validators/types' at '../../common/validators/types.xquery';

declare function vldtrefperiod:validate-time-reference-period(
    $columnPhenomenonTimePeriod as element(column),
    $dataFlowCycles as element(DataFlows),
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $dataFlowCycle := vldtrefperiod:get-data-flow-cycle($dataFlowCycles)
    let $cycleStartDate := vldtrefperiod:get-start-date($dataFlowCycle)
    let $cycleEndDate := vldtrefperiod:get-end-date($dataFlowCycle)
    let $resultRows := vldtrefperiod:_validate($columnPhenomenonTimePeriod, $cycleStartDate, $cycleEndDate, $dataRows, 1, ())
    let $counts := vldres:calculate-column-value-counts($resultRows, $columnPhenomenonTimePeriod)
    return vldres:create-result($resultRows, $counts)
};   

declare function vldtrefperiod:get-data-flow-cycle($dataFlowCycles as element(DataFlows))
as element(DataFlowCycle)
{
    $dataFlowCycles/DataFlow[@RO_ID="184"]/DataFlowCycle[@Identifier="2016"]
};

declare function vldtrefperiod:get-start-date($dataFlowCycle as element(DataFlowCycle))
as xs:date
{
    xs:date($dataFlowCycle/timeValuesLimitDateStart)
};

declare function vldtrefperiod:get-end-date($dataFlowCycle as element(DataFlowCycle))
as xs:date
{
    xs:date($dataFlowCycle/timeValuesLimitDateEnd)
};

declare function vldtrefperiod:_validate(
    $columnPhenomenonTimePeriod as element(column),
    $cycleStartDate as xs:date,
    $cycleEndDate as xs:date,
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
        let $rowResult := vldtrefperiod:_validate-data-row($columnPhenomenonTimePeriod, $cycleStartDate, $cycleEndDate, $dataRow)
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldtrefperiod:_validate($columnPhenomenonTimePeriod, $cycleStartDate, $cycleEndDate, $dataRows, $dataRowIndex + 1, $newResultRows)
};

declare function vldtrefperiod:_validate-data-row(
    $columnPhenomenonTimePeriod as element(column),
    $cycleStartDate as xs:date,
    $cycleEndDate as xs:date,
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $timeRefPeriodStringValues := data:get-row-values($dataRow, $columnPhenomenonTimePeriod)
    return
        if (data:is-empty-value($timeRefPeriodStringValues)) then
            ()
        else
            let $flaggedValues :=
                for $timeRefPeriodStringValue in $timeRefPeriodStringValues
                let $timeRefPeriod := vldtrefperiod:_parse-period($timeRefPeriodStringValue)
                let $errorCode :=
                    if (empty($timeRefPeriod)) then
                        1
                    else if (not(vldtrefperiod:_is-valid-time-frame($timeRefPeriod, $cycleStartDate, $cycleEndDate))) then
                        2
                    else if (not(vldtrefperiod:_is-valid-quarter-frame($timeRefPeriod))) then
                        3
                    else
                        0
                return
                    if ($errorCode < 1) then
                        ()
                    else
                        vldres:create-flagged-value($qclevels:BLOCKER, $timeRefPeriodStringValue, xs:string($errorCode))
            return
                if (empty($flaggedValues)) then
                    ()
                else
                    let $flaggedColumn := vldres:create-flagged-column-by-values($columnPhenomenonTimePeriod, $flaggedValues)
                    return vldres:create-result-row($dataRow, $flaggedColumn)
};

declare function vldtrefperiod:_parse-period($value as xs:string)
as xs:date*
{
    let $dateTokens := tokenize($value, "\-\-")
    let $tokenCount := count($dateTokens)
    return
        if ($tokenCount > 2) then
            ()
        else if ($tokenCount = 1) then
            vldtrefperiod:_parse-date($value)
        else 
            let $startDate := vldtrefperiod:_parse-period-date($dateTokens[1])
            let $endDate := vldtrefperiod:_parse-period-date($dateTokens[2])
            return 
                if (empty($startDate) or empty($endDate)) then
                    ()
                else
                    ($startDate, $endDate)
};

declare function vldtrefperiod:_parse-date($value as xs:string)
as xs:date?
{
    if ($value castable as xs:date) then
        xs:date($value)
    else
        let $value2 := concat($value, "-01")
        return
            if ($value2 castable as xs:date) then
                xs:date($value2)
            else
                let $value3 := concat($value2, "-01")
                return
                    if ($value3 castable as xs:date) then
                        xs:date($value3)
                    else
                        ()
};

declare function vldtrefperiod:_parse-period-date($value as xs:string)
as xs:date?
{
     let $value2 := concat($value, "-01")
    return
        if ($value2 castable as xs:date) then
            xs:date($value2)
        else
            ()
};

declare function vldtrefperiod:_is-valid-time-frame(
    $timeRefPeriod as xs:date*,
    $cycleStartDate as xs:date,
    $cycleEndDate as xs:date
)
as xs:boolean
{
    let $startDate := $timeRefPeriod[1]
    let $endDate := if (count($timeRefPeriod) > 1) then $timeRefPeriod[2] else $timeRefPeriod[1]
    return $startDate <= $endDate and year-from-date($startDate) >= year-from-date($cycleStartDate) 
            and year-from-date($endDate) <= year-from-date($cycleEndDate) 
};

declare function vldtrefperiod:_is-valid-quarter-frame($timeRefPeriod as xs:date*)
as xs:boolean
{
    if (count($timeRefPeriod) < 2) then
        true()
    else
        let $startDate := $timeRefPeriod[1]
        let $endDate := $timeRefPeriod[2]
        let $startYear := year-from-date($startDate)
        let $endYear := year-from-date($endDate)
        return
            if ($startYear != $endYear) then
                false()
            else
                let $startMonth := month-from-date($startDate)
                let $endMonth := month-from-date($endDate)
                return ($startMonth = 1 and $endMonth = 3) or ($startMonth = 4 and $endMonth = 6)
                        or ($startMonth = 7 and $endMonth = 9) or ($startMonth = 10 and $endMonth = 12)
};
