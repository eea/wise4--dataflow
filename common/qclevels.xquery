xquery version "1.0" encoding "UTF-8";

module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels';

declare variable $qclevels:OK as xs:integer := 0;
declare variable $qclevels:INFO as xs:integer := 1;
declare variable $qclevels:WARNING as xs:integer := 2;
declare variable $qclevels:ERROR as xs:integer := 3;
declare variable $qclevels:BLOCKER as xs:integer := 4;

declare function qclevels:to-qc-event($qc as element(qc), $qcLevel as xs:integer)
as element()?
{
    if ($qcLevel = $qclevels:OK) then
        $qc/onSuccess
    else if ($qcLevel = $qclevels:INFO) then
        $qc/onInfo
    else if ($qcLevel = $qclevels:WARNING) then
        $qc/onWarning
    else if ($qcLevel = $qclevels:ERROR) then
        $qc/onError
    else if ($qcLevel = $qclevels:BLOCKER) then
        $qc/onBlocker
    else
        ()
};

declare function qclevels:to-qc-code($qcLevel as xs:integer)
as xs:string?
{
    if ($qcLevel = $qclevels:OK) then
        "OK"
    else if ($qcLevel = $qclevels:INFO) then
        "INFO"
    else if ($qcLevel = $qclevels:WARNING) then
        "WARNING"
    else if ($qcLevel = $qclevels:ERROR) then
        "ERROR"
    else if ($qcLevel = $qclevels:BLOCKER) then
        "BLOCKER"
    else
        ()
};

declare function qclevels:to-qc-color-class($qcLevel as xs:integer)
as xs:string?
{
    if ($qcLevel = $qclevels:OK) then
        "green"
    else if ($qcLevel = $qclevels:INFO) then
        "blue"
    else if ($qcLevel = $qclevels:WARNING) then
        "orange"
    else if ($qcLevel = $qclevels:ERROR) then
        "red"
    else if ($qcLevel = $qclevels:BLOCKER) then
        "red"
    else
        ()
};

declare function qclevels:to-qc-level($qcCode as xs:string)
as xs:integer?
{
    let $qcCodeUpperCase := upper-case($qcCode)
    return
        if ($qcCodeUpperCase = "OK") then
            $qclevels:OK
        else if ($qcCodeUpperCase = "INFO") then
            $qclevels:INFO
        else if ($qcCodeUpperCase = "WARNING") then
            $qclevels:WARNING
        else if ($qcCodeUpperCase = "ERROR") then
            $qclevels:ERROR
        else if ($qcCodeUpperCase = "BLOCKER") then
            $qclevels:BLOCKER
        else
            ()
};

declare function qclevels:list-flag-levels-desc()
as xs:integer*
{
    ($qclevels:BLOCKER, $qclevels:ERROR, $qclevels:WARNING, $qclevels:INFO)
};
