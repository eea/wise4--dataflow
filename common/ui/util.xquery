xquery version "1.0" encoding "UTF-8";

module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util';

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../data.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../qclevels.xquery';
import module namespace util = 'http://converters.eionet.europa.eu/common/util' at '../util.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../validators/validation-result.xquery';

declare variable $uiutil:_MAX-RESULT-ROWS as xs:integer := 300;

declare function uiutil:build-header-and-menu-markup(
    $dsCaption as xs:string,
    $tableCaption as xs:string,
    $qcs as element(qcs), 
    $qcResultsMarkup as element(div)
) 
as element(div)
{
    let $menu := 
        <ul class="qcMenu"> {
            for $qc in $qcs/qc
            let $qcId := string($qc/@id)
            let $qcCaption := string($qc/caption)
            let $qcDivSection := $qcResultsMarkup/div[@id = $qcId][1]
            let $qcErrorLevel := tokenize(string($qcDivSection/@class), ' ')[2]
            return
                <li>
                    <a href="#{ $qcId }">{ $qcCaption }</a> - <span class="errorLevel { $qcErrorLevel }">{ $qcErrorLevel }</span>
                </li>
        }
        </ul>
    let $qcMaxResult := max(
        for $qcCode in $menu/li/string(span)
        return qclevels:to-qc-level($qcCode)
    )
    return
        if($tableCaption = "Envelope") then
            <div>
                <h2>The following tests were performed against { $dsCaption } / { $tableCaption }</h2>
                <div id="feedbackStatus" class="{ qclevels:to-qc-code($qcMaxResult) }" style="display: none"> {
                    uiutil:build-feedback-status($qcMaxResult)
                }
                </div>
                { $menu }
            </div>
         else
        <div>
            <h2 id="feedbackStatus_{$tableCaption}">The following tests were performed against the table: { $dsCaption } / { $tableCaption }</h2>
            <div nid="feedbackStatus_{$tableCaption}" dsCaption="{$dsCaption}" tableCaption="{$tableCaption}" level="{$qcMaxResult}" class="{ qclevels:to-qc-code($qcMaxResult) }" style="display: none"> {
                uiutil:build-feedback-status($qcMaxResult)
            }
            </div>
            { $menu }
        </div>
};

declare function uiutil:build-feedback-status($qcMaxResult) {
    if ($qcMaxResult = $qclevels:OK) then
        "All quality checks passed successfully."
    else if ($qcMaxResult = $qclevels:INFO) then
        "The quality checks found no errors, but some additional info has been attached."
    else if ($qcMaxResult = $qclevels:WARNING) then
        "The quality checks found no errors, but some warnings where generated."
    else if ($qcMaxResult = $qclevels:ERROR) then
        "The quality checks found non-blocking errors."
    else if ($qcMaxResult = $qclevels:BLOCKER) then
        "The quality checks found blocking errors."
    else
        "Unknown"
};

declare function uiutil:build-generic-qc-markup-without-checkbox-table(
    $qc as element(qc),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    let $qcId := $qc/@id
    let $qcLevel := vldres:get-qc-level($validationResult)
    let $pass := $qcLevel = $qclevels:OK
    let $event := qclevels:to-qc-event($qc, $qcLevel)
    return
        <div id="{$qcId}" class="{ uiutil:create-section-class($qcLevel) }">
            { uiutil:create-section-heading($qc) }
            { uiutil:create-section-description($qc) }
            { uiutil:create-section-summary($event) }
            {
                if ($pass) then
                    ()
                else
                    <div class="qcDetails">
                        { uiutil:create-record-count($validationResult) }
                        { uiutil:create-row-toggle-button($qcId) }
                        <div id="dataarea_{ $qcId }" style="display: none;">
                            { uiutil:create-data-table($qc, $columnsToDisplay, $validationResult) }
                        </div>
                    </div>
            }
        </div>
};

