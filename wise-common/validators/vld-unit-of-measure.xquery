xquery version "1.0" encoding "UTF-8";

module namespace vlduom = "http://converters.eionet.europa.eu/wise/common/validators/unitOfMeasure";

declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace owl = "http://www.w3.org/2002/07/owl#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../common/data.xquery";
import module namespace datax = "http://converters.eionet.europa.eu/common/dataExtensions" at "../../common/data-extensions.xquery";
import module namespace qclevels = "http://converters.eionet.europa.eu/common/qclevels" at "../../common/qclevels.xquery";
import module namespace rdfutil = "http://converters.eionet.europa.eu/common/rdfutil" at "../../common/rdf-util.xquery";
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../common/validators/validation-result.xquery';
import module namespace uomutil = 'http://converters.eionet.europa.eu/wise/common/uomUtil' at '../uom-util.xquery';

declare function vlduom:validate-unit-of-measure(
    $columnResultUom as element(column), 
    $columnObservedPropertyDeterminandCode as element(column),
    $tableName as xs:string,
    $vocabularyUom as element(),
    $vocabularyObservedProperty as element(),
    $vocabularyCombinationTableDeterminandUom as element(),
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $resultRows := vlduom:_validate(
        $columnResultUom, $columnObservedPropertyDeterminandCode, $tableName,
        $vocabularyUom, $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom,
        $dataRows, 1, ()
    )
    let $columnCounts := vldres:calculate-column-value-counts($resultRows, $columnResultUom)
    return vldres:create-result($resultRows, $columnCounts)
};

declare function vlduom:_validate(
    $columnResultUom as element(column), 
    $columnObservedPropertyDeterminandCode as element(column),
    $tableName as xs:string,
    $vocabularyUom as element(),
    $vocabularyObservedProperty as element(),
    $vocabularyCombinationTableDeterminandUom as element(),
    $dataRows as element(dataRow)*,
    $dataRowIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    let $concepts := rdfutil:conceptsUom($vocabularyCombinationTableDeterminandUom)
    return (for $row in $dataRows
    return vlduom:_validate-row(
            $columnResultUom, $columnObservedPropertyDeterminandCode, $tableName, $vocabularyUom,
            $vocabularyObservedProperty, $concepts, $row
    ))[position() = 1 to  $vldres:MAX_RECORD_RESULTS]
    (:if ($dataRowIndex > count($dataRows)) then
        $resultRows
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $rowResult := vlduom:_validate-row(
            $columnResultUom, $columnObservedPropertyDeterminandCode, $tableName, $vocabularyUom,
            $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vlduom:_validate(
            $columnResultUom, $columnObservedPropertyDeterminandCode, $tableName, $vocabularyUom,
            $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $dataRows,
            $dataRowIndex + 1, $newResultRows
        ):)
};

declare function vlduom:_validate-row(
    $columnResultUom as element(column), 
    $columnObservedPropertyDeterminandCode as element(column),
    $tableName as xs:string,
    $vocabularyUom as element(),
    $vocabularyObservedProperty as element(),
    $concepts as xs:string*,
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $resultUom := datax:get-row-value($dataRow, $columnResultUom)
    let $observedPropertyDeterminandCode := datax:get-row-value($dataRow, $columnObservedPropertyDeterminandCode)
    return
    if (empty($resultUom) or empty($observedPropertyDeterminandCode)) then
        ()
    else 
        if (vlduom:_is-valid-row($resultUom, $observedPropertyDeterminandCode, $tableName, $vocabularyUom, $vocabularyObservedProperty, $concepts)) then
            ()
        else 
            vlduom:_create-result-row($dataRow, $columnResultUom, $resultUom)
};

declare function vlduom:_is-valid-row(
    $resultUom as xs:string, 
    $observedPropertyDeterminandCode as xs:string,
    $tableName as xs:string,
    $vocabularyUom as element(),
    $vocabularyObservedProperty as element(),
    $concepts as xs:string*
)
as xs:boolean
{
    (:let $uomConceptUri := rdfutil:get-concept-uri-by-notation($vocabularyUom, $resultUom):)
    let $uom := tokenize($vocabularyUom/skos:Concept[skos:notation = $resultUom]/@rdf:about, "/")[last()]
    let $determinandConceptUri := rdfutil:get-concept-uri-by-notation($vocabularyObservedProperty, $observedPropertyDeterminandCode)
    let $x := string-join(($determinandConceptUri, $uom, $tableName), "#")
    return
        if (not($x = $concepts)) then
            true()
        else
            false()
        (:if (empty($uomConceptUri) or empty($determinandConceptUri)) then
            true()
        else
            let $matchingCombinations :=
                for $concept in rdfutil:concepts($vocabularyCombinationTableDeterminandUom)
                where uomutil:has-determinant($concept, $determinandConceptUri)
                        and uomutil:has-uom($concept, $uomConceptUri) and uomutil:has-table($concept, $tableName)
                return $concept
            return not(empty($matchingCombinations)):)
};

declare function vlduom:_create-result-row(
    $dataRow as element(dataRow), 
    $columnResultUom as element(column),
    $resultUom as xs:string
)
as element(row)
{
    let $flaggedValue := vldres:create-flagged-value($qclevels:BLOCKER, $resultUom)
    let $flaggedColumn := vldres:create-flagged-column-by-values($columnResultUom, $flaggedValue)
    return vldres:create-result-row($dataRow, $flaggedColumn)
};
