xquery version "1.0" encoding "UTF-8";

module namespace vldsampleperiod = 'http://converters.eionet.europa.eu/wise/common/validators/samplingPeriod';

import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../common/data.xquery";
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../common/validators/validation-result.xquery';
import module namespace vldtypes = 'http://converters.eionet.europa.eu/common/validators/types' at '../../common/validators/types.xquery';

declare function vldsampleperiod:validate-sampling-period(
    $columnSamplingPeriod as element(column),
    $columnReferenceYear as element(column), 
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $resultRows := vldsampleperiod:_validate($columnSamplingPeriod, $columnReferenceYear, $dataRows, 1, ())
    let $tagCounts := vldres:calculate-tag-value-counts($resultRows)
    return vldres:create-result($resultRows, $tagCounts)
};   

declare function vldsampleperiod:_validate(
    $columnSamplingPeriod as element(column),
    $columnReferenceYear as element(column), 
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
        let $rowResult := vldsampleperiod:_validate-data-row($columnSamplingPeriod, $columnReferenceYear, $dataRow)
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldsampleperiod:_validate($columnSamplingPeriod, $columnReferenceYear, $dataRows, $dataRowIndex + 1, $newResultRows)
};

declare function vldsampleperiod:_validate-data-row(
    $columnSamplingPeriod as element(column),
    $columnReferenceYear as element(column),
    $dataRow as element()
)
as element(row)?
{
    let $samplingPeriodStringValues := data:get-row-values($dataRow, $columnSamplingPeriod)
    return
        if (data:is-empty-value($samplingPeriodStringValues)) then
            ()
        else
            let $flaggedValues :=
                for $samplingPeriodStringValue in $samplingPeriodStringValues
                let $samplingPeriod := vldsampleperiod:_parse-period($samplingPeriodStringValue)
                let $errorCode :=
                    if (empty($samplingPeriod)) then
                        1
                    else
                        let $startDate := $samplingPeriod[1]
                        let $endDate := $samplingPeriod[2]
                        return
                            if (not(vldsampleperiod:_is-valid-time-frame($startDate, $endDate))) then
                                2
                            else if (not(vldsampleperiod:_is-at-most-ne-year-frame($startDate, $endDate))) then
                                3
                            else
                                let $referenceYearStringValue := data:get-row-values($dataRow, $columnReferenceYear)
                                return
                                    if (data:is-empty-value($referenceYearStringValue) or vldtypes:validate-by-type($columnReferenceYear, $referenceYearStringValue)) then
                                        0
                                    else
                                        let $referenceYear := xs:integer($referenceYearStringValue)
                                        return
                                            if (vldsampleperiod:_is-valid-by-time-reference($startDate, $endDate, $referenceYear)) then
                                                0
                                            else
                                                4
                return
                    if ($errorCode < 1) then
                        ()
                    else
                        vldres:create-flagged-value($qclevels:ERROR, $samplingPeriodStringValue, xs:string($errorCode))
            return
                if (empty($flaggedValues)) then
                    ()
                else
                    let $flaggedColumn := vldres:create-flagged-column-by-values($columnSamplingPeriod, $flaggedValues)
                    return vldres:create-result-row($dataRow, $flaggedColumn)
};

declare function vldsampleperiod:_parse-period($value as xs:string)
as xs:date*
{
    let $dateTokens := tokenize($value, "\-\-")
    return
        if (count($dateTokens) != 2) then
            ()
        else 
            let $startDate := vldsampleperiod:_parse-date($dateTokens[1])
            let $endDate := vldsampleperiod:_parse-date($dateTokens[2])
            return
                if (empty($startDate) or empty($endDate)) then
                    ()
                else
                    ($startDate, $endDate)
};

declare function vldsampleperiod:_parse-date($value as xs:string)
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
                ()
};

declare function vldsampleperiod:_is-valid-time-frame($startDate as xs:date, $endDate as xs:date)
as xs:boolean
{
    year-from-date($startDate) <= year-from-date($endDate) and $startDate <= $endDate
};

declare function vldsampleperiod:_is-at-most-ne-year-frame($startDate as xs:date, $endDate as xs:date)
as xs:boolean
{
    days-from-duration($endDate - $startDate) <= 365
};

declare function vldsampleperiod:_is-valid-by-time-reference($startDate as xs:date, $endDate as xs:date, $referenceYear as xs:integer)
as xs:boolean
{
    year-from-date($startDate) = $referenceYear or year-from-date($endDate) = $referenceYear
};
