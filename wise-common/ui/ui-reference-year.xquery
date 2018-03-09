xquery version "1.0" encoding "UTF-8";

module namespace uirefyear = 'http://converters.eionet.europa.eu/wise/common/ui/referenceYear';

import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at '../../common/ui/util.xquery';

declare function uirefyear:build-reference-year-qc-markup(
    $qc as element(qc),
    $columnReferenceYear as element(column),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    uiutil:build-generic-qc-markup-by-column-values($qc, $columnReferenceYear, $columnsToDisplay, $validationResult)
};
