xquery version "1.0" encoding "UTF-8";

module namespace vldwqlbioeqrcpbvmath = 'http://converters.eionet.europa.eu/wise/waterQuality/biologyEqrClassificationProcedure/validators/boundaryValuesMathRules';

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../../common/data.xquery';
import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';

declare function vldwqlbioeqrcpbvmath:validate-boundary-values-math-rules(
    $model as element(model),
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $columnParameterBoundaryValueClasses12 := meta:get-column-by-name($model, "parameterBoundaryValueClasses12")
    let $columnParameterBoundaryValueClasses23 := meta:get-column-by-name($model, "parameterBoundaryValueClasses23")
    let $columnParameterBoundaryValueClasses34 := meta:get-column-by-name($model, "parameterBoundaryValueClasses34")
    let $columnParameterBoundaryValueClasses45 := meta:get-column-by-name($model, "parameterBoundaryValueClasses45")
    let $resultRows := vldwqlbioeqrcpbvmath:_validate(
        $columnParameterBoundaryValueClasses12, $columnParameterBoundaryValueClasses23,
        $columnParameterBoundaryValueClasses34, $columnParameterBoundaryValueClasses45,
        $dataRows, 1, ()
    )
    let $tagCounts := vldres:calculate-tag-value-counts($resultRows)
    return vldres:create-result($resultRows, $tagCounts)
};

declare function vldwqlbioeqrcpbvmath:_validate(
    $columnParameterBoundaryValueClasses12 as element(column),
    $columnParameterBoundaryValueClasses23 as element(column),
    $columnParameterBoundaryValueClasses34 as element(column),
    $columnParameterBoundaryValueClasses45 as element(column),
    $dataRows as element(dataRow)*,
    $dataRowIndex as xs:integer,
    $resultRows as element(row)*
)
as element(row)*
{
    if ($dataRowIndex > count($dataRows)) then
        $resultRows
    else if (count($resultRows) >= $vldres:MAX_RECORD_RESULTS) then
        ($resultRows, vldres:create-truncation-row())
    else
        let $dataRow := $dataRows[$dataRowIndex]
        let $rowResult := vldwqlbioeqrcpbvmath:_validate-data-row(
            $columnParameterBoundaryValueClasses12, $columnParameterBoundaryValueClasses23,
            $columnParameterBoundaryValueClasses34, $columnParameterBoundaryValueClasses45, $dataRow
        )
        let $newResultRows :=
            if (empty($rowResult)) then
                $resultRows
            else
                ($resultRows, $rowResult)
        return vldwqlbioeqrcpbvmath:_validate(
            $columnParameterBoundaryValueClasses12, $columnParameterBoundaryValueClasses23,
            $columnParameterBoundaryValueClasses34, $columnParameterBoundaryValueClasses45,
            $dataRows, $dataRowIndex + 1, $newResultRows
        )
};

declare function vldwqlbioeqrcpbvmath:_validate-data-row(
    $columnParameterBoundaryValueClasses12 as element(column),
    $columnParameterBoundaryValueClasses23 as element(column),
    $columnParameterBoundaryValueClasses34 as element(column),
    $columnParameterBoundaryValueClasses45 as element(column),
    $dataRow as element(dataRow)
)
as element(row)?
{
    let $parameterBoundaryValueClasses12 := datax:get-row-decimal-value($dataRow, $columnParameterBoundaryValueClasses12)
    let $parameterBoundaryValueClasses23 := datax:get-row-decimal-value($dataRow, $columnParameterBoundaryValueClasses23)
    let $parameterBoundaryValueClasses34 := datax:get-row-decimal-value($dataRow, $columnParameterBoundaryValueClasses34)
    let $parameterBoundaryValueClasses45 := datax:get-row-decimal-value($dataRow, $columnParameterBoundaryValueClasses45)
    
    let $ruleResults := (
        vldwqlbioeqrcpbvmath:_create-rule-result(
            "01",
            vldwqlbioeqrcpbvmath:_is-valid-rule-01($parameterBoundaryValueClasses12, $parameterBoundaryValueClasses23), 
            ($columnParameterBoundaryValueClasses12, $columnParameterBoundaryValueClasses23)
        ),
        vldwqlbioeqrcpbvmath:_create-rule-result(
            "02",
            vldwqlbioeqrcpbvmath:_is-valid-rule-02($parameterBoundaryValueClasses23, $parameterBoundaryValueClasses34),
            ($columnParameterBoundaryValueClasses23, $columnParameterBoundaryValueClasses34)
        ),
        vldwqlbioeqrcpbvmath:_create-rule-result(
            "03",
            vldwqlbioeqrcpbvmath:_is-valid-rule-03($parameterBoundaryValueClasses34, $parameterBoundaryValueClasses45),
            ($columnParameterBoundaryValueClasses34, $columnParameterBoundaryValueClasses45)
        )
    )
    
    let $columns := (
        $columnParameterBoundaryValueClasses12, $columnParameterBoundaryValueClasses23, 
        $columnParameterBoundaryValueClasses34, $columnParameterBoundaryValueClasses45   
    )
    let $flaggedColumns :=
        for $column in $columns
        let $columnName := meta:get-column-name($column)
        let $ruleIds := $ruleResults[@success = false()][column[text() = $columnName]]/@id
        let $columnValue := data:get-row-values($dataRow, $column)[1]
        let $flaggedValues :=
            for $ruleId in $ruleIds
            return vldres:create-flagged-value($qclevels:WARNING, $columnValue, $ruleId)
        where not(empty($flaggedValues))
        return vldres:create-flagged-column-by-values($column, $flaggedValues)
    return
        if (empty($flaggedColumns)) then
            ()
        else
            vldres:create-result-row($dataRow, $flaggedColumns)
};


declare function vldwqlbioeqrcpbvmath:_create-rule-result($ruleId as xs:string, $isSuccess as xs:boolean, $columns as element(column)*)
as element(ruleResult)
{
    <ruleResult id="{ $ruleId }" success="{ $isSuccess }"> {
        for $column in $columns
        return 
            <column>{ meta:get-column-name($column) }</column>
    }
    </ruleResult>
};

(: parameterBoundaryValueClasses12 > parameterBoundaryValueClasses23 :)
declare function vldwqlbioeqrcpbvmath:_is-valid-rule-01($parameterBoundaryValueClasses12 as xs:decimal?, $parameterBoundaryValueClasses23 as xs:decimal?)
as xs:boolean
{
    empty($parameterBoundaryValueClasses12) or empty($parameterBoundaryValueClasses23)
        or $parameterBoundaryValueClasses12 > $parameterBoundaryValueClasses23
};

(: parameterBoundaryValueClasses23 > parameterBoundaryValueClasses34 :)
declare function vldwqlbioeqrcpbvmath:_is-valid-rule-02($parameterBoundaryValueClasses23 as xs:decimal?, $parameterBoundaryValueClasses34 as xs:decimal?)
as xs:boolean
{
    empty($parameterBoundaryValueClasses23) or empty($parameterBoundaryValueClasses34)
        or $parameterBoundaryValueClasses23 > $parameterBoundaryValueClasses34
};

(: parameterBoundaryValueClasses34 > parameterBoundaryValueClasses45 :)
declare function vldwqlbioeqrcpbvmath:_is-valid-rule-03($parameterBoundaryValueClasses34 as xs:decimal?, $parameterBoundaryValueClasses45 as xs:decimal?)
as xs:boolean
{
    empty($parameterBoundaryValueClasses34) or empty($parameterBoundaryValueClasses45)
        or $parameterBoundaryValueClasses34 > $parameterBoundaryValueClasses45
};
