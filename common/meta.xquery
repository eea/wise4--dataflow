xquery version "1.0" encoding "UTF-8";

module namespace meta = 'http://converters.eionet.europa.eu/common/meta';

import module namespace rdfutil = 'http://converters.eionet.europa.eu/common/rdfutil' at './rdf-util.xquery';

declare namespace dd = 'http://dd.eionet.europa.eu';
declare namespace ddrdf="http://dd.eionet.europa.eu/schema.rdf#";

declare variable $meta:_DD-TABLE-SCHEMA-URL as xs:string := 'http://dd.eionet.europa.eu/GetSchema?id=TBL';
declare variable $meta:_DD-TABLE-CONTAINER-URL as xs:string := 'http://dd.eionet.europa.eu/GetContainerSchema?id=TBL';
declare variable $meta:_DD-TABLE-CODELISTS-URL as xs:string := 'http://dd.eionet.europa.eu/codelists/tables/';

declare variable $meta:_VALUELIST-FIXED as xs:string := "fixed";
declare variable $meta:_VALUELIST-SUGGESTED as xs:string := "quantitative";
declare variable $meta:_VALUELIST-VOCABULARY as xs:string := "vocabulary";

declare function meta:get-table-metadata($tableId as xs:string)
as element(model)
{
    meta:get-table-metadata($tableId, (), ())
};

declare function meta:get-table-metadata($tableId as xs:string, $vocabularies as element()*, $vocabularyColumns as xs:string*) 
as element(model)
{
    let $tableSchema := doc(concat($meta:_DD-TABLE-SCHEMA-URL, $tableId))/xs:schema
    let $tableContainer := doc(concat($meta:_DD-TABLE-CONTAINER-URL, $tableId))/xs:schema
    let $codelists := doc(concat($meta:_DD-TABLE-CODELISTS-URL, $tableId, "/xml"))/dd:value-lists
    let $tablePrimaryKeys := $tableSchema//xs:key[@name = 'PK_Row_ID']/xs:field/@xpath
    return 
        <model>
            <columns> {
                for $schemaElement in $tableSchema//xs:element[@name = "Row"]/xs:complexType/xs:sequence/xs:element
                let $name := string($schemaElement/@ref)
                let $localName := substring-after($name, ":")
                let $isMandatory := "1" = string($schemaElement/@minOccurs)
                let $minOccurs := string($schemaElement/@minOccurs)
                let $maxOccurs := string($schemaElement/@maxOccurs)
                let $isPrimaryKey := $name = $tablePrimaryKeys
                let $containerElement := $tableContainer/xs:element[@name = $localName]
                let $dataType := meta:_get-element-type($containerElement, $localName)
                let $restrictions := meta:_get-element-restrictions($containerElement, $localName)
                let $valueList := meta:_get-element-valuelist($codelists, $localName, $vocabularies, $vocabularyColumns)
                let $multiValueDelimiter := string($schemaElement/@ddrdf:multiValueDelim)
                return
                    <column name="{ $name }" 
                            localName="{ $localName  }"
                            mandatory="{ $isMandatory }" 
                            dataType="{ $dataType }" 
                            primaryKey="{ $isPrimaryKey }"
                            minOccurs="{ $minOccurs }"
                            maxOccurs="{ $maxOccurs }"
                            multiValueDelimiter="{ $multiValueDelimiter }">
                        { $restrictions }
                        { $valueList }
                    </column>
            }
            </columns>
        </model>
};

declare function meta:get-mandatory-columns($model as element(model))
as element(column)*
{
    $model/columns/column[@mandatory = true()]
};

declare function meta:get-primary-key-columns($model as element(model))
as element(column)*
{
    $model/columns/column[meta:is-primary-key-column(.)]
};

declare function meta:get-valuelist-columns($model as element(model))
as element(column)*
{
    $model/columns/column[meta:is-valuelist-column(.)]
};

declare function meta:get-column-by-name($model as element(model), $columnName as xs:string)
as element(column)
{
    meta:get-columns-by-names($model, ($columnName))
};

