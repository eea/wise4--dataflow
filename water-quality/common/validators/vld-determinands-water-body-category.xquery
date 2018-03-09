xquery version "1.0" encoding "UTF-8";

module namespace vldwqldetwbcat = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/determinandsAndWaterBodyCategory";

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../../common/data.xquery';
import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace util = 'http://converters.eionet.europa.eu/common/util' at '../../../common/util.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';

declare variable $vldwqldetwbcat:lw-determinands := util:lower-case(("EEA_123-01-3", "EEA_123-02-4", "EEA_123-03-5", "EEA_123-04-6", "EEA_11-01-8", "EEA_11-02-9", "EEA_11-03-0", "EEA_11-04-1"));
declare variable $vldwqldetwbcat:rw-determinands := util:lower-case(("EEA_124-01-6", "EEA_124-02-7", "EEA_124-03-8", "EEA_124-04-9", "EEA_13-01-4", "EEA_13-02-5", "EEA_13-03-6", "EEA_13-04-7"));

declare function vldwqldetwbcat:validate-determinands-and-water-body-category($model as element(model), $dataRows as element(dataRow)*)
as element(result)
{
    let $columnDeterminand := meta:get-column-by-name($model, "observedPropertyDeterminandBiologyEQRCode")
    let $columnWaterBodyCategory :=  meta:get-column-by-name($model, "parameterWaterBodyCategory")
    let $resultRows := vldwqldetwbcat:_validate($columnDeterminand, $columnWaterBodyCategory, $dataRows, 1, ())
    return vldres:create-result($resultRows)
};

declare function vldwqldetwbcat:_validate(
    $columnDeterminand as element(column),
    $columnWaterBodyCategory as element(column),
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
        let $rowResult := vldwqldetwbcat:_validate-row($columnDeterminand, $columnWaterBodyCategory, $dataRow)
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwqldetwbcat:_validate($columnDeterminand, $columnWaterBodyCategory, $dataRows, $dataRowIndex + 1, $newResultRows)
};

declare function vldwqldetwbcat:_validate-row(
    $columnDeterminand as element(column),
    $columnWaterBodyCategory as element(column),
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $determinand := datax:get-row-value($dataRow, $columnDeterminand)
    let $waterBodyCategory := datax:get-row-value($dataRow, $columnWaterBodyCategory)
    let $determinandLowerCase := lower-case($determinand)
    let $waterBodyCategoryLowerCase := lower-case($waterBodyCategory)
    let $determinandsToMatch :=
        if ($waterBodyCategoryLowerCase = "lw") then
            $vldwqldetwbcat:lw-determinands
        else if ($waterBodyCategoryLowerCase = "rw") then
            $vldwqldetwbcat:rw-determinands
        else
            ()
    return
        if (empty($determinandsToMatch) or empty($determinand) or $determinandLowerCase = $determinandsToMatch) then
            ()
        else
            let $flaggedColumns := (
                vldres:create-flagged-column-by-values($columnDeterminand, vldres:create-flagged-value($qclevels:ERROR, $determinand)),
                vldres:create-flagged-column-by-values($columnWaterBodyCategory, vldres:create-flagged-value($qclevels:ERROR, $waterBodyCategory))
            )
            return vldres:create-result-row($dataRow, $flaggedColumns)
};
