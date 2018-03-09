xquery version "1.0" encoding "UTF-8";

module namespace vldemisemismethod = "http://converters.eionet.europa.eu/wise/emissions/emissions/validators/emissionsMethod";

import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../../common/data.xquery";
import module namespace datax = "http://converters.eionet.europa.eu/common/dataExtensions" at "../../../common/data-extensions.xquery";
import module namespace meta = "http://converters.eionet.europa.eu/common/meta" at "../../../common/meta.xquery";
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace util = "http://converters.eionet.europa.eu/common/util" at "../../../common/util.xquery";
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';

declare variable $vldemisemismethod:categories-qc-1 := util:lower-case( ("PT","U","U1","U11","U12","U13","U14","U2","U21","U22","U23","U24","I","I3","I4","O","O1","O2","O3","O4"));
declare variable $vldemisemismethod:methods-qc-1 := util:lower-case(("calculated","estimated","measured"));
declare variable $vldemisemismethod:categories-qc-2 := util:lower-case( ("NP","NP1","NP2","NP3","NP4","NP5","NP7","NP71","NP72","NP73","NP74","NP8"));
declare variable $vldemisemismethod:methods-qc-2 := util:lower-case(("estimated","modelled"));

declare function vldemisemismethod:validate-emissions-method(
    $model as element(model),
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $columnProcedureEmissionsMethod := meta:get-column-by-name($model, "procedureEmissionsMethod")
    let $columnParameterEmissionsSourceCategory := meta:get-column-by-name($model, "parameterEmissionsSourceCategory")
    let $resultRows := vldemisemismethod:_validate(
        $columnProcedureEmissionsMethod, $columnParameterEmissionsSourceCategory, $dataRows, 1, ()
    )
    return vldres:create-result($resultRows)
};

declare function vldemisemismethod:_validate(
    $columnProcedureEmissionsMethod as element(column),
    $columnParameterEmissionsSourceCategory as element(column),
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
        let $rowResult := vldemisemismethod:_validate-row(
            $columnProcedureEmissionsMethod, $columnParameterEmissionsSourceCategory, $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldemisemismethod:_validate(
            $columnProcedureEmissionsMethod, $columnParameterEmissionsSourceCategory, $dataRows, $dataRowIndex + 1, $newResultRows
        )
};

declare function vldemisemismethod:_validate-row(
    $columnProcedureEmissionsMethod as element(column),
    $columnParameterEmissionsSourceCategory as element(column),
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $method := datax:get-row-value($dataRow ,$columnProcedureEmissionsMethod)
    let $category := datax:get-row-value($dataRow , $columnParameterEmissionsSourceCategory)
    return
        if (empty($method) or empty($category)) then
            ()
        else
            if (vldemisemismethod:_is-valid($method, $category)) then
                ()
            else
                let $flaggedMethod := vldres:create-flagged-value($qclevels:BLOCKER, $method)
                let $flaggedCategory := vldres:create-flagged-value($qclevels:BLOCKER, $category)
                let $flaggedColumns := (
                    vldres:create-flagged-column-by-values($columnProcedureEmissionsMethod, $flaggedMethod),
                    vldres:create-flagged-column-by-values($columnParameterEmissionsSourceCategory, $flaggedCategory)
                )
                return vldres:create-result-row($dataRow, $flaggedColumns)
};

declare function vldemisemismethod:_is-valid($method as xs:string, $category as xs:string)
as xs:boolean
{
    let $methodLowerCase := lower-case($method)
    let $categoryLowerCase := lower-case($category)
    return
        if ($categoryLowerCase = $vldemisemismethod:categories-qc-1) then
            $methodLowerCase = $vldemisemismethod:methods-qc-1
        else if ($categoryLowerCase = $vldemisemismethod:categories-qc-2) then
            $methodLowerCase = $vldemisemismethod:methods-qc-2
        else
            true()
};
