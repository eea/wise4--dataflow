xquery version "1.0" encoding "UTF-8";

module namespace vldvallim = "http://converters.eionet.europa.eu/wise/common/validators/valueLimits";

import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../common/qclevels.xquery';

declare function vldvallim:get-limits(
    $limitDefinitions as element(WiseSoeQc),
    $datasetId as xs:string,
    $tableId as xs:string
)
as element(limits)*
{
    for $determinand in $limitDefinitions/Determinand
    let $tableLimits := $determinand/Dataset[@Identifier = $datasetId]/Table[@Identifier = $tableId]/*
    return
        if (empty($tableLimits)) then
            ()
        else
            <limits determinand="{ string($determinand/@Identifer) }">{ $tableLimits }</limits>
};

declare function vldvallim:validate-value-limit($value as xs:decimal?, $limits as element(limits)?)
as xs:integer
{
    if (empty($value) or empty($limits)) then
        $qclevels:OK
    else
        max((
            vldvallim:_validate-by-restriction($value, $limits, "minExclusive"),
            vldvallim:_validate-by-restriction($value, $limits, "minInclusive"),
            vldvallim:_validate-by-restriction($value, $limits, "maxInclusive"),
            vldvallim:_validate-by-restriction($value, $limits, "maxExclusive")
        ))
};

declare function vldvallim:_validate-by-restriction($value as xs:decimal, $limits as element(limits), $restriction as xs:string)
as xs:integer
{
    let $limit := $limits/*[local-name(.) = $restriction]
    let $limitValueText := if (empty($limit)) then () else string($limit[1])
    let $limitValue := if ($limitValueText castable as xs:decimal) then xs:decimal($limitValueText) else ()
    return
        if (empty($limitValue)) then
            $qclevels:OK
        else
            let $isValid :=
                if ($restriction = "minExclusive") then
                    $value > $limitValue
                else if ($restriction = "minInclusive") then
                    $value >= $limitValue
                else if ($restriction = "maxInclusive") then
                    $value <= $limitValue
                else if ($restriction = "maxExclusive") then
                    $value < $limitValue
                else
                    true()
            return
                if ($isValid) then
                    $qclevels:OK
                else
                    let $tag := xs:string($limit/@tag)
                    return vldvallim:_restriction-tag-to-qc-level($tag)
};

declare function vldvallim:_restriction-tag-to-qc-level($tag as xs:string)
as xs:integer
{   
    let $tagLowerCase := lower-case($tag)
    return
        if ($tagLowerCase = "blocker") then
            $qclevels:BLOCKER
        else if ($tagLowerCase = "error") then
            $qclevels:ERROR
        else if ($tagLowerCase = "warning") then
            $qclevels:WARNING
        else if ($tagLowerCase = "info") then
            $qclevels:INFO
        else
            $qclevels:OK
};
