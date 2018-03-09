xquery version "1.0" encoding "UTF-8";

module namespace data = 'http://converters.eionet.europa.eu/common/data';

import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at 'meta.xquery';

declare variable $data:ROW-KEY-VALUE-SEPARATOR as xs:string := "#$%~~%#";

declare variable $data:_AGGREGATE-TYPE-COUNT as xs:string := "count";
declare variable $data:_AGGREGATE-TYPE-GROUP-VALUES as xs:string := "group-values";

declare variable $data:_AGGREGATE-TYPE-GROUP as xs:string := "group";

declare function data:get-rows($tableDocument) 
as element(dataRow)*
{
    for $row at $pos in $tableDocument/*[local-name(.) = "Row"]
    return data:create-data-row($row, $pos)
};

declare function data:create-data-row($ddRow as element(), $index as xs:integer)
as element(dataRow)
{
    <dataRow index="{ $index }">{ $ddRow }</dataRow>
};

declare function data:get-row-index($row as element(dataRow))
as xs:integer
{
    xs:integer($row/@index)
};

declare function data:get-row-content($row as element(dataRow))
as element()
{
    $row/*
};

declare function data:get-row-values($row as element(dataRow), $column as element(column))
as xs:string*
{
    let $columnName := meta:get-column-name($column)
    let $dataCells := $row/*[1]/*[local-name(.) = $columnName]
    let $maxOccurs := meta:get-column-max-occurs($column)
    let $maxValueIndex := if ($maxOccurs != -1) then $maxOccurs else count($dataCells)
    let $dataValues :=
        for $dataCell at $index in $dataCells
        return
            if ($index > $maxValueIndex) then
                ()
            else
                let $dataValue := normalize-space(string($dataCell))
                return if ($dataValue = "") then () else $dataValue
    return 
        if (empty($dataValues)) then 
            ("") 
        else
            $dataValues
};

declare function data:is-empty-cell($row as element(dataRow), $column as element(column))
as xs:boolean
{
    let $values := data:get-row-values($row, $column)
    return data:is-empty-value($values)
};

declare function data:is-empty-value($values as xs:string*) 
as xs:boolean
{
    count($values) = 1 and $values[1] = ""
};

declare function data:get-row-key($row as element(dataRow), $keyColumns as element(column)*)
as xs:string
{
    let $keyValues := 
        for $keyColumn in $keyColumns
        let $keyColumnValues := data:get-row-values($row, $keyColumn)
        return
            if (count($keyColumnValues) > 1) then
                let $orderedValues :=
                    for $keyColumnValue in $keyColumnValues
                    order by $keyColumnValue
                    return $keyColumnValue
                let $delimiter := meta:get-column-multi-value-delimiter($keyColumn)
                return string-join($orderedValues, $delimiter)
            else
                $keyColumnValues
    return lower-case(string-join($keyValues, $data:ROW-KEY-VALUE-SEPARATOR))
};

declare function data:get-row-values-as-string($row as element(dataRow), $column as element(column))
as xs:string
{
    let $values := data:get-row-values($row, $column)
    return
        if (count($values) < 2) then
            $values[1]
        else
            let $delimiter := meta:get-column-multi-value-delimiter($column)
            return string-join($values, $delimiter)
};

declare function data:create-count-aggregate($alias as xs:string)
as element(aggregate)
{
    <aggregate type="{ $data:_AGGREGATE-TYPE-COUNT }" alias="{ $alias }" />
};

declare function data:create-group-values-aggregate($alias as xs:string, $column as element(column))
as element(aggregate)
{
    <aggregate type="{ $data:_AGGREGATE-TYPE-GROUP-VALUES }" alias="{ $alias }">
        { $column }
    </aggregate>
};

declare function data:create-group-aggregate()
as element(aggregate)
{
    <aggregate type="{ $data:_AGGREGATE-TYPE-GROUP }" />
};

declare function data:group-by($rows as element(dataRow)*, $columns as element(column)*, $aggregates as element(aggregate)*)
as element(group)*
{
    let $rowKeys := data:_calculate-row-keys($rows, $columns)
    for $rowKey in $rowKeys
    let $groupRows :=
        for $row in $rows
        where $rowKey = data:get-row-key($row, $columns)
        return $row
    let $groupRow := $groupRows[1]
    return
        <group>
            <columns> {
                for $column in $columns
                return
                    <column name="{ meta:get-column-name($column) }">
                        <value>{ data:get-row-values-as-string($groupRow, $column) }</value>
                    </column>
            }
            </columns> 
            {
                if (empty($aggregates[@type = $data:_AGGREGATE-TYPE-GROUP])) then
                    ()
                else
                    <rows>{ $groupRows }</rows>
            }
            <totals> {
                for $aggregate in $aggregates
                let $alias := string($aggregate/@alias)
                let $type := string($aggregate/@type)
                let $calculatedValues :=
                    if ($type = $data:_AGGREGATE-TYPE-COUNT) then
                        (data:_calculate-count($groupRows))
                    else if ($type = $data:_AGGREGATE-TYPE-GROUP-VALUES) then
                        data:_calculate-group-values($aggregate, $groupRows)
                    else
                        ()
                return
                    <total name="{ $alias }"> {
                        for $value in $calculatedValues
                        return <value>{ $value }</value>
                    }
                    </total>
            }
            </totals>
        </group>
    
};

declare function data:_calculate-row-keys($rows as element(dataRow)*, $columns as element(column)*)
as xs:string*
{
    let $rowKeys := 
        for $row in $rows
        let $rowKey := data:get-row-key($row, $columns)
        order by $rowKey  
        return $rowKey
    return distinct-values($rowKeys)
};

declare function data:_calculate-count($groupRows as element(dataRow)*)
as xs:integer
{
    count($groupRows)
};

declare function data:_calculate-group-values($groupAggregate as element(aggregate), $groupRows as element(dataRow)*)
as xs:string*
{
    let $groupColumn := $groupAggregate/column
    let $groupValues :=
        for $row in $groupRows
        let $values := data:get-row-values($row, $groupColumn)
        return 
            if (data:is-empty-value($values)) then
                ()
            else
                $values
    return distinct-values($groupValues)
};
