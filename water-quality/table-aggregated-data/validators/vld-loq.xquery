xquery version "1.0" encoding "UTF-8";

module namespace vldwqlaggloq = "http://converters.eionet.europa.eu/wise/waterQuality/aggregatedData/validators/loq";

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../../common/data.xquery';
import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace rdfutil = 'http://converters.eionet.europa.eu/common/rdfutil' at '../../../common/rdf-util.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';
import module namespace vldwqlloq = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/loq" at '../../common/validators/vld-loq.xquery';

declare variable $vldwqlaggloq:_TABLE-NAME := "http://dd.eionet.europa.eu/vocabulary/datadictionary/ddTables/WISE-SoE_WaterQuality.AggregatedData";

declare function vldwqlaggloq:validate-loq($model as element(model), $vocabularyObservedProperty as element(), $dataRows as element(dataRow)*)
as element(result)
{
    let $columnObservedPropertyDeterminandCode := meta:get-column-by-name($model, "observedPropertyDeterminandCode")
    let $columnResultObservationStatus := meta:get-column-by-name($model, "resultObservationStatus")
    let $columnProcedureLOQValue := meta:get-column-by-name($model, "procedureLOQValue")
    let $columnResultQualityNumberOfSamplesBelowLOQ := meta:get-column-by-name($model, "resultQualityNumberOfSamplesBelowLOQ")
    let $columnResultQualityMeanBelowLOQ := meta:get-column-by-name($model, "resultQualityMeanBelowLOQ")
    let $columnResultMeanValue := meta:get-column-by-name($model, "resultMeanValue")
    let $columnResultQualityMinimumBelowLOQ := meta:get-column-by-name($model, "resultQualityMinimumBelowLOQ")
    let $columnResultMinimumValue := meta:get-column-by-name($model, "resultMinimumValue")
    let $columnResultQualityMaximumBelowLOQ := meta:get-column-by-name($model,"resultQualityMaximumBelowLOQ")
    let $columnResultMaximumValue := meta:get-column-by-name($model, "resultMaximumValue")
    let $columnResultQualityMedianBelowLOQ := meta:get-column-by-name($model, "resultQualityMedianBelowLOQ")
    let $columnResultMedianValue := meta:get-column-by-name($model, "resultMedianValue")
    let $resultRows := vldwqlaggloq:_validate(
        $columnObservedPropertyDeterminandCode, $columnResultObservationStatus,
        $columnProcedureLOQValue, $columnResultQualityNumberOfSamplesBelowLOQ,
        $columnResultQualityMeanBelowLOQ, $columnResultMeanValue,
        $columnResultQualityMinimumBelowLOQ, $columnResultMinimumValue,
        $columnResultQualityMaximumBelowLOQ, $columnResultMaximumValue,
        $columnResultQualityMedianBelowLOQ, $columnResultMedianValue,
        $vocabularyObservedProperty, $dataRows, 1, ()
    )
    let $counts := vldres:calculate-tag-column-counts($resultRows)
    return vldres:create-result($resultRows, $counts)
};

