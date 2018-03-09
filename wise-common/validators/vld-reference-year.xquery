xquery version "1.0" encoding "UTF-8";

module namespace vldrefyear = 'http://converters.eionet.europa.eu/wise/common/validators/referenceYear';

import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../common/data.xquery";
import module namespace datax = "http://converters.eionet.europa.eu/common/dataExtensions" at "../../common/data-extensions.xquery";
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../common/validators/validation-result.xquery';

declare function vldrefyear:validate-reference-year(
    $columnReferenceYear as element(column),
    $dataFlowCycles as element(DataFlows),
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $flowCycle := vldrefyear:get-data-flow-cycle($dataFlowCycles)
    let $yearStart := vldrefyear:get-start-year($flowCycle)
    let $yearEnd := vldrefyear:get-end-year($flowCycle)
    let $resultRows := vldrefyear:_validate($columnReferenceYear, $yearStart, $yearEnd, $dataRows, 1, ())
    let $counts := vldres:calculate-column-value-counts($resultRows, $columnReferenceYear)
    return vldres:create-result($resultRows, $counts)
};

declare function vldrefyear:validate-reference-year-biology-2017(
        $columnReferenceYear as element(column),
        $dataFlowCycles as element(DataFlows),
        $dataRows as element(dataRow)*
)
as element(result)
{
    let $flowCycle := vldrefyear:get-data-flow-cycle_bio_2017($dataFlowCycles)
    let $yearStart := vldrefyear:get-start-year($flowCycle)
    let $yearEnd := vldrefyear:get-end-year($flowCycle)
    let $resultRows := vldrefyear:_validate($columnReferenceYear, $yearStart, $yearEnd, $dataRows, 1, ())
    let $counts := vldres:calculate-column-value-counts($resultRows, $columnReferenceYear)
    return vldres:create-result($resultRows, $counts)
};

declare function vldrefyear:validate-reference-year-emissions-2017(
        $columnReferenceYear as element(column),
        $dataFlowCycles as element(DataFlows),
        $dataRows as element(dataRow)*
)
as element(result)
{
    let $flowCycle := vldrefyear:get-data-flow-cycle_emission_2017($dataFlowCycles)
    let $yearStart := vldrefyear:get-start-year($flowCycle)
    let $yearEnd := vldrefyear:get-end-year($flowCycle)
    let $resultRows := vldrefyear:_validate($columnReferenceYear, $yearStart, $yearEnd, $dataRows, 1, ())
    let $counts := vldres:calculate-column-value-counts($resultRows, $columnReferenceYear)
    return vldres:create-result($resultRows, $counts)
};

declare function vldrefyear:get-data-flow-cycle($dataFlowCycles as element(DataFlows))
as element(DataFlowCycle)
{
    $dataFlowCycles/DataFlow[@RO_ID="714"]/DataFlowCycle[@Identifier="2016"]
};

declare function vldrefyear:get-data-flow-cycle_bio_2017($dataFlowCycles as element(DataFlows))
as element(DataFlowCycle)
{
    $dataFlowCycles/DataFlow[@RO_ID="630"]/DataFlowCycle[@Identifier="2017"]
};

declare function vldrefyear:get-data-flow-cycle_emission_2017($dataFlowCycles as element(DataFlows))
as element(DataFlowCycle)
{
    $dataFlowCycles/DataFlow[@RO_ID="632"]/DataFlowCycle[@Identifier="2017"]
};

declare function vldrefyear:get-start-year($dataFlowCycle as element(DataFlowCycle))
as xs:integer
{
    year-from-date(xs:date($dataFlowCycle/timeValuesLimitDateStart))
};

declare function vldrefyear:get-end-year($dataFlowCycle as element(DataFlowCycle))
as xs:integer
{
    year-from-date(xs:date($dataFlowCycle/timeValuesLimitDateEnd))
};

declare function vldrefyear:_validate(
    $columnReferenceYear as element(column), 
    $yearStart as xs:integer,
    $yearEnd as xs:integer,
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
        let $rowResult := vldrefyear:_validate-data-row($columnReferenceYear, $yearStart, $yearEnd, $dataRow)
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldrefyear:_validate($columnReferenceYear, $yearStart, $yearEnd, $dataRows, $dataRowIndex + 1 ,$newResultRows)
};

declare function vldrefyear:_validate-data-row(
    $columnReferenceYear as element(column), 
    $yearStart as xs:integer,
    $yearEnd as xs:integer,
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $yearValue := datax:get-row-integer-value($dataRow, $columnReferenceYear)
    return
        if (empty($yearValue) or ($yearValue >= $yearStart and $yearValue <= $yearEnd)) then
            ()
        else
            let $flaggedValue := vldres:create-flagged-value($qclevels:WARNING, data:get-row-values($dataRow, $columnReferenceYear))
            let $flaggedColumn := vldres:create-flagged-column-by-values($columnReferenceYear, $flaggedValue)
            return vldres:create-result-row($dataRow, $flaggedColumn)
};
