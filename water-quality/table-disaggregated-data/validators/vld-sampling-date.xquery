xquery version "1.0" encoding "UTF-8";

module namespace vldwqldismpsdate = 'http://converters.eionet.europa.eu/wise/waterQuality/disaggregatedData/validators/samplingDate';

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../../common/data.xquery';
import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';

declare function vldwqldismpsdate:validate-sampling-date(
    $model as element(model), 
    $dataFlowCycles as element(DataFlows), 
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $columnSamplingDate := meta:get-column-by-name($model, "phenomenonTimeSamplingDate")
    let $flowCycle := vldwqldismpsdate:get-data-flow-cycle($dataFlowCycles)
    let $dateStart := xs:date($flowCycle/timeValuesLimitDateStart)
    let $dateEnd := xs:date($flowCycle/timeValuesLimitDateEnd)
    let $resultRows := vldwqldismpsdate:_validate($columnSamplingDate, $dateStart, $dateEnd, $dataRows, 1, ())
    let $counts := vldres:calculate-column-value-counts($resultRows, $columnSamplingDate)
    return vldres:create-result($resultRows, $counts)
};

declare function vldwqldismpsdate:get-data-flow-cycle($dataFlowCycles as element(DataFlows))
as element(DataFlowCycle)
{
    $dataFlowCycles/DataFlow[@RO_ID="714"]/DataFlowCycle[@Identifier="2016"]
};

declare function vldwqldismpsdate:_validate(
    $columnSamplingDate as element(column), 
    $dateStart as xs:date,
    $dateEnd as xs:date,
    $dataRows as element(dataRow)*,
    $dataRowIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    (for $row in $dataRows
    return vldwqldismpsdate:_validate-data-row($columnSamplingDate, $dateStart, $dateEnd, $row)
    )[position() = 1 to  $vldres:MAX_RECORD_RESULTS]

    (:if ($dataRowIndex > count($dataRows)) then
        $resultRows
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $rowResult := vldwqldismpsdate:_validate-data-row($columnSamplingDate, $dateStart, $dateEnd, $dataRow)
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwqldismpsdate:_validate($columnSamplingDate, $dateStart, $dateEnd, $dataRows, $dataRowIndex + 1, $newResultRows):)
};

declare function vldwqldismpsdate:_validate-data-row(
    $columnSamplingDate as element(column), 
    $dateStart as xs:date,
    $dateEnd as xs:date,
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $samplingDate := datax:get-row-date-value($dataRow, $columnSamplingDate)
    return
        if (empty($samplingDate) or ($samplingDate >= $dateStart and $samplingDate <= $dateEnd)) then
            ()
        else
            let $flaggedValue := vldres:create-flagged-value($qclevels:WARNING, data:get-row-values($dataRow, $columnSamplingDate))
            let $flaggedColumn := vldres:create-flagged-column-by-values($columnSamplingDate, $flaggedValue)
            return vldres:create-result-row($dataRow, $flaggedColumn)
};
