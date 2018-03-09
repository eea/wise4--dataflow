xquery version "1.0" encoding "UTF-8";

module namespace vldtypes = 'http://converters.eionet.europa.eu/common/validators/types';

import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../qclevels.xquery';
import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../data.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../meta.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at 'validation-result.xquery';

declare function vldtypes:validate-data-types(
    $model as element(model),
    $dataRows as element(dataRow)*,
    $exceptions as element(typeExceptions)
    )
    as element(result)
    {
        let $mixedResultRows := vldtypes:_validate($model, $exceptions, $dataRows, 1, 1, ())
        let $resultRows := vldres:filter-max-qc-level-by-flagged-values($mixedResultRows)
        let $counts := vldres:calculate-column-counts($resultRows, $model/columns/column)
        return vldres:create-result($resultRows, $counts)
};

declare function vldtypes:_validate(
    $model as element(model),
    $exceptions as element(typeExceptions),
    $dataRows as element(dataRow)*,
    $dataRowIndex as xs:integer,
    $qclevelIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    let $blocker := vldres:mark_trunkated(
        (for $row in $dataRows
        let $currentQclevel := qclevels:list-flag-levels-desc()[1]
        return vldtypes:_validate-row($model, $exceptions, $row, $currentQclevel)
        ), $vldres:MAX_RECORD_RESULTS)
    let $error := vldres:mark_trunkated(
        (for $row in $dataRows
        let $currentQclevel := qclevels:list-flag-levels-desc()[2]
        return vldtypes:_validate-row($model, $exceptions, $row, $currentQclevel)
        ), $vldres:MAX_RECORD_RESULTS)
    let $warning := vldres:mark_trunkated(
        (for $row in $dataRows
        let $currentQclevel := qclevels:list-flag-levels-desc()[3]
        return vldtypes:_validate-row($model, $exceptions, $row, $currentQclevel)
        ), $vldres:MAX_RECORD_RESULTS)
    let $info := vldres:mark_trunkated(
        (for $row in $dataRows
        let $currentQclevel := qclevels:list-flag-levels-desc()[4]
        return vldtypes:_validate-row($model, $exceptions, $row, $currentQclevel)
        ), $vldres:MAX_RECORD_RESULTS)
    return ($blocker, $error, $warning, $info)


    (:if ($qclevelIndex > count(qclevels:list-flag-levels-desc())) then
        $resultRows
    else if ($dataRowIndex > count($dataRows)) then
        if ($qclevelIndex > count(qclevels:list-flag-levels-desc())) then
            $resultRows
        else
            vldtypes:_validate($model, $exceptions, $dataRows, 1, $qclevelIndex + 1, $resultRows)
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $currentQclevel := qclevels:list-flag-levels-desc()[$qclevelIndex]
        let $rowResult := vldtypes:_validate-row($model, $exceptions, $dataRow, $currentQclevel)
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldtypes:_validate($model, $exceptions, $dataRows, $dataRowIndex + 1, $qclevelIndex, $newResultRows):)
};

declare function vldtypes:_validate-row(
    $model as element(model),
    $exceptions as element(typeExceptions),
    $row as element(dataRow),
    $acceptedQcLevel as xs:integer
)
as element(row)?
{
    let $flaggedColumns :=
        for $column in $model/columns/column
        let $values := data:get-row-values($row, $column)
        let $flaggedValues :=
            for $value in $values
            let $qcLevel := vldtypes:validate-by-type($column, $value, $exceptions)
            where $qcLevel != $qclevels:OK and $qcLevel = $acceptedQcLevel
            return 
                vldres:create-flagged-value($qcLevel, $value)
        where not(empty($flaggedValues))
        return 
            vldres:create-flagged-column-by-values($column, $flaggedValues)
    return
        if (empty($flaggedColumns)) then
            ()
        else 
            vldres:create-result-row($row, $flaggedColumns)
};

declare function vldtypes:validate-by-type($column as element(column), $value as xs:string)
as xs:integer
{
    vldtypes:validate-by-type($column, $value, <typeExceptions/>)
};