declare function uiutil:build-generic-qc-markup-by-column-values(
    $qc as element(qc),
    $qcColumn as element(column),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    let $qcId := $qc/@id
    let $qcLevel := vldres:get-qc-level($validationResult)
    let $pass := $qcLevel = $qclevels:OK
    let $event := qclevels:to-qc-event($qc, $qcLevel)
    return
        <div id="{$qcId}" class="{ uiutil:create-section-class($qcLevel) }">
            { uiutil:create-section-heading($qc) }
            { uiutil:create-section-description($qc) }
            { uiutil:create-section-summary($event) }
            { 
                if ($pass) then
                    ()
                else
                    <div class="qcDetails">
                        { uiutil:create-record-count($validationResult) }
                        { uiutil:create-checkbox-table-by-column-values($qcId, $qcColumn, $validationResult) }
                        { uiutil:create-row-toggle-button($qcId) }
                        <div id="dataarea_{ $qcId }" style="display: none;">
                            { uiutil:create-data-table-by-column-values($qc, $qcColumn, $columnsToDisplay, $validationResult) }
                        </div>
                    </div>
            }
        </div>
};

declare function uiutil:build-generic-qc-markup-by-tag-values(
    $qc as element(qc),
    $tagCaption as xs:string,
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    let $qcId := $qc/@id
    let $qcLevel := vldres:get-qc-level($validationResult)
    let $pass := $qcLevel = $qclevels:OK
    let $event := qclevels:to-qc-event($qc, $qcLevel)
    return
        <div id="{$qcId}" class="{ uiutil:create-section-class($qcLevel) }">
            { uiutil:create-section-heading($qc) }
            { uiutil:create-section-description($qc) }
            { uiutil:create-section-summary($event) }
            { 
                if ($pass) then
                    ()
                else
                    <div class="qcDetails">
                        { uiutil:create-record-count($validationResult) }
                        { uiutil:create-checkbox-table-by-tag-values($qcId, $tagCaption, $validationResult) }
                        { uiutil:create-row-toggle-button($qcId) }
                        <div id="dataarea_{ $qcId }" style="display: none;">
                            { uiutil:create-data-table-by-tag-values($qc, $columnsToDisplay, $tagCaption, $validationResult) }
                        </div>
                    </div>
            }
        </div>
};

