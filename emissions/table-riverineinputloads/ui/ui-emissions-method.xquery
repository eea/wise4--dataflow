xquery version "1.0" encoding "UTF-8";

module namespace uiemisemismethod = "http://converters.eionet.europa.eu/wise/emissions/emissions/ui/emissionsMethod";

import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at '../../../common/ui/util.xquery';
import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../../common/data.xquery";
import module namespace meta = "http://converters.eionet.europa.eu/common/meta" at "../../../common/meta.xquery";
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';

declare function uiemisemismethod:build-emissions-method-qc-markup(
    $qc as element(qc),
    $model as element(model),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    let $columnProcedureEmissionsMethod := meta:get-column-by-name($model, "procedureEmissionsMethod")
    let $columnParameterEmissionsSourceCategory := meta:get-column-by-name($model, "parameterEmissionsSourceCategory")
    let $aggregates := (
        data:create-group-values-aggregate("Emission source category codes", $columnParameterEmissionsSourceCategory),
        data:create-count-aggregate("Number of records")
    )
    return uiutil:build-generic-qc-markup-by-grouping($qc, $columnProcedureEmissionsMethod, $aggregates, $columnsToDisplay, $validationResult)
};