declare function meta:get-columns-by-names($model as element(model), $columnNames as xs:string*)
as element(column)*
{
    $model/columns/column[meta:get-column-name(.) = $columnNames]
}; 

declare function meta:get-column-name($column as element(column))
as xs:string
{
    string($column/@localName)
};

declare function meta:get-column-max-occurs($column as element(column))
as xs:integer
{
    let $maxOccurs := string($column/@maxOccurs)
    return
        if ($maxOccurs castable as xs:integer) then
            xs:integer($maxOccurs)
        else
            -1
};

declare function meta:is-mandatory-column($column as element(column))
as xs:boolean
{
    not(empty($column[@mandatory = true()]))
};

declare function meta:is-primary-key-column($column as element(column))
as xs:boolean
{
    not(empty($column[@primaryKey = true()]))
};

declare function meta:is-valuelist-column($column as element(column))
as xs:boolean
{
    not(empty($column/valueList))
};

declare function meta:get-column-multi-value-delimiter($column as element(column))
as xs:string
{
     meta:get-column-multi-value-delimiter($column, " ")
};

declare function meta:get-column-multi-value-delimiter($column as element(column), $defaultDelimiter as xs:string)
as xs:string
{
    let $delimiter := string($column/@multiValueDelimiter)
    return 
        if ($delimiter = "") then
            $defaultDelimiter
        else
            $delimiter
};

declare function meta:is-fixed-valuelist($valuelist as element(valueList))
as xs:boolean
{
    not(empty($valuelist[@type = $meta:_VALUELIST-FIXED]))
};

declare function meta:is-suggested-valuelist($valuelist as element(valueList))
as xs:boolean
{
    not(empty($valuelist[@type = $meta:_VALUELIST-SUGGESTED]))
};

declare function meta:is-vocabulary-valuelist($valuelist as element(valueList))
as xs:boolean
{
    not(empty($valuelist[@type = $meta:_VALUELIST-VOCABULARY]))
};

declare function meta:_get-element-type($containerElement as element(xs:element), $elementLocalName)
as xs:string
{
    let $hasTypeAttribute := string($containerElement/@type) != ""
    let $xmlType := 
        if ($hasTypeAttribute = true()) then
            string($containerElement/@type)
        else 
            string($containerElement/xs:simpleType/xs:restriction/@base)
    return 
        if (contains($xmlType, ":")) then 
            substring-after($xmlType, ":") 
        else 
            $xmlType
};

declare function meta:_get-element-restrictions($containerElement as element(xs:element), $elementLocalName)
as element(restrictions)*
{
    let $restrictions := $containerElement/xs:simpleType/xs:restriction/*[local-name(.) != "enumeration"]
    return 
        if (empty($restrictions)) then
            ()
        else
            <restrictions> {
                for $restriction in $restrictions
                return 
                    <restriction name="{ local-name($restriction) }" value="{ string($restriction/@value) }" />
            }
            </restrictions>
};

declare function meta:_get-element-valuelist(
    $valueLists as element(dd:value-lists),
    $elementLocalName as xs:string,
    $vocabularies as element()*,
    $vocabularyColumns as xs:string*
)
as element(valueList)*
{
    if ($elementLocalName = $vocabularyColumns) then
        let $vocabularyIndex := fn:index-of($vocabularyColumns, $elementLocalName)
        return
            <valueList type="{ $meta:_VALUELIST-VOCABULARY }"> {
                for $concept in rdfutil:concepts($vocabularies[$vocabularyIndex])
                let $code := rdfutil:notation($concept)
                return 
                    <value code="{ $code }" />
            }
            </valueList>
    else
        let $elementValueLists := $valueLists/dd:value-list[@element = $elementLocalName]
        for $elementValueList in $elementValueLists
        let $valuelistType := string($elementValueList/@type)
        return
            <valueList type="{ $valuelistType }"> {
                for $value in $elementValueList/dd:value
                let $code := string($value/@code)
                return 
                    <value code="{ $code }" />
            }
            </valueList>
};
