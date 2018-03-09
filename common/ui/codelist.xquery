xquery version "1.0" encoding "UTF-8";

module namespace uiclist = 'http://converters.eionet.europa.eu/common/ui/codelist';

import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at 'util.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../validators/validation-result.xquery';

declare function uiclist:build-codelists-markup(
    $qc as element(qc), 
    $model as element(model),
    $columnsToDisplay as element(column)*,
    $codelistUrls as element(codelistUrls),
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
                        { uiutil:create-checkbox-table($qcId, $validationResult, true()) }
                        { uiutil:create-row-toggle-button($qcId) }
                        <div id="dataarea_{ $qcId }" style="display: none;">
                            { uiutil:create-data-table($qc, $columnsToDisplay, $validationResult) }
                            <table id="additionalTable_{ $qcId }" class="additional">
                                <thead>
                                    <tr>
                                        <th colspan="4">Code lists</th>
                                    </tr>
                                    <tr>
                                        <th>Field name</th>
                                        <th>Code list type</th>
                                        <th>Code list URL</th>
                                        <th>Multi-value delimiter</th>
                                    </tr>
                                </thead>
                                <tbody> {
                                    let $errorColumnNames := $validationResult/counts/column/string(@name)
                                    let $codelistColumns := meta:get-valuelist-columns($model)
                                    for $codelistColumn in $codelistColumns
                                    let $columnName := meta:get-column-name($codelistColumn)
                                    return
                                        if (not($columnName = $errorColumnNames)) then
                                            ()
                                        else
                                            let $valuelist := $codelistColumn/valueList
                                            return
                                                <tr class="{ string-join(($qcId, $columnName), " ") }">
                                                    <td>{ $columnName }</td>
                                                    <td>{ string($valuelist/@type) }</td>
                                                    <td>
                                                        <a target="_blank" href="{ string($codelistUrls/url[@columnName = $columnName]/@value) }">
                                                            See on Data Dictionary
                                                        </a>
                                                    </td>
                                                    <td>{ meta:get-column-multi-value-delimiter($codelistColumn) }</td>
                                                </tr>
                                }
                                </tbody>
                            </table>
                        </div>
                    </div>
            }
        </div>
};
