xquery version "1.0" encoding "UTF-8";

module namespace vldwqldsmpdpth = "http://converters.eionet.europa.eu/wise/biology/common/validators/sampleDepth";

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../../common/data.xquery';
import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace rdfutil = 'http://converters.eionet.europa.eu/common/rdfutil' at '../../../common/rdf-util.xquery';
import module namespace util = 'http://converters.eionet.europa.eu/common/util' at '../../../common/util.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';

declare function vldwqldsmpdpth:validate-sample-depth(
    $model as element(model), 
    $vocabularyMonitoringSites as element(), 
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $columnParameterSampleDepth := meta:get-column-by-name($model, "parameterSampleDepth") 
    let $columnMonitoringSiteId := meta:get-column-by-name($model, "monitoringSiteIdentifier")
    let $columnMonitoringSiteIdScheme := meta:get-column-by-name($model, "monitoringSiteIdentifierScheme")
    let $monitoringSiteConcepts := rdfutil:concepts($vocabularyMonitoringSites)[not(empty(./*[local-name(.) = "hasMaximumDepth"]))]
    let $resultRows := vldwqldsmpdpth:_validate(
        $columnParameterSampleDepth, $columnMonitoringSiteId, $columnMonitoringSiteIdScheme,
        $monitoringSiteConcepts, $dataRows, 1, ()
    )
    return vldres:create-result($resultRows)
};

declare function vldwqldsmpdpth:create-max-depth-pseudo-column()
as element(column)
{
    <column name="maximumDepth" localName="maximumDepth" />
};

declare function vldwqldsmpdpth:_validate(
    $columnParameterSampleDepth as element(column), 
    $columnMonitoringSiteId as element(column),
    $columnMonitoringSiteIdScheme as element(column),
    $monitoringSiteConcepts as element()*,
    $dataRows as element(dataRow)*,
    $dataRowIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    (for $row in $dataRows
    return vldwqldsmpdpth:_validate-row(
            $columnParameterSampleDepth, $columnMonitoringSiteId, $columnMonitoringSiteIdScheme, $monitoringSiteConcepts, $row
    ))[position() = 1 to  $vldres:MAX_RECORD_RESULTS]

    (:if ($dataRowIndex > count($dataRows)) then
        $resultRows
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $rowResult := vldwqldsmpdpth:_validate-row(
            $columnParameterSampleDepth, $columnMonitoringSiteId, $columnMonitoringSiteIdScheme, $monitoringSiteConcepts, $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwqldsmpdpth:_validate(
            $columnParameterSampleDepth, $columnMonitoringSiteId, $columnMonitoringSiteIdScheme,
            $monitoringSiteConcepts, $dataRows, $dataRowIndex + 1, $newResultRows
        ):)
};

declare function vldwqldsmpdpth:_validate-row(
    $columnParameterSampleDepth as element(column), 
    $columnMonitoringSiteId as element(column),
    $columnMonitoringSiteIdScheme as element(column),
    $monitoringSiteConcepts as element()*,
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $sampleDepth := datax:get-row-float-value($dataRow, $columnParameterSampleDepth)
    let $siteId := datax:get-row-value($dataRow, $columnMonitoringSiteId)
    let $siteIdScheme := datax:get-row-value($dataRow, $columnMonitoringSiteIdScheme)
    return
        if (empty($sampleDepth) or empty($siteId) or empty($siteIdScheme)) then
            ()
        else
            let $maxDepth := vldwqldsmpdpth:_get-max-depth($monitoringSiteConcepts, $siteId, $siteIdScheme)
            return
                if (empty($maxDepth) or $sampleDepth <= $maxDepth) then
                    ()
                else
                    let $flaggedColumns := (
                        vldres:create-flagged-column($columnParameterSampleDepth, $qclevels:ERROR),
                        vldres:create-flagged-column(vldwqldsmpdpth:create-max-depth-pseudo-column(), $qclevels:ERROR)
                    )
                    let $enhancedDataRow := vldwqldsmpdpth:_enhance-data-row-with-max-depth($dataRow, $maxDepth)
                    return vldres:create-result-row($enhancedDataRow, $flaggedColumns)
};

declare function vldwqldsmpdpth:_get-max-depth($monitoringSiteConcepts as element()*, $siteId as xs:string, $siteIdScheme as xs:string)
as xs:float?
{
    let $conceptUri := concat("http://dd.eionet.europa.eu/vocabulary/wise/MonitoringSite/", $siteIdScheme, ".", $siteId)
    let $maxDepthElm := $monitoringSiteConcepts[rdfutil:about(.) = $conceptUri]/*[local-name(.) = "hasMaximumDepth"]
    return
        if (empty($maxDepthElm)) then
            ()
        else
            let $stringValue := string($maxDepthElm)
            return
                if ($stringValue castable as xs:float) then
                    xs:float($stringValue)
                else
                    ()
};

declare function vldwqldsmpdpth:_enhance-data-row-with-max-depth($dataRow as element(dataRow), $maxDepth as xs:float)
as element(dataRow)
{
    let $enhancedDDRow := 
        <Row>
            { data:get-row-content($dataRow)/* }
            <maximumDepth>{ $maxDepth }</maximumDepth>
        </Row>
    return data:create-data-row($enhancedDDRow, data:get-row-index($dataRow))
};
