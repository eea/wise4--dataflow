xquery version "1.0" encoding "UTF-8";

module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult';

import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../qclevels.xquery';

declare variable $vldres:MAX_RECORD_RESULTS := 300;

declare function vldres:get-qc-level($validationResult as element(result))
as xs:integer
{
    let $resultRows := $validationResult/rows/*
    return
        if (empty($resultRows)) then
            $qclevels:OK
        else
            let $qcLevels :=
                for $flaggedColumn in $resultRows/flaggedColumns/flaggedColumn
                let $columnLevel := $flaggedColumn/@level
                return
                    if (not(empty($columnLevel))) then
                        data($columnLevel)
                    else
                        data($flaggedColumn/flaggedValues/value/@level)
            return xs:integer(max($qcLevels))
};

declare function vldres:create-result($resultRows as element(row)*)
as element(result)
{
    vldres:create-result($resultRows, <counts/>)
};

declare function vldres:create-result($resultRows as element(row)*, $counts as element(counts))
as element(result)
{
    let $truncated := not(empty($resultRows[vldres:_is-trucation-row(.)]))
    return
        <result truncated="{ $truncated }">
            <rows>{ 
                if ($truncated) then
                    $resultRows[not(vldres:_is-trucation-row(.))]
                else
                    $resultRows
            }
            </rows>
            { $counts }
        </result>
};

declare function vldres:is-truncated-result($validationResult as element(result))
as xs:boolean
{
    not(empty($validationResult[@truncated = true()]))
};

declare function vldres:create-result-row($dataRow as element(dataRow), $flaggedColumns as element(flaggedColumn)*)
as element(row)
{
    <row>
        <data>{ $dataRow }</data>
        <flaggedColumns>
            { $flaggedColumns }
        </flaggedColumns>
    </row>
}; 

declare function vldres:create-truncation-row()
as element(row)
{
    <row truncated="true" />
};

declare function vldres:_is-trucation-row($resultRow as element(row))
as xs:boolean
{
    not(empty($resultRow[@truncated = true()]))
};

declare function vldres:create-flagged-column($column as element(column), $errorLevel as xs:integer)
as element(flaggedColumn)
{
    <flaggedColumn level="{ $errorLevel }">{ $column }</flaggedColumn>
};

declare function vldres:create-flagged-column($column as element(column), $errorLevel as xs:integer, $tag as xs:string)
as element(flaggedColumn)
{
    <flaggedColumn level="{ $errorLevel }" tag="{ $tag }">{ $column }</flaggedColumn>
};

declare function vldres:create-flagged-column-by-values($column as element(column), $flaggedValues as element(value)*)
as element(flaggedColumn)
{
    <flaggedColumn>
        { $column }
        <flaggedValues>
            { $flaggedValues }
        </flaggedValues>
    </flaggedColumn>
};

declare function vldres:create-flagged-value($errorLevel as xs:integer, $value as xs:string)
as element(value)
{
    <value level="{ $errorLevel }">{ $value }</value>
};

declare function vldres:create-flagged-value($errorLevel as xs:integer, $value as xs:string, $tag as xs:string)
as element(value)
{
    <value level="{ $errorLevel }" tag="{ $tag }">{ $value }</value>
};

declare function vldres:calculate-column-counts($resultRows as element(row)*, $columns as element(column)*)
as element(counts)
{
    <counts> {
        for $column in $columns
        let $columnName := meta:get-column-name($column)
        let $matchingRows :=
            for $resultRow in $resultRows
            where not(empty($resultRow/flaggedColumns/flaggedColumn/column[meta:get-column-name(.) = $columnName]))
            return $resultRow
        let $count := count($matchingRows)
        where $count > 0
        return
            <column name="{ $columnName }" count="{ $count }" />
    }
    </counts>
};

declare function vldres:calculate-column-value-counts($resultRows as element(row)*, $columns as element(column)*)
as element(counts)
{
    <counts> {
        for $column in $columns
        let $columnName := meta:get-column-name($column)
        let $columnRows :=
            for $resultRow in $resultRows
            let $flaggedColumns := $resultRow/flaggedColumns/flaggedColumn[column[meta:get-column-name(.) = $columnName]] 
            where not(empty($flaggedColumns))
            return <columnRow>{ $flaggedColumns }</columnRow>
        let $columnValues := distinct-values(data($columnRows/flaggedColumn/flaggedValues/value))
        return
            for $columnValue in $columnValues
            let $columnValueRows :=
                for $columnRow in $columnRows
                let $matchingValues := $columnRow/flaggedColumn/flaggedValues/value[text() = $columnValue]
                where not(empty($matchingValues))
                return $columnRow
            let $columnValueCount := count($columnValueRows)
            where $columnValueCount > 0
            return
                <columnValue columnName="{ $columnName }" value="{ $columnValue }" count="{ $columnValueCount }" />
    }
    </counts>
};

declare function vldres:calculate-tag-column-counts($resultRows as element(row)*)
as element(counts)
{
    <counts> {
        let $flaggedColumns := $resultRows/flaggedColumns/flaggedColumn
        let $tags := distinct-values(data($flaggedColumns/@tag))
        return
            for $tag in $tags
            let $tagCount := count($resultRows[flaggedColumns/flaggedColumn[@tag = $tag]])
            return
                <tagValue tag="{ $tag }" count="{ $tagCount }" />
    }
    </counts>
};

declare function vldres:calculate-tag-value-counts($resultRows as element(row)*)
as element(counts)
{
    <counts> {
        let $flaggedValues := $resultRows/flaggedColumns/flaggedColumn/flaggedValues/value
        let $tags := distinct-values(data($flaggedValues/@tag))
        return
            for $tag in $tags
            let $tagCount := count($resultRows[flaggedColumns/flaggedColumn/flaggedValues/value[@tag = $tag]])
            return
                <tagValue tag="{ $tag }" count="{ $tagCount }" />
    }
    </counts>
};

declare function vldres:get-row-qc-level($resultRow as element(row))
as xs:integer
{
    xs:integer(max((
        max($resultRow/flaggedColumns/flaggedColumn/@level),
        max($resultRow/flaggedColumns/flaggedColumn/flaggedValues/value/@level)
    )))
};

declare function vldres:filter-max-qc-level-by-flagged-columns($resultRows as element(row)*)
as element(row)*
{
    let $maxQcLevel := max($resultRows/flaggedColumns/flaggedColumn/@level)
    return
        if ($maxQcLevel < $qclevels:BLOCKER) then
            $resultRows
        else
            for $resultRow in $resultRows
            return
                if (vldres:_is-trucation-row($resultRow)) then
                    $resultRow
                else
                    (:let $blockerColumns := $resultRow/flaggedColumns/flaggedColumn[@level = $qclevels:BLOCKER]:)
                    let $blockerColumns := $resultRow/flaggedColumns/flaggedColumn
                    return
                        if (empty($blockerColumns)) then
                            ()
                        else
                            vldres:create-result-row($resultRow/data/*[1], $blockerColumns)
};

declare function vldres:filter-max-qc-level-by-flagged-values($resultRows as element(row)*)
as element(row)*
{
    let $maxQcLevel := max($resultRows/flaggedColumns/flaggedColumn/flaggedValues/value/@level)
    return
        if ($maxQcLevel < $qclevels:BLOCKER) then
            $resultRows
        else
            for $resultRow in $resultRows
            return
                if (vldres:_is-trucation-row($resultRow)) then
                    $resultRow
                else
                    let $blockerColumns :=
                        for $flaggedColumn in  $resultRow/flaggedColumns/flaggedColumn
                        let $blockerValues := $flaggedColumn/flaggedValues/value[@level = $qclevels:BLOCKER]
                        where not(empty($blockerValues))
                        return
                            vldres:create-flagged-column-by-values($flaggedColumn/column, $blockerValues)
                    return
                        if (empty($blockerColumns)) then
                            ()
                        else
                            vldres:create-result-row($resultRow/data/*[1], $blockerColumns)
};

declare function vldres:mark_trunkated(
        $r as element()*,
        $limit as xs:decimal
)
as element()*
{
    if (count($r) > $limit) then
        ($r[position() = 1 to $limit], vldres:create-truncation-row())
    else
        $r
};
