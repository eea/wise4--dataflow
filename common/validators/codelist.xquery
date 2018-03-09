xquery version "1.0" encoding "UTF-8";

module namespace vldclist = 'http://converters.eionet.europa.eu/common/validators/codelist';

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../data.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../qclevels.xquery';
import module namespace util = 'http://converters.eionet.europa.eu/common/util' at '../util.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at 'validation-result.xquery';

declare variable $vldclist:_ALLOWED_BOOLEAN_VALUES as xs:string* := ("true", "false", "1", "0");

declare function vldclist:validate-codelists($model as element(model), $dataRows as element(dataRow)*)
as element(result)
{
    vldclist:validate-codelists($model, (), $dataRows)
};

declare function vldclist:validate-codelists($model as element(model), $exceptions as element(codelistException)*, $dataRows as element(dataRow)*)
as element(result)
{
    let $codelistColumns := meta:get-valuelist-columns($model)
    let $mixRowResults := vldclist:_validate-codelists($codelistColumns, $exceptions, $dataRows, 1, 1, ())
    let $rowResults := vldres:filter-max-qc-level-by-flagged-values($mixRowResults)
    let $columnCounts := vldres:calculate-column-counts($rowResults, $codelistColumns) 
    return
        vldres:create-result($rowResults, $columnCounts)
};

declare function vldclist:_validate-codelists(
    $codelistColumns as element(column)*, 
    $exceptions as element(codelistException)*, 
    $dataRows as element(dataRow)*,
    $dataRowIndex as xs:integer,
    $qclevelIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    let $blocker := vldres:mark_trunkated(
        (for $row in $dataRows
        let $currentQclevel := qclevels:list-flag-levels-desc()[1]
        return vldclist:_validate-row-codelists($codelistColumns, $exceptions, $row, $currentQclevel)
        ), $vldres:MAX_RECORD_RESULTS)
    let $error := vldres:mark_trunkated(
        (for $row in $dataRows
        let $currentQclevel := qclevels:list-flag-levels-desc()[2]
        return vldclist:_validate-row-codelists($codelistColumns, $exceptions, $row, $currentQclevel)
        ), $vldres:MAX_RECORD_RESULTS)
    let $warning := vldres:mark_trunkated(
        (for $row in $dataRows
        let $currentQclevel := qclevels:list-flag-levels-desc()[3]
        return vldclist:_validate-row-codelists($codelistColumns, $exceptions, $row, $currentQclevel)
        ), $vldres:MAX_RECORD_RESULTS)
    let $info := vldres:mark_trunkated(
        (for $row in $dataRows
        let $currentQclevel := qclevels:list-flag-levels-desc()[4]
        return vldclist:_validate-row-codelists($codelistColumns, $exceptions, $row, $currentQclevel)
        ), $vldres:MAX_RECORD_RESULTS)
    return
        ($blocker, $error, $warning, $info)

    (:if ($qclevelIndex > count(qclevels:list-flag-levels-desc())) then
        $resultRows
    else if ($dataRowIndex > count($dataRows)) then
        if ($qclevelIndex > count(qclevels:list-flag-levels-desc())) then
            $resultRows
        else
            vldclist:_validate-codelists($codelistColumns, $exceptions, $dataRows, 1, $qclevelIndex + 1, $resultRows)
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $currentQclevel := qclevels:list-flag-levels-desc()[$qclevelIndex]
        let $rowResult := vldclist:_validate-row-codelists($codelistColumns, $exceptions, $dataRow, $currentQclevel)
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldclist:_validate-codelists($codelistColumns, $exceptions, $dataRows, $dataRowIndex + 1, $qclevelIndex, $newResultRows):)
};

declare function vldclist:_validate-row-codelists(
    $codelistColumns as element(column)*,
    $exceptions as element(codelistException)*,
    $dataRow as element(dataRow),
    $acceptedQcLevel as xs:integer
)
as element(row)?
{
    let $flaggedColumns :=
        for $codelistColumn in $codelistColumns
        return vldclist:validate-codelist($codelistColumn, $exceptions, $dataRow, $acceptedQcLevel)
    return
        if (empty($flaggedColumns)) then
            ()
        else
            vldres:create-result-row($dataRow, $flaggedColumns)
};

declare function vldclist:validate-codelist($column as element(column), $dataRow as element(dataRow))
as element(flaggedColumn)?
{
    vldclist:validate-codelist($column, (), $dataRow)
};

declare function vldclist:validate-codelist($column as element(column), $exceptions as element(codelistException)*, $dataRow as element(dataRow))
as element(flaggedColumn)?
{
    vldclist:validate-codelist($column, $exceptions, $dataRow, ())
};

declare function vldclist:validate-codelist(
    $column as element(column),
    $exceptions as element(codelistException)*,
    $dataRow as element(dataRow),
    $acceptedQcLevel as xs:integer?
)
as element(flaggedColumn)?
{
    let $rowValues := data:get-row-values($dataRow, $column)
    return
        if (data:is-empty-value($rowValues)) then
            ()
        else
            let $rowValuesLower := util:lower-case($rowValues)
            let $codelistCodes := vldclist:_get-codelist-codes($column)
            let $flaggedValues :=
                for $value at $pos in $rowValuesLower
                let $isValid := $value = $codelistCodes
                let $errorCode := if ($isValid) then $qclevels:OK else vldclist:_get-qc-level($column, $exceptions)
                where $errorCode != $qclevels:OK and (empty($acceptedQcLevel) or $errorCode = $acceptedQcLevel)
                return
                    vldres:create-flagged-value($errorCode, $rowValues[$pos])
            return
                if (empty($flaggedValues)) then
                    ()
                else
                    vldres:create-flagged-column-by-values($column, $flaggedValues)
};

declare function vldclist:_get-codelist-codes($column as element(column))
as xs:string*
{
    let $codelistCodes := util:lower-case(data($column/valueList/value/@code))
    return
        if (string($column/@dataType) != "boolean") then
            $codelistCodes
        else
            ($codelistCodes, $vldclist:_ALLOWED_BOOLEAN_VALUES)
        
};

declare function vldclist:_get-qc-level($column as element(column), $exceptions as element(codelistException)*)
as xs:integer
{
    let $columnName := meta:get-column-name($column)
    let $columnExceptions := $exceptions[@columnName = $columnName]
    return
        if (not(empty($columnExceptions))) then
            xs:integer($columnExceptions[1]/@onMatch)
        else if (meta:is-suggested-valuelist($column/valueList)) then
            $qclevels:WARNING
        else
            $qclevels:BLOCKER
};
