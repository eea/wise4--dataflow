xquery version "1.0" encoding "UTF-8";

module namespace vldwqlagwbstclass = "http://converters.eionet.europa.eu/wise/waterQuality/aggregatedDataByWaterBody/validators/siteClass";

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../../common/data.xquery';
import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';

declare function vldwqlagwbstclass:validate-site-class($model as element(model), $dataRows as element(dataRow)*)
as element(result)
{
    let $columnObservedPropertyDeterminandCode := meta:get-column-by-name($model, "observedPropertyDeterminandCode")
    let $columnResultNumberOfSitesClass4 := meta:get-column-by-name($model, "resultNumberOfSitesClass4")
    let $columnResultNumberOfSitesClass5 := meta:get-column-by-name($model, "resultNumberOfSitesClass5")
    let $resultRows := vldwqlagwbstclass:_validate(
        $columnObservedPropertyDeterminandCode, $columnResultNumberOfSitesClass4,
        $columnResultNumberOfSitesClass5, $dataRows, 1, ()
    )
    let $tagCounts := vldres:calculate-tag-value-counts($resultRows)
    return vldres:create-result($resultRows, $tagCounts)
};

declare function vldwqlagwbstclass:_validate(
    $columnObservedPropertyDeterminandCode as element(column),
    $columnResultNumberOfSitesClass4 as element(column),
    $columnResultNumberOfSitesClass5 as element(column),
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
        let $rowResult := vldwqlagwbstclass:_validate-data-row(
            $columnObservedPropertyDeterminandCode, $columnResultNumberOfSitesClass4, $columnResultNumberOfSitesClass5, $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwqlagwbstclass:_validate(
            $columnObservedPropertyDeterminandCode, $columnResultNumberOfSitesClass4, 
            $columnResultNumberOfSitesClass5, $dataRows, $dataRowIndex + 1, $newResultRows
        )
};

declare function vldwqlagwbstclass:_validate-data-row(
    $columnObservedPropertyDeterminandCode as element(column),
    $columnResultNumberOfSitesClass4 as element(column),
    $columnResultNumberOfSitesClass5 as element(column),
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $observedPropertyDeterminandCodes := data:get-row-values($dataRow, $columnObservedPropertyDeterminandCode)
    return
        if (data:is-empty-value($observedPropertyDeterminandCodes)) then
            ()
        else
            let $flaggedColumns :=
                for $observedPropertyDeterminandCode in $observedPropertyDeterminandCodes
                return
                    (
                        vldwqlagwbstclass:_validate-class4($observedPropertyDeterminandCode, $columnResultNumberOfSitesClass4, $dataRow),
                        vldwqlagwbstclass:_validate-class5($observedPropertyDeterminandCode, $columnResultNumberOfSitesClass5, $dataRow)
                    )
            return
                if (empty($flaggedColumns)) then
                    ()
                else
                    vldres:create-result-row($dataRow, $flaggedColumns)
};

declare function vldwqlagwbstclass:_validate-class4(
    $observedPropertyDeterminandCode as xs:string,
    $columnResultNumberOfSitesClass4 as element(column),
    $dataRow as element(dataRow)
)
as element(flaggedColumn)?
{
    let $observedPropertyDeterminandCodeUpperCase := upper-case($observedPropertyDeterminandCode)
    let $flaggedValues := 
        if ($observedPropertyDeterminandCodeUpperCase != "EEA_3132-01-2") then
            ()
        else
            let $resultNumberOfSitesClass4 := datax:get-row-integer-value($dataRow, $columnResultNumberOfSitesClass4)
            return
                if (empty($resultNumberOfSitesClass4) or $resultNumberOfSitesClass4 = 0) then
                    ()
                else
                    let $stringValue := data:get-row-values($dataRow, $columnResultNumberOfSitesClass4)[1]
                    return vldres:create-flagged-value($qclevels:BLOCKER, $stringValue, "1")
    return
        if (empty($flaggedValues)) then
            ()
        else
            vldres:create-flagged-column-by-values($columnResultNumberOfSitesClass4, $flaggedValues)
};

declare function vldwqlagwbstclass:_validate-class5(
    $observedPropertyDeterminandCode as xs:string,
    $columnResultNumberOfSitesClass5 as element(column),
    $dataRow as element(dataRow)
)
as element(flaggedColumn)?
{
    let $observedPropertyDeterminandCodeUpperCase := upper-case($observedPropertyDeterminandCode)
    let $flaggedValues := 
        if (not($observedPropertyDeterminandCodeUpperCase = ("EEA_3132-01-2", "CAS_14798-03-9", "CAS_14797-55-8"))) then
            ()
        else
            let $resultNumberOfSitesClass5 := datax:get-row-integer-value($dataRow, $columnResultNumberOfSitesClass5)
            return
                if (empty($resultNumberOfSitesClass5) or $resultNumberOfSitesClass5 = 0) then
                    ()
                else
                    let $stringValue := data:get-row-values($dataRow, $columnResultNumberOfSitesClass5)[1]
                    return vldres:create-flagged-value($qclevels:BLOCKER, $stringValue, "2")
    return
        if (empty($flaggedValues)) then
            ()
        else
            vldres:create-flagged-column-by-values($columnResultNumberOfSitesClass5, $flaggedValues)
};