declare function vldtypes:validate-by-type($column as element(column), $value as xs:string, $exceptions as element(typeExceptions))
as xs:integer
{
    let $dataType := string($column/@dataType)
    return 
        if ($value = '') then
            $qclevels:OK
        else if ($dataType = 'string') then
            vldtypes:validate-string($column, $value, $exceptions)
        else if ($dataType = 'integer') then
            vldtypes:validate-integer($column, $value, $exceptions)
        else if ($dataType = 'decimal') then
            vldtypes:validate-decimal($column, $value, $exceptions)
        else if ($dataType = 'double') then
            vldtypes:validate-double($column, $value, $exceptions)
        else if ($dataType = 'float') then
            vldtypes:validate-float($column, $value, $exceptions)
        else if ($dataType = 'date') then
            vldtypes:validate-date($column, $value, $exceptions)
        else 
            $qclevels:OK
};

declare function vldtypes:validate-date($column as element(column), $value as xs:string, $exceptions as element(typeExceptions))
as xs:integer
{
    let $resultValue :=
        if ($value castable as xs:date) then
            $qclevels:OK
        else
            vldtypes:_get-exception-or-error($column, $exceptions, 'type')
    return $resultValue
};

declare function vldtypes:validate-string($column as element(column), $value as xs:string, $exceptions as element(typeExceptions)) as xs:integer {
    let $minLength := vldtypes:_get-restriction-value($column, "minLength")
    let $maxLength := vldtypes:_get-restriction-value($column, "maxLength")
    let $valueLength := string-length($value)
    let $validationCodes := (
        if ($minLength castable as xs:integer) then
            if (xs:integer($minLength) <= $valueLength) then
                $qclevels:OK
            else
                vldtypes:_get-exception-or-error($column, $exceptions, 'minLength')
        else
            $qclevels:OK
        ,
        if ($maxLength castable as xs:integer) then
            if (xs:integer($maxLength) >= $valueLength) then
                $qclevels:OK
            else
                vldtypes:_get-exception-or-error($column, $exceptions, 'maxLength')
        else
            $qclevels:OK
    )
    let $resultValue := max($validationCodes)
    
    return $resultValue
};

declare function vldtypes:validate-integer($column as element(column), $value as xs:string, $exceptions as element(typeExceptions))
as xs:integer
{
    let $minInclusive := vldtypes:_get-restriction-value($column, "minInclusive")
    let $minExclusive := vldtypes:_get-restriction-value($column, "minExclusive")
    let $maxInclusive := vldtypes:_get-restriction-value($column, "maxInclusive")
    let $maxExclusive := vldtypes:_get-restriction-value($column, "maxExclusive")
    let $isInteger := $value castable as xs:integer
    let $validationCodes := 
        if (not($isInteger)) then
            ( vldtypes:_get-exception-or-error($column, $exceptions, 'type') )
        else
            let $numValue := xs:integer($value)
            return (
                if ($minInclusive castable as xs:integer) then
                    if (xs:integer($minInclusive) <= $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'minInclusive')
                else
                    $qclevels:OK
                ,
                if ($minExclusive castable as xs:integer) then
                    if (xs:integer($minExclusive) < $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'minExclusive')
                else
                    $qclevels:OK
                ,
                if ($maxInclusive castable as xs:integer) then
                    if (xs:integer($maxInclusive) >= $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'maxInclusive')
                else
                    $qclevels:OK
                ,
                if ($maxExclusive castable as xs:integer) then
                    if (xs:integer($maxExclusive) > $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'maxExclusive')
                else
                    $qclevels:OK
            )
    let $resultValue := max($validationCodes)
    return $resultValue
};

declare function vldtypes:validate-decimal($column as element(column), $value as xs:string, $exceptions as element(typeExceptions))
as xs:integer
{
    let $minInclusive := vldtypes:_get-restriction-value($column, "minInclusive")
    let $minExclusive := vldtypes:_get-restriction-value($column, "minExclusive")
    let $maxInclusive := vldtypes:_get-restriction-value($column, "maxInclusive")
    let $maxExclusive := vldtypes:_get-restriction-value($column, "maxExclusive")
    let $isDecimal := $value castable as xs:decimal
    let $validationCodes :=
        if (not($isDecimal)) then
            ( vldtypes:_get-exception-or-error($column, $exceptions, 'type') )
        else
            let $numValue := xs:decimal($value)
            return (
                if ($minInclusive castable as xs:decimal) then
                    if (xs:decimal($minInclusive) <= $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'minInclusive')
                else
                    $qclevels:OK
                ,
                if ($minExclusive castable as xs:decimal) then
                    if (xs:decimal($minExclusive) < $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'minExclusive')
                else
                    $qclevels:OK
                ,
                if ($maxInclusive castable as xs:decimal) then
                    if (xs:decimal($maxInclusive) >= $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'maxInclusive')
                else
                    $qclevels:OK
                ,
                if ($maxExclusive castable as xs:decimal) then
                    if (xs:decimal($maxExclusive) > $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'maxExclusive')
                else
                    $qclevels:OK
            )
    let $resultValue := max($validationCodes)
    return $resultValue
};

