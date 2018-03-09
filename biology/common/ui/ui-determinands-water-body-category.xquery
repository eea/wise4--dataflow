xquery version "1.0" encoding "UTF-8";

module namespace uiwqldetwbcat = "http://converters.eionet.europa.eu/wise/biology/common/ui/determinandsAndWaterBodyCategory";

import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at "../../../common/ui/util.xquery";

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../../common/data.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace rdfutil = 'http://converters.eionet.europa.eu/common/rdfutil' at '../../../common/rdf-util.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';

declare function uiwqldetwbcat:build-determinands-and-water-body-category-qc-markup(
    $qc as element(qc),
    $model as element(model),
    $vocabularyObservedPropertyBiologyEQR as element(),
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
                    let $columnWaterBodyCategory := meta:get-column-by-name($model, "parameterWaterBodyCategory")
                    return
                        <div class="qcDetails">
                            { uiutil:create-record-count($validationResult) }
                            { uiwqldetwbcat:_create-checkbox-table($qcId, $model, $vocabularyObservedPropertyBiologyEQR, $validationResult) }
                            { uiutil:create-row-toggle-button($qcId) }
                            <div id="dataarea_{ $qcId }" style="display: none;">
                                { uiutil:create-data-table-by-column-values($qc, $columnWaterBodyCategory, $columnsToDisplay, $validationResult) }
                            </div>
                        </div>
            }
        </div>
};

declare function uiwqldetwbcat:_create-checkbox-table(
    $qcId as xs:string, 
    $model as element(model),
    $vocabularyObservedPropertyBiologyEQR as element(), 
    $validationResult as element(result))
as element(table)
{
    let $columnWaterBodyCategory := meta:get-column-by-name($model, "parameterWaterBodyCategory")
    let $columnDeterminand := meta:get-column-by-name($model, "observedPropertyDeterminandBiologyEQRCode")
    let $aggregateDeterminands := data:create-group-values-aggregate("determinands", $columnDeterminand)
    let $aggregateCount := data:create-count-aggregate("count")
    let $groups := data:group-by($validationResult/rows/row/data/*, $columnWaterBodyCategory, ($aggregateDeterminands, $aggregateCount))
    return
        <table id="{ concat('checkboxTable_', $qcId) }">
            <thead>
                <tr>
                    <th></th>
                    <th>Water body categories</th>
                    <th>Irrelevant determinands</th>
                </tr>
            </thead>
            <tbody> {
                for $group in $groups
                let $checkboxId := concat("checkbox_", $qcId, "_", uiutil:compose-group-class-name-of-group($group, $columnWaterBodyCategory))
                return
                    <tr>
                        <td>
                            <input id="{ $checkboxId }" type="checkbox" onclick="onColumnCheckboxCheck(this)"></input>
                        </td>
                        <td>{ data($group/columns/column[@name = meta:get-column-name($columnWaterBodyCategory)]/value) }</td>
                        <td> {
                            let $determinands := data($group/totals/total[@name = string($aggregateDeterminands/@alias)]/value)
                            let $determinandCount := count($determinands)
                            for $determinand at $pos in $determinands
                            let $determinantConcept := rdfutil:get-concept-by-notation($vocabularyObservedPropertyBiologyEQR, $determinand)
                            let $determinandView :=
                                if (empty($determinantConcept)) then
                                    <span>{ $determinand }</span>
                                else
                                    <a target="_blank" href="{ rdfutil:about($determinantConcept) }">{ $determinand }</a>
                            return
                                if ($pos = $determinandCount) then
                                    $determinandView
                                else
                                    ($determinandView, <span>, </span>)
                        }
                        </td>
                    </tr>
            }
            </tbody>
        </table>
};

