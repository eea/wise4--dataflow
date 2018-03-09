xquery version "1.0" encoding "UTF-8";

module namespace vldwqlvallim = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/valueLimits";

import module namespace vldvallim = "http://converters.eionet.europa.eu/wise/common/validators/valueLimits" at '../../../wise-common/validators/vld-value-limits.xquery';

declare function vldwqlvallim:get-limits(
    $limitDefinitions as element(WiseSoeQc),
    $datasetId as xs:string,
    $tableId as xs:string
)
as element(limits)*
{
    vldvallim:get-limits($limitDefinitions, $datasetId, $tableId)
};

declare function vldwqlvallim:validate-value-limit($value as xs:decimal?, $limits as element(limits)?)
as xs:integer
{
    vldvallim:validate-value-limit($value, $limits)
};
