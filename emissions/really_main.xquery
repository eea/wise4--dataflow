xquery version "1.0" encoding "UTF-8";

declare namespace wise1 = 'http://converters.eionet.europa.eu/wise/emissions';

import module namespace emissions_directdischarges = 'http://converters.eionet.europa.eu/wise/emissions/directdischarges' at 'table-directdischarges/qcs.xquery';
import module namespace emissions = 'http://converters.eionet.europa.eu/wise/emissions/emissions' at 'table-emissions/qcs.xquery';
import module namespace emissions_riverineinputloads = 'http://converters.eionet.europa.eu/wise/emissions/riverineinputloads' at 'table-riverineinputloads/qcs.xquery';

import module namespace html = 'http://converters.eionet.europa.eu/common/ui/html' at "../common/ui/html-scripts.xquery";
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../common/qclevels.xquery';
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at '../common/ui/util.xquery';


declare variable $source_url as xs:string external;


declare function wise1:print-all($source_url as xs:string)
as element(div) {
    let $results := wise1:run-all($source_url)
    let $maxLevel := max($results//div[not(empty(@level))]/@level)
    let $maxLevel := xs:integer($maxLevel)
    let $titles :=
        <ul class="qcMenu"> {
            for $r in $results//div[not(empty(@tableCaption))]

            let $nid := $r/@nid/string()
            let $dsCaption := $r/@dsCaption/string()
            let $tableCaption := $r/@tableCaption/string()
            let $class := $r/@class/string()
            return
                <li>
                    <a href="#{$nid}">Table {$dsCaption} / {$tableCaption}</a> - <span class="errorLevel {$class}">{$class}</span>
                </li>
            }
        </ul>

    return
        <div>
            { html:getCss() }
            { html:getJavascript() }

            <div>
                <h2>The following tests were performed against the file</h2>
                <div id="feedbackStatus" class="{ qclevels:to-qc-code($maxLevel) }" style="display: none"> {
                    uiutil:build-feedback-status($maxLevel)
                }
                </div>
            </div>

            <div>
                {$titles}
            </div>
            <div>
                {$results}
            </div>
        </div>
};



declare function wise1:run-all($source_url as xs:string) as element(div) {
    <div>
        { emissions_directdischarges:run-checks($source_url) }
        { emissions:run-checks($source_url) }
        { emissions_riverineinputloads:run-checks($source_url) }
    </div>
};

wise1:print-all($source_url)

