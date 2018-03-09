xquery version "1.0" encoding "UTF-8";

module namespace vldmsiteid = 'http://converters.eionet.europa.eu/wise/common/validators/monitoringSiteIdentifier';

import module namespace vldinterid = 'http://converters.eionet.europa.eu/wise/common/validators/internationalIdentifier' at './vld-international-identifier.xquery';

declare function vldmsiteid:validate-monitoring-site-identifier-format(
    $column as element(column), 
    $envelope as element(envelope), 
    $dataRows as element(dataRow)*
)
as element(result)
{
    vldinterid:validate-international-identifier-format($column, $envelope, $dataRows)
};

declare function vldmsiteid:validate-monitoring-site-identifier-reference(
    $columnMonitoringSiteIdentifier as element(column),
    $columnMonitoringSiteIdentifierScheme as element(column),
    $vocabularyMonitoringSites as element(),
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $schemeUrlPrefix := "http://dd.eionet.europa.eu/vocabulary/wise/MonitoringSite/"
    return vldinterid:validate-international-identifier-reference(
        $columnMonitoringSiteIdentifier,
        $columnMonitoringSiteIdentifierScheme,
        $vocabularyMonitoringSites,
        $schemeUrlPrefix,
        $dataRows
    )
};