declare function vldwqlaggloq:_validate(
    $columnObservedPropertyDeterminandCode as element(column),
    $columnResultObservationStatus as element(column),
    $columnProcedureLOQValue as element(column),
    $columnResultQualityNumberOfSamplesBelowLOQ as element(column),
    $columnResultQualityMeanBelowLOQ as element(column),
    $columnResultMeanValue as element(column),
    $columnResultQualityMinimumBelowLOQ as element(column),
    $columnResultMinimumValue as element(column),
    $columnResultQualityMaximumBelowLOQ as element(column),
    $columnResultMaximumValue as element(column),
    $columnResultQualityMedianBelowLOQ as element(column),
    $columnResultMedianValue as element(column),
    $vocabularyObservedProperty as element(),
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
        let $rowResult := vldwqlaggloq:_validate-row(
            $columnObservedPropertyDeterminandCode, $columnResultObservationStatus,
            $columnProcedureLOQValue, $columnResultQualityNumberOfSamplesBelowLOQ,
            $columnResultQualityMeanBelowLOQ, $columnResultMeanValue,
            $columnResultQualityMinimumBelowLOQ, $columnResultMinimumValue,
            $columnResultQualityMaximumBelowLOQ, $columnResultMaximumValue,
            $columnResultQualityMedianBelowLOQ, $columnResultMedianValue,
            $vocabularyObservedProperty, $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwqlaggloq:_validate(
            $columnObservedPropertyDeterminandCode, $columnResultObservationStatus,
            $columnProcedureLOQValue, $columnResultQualityNumberOfSamplesBelowLOQ,
            $columnResultQualityMeanBelowLOQ, $columnResultMeanValue,
            $columnResultQualityMinimumBelowLOQ, $columnResultMinimumValue,
            $columnResultQualityMaximumBelowLOQ, $columnResultMaximumValue,
            $columnResultQualityMedianBelowLOQ, $columnResultMedianValue,
            $vocabularyObservedProperty, $dataRows, $dataRowIndex + 1, $newResultRows
        )
};

declare function vldwqlaggloq:_validate-row(
    $columnObservedPropertyDeterminandCode as element(column),
    $columnResultObservationStatus as element(column),
    $columnProcedureLOQValue as element(column),
    $columnResultQualityNumberOfSamplesBelowLOQ as element(column),
    $columnResultQualityMeanBelowLOQ as element(column),
    $columnResultMeanValue as element(column),
    $columnResultQualityMinimumBelowLOQ as element(column),
    $columnResultMinimumValue as element(column),
    $columnResultQualityMaximumBelowLOQ as element(column),
    $columnResultMaximumValue as element(column),
    $columnResultQualityMedianBelowLOQ as element(column),
    $columnResultMedianValue as element(column),
    $vocabularyObservedProperty as element(),
    $dataRow as element(dataRow)
)
as element(row)?
{
    if (not(vldwqlaggloq:_is-valid-by-qc-1($columnObservedPropertyDeterminandCode, $columnResultObservationStatus, 
            $columnProcedureLOQValue, $vocabularyObservedProperty, $dataRow))) then
        let $flaggedColumn := vldres:create-flagged-column($columnProcedureLOQValue, $qclevels:ERROR, "1")
        return vldres:create-result-row($dataRow, $flaggedColumn)
    else
        let $flaggedColumns := (
            vldwqlaggloq:_validate-by-condition($columnResultQualityMeanBelowLOQ, $columnResultMeanValue, $columnProcedureLOQValue, "2", $dataRow),
            vldwqlaggloq:_validate-by-condition($columnResultQualityMinimumBelowLOQ, $columnResultMinimumValue, $columnProcedureLOQValue, "3", $dataRow),
            vldwqlaggloq:_validate-by-condition($columnResultQualityMaximumBelowLOQ, $columnResultMaximumValue, $columnProcedureLOQValue, "4", $dataRow),
            vldwqlaggloq:_validate-by-condition($columnResultQualityMedianBelowLOQ, $columnResultMedianValue, $columnProcedureLOQValue, "5", $dataRow)
        )
        return
            if (empty($flaggedColumns)) then
                ()
            else
                vldres:create-result-row($dataRow, ($flaggedColumns, vldres:create-flagged-column($columnProcedureLOQValue, $qclevels:ERROR)))
};

declare function vldwqlaggloq:_is-valid-by-qc-1(
    $columnObservedPropertyDeterminandCode as element(column),
    $columnResultObservationStatus as element(column),
    $columnProcedureLOQValue as element(column),
    $vocabularyObservedProperty as element(),
    $dataRow as element(dataRow)
)
as xs:boolean
{
    vldwqlloq:is-valid-by-qc-1($columnObservedPropertyDeterminandCode, $columnResultObservationStatus, $columnProcedureLOQValue, 
        $vldwqlaggloq:_TABLE-NAME, $vocabularyObservedProperty,$dataRow)
};

declare function vldwqlaggloq:_validate-by-condition(
    $columnBooleanIndicator as element(column),
    $columnValue as element(column),
    $columnProcedureLOQValue as element(column),
    $qcTag as xs:string,
    $dataRow
)
as element(flaggedColumn)*
{
    if (vldwqlaggloq:_is-valid-by-condition($columnBooleanIndicator, $columnValue, $columnProcedureLOQValue, $dataRow)) then
        ()
    else
        (
            vldres:create-flagged-column($columnBooleanIndicator, $qclevels:ERROR, $qcTag),
            vldres:create-flagged-column($columnValue, $qclevels:ERROR, $qcTag)
        )
};

declare function vldwqlaggloq:_is-valid-by-condition(
    $columnBooleanIndicator as element(column), 
    $columnValue as element(column), 
    $columnProcedureLOQValue as element(column), 
    $dataRow as element(dataRow)
)
as xs:boolean
{
    let $booleanIndicator := datax:get-row-boolean-value($dataRow, $columnBooleanIndicator)
    let $procedureLOQValue := datax:get-row-float-value($dataRow, $columnProcedureLOQValue)
    return
        if ($booleanIndicator = true() and not(empty($procedureLOQValue))) then
            if (data:is-empty-cell($dataRow, $columnValue)) then
                false()
            else
                let $value := datax:get-row-float-value($dataRow, $columnValue)
                return empty($value) or $value = $procedureLOQValue
        else
            true()
};
