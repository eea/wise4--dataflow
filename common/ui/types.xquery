xquery version "1.0" encoding "UTF-8";

module namespace uitypes = 'http://converters.eionet.europa.eu/common/ui/types';

import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at 'util.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../validators/validation-result.xquery';

declare function uitypes:build-data-types-qc-markup(
    $qc as element(qc), 
    $model as element(model),
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
                        { uiutil:create-checkbox-table($qcId, $validationResult) }
                        { uiutil:create-row-toggle-button($qcId) }
                        <div id="dataarea_{ $qcId }" style="display: none;">
                            { uiutil:create-data-table($qc, $columnsToDisplay, $validationResult) }
                            <table id="additionalTable_{ $qcId }" class="additional">
                                <thead>
                                    <tr>
                                        <th colspan="9">Field definitions</th>
                                    </tr>
                                    <tr>
                                        <th>Element name</th>
                                        <th>Data type</th>
                                        <th>Min size</th>
                                        <th>Max size</th>
                                        <th>Min value inclusive (&gt;=)</th>
                                        <th>Min value exclusive (&gt;)</th>
                                        <th>Max value inclusive (&lt;=)</th>
                                        <th>Max value exclusive (&lt;)</th>
                                        <th>Total digits</th>
                                    </tr>
                                </thead>
                                <tbody> {
                                    let $errorColumnNames := $validationResult/counts/column/string(@name)
                                    for $column in $model/columns/column
                                    let $columnName := meta:get-column-name($column) 
                                    where $columnName = $errorColumnNames
                                    return 
                                        <tr class="{ string-join(($qcId, $columnName), " ") }">
                                            <td>{ $columnName }</td>
                                            <td>{ string($column/@dataType) }</td>
                                            <td>{ string($column/restrictions/restriction[@name="minLength"]/@value) }</td>
                                            <td>{ string($column/restrictions/restriction[@name="maxLength"]/@value) }</td>
                                            <td>{ data($column/restrictions/restriction[@name="minInclusive"]/@value) }</td>
                                            <td>{ data($column/restrictions/restriction[@name="minExclusive"]/@value) }</td>
                                            <td>{ data($column/restrictions/restriction[@name="maxInclusive"]/@value) }</td>
                                            <td>{ data($column/restrictions/restriction[@name="maxExclusive"]/@value) }</td>
                                            <td>{ string($column/restrictions/restriction[@name="totalDigits"]/@value) }</td>
                                        </tr>
                                }
                                </tbody>
                            </table>
                        </div>
                    </div>
            }
        </div>
};