declare function vldtypes:validate-double($column as element(column), $value as xs:string, $exceptions as element(typeExceptions))
as xs:integer
{
    let $minInclusive := vldtypes:_get-restriction-value($column, "minInclusive")
    let $minExclusive := vldtypes:_get-restriction-value($column, "minExclusive")
    let $maxInclusive := vldtypes:_get-restriction-value($column, "maxInclusive")
    let $maxExclusive := vldtypes:_get-restriction-value($column, "maxExclusive")
    let $isDouble := $value castable as xs:double
    let $validationCodes :=
        if (not($isDouble)) then
            ( vldtypes:_get-exception-or-error($column, $exceptions, 'type') )
        else
            let $numValue := xs:double($value)
            return (
                if ($minInclusive castable as xs:double) then
                    if (xs:double($minInclusive) <= $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'minInclusive')
                else
                    $qclevels:OK
                ,
                if ($minExclusive castable as xs:double) then
                    if (xs:double($minExclusive) < $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'minExclusive')
                else
                    $qclevels:OK
                ,
                if ($maxInclusive castable as xs:double) then
                    if (xs:double($maxInclusive) >= $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'maxInclusive')
                else
                    $qclevels:OK
                ,
                if ($maxExclusive castable as xs:double) then
                    if (xs:double($maxExclusive) > $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'maxExclusive')
                else
                    $qclevels:OK
            )
    let $resultValue := max($validationCodes)
    return $resultValue
};

declare function vldtypes:validate-float($column as element(column), $value as xs:string, $exceptions as element(typeExceptions))
as xs:integer
{
    let $minInclusive := vldtypes:_get-restriction-value($column, "minInclusive")
    let $minExclusive := vldtypes:_get-restriction-value($column, "minExclusive")
    let $maxInclusive := vldtypes:_get-restriction-value($column, "maxInclusive")
    let $maxExclusive := vldtypes:_get-restriction-value($column, "maxExclusive")
    let $isFloat := $value castable as xs:float
    let $validationCodes :=
        if (not($isFloat)) then
            ( vldtypes:_get-exception-or-error($column, $exceptions, 'type') )
        else
            let $numValue := xs:float($value)
            return (
                if ($minInclusive castable as xs:float) then
                    if (xs:float($minInclusive) <= $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'minInclusive')
                else
                    $qclevels:OK
                ,
                if ($minExclusive castable as xs:float) then
                    if (xs:float($minExclusive) < $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'minExclusive')
                else
                    $qclevels:OK
                ,
                if ($maxInclusive castable as xs:float) then
                    if (xs:float($maxInclusive) >= $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'maxInclusive')
                else
                    $qclevels:OK
                ,
                if ($maxExclusive castable as xs:float) then
                    if (xs:float($maxExclusive) > $numValue) then
                        $qclevels:OK
                    else
                        vldtypes:_get-exception-or-error($column, $exceptions, 'maxExclusive')
                else
                    $qclevels:OK
            )
    let $resultValue := max($validationCodes)
    return $resultValue
};

declare function vldtypes:_get-exception-or-error(
    $column as element(column), 
    $exceptions as element(typeExceptions), 
    $restrictionName as xs:string
)
as xs:integer
{
    let $exception := vldtypes:_get-column-exceptions($column, $exceptions, $restrictionName)
    return
        if (empty($exception)) then
            $qclevels:BLOCKER
        else
            xs:integer($exception/@qcResult)
};

declare function vldtypes:_get-column-exceptions(
    $column as element(column),
    $exceptions as element(typeExceptions),
    $restrictionName as xs:string
)
as element(typeException)*
{
    $exceptions/typeException[@columnName = meta:get-column-name($column) and @restrictionName = $restrictionName]
};

declare function vldtypes:_get-restriction-value($column as element(column), $restrictionName as xs:string)
as xs:string
{
    let $q := $column/restrictions/restriction[@name = $restrictionName]/@value
    return if (empty($q)) then '' else string($q)
};
