xquery version "1.0" encoding "UTF-8";

module namespace uicountrycode = 'http://converters.eionet.europa.eu/wise/common/ui/countryCode';

import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at '../../common/ui/util.xquery';

declare function uicountrycode:build-country-code-qc-markup(
    $qc as element(qc),
    $columnCountryCode as element(column),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    uiutil:build-generic-qc-markup-by-column-values($qc, $columnCountryCode, $columnsToDisplay, $validationResult)
};
