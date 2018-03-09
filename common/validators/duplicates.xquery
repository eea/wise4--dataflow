xquery version "1.0" encoding "UTF-8";

module namespace vldduplicates = 'http://converters.eionet.europa.eu/common/validators/duplicates';

import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../qclevels.xquery';
import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../data.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../meta.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at 'validation-result.xquery';

declare function vldduplicates:validate-duplicate-rows($rows as element(dataRow)*, $keyColumns as element(column)*)
as element(result)
{
    vldduplicates:validate-duplicate-rows($rows, $keyColumns, $qclevels:BLOCKER)
};

declare function vldduplicates:validate-duplicate-rows($rows as element(dataRow)*, $keyColumns as element(column)*, $errorLevel as xs:integer)
as element(result)
{
    let $keys := 
        for $row in $rows
        where not(vldduplicates:_has-empty-key-values($row, $keyColumns))
        return data:get-row-key($row, $keyColumns)
    let $flaggedColumns :=
        for $keyColumn in $keyColumns
        return vldres:create-flagged-column($keyColumn, $errorLevel)
    let $resultRows := vldduplicates:_validate($keyColumns, $keys, $flaggedColumns, $rows, 1, ())
    return vldres:create-result($resultRows)
};

declare function vldduplicates:_validate(
    $keyColumns as element(column)*,
    $keys as xs:string*,
    $flaggedColumns as element(flaggedColumn)*,
    $dataRows as element(dataRow)*,
    $dataRowIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    vldres:mark_trunkated(
    (for $row in $dataRows
    let $rowKey := data:get-row-key($row, $keyColumns)
    return
        if (vldduplicates:_has-empty-key-values($row, $keyColumns)) then
            ()
        else if (count(index-of($keys, $rowKey)) > 1) then
            vldres:create-result-row($row, $flaggedColumns)
        else
            ()), $vldres:MAX_RECORD_RESULTS)

    (:
    if ($dataRowIndex > count($dataRows)) then
        $resultRows
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $row := $dataRows[$dataRowIndex]
        let $rowResult := 
            if (vldduplicates:_has-empty-key-values($row, $keyColumns)) then
                ()
            else
                let $rowKey := data:get-row-key($row, $keyColumns)
                return 
                    if (count(index-of($keys, $rowKey)) > 1) then
                        vldres:create-result-row($row, $flaggedColumns)
                    else
                        ()
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldduplicates:_validate($keyColumns, $keys, $flaggedColumns, $dataRows, $dataRowIndex + 1, $newResultRows):)
};

declare function vldduplicates:_has-empty-key-values($row as element(dataRow), $keyColumns as element(column)*)
as xs:boolean
{
    let $emptyColumns := 
        for $keyColumn in $keyColumns
        where meta:is-mandatory-column($keyColumn) and data:is-empty-value(data:get-row-values($row, $keyColumn))
        return $keyColumn
    return not(empty($emptyColumns))
};
