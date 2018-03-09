xquery version "1.0" encoding "UTF-8";

module namespace uiwqldismpsdate = 'http://converters.eionet.europa.eu/wise/waterQuality/disaggregatedData/ui/samplingDate';

import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at '../../../common/ui/util.xquery';

declare function uiwqldismpsdate:build-sampling-date-qc-markup(
    $qc as element(qc),
    $model as element(model),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    let $columnSamplingDate := meta:get-column-by-name($model, "phenomenonTimeSamplingDate")
    return uiutil:build-generic-qc-markup-by-column-values($qc, $columnSamplingDate, $columnsToDisplay, $validationResult)
};
