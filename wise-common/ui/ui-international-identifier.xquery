xquery version "1.0" encoding "UTF-8";

module namespace uiinterid = 'http://converters.eionet.europa.eu/wise/common/ui/internationalIdentifier';

import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at '../../common/ui/util.xquery';
import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../common/data.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../common/validators/validation-result.xquery';

declare function uiinterid:build-international-id-format-qc-markup(
    $qc as element(qc),
    $idColumn as element(column),
    $idSchemeColumn as element(column),
    $validationResult as element(result)
)
as element(div)
{
    uiinterid:_build-international-id-qc-markup($qc, $idColumn, $idSchemeColumn, $validationResult)
};

declare function uiinterid:build-international-id-reference-qc-markup(
    $qc as element(qc),
    $idColumn as element(column),
    $idSchemeColumn as element(column),
    $validationResult as element(result)
)
as element(div)
{
    uiinterid:_build-international-id-qc-markup($qc, $idColumn, $idSchemeColumn, $validationResult)
};

declare function uiinterid:_build-international-id-qc-markup(
    $qc as element(qc),
    $idColumn as element(column),
    $idSchemeColumn as element(column),
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
                    let $dataRows := $validationResult/rows/row/data/*
                    let $groupByColumns := ($idColumn, $idSchemeColumn)
                    let $countAlias := "groupByRecordCount"
                    let $aggregates := ( data:create-count-aggregate($countAlias) )
                    let $groupRows := data:group-by($dataRows, $groupByColumns, $aggregates)
                    let $errorValueClass := qclevels:to-qc-color-class($qcLevel)
                    return
                        <div class="qcDetails">
                            <p>{ count($groupRows) } identifiers detected.</p>
                            { uiutil:create-row-toggle-button($qcId) }
                            <div id="dataarea_{ $qcId }" style="display: none;">
                                <table id="datatable_{ $qcId }" class="dataTable">
                                    <thead>
                                        <tr> {
                                            for $groupByColumn in $groupByColumns
                                            return
                                                <th>{ meta:get-column-name($groupByColumn) }</th>
                                        }
                                            <th>number of records</th>
                                        </tr>
                                    </thead>
                                    <tbody> {
                                        for $groupRow at $trIndex in $groupRows
                                        return
                                            <tr> {
                                                for $groupByColumn in $groupByColumns
                                                let $groupByColumnName := meta:get-column-name($groupByColumn)
                                                let $groupColumn := $groupRow/columns/column[@name = $groupByColumnName]
                                                return
                                                    <td class="{ $errorValueClass }">{ string($groupColumn/value) }</td>
                                            } {
                                                let $total := $groupRow/totals/total[@name = $countAlias]
                                                return
                                                    <td>{ string($total/value) }</td>
                                            }
                                            </tr>
                                    }
                                    { uiutil:try-generate-truncated-result-row($validationResult, count($groupByColumns) + 1) }
                                    </tbody>
                                </table>
                            </div>
                        </div>
            }
        </div>
};
