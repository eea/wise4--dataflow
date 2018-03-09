xquery version "1.0" encoding "UTF-8";

module namespace vldwtrbdcat = "http://converters.eionet.europa.eu/wise/common/validators/waterBodyCategory";

import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../common/data.xquery";
import module namespace util = "http://converters.eionet.europa.eu/common/util" at "../../common/util.xquery";
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../common/validators/validation-result.xquery';
import module namespace vldclist = 'http://converters.eionet.europa.eu/common/validators/codelist' at '../../common/validators/codelist.xquery';

declare function vldwtrbdcat:validate-water-body-category(
    $columnWaterBodyCategory as element(column),
    $validCategories as xs:string*,
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $validCategoriesLowerCase := util:lower-case($validCategories)
    let $resultRows := vldwtrbdcat:_validate($columnWaterBodyCategory, $validCategoriesLowerCase, $dataRows, 1, ())
    let $flaggedColumnCounts := vldres:calculate-column-value-counts($resultRows, $columnWaterBodyCategory)
    return vldres:create-result($resultRows, $flaggedColumnCounts)
};

declare function vldwtrbdcat:_validate(
    $columnWaterBodyCategory as element(column),
    $validCategoriesLowerCase as xs:string*,
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
        let $rowResult := vldwtrbdcat:_validate-data-row($columnWaterBodyCategory, $validCategoriesLowerCase, $dataRow)
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwtrbdcat:_validate($columnWaterBodyCategory, $validCategoriesLowerCase, $dataRows, $dataRowIndex + 1, $newResultRows)
};

declare function vldwtrbdcat:_validate-data-row(
    $columnWaterBodyCategory as element(column),
    $validCategoriesLowerCase as xs:string*,
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $categories := data:get-row-values($dataRow, $columnWaterBodyCategory)
    let $flaggedValues :=
        for $category in $categories
        let $skip := $category = "" or not(empty(vldclist:validate-codelist($columnWaterBodyCategory, $dataRow)))
        return
            if ($skip or lower-case($category) = $validCategoriesLowerCase) then
                ()
            else
                vldres:create-flagged-value($qclevels:ERROR, $category)
    return 
        if (empty($flaggedValues)) then
            ()
        else
            let $flaggedColumn := vldres:create-flagged-column-by-values($columnWaterBodyCategory, $flaggedValues)
            return vldres:create-result-row($dataRow, $flaggedColumn)
};
