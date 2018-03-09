xquery version "1.0" encoding "UTF-8";

module namespace uiuom = "http://converters.eionet.europa.eu/wise/common/ui/unitOfMeasure";

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../common/data.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../common/qclevels.xquery';
import module namespace rdfutil = 'http://converters.eionet.europa.eu/common/rdfutil' at '../../common/rdf-util.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../common/validators/validation-result.xquery';
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at "../../common/ui/util.xquery";
import module namespace uomutil = 'http://converters.eionet.europa.eu/wise/common/uomUtil' at '../uom-util.xquery';

declare function uiuom:build-unit-of-measure-qc-markup(
    $qc as element(qc),
    $columnResultUom as element(column), 
    $columnObservedPropertyDeterminandCode as element(column),
    $tableName as xs:string,
    $vocabularyUom as element(),
    $vocabularyObservedProperty as element(),
    $vocabularyCombinationTableDeterminandUom as element(),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    let $qcId := $qc/@id
    let $qcLevel := vldres:get-qc-level($validationResult)
    let $pass := $qcLevel = $qclevels:OK
    let $event := qclevels:to-qc-event($qc, $qcLevel)
    return
        <div id="{$qcId}" class="{ uiutil:create-section-class($qcLevel) }">
            { uiutil:create-section-heading($qc) }
            { uiutil:create-section-description($qc) }
            { uiutil:create-section-summary($event) }
            {
                if ($pass) then
                    ()
                else
                    <div class="qcDetails">
                        { uiutil:create-record-count($validationResult) }
                        { 
                            uiuom:_create-checkbox-table($qcId, $columnResultUom, $columnObservedPropertyDeterminandCode, $tableName, 
                                $vocabularyUom,$vocabularyObservedProperty,$vocabularyCombinationTableDeterminandUom,$validationResult) 
                        }
                        { uiutil:create-row-toggle-button($qcId) }
                        <div id="dataarea_{ $qcId }" style="display: none;">
                            { uiutil:create-data-table-by-column-values($qc, $columnResultUom, $columnsToDisplay, $validationResult) }
                        </div>
                    </div>
            }
        </div>
};

declare function uiuom:_create-checkbox-table(
    $qcId as xs:string, 
    $columnResultUom as element(column), 
    $columnObservedPropertyDeterminandCode as element(column),
    $tableName as xs:string,
    $vocabularyUom as element(),
    $vocabularyObservedProperty as element(),
    $vocabularyCombinationTableDeterminandUom as element(), 
    $validationResult as element(result))
as element(table)
{
    let $aggregateDeterminands := data:create-group-values-aggregate("determinands", $columnObservedPropertyDeterminandCode)
    let $aggregateCount := data:create-count-aggregate("count")
    let $groups := data:group-by($validationResult/rows/row/data/*, $columnResultUom, ($aggregateDeterminands, $aggregateCount))
    return
        <table id="{ concat('checkboxTable_', $qcId) }">
            <thead>
                <tr>
                    <th></th>
                    <th>{ meta:get-column-name($columnResultUom) }</th>
                    <th>Determinand codes (correct UoM)</th>
                    <th>Number of records</th>
                </tr>
            </thead>
            <tbody> {
                for $group at $trIndex in $groups
                let $checkboxId := concat("checkbox_", $qcId, "_", uiutil:compose-group-class-name-of-group($group, $columnResultUom))
                return
                    <tr>
                        <td>
                            <input id="{ $checkboxId }" type="checkbox" onclick="onColumnCheckboxCheck(this)"></input>
                        </td>
                        <td>{ data($group/columns/column[@name = meta:get-column-name($columnResultUom)]/value) }</td>
                        <td> {
                            let $determinands := data($group/totals/total[@name = string($aggregateDeterminands/@alias)]/value)
                            let $determinandCount := count($determinands)
                            for $determinand at $pos in $determinands
                            let $determinandView := uiuom:_compose-determinand-item($tableName, $vocabularyUom, $vocabularyObservedProperty, 
                                                        $vocabularyCombinationTableDeterminandUom, $determinand)
                            return
                                if ($pos = $determinandCount) then
                                    $determinandView
                                else
                                    ($determinandView, <span>, </span>)
                        }
                        </td>
                        <td>{ data($group/totals/total[@name = string($aggregateCount/@alias)]/value) }</td>
                    </tr>
            }
            { uiutil:try-generate-truncated-result-row($validationResult, 4) }
            </tbody>
        </table>
};

declare function uiuom:_compose-determinand-item(
    $tableName as xs:string,
    $vocabularyUom as element(),
    $vocabularyObservedProperty as element(),
    $vocabularyCombinationTableDeterminandUom as element(),
    $determinand as xs:string
)
as element(span)
{
    let $determinandUri := rdfutil:get-concept-uri-by-notation($vocabularyObservedProperty, $determinand)
    let $correctUomUris :=
        for $combinationConcept in rdfutil:concepts($vocabularyCombinationTableDeterminandUom)
        where uomutil:has-table($combinationConcept, $tableName) and uomutil:has-determinant($combinationConcept, $determinandUri)
        return uomutil:get-uom-uri($combinationConcept)
    let $correctUom := if (empty($correctUomUris)) then "" else rdfutil:get-notation-by-concept-uri($vocabularyUom, $correctUomUris[1])
    return
        <span>
            <a target="_blank" href="{ $determinandUri }">{ $determinand }</a> ({ $correctUom })
        </span>
};
