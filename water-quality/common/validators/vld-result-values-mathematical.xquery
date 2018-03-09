xquery version "1.0" encoding "UTF-8";

module namespace vldwqlrvmath = 'http://converters.eionet.europa.eu/wise/waterQuality/common/validators/resultValuesMathRules';

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../../common/data.xquery';
import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';

declare function vldwqlrvmath:validate-result-values-math-rules(
    $model as element(model),
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $columnResultNumberOfSamples := meta:get-column-by-name($model, "resultNumberOfSamples")
    let $columnResultQualityNumberOfSamplesBelowLOQ := meta:get-column-by-name($model, "resultQualityNumberOfSamplesBelowLOQ")
    let $columnResultQualityMinimumBelowLOQ := meta:get-column-by-name($model, "resultQualityMinimumBelowLOQ")
    let $columnResultMinimumValue := meta:get-column-by-name($model, "resultMinimumValue")
    let $columnResultQualityMeanBelowLOQ := meta:get-column-by-name($model, "resultQualityMeanBelowLOQ")
    let $columnResultMeanValue := meta:get-column-by-name($model, "resultMeanValue")
    let $columnResultQualityMaximumBelowLOQ := meta:get-column-by-name($model, "resultQualityMaximumBelowLOQ")
    let $columnResultMaximumValue := meta:get-column-by-name($model, "resultMaximumValue")
    let $columnResultQualityMedianBelowLOQ := meta:get-column-by-name($model, "resultQualityMedianBelowLOQ")
    let $columnResultMedianValue := meta:get-column-by-name($model, "resultMedianValue")
    let $columnResultStandardDeviationValue := meta:get-column-by-name($model, "resultStandardDeviationValue")
    let $resultRows := vldwqlrvmath:_validate(
        $columnResultNumberOfSamples, $columnResultQualityNumberOfSamplesBelowLOQ,
        $columnResultQualityMinimumBelowLOQ, $columnResultMinimumValue,
        $columnResultQualityMeanBelowLOQ, $columnResultMeanValue,
        $columnResultQualityMaximumBelowLOQ, $columnResultMaximumValue,
        $columnResultQualityMedianBelowLOQ, $columnResultMedianValue,
        $columnResultStandardDeviationValue, $dataRows, 1, ()
    )
    let $tagCounts := vldres:calculate-tag-value-counts($resultRows)
    return vldres:create-result($resultRows, $tagCounts)
};