declare function uiutil:build-generic-qc-markup-by-grouping(
    $qc as element(qc),
    $groupColumns as element(column)*,
    $aggregates as element(aggregate)*,
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    let $qcId := $qc/@id
    let $qcLevel := vldres:get-qc-level($validationResult)
    let $pass := $qcLevel = $qclevels:OK
    let $event := qclevels:to-qc-event($qc, $qcLevel)
    return
        <div id="{$qcId}" class="{ uiutil:create-section-class($qcLevel) }">
            { uiutil:create-section-heading($qc) }
            { uiutil:create-section-description($qc) }
            { uiutil:create-section-summary($event) }
            { 
                if ($pass) then
                    ()
                else
                    <div class="qcDetails">
                        { uiutil:create-record-count($validationResult) }
                        { uiutil:create-checkbox-table-by-grouping($qcId, $groupColumns, $aggregates, $validationResult) }
                        { uiutil:create-row-toggle-button($qcId) }
                        <div id="dataarea_{ $qcId }" style="display: none;">
                            <table id="datatable_{ string($qc/@id) }" class="dataTable">
                                { uiutil:create-data-table-head($columnsToDisplay) }
                                <tbody> {
                                    for $resultRow in $validationResult/rows/row
                                    let $rowCssClass := uiutil:compose-group-class-name-of-data-row($resultRow/data/*, $groupColumns)
                                    return uiutil:create-data-table-body-row($qc, $columnsToDisplay, $resultRow, $rowCssClass)
                                }
                                </tbody>
                            </table>
                        </div>
                    </div>
            }
        </div>
};

declare function uiutil:create-section-class($qcLevel as xs:integer)
as xs:string
{
    concat("qcSection ", qclevels:to-qc-code($qcLevel))
};

declare function uiutil:create-section-heading($qc as element(qc))
as element(h3)
{
    <h3>{ string($qc/caption) }</h3>
};

declare function uiutil:create-section-description($qc as element(qc))
as element(p)
{
    <p>{ $qc/description }</p>
};

declare function uiutil:create-section-summary($qcEvent as element())
as element(span)
{
    <span class="summary">{ string($qcEvent/message) }</span>
};

declare function uiutil:create-record-count($validationResult as element(result))
as element(p)
{
    if (vldres:is-truncated-result($validationResult)) then
        <p>More than { $vldres:MAX_RECORD_RESULTS } records detected, result set was truncated.</p>
    else
        <p>{ count($validationResult/rows/row) } records detected.</p>
};

declare function uiutil:create-checkbox-table($qcId as xs:string, $validationResult as element(result))
as element(table)
{
    uiutil:create-checkbox-table($qcId, $validationResult, false())
};

declare function uiutil:create-checkbox-table($qcId as xs:string, $validationResult as element(result), $showElementValues as xs:boolean)
as element(table)
{
    <table id="{ concat('checkboxTable_', $qcId) }">
        <thead>
            <tr>
                <th></th>
                <th>Element name</th>
                {
                    if ($showElementValues) then 
                        <th>Incorrect values</th>
                    else
                        ()
                }
                <th>Number of records detected</th>
            </tr>
        </thead>
        <tbody> {
            for $errorColumn in $validationResult/counts/column
            let $columnName := string($errorColumn/@name)
            let $checkboxId := concat("checkbox_", $qcId, "_", $columnName)
            let $columnValues := 
                if (not($showElementValues)) then 
                    () 
                else
                    string-join(util:sort(distinct-values(
                        for $resultRow in $validationResult/rows/row
                        let $flaggedColumn := $resultRow/flaggedColumns/flaggedColumn[meta:get-column-name(./column) = $columnName]
                        return
                            if (empty($flaggedColumn/@level)) then
                                $flaggedColumn/flaggedValues/string(value)
                            else
                                data:get-row-values($resultRow/data/*, $flaggedColumn/column)
                    )), ", ")
            return 
                <tr>
                    <td>
                        <input id="{ $checkboxId }" type="checkbox" onclick="onColumnCheckboxCheck(this)"></input>
                    </td>
                    <td>{ $columnName }</td>
                    {
                        if ($showElementValues) then 
                            <td>{ $columnValues }</td>
                        else
                            ()
                    }
                    <td>{ string($errorColumn/@count) }</td>
                </tr>
        }
        </tbody>
    </table>
};

declare function uiutil:create-checkbox-table-by-column-values(
    $qcId as xs:string,
    $column as element(column),
    $validationResult as element(result)
)
as element(table)
{
    let $columnName := meta:get-column-name($column)
    let $valueCounts := $validationResult/counts/columnValue[@columnName = $columnName] 
    return
        <table id="{ concat('checkboxTable_', $qcId) }">
            <thead>
                <tr>
                    <th></th>
                    <th>{ meta:get-column-name($column) }</th>
                    <th>Number of records detected</th>
                </tr>
            </thead>
            <tbody> {
                for $valueCount in $valueCounts
                let $value := string($valueCount/@value)
                let $count := xs:integer($valueCount/@count)
                let $checkboxId := concat("checkbox_", $qcId, "_", uiutil:strip-white-chars($value))
                return
                    <tr>
                        <td><input id="{ $checkboxId }" type="checkbox" onclick="onColumnCheckboxCheck(this)"></input></td>
                        <td>{ $value }</td>
                        <td>{ $count }</td>
                    </tr>
            }
            </tbody>
        </table>
};

declare function uiutil:create-checkbox-table-by-tag-values(
    $qcId as xs:string,
    $tagCaption as xs:string,
    $validationResult as element(result)
)
as element(table)
{
    let $tagCounts := $validationResult/counts/tagValue 
    return
        <table id="{ concat('checkboxTable_', $qcId) }">
            <thead>
                <tr>
                    <th></th>
                    <th>{ $tagCaption }</th>
                    <th>Number of records detected</th>
                </tr>
            </thead>
            <tbody> {
                for $tagCount in $tagCounts
                let $tag := string($tagCount/@tag)
                let $count := xs:integer($tagCount/@count)
                let $checkboxId := concat("checkbox_", $qcId, "_", uiutil:strip-white-chars($tag))
                order by $tag
                return
                    <tr>
                        <td><input id="{ $checkboxId }" type="checkbox" onclick="onColumnCheckboxCheck(this)"></input></td>
                        <td>{ $tag }</td>
                        <td>{ $count }</td>
                    </tr>
            }
            </tbody>
        </table>
};

declare function uiutil:create-checkbox-table-by-grouping(
    $qcId as xs:string,
    $groupColumns as element(column)*,
    $aggregates as element(aggregate)*,
    $validationResult as element(result)
)
as element(table)
{
    let $dataRows := $validationResult/rows/row/data/*
    let $groupRows := data:group-by($dataRows, $groupColumns, $aggregates)
    return
        <table id="{ concat('checkboxTable_', $qcId) }">
            <thead>
                <tr>
                    <th></th>
                    {
                        for $groupColumn in $groupColumns
                        return
                            <th>{ meta:get-column-name($groupColumn) }</th>
                    }
                    {
                        for $aggregate in $aggregates
                        return
                            <th>{ string($aggregate/@alias) }</th>
                    }
                </tr>
            </thead>
            <tbody> {
                for $groupRow in $groupRows
                let $checkboxId := concat("checkbox_", $qcId, "_", uiutil:compose-group-class-name-of-group($groupRow ,$groupColumns))
                return
                    <tr>
                        <td>
                            <input id="{ $checkboxId }" type="checkbox" onclick="onColumnCheckboxCheck(this)"></input>
                        </td>
                        {
                            for $groupColumn in $groupColumns
                            return 
                                <td>
                                    { data($groupRow/columns/column[@name = meta:get-column-name($groupColumn)]/value) }
                                </td>
                        }
                        {
                            for $aggregate in $aggregates
                            let $aggregateAlias := string($aggregate/@alias)
                            return
                                <td> {
                                    let $values := data($groupRow/totals/total[@name = $aggregateAlias]/value)
                                    return string-join($values, ", ")
                                }
                                </td>
                        }
                    </tr>
            }
            </tbody>
        </table> 
};

declare function uiutil:create-row-toggle-button($qcId as xs:string)
as element(div)
{
    <div>
        <input id="toggleButton_{$qcId}" type="button" value="Show all records" onclick="onToggleButtonClick(this)"></input>
    </div>
};

declare function uiutil:create-data-table(
    $qc as element(qc),
    $columnsToDisplay as element(column)*, 
    $validationResult as element(result)
)
as element(table)
{
    <table id="datatable_{ string($qc/@id) }" class="dataTable">
        { uiutil:create-data-table-head($columnsToDisplay) }
        { uiutil:create-data-table-body($qc, $columnsToDisplay, $validationResult) }
    </table>
};

declare function uiutil:create-data-table-by-column-values(
    $qc as element(qc),
    $column as element(column),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(table)
{
    <table id="datatable_{ string($qc/@id) }" class="dataTable">
        { uiutil:create-data-table-head($columnsToDisplay) }
        <tbody> {
            let $columnName := meta:get-column-name($column)
            for $resultRow at $trIndex in $validationResult/rows/row
            let $trClass := concat(string($qc/@id), " ", uiutil:compose-class-name-by-column-values($resultRow, $column))
            return
                <tr class="{ $trClass }"> 
                    <td>{ uiutil:get-row-index($resultRow) }</td>
                {
                    let $flaggedColumnNames := $resultRow/flaggedColumns/flaggedColumn/column/meta:get-column-name(.)
                    for $displayColumn in $columnsToDisplay
                    let $displayColumnName := meta:get-column-name($displayColumn) 
                    return
                        if (not($displayColumnName = $flaggedColumnNames)) then
                            <td>{ uiutil:create-column-cell-value($resultRow, $displayColumn) }</td>
                        else
                            let $flaggedColumn := $resultRow/flaggedColumns/flaggedColumn[meta:get-column-name(./column) = $displayColumnName]
                            return
                                <td>
                                    { uiutil:create-flagged-column-cell-value($resultRow, $displayColumn, $flaggedColumn) }
                                </td>
                }           
                </tr>
        }
        { uiutil:try-generate-truncated-result-row($validationResult, count($columnsToDisplay) + 1) }
        </tbody>
    </table>
};

declare function uiutil:create-data-table-by-tag-values(
    $qc as element(qc),
    $columnsToDisplay as element(column)*,
    $tagCaption as xs:string,
    $validationResult as element(result)
)
as element(table)
{
    <table id="datatable_{ string($qc/@id) }" class="dataTable">
        { 
            let $columnsToDisplayWithTag := ( $columnsToDisplay,
                <column localName="{ $tagCaption }" />
            )
            return uiutil:create-data-table-head($columnsToDisplayWithTag) 
        }
        <tbody> {
            for $rowResult at $trIndex in $validationResult/rows/*
            let $tags := util:sort(
                distinct-values(
                    for $flaggedColumn in $rowResult/flaggedColumns/flaggedColumn
                    let $columnTag := for $tag in $flaggedColumn/@tag return string($tag)
                    let $valueTags := for $tag in $flaggedColumn/flaggedValues/value/@tag return string($tag) 
                    return ($columnTag, $valueTags)
                )
            )
            let $rowCssClass := concat(string($qc/@id), " ", string-join($tags, " "))
            let $tr := uiutil:create-data-table-body-row($qc, $columnsToDisplay, $rowResult, $rowCssClass)
            return
                <tr>
                    { $tr/@* }
                    { $tr/* }
                    <td>{ string-join($tags, ", ") }</td>
                </tr>
        }
        { uiutil:try-generate-truncated-result-row($validationResult, count($columnsToDisplay) + 1) }
        </tbody>
    </table>
};

declare function uiutil:create-data-table-head($columnsToDisplay as element(column)*)
as element(thead)
{
    <thead>
        <tr> 
            <th>Row</th>
            {
                for $column in $columnsToDisplay
                return <th>{ meta:get-column-name($column) }</th>
            }
        </tr>
    </thead>
};

declare function uiutil:create-data-table-body(
    $qc as element(qc),
    $columnsToDisplay as element(column)*, 
    $validationResult as element(result)
)
as element(tbody)
{
    <tbody> {
        for $rowResult at $trIndex in $validationResult/rows/*
        let $flaggedColumnNames := $rowResult/flaggedColumns/flaggedColumn/column/meta:get-column-name(.)
        let $trClassName := concat(string($qc/@id), " ", string-join($flaggedColumnNames, ' '))
        return uiutil:create-data-table-body-row($qc, $columnsToDisplay, $rowResult, $trClassName)
    }
    { uiutil:try-generate-truncated-result-row($validationResult, count($columnsToDisplay) + 1) }
    </tbody>
};

declare function uiutil:create-data-table-body-row(
    $qc as element(qc),
    $columnsToDisplay as element(column)*, 
    $rowResult as element(row),
    $rowCssClass as xs:string
)
as element(tr)
{
    <tr class="{$rowCssClass}">
        <td>{ uiutil:get-row-index($rowResult) }</td> 
        {
            for $column in $columnsToDisplay
            let $columnName := meta:get-column-name($column)
            let $flaggedColumn := $rowResult/flaggedColumns/flaggedColumn[column/meta:get-column-name(.) = $columnName]
            let $isNotFlagged := empty($flaggedColumn)
            return 
                if ($isNotFlagged) then
                    <td>{ uiutil:create-column-cell-value($rowResult, $column) }</td>
                else 
                    let $isColumnLevelFlag := not(empty($flaggedColumn/@level))
                    return
                        if ($isColumnLevelFlag) then
                            let $flaggedValueClass := qclevels:to-qc-color-class($flaggedColumn/@level)
                            return
                                <td class="{ $flaggedValueClass }"> {
                                    let $cellValue := uiutil:create-column-cell-value($rowResult, $column)
                                    return if ($cellValue = "") then "-empty-" else $cellValue
                                }
                                </td>
                        else
                            <td>{ uiutil:create-flagged-column-cell-value($rowResult, $column, $flaggedColumn) }</td>
        }
    </tr>
};

declare function uiutil:create-column-cell-value(
    $rowResult as element(row),
    $column as element(column)
)
as xs:string
{
    let $columnValues := data:get-row-values($rowResult/data/*[1], $column)
    return
        if (data:is-empty-value($columnValues)) then
            ""
        else if (count($columnValues) > 1) then
            let $delimiter := meta:get-column-multi-value-delimiter($column)
            return string-join($columnValues, $delimiter)
        else
            $columnValues[1]
};

declare function uiutil:create-flagged-column-cell-value(
    $rowResult as element(row),
    $column as element(column),
    $flaggedColumn as element(flaggedColumn) 
)
{    
    let $columnValues := data:get-row-values($rowResult/data/*[1], $column)
    return
        if (data:is-empty-value($columnValues)) then
            let $flaggedValues := $flaggedColumn/flaggedValues/value
            let $flaggedValueClass := qclevels:to-qc-color-class(xs:integer(max($flaggedValues/@level)))
                return
                    <span class="{ $flaggedValueClass }">-empty-</span>
        else
            let $columnValuesCount := count($columnValues)
            let $columnMultiValueDelimiter := meta:get-column-multi-value-delimiter($column)
            return
                for $columnValue at $valuePosition in $columnValues
                let $flaggedValues := $flaggedColumn/flaggedValues/value[text() = $columnValue]
                let $isNotFlaggedValue := empty($flaggedValues)
                return (
                    if ($isNotFlaggedValue) then
                        <span>{ $columnValue }</span>
                    else
                        let $flaggedValueClass := qclevels:to-qc-color-class(xs:integer(max($flaggedValues/@level)))
                        return
                            <span class="{ $flaggedValueClass }">{ $columnValue }</span>
                    ,
                    if ($valuePosition < $columnValuesCount) then $columnMultiValueDelimiter else ()
                )
};

declare function uiutil:compose-class-name-by-column-values(
    $validationRow as element(row),
    $column as element(column)
)
as xs:string
{
    let $dataRow := $validationRow/data/*
    let $rowValues := 
        for $value in data:get-row-values($dataRow, $column)
        return uiutil:strip-white-chars($value)
    return string-join($rowValues, " ")
};

declare function uiutil:strip-white-chars($value as xs:string)
as xs:string
{
    replace($value, '\s', '--~~--')
};

declare function uiutil:compose-group-class-name-of-group($group as element(group), $groupColumns as element(column)*)
as xs:string
{
    let $values := 
        for $groupColumn in $groupColumns
        let $columnName := meta:get-column-name($groupColumn)
        let $value := string($group/columns/column[@name = $columnName]/value) 
        return uiutil:strip-white-chars($value)
    return string-join($values, "_")
};

declare function uiutil:compose-group-class-name-of-data-row($dataRow as element(dataRow), $groupColumns as element(column)*)
as xs:string
{
    let $values := 
        for $groupColumn in $groupColumns
        let $value := data:get-row-values-as-string($dataRow, $groupColumn)
        return uiutil:strip-white-chars($value)
    return string-join($values, "_")
};

declare function uiutil:get-row-index($resultRow as element(row))
as xs:integer
{
    data:get-row-index($resultRow/data/*)
};

declare function uiutil:try-generate-truncated-result-row($validationResult as element(result), $columnCount as xs:integer)
as element(tr)?
{
    if (vldres:is-truncated-result($validationResult)) then
        <tr class="eionet_qc_result_set_truncated">
            <td colspan="{ $columnCount }">
                <span>Record set was truncated because it has exceeded maximum displayable size.</span>
            </td>
        </tr>
    else
        ()
};




declare function uiutil:_create-generic-validation-result($rows as element(row)*) as element(result)
{
    <result truncated="false">
        <rows>
            {$rows}
        </rows>
    </result>
};


declare function uiutil:_create-generic-flagged-row($row as element(dataRow), $columns as element(column)*, $level as xs:integer) as element(row)
{
    let $wrColumns := for $c in $columns
    return <flaggedColumn level="{$level}">
        {$c}
    </flaggedColumn>
    return
        <row>
            <data>
                {$row}
            </data>
            <flaggedColumns>
                {$wrColumns}
            </flaggedColumns>
        </row>
};

declare function uiutil:_create-generic-column($cn as xs:string*) as element(column)*{
    for $c in $cn
    return
        <column name="{ $c }"
        localName="{ $c }"/>
};

declare function uiutil:build-generic-qc-table(
        $qc as element(qc),
        $columnsToDisplay as element()*,
        $validationResult as element()
)
as element(div)
{
    let $qcLevel := vldres:get-qc-level($validationResult)
    let $qcId := $qc/@id
    let $pass := $qcLevel = $qclevels:OK
    let $event := qclevels:to-qc-event($qc, $qcLevel)
    return
        <div id="{$qcId}" class="{ uiutil:create-section-class($qcLevel) }">
            { uiutil:create-section-heading($qc) }
            { uiutil:create-section-description($qc) }
            { uiutil:create-section-summary($event) }
            {
                if ($pass) then
                    ()
                else
                    <div class="qcDetails">
                        { uiutil:create-record-count($validationResult) }
                        { uiutil:create-row-toggle-button($qcId) }
                        <div id="dataarea_{ $qcId }" style="display: none;">
                            { uiutil:create-data-table($qc, $columnsToDisplay, $validationResult) }
                        </div>
                    </div>
            }
        </div>
};