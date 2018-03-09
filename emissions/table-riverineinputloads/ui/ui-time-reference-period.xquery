xquery version "1.0" encoding "UTF-8";

module namespace uiemisemistrefprd = "http://converters.eionet.europa.eu/wise/emissions/emissions/ui/timeReferencePeriod";

import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at '../../../common/ui/util.xquery';

declare function uiemisemistrefprd:build-time-reference-period-qc-markup(
    $qc as element(qc),
    $model as element(model),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    let $qcColumn := meta:get-column-by-name($model, 'phenomenonTimeReferencePeriod')
    return uiutil:build-generic-qc-markup-by-column-values($qc, $qcColumn, $columnsToDisplay, $validationResult)
};

