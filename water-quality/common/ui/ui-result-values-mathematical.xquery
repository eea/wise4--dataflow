xquery version "1.0" encoding "UTF-8";

module namespace uiwqlrvmath = 'http://converters.eionet.europa.eu/wise/waterQuality/common/ui/resultValuesMathRules';

import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at '../../../common/ui/util.xquery';

declare function uiwqlrvmath:build-result-values-math-rules-qc-markup(
    $qc as element(qc),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    uiutil:build-generic-qc-markup-by-tag-values($qc, "Error type", $columnsToDisplay, $validationResult)
};
