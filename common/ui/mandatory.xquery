xquery version "1.0" encoding "UTF-8";

module namespace uimandatory = 'http://converters.eionet.europa.eu/common/ui/mandatory';

import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at 'util.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../validators/validation-result.xquery';

declare function uimandatory:build-mandatory-column-qc-markup(
    $qc as element(qc),
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
        <div id="{ $qcId }" class="{ uiutil:create-section-class($qcLevel) }">
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
                        </div>
                    </div>
            }
        </div>
};
