xquery version "1.0" encoding "UTF-8";

module namespace uispunitidsch = 'http://converters.eionet.europa.eu/wise/common/ui/spatialUnitIdentifierScheme';

import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at '../../common/ui/util.xquery';

declare function uispunitidsch:build-spatial-unit-identifier-scheme-qc-markup(
    $qc as element(qc),
    $columnSpatialUnitIdentifierScheme as element(column),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    uiutil:build-generic-qc-markup-by-column-values($qc, $columnSpatialUnitIdentifierScheme, $columnsToDisplay, $validationResult)
};
