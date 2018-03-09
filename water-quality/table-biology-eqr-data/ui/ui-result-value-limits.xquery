xquery version "1.0" encoding "UTF-8";

module namespace uiwqlbioeqrdres = 'http://converters.eionet.europa.eu/wise/waterQuality/biologyEqrData/ui/resultValueLimits';

import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at '../../../common/ui/util.xquery';

declare function uiwqlbioeqrdres:build-result-value-limits-qc-markup(
    $qc as element(qc),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    uiutil:build-generic-qc-markup-without-checkbox-table($qc, $columnsToDisplay, $validationResult)
};