declare function vldwqlrvmath:_validate(
    $columnResultNumberOfSamples as element(column),
    $columnResultQualityNumberOfSamplesBelowLOQ as element(column),
    $columnResultQualityMinimumBelowLOQ as element(column),
    $columnResultMinimumValue as element(column),
    $columnResultQualityMeanBelowLOQ as element(column),
    $columnResultMeanValue as element(column),
    $columnResultQualityMaximumBelowLOQ as element(column),
    $columnResultMaximumValue as element(column),
    $columnResultQualityMedianBelowLOQ as element(column),
    $columnResultMedianValue as element(column),
    $columnResultStandardDeviationValue as element(column),
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
        let $rowResult := vldwqlrvmath:_validate-data-row(
            $columnResultNumberOfSamples, $columnResultQualityNumberOfSamplesBelowLOQ,
            $columnResultQualityMinimumBelowLOQ, $columnResultMinimumValue,
            $columnResultQualityMeanBelowLOQ, $columnResultMeanValue,
            $columnResultQualityMaximumBelowLOQ, $columnResultMaximumValue,
            $columnResultQualityMedianBelowLOQ, $columnResultMedianValue,
            $columnResultStandardDeviationValue, $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwqlrvmath:_validate(
            $columnResultNumberOfSamples, $columnResultQualityNumberOfSamplesBelowLOQ,
            $columnResultQualityMinimumBelowLOQ, $columnResultMinimumValue,
            $columnResultQualityMeanBelowLOQ, $columnResultMeanValue,
            $columnResultQualityMaximumBelowLOQ, $columnResultMaximumValue,
            $columnResultQualityMedianBelowLOQ, $columnResultMedianValue,
            $columnResultStandardDeviationValue, $dataRows, $dataRowIndex + 1, $newResultRows
        )
};

declare function vldwqlrvmath:_validate-data-row(
    $columnResultNumberOfSamples as element(column),
    $columnResultQualityNumberOfSamplesBelowLOQ as element(column),
    $columnResultQualityMinimumBelowLOQ as element(column),
    $columnResultMinimumValue as element(column),
    $columnResultQualityMeanBelowLOQ as element(column),
    $columnResultMeanValue as element(column),
    $columnResultQualityMaximumBelowLOQ as element(column),
    $columnResultMaximumValue as element(column),
    $columnResultQualityMedianBelowLOQ as element(column),
    $columnResultMedianValue as element(column),
    $columnResultStandardDeviationValue as element(column),
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $resultNumberOfSamples := datax:get-row-decimal-value($dataRow, $columnResultNumberOfSamples)
    let $resultQualityNumberOfSamplesBelowLOQ := datax:get-row-decimal-value($dataRow, $columnResultQualityNumberOfSamplesBelowLOQ)
    let $resultQualityMinimumBelowLOQ := datax:get-row-boolean-value($dataRow, $columnResultQualityMinimumBelowLOQ)
    let $resultMinimumValue := datax:get-row-decimal-value($dataRow, $columnResultMinimumValue)
    let $resultQualityMeanBelowLOQ := datax:get-row-boolean-value($dataRow, $columnResultQualityMeanBelowLOQ)
    let $resultMeanValue := datax:get-row-decimal-value($dataRow, $columnResultMeanValue)
    let $resultQualityMaximumBelowLOQ := datax:get-row-boolean-value($dataRow, $columnResultQualityMaximumBelowLOQ)
    let $resultMaximumValue := datax:get-row-decimal-value($dataRow, $columnResultMaximumValue)
    let $resultQualityMedianBelowLOQ := datax:get-row-boolean-value($dataRow, $columnResultQualityMedianBelowLOQ)
    let $resultMedianValue := datax:get-row-decimal-value($dataRow, $columnResultMedianValue)
    let $resultStandardDeviationValue := datax:get-row-decimal-value($dataRow, $columnResultStandardDeviationValue)
    
    let $ruleResults := (
        vldwqlrvmath:_create-rule-result(
            "01",
            vldwqlrvmath:_is-valid-rule-01($resultMeanValue, $resultMinimumValue), 
            ($columnResultMeanValue, $columnResultMinimumValue)
        ),
        vldwqlrvmath:_create-rule-result(
            "02",
            vldwqlrvmath:_is-valid-rule-02($resultMeanValue, $resultMaximumValue),
            ($columnResultMeanValue, $columnResultMaximumValue)
        ),
        vldwqlrvmath:_create-rule-result(
            "03",
            vldwqlrvmath:_is-valid-rule-03($resultMedianValue, $resultMinimumValue),
            ($columnResultMedianValue, $columnResultMinimumValue)
        ),
        vldwqlrvmath:_create-rule-result(
            "04",
            vldwqlrvmath:_is-valid-rule-04($resultMedianValue, $resultMaximumValue),
            ($columnResultMedianValue, $columnResultMaximumValue)
        ),
        vldwqlrvmath:_create-rule-result(
            "05",
            vldwqlrvmath:_is-valid-rule-05($resultMinimumValue, $resultMaximumValue),
            ($columnResultMinimumValue, $columnResultMaximumValue)
        ),
        vldwqlrvmath:_create-rule-result(
            "06",
            vldwqlrvmath:_is-valid-rule-06($resultMinimumValue, $resultMaximumValue, $resultStandardDeviationValue),
            ($columnResultMinimumValue, $columnResultMaximumValue, $columnResultStandardDeviationValue)
        ),
        vldwqlrvmath:_create-rule-result(
            "07",
            vldwqlrvmath:_is-valid-rule-07($resultMinimumValue, $resultMaximumValue, $resultStandardDeviationValue),
            ($columnResultMinimumValue, $columnResultMaximumValue, $columnResultStandardDeviationValue)
        ),
        vldwqlrvmath:_create-rule-result(
            "08",
            vldwqlrvmath:_is-valid-rule-08($resultNumberOfSamples, $resultMinimumValue, $resultMaximumValue, $resultMeanValue, $resultMedianValue),
            ($columnResultNumberOfSamples, $columnResultMinimumValue, $columnResultMaximumValue, $columnResultMeanValue, $columnResultMedianValue)
        ),
        vldwqlrvmath:_create-rule-result(
            "09",
            vldwqlrvmath:_is-valid-rule-09($resultNumberOfSamples, $resultStandardDeviationValue),
            ($columnResultNumberOfSamples, $columnResultStandardDeviationValue)
        ),
        vldwqlrvmath:_create-rule-result(
            "10",
            vldwqlrvmath:_is-valid-rule-10($resultNumberOfSamples, $resultQualityNumberOfSamplesBelowLOQ),
            ($columnResultNumberOfSamples, $columnResultQualityNumberOfSamplesBelowLOQ)
        ),
        vldwqlrvmath:_create-rule-result(
            "11",
            vldwqlrvmath:_is-valid-rule-11($resultQualityNumberOfSamplesBelowLOQ, $resultQualityMinimumBelowLOQ, $resultQualityMeanBelowLOQ, $resultQualityMaximumBelowLOQ, $resultQualityMedianBelowLOQ),
            ($columnResultQualityNumberOfSamplesBelowLOQ, $columnResultQualityMinimumBelowLOQ, $columnResultQualityMeanBelowLOQ, $columnResultQualityMaximumBelowLOQ, $columnResultQualityMedianBelowLOQ)
        ),
        vldwqlrvmath:_create-rule-result(
            "12",
            vldwqlrvmath:_is-valid-rule-12($resultNumberOfSamples, $resultQualityMinimumBelowLOQ, $resultQualityMeanBelowLOQ, $resultQualityMaximumBelowLOQ, $resultQualityMedianBelowLOQ),
            ($columnResultNumberOfSamples, $columnResultQualityMinimumBelowLOQ, $columnResultQualityMeanBelowLOQ, $columnResultQualityMaximumBelowLOQ, $columnResultQualityMedianBelowLOQ)
        ),
        vldwqlrvmath:_create-rule-result(
            "13",
            vldwqlrvmath:_is-valid-rule-13($resultNumberOfSamples, $resultQualityNumberOfSamplesBelowLOQ, $resultQualityMinimumBelowLOQ, $resultQualityMeanBelowLOQ, $resultQualityMaximumBelowLOQ, $resultQualityMedianBelowLOQ),
            ($columnResultNumberOfSamples, $columnResultQualityNumberOfSamplesBelowLOQ, $columnResultQualityMinimumBelowLOQ, $columnResultQualityMeanBelowLOQ, $columnResultQualityMaximumBelowLOQ, $columnResultQualityMedianBelowLOQ)
        )
    )
    let $columns := (
            $columnResultNumberOfSamples,
            $columnResultQualityNumberOfSamplesBelowLOQ,
            $columnResultQualityMinimumBelowLOQ,
            $columnResultMinimumValue,
            $columnResultQualityMeanBelowLOQ,
            $columnResultMeanValue,
            $columnResultQualityMaximumBelowLOQ,
            $columnResultMaximumValue,
            $columnResultQualityMedianBelowLOQ,
            $columnResultMedianValue,
            $columnResultStandardDeviationValue
    )
    let $flaggedColumns :=
        for $column in $columns
        let $columnName := meta:get-column-name($column)
        let $ruleIds := $ruleResults[@success = false()][column[text() = $columnName]]/@id
        let $columnValue := data:get-row-values($dataRow, $column)[1]
        let $flaggedValues :=
            for $ruleId in $ruleIds
            return vldres:create-flagged-value($qclevels:BLOCKER, $columnValue, $ruleId)
        where not(empty($flaggedValues))
        return vldres:create-flagged-column-by-values($column, $flaggedValues)
    return
        if (empty($flaggedColumns)) then
            ()
        else
            vldres:create-result-row($dataRow, $flaggedColumns)
};

declare function vldwqlrvmath:_create-rule-result($ruleId as xs:string, $isSuccess as xs:boolean, $columns as element(column)*)
as element(ruleResult)
{
    <ruleResult id="{ $ruleId }" success="{ $isSuccess }"> {
        for $column in $columns
        return 
            <column>{ meta:get-column-name($column) }</column>
    }
    </ruleResult>
};

(: resultMeanValue >= resultMinimumValue :)
declare function vldwqlrvmath:_is-valid-rule-01($resultMeanValue as xs:decimal?, $resultMinimumValue as xs:decimal?)
as xs:boolean
{
    empty($resultMeanValue) or empty($resultMinimumValue)
        or $resultMeanValue >= $resultMinimumValue
};

(: resultMaximumValue >= resultMeanValue :)
declare function vldwqlrvmath:_is-valid-rule-02($resultMeanValue as xs:decimal?, $resultMaximumValue as xs:decimal?)
as xs:boolean
{
    empty($resultMeanValue) or empty($resultMaximumValue) 
        or $resultMaximumValue >= $resultMeanValue
};

(: resultMedianValue >= resultMinimumValue :)
declare function vldwqlrvmath:_is-valid-rule-03($resultMedianValue as xs:decimal?, $resultMinimumValue as xs:decimal?)
as xs:boolean
{
    empty($resultMedianValue) or empty($resultMinimumValue) 
        or $resultMedianValue >= $resultMinimumValue
};

(: resultMaximumValue >= resultMedianValue :)
declare function vldwqlrvmath:_is-valid-rule-04($resultMedianValue as xs:decimal?, $resultMaximumValue as xs:decimal?)
as xs:boolean
{
    empty($resultMedianValue) or empty($resultMaximumValue) 
        or $resultMaximumValue >= $resultMedianValue
};

(: resultMaximumValue >= resultMinimumValue :)
declare function vldwqlrvmath:_is-valid-rule-05($resultMinimumValue as xs:decimal?, $resultMaximumValue as xs:decimal?)
as xs:boolean
{
    empty($resultMinimumValue) or empty($resultMaximumValue) 
        or $resultMaximumValue >= $resultMinimumValue
};

(: resultStandardDeviationValue <= (resultMaximumValue - resultMinimumValue) :)
declare function vldwqlrvmath:_is-valid-rule-06(
    $resultMinimumValue as xs:decimal?,
    $resultMaximumValue as xs:decimal?,
    $resultStandardDeviationValue as xs:decimal?
)
as xs:boolean
{
    empty($resultMinimumValue) or empty($resultMaximumValue) or empty($resultStandardDeviationValue)
        or $resultStandardDeviationValue <= $resultMaximumValue - $resultMinimumValue
};

(: If resultMinimumValue < resultMaximumValue Then resultStandardDeviationValue > 0 :)
declare function vldwqlrvmath:_is-valid-rule-07(
    $resultMinimumValue as xs:decimal?,
    $resultMaximumValue as xs:decimal?,
    $resultStandardDeviationValue as xs:decimal?
)
as xs:boolean
{
    empty($resultMinimumValue) or empty($resultMaximumValue) or empty($resultStandardDeviationValue)
        or ( if ($resultMinimumValue < $resultMaximumValue) then $resultStandardDeviationValue > 0 else true())
};

(: If resultNumberOfSamples = 1, then resultMinimumValue = resultMeanValue = resultMaximumValue = resultMedianValue :)
declare function vldwqlrvmath:_is-valid-rule-08(
    $resultNumberOfSamples as xs:decimal?,
    $resultMinimumValue as xs:decimal?,
    $resultMaximumValue as xs:decimal?,
    $resultMeanValue as xs:decimal?,
    $resultMedianValue as xs:decimal?
)
as xs:boolean
{
    empty($resultMinimumValue) or empty($resultMaximumValue) or empty($resultMeanValue) 
        or empty($resultMedianValue) or empty($resultNumberOfSamples) 
        or (
            if ($resultNumberOfSamples = 1) then
              $resultMinimumValue = $resultMaximumValue and $resultMaximumValue = $resultMeanValue 
                and $resultMeanValue = $resultMedianValue
            else 
                true()
        )
};

(: If resultNumberOfSamples = 1, then resultStandardDeviationValue = 0 :)
declare function vldwqlrvmath:_is-valid-rule-09($resultNumberOfSamples as xs:decimal?, $resultStandardDeviationValue as xs:decimal?)
as xs:boolean
{
    empty($resultNumberOfSamples) or empty($resultStandardDeviationValue)
        or (
            if ($resultNumberOfSamples = 1) then
                $resultStandardDeviationValue = 0
            else
                true()
        )
};

(: resultQualityNumberOfSamplesBelowLOQ <= resultNumberOfSamples :)
declare function vldwqlrvmath:_is-valid-rule-10($resultNumberOfSamples as xs:decimal?, $resultQualityNumberOfSamplesBelowLOQ as xs:decimal?)
as xs:boolean
{
    empty($resultNumberOfSamples) or empty($resultQualityNumberOfSamplesBelowLOQ)
        or $resultQualityNumberOfSamplesBelowLOQ <= $resultNumberOfSamples
};

(: If resultQualityNumberOfSamplesBelowLOQ = 0, then resultQualityMinimumBelowLOQ, resultQualityMeanBelowLOQ, resultQualityMaximumBelowLOQ and resultQualityMedianBelowLOQ = False :)
declare function vldwqlrvmath:_is-valid-rule-11(
    $resultQualityNumberOfSamplesBelowLOQ as xs:decimal?,
    $resultQualityMinimumBelowLOQ as xs:boolean?,
    $resultQualityMeanBelowLOQ as xs:boolean?,
    $resultQualityMaximumBelowLOQ as xs:boolean?,
    $resultQualityMedianBelowLOQ as xs:boolean?
)
as xs:boolean
{
    empty($resultQualityNumberOfSamplesBelowLOQ) or empty($resultQualityMinimumBelowLOQ) or empty($resultQualityMeanBelowLOQ)
        or empty($resultQualityMaximumBelowLOQ) or empty($resultQualityMedianBelowLOQ)
        or (
            if ($resultQualityNumberOfSamplesBelowLOQ = 0) then
                not($resultQualityMinimumBelowLOQ) and not($resultQualityMeanBelowLOQ) 
                    and not($resultQualityMaximumBelowLOQ) and not($resultQualityMedianBelowLOQ)
            else
                true()
        )
};

(: If resultNumberOfSamples = 1, then resultQualityMinimumBelowLOQ = resultQualityMeanBelowLOQ = resultQualityMaximumBelowLOQ = resultQualityMedianBelowLOQ :)
declare function vldwqlrvmath:_is-valid-rule-12(
    $resultNumberOfSamples as xs:decimal?,
    $resultQualityMinimumBelowLOQ as xs:boolean?,
    $resultQualityMeanBelowLOQ as xs:boolean?,
    $resultQualityMaximumBelowLOQ as xs:boolean?,
    $resultQualityMedianBelowLOQ as xs:boolean?
)
as xs:boolean
{
    empty($resultNumberOfSamples) or empty($resultQualityMinimumBelowLOQ) or empty($resultQualityMeanBelowLOQ)
        or empty($resultQualityMaximumBelowLOQ) or empty($resultQualityMedianBelowLOQ)
        or (
            if ($resultNumberOfSamples = 1) then
                $resultQualityMinimumBelowLOQ = $resultQualityMeanBelowLOQ and $resultQualityMeanBelowLOQ = $resultQualityMaximumBelowLOQ 
                        and $resultQualityMaximumBelowLOQ = $resultQualityMedianBelowLOQ 
            else
                true()
        )
};

(: If resultQualityNumberOfSamplesBelowLOQ = resultNumberOfSamples, then resultQualityMinimumBelowLOQ, resultQualityMeanBelowLOQ, resultQualityMaximumBelowLOQ and resultQualityMedianBelowLOQ = True :)
declare function vldwqlrvmath:_is-valid-rule-13(
    $resultNumberOfSamples as xs:decimal?,
    $resultQualityNumberOfSamplesBelowLOQ as xs:decimal?,
    $resultQualityMinimumBelowLOQ as xs:boolean?,
    $resultQualityMeanBelowLOQ as xs:boolean?,
    $resultQualityMaximumBelowLOQ as xs:boolean?,
    $resultQualityMedianBelowLOQ as xs:boolean?
)
as xs:boolean
{
    empty($resultNumberOfSamples) or empty($resultQualityNumberOfSamplesBelowLOQ) or empty($resultQualityMinimumBelowLOQ) 
        or empty($resultQualityMeanBelowLOQ) or empty($resultQualityMaximumBelowLOQ) or empty($resultQualityMedianBelowLOQ)
        or (
            if ($resultNumberOfSamples = $resultQualityNumberOfSamplesBelowLOQ) then
                $resultQualityMinimumBelowLOQ and $resultQualityMeanBelowLOQ 
                    and $resultQualityMaximumBelowLOQ and $resultQualityMedianBelowLOQ 
            else
                true()
        )
};
