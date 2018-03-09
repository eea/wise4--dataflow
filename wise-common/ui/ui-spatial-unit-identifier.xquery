xquery version "1.0" encoding "UTF-8";

module namespace uispunitid = 'http://converters.eionet.europa.eu/wise/common/ui/spatialUnitIdentifier';

import module namespace uiinterid = 'http://converters.eionet.europa.eu/wise/common/ui/internationalIdentifier' at './ui-international-identifier.xquery';

declare function uispunitid:build-spatial-unit-id-format-qc-markup(
    $qc as element(qc),
    $monitoringSiteIdColumn as element(column),
    $monitoringSiteIdSchemeColumn as element(column),
    $validationResult as element(result)
)
as element(div)
{
    uiinterid:build-international-id-format-qc-markup($qc, $monitoringSiteIdColumn, $monitoringSiteIdSchemeColumn, $validationResult)
};

declare function uispunitid:build-spatial-unit-id-reference-qc-markup(
    $qc as element(qc),
    $monitoringSiteIdColumn as element(column),
    $monitoringSiteIdSchemeColumn as element(column),
    $validationResult as element(result)
)
as element(div)
{
    uiinterid:build-international-id-reference-qc-markup($qc, $monitoringSiteIdColumn, $monitoringSiteIdSchemeColumn, $validationResult)
};
