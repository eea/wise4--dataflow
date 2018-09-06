xquery version "1.0" encoding "UTF-8";

module namespace vldinterid = 'http://converters.eionet.europa.eu/wise/common/validators/internationalIdentifier';

import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../common/data.xquery";
import module namespace qclevels = "http://converters.eionet.europa.eu/common/qclevels" at "../../common/qclevels.xquery";
import module namespace rdfutil = "http://converters.eionet.europa.eu/common/rdfutil" at "../../common/rdf-util.xquery";
import module namespace util = "http://converters.eionet.europa.eu/common/util" at "../../common/util.xquery";
import module namespace valconv = "http://converters.eionet.europa.eu/common/valueConversion" at "../../common/value-conversion.xquery";
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../common/validators/validation-result.xquery';

declare function vldinterid:validate-international-identifier-format(
    $column as element(column), 
    $envelope as element(envelope), 
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $envelopeCountryCode := lower-case(valconv:convertCountryCode(string($envelope/countrycode)))
    let $resultRows := vldinterid:_validate-international-identifier-format($column, $envelopeCountryCode, $dataRows, 1, ())
    let $columnCounts := vldres:calculate-column-counts($resultRows, $column)
    return
        vldres:create-result($resultRows, $columnCounts)
};

declare function vldinterid:_validate-international-identifier-format(
    $column as element(column),
    $envelopeCountryCode as xs:string,
    $dataRows as element(dataRow)*,
    $dataRowIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    vldres:mark_trunkated(
    (for $row in $dataRows
    return vldinterid:_validate-international-identifier-format-row($column, $envelopeCountryCode, $row)
    ), $vldres:MAX_RECORD_RESULTS)
    (:if ($dataRowIndex > count($dataRows)) then
        $resultRows
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $rowResult := vldinterid:_validate-international-identifier-format-row($column, $envelopeCountryCode, $dataRow)
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldinterid:_validate-international-identifier-format($column, $envelopeCountryCode, $dataRows, $dataRowIndex + 1, $newResultRows):)
};

declare function vldinterid:_validate-international-identifier-format-row(
    $column as element(column),
    $envelopeCountryCode as xs:string,
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $siteIds := data:get-row-values($dataRow, $column)
    let $flaggedValues :=
        for $siteId in $siteIds
        where $siteId != "" and not(vldinterid:is-valid-format-identifier($siteId, $envelopeCountryCode))
        return
            vldres:create-flagged-value($qclevels:BLOCKER, $siteId)
    return
        if (empty($flaggedValues)) then
            ()
        else
            vldres:create-result-row($dataRow, vldres:create-flagged-column-by-values($column, $flaggedValues))
};

declare function vldinterid:is-valid-format-identifier($id as xs:string, $countryCodeLowerCase as xs:string)
as xs:boolean
{
    vldinterid:is-country-code-match($id, $countryCodeLowerCase) and vldinterid:_is-well-formated($id)
};

declare function vldinterid:is-country-code-match($id as xs:string, $countryCodeLowerCase as xs:string)
as xs:boolean
{
    let $idCountryCode := lower-case(substring($id, 1, 2))
    return $idCountryCode = $countryCodeLowerCase
};

declare function vldinterid:_is-well-formated($siteId as xs:string)
as xs:boolean
{
    matches($siteId, "^[A-Z]{2}[0-9A-Z]{1}([0-9A-Z_\-]{0,38}[0-9A-Z]{1}){0,1}$") and matches($siteId, "^([A-Z0-9](\-|_)?)+$")
};

declare function vldinterid:validate-international-identifier-reference(
    $identifierColumn as element(column),
    $identifierSchemeColumn as element(column),
    $referencesVocabulary as element(),
    $schemeUrlPrefix as xs:string,
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $references := util:lower-case(rdfutil:concepts($referencesVocabulary)/rdfutil:about(.))
    let $rowResults := vldinterid:_validate-international-identifier-reference(
        $identifierColumn, $identifierSchemeColumn, $references, $schemeUrlPrefix, $dataRows, 1, ()
    )
    let $columnCounts := vldres:calculate-column-counts($rowResults, $identifierColumn)
    return vldres:create-result($rowResults, $columnCounts)
};

declare function vldinterid:_validate-international-identifier-reference(
    $identifierColumn as element(column),
    $identifierSchemeColumn as element(column),
    $references as xs:string*,
    $schemeUrlPrefix as xs:string,
    $dataRows as element(dataRow)*,
    $dataRowIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    vldres:mark_trunkated(
    (for $row in $dataRows
    return vldinterid:_validate-international-identifier-reference-row(
                $identifierColumn, $identifierSchemeColumn, $references, $schemeUrlPrefix, $row)
    ), $vldres:MAX_RECORD_RESULTS)
    (:if ($dataRowIndex > count($dataRows)) then
        $resultRows
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $rowResult := vldinterid:_validate-international-identifier-reference-row(
            $identifierColumn, $identifierSchemeColumn, $references, $schemeUrlPrefix, $dataRow
        ) 
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldinterid:_validate-international-identifier-reference(
            $identifierColumn, $identifierSchemeColumn, $references, $schemeUrlPrefix, $dataRows, $dataRowIndex + 1, $newResultRows
        ):)
};

declare function vldinterid:_validate-international-identifier-reference-row(
    $identifierColumn as element(column),
    $identifierSchemeColumn as element(column),
    $references as xs:string*,
    $schemeUrlPrefix as xs:string,
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $id := data:get-row-values-as-string($dataRow, $identifierColumn)
    let $idScheme := data:get-row-values-as-string($dataRow, $identifierSchemeColumn)
    let $conceptUrl := lower-case(concat($schemeUrlPrefix, $idScheme, ".", $id))
    return
        if ($id != "" and $idScheme != "" and not($conceptUrl = $references)) then
            vldres:create-result-row($dataRow, vldres:create-flagged-column($identifierColumn, $qclevels:BLOCKER))
        else
            ()
};

