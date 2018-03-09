xquery version "1.0" encoding "UTF-8";

module namespace uitrefperiod = 'http://converters.eionet.europa.eu/wise/common/ui/timeReferencePeriod';

import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at '../../common/ui/util.xquery';

declare function uitrefperiod:build-time-reference-period-qc-markup(
    $qc as element(qc),
    $columnPhenomenonTimePeriod as element(column),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    uiutil:build-generic-qc-markup-by-column-values($qc, $columnPhenomenonTimePeriod, $columnsToDisplay, $validationResult)
};
