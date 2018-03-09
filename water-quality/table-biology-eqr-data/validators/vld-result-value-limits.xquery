xquery version "1.0" encoding "UTF-8";

module namespace vldwqlbioeqrdres = 'http://converters.eionet.europa.eu/wise/waterQuality/biologyEqrData/validators/resultValueLimits';

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../../common/data.xquery';
import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace vldtypes = 'http://converters.eionet.europa.eu/common/validators/types' at '../../../common/validators/types.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';

declare function vldwqlbioeqrdres:validate-result-value-limits($model as element(model), $dataRows as element(dataRow)*)
as element(result)
{
    let $columnResultEQRValue := meta:get-column-by-name($model, 'resultEQRValue') 
    let $columnResultObservationStatus := meta:get-column-by-name($model, "resultObservationStatus")
    let $resultRows := vldwqlbioeqrdres:_validate(
        $columnResultEQRValue, $columnResultObservationStatus, $dataRows, 1, 1, ()
    )
    let $valueCounts := vldres:calculate-column-counts($resultRows, $columnResultEQRValue)
    return vldres:create-result($resultRows, $valueCounts)
};

declare function vldwqlbioeqrdres:_validate(
    $columnResultEQRValue as element(column), 
    $columnResultObservationStatus as element(column),
    $dataRows as element(dataRow)*,
    $dataRowIndex as xs:integer,
    $qclevelIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    if ($qclevelIndex > count(qclevels:list-flag-levels-desc())) then
        $resultRows
    else if ($dataRowIndex > count($dataRows)) then
        if ($qclevelIndex > count(qclevels:list-flag-levels-desc())) then
            $resultRows
        else
            vldwqlbioeqrdres:_validate(
                $columnResultEQRValue, $columnResultObservationStatus, $dataRows,
                1, $qclevelIndex + 1, $resultRows
            )
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $currentQclevel := qclevels:list-flag-levels-desc()[$qclevelIndex]
        let $rowResult := vldwqlbioeqrdres:_validate-data-row(
            $columnResultEQRValue, $columnResultObservationStatus, $currentQclevel, $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwqlbioeqrdres:_validate(
            $columnResultEQRValue, $columnResultObservationStatus, $dataRows,
            $dataRowIndex + 1, $qclevelIndex, $newResultRows
        )
};

declare function vldwqlbioeqrdres:_validate-data-row(
    $columnResultEQRValue as element(column), 
    $columnResultObservationStatus as element(column),
    $acceptedQcLevel as xs:integer,
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $resultEQRValue := datax:get-row-decimal-value($dataRow, $columnResultEQRValue)
    return
        if (empty($resultEQRValue) or $resultEQRValue <= 1.5) then
            ()
        else
            let $resultObservationStatus := upper-case(datax:get-row-value($dataRow, $columnResultObservationStatus))
            let $qcLevel :=
                if ($resultObservationStatus = "A") then
                    $qclevels:INFO
                else
                    $qclevels:WARNING
            return
                if ($qcLevel = $acceptedQcLevel) then
                    let $flaggedColumn := vldres:create-flagged-column($columnResultEQRValue, $qcLevel)
                    return vldres:create-result-row($dataRow, $flaggedColumn)
                else
                    ()
};

