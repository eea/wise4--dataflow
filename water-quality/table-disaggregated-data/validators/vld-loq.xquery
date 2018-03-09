xquery version "1.0" encoding "UTF-8";

module namespace vldwqldisloq = "http://converters.eionet.europa.eu/wise/waterQuality/disaggregatedData/validators/loq";

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../../common/data.xquery';
import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace rdfutil = 'http://converters.eionet.europa.eu/common/rdfutil' at '../../../common/rdf-util.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';
import module namespace vldwqlloq = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/loq" at '../../common/validators/vld-loq.xquery';

declare variable $vldwqldisloq:_TABLE-NAME := "http://dd.eionet.europa.eu/vocabulary/datadictionary/ddTables/WISE-SoE_WaterQuality.DisaggregatedData";

declare function vldwqldisloq:validate-loq($model as element(model), $vocabularyObservedProperty as element(), $dataRows as element(dataRow)*)
as element(result)
{
    let $columnObservedPropertyDeterminandCode := meta:get-column-by-name($model, "observedPropertyDeterminandCode")
    let $columnResultObservedValue := meta:get-column-by-name($model, "resultObservedValue")
    let $columnResultObservationStatus := meta:get-column-by-name($model, "resultObservationStatus") 
    let $columnResultQualityObservedValueBelowLOQ := meta:get-column-by-name($model, "resultQualityObservedValueBelowLOQ") 
    let $columnProcedureLOQValue := meta:get-column-by-name($model, "procedureLOQValue")
    let $resultRows := vldwqldisloq:_validate(
        $columnObservedPropertyDeterminandCode,
        $columnResultObservationStatus,
        $columnProcedureLOQValue,
        $columnResultQualityObservedValueBelowLOQ,
        $columnResultObservedValue,
        $vocabularyObservedProperty,
        $dataRows
    )
    let $counts := vldres:calculate-tag-column-counts($resultRows)
    return vldres:create-result($resultRows, $counts)
};

declare function vldwqldisloq:_validate(
    $columnObservedPropertyDeterminandCode as element(column),
    $columnResultObservationStatus as element(column),
    $columnProcedureLOQValue as element(column),
    $columnResultQualityObservedValueBelowLOQ as element(column),
    $columnResultObservedValue as element(column),
    $vocabularyObservedProperty as element(),
    $dataRows as element(dataRow)*
)
as element(row)*
{
    vldwqldisloq:_validate(
        $columnObservedPropertyDeterminandCode,
        $columnResultObservationStatus,
        $columnProcedureLOQValue,
        $columnResultQualityObservedValueBelowLOQ,
        $columnResultObservedValue,
        $vocabularyObservedProperty,
        $dataRows,
        1,
        ()
    )
};

declare function vldwqldisloq:_validate(
    $columnObservedPropertyDeterminandCode as element(column),
    $columnResultObservationStatus as element(column),
    $columnProcedureLOQValue as element(column),
    $columnResultQualityObservedValueBelowLOQ as element(column),
    $columnResultObservedValue as element(column),
    $vocabularyObservedProperty as element(),
    $dataRows as element(dataRow)*,
    $dataRowIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    let $concepts := rdfutil:conceptsLoq($vocabularyObservedProperty)
    return
    (for $row in $dataRows
    return vldwqldisloq:_validate-row(
            $columnObservedPropertyDeterminandCode,
            $columnResultObservationStatus,
            $columnProcedureLOQValue,
            $columnResultQualityObservedValueBelowLOQ,
            $columnResultObservedValue,
            $concepts,
            $row
    ))[position() = 1 to  $vldres:MAX_RECORD_RESULTS]
    (:if ($dataRowIndex > count($dataRows)) then
        $resultRows
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $rowResult := vldwqldisloq:_validate-row(
            $columnObservedPropertyDeterminandCode,
            $columnResultObservationStatus,
            $columnProcedureLOQValue,
            $columnResultQualityObservedValueBelowLOQ,
            $columnResultObservedValue,
            $vocabularyObservedProperty,
            $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwqldisloq:_validate(
            $columnObservedPropertyDeterminandCode,
            $columnResultObservationStatus,
            $columnProcedureLOQValue,
            $columnResultQualityObservedValueBelowLOQ,
            $columnResultObservedValue,
            $vocabularyObservedProperty,
            $dataRows,
            $dataRowIndex + 1,
            $newResultRows
        ):)
};

declare function vldwqldisloq:_validate-row(
    $columnObservedPropertyDeterminandCode as element(column),
    $columnResultObservationStatus as element(column),
    $columnProcedureLOQValue as element(column),
    $columnResultQualityObservedValueBelowLOQ as element(column),
    $columnResultObservedValue as element(column),
    $concepts as xs:string*,
    $dataRow as element(dataRow)
)
as element(row)?
{
    if (not(vldwqldisloq:_is-valid-by-qc-1($columnObservedPropertyDeterminandCode, $columnResultObservationStatus, $columnProcedureLOQValue, $concepts, $dataRow))) then
        let $flaggedColumn := vldres:create-flagged-column($columnProcedureLOQValue, $qclevels:ERROR, "1")
        return vldres:create-result-row($dataRow, $flaggedColumn)
    else if (vldwqldisloq:_is-valid-by-qc-2($columnResultQualityObservedValueBelowLOQ, $columnResultObservedValue, $columnProcedureLOQValue, $dataRow)) then
        ()
    else
        let $flaggedColumns := (
            vldres:create-flagged-column($columnResultObservedValue, $qclevels:ERROR, "2"),
            vldres:create-flagged-column($columnResultQualityObservedValueBelowLOQ, $qclevels:ERROR),
            vldres:create-flagged-column($columnProcedureLOQValue, $qclevels:ERROR)
        )
        return vldres:create-result-row($dataRow, $flaggedColumns)
};

declare function vldwqldisloq:_is-valid-by-qc-1(
    $columnObservedPropertyDeterminandCode as element(column),
    $columnResultObservationStatus as element(column),
    $columnProcedureLOQValue as element(column),
    $concepts as xs:string*,
    $dataRow as element(dataRow)
)
as xs:boolean
{
    vldwqlloq:is-valid-by-qc-1($columnObservedPropertyDeterminandCode, $columnResultObservationStatus, $columnProcedureLOQValue, 
        $vldwqldisloq:_TABLE-NAME, $concepts,$dataRow)
};

declare function vldwqldisloq:_is-valid-by-qc-2(
    $columnResultQualityObservedValueBelowLOQ as element(column),
    $columnResultObservedValue as element(column),
    $columnProcedureLOQValue as element(column),
    $dataRow as element(dataRow)
)
as xs:boolean
{
    let $resultQualityObservedValueBelowLOQ := datax:get-row-boolean-value($dataRow, $columnResultQualityObservedValueBelowLOQ)
    return
        if (not($resultQualityObservedValueBelowLOQ = true())) then
            true()
        else
            let $procedureLOQValue := datax:get-row-float-value($dataRow, $columnProcedureLOQValue)
            let $resultObservedValue := datax:get-row-decimal-value($dataRow, $columnResultObservedValue)
            return
                if (data:is-empty-cell($dataRow, $columnProcedureLOQValue)) then
                    empty($resultObservedValue)
                else if (data:is-empty-cell($dataRow, $columnResultObservedValue)) then
                    empty($procedureLOQValue)
                else
                    empty($procedureLOQValue) or empty($resultObservedValue) or $resultObservedValue = $procedureLOQValue
};
