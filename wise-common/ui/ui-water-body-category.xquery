xquery version "1.0" encoding "UTF-8";

module namespace uiwtrbdcat = "http://converters.eionet.europa.eu/wise/common/ui/waterBodyCategory";

import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at '../../common/ui/util.xquery';

declare function uiwtrbdcat:build-water-body-category-qc-markup(
    $qc as element(qc),
    $columnWaterBodyCategory as element(column),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    uiutil:build-generic-qc-markup-by-column-values($qc, $columnWaterBodyCategory, $columnsToDisplay, $validationResult)
};
