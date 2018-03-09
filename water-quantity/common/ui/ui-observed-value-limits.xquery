xquery version "1.0" encoding "UTF-8";

module namespace uiwqnobsvallim = "http://converters.eionet.europa.eu/wise/waterQuantity/common/ui/observedValueLimits";

import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace rdfutil = 'http://converters.eionet.europa.eu/common/rdfutil' at '../../../common/rdf-util.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at "../../../common/ui/util.xquery";

declare function uiwqnobsvallim:build-observed-value-limits-qc-markup(
    $qc as element(qc),
    $columnObservedProperty as element(column),
    $limitsList as element(limits)*,
    $infoColumnUrl as xs:string,
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
                        { uiutil:create-row-toggle-button($qcId) }
                        <div id="dataarea_{ $qcId }" style="display: none;">
                            { uiutil:create-data-table($qc, $columnsToDisplay, $validationResult) }
                            { uiwqnobsvallim:_create-additional-limits-table($columnObservedProperty, $limitsList, $infoColumnUrl, $validationResult) }
                        </div>
                    </div>
            }
        </div>
};

declare function uiwqnobsvallim:_create-additional-limits-table(
    $columnObservedProperty as element(column),
    $limitsList as element(limits)*, 
    $infoColumnUrl as xs:string,
    $validationResult as element(result)
)
as element(table)
{
    let $flaggedDeterminands := distinct-values(
        for $dataRow in $validationResult/rows/row/data/*
        return lower-case(datax:get-row-value($dataRow, $columnObservedProperty))
    )
    return
        <table class="additional">
            <thead>
                <tr>
                    <th colspan="5">Parameter value limits</th>
                </tr>
                <tr>
                    <th>Determinand code</th>
                    <th>Minimum inclusive (&gt;=)</th>
                    <th>Minimum exclusive (&gt;)</th>
                    <th>Maximum inclusive (&lt;=)</th>
                    <th>Maximum exclusive (&lt;)</th>
                </tr>
            </thead>
            <tbody> {
                for $limits in $limitsList
                let $determinand := string($limits/@determinand)
                where lower-case($determinand) = $flaggedDeterminands
                return
                    <tr>
                        <td>
                            <a target="_blank" href="{ $infoColumnUrl }">{ 
                                $determinand 
                            }
                            </a>
                        </td>
                        <td>{ string($limits/minInclusive) }</td>
                        <td>{ string($limits/minExclusive) }</td>
                        <td>{ string($limits/maxInclusive) }</td>
                        <td>{ string($limits/maxExclusive) }</td>
                    </tr>
            }
            </tbody>
        </table>
};
