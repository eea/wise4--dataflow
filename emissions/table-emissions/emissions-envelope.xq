xquery version "1.0" encoding "UTF-8";

declare namespace xmlconv = "http://converters.eionet.europa.eu/wise-soe/emissions";
declare namespace dd791 = "http://dd.eionet.europa.eu/namespace.jsp?ns_id=791";
declare namespace dd814 = "http://dd.eionet.europa.eu/namespace.jsp?ns_id=814";
declare namespace dd815 = "http://dd.eionet.europa.eu/namespace.jsp?ns_id=815";
declare namespace constants = "http://converters.eionet.europa.eu/wise-soe/constants";
declare namespace ddutil = "http://converters.eionet.europa.eu/wise-soe/ddutil";
declare namespace rdfutil = "http://converters.eionet.europa.eu/wise-soe/rdfutil";
declare namespace errors = "http://converters.eionet.europa.eu/wise-soe/errors";
declare namespace functx = "http://www.functx.com";
declare namespace locale = "http://converters.eionet.europa.eu/dataflows/locale";
declare namespace maps = "http://converters.eionet.europa.eu/dataflows/model/maps";
declare namespace model = "http://converters.eionet.europa.eu/wise-soe/model";
declare namespace types = "http://converters.eionet.europa.eu/wise-soe/types";
declare namespace ruleutil = "http://converters.eionet.europa.eu/wise-soe/ruleutil";
declare namespace schema = "http://converters.eionet.europa.eu/wise-soe/schema";
declare namespace html = "http://converters.eionet.europa.eu/wise-soe/html";
declare namespace tables = "http://converters.eionet.europa.eu/dataflows/ui/tables";
declare namespace uiutil = "http://converters.eionet.europa.eu/wise-soe/uiutil";
declare namespace common = "http://converters.eionet.europa.eu/wise-soe/common";
declare namespace envelope-common = "http://converters.eionet.europa.eu/wise-soe/validators/envelope-common";
declare namespace validatorutil = "http://converters.eionet.europa.eu/wise-soe/validatorutil";
declare namespace validators = "http://converters.eionet.europa.eu/wise-soe/validators";
declare namespace validators-extra = "http://converters.eionet.europa.eu/dataflows/validators/extra";
declare namespace xmlutil = "http://converters.eionet.europa.eu/wise-soe/xmlutil";
declare namespace adms = "http://www.w3.org/ns/adms#";
declare namespace sparql = "http://www.w3.org/2005/sparql-results#";
declare namespace dd = "http://dd.eionet.europa.eu";
declare namespace ddrdf="http://dd.eionet.europa.eu/schema.rdf#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace property = "http://dd.eionet.europa.eu/property/";

declare variable $xmlconv:TEST_ENV := false();

declare variable $constants:DETERMINANDS_URL as xs:string := "http://dd.eionet.europa.eu/vocabulary/wise/determinandCodes";
declare variable $constants:COMBINATIONDETERMINANDUOM_URL as xs:string:= "http://dd.eionet.europa.eu/vocabulary/wise/QCCombinationTableDeterminandUom";
declare variable $constants:LIMITS_URL as xs:string := "http://converters.eionet.europa.eu/xmlfile/wise_soe_determinand_value_limits.xml";
declare variable $constants:CYCLES_URL as xs:string := "http://converters.eionet.europa.eu/xmlfile/dataflow_cycles.xml";
declare variable $constants:MONITORINGSITES_URL as xs:string := "http://dd.eionet.europa.eu/vocabulary/wise/MonitoringSite";
declare variable $constants:INSPIRE_STATUS_VALID := "http://inspire.ec.europa.eu/registry/status/valid";
declare variable $rdfutil:STATUS_VALID := "http://dd.eionet.europa.eu/vocabulary/datadictionary/status/valid";
declare variable $rdfutil:UOM_RDF_URL := "http://dd.eionet.europa.eu/vocabulary/wise/Uom/rdf";
declare variable $rdfutil:COMBINATIONDETERMINANDUOM_RDF_URL := "http://dd.eionet.europa.eu/vocabulary/wise/QCCombinationTableDeterminandUom/rdf";
declare variable $rdfutil:DETERMINANDS_RDF_URL := "http://dd.eionet.europa.eu/vocabulary/wise/ObservedProperty/rdf";
declare variable $errors:INVALID_NUMBER as xs:integer := -99999;
declare variable $errors:INVALID_BOOLEAN as xs:string := "##INVALID_BOOLEAN##";
declare variable $errors:OK_LEVEL as xs:integer := 0;
declare variable $errors:UNKNOWN_LEVEL as xs:integer := 1;
declare variable $errors:EXCEPTION_LEVEL as xs:integer := 2;
declare variable $errors:WARNING_LEVEL as xs:integer := 3;
declare variable $errors:ERROR_LEVEL as xs:integer := 4;
declare variable $errors:BLOCKER_LEVEL as xs:integer := 5;
declare variable $model:DATASET_SEPARATOR := ".";
declare variable $model:GROUP_SEPARATOR := "##";
declare variable $model:HASHMAP_SEPARATOR := "##";
declare variable $model:CSV_SEPARATOR := ", ";
declare variable $types:VALID_STATUS := "http://dd.eionet.europa.eu/vocabulary/datadictionary/status/valid";
declare variable $schema:ENVELOPE_SCHEMA := "http://cdr.eionet.europa.eu/schemas/envelope-metadata.xsd";
declare variable $tables:SUMMARY as xs:string := "SUMMARY";
declare variable $tables:RESULT as xs:string := "RESULT";
declare variable $tables:ADDITIONAL as xs:string := "ADDITIONAL";
declare variable $tables:SUMMARY_NULL_TABLE as xs:integer := -1;
declare variable $tables:SUMMARY_EMPTY_TABLE as xs:integer := 0;
declare variable $tables:SUMMARY_SIMPLE_TABLE as xs:integer := 1;
declare variable $tables:SUMMARY_MANDATORY as xs:integer := 2;
declare variable $tables:SUMMARY_DUPLICATES as xs:integer := 3;
declare variable $tables:SUMMARY_DATATYPES as xs:integer := 4;
declare variable $tables:SUMMARY_CODELIST as xs:integer := 5;
declare variable $tables:SUMMARY_MONITORINGFORMAT as xs:integer := 6;
declare variable $tables:SUMMARY_MONITORINGREFERENCE as xs:integer := 7;
declare variable $tables:SUMMARY_UNITOFMEASURE as xs:integer := 8;
declare variable $tables:SUMMARY_REFERENCEYEAR as xs:integer := 9;
declare variable $tables:SUMMARY_SAMPLINGPERIOD as xs:integer := 10;
declare variable $tables:SUMMARY_VALUESLIMITS as xs:integer := 11;
declare variable $tables:SUMMARY_MATHEMATICALRELATION as xs:integer := 12;
declare variable $tables:SUMMARY_LOQ as xs:integer := 13;
declare variable $tables:SUMMARY_SAMPLEDEPTH as xs:integer := 14;
declare variable $tables:RESULT_SIMPLE as xs:integer := 100;
declare variable $tables:RESULT_MANDATORY as xs:integer := 101;
declare variable $tables:RESULT_DUPLICATES as xs:integer := 102;
declare variable $tables:RESULT_DATATYPES as xs:integer := 103;
declare variable $tables:RESULT_CODELIST as xs:integer := 104;
declare variable $tables:RESULT_MONITORINGFORMAT as xs:integer := 105;
declare variable $tables:RESULT_MONITORINGREFERENCE as xs:integer := 106;
declare variable $tables:RESULT_UNITOFMEASURE as xs:integer := 107;
declare variable $tables:RESULT_REFERENCEYEAR as xs:integer := 108;
declare variable $tables:RESULT_SAMPLINGPERIOD as xs:integer := 109;
declare variable $tables:RESULT_VALUESLIMITS as xs:integer := 110;
declare variable $tables:RESULT_MATHEMATICALRELATION as xs:integer := 111;
declare variable $tables:RESULT_LOQ as xs:integer := 112;
declare variable $tables:RESULT_SAMPLEDEPTH as xs:integer := 113;
declare variable $tables:ADDITIONAL_DATATYPES as xs:integer := 201;
declare variable $tables:ADDITIONAL_CODELIST as xs:integer := 202;
declare variable $tables:ADDITIONAL_VALUELIMITS as xs:integer := 203;
declare variable $xmlutil:TEST_ENV as xs:boolean := false();
declare variable $xmlutil:INSPIRE_STATUS_VALID := "http://inspire.ec.europa.eu/registry/status/valid";
declare variable $xmlutil:MIN_DATATYPE_EXCEPTION_VALUE := -3;
declare variable $xmlutil:MISSING_VALUE_LABEL as xs:string :=  "-empty-";
declare variable $xmlutil:CR_SPARQL_URL as xs:string := "http://cr.eionet.europa.eu/sparql";
declare variable $xmlutil:LIST_ITEM_SEP as xs:string := "##";
declare variable $xmlutil:MIN_MAX_URL as xs:string := "http://converters.eionet.europa.eu/xmlfile/stations-min-max.xml";
declare variable $xmlutil:EU_MIN_X as xs:integer := -32;
declare variable $xmlutil:EU_MIN_Y as xs:integer := 27;
declare variable $xmlutil:EU_MAX_X as xs:integer := 33;
declare variable $xmlutil:EU_MAX_Y as xs:integer := 72;
declare variable $xmlutil:ALLOWED_BOOLEAN_VALUES as xs:string* := ("true", "false", "1", "0", "y", "n", "yes", "no", "-1");
declare variable $xmlutil:EU_COUNTRIES := ("AT", "BE", "BG", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT", "RO", "SK", "SI", "ES", "SE", "GB");
declare variable $xmlutil:DISPLAY_ELEMENTS_XML := "http://converters.eionet.europa.eu/xmlfile/AutomaticQA_water_FieldsToDisplayInResults.xml";
declare variable $xmlutil:MAX_VALID_YEAR as xs:integer := 2015;
declare variable $xmlutil:MIN_VALID_YEAR as xs:integer := 1800;
declare variable $xmlutil:RESULT_TYPE_MINIMAL := "minimal";
declare variable $xmlutil:RESULT_TYPE_TABLE := "table";
declare variable $xmlutil:RESULT_TYPE_TABLE_CODES := "table-codes";
declare variable $xmlutil:SOURCE_URL_PARAM := "source_url=";
declare variable $xmlutil:CODELIST_ELEMS_WITH_SHORT_DESC := ("DeterminandBiology", "UnitBiology", "MetricScale");



declare variable $constants:OBSERVEDPROPERTY_URL as xs:string := "http://dd.eionet.europa.eu/vocabulary/wise/ObservedProperty/";




declare variable $constants:DDLINKS as element() :=
<Datasets>
	<Dataset name="Wise-SOE">
		<Table name="AggregatedData">
			<Element link="http://dd.eionet.europa.eu/fixedvalues/elem/75870">monitoringSiteIdentifierScheme</Element>
			<Element link="http://dd.eionet.europa.eu/vocabulary/wise/WFDWaterBodyCategory/view">parameterWaterBodyCategory</Element>
			<Element link="http://dd.eionet.europa.eu/vocabulary/wise/ObservedProperty/view">observedPropertyDeterminandCode</Element>
			<Element link="http://dd.eionet.europa.eu/fixedvalues/elem/75921">procedureAnalysedFraction</Element>
			<Element link="http://dd.eionet.europa.eu/fixedvalues/elem/75920">procedureAnalysedMedia</Element>
			<Element link="http://dd.eionet.europa.eu/vocabulary/wise/Uom/view">resultUom</Element>
			<Element link="http://dd.eionet.europa.eu/fixedvalues/elem/75897">resultQualityMinimumBelowLOQ</Element>
			<Element link="http://dd.eionet.europa.eu/fixedvalues/elem/75898">resultQualityMeanBelowLOQ</Element>
			<Element link="http://dd.eionet.europa.eu/fixedvalues/elem/75900">resultQualityMaximumBelowLOQ</Element>
			<Element link="http://dd.eionet.europa.eu/fixedvalues/elem/75899">resultQualityMedianBelowLOQ</Element>
			<Element link="http://dd.eionet.europa.eu/fixedvalues/elem/77669">resultObservationStatus</Element>
		</Table>
	</Dataset>
</Datasets>;

(:
 : ======================================================================
 :    DD HELPER methods: methods for quering data from Data Dictionary
 : ======================================================================
 :)



(: Get DD XML Schema - Intends to deprecate the other functions :)
declare function ddutil:getSchemaFromDocument($document as document-node()) {
    let $url := tokenize($document/child::*[1]/@xsi:schemaLocation, " ")[last()]
    let $url :=
        if (empty($url)) then
            tokenize($document/child::*[1]/@xsi:noNamespaceSchemaLocation, " ")[last()]
        else $url
    return
        if (doc-available($url)) then
            doc($url)
        else
            ()
};

(: Get DD XML Schema Container - Intends to deprecate the other functions :)
declare function ddutil:getSchemaContainerFromSchema($schema as document-node()) {
    let $url := tokenize($schema/child::*[1]/xs:import/@schemaLocation, " ")[last()]
    return
        if (doc-available($url)) then
            doc($url)
        else
            ()
};
(: Get Table ID from Schema :)
declare function ddutil:getSchemaId($schema as document-node()) {
    let $url := tokenize($schema/child::*[1]/xs:import/@schemaLocation, " ")[last()]
    return substring-after($url, "TBL")
};

(:~
 : Get DD XML Schema URL for given ID.
 : @param schemaId DD table ID
 : @return URL
 :)
declare function ddutil:getDDSchemaUrl($schemaId as xs:string) as xs:string {
    concat("http://dd.eionet.europa.eu/GetSchema?id=TBL", $schemaId)
};
(:~
 : Get DD table URL for given ID.
 : @param schemaId DD table ID
 : @return URL
 :)
declare function ddutil:getDDTableUrl($schemaId as xs:string) as xs:string {
    concat("http://dd.eionet.europa.eu/tables/", $schemaId)
};
(:~
 : Get DD Dataset URL for given ID.
 : @param $datasetId DD dataset ID
 : @return URL
 :)
declare function ddutil:getDDDatasetUrl($datasetId as xs:string) as xs:string {
    concat("http://dd.eionet.europa.eu/datasets/", $datasetId)
};

(:~
 : Get DD Elements XML Schema URL for given ID.
 : @param schemaId DD table ID
 : @return URL
 :)
declare function ddutil:getDDSchemaContainerUrl($schemaId as xs:string) as xs:string {
    concat("http://dd.eionet.europa.eu/GetContainerSchema?id=TBL",$schemaId)
};
(:~
 : Get DD table code list values XML  URL
 : @param schemaId DD table ID
 : @return URL
 :)
declare function ddutil:getDDCodelistXmlUrl($schemaId as xs:string) as xs:string {
    concat("http://dd.eionet.europa.eu/codelists/tables/", $schemaId, "/xml")
};

declare function ddutil:getDDTableCodelists($url as xs:string) as element(dd:value-lists)? {
    if (doc-available($url)) then
        doc($url)/dd:value-lists
    else
        ()
};

(:~
 : Fetches XML schema
 : @param schemaUrl Schema location
 : @return Schema XML
 :)
declare function ddutil:getSchema($schemaUrl as xs:string) as document-node() {
    if (doc-available($schemaUrl)) then
        doc($schemaUrl)
    else
        ()
};
declare function ddutil:getSchemaContainer($schemaUrl as xs:string) as document-node() {
    if (doc-available($schemaUrl)) then
        doc($schemaUrl)
    else
        ()
};

(:~
 : Extract all elements from XML Schema.
 : @param schemaUrl URL of XML Schema
 : @return the list of manadatory XML element names.
 :)
declare function ddutil:getAllElements($schemaUrl as xs:string) as xs:string* {
    fn:doc($schemaUrl)//xs:element[@name="Row"]/xs:complexType/xs:sequence/xs:element/string(@ref)
};

(:~
 : Extract all elements with fixed values.
 : @param codeListXmlUrl URL of XML with code list elements
 : @return the list of manadatory XML element names.
 :)
declare function ddutil:getCodeListElements($codeListXmlUrl as xs:string) as xs:string* {
    fn:doc($codeListXmlUrl)//dd:value-list/@element
};

declare function ddutil:getCodelistElementsCSV($codelists) as xs:string {
    let $elems :=
        for $elem in $codelists/dd:value-list/@element
            return common:getElemNameWithoutNs($elem)
    return
        string-join($elems, ", ")
};
(:~
 : Extract all elements with suggested values.
 : @param codeListXmlUrl URL of XML with code list elements
 : @return the list of manadatory XML element names.
 :)
declare function ddutil:getSuggestedCodeListElements($valueList as element(dd:value-lists)) as xs:string* {
    $valueList/dd:value-list[count(@fixed)=0]/@element
};
(:~
 : Extract all mandatory elements from XML Schema. Mandatory element minOccurs=1.
 : @param schemaUrl URL of XML Schema
 : @return the list of manadatory XML element names.
 :)
declare function ddutil:getMandatoryElements($schemaUrl as xs:string) as xs:string* {
    for $element in fn:doc($schemaUrl)//xs:element[@name="Row"]/xs:complexType/xs:sequence/xs:element[@minOccurs=1]
    return
        string($element/@ref)
};
(:~
 : Extract all elements with mulitvalues
 : @param schemaId DD table ID
 : @return the mapping between elements and their delimiters
 :)
declare function ddutil:getMultivalueElements($schemaId as xs:string) as xs:string* {
    for $element in fn:doc(ddutil:getDDSchemaUrl($schemaId))//xs:element[@name="Row"]/xs:complexType/xs:sequence/xs:element[count(@ddrdf:multiValueDelim) > 0]
    return
        maps:createHashMapEntry(fn:substring-after($element/@ref, ":"), fn:data($element/@ddrdf:multiValueDelim))
};
(:~
 : Define elements with multivalues.
 : @param $multiValueDelimiters list of multivalue elements and their delimiters
 : @param $elemName Element name which has suggested values.
 : @return the list of suggested values.
 :)
declare function ddutil:getMultiValueDelim($multiValueDelimiters as xs:string*, $elemName as xs:string) as xs:string {
    let $elemName := if ( fn:contains($elemName, ":")) then fn:substring-after($elemName, ":") else $elemName
    return
        if (fn:not(fn:empty(fn:index-of(maps:getHashMapKeys($multiValueDelimiters), $elemName)))) then
            maps:getHashMapValue($multiValueDelimiters, $elemName)[1]
        else
            ""
};

(:~
 : Get DD Elements XML Schema PK Element for given ID.
 : @param schemaId DD table ID
 : @return PK element name(s)
 :)
declare function ddutil:getDDElemPKFields($schemaId as xs:string) as xs:string* {
    let $shemaDoc := ddutil:getDDSchemaUrl($schemaId)
    return
        if (fn:doc-available($shemaDoc)) then
            fn:doc($shemaDoc)//xs:key[@name='PK_Row_ID']/xs:field/@xpath
        else
           ()
};

declare function ddutil:getValidCodelistValues($url as xs:string) {
    let $url := concat($url, "/codelist")
    return
       if (doc-available($url)) then
            let $values := doc($url)/codelist/containeditems/value
            let $validValues :=
                for $value in $values
                    return
                        if ($value/status/@id = $constants:INSPIRE_STATUS_VALID) then
                            $value
                        else
                            ()
            return data($validValues/@id)
        else ()
};

declare function ddutil:getValidRdfConcepts($url as xs:string) {
    let $url := concat($url, "/rdf")
    return
       if (doc-available($url)) then
            let $values := doc($url)/rdf:RDF/skos:Concept
            let $validValues :=
                for $value in $values
                where ($values/adms:status/@rdf:resource = $types:VALID_STATUS)
                    return
                        $value
            return $validValues
        else ()
};

(: TODO Fix Identifer and Table :)
declare function ddutil:getDeterminandLimits($determinand as xs:string, $dataset, $table) as element()? {
    let $limits := doc($constants:LIMITS_URL)
    return $limits//Determinand[@Identifer = $determinand]/Dataset[@Identifier = $dataset]/Table[@Identifier = "DisaggregatedData"]
};

declare function ddutil:getMonitoringSiteMaximumDepth($monitoringSiteIdentifierScheme, $monitoringSiteIdentifier) {
    let $rdfUrl := concat($constants:MONITORINGSITES_URL, "/rdf")
    let $maximumDepth :=
        if (doc-available($rdfUrl)) then
            data(doc($rdfUrl)/rdf:RDF/skos:Concept[@rdf:about = concat($constants:MONITORINGSITES_URL, "/",
                $monitoringSiteIdentifierScheme, $model:DATASET_SEPARATOR, $monitoringSiteIdentifier)]/property:hasMaximumDepth)
        else
            ()
    return $maximumDepth
};








declare function rdfutil:getUomFromDeterminand($determinand as xs:string) as xs:string? {
    let $data := doc($rdfutil:COMBINATIONDETERMINANDUOM_RDF_URL)
    let $determinandConcept := rdfutil:getDeterminandConcept($determinand)
    let $uomConcept :=
        if (empty($determinandConcept)) then
            ()
        else
            string($data//skos:Concept[property:hasDeterminand/@rdf:resource = $determinandConcept][1]/property:hasUom/@rdf:resource)
    return
        if (empty($uomConcept)) then
            ()
        else
            rdfutil:getUomFromUomConcept($uomConcept)
};
declare function rdfutil:getDeterminandConcept($determinand as xs:string) as xs:string {
    let $data := doc($rdfutil:DETERMINANDS_RDF_URL)
    return string($data//skos:Concept[adms:status/@rdf:resource = $rdfutil:STATUS_VALID and skos:notation = $determinand][1]/@rdf:about)
};
declare function rdfutil:getUomConceptFromUom($uom as xs:string) as xs:string {
    let $data := doc($rdfutil:UOM_RDF_URL)
    return string($data//skos:Concept[skos:notation = $uom][1]/@rdf:about)
};
declare function rdfutil:getUomFromUomConcept($uomConcept as xs:string) as xs:string {
    let $data := doc($rdfutil:UOM_RDF_URL)
    return string($data//skos:Concept[@rdf:about = $uomConcept][1]/skos:notation)
};





(:~ Constants for blocker/error/warning/exception/info level messages. :)







declare function errors:getMaxTableError($result as element(Result)) as xs:integer {
    let $errors := data($result//Row/Column/@error)
    return
        if ($errors = $errors:BLOCKER_LEVEL) then
            $errors:BLOCKER_LEVEL
        else if ($errors = $errors:ERROR_LEVEL) then
            $errors:ERROR_LEVEL
        else if ($errors = $errors:WARNING_LEVEL) then
            $errors:WARNING_LEVEL
        else if ($errors = $errors:EXCEPTION_LEVEL) then
            $errors:EXCEPTION_LEVEL
        else if ($errors = $errors:UNKNOWN_LEVEL) then
            $errors:UNKNOWN_LEVEL
        else
            $errors:OK_LEVEL
};

declare function errors:getResultErrorString($result as element(div)*) as xs:string? {
    let $results :=
        for $r in $result//@result
        return
            tokenize($r, "-")[2]
    return
        if ($results = "blocker") then
            "BLOCKER"
        else if ($results = "error") then
            "ERROR"
        else if ($results = "warning") then
            "WARNING"
        else if ($results = "info") then
            "INFO"
        else if ($results = "unknown") then
            "UNKNOWN"
        else if ($results = "ok") then
            "OK"
        else ()
};

declare function errors:getFeedbackMessage($error as xs:string?) as xs:string {
    if (empty($error)) then
        "The rules could not be executed."
    else if ($error = "BLOCKER") then
        "The quality checks found blocking errors."
    else if ($error = "ERROR") then
        "The quality checks found non-blocking errors."
    else if ($error = "WARNING") then
        "The quality checks found no errors, but some warnings were raised."
    else if ($error = "INFO") then
        "The quality checks found no errors, but some additional info has been attached."
    else if ($error = "UNKNOWN") then
        "There was an unknown error"
    else if ($error = "OK") then
        "All quality checks passed successfully."
    else
        "There was an unknown error"
};

declare function errors:getErrorClass($level as xs:string) as xs:string {
    let $int := if ($level castable as xs:integer) then xs:integer($level) else $errors:UNKNOWN_LEVEL
    return
        if ($int = $errors:UNKNOWN_LEVEL) then "td-unknown"
        else if ($int = $errors:WARNING_LEVEL) then "td-warning"
        else if ($int = $errors:EXCEPTION_LEVEL) then "td-exception"
        else if ($int = $errors:ERROR_LEVEL) then "td-error"
        else if ($int = $errors:BLOCKER_LEVEL) then "td-blocker"
        else if ($int = $errors:OK_LEVEL) then "td-ok"
        else "td-unknown"
};

declare function errors:getErrorName($level as xs:string) as xs:string {
    let $int := if ($level castable as xs:integer) then xs:integer($level) else $errors:UNKNOWN_LEVEL
    return
        if ($int = $errors:UNKNOWN_LEVEL) then "UNKNOWN"
        else if ($int = $errors:WARNING_LEVEL) then "WARNING"
        else if ($int = $errors:EXCEPTION_LEVEL) then "EXCEPTION"
        else if ($int = $errors:ERROR_LEVEL) then "ERROR"
        else if ($int = $errors:BLOCKER_LEVEL) then "BLOCKER"
        else if ($int = $errors:OK_LEVEL) then "OK"
        else "UNKNOWN"
};
(:~
 : Compares two error levels
 :)
declare function errors:isHigher($error as xs:integer, $errorLevel as xs:integer) {
    if ($error > $errorLevel) then
        true()
    else
        false()
};

declare function errors:noErrors($values as xs:anyAtomicType*) as xs:boolean {
    let $errors :=
        for $v in $values
        where (string($v) = string($errors:INVALID_NUMBER) or string($v) = $errors:INVALID_BOOLEAN)
        return true()
    return not($errors = true())
};

declare function functx:is-leap-year
  ( $date as xs:anyAtomicType? )  as xs:boolean {

    for $year in xs:integer(substring(string($date),1,4))
    return ($year mod 4 = 0 and
            $year mod 100 != 0) or
            $year mod 400 = 0
};

declare function functx:if-empty
  ( $arg as item()? ,
    $value as item()* )  as item()* {

  if (string($arg) != '')
  then data($arg)
  else $value
 } ;

declare function functx:type($values as xs:anyAtomicType*) as xs:string* {
for $val in $values
    return
 (if ($val instance of xs:untypedAtomic) then 'xs:untypedAtomic'
 else if ($val instance of xs:anyURI) then 'xs:anyURI'
 else if ($val instance of xs:ENTITY) then 'xs:ENTITY'
 else if ($val instance of xs:ID) then 'xs:ID'
 else if ($val instance of xs:NMTOKEN) then 'xs:NMTOKEN'
 else if ($val instance of xs:language) then 'xs:language'
 else if ($val instance of xs:NCName) then 'xs:NCName'
 else if ($val instance of xs:Name) then 'xs:Name'
 else if ($val instance of xs:token) then 'xs:token'
 else if ($val instance of xs:normalizedString) then 'xs:normalizedString'
 else if ($val instance of xs:string) then 'xs:string'
 else if ($val instance of xs:QName) then 'xs:QName'
 else if ($val instance of xs:boolean) then 'xs:boolean'
 else if ($val instance of xs:base64Binary) then 'xs:base64Binary'
 else if ($val instance of xs:hexBinary) then 'xs:hexBinary'
 else if ($val instance of xs:byte) then 'xs:byte'
 else if ($val instance of xs:short) then 'xs:short'
 else if ($val instance of xs:int) then 'xs:int'
 else if ($val instance of xs:long) then 'xs:long'
 else if ($val instance of xs:unsignedByte) then 'xs:unsignedByte'
 else if ($val instance of xs:unsignedShort) then 'xs:unsignedShort'
 else if ($val instance of xs:unsignedInt) then 'xs:unsignedInt'
 else if ($val instance of xs:unsignedLong) then 'xs:unsignedLong'
 else if ($val instance of xs:positiveInteger) then 'xs:positiveInteger'
 else if ($val instance of xs:nonNegativeInteger) then 'xs:nonNegativeInteger'
 else if ($val instance of xs:negativeInteger) then 'xs:negativeInteger'
 else if ($val instance of xs:nonPositiveInteger) then 'xs:nonPositiveInteger'
 else if ($val instance of xs:integer) then 'xs:integer'
 else if ($val instance of xs:decimal) then 'xs:decimal'
 else if ($val instance of xs:float) then 'xs:float'
 else if ($val instance of xs:double) then 'xs:double'
 else if ($val instance of xs:date) then 'xs:date'
 else if ($val instance of xs:time) then 'xs:time'
 else if ($val instance of xs:dateTime) then 'xs:dateTime'
 else if ($val instance of xs:dayTimeDuration) then 'xs:dayTimeDuration'
 else if ($val instance of xs:yearMonthDuration) then 'xs:yearMonthDuration'
 else if ($val instance of xs:duration) then 'xs:duration'
 else if ($val instance of xs:gMonth) then 'xs:gMonth'
 else if ($val instance of xs:gYear) then 'xs:gYear'
 else if ($val instance of xs:gYearMonth) then 'xs:gYearMonth'
 else if ($val instance of xs:gDay) then 'xs:gDay'
 else if ($val instance of xs:gMonthDay) then 'xs:gMonthDay'
 else 'unknown')
};


declare function locale:getValidCountryCode($countryCode) {
    if (upper-case($countryCode) = "GB") then
        "UK"
    else if (upper-case($countryCode) = "GR") then
        "EL"
    else if ($countryCode) then
        $countryCode
    else
        ""
};



(:~
 : Get key values from the self constructed map - sequence of structured strings.
 : MAP structure: (key1||value1##value2##value3 , key2||value1##value2##value3).
 : @param $map Self constructed map - sequence of strings.
 : @return Sequence of keys
:)
declare function maps:getHashMapKeys($map as xs:string*) as xs:string* {
    for $entry in $map
    return
        fn:substring-before($entry, "||")
};

(:~
 : Get value from the self constructed map - sequence of structured strings.
 : MAP structure: (key1||value1##value2##value3 , key2||value1##value2##value3).
 : @param $map Self constructed map - sequence of strings.
 : @param $key unique key in the map
 : @return value
:)
declare function maps:getHashMapValue($map as xs:string*, $key as xs:string) as xs:string* {
    for $entry in $map
    let $mapKey := fn:substring-before($entry, "||")
    where ($mapKey = $key) or ($mapKey = substring-after($key, ";")) (:ignore namespace :)
    return
        fn:substring-after($entry, "||")
};
(:~
 : Get the list of values from the self constructed Map object - sequence of structured strings.
 : MAP structure: (key1||value1##value2##value3 , key2||value1##value2##value3).
 : @param $map Self constructed map - sequence of strings.
 : @param $key Key value
 : @return Sequence of keys
:)
declare function maps:getHashMapBooleanValues($map as xs:string*, $key as xs:string) as xs:boolean* {
    for $entry in $map
    where fn:starts-with($entry, concat($key,"||"))
    return
        let $values := fn:tokenize(fn:substring-after($entry,"||"), "##")
        for $val in $values
        return
            if ($val="true") then fn:true()
            else if ($val="false") then fn:false()
            else fn:false()
};
(:~
 : Create Map Entry object - key value pair stored in sequnce. Value represents a list of values delimited with ##.
 : MAP structure: (key1||value1##value2##value3 , key2||value1##value2##value3).
 : @param $key Key value.
 : @param $key List of values.
 : @return Map entry object as string.
:)
declare function maps:createHashMapEntry($key as xs:string, $values as xs:string*) as xs:string* {
    concat($key,"||",string-join($values, "##"))
};

declare function maps:getHashMapValues($map as xs:string*, $key as xs:string) as xs:string* {
    let $values :=
    for $entry in $map
        let $mapKey := fn:substring-before($entry, "||")
    where ($mapKey = $key)
    return
        fn:substring-after($entry, "||")
    let $values := tokenize($values, $model:HASHMAP_SEPARATOR)
    let $values :=
        for $v in $values
        return
            normalize-space($v)
    return $values
};

declare function maps:containsHashMapValue($map as xs:string*, $key as xs:string, $value as xs:string) as xs:boolean {
    let $values := maps:getHashMapValues($map, $key)
    return ($values = $value)
};

declare function maps:getHashMapValuesCSV($map as xs:string*, $key as xs:string) as xs:string {
    string-join(maps:getHashMapValues($map, $key), $model:CSV_SEPARATOR)
};


(: Alternative map :)
declare function maps:createElemMapEntry($key as xs:string, $values as xs:string*) as xs:string* {
    <MapEntry key="{$key}">{
        for $v in $values
        return
            <Value>{$v}</Value>
    }</MapEntry>
};

declare function maps:getElemMapValues($map as element(Map), $key as xs:string) as xs:string* {
    let $entry := $map/MapEntry[@key = $key]
    let $values :=
        for $v in $entry/Value
        return string($v)
    return $values
};

declare function maps:createElemMap($entries as element(MapEntry)*) {
    let $keys := data($entries/@key)
    let $uniqueKeys := distinct-values($keys)
    let $uniqueEntries :=
        for $key in $uniqueKeys
        return
            $entries[@key = $key][1]
    return
        <Map>
        {$uniqueEntries}
        </Map>
};








declare function model:getResult($rows) as element(Result) {
    <Result>{
        for $row in $rows
        return
            model:getRow($row)
            }
    </Result>
};
declare function model:getRow($row) as element(Row) {
    let $children := $row//child::*
    return
    <Row>{
        for $child in $children
        return
            model:getColumn($child/local-name(), string($child), "1")
        }
    </Row>
};
(:~
 : Creates a intermediate result column
 : The result must have this form
 : <Result>
 :     <Row>
 :       <Column></Column>
 :     </Row>
 : </Result>
 :)
declare function model:getColumn($element, $value, $errorLevel) as element(Column) {
    <Column element="{$element}" value="{$value}" error="{$errorLevel}"/>
};

declare function model:createMeta($schema as document-node(), $schemaContainer as document-node(), $document as document-node(), $envelopeXml as document-node()?, $codeLists as element(dd:value-lists), $allowedBoolean as xs:string*) as element(Meta) {
    let $table := $codeLists/dd:value-list[1]/string(@table)
    let $dataset := $codeLists/dd:value-list[1]/string(@dataset)
    let $ddTable := concat("http://dd.eionet.europa.eu/vocabulary/datadictionary/ddTables/", $dataset, $model:DATASET_SEPARATOR, $table)
    let $rowNamespace := xmlutil:getRowNamespace($document)
    let $elemPrefix := schema:getElemPrefix($schema)
    let $allElements :=
        for $elem in $schema/xs:schema/xs:element/xs:complexType/xs:sequence/xs:element[@name = "Row"]//xs:element
            let $elemName := $elem/string(@ref)
            let $elemLocalName := substring-after($elemName, ":")
            let $primaryKey := $schema/xs:schema/xs:element/xs:key/xs:field/@xpath = $elemName
            let $mandatory := data($elem/minOccurs) > 0
            let $elemType := model:getElemType($schemaContainer, $elemLocalName)
            let $restriction := model:getElemRestriction($schemaContainer, $elemLocalName)
        return
        <Element name="{$elemName}" type="{$elemType}" primaryKey="{$primaryKey}" mandatory="{$mandatory}">
            {$restriction}
        </Element>

    let $result :=
        <Meta table="{$table}" dataset="{$dataset}" rowNamespace="{$rowNamespace}" elemPrefix="{$elemPrefix}" ddTable="{$ddTable}" allowedBoolean="{$allowedBoolean}">
            {$envelopeXml/envelope}
            <Schema>{$schema/xs:schema}</Schema>
            <SchemaContainer>{$schemaContainer/xs:schema}</SchemaContainer>
            <Codelist>{$codeLists}</Codelist>
            <Elements>{$allElements}</Elements>
        </Meta>
    return $result
};

declare function model:getMetadataSchema($metadata as element(Meta)) as element() {
    $metadata/Schema
};
declare function model:getMetadataSchemaContainer($metadata as element(Meta)) as element() {
    $metadata/SchemaContainer
};

declare function model:getElemType($schemaContainer as document-node(), $elemName as xs:string) {
    $schemaContainer/xs:schema/xs:element[@name = $elemName]/xs:simpleType/xs:restriction/string(@base)
};

declare function model:getElemRestriction($schemaContainer as document-node(), $elemName as xs:string) as element(xs:restriction) {
    $schemaContainer/xs:schema/xs:element[@name = $elemName]/xs:simpleType/xs:restriction
    (:let $elemType := model:getElemType($schemaContainer, $elemName)
    let $elemRestriction :=
        for $child in $elem/child::*
            return
                element {$child/local-name()} { attribute value { $child/@value }  }
    return
        <Restriction>{$elemRestriction}</Restriction>:)
};

declare function model:getElementFromLocalName($row, $localName as xs:string) as element()? {
    $row/*[local-name() = $localName][1]
};
declare function model:getStringValueFromLocalName($row, $localName as xs:string) as xs:string {
    string(model:getElementFromLocalName($row, $localName))
};
declare function model:getValueFromLocalName($row, $localName as xs:string, $metadata as element(Meta)) as xs:anyAtomicType? {
    let $value := normalize-space(string($row/child::*[local-name() = $localName][1]))
    return model:getValueFromMetaType($metadata, $localName, $value)
};

declare function model:getValueFromMetaType($metadata as element(), $localName as xs:string, $value as xs:anyAtomicType) as xs:anyAtomicType? {
    let $metaType := model:getTypeFromLocalName($metadata, $localName)
    return
        if ($metaType = "xs:integer") then
            if ($value castable as xs:integer) then xs:integer($value) else ()
        else if ($metaType = "xs:float") then
            if ($value castable as xs:float) then xs:float($value) else ()
        else if ($metaType = "xs:double") then
            if ($value castable as xs:double) then xs:double($value) else ()
        else if ($metaType = "xs:date") then
            if ($value castable as xs:date) then xs:date($value) else ()
        else if ($metaType = "xs:boolean") then
            if ($value castable as xs:boolean) then xs:boolean($value) else ()
        else
            string($value)
};
declare function model:getMetaElementType($metadata as element(), $elem as xs:string) as xs:string {
    string($metadata/Elements/Element[@name = $elem]/@type)
};
declare function model:getTypeFromLocalName($metadata as element(), $localName as xs:string) as xs:string? {
    string($metadata/Elements/Element[substring-after(@name, ":") = $localName]/@type)
};
declare function model:getMandatoryElements($metadata as element(Meta)) as xs:string* {
    data($metadata/Elements/Element[@mandatory = true()])
};
declare function model:getReportingCountry($metadata as element()) as xs:string {
    let $countryCode := upper-case(string($metadata/envelope/countrycode[1]))
    return locale:getValidCountryCode($countryCode)
};


declare function model:getCodeListFixedValues($metadata as element(Meta), $ddValueList as element(dd:value-list), $toLower as xs:boolean) as xs:string* {
    let $ddTable := model:getMetadataDDTable($metadata)
    let $allowedBoolean := model:getAllowedBoolean($metadata)
    (:let $ddValueList := model:getCodeValueLists($metadata)/dd:value-list:)

    let $fixedValues :=
        if ($ddValueList/@table = $ddTable) then
            $ddValueList//dd:value/@code
        else ()

    let $fixedValues := if ($toLower) then
            for $val in $fixedValues return lower-case($val)
        else
            $fixedValues

    (: if fixed value is boolean, the following values are also allowed: 1, 0 :)
    let $fixedValues :=
        if (common:containsStr($fixedValues, "true") and common:containsStr($fixedValues, "false")) then
            fn:distinct-values(fn:insert-before($xmlutil:ALLOWED_BOOLEAN_VALUES, 1, $fixedValues))
        else
            $fixedValues

    return $fixedValues
};


declare function model:getCodelistLink($metadata, $localName) {
    let $link := $constants:DDLINKS//Element[text() = $localName]/@link[1]
    return string($link)
};

declare function model:getCodeListSuggestedElements($metadata as element(Meta)) as xs:string* {
    let $lists := model:getCodelists($metadata)
    let $suggestedElems := $lists/dd:value-list[@fixed="false"]/@element
    return $suggestedElems
};
declare function model:getCodeValueListElementsCSV($metadata as element(Meta)) as xs:string {
    let $lists := model:getCodelists($metadata)
    let $elements := data($lists/dd:value-list/@element)
    return string-join($elements, ", ")
};
declare function model:getCodelists($metadata as element(Meta)) as element(dd:value-lists) {
    $metadata/Codelist/dd:value-lists
};

declare function model:getAllowedBoolean($metadata as element(Meta)) as xs:string* {
    tokenize($metadata/@allowedBoolean, ",")
};


declare function model:getMetadataTable($metadata as element()) as xs:string? {
    string($metadata/@table)
};
declare function model:getMetadataDataset($metadata as element()) as xs:string? {
    string($metadata/@dataset)
};
declare function model:getMetadataElemPrefix($metadata as element()) as xs:string? {
    string($metadata/@elemPrefix)
};
declare function model:getNameFromLocalName($metadata as element(Meta), $localName as xs:string) as xs:string {
    let $prefix := model:getMetadataElemPrefix($metadata)
    let $name := concat($prefix, ":", $localName)
    return $name
};
declare function model:getMetadataRowNamespace($metadata as element()) as xs:string? {
    string($metadata/@rowNamespace)
};
declare function model:isMetaValidValue($metadata as element(), $value as xs:anyAtomicType) as xs:boolean {
    true()
};
declare function model:getMetadataDDTable($metadata as element(Meta)) {
    string($metadata/@ddTable)
};




(:~
 : Checks if value can be casted to boolean
 : @param value to cast
 : @return boolean value, else empty sequence
 :)
declare function types:getBoolean($value as xs:string) {
    if ($value castable as xs:boolean) then
        xs:boolean($value)
    else
        ()
};
(:~
 : Checks if value can be casted to float
 : @param value to cast
 : @return float value, else empty sequence
 :)
declare function types:getFloat($value as xs:string) {
    if ($value castable as xs:float) then
        xs:float($value)
    else
        ()
};
(:~
 : Checks if value can be casted to double
 : @param value to cast
 : @return double value, else empty sequence
 :)
declare function types:getDouble($value as xs:string) {
    if ($value castable as xs:double) then
        xs:double($value)
    else
        ()
};
(:~
 : Checks if value can be casted to integer
 : @param value to cast
 : @return integer value, else empty sequence
 :)
declare function types:getInteger($value as xs:string) {
    if ($value castable as xs:integer) then
        xs:integer($value)
    else
        ()
};



(:~
 : Get error message for given rule Code from the rules XML.
 :)
declare function ruleutil:getRuleErrorMessage($rule as element(rule)) as xs:string {
(:    concat($rule/@code, " ", $rule/errorMessage):)
    $rule/errorMessage
};

declare function ruleutil:checkException($rule as element(rule), $row as element(), $metadata as element()) as xs:boolean {
    let $exception := $rule/exceptions/exception
    let $prefix := model:getMetadataElemPrefix($metadata)
    let $result :=
        ruleutil:checkExceptionGroup($exception, $row, $prefix, $metadata)
    return
        $result
};

declare function ruleutil:checkExceptionGroup($exception as element(exception), $row as element(), $prefix as xs:string, $metadata as element(Meta)) {
        let $orValues :=
            for $group in $exception/Group[@operand = "or"]
                let $checkValues := ruleutil:checkExceptionField($group, $row, $prefix)
            return $checkValues
        let $orResult :=
            if (not(empty($orValues))) then
                $orValues = true()
            else
                ()

        let $andValues :=
            for $group in $exception/Group[@operand = "and" or not(@operand)]
                let $checkValues := ruleutil:checkExceptionField($group, $row, $prefix)
            return $checkValues
        let $andResult :=
            if (not(empty($andValues))) then
                not($andValues = false())
            else
                ()

        return
            if (not(empty(($orResult,$andResult)))) then
                not(false() = ($orResult, $andResult))
            else
                false()
};
declare function ruleutil:checkExceptionField($group as element(), $row as element(), $prefix as xs:string) {
    let $or :=
        for $field in $group/Field[@operand = "or"]
            let $name := concat($prefix, ":", $field/@localName)
            let $expected :=
            for $v in $field/Value
                return string($v)
            let $actual := string($row/*[name() = $name][1])
            let $check := $expected = $actual
        return
            $check
    let $or :=
        if (not(empty($or))) then
            $or = true()
        else
            ()

    let $and :=
        for $field in $group/Field[@operand = "and" or not(@operand)]
            let $name := concat($prefix, ":", $field/@localName)
            let $expected :=
                for $v in $field/Value
                return string($v)
            let $actual := string($row/*[name() = $name][1])
            let $check := $expected = $actual
        return
            $check
    let $and :=
        if (not(empty($and))) then
            not($and = false())
        else
            ()

    return
        if (not(empty(($or,$and)))) then
            not(false() = ($or,$and))
        else
            ()
};

(:~
 : Get error messages for sub rules.
 : @param $ruleCode Parent rule code
 : @param $subRuleCodes List of sub rule codes.
 : @return xs:string

declare function ruleutil:getSubRuleMessages($rule as element(rule), $subRuleCodes as xs:string*)
as xs:string
{
    let $rules := ruleutil:getRules()//group[rule/@code = $ruleCode]
    let $subRuleMessages :=
         for $subRuleCode in fn:reverse($subRuleCodes)
         let $rule := $rules//rule[@code = concat($ruleCode, ".", $subRuleCode)]
         return
             fn:concat($rule/@code, " ", $rule/message)
    return
        if (count($subRuleMessages) > 1) then string-join($subRuleMessages, "; ") else fn:string($subRuleMessages)
};:)

(:~
 : Get error message for given rule Code from the rules XML.
 : @param $ruleCode Rule code in rules XML.
 : @return xs:string
 :)
declare function ruleutil:getRuleExceptionMessage($rule as element(rule)) as xs:string {
    concat($rule/@code, " ", $rule/exceptionMessage)
};

(:~
 : Get rule element for given rule Code from the rules XML.
 : @param $rules Rules
 : @param $ruleCode Rule code in rules XML.
 : @return rule element.
 :)
declare function ruleutil:getRule($rules as element(rules), $ruleCode as xs:string) as element(rule) {
    $rules//rule[@code = $ruleCode][1]
};
declare function ruleutil:getAllRules($rules as element(rules)) as element(rule)+ {
    $rules//rule
};
declare function ruleutil:getRuleCode($rule as element(rule)) as xs:string {
    string($rule/@code)
};
declare function ruleutil:getRuleTitle($rule as element(rule)) as xs:string {
    string($rule/title)
};
declare function ruleutil:getRuleDescription($rule as element(rule)) as element()* {
    $rule/descr
};
declare function ruleutil:getRuleErrorLevel($rule as element(rule)) as xs:string {
    string($rule/errorLevel)
};
declare function ruleutil:getRuleGroupBy($rule as element(rule)) as xs:string* {
    let $x := tokenize($rule/results/groupBy, ", ")
    for $i in $x
        return normalize-space($i)
};
declare function ruleutil:getRuleSummaryTable($rule as element(rule)) as xs:integer {
    xs:integer($rule/results/summaryTable)
};
declare function ruleutil:getRuleResultTable($rule as element(rule)) as xs:integer {
    xs:integer($rule/results/resultTable)
};
declare function ruleutil:getRuleAdditionalTable($rule as element(rule)?) as xs:integer? {
    xs:integer($rule/results/additionalTable)
};
declare function ruleutil:getRuleResultUnit($rule as element(rule)) as xs:string {
    if (empty($rule/results/unit)) then "record" else string($rule/results/unit)
};
declare function ruleutil:getRuleShowRow($rule as element(rule)) as xs:boolean {
    if ($rule/results/showRow = "false") then false() else true()
};
declare function ruleutil:getRuleElements($rule as element(rule)) as xs:string* {
    let $x := tokenize($rule/results/elementsView, ",")
    let $values :=
        for $i in $x
            (:, $prefix as xs:string:)
            (:return concat($prefix, ":", normalize-space($i)):)
        return normalize-space($i)
    return distinct-values($values)
};

declare function ruleutil:executeRules($schema as document-node(), $schemaContainer as document-node(), $document as document-node(), $metadata as element(Meta), $rules) {
    let $body :=
        for $rule at $pos in $rules//rule
        return
            ruleutil:executeRule($schema, $schemaContainer, $document, $metadata, $rule, $pos)
    return $body
};

declare function ruleutil:executeRule($schema as document-node(), $schemaContainer as document-node(), $document as document-node(), $metadata as element(Meta), $rule as element(rule), $pos as xs:integer) {
    let $id := string($rule/@id)
    let $summaryTable := ruleutil:getRuleSummaryTable($rule)
    let $table := if ($summaryTable castable as xs:integer) then xs:integer($summaryTable) else ()

    let $prefix := tokenize($id, ":")[1]
    let $funct := tokenize($id, ":")[2]
    let $res :=
        if ($prefix = "common") then
            if ($funct = "mandatory") then
                validators:checkMandatoryValues($schema, $document, $metadata, $rule)
            else if ($funct = "duplicates") then
                validators:checkDuplicates($schema, $document, $metadata, $rule)
            else if ($funct = "types") then
                validators:checkDataTypes($schema, $schemaContainer, $document, $metadata, $rule)
            else if ($funct = "codelist") then
                validators:checkCodelistValues($schemaContainer, $document, $metadata, $rule)
            else if ($funct = "monitoringFormat") then
                validators:checkMonitoringFormat($schema, $document, $metadata, $rule)
            else if ($funct = "monitoringReference") then
                validators:checkMonitoringReference($schema, $document, $metadata, $rule)
            else if ($funct = "unitOfMeasure") then
                validators:checkUnitOfMeasure($schema, $document, $metadata, $rule)
            else if ($funct = "referenceYear") then
                validators:checkReferenceYear($schema, $document, $metadata, $rule)
            else if ($funct = "samplingPeriod") then
                validators:checkSamplingPeriod($schema, $document, $metadata, $rule)
            else if ($funct = "resultValuesLimit") then
                validators:checkResultValuesLimit($schema, $document, $metadata, $rule)
            else if ($funct = "resultValuesMathematical") then
                validators:checkResultValuesMathematical($schema, $document, $metadata, $rule)
            else if ($funct = "loq") then
                validators:checkLoq($schema, $document, $metadata, $rule)
            else if ($funct = "sampleDepth") then
                validators:checkSampleDepth($schema, $document, $metadata, $rule)
            else ()
        else ()
        let $result :=
            if ($res) then
                uiutil:buildTable($schema, $schemaContainer, $rule, $res, $metadata)
            else
                ()
    return $result
};



declare function schema:getAllElementsCSV($schema as document-node()) as xs:string {
    let $allElements := schema:getAllElements($schema)
    let $elems :=
        for $i in $allElements
            return substring-after($i, ":")
    return string-join($elems, ",")
};

(:~
 : Extract all elements from XML Schema.
 : @param schema XML Schema
 : @return the list of manadatory XML element names.
 :)
declare function schema:getAllElements($schema as document-node()) as xs:string* {
    $schema//xs:element[@name="Row"]/xs:complexType/xs:sequence/xs:element/string(@ref)
};


declare function schema:getMandatoryElementsCSV($schema as document-node()) {
    let $mandatoryElems := schema:getMandatoryElements($schema)
    let $elems :=
        for $i in $mandatoryElems
        return substring-after($i, ":")
    return string-join($elems, ", ")
};
declare function schema:getMandatoryElements($schema as document-node()) {
    let $elems := $schema//xs:element[@name="Row"]//xs:element[@minOccurs != "0"]
    for $elem in $elems
        return string($elem/@ref)
};
(:~
 : Returns primary key elements for usage in AggregatedData rules
 :)
declare function schema:getPrimaryKeysCSV($schema as document-node()) as xs:string {
    let $primaryKeys := schema:getPrimaryKeys($schema)
    let $keys :=
        for $i in $primaryKeys
            return substring-after($i, ":")
    return string-join($keys, ", ")
};

declare function schema:getPrimaryKeys($schema as document-node()) as xs:string* {
    $schema//xs:key[@name='PK_Row_ID']/xs:field/string(@xpath)
};

declare function schema:getElemPrefix($schema as document-node()) as xs:string {
    let $namespace := string($schema/xs:schema/xs:import[1]/@namespace)
    for $prefix in in-scope-prefixes($schema/xs:schema)
    return
        if (namespace-uri-for-prefix($prefix, $schema/xs:schema) = $namespace) then
            $prefix
        else
            ()
};

declare function html:anchorNewTab($href as xs:string, $text as xs:string) as element(a) {
    <a href="{$href}" target="_blank">{$text}</a>
};



declare function html:sequenceToCSV($seq as item()*) as item()* {
    let $char := (")")
    let $newSeq :=
        for $s at $pos in $seq
        return
            if ($s instance of xs:string and ends-with($s, $char) and $pos < count($seq)) then
                concat($s, ", ")
            else
                $s
    return $newSeq
};











































declare function tables:buildTable($type as xs:string, $rule as element(rule), $result as element(Result), $metadata as element(Meta)) {
    let $table :=
        if ($type = "SUMMARY") then
            ruleutil:getRuleSummaryTable($rule)
        else if ($type = "RESULT") then
            ruleutil:getRuleResultTable($rule)
        else if ($type = "ADDITIONAL") then
            ruleutil:getRuleAdditionalTable($rule)
        else ()
    return
    if (not(empty($table))) then
        (:~
         : SUMMARY TABLES
         :)
        if ($table = $tables:SUMMARY_NULL_TABLE) then
            ()
        else if ($table = $tables:SUMMARY_EMPTY_TABLE) then
            tables:getEmptySummaryTable($result, $rule, $metadata)
        else if ($table = $tables:SUMMARY_SIMPLE_TABLE) then
            tables:getSimpleSummaryTable($result, $rule, $metadata)
        else if ($table = $tables:SUMMARY_MANDATORY) then
            tables:getMandatorySummaryTable($result, $rule, $metadata)
        else if ($table = $tables:SUMMARY_DUPLICATES) then
            tables:getEmptySummaryTable($result, $rule, $metadata)
        else if ($table = $tables:SUMMARY_DATATYPES) then
            tables:getDatatypesSummaryTable($result, $rule, $metadata)
        else if ($table = $tables:SUMMARY_CODELIST) then
            tables:getCodelistSummaryTable($result, $rule, $metadata)
        else if ($table = $tables:SUMMARY_MONITORINGFORMAT) then
            ()
        else if ($table = $tables:SUMMARY_MONITORINGREFERENCE) then
            ()
        else if ($table = $tables:SUMMARY_UNITOFMEASURE) then
            tables:getUomSummaryTable($result, $rule, $metadata)
        else if ($table = $tables:SUMMARY_REFERENCEYEAR) then
            tables:getSimpleSummaryTable($result, $rule, $metadata)
        else if ($table = $tables:SUMMARY_SAMPLINGPERIOD) then
            tables:getSamplingPeriodSummaryTable($result, $rule, $metadata)
        else if ($table = $tables:SUMMARY_VALUESLIMITS) then
            ()
        else if ($table = $tables:SUMMARY_MATHEMATICALRELATION) then
            tables:getMathematicalRelationSummaryTable($result, $rule, $metadata)
        else if ($table = $tables:SUMMARY_LOQ) then
            tables:getLOQSummaryTable($result, $rule, $metadata)
        else if ($table = $tables:SUMMARY_SAMPLEDEPTH) then
            tables:getEmptySummaryTable($result, $rule, $metadata)
        (:~
         : RESULT TABLES
         :)
        else if ($table = $tables:RESULT_SIMPLE) then
            tables:getSimpleResultTable($result, $rule, $metadata)
        else if ($table = $tables:RESULT_MANDATORY) then
            tables:getMandatoryResultTable($result, $rule, $metadata)
        else if ($table = $tables:RESULT_DUPLICATES) then
            tables:getDuplicatesResultTable($result, $rule, $metadata)
        else if ($table = $tables:RESULT_DATATYPES) then
            tables:getDatatypesResultTable($result, $rule, $metadata)
        else if ($table = $tables:RESULT_CODELIST) then
            tables:getCodelistResultTable($result, $rule, $metadata)
        else if ($table = $tables:RESULT_MONITORINGFORMAT) then
            tables:getMonitoringFormatResultTable($result, $rule, $metadata)
        else if ($table = $tables:RESULT_MONITORINGREFERENCE) then
            tables:getMonitoringReferenceResultTable($result, $rule, $metadata)
        else if ($table = $tables:RESULT_UNITOFMEASURE) then
            tables:getUomResultTable($result, $rule, $metadata)
        else if ($table = $tables:RESULT_REFERENCEYEAR) then
            tables:getReferenceYearResultTable($result, $rule, $metadata)
        else if ($table = $tables:RESULT_SAMPLINGPERIOD) then
            tables:getSamplingPeriodResultTable($result, $rule, $metadata)
        else if ($table = $tables:RESULT_VALUESLIMITS) then
            tables:getSimpleResultTable($result, $rule, $metadata)
        else if ($table = $tables:RESULT_MATHEMATICALRELATION) then
            tables:getMathematicalRelationResultTable($result, $rule, $metadata)
        else if ($table = $tables:RESULT_LOQ) then
            tables:getLOQResultTable($result, $rule, $metadata)
        else if ($table = $tables:RESULT_SAMPLEDEPTH) then
            tables:getSampleDepthResultTable($result, $rule, $metadata)
        (:~
         : ADDITIONAL TABLES
         :)
        else if ($table = $tables:ADDITIONAL_DATATYPES) then
            tables:getAdditionalDataTypes($result, $metadata)
        else if ($table = $tables:ADDITIONAL_CODELIST) then
            tables:getAdditionalCodelistTable($result, $metadata)
        else if ($table = $tables:ADDITIONAL_VALUELIMITS) then
            tables:getAdditionalValueLimits($result, $metadata)
        else ()
    else ()
};

(: $unit should be record or file :)
declare function tables:getEmptySummaryTable($result, $rule, $metadata) as element(div) {
    let $unit := ruleutil:getRuleResultUnit($rule)
    let $count := count($result/Row[Column/@error > $errors:OK_LEVEL])
    return
        <div>
            <p>{$count} &#32; {$unit}{if ($count > 1) then "s" else ""} detected.</p>
        </div>
};

declare function tables:getSimpleSummaryTable($result, $rule, $metadata as element(Meta)) as element(div) {
    let $ruleCode := ruleutil:getRuleCode($rule)
    let $unit := ruleutil:getRuleResultUnit($rule)
    let $countInvalidRecords := count($result/Row)
    let $resultText := <p>{$countInvalidRecords} &#32; {$unit}{if ($countInvalidRecords > 1) then "s" else ""} detected.</p>
    let $resultTable :=
        <table border="1" js-class="summary" type="elements">
            <tr>
                <th></th>
                <th>Field name</th>
                <th>Number of &#32; {$unit}{if ($countInvalidRecords > 1) then "s" else ""} detected</th>
            </tr>{
    let $errorElems :=
        for $column in $result/Row/Column
            return data($column[@error > $errors:OK_LEVEL]/@element)
        for $errorElem at $pos in distinct-values($errorElems)
            let $columnName := $errorElem
            let $errors := count($result/Row/Column[@error > $errors:OK_LEVEL and @element = $errorElem])
            return
            <tr>
                <td>{uiutil:getCheckbox($ruleCode, $columnName)}</td>
                <td><label for="chk{concat($ruleCode, "-", $columnName)}">{common:getElemNameWithoutNs($columnName)}</label></td>
                <td>{$errors}</td>
            </tr>}
        </table>
    return
        <div>
           {$resultText}
           {$resultTable}
        </div>
};

declare function tables:getMandatorySummaryTable($result, $rule, $metadata) as element(div) {
    tables:getSimpleSummaryTable($result, $rule, $metadata)
};

declare function tables:getDatatypesSummaryTable($result, $rule, $metadata) as element(div) {
    tables:getSimpleSummaryTable($result, $rule, $metadata)
};

declare function tables:getCodelistSummaryTable($result, $rule, $metadata) as element(div) {
    let $ruleCode := ruleutil:getRuleCode($rule)
    let $countInvalidRecords := count($result/Row)
    let $resultText := <p>{$countInvalidRecords} record{if ($countInvalidRecords > 1) then "s" else ""} detected.</p>
    let $resultTable :=
        <table border="1"  js-class="summary" type="elements">
            <tr>
                <th></th>
                <th>Field name</th>
                <th>Incorrect codes</th>
                <th>Number of records detected</th>
            </tr>{
    let $errorElems :=
        for $column in $result/Row/Column
            return data($column[@error > $errors:OK_LEVEL]/@element)
        for $errorElem at $pos in distinct-values($errorElems)
            let $columnName := $errorElem
            let $errors := count($result/Row/Column[@error > $errors:OK_LEVEL and @element = $errorElem])
            return
            <tr>
                <td>{uiutil:getCheckbox($ruleCode, $columnName)}</td>
                <td><label for="chk{concat($ruleCode, "-", $columnName)}">{common:getElemNameWithoutNs($columnName)}</label></td>
                <td></td>
                <td>{$errors}</td>
            </tr>}
        </table>
    return
        <div>
           {$resultText}
           {$resultTable}
        </div>
};

declare function tables:getUomSummaryTable($result, $rule, $metadata) as element(div) {
    let $ruleCode := ruleutil:getRuleCode($rule)
    let $countInvalidRecords := count($result/Row)
    let $resultText := <p>{$countInvalidRecords} record{if ($countInvalidRecords > 1) then "s" else ""} detected.</p>
    let $resultTable :=
        <table border="1"  js-class="summary" type="values">
            <thead>
                <tr>
                    <th></th>
                    <th>resultUom</th>
                    <th>Determinand codes</th>
                    <th>Number of records detected</th>
                </tr>
            </thead>
            <tbody>{
                let $keys :=
                    for $value in $result/Row/Column[@element = "resultUom"]/@value
                    return $value
                let $uniqueKeys := distinct-values($keys)
                let $countMap :=
                    for $key in $uniqueKeys
                    return
                        maps:createHashMapEntry($key, string(count(index-of($keys, $key))))
                for $key at $pos in $uniqueKeys
                let $columnName := $key
                where $result/Row/Column[@element = "resultUom" and @value = $key and @error > $errors:OK_LEVEL]
                return
                <tr>
                    <td>{uiutil:getCheckbox($ruleCode, $columnName)}</td>
                    <td>{$key}</td>
                    <td>{
                        let $incorrectUoms :=
                            for $row in $result/Row
                            let $determinand := string($row/Column[@element = "observedPropertyDeterminandCode"]/@value)
                            let $determinandConcept := rdfutil:getDeterminandConcept($determinand)
                            let $determinandLink :=
                                if (common:isEmpty($determinandConcept)) then
                                    $determinand
                                else
                                    html:anchorNewTab($determinandConcept, $determinand)

                            let $uom := rdfutil:getUomFromDeterminand($determinand)
                            let $uomLink :=
                                if (common:isEmpty($uom)) then
                                    "(Not Found)"
                                else
                                    concat("(", $uom, ")")

                           (: let $uomConcept := rdfutil:getUomConceptFromUom($uom)
                            let $uomLink :=
                                    html:anchorNewTab($uomConcept, $uom):)

                            where $row/Column[@element = "resultUom" and @value = $key]
                            return
                                ($determinandLink, $uomLink)
                        return html:sequenceToCSV($incorrectUoms)
                    }</td>
                    <td>{maps:getHashMapValue($countMap, $key)}</td>
                </tr>
              }</tbody>
        </table>
    return
        <div>
           {$resultText}
           {$resultTable}
        </div>
};

declare function tables:getSamplingPeriodSummaryTable($result, $rule, $metadata) as element(div) {
    let $ruleCode := ruleutil:getRuleCode($rule)
    let $countInvalidRecords := count($result/Row)
    let $resultText := <p>{$countInvalidRecords} record{if ($countInvalidRecords > 1) then "s" else ""} detected.</p>
    let $resultTable :=
        <table border="1" js-class="summary" type="rules">
            <thead>
                <tr>
                    <th></th>
                    <th>Error type</th>
                    <th>Number of records detected</th>
                </tr>
            </thead>
            <tbody>{
                let $invalidRows := $result/Row[Column[@error > $errors:OK_LEVEL] and string(@invalid) = "true"]
                let $columnName := "Invalid types"
                let $pos := 1
                return
                    <tr>
                        <td>{uiutil:getCheckbox($ruleCode, $columnName)}</td>
                        <td>Invalid types</td>
                        <td>{count($invalidRows)}</td>
                    </tr>
                }
                {
                let $maps := $result/Row[Column[@error > $errors:OK_LEVEL]]/@rules
                let $keys :=
                    for $m in $maps
                    return
                        maps:getHashMapValues($m, "rules")

                let $countMap :=
                    for $key in ("1","2","3","4")
                    return
                        maps:createHashMapEntry($key, string(count(index-of($keys, $key))))
                for $key at $pos in ("1","2","3","4")
                    let $columnName := $key
                return
                <tr>
                    <td>{uiutil:getCheckbox($ruleCode, $columnName)}</td>
                    <td>{$key}</td>
                    <td>{maps:getHashMapValue($countMap, $key)}</td>
                </tr>
              }</tbody>
        </table>
    return
        <div>
           {$resultText}
           {$resultTable}
        </div>
};

declare function tables:getMathematicalRelationSummaryTable($result, $rule, $metadata) as element(div) {
    let $ruleCode := ruleutil:getRuleCode($rule)
    let $countInvalidRecords := count($result/Row)
    let $resultText := <p>{$countInvalidRecords} record{if ($countInvalidRecords > 1) then "s" else ""} detected.</p>
    let $resultTable :=
        <table border="1" js-class="summary" type="rules">
            <thead>
                <tr>
                    <th></th>
                    <th>Rule</th>
                    <th>Number of records detected</th>
                </tr>
            </thead>
            <tbody>{
                let $invalidRows := $result/Row[Column[@error > $errors:OK_LEVEL] and string(@invalid) = "true"]
                let $columnName := "Invalid types"
                let $pos := 1
                return
                    <tr>
                        <td>{uiutil:getCheckbox($ruleCode, $columnName)}</td>
                        <td>Invalid types</td>
                        <td>{count($invalidRows)}</td>
                    </tr>
                }
                {
                let $maps := $result/Row[Column[@error > $errors:OK_LEVEL]]/string(@rules)
                let $keys :=
                    for $m in $maps
                    return
                        maps:getHashMapValues($m, "rules")
                let $uniqueKeys := distinct-values($keys)
                let $countMap :=
                    for $key in $uniqueKeys
                    return
                        maps:createHashMapEntry($key, string(count(index-of($keys, $key))))
                for $key at $pos in $uniqueKeys
                    let $columnName := $key
                (:where $result/Row[maps:containsHashMapValue(@rules = $key]/Column[@error > $errors:OK_LEVEL]:)
                return
                <tr>
                    <td>{
                        let $id := concat("chk", $ruleCode, "-", $columnName)
                        return
                        <input type="checkbox" value="{$columnName}" id="{$id}" onclick="javascript:singleCheckboxToggle('{$id}');" />
                        }
                    </td>
                    <td>{$key}</td>
                    <td>{maps:getHashMapValue($countMap, $key)}</td>
                </tr>
              }</tbody>
        </table>
    return
        <div>
           {$resultText}
           {$resultTable}
        </div>
};

declare function tables:getLOQSummaryTable($result, $rule, $metadata) as element(div) {
    let $ruleCode := ruleutil:getRuleCode($rule)
    let $countInvalidRecords := count($result/Row)
    let $resultText := <p>{$countInvalidRecords} record{if ($countInvalidRecords > 1) then "s" else ""} detected.</p>
    let $resultTable :=
        <table border="1" js-class="summary" type="rules">
            <thead>
                <tr>
                    <th></th>
                    <th>Error</th>
                    <th>Number of records detected</th>
                </tr>
            </thead>
            <tbody>{
                let $invalidRows := $result/Row[Column[@error > $errors:OK_LEVEL] and string(@invalid) = "true"]
                let $columnName := "Invalid types"
                let $pos := 1
                return
                    <tr>
                        <td>
                            {uiutil:getCheckbox($ruleCode, $columnName)}
                        </td>
                        <td>Invalid types</td>
                        <td>{count($invalidRows)}</td>
                    </tr>
                }
                {
                let $maps := $result/Row[Column[@error > $errors:OK_LEVEL]]/@rules
                let $keys :=
                    for $m in $maps
                    return
                        maps:getHashMapValues($m, "rules")

                let $uniqueKeys := distinct-values($keys)
                let $countMap :=
                    for $key in $uniqueKeys
                    return
                        maps:createHashMapEntry($key, string(count(index-of($keys, $key))))
                for $key at $pos in $uniqueKeys
                    let $columnName := $key
                (:where $result/Row[maps:containsHashMapValue(@rules = $key]/Column[@error > $errors:OK_LEVEL]:)
                return
                <tr>
                    <td>{
                        let $id := concat("chk", $ruleCode, "-", $columnName)
                        return
                        <input type="checkbox" value="{$columnName}" id="{$id}" onclick="javascript:singleCheckboxToggle('{$id}');" />
                        }
                    </td>
                    <td>{$key}</td>
                    <td>{maps:getHashMapValue($countMap, $key)}</td>
                </tr>
              }</tbody>
        </table>
    return
        <div>
           {$resultText}
           {$resultTable}
        </div>
};

(:~
 : RESULT TABLES
 :)

declare function tables:buildResultTableTH($elements as xs:string*, $row as xs:boolean) as element(tr)* {
    <tr>
        {if ($row = true()) then <th>Row</th> else ()}
        {
    for $elem in $elements
    return <th>{$elem}</th>
    }</tr>
};

declare function tables:buildResultTableTR($ruleElems as xs:string*, $result as element(Result), $showRow as xs:boolean) as element(tr)* {
    for $row in $result/Row
        let $id := string($row/@row-id)
    return
    <tr invalid="{$row/string(@invalid)}" rules="{$row/string(@rules)}">
        {if ($showRow = true()) then <td>{$id}</td> else ()}
        {
        for $elem in $ruleElems
            let $errorClass := string($row/Column[@element = $elem]/@error)
            let $errorClass := errors:getErrorClass($errorClass)
            let $value := string($row/Column[@element = $elem]/@value)
        return
           <td class="{$errorClass}" element="{$elem}">{$value}</td>
        }
    </tr>
};

declare function tables:getSimpleResultTable($result, $rule, $metadata) as element(table) {
    let $elems := ruleutil:getRuleElements($rule)
    let $error := ruleutil:getRuleErrorMessage($rule)
    let $row := ruleutil:getRuleShowRow($rule)
    return
    <table js-class="result" class="datatable" border="1" error="{$error}">
        <thead>
        {tables:buildResultTableTH($elems, $row)}
        </thead>
        <tbody>
        {tables:buildResultTableTR($elems, $result, $row)}
        </tbody>
    </table>

};

declare function tables:getGroupByResultTable($result, $rule, $metadata) as element(table) {
    let $elems := ruleutil:getRuleElements($rule)
    let $groupBy := ruleutil:getRuleGroupBy($rule)
    let $error := ruleutil:getRuleErrorMessage($rule)
    let $keys :=
        for $row in $result/Row
            let $key :=
                for $i at $pos in $groupBy
                return
                    string($row/Column[@element = $groupBy[$pos]]/@value)
            let $key := common:sort($key)
            let $key := string-join($key, $model:GROUP_SEPARATOR)
        return $key
    let $uniqueKeys := distinct-values($keys)
    let $countKeys :=
        for $key in $uniqueKeys
        return
            maps:createHashMapEntry($key, string(count(index-of($keys, $key))))
    return
    <table border="1" js-class="result" error="{$error}">
        <thead>
            <tr>{
                for $elem in $elems
                return
                    <th>{$elem}</th>
                }
                <th>Number of records</th>
            </tr>
        </thead>
        <tbody>{
                for $i in $uniqueKeys
                    let $tds := tokenize($i, $model:GROUP_SEPARATOR)
                return
                <tr>{
                    for $elem in $tds
                    let $errorClass := errors:getErrorClass(ruleutil:getRuleErrorLevel($rule))
                    return
                        <td class="{$errorClass}">{$elem}</td>
                    }
                    <td>{maps:getHashMapValue($countKeys, $i)}</td>
                </tr>
        }</tbody>
    </table>
};

declare function tables:getMandatoryResultTable($result, $rule, $metadata) as element(table) {
    tables:getSimpleResultTable($result, $rule, $metadata)
};

declare function tables:getDuplicatesResultTable($result, $rule, $metadata) as element(table) {
    tables:getSimpleResultTable($result, $rule, $metadata)
};

declare function tables:getDatatypesResultTable($result, $rule, $metadata) as element(table) {
    tables:getSimpleResultTable($result, $rule, $metadata)
};

declare function tables:getCodelistResultTable($result, $rule, $metadata) as element(table) {
    tables:getSimpleResultTable($result, $rule, $metadata)
};
declare function tables:getMonitoringFormatResultTable($result, $rule, $metadata) as element(table) {
    let $elems := ruleutil:getRuleElements($rule)
    let $groupBy := ruleutil:getRuleGroupBy($rule)
    let $error := ruleutil:getRuleErrorMessage($rule)
    let $keys :=
        for $row in $result/Row
            let $key :=
                for $i at $pos in $groupBy
                return
                    string($row/Column[@element = $groupBy[$pos]]/@value)
            let $key := common:sort($key)
            let $key := string-join($key, $model:GROUP_SEPARATOR)
        return $key
    let $uniqueKeys := distinct-values($keys)
    let $countKeys :=
        for $key in $uniqueKeys
        return
            maps:createHashMapEntry($key, string(count(index-of($keys, $key))))
    return
    <table  border="1" js-class="result" error="{$error}">
        <thead>
            <tr>{
                for $elem in $elems
                return
                    <th>{$elem}</th>
                }
                <th>Number of records</th>
            </tr>
        </thead>
        <tbody>{
                for $i in $uniqueKeys
                    let $tds := tokenize($i, $model:GROUP_SEPARATOR)
                return
                <tr>{
                    for $elem in $tds
                    let $errorClass := errors:getErrorClass(ruleutil:getRuleErrorLevel($rule))
                    return
                        <td class="{$errorClass}">{$elem}</td>
                    }
                    <td>{maps:getHashMapValue($countKeys, $i)}</td>
                </tr>
        }</tbody>
    </table>
};

declare function tables:getMonitoringReferenceResultTable($result, $rule, $metadata) as element(table) {
   tables:getGroupByResultTable($result, $rule, $metadata)
};

declare function tables:getUomResultTable($result, $rule, $metadata) as element(table) {
    tables:getSimpleResultTable($result, $rule, $metadata)
};

declare function tables:getReferenceYearResultTable($result, $rule, $metadata) as element(table) {
    tables:getSimpleResultTable($result, $rule, $metadata)
};
declare function tables:getSamplingPeriodResultTable($result, $rule, $metadata) as element(table) {
    tables:getSimpleResultTable($result, $rule, $metadata)
};
declare function tables:getMathematicalRelationResultTable($result, $rule, $metadata) as element(table) {
    let $elems := ruleutil:getRuleElements($rule)
    let $error := ruleutil:getRuleErrorMessage($rule)
    return
    <table  border="1" js-class="result" error="{$error}">
        <thead>
            <tr>
                <th>Row</th>{
                    for $elem in $elems
                    return
                        <th>{$elem}</th>
                    }
                <th>Broken Rules</th>
            </tr>
        </thead>
        <tbody>{
            for $row in $result/Row
                let $id := string($row/@row-id)
                let $rules := maps:getHashMapValuesCSV(string($row/@rules), "rules")
            return
                <tr invalid="{$row/string(@invalid)}" rules="{$row/string(@rules)}">
                    <td>{$id}</td>
                    {
                    for $elem in $elems
                        let $errorClass := string($row/Column[@element = $elem]/@error)
                        let $errorClass := errors:getErrorClass($errorClass)
                        let $value := string($row/Column[@element = $elem]/@value)
                    return
                    <td class="{$errorClass}" element="{$elem}">{$value}</td>
                    }
                    <td>{$rules}</td>
                </tr>
        }</tbody>
    </table>
};
declare function tables:getLOQResultTable($result, $rule, $metadata) as element(table) {
    let $elems := ruleutil:getRuleElements($rule)
    let $error := ruleutil:getRuleErrorMessage($rule)
    return
    <table border="1" js-class="result" error="{$error}">
        <thead>
            <tr>
                <th>Row</th>{
                    for $elem in $elems
                    return
                        <th>{$elem}</th>
                    }
                <th>Broken Rules</th>
            </tr>
        </thead>
        <tbody>{
            for $row in $result/Row
                let $id := string($row/@row-id)
                let $rules := maps:getHashMapValuesCSV(string($row/@rules), "rules")
            return
                <tr invalid="{$row/string(@invalid)}" rules="{$row/string(@rules)}">
                    <td>{$id}</td>
                    {
                    for $elem in $elems
                        let $errorClass := string($row/Column[@element = $elem]/@error)
                        let $errorClass := errors:getErrorClass($errorClass)
                        let $value := string($row/Column[@element = $elem]/@value)
                    return
                    <td class="{$errorClass}" element="{$elem}">{$value}</td>
                    }
                    <td>{$rules}</td>
                </tr>
        }</tbody>
    </table>
};
declare function tables:getSampleDepthResultTable($result, $rule, $metadata) as element(table) {
    tables:getSimpleResultTable($result, $rule, $metadata)
};


(:~
 : ADDITIONAL TABLES
 :)

declare function tables:getAdditionalDataTypes($result, $metadata as element(Meta)) as element(div) {
    let $schema := model:getMetadataSchemaContainer($metadata)
    let $localNames := data($result//Column/@element)
    (: let $allElementsWithoutNs := common:getElementsWithoutNs($allElements) :)
    return
    <div class="table-additional">
        <p><strong>Field Definitions</strong></p>
        <table border="1" js-class="additional">
            <thead>
                <th>Field Name</th>
                <th>Data type</th>
                <th>Min size</th>
                <th>Max size</th>
                <th>Min value</th>
                <th>Max value</th>
                <th>Total digits</th>
            </thead>
            <tbody>{
            for $pn in $schema/xs:schema/xs:element
            where not(empty(index-of($localNames,fn:string($pn/@name))))
            return
                <tr>
                    <td>{ fn:string($pn/@name) }</td>
                    <td>{ fn:substring-after(fn:string($pn/xs:simpleType/xs:restriction/@base), ":") }</td>
                    <td>{ fn:string($pn/xs:simpleType/xs:restriction/xs:minLength/@value) }</td>
                    <td>{ fn:string($pn/xs:simpleType/xs:restriction/xs:maxLength/@value) }</td>
                    <td>{ fn:string($pn/xs:simpleType/xs:restriction/xs:minInclusive/@value) }</td>
                    <td>{ fn:string($pn/xs:simpleType/xs:restriction/xs:maxInclusive/@value) }</td>
                    <td>{ fn:string($pn/xs:simpleType/xs:restriction/xs:totalDigits/@value) }</td>
                </tr>
            }</tbody>
        </table>
    </div>
};

(:~
 : Build HTML table for displaying element codelist values
 : @param $codeListXmlUrl Url of DD codelists XML
 : @param $multiValueDelimiters list of multivalue elements and their delimiters
 : return HTML table elements.
 :)
declare function tables:getAdditionalCodelistTable($result, $metadata as element(Meta)) as element(div){
    let $ddTable := model:getMetadataDDTable($metadata)
    return
    <div class="table-additional">
        <p><strong>Code lists</strong></p>
        <table js-class="additional" class="datatable" border="1">
            <tr>
                <th>Field name</th>
                <th>Codelist type</th>
                <th>Codelist</th>
                <th>Multivalue delimiter <sup>*</sup></th>
            </tr>{
            let $valueLists := model:getCodelists($metadata)
            for $valueList in $valueLists/dd:value-list
                let $localName := fn:data($valueList/@element)
                let $fixedValues :=  model:getCodeListFixedValues($metadata, $valueList, false())
                let $linkToDD := model:getCodelistLink($metadata, $localName)
            return
                <tr>
                    <td>{ $localName }</td>
                    <td>{ if ($valueList/@fixed = "true") then "Fixed" else if ($valueList/@fixed = "false") then "Vocabulary" else "Suggested" }</td>
                    <td><a href="{$linkToDD}"></a>See Codelist in Data Dictionary</td>
                    <td>{ ddutil:getMultiValueDelim("test", $valueList/@element) }</td>
                </tr>
        }</table>
        <span><sup>*</sup> Note: Field where multivalue delimiter is defined can contain more than one code from the respective code list if the codes are separated by the delimiter character.</span>
    </div>
};

declare function tables:getAdditionalValueLimits($result, $metadata as element(Meta)) as element(div) {
    let $limitsUrl := $constants:LIMITS_URL
    let $limitsDoc := if (doc-available($limitsUrl)) then doc($limitsUrl) else ()

    let $table := model:getMetadataTable($metadata)
    let $dataset := model:getMetadataDataset($metadata)

    let $schema := model:getMetadataSchemaContainer($metadata)
    let $localNames := data($result//Column/@element)
    let $determinands :=
        for $column in $result/Row/Column
        where ($column/@element = "observedPropertyDeterminandCode")
        return
            string($column/@value)
    let $uniqueDeterminands := distinct-values($determinands)

    (: let $allElementsWithoutNs := common:getElementsWithoutNs($allElements) :)
    return
    <div class="table-additional">
        <p><strong>Determinand value limits</strong></p>
        <table js-class="additional" class="datatable" border="1">
            <thead>
                <th>Determinand code</th>
                <th>Minimum inclusive (>=)</th>
                <th>Minimum exclusive (>)</th>
                <th><![CDATA[Maximum inclusive (<=)]]></th>
                <th><![CDATA[Maximum exclusive (<)]]></th>
            </thead>
            <tbody>{
            for $determinand in $uniqueDeterminands
                let $limits := ddutil:getDeterminandLimits($determinand, $dataset, $table)
            return
                <tr>
                    <td>{$determinand}</td>
                    <td>{$limits/minInclusive}</td>
                    <td>{$limits/minExclusive}</td>
                    <td>{$limits/maxInclusive}</td>
                    <td>{$limits/maxExclusive}</td>
                </tr>
            }</tbody>
        </table>
    </div>
};

(:~ Build HTML list containing links to QA rules. Display result message at the end of link.
 : @param $rules List of rule elements from rules XML.
 : @param $results List of rule result codes.
 : @return HTML list of rule headings.
 :)
declare function tables:buildTableOfContents($rules as element(rule)*, $results as element()*) as element(ul) {
        <ul>{
        for $rule in $rules[contains(@code, ".") = false()]
            let $ruleCode := ruleutil:getRuleCode($rule)
            let $ruleTitle := ruleutil:getRuleTitle($rule)
        return
            <li><a href="#{$ruleCode}">{$ruleCode}.&#32;{$ruleTitle}</a>&#32;&#32;{ uiutil:getRuleResultBox($ruleCode, $results/@result) }</li>
        }</ul>
};
(:
 : ======================================================================
 :     UI HELPER methods: HELPER methods for building QA results HTML
 : ======================================================================
 :)

declare function uiutil:buildScriptHeader($rules as element(rules)) as element(h2) {
    <h2>The following { fn:count($rules//rule[not(contains(@code, '.'))]) } quality tests were made against this table - {
        fn:data($rules/@title) }</h2>
};
(:~
 : Build link to DD Table.
 : @param $schemaId DD table ID
 : @return
 :)
declare function uiutil:buildLinkToDDTable($schemaId as xs:string) as element(p) {
    <p>View detailed data definitions in <a href="{ ddutil:getDDTableUrl($schemaId) }">Data Dictionary</a></p>
};
(:~
 : Build link to DD Dataset.
 : @param $datasetId DD table ID
 : @return
 :)
declare function uiutil:buildLinkToDDDataset($datasetId as xs:string) as element(p) {
    <p>View detailed data definitions in <a href="{ ddutil:getDDDatasetUrl($datasetId) }">Data Dictionary</a></p>
};


(: Function builds HTML fragemnt for displaying successful sub rule result header.
 : @param $rule Rule element defined in rules XML.
 : @return HTML fragment.
 :)
declare function uiutil:buildSubHeader($rule as element(rule), $errLevel as xs:integer, $message as xs:string) as element(div) {
    <div>
        <h3>{$rule/@code} { $rule/title} </h3>
        <p>{ fn:data($rule/errorMessage) }</p>
        { if ($errLevel = $errors:BLOCKER_LEVEL) then
            <div style="color:red">BLOCKER - {ruleutil:getRuleErrorMessage($rule)} { $message }</div>
          else if ($errLevel = $errors:ERROR_LEVEL) then
            <div style="color:red">ERROR - {ruleutil:getRuleErrorMessage($rule)} { $message }</div>
          else if ($errLevel = $errors:WARNING_LEVEL) then
            <div style="color:orange">WARNING - {ruleutil:getRuleErrorMessage($rule)} { $message }</div>
          else if ($errLevel = $errors:UNKNOWN_LEVEL) then
            <div style="color:gray">UNKNOWN - {ruleutil:getRuleErrorMessage($rule)} { $message }</div>
          else if ($errLevel = $errors:EXCEPTION_LEVEL) then
            <div style="color:deepskyblue">INFO - {ruleutil:getRuleErrorMessage($rule)} { $message }</div>
          else if ($errLevel = $errors:OK_LEVEL) then
            <div style="color:green">OK - data passed the test.</div>
          else ()
        }
    </div>
};
declare function uiutil:getErrorClass($errLevel as xs:integer) as xs:string {
    if ($errLevel = $errors:BLOCKER_LEVEL) then
        "blocker"
    else if ($errLevel = $errors:ERROR_LEVEL) then
        "error"
    else if ($errLevel = $errors:WARNING_LEVEL) then
        "warning"
    else if ($errLevel = $errors:EXCEPTION_LEVEL) then
        "info"
    else if ($errLevel = $errors:UNKNOWN_LEVEL) then
        "unknown"
    else if ($errLevel = $errors:OK_LEVEL) then
        "ok"
    else ()
};
declare function uiutil:buildHeader($rule as element(rule), $errLevel as xs:integer, $message as xs:string) as element(div) {
    let $errClass := uiutil:getErrorClass($errLevel)
    return
    <div>
        { uiutil:buildTitle(ruleutil:getRuleCode($rule), ruleutil:getRuleTitle($rule)) }
        { uiutil:buildDescr(ruleutil:getRuleDescription($rule)) }
        { if ($errLevel = $errors:BLOCKER_LEVEL) then
            <div style="color:{uiutil:getErrorColor($errors:BLOCKER_LEVEL)}">BLOCKER - {ruleutil:getRuleErrorMessage($rule)} { $message }</div>
          else if ($errLevel = $errors:ERROR_LEVEL) then
            <div style="color:{uiutil:getErrorColor($errors:ERROR_LEVEL)}">ERROR - {ruleutil:getRuleErrorMessage($rule)} { $message }</div>
          else if ($errLevel = $errors:WARNING_LEVEL) then
            <div style="color:{uiutil:getErrorColor($errors:WARNING_LEVEL)}">WARNING - {ruleutil:getRuleErrorMessage($rule)} { $message }</div>
          else if ($errLevel = $errors:UNKNOWN_LEVEL) then
            <div style="color:{uiutil:getErrorColor($errors:UNKNOWN_LEVEL)}">UNKNOWN - {ruleutil:getRuleErrorMessage($rule)} { $message }</div>
          else if ($errLevel = $errors:EXCEPTION_LEVEL) then
            <div style="color:{uiutil:getErrorColor($errors:EXCEPTION_LEVEL)}">INFO - {ruleutil:getRuleErrorMessage($rule)} { $message }</div>
          else if ($errLevel = $errors:OK_LEVEL) then
            <div style="color:{uiutil:getErrorColor($errors:OK_LEVEL)}">OK - data passed the test.</div>
          else ()
        }
    </div>
};
declare function uiutil:getElementValue($row as element(), $element as xs:string, $delimiter as xs:string)
as xs:string
{
    fn:string-join(uiutil:getElementValues($row/*[name()=$element]), $delimiter)
};
declare function uiutil:getElementValueSorted($row as element(), $element as xs:string, $delimiter as xs:string)
as xs:string
{
    string-join(common:sort(uiutil:getElementValues($row/*[name()=$element])), $delimiter)
};
declare function uiutil:getElementValues($elements as element())
as xs:string*
{
    for $elem in $elements
    where not(common:isEmpty($elem))
    return
        normalize-space(string($elem))
};
(:~
 : Return the color of error message.
 : @param $errLevel error level (0 - EXCEPTION, 1 - WARNING, 2 - ERROR, 3 - BLOCKER)
 : @rteturn color name
 :)
declare function uiutil:getErrorColor($errLevel as xs:integer) as xs:string {
    if ($errLevel = $errors:WARNING_LEVEL) then
        "orange"
    else if ($errLevel = $errors:EXCEPTION_LEVEL) then
        "deepskyblue"
    else if ($errLevel = $errors:BLOCKER_LEVEL) then
        "red"
    else if ($errLevel = $errors:ERROR_LEVEL) then
        "red"
    else if ($errLevel = $errors:OK_LEVEL) then
        "green"
    else if ($errLevel = $errors:UNKNOWN_LEVEL) then
        "gray"
    else ()
};

(:~
 : Build HTML title element
 : @param $rule Rule element defined in rules XML.
 : @return HTML fragment
 :)
declare function uiutil:buildTitle($ruleCode as xs:string, $title as xs:string) as element(h2) {
    <h2><a name="{$ruleCode}">{$ruleCode}.</a>&#32;{$title}</h2>
};
(:~
 : Build HTML descritoption element
 : @param $rule Rule element defined in rules XML.
 : @return HTML fragment
 :)
declare function uiutil:buildDescr($description) as element(p) {
    <p>{$description}</p>
};

(:~
 : Build HTML title and table with invalid rows for sub-rule.
 : @param $ruleDef Rule code in rules XML.
 : @param $result HTML table tr elements with invalid values.
 : @param $ruleElements List of XML elements used in this rule
 : @return HTML div element.
 :)
declare function uiutil:buildSubRuleFailedResult($rule as element(rule), $result as element(tr)*, $ruleElements as xs:string*)
as element(div){
    <div>
        { uiutil:buildSubHeader($rule, $errors:ERROR_LEVEL, "") }
        <table border="1" class="datatable" error="{ ruleutil:getRuleErrorMessage($rule) }">
        { tables:buildResultTableTH($ruleElements, ruleutil:getRuleShowRow($rule)) }
        { $result }
        </table>
    </div>
};
(:~
 : Create rule result message displayed in the list of rules at the end of each rule.
 : @param $errorCode Rule code.
 : @param $results Rule results codes ("1-ok")
 : return HTML containing rule result message
 :)
declare function uiutil:getRuleResultBox($ruleCode as xs:string, $results as xs:string*) as element(span)*{
    for $result in $results
        let $resultCode := fn:substring-after($result, "-")
    where fn:substring-before($result, "-") = $ruleCode
    return
        if($resultCode = "ok") then
            <span style="background-color:green;font-size:0.8em;color:white;">OK</span>
        else if ($resultCode = "info") then
            <span style="background-color:deepskyblue;font-size:0.8em;color:white;">INFO</span>
        else if($resultCode = "blocker") then
            <span style="background-color:red;font-size:0.8em;color:white;">BLOCKER</span>
        else if($resultCode = "error") then
            <span style="background-color:red;font-size:0.8em;color:white;">ERROR</span>
        else if($resultCode = "warning") then
            <span style="background-color:orange;font-size:0.8em;color:white;">WARNING</span>
        else if($resultCode = "unknown") then
            <span style="background-color:gray;font-size:0.8em;color:white;">UNKNOWN</span>
        else if($resultCode = "skipped") then
            <span style="background-color:brown;font-size:0.8em;color:white;">SKIPPED</span>
        else
            <span/>
};
(:~
 : Build rule results code containg rule code and result message eg.: "1-ok" or "2-error"
 : @param $errorCode Rule code.
 : @param $result Result code: blocker, error, warning, exception, ok
 : @return Rule result code.
 :)
declare function uiutil:getResultCode($ruleCode as xs:string, $result as xs:string) as xs:string {
   concat($ruleCode, "-", $result)
};

declare function uiutil:getCheckbox($ruleCode as xs:string, $columnName as xs:string) as element(input) {
    <input type="checkbox" value="{$columnName}" onclick="javascript:singleCheckboxToggle('{$ruleCode}');" />
};
(:~
 : Return rule results from span result attribute.
 : @param $results List of rule results as HTML fragments starting with span element.
 : @return List of rule results.
 :)
declare function uiutil:getResultCodes($results as element(div)*)
as xs:string*
{
    for $result in $results
    return
        if (fn:string-length($result/@result) > 0) then
            fn:string($result/@result)
        else if (fn:string-length($result/div/@result) > 0) then
            fn:string($result/div/@result)
        else
            ()
};
(:~
 : Build HTML table for logical rules errros.
 : @param $ruleDefs List of rule elements
 : @return HTML table element.
 :)
declare function uiutil:buildRulesTable($ruleDefs as element(rule)*) as element(table) {
    <table class="datatable" border="1">
        <tr>
            <th>Code</th>
            <th>Rule violated</th>
            {
            if(count($ruleDefs//*[name()="message2"]) > 0) then
                <th>Description</th>
            else
                <th style="display:none"/>
            }
        </tr>{
            for $ruleDef in $ruleDefs
            let $value := fn:substring-after($ruleDef/@code, ".")
            return
                <tr>
                    <td>{ fn:data($value) }</td>
                    <td>{ fn:data($ruleDef/message) }</td>
                    {
                    if(count($ruleDefs//*[name()="message2"]) > 0) then
                        <td>{ fn:data($ruleDef/message2) }</td>
                    else
                        <td style="display:none"/>
                    }
                </tr>
    }</table>
};

declare function uiutil:buildEnvelopeTable($envelope as document-node(), $rule as element(rule), $result as element(Result)) {
    let $errLevel := errors:getMaxTableError($result)
    let $ruleElems := ruleutil:getRuleElements($rule)
    let $ruleCode := ruleutil:getRuleCode($rule)
    let $errClass := uiutil:getErrorClass($errLevel)

    let $fakeResult := $result/@fake = "true"

    return
    if ($fakeResult) then
        <div js-class="parent" ruleCode="{ruleutil:getRuleCode($rule)}" result="{ uiutil:getResultCode(ruleutil:getRuleCode($rule), $errClass) }">
            { uiutil:buildHeader($rule, $errLevel, "") }
            { tables:buildTable($tables:SUMMARY, $rule, $result, <Meta></Meta>) }
        </div>
    else if ($errLevel > $errors:OK_LEVEL) then
        <div js-class="parent" ruleCode="{ruleutil:getRuleCode($rule)}" result="{ uiutil:getResultCode(ruleutil:getRuleCode($rule), $errClass) }">
            { uiutil:buildHeader($rule, $errLevel, "") }
            { tables:buildTable($tables:SUMMARY, $rule, $result, <Meta></Meta>) }
            <div js-class="container">
                { tables:buildTable($tables:RESULT, $rule, $result, <Meta></Meta>) }
                { tables:buildTable($tables:ADDITIONAL, $rule, $result, <Meta></Meta>) }
            </div>
        </div>
    else
    <div result="{ uiutil:getResultCode(ruleutil:getRuleCode($rule), $errClass) }">
        { uiutil:buildHeader($rule, $errLevel, "") }
    </div>
};

declare function uiutil:buildTable($schema as document-node(), $schemaContainer as document-node(), $rule as element(rule), $result as element(Result), $metadata as element()) as element(div) {
    let $errLevel := errors:getMaxTableError($result)
    let $ruleElems := ruleutil:getRuleElements($rule)
    let $ruleCode := ruleutil:getRuleCode($rule)
    let $errClass := uiutil:getErrorClass($errLevel)

    return
    if ($errLevel > $errors:OK_LEVEL) then
        <div js-class="parent" ruleCode="{ruleutil:getRuleCode($rule)}" result="{ uiutil:getResultCode(ruleutil:getRuleCode($rule), $errClass) }">
            { uiutil:buildHeader($rule, $errLevel, "") }
            { tables:buildTable($tables:SUMMARY, $rule, $result, $metadata) }
            <div js-class="container" style="display:none">
                { tables:buildTable($tables:RESULT, $rule, $result, $metadata) }
                { tables:buildTable($tables:ADDITIONAL, $rule, $result, $metadata) }
            </div>
            <div style="margin-top:0.5em;margin-bottom:0.5em;">
                {uiutil:showAndHideRecordsButton($ruleCode)}
            </div>
        </div>
    else
    <div result="{ uiutil:getResultCode(ruleutil:getRuleCode($rule), $errClass) }">
        { uiutil:buildHeader($rule, $errLevel, "") }
    </div>
};

declare function uiutil:showAndHideRecordsButton($ruleCode as xs:string) as element(a) {
(:onclick="javascript:toggle('buttonId-{$ruleCode}');" >:)
    <a id="buttonId-{$ruleCode}"
       class="button"
       href="javascript:void(0)"
       onclick="javascript:toggle('{$ruleCode}');" >
       Show records
     </a>
};

declare function uiutil:buildHeaderSection($rules as element(rules), $result, $schemaId, $dataset as xs:boolean) {
    let $linkToDD :=
        if ($dataset = true()) then
            uiutil:buildLinkToDDDataset($schemaId)
        else
            uiutil:buildLinkToDDTable($schemaId)

   return
    (uiutil:javaScript(),
    uiutil:getCSS(),
    uiutil:buildScriptHeader($rules),
    tables:buildTableOfContents($rules//rule, $result),
    $linkToDD)
};
(:~
 : JavaScript
 :)
declare function uiutil:javaScript() as element(script) {
    <script type="text/javascript">
       <![CDATA[
            function getChildWithAttribute(parent, attribute, value) {
                var allElements = parent.getElementsByTagName('*');
                for (var i = 0; i != allElements.length; i++) {
                  if (allElements[i].getAttribute(attribute) !== null) {
                    if (allElements[i].getAttribute(attribute) === value) {
                        return allElements[i];
                    }
                  }
                }
                return null;
              }

            function toggle(ruleCode) {
                var parent = document.querySelector('div[ruleCode = "' + ruleCode +'"]')
                var button = parent.querySelector('a[id = "buttonId-' + ruleCode +'"]')

                var summaryTable = parent.querySelector('div table[js-class = "summary"]')
                var containerDiv = parent.querySelector('div[js-class = "container"]')
                var resultTable = containerDiv.querySelector('table[js-class = "result"]')

                var type = null;
                if (summaryTable !== null) {
                    type = summaryTable.getAttribute("type");
                }
                if (containerDiv.style.display === "none") {
                    containerDiv.style.display = "block";
                    showAllRecords(summaryTable, resultTable, type);
                    button.innerHTML = "Hide records";
                }
                else {
                    containerDiv.style.display = "none";
                    hideAllRecords(summaryTable, resultTable, type);
                    button.innerHTML = "Show records";
                }
            }

            function showAllRecords(summaryTable, resultTable, type) {
                if (summaryTable !== null) {
                    var inputElements = summaryTable.getElementsByTagName('input');
                    for (var c = 0; c != inputElements.length; c++) {
                        inputElements[c].checked=true;
                    }
                    for (var c = 0; c != inputElements.length; c++) {
                        var value = inputElements[c].value
                        if (type === "rules") {
                            checkboxToggleRules(summaryTable, resultTable);
                        }
                        else if (type === "elements") {
                            checkboxToggleElements(summaryTable, resultTable);
                        }
                        else if (type === "values") {
                            checkboxToggleValues(summaryTable, resultTable);
                        }
                    }
                } else {
                    var resultRows = resultTable.querySelectorAll('tr')
                    resultTable.style.display = "table";
                    for (i = 0; i != resultRows.length; i++) {
                        resultRows[i].style.display = "table-row";
                    }
                }
            }

            function hideAllRecords(summaryTable, resultTable, type) {
                if (summaryTable !== null) {
                    var inputElements = summaryTable.getElementsByTagName('input');
                    for (var c = 0; c != inputElements.length; c++) {
                        inputElements[c].checked=false;
                    }
                    for (var c = 0; c != inputElements.length; c++) {
                        var value = inputElements[c].value
                        if (type === "rules") {
                            checkboxToggleRules(summaryTable, resultTable);
                        }
                        else if (type === "elements") {
                            checkboxToggleElements(summaryTable, resultTable);
                        }
                        else if (type === "values") {
                            checkboxToggleValues(summaryTable, resultTable);
                        }
                    }
                } else {
                    var resultRows = resultTable.querySelectorAll('tr')
                    resultTable.style.display = "none";
                    for (i = 0; i != resultRows.length; i++) {
                        resultRows[i].style.display = "table-row";
                    }
                }
            }

            function checkboxToggleElements(summaryTable, resultTable) {
                var trs = resultTable.getElementsByTagName("tbody")[0].getElementsByTagName("tr");
                for (var k = 0; k != trs.length; k++) {
                    trs[k].style.display = "none";
                }
                resultTable.parentNode.style.display = "none";
                var inputElements = summaryTable.getElementsByTagName('input');

                for (var c = 0; c != inputElements.length; c++) {
                    if (inputElements[c].checked) {
                        resultTable.style.display = "table";
                        resultTable.parentNode.style.display = "block";
                        for (var i = 0; i != trs.length; i++) {
                            var tds = trs[i].getElementsByTagName("td");
                            for (var j = 1; j != tds.length; j++) {
                                if(tds[j].innerHTML.length != 0){
                                    if(tds[j].getAttribute("element") == inputElements[c].value) {
                                        trs[i].style.display = "table-row";
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            function checkboxToggleRules(summaryTable, resultTable) {
                var trs = resultTable.getElementsByTagName("tbody")[0].getElementsByTagName("tr");
                for (var k = 0; k != trs.length; k++) {
                    trs[k].style.display = "none";
                }
                resultTable.parentNode.style.display = "none";
                var inputElements = summaryTable.getElementsByTagName('input');

                for (var c = 0; c != inputElements.length; c++) {
                    if (inputElements[c].checked) {
                        resultTable.style.display = "table";
                        resultTable.parentNode.style.display = "block";
                        resultTable.parentNode.parentNode.style.display = "block";

                        for (var i = 0; i != trs.length; i++) {
                            var rules = trs[i].getAttribute("rules")
                            if (rules !== null) {
                                if (rules.indexOf(inputElements[c].value) != -1) {
                                    trs[i].style.display = "table-row";
                                } else if (inputElements[c].value === "Invalid types") {
                                    if (trs[i].getAttribute("invalid") === "true") {
                                        trs[i].style.display = "table-row";
                                    }
                                }
                            }
                        }
                    }
                }
            }

            function checkboxToggleValues(summaryTable, resultTable) {
                var trs = resultTable.querySelectorAll('tbody tr')
                for (var k = 0; k != trs.length; k++) {
                    trs[k].style.display = "none";
                }
                resultTable.parentNode.style.display = "none";
                var elementName = summaryTable.querySelectorAll('thead tr th')[1].innerHTML

                var inputElements = summaryTable.getElementsByTagName('input');
                for (var c = 0; c != inputElements.length; c++) {
                    if (inputElements[c].checked) {
                        resultTable.style.display = "table";
                        resultTable.parentNode.style.display = "block";

                        for (var i = 0; i != trs.length; i++) {
                            var tds = trs[i].getElementsByTagName("td");
                            for (var j = 1; j != tds.length; j++) {
                                if(tds[j].innerHTML.length != 0){
                                    if (tds[j].getAttribute("element") == elementName) {
                                        if (tds[j].innerHTML === inputElements[c].value) {
                                            trs[i].style.display = "table-row";
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            function singleCheckboxToggle(ruleCode) {
                var parent = document.querySelector('div[ruleCode = "' + ruleCode +'"]')
                if (parent !== null) {
                    var summaryTable = parent.querySelector('div table[js-class = "summary"]')
                    var type = summaryTable.getAttribute("type");
                    var containerDiv = parent.querySelector('div[js-class = "container"]')
                    var resultTable = containerDiv.querySelector('table[js-class = "result"]')
                    if (type === "rules") {
                        checkboxToggleRules(summaryTable, resultTable);
                    }
                    else if (type === "elements") {
                        checkboxToggleElements(summaryTable, resultTable);
                    }
                    else if (type === "values") {
                        checkboxToggleValues(summaryTable, resultTable);
                    }
                }
            }
        ]]>
    </script>
};

declare function uiutil:getCSS() as element(style) {
<style><![CDATA[
    .button {
       background-image: -moz-linear-gradient(center bottom , #CFCFCF 16%, #FCFCFC 79%);
       border: 1px solid #000000;
       border-radius: 5px 5px 5px 5px;
       color: #000000;
       padding: 2px 5px;
       text-decoration: none;
    }
    .error { color:red; }
    .ok { color:green; }
    .info { color:deepskyblue; }

    .td-blocker { color:red; }
    .td-error { color:red; }
    .td-warning { color:orange; }
    .td-unknown { color:gray; }
    .td-info,.td-exception { color:deepskyblue; }
       ]]>
</style>
};


(:~
 : Return element name without namespace prefix
 : @param $seq sequence of strings
 : @return Boolean value.
 :)
declare function common:getElemNameWithoutNs($elemName as xs:string) as xs:string {
    if (fn:contains($elemName, ":")) then fn:substring-after($elemName, ":") else $elemName
};

(:~
 : Return element names with namespace prefix
 : @param $elemNames sequence of strings
 : @return Boolean value.
 :)
declare function common:getElemNamesWithNs($elemNames as xs:string*, $ns as xs:string) as xs:string* {
    for $elemName in $elemNames
    return
        if (fn:contains($elemName, ":")) then $elemName else fn:concat($ns, $elemName)
};
declare function common:getNameWithPrefix($prefix as xs:string, $localName as xs:string) as xs:string {
    concat($prefix, ":", $localName)
};
(:~
 : Checks if sequence contains given string
 : @param $seq sequence of strings
 : @param $str string to find from sequence
 : @return Boolean value.
 :)
declare function common:containsStr($seq as xs:string*, $str as xs:string) as xs:boolean {
     fn:not(fn:empty(fn:index-of($seq, $str)))
};
(:~
 : Checks if sequence contains given boolean
 : @param $seq sequence of booleans
 : @param $bool booelan to find from sequence
 : @return Boolean value.
 :)
declare function common:containsBoolean($seq as xs:boolean*, $booelan as xs:boolean) as xs:boolean {
     fn:not(fn:empty(fn:index-of($seq, $booelan)))
};
(:~
 : Checks if element value is empty or not.
 : @param $value Element value.
 : @return Boolean value.
 :)
declare function common:isEmpty($value) as xs:boolean {
    if (empty($value) or normalize-space(string($value)) = "") then
         true()
    else
        false()
};
(:~
 : Checks if XML element is missing or not.
 : @param $node XML node
 : return Boolean value.
 :)
declare function common:isMissing($node as node()*) as xs:boolean {
    if (fn:count($node) = 0) then
         fn:true()
    else
        fn:false()
};
(:~
 : Checks if XML element is missing or value is empty.
 : @param $node XML element or value
 : return Boolean value.
 :)
declare function common:isMissingOrEmpty($node as item()*) as xs:boolean {
    if (common:isMissing($node)) then
        fn:true()
    else
        common:isEmpty(string-join($node, ""))
};
(:~
 : Function removes the file part from the end of URL and appends 'xml' for getting the envelope xml description.
 : @param $url XML File URL.
 : @return Envelope node.
 :)
declare function common:getEnvelopeXML($url as xs:string) as node()? {
    let $col := fn:tokenize($url,'/')
    let $col := fn:remove($col, fn:count($col))
    let $ret := fn:string-join($col,'/')
    let $ret := fn:concat($ret,'/xml')
    return
        if (fn:doc-available($ret)) then
            doc($ret)
        else if ($xmlutil:TEST_ENV) then
                <envelope released="true" xsi:noNamespaceSchemaLocation="http://cdr.eionet.europa.eu/schemas/envelope-metadata.xsd">
                    <title>Test Envelope</title>
                    <countrycode>MZ</countrycode>
                </envelope>
        else ()
};
(:~
 : Function reads reproting country code from envelope xml. Returns empty string if envelope XML not found.
 : @param $url XML file URL.
 : @return ECountry code.
 :)
declare function common:getReportingCountry($url as xs:string) as xs:string {
    let $countryCode := common:getEnvelopeXML($url)/countrycode
    return
        if ($countryCode) then
            $countryCode
        else ""
};
(:~
 : Remove leading or trailing chars from the string.
 : @param $s Original string.
 : @param $c String to be reomved.
 : @return String value.
 :)
declare function common:removeChars($s as xs:string, $c as xs:string, $fromTrailing as xs:boolean) as xs:string {
    let $idx := if ($fromTrailing) then string-length($s) else 1
    let $new_s := if ($fromTrailing) then substring($s, 1, $idx - 1) else substring-after($s, $c)
    let $new_c := substring($s,$idx,1)
    let $new_c2 := substring($s,$idx,2)

    return
        if ($new_c = $c and $new_c2 != "0.") then
            common:removeChars($new_s , $c , $fromTrailing)
        else
            $s
};
(:~
 : Count total digits of the number. Comma, period or other special caharacter
 : and leading or trailing zeros are not considered as a digit.
 : @param $s Original number (in string type).
 : @return Number of digits.
 :)
declare function common:countTotalDigits($s as xs:string ) as xs:integer {
    let $s := replace($s, ",", ".")

    (: remove trailing + or -  :)
    let $s:=
        if (fn:starts-with($s,"+")) then
            substring-after($s,"+")
        else if (fn:starts-with($s,"-")) then
            substring-after($s,"-")
        else
            $s

    (: remove leading zeros :)
    let $s :=  if (fn:starts-with($s,"0")) then string(common:removeChars($s, "0", false())) else $s
    (: remove trailing zeros :)
    let $s :=  if (fn:ends-with($s,"0")) then string(common:removeChars($s, "0", true())) else $s
    (: remove decimal indicator :)
    let $s := replace($s,"\.","")

    return
        string-length($s)
};

(:~
 : Function for sort sequences.
 : @param $seq Sequence of items.
 : @return Sorted sequence.
 :)
declare function common:sort($seq as item()*) as item()* {
   for $item in $seq
   order by $item
   return $item
 };
 (:~
  : Removes namespaces from the element names.
  : @param $allElements List of XML elements.
  : @return List of XML elemnets without namespaces.
  :)
 declare function common:getElementsWithoutNs($allElements as xs:string*)  as xs:string* {
    for $elem in $allElements
    return
        fn:substring-after($elem, ":")
 };
(:~
 : Convaert list of booleans into list of strings.
 : @param $booleanValues List of boolean values
 : @return List of string values.
 :)
declare function common:castBooleanSequenceToStringSeq($booleanValues as xs:boolean*) as xs:string* {
    for $value in $booleanValues
    return
        string($value)
};
(:~
 : Get the list of distinc errror codes in ascending order from the semicolon separated string of error codes.
 : @param $allErrors Semicolon separated string of error codes.
 : @return The list of error codes.
 :)
declare function common:getParsedErrorCodes($allErrors as xs:string) as xs:integer* {
    let $errors := fn:reverse(fn:distinct-values(fn:tokenize($allErrors, ";")))
    for $e in $errors
    let $strE := substring-after(normalize-space($e), ".")
    where $strE!=""
    order by fn:number($e) ascending
    return
        $strE
};
(:~
 : Get the error codes in correct order.
 : @param $allErrors List of error codes.
 : @return List of error codes.
 :)
(:declare function xmlutil:getOrderedErrorCodes($allErrors as xs:string*)
as xs:integer
{
    let $errors := fn:reverse(fn:distinct-values(fn:tokenize($allErrors, ";")))
    for $e in $allErrors
    order by fn:number($e) ascending
    return
        $e
};:)
(:~
 : Get element all error codes.
 : @param $errCodes List of all error codes.
 : @param $elemName XML element name.
 : @return List error codes relevant for given XML element.
 :)
declare function common:getElemLogicalErrors($errCodes as xs:string*, $elemName as xs:string) as xs:string* {
    for $errCode in $errCodes
    let $errCodeTokens := fn:tokenize($errCode, "#")
    let $errcode :=  if (not(empty(index-of($errCodeTokens, $elemName)))) then $errCodeTokens[1] else ""
    where string-length($errcode) > 0
    return
        $errcode
};(:~
 : Parse and clean element error codes. Return only distinct values.
 : @param $errCodes List of all error codes.
 : @return List of distinct error codes
 :)
declare function common:getCleanedElemErrors($errors as xs:string*) as xs:string* {
    fn:reverse(fn:distinct-values(common:getParsedElemErrors($errors)))
};
(:~
 : Parse element error codes and element names (input list is in formaat: errorCode#elem1Name#elem2Name). Return only the list of error codes.
 : @param $errCodes List of all error codes and element names.
 : @return List of error codes
 :)
declare function common:getParsedElemErrors($errors as xs:string*) as xs:string* {
    for $error in $errors
    let $errTokens := fn:tokenize($error, "#")
    return
        $errTokens[1]
};
(:~
 : Get error messages for sub rules.
 : @param $ruleDefs Rule elements from Rules XML definition.
 : @param $ruleCode Parent rule code
 : @param $subRuleCodes List of sub rule codes.
 : @return List of rule elements matching to sub rule codes.
 :)
declare function common:getSubRuleDefs($ruleDefs as element(rule)*, $ruleCode as xs:string, $subRuleCodes as xs:string*) as element(rule)* {
    for $subRuleCode in $subRuleCodes
        for $ruleDef in $ruleDefs[@code = concat($ruleCode, ".", $subRuleCode)]
            return $ruleDef
};


declare function envelope-common:checkEmptyXML($source_url, $envelopeXml as document-node(), $rule as element(rule)) {
    let $wrongXmls :=
        for $xml in $envelopeXml//file[@type="text/xml"]
        let $tmpDoc := doc(xmlutil:getAuthenticatedUrl($source_url, $xml/string(@link)))
        where (count($tmpDoc//*) = 1)
        return $xml/@name
    return
    <Result> {
        for $file at $pos in $envelopeXml//file[@type="text/xml"]
        return
            <Row row-id="{$pos}">{
            let $errorLevel :=
                if ($wrongXmls = $file/@name) then
                    ruleutil:getRuleErrorLevel($rule)
                else
                    string($errors:OK_LEVEL)
               let $res := (
                    1,
                    model:getColumn("File name", string($file/@name), $errors:OK_LEVEL),
                    model:getColumn("Status", errors:getErrorName($errorLevel), $errorLevel)
                    )
                return
                    $res
            }</Row>
    }</Result>
};
declare function envelope-common:checkEmptyEnvelope($envelopeXml as document-node(), $rule as element(rule)) {
    let $result :=
    if (count($envelopeXml//file[@type="text/xml"]) = 0) then
            <Result fake="true"><Row><Column error="{$errors:BLOCKER_LEVEL}"></Column></Row></Result>
        else
            <Result fake="true"><Row><Column error="{$errors:OK_LEVEL}"></Column></Row></Result>
    return $result
};




declare function validatorutil:validateTypes($metadata as element(Meta), $row as element(), $localNames as xs:string*) {
    let $invalidTypes :=
        for $i in $localNames
        let $value := $row/*[local-name() = $i]
        where empty(model:getValueFromMetaType($metadata, $i, $row))
        return true()
    return $invalidTypes = true()
};

(:~
 : Goes through all elements in one row and reads the data type values.
 : Returns a map, where key = element name and value is a list of true/false values for each entry (normally only 1 value if it is not multivalue element)
 : @param $row XML Row element to be checked.
 : @param $elemSchemaUrl XML Schema in DD containing elem defs.
 : @param $allElements List of all element names to be checked.
 : @return List of invalid element names and invalid value true/false indexes(in case of multivalue elments).
 :)
declare function validatorutil:getInvalidDataTypeValues($row as element(), $schema as document-node(), $allElements as xs:string*, $exceptions as element(exceptions)) as xs:string* {
    for $elemName in $allElements
    let $isInvalidValues := validatorutil:isInvalidDatatype($row, $elemName, $schema/xs:schema, $exceptions)
    where not(empty(index-of($isInvalidValues, fn:true())))
    return
        maps:createHashMapEntry($elemName, common:castBooleanSequenceToStringSeq($isInvalidValues))
};

(:~
 : Check if the node exists and it has correct datatype. Return the list of boolean values (TRUE if everything is OK, otherwise FALSE).
 : @param $row XML Row element to be checked.
 : @param $elementName XML element name to be checked
 : @param $schemaDoc xs:schema element from XML Schema
 : @return List of boolean values (valid/invalid tokens)
 :)
declare function validatorutil:isInvalidDatatype($row as element(), $elementName as xs:string, $schemaDoc as element(xs:schema), $exceptions as element(exceptions)) as xs:boolean* {
    let $elements :=  $row/*[name()=$elementName]
    for $elem in $elements
        let $isMissing:= common:isMissing($elem)
        let $value:= if($isMissing = fn:true()) then fn:string("") else fn:normalize-space(string($elem))

        let $elemSchemaDef := $schemaDoc//xs:element[@name=$elem/local-name()]/xs:simpleType/xs:restriction
        let $datatype := $elemSchemaDef/@base

        let $determinand :=  fn:lower-case($row/*[local-name() = "Determinand_Nutrients"][1])

        let $isInvalid :=
            if ($value="") then fn:false()
            else if(string($datatype)="xs:string") then
                validatorutil:isInvalidString($value, $elemSchemaDef, $exceptions)
            else if(string($datatype)="xs:boolean") then
                validatorutil:isInvalidBoolean($value, $elemSchemaDef)
            else if(string($datatype)="xs:decimal") then
                validatorutil:isInvalidDecimal($value, $elemSchemaDef)
            else if(string($datatype)="xs:float") then
                validatorutil:isInvalidFloat($value, $elemSchemaDef, $determinand)
            else if(string($datatype)="xs:double") then
                validatorutil:isInvalidDouble($value, $elemSchemaDef)
            else if(string($datatype)="xs:integer") then
                validatorutil:isInvalidInteger($value, $elemSchemaDef)
            else if(string($datatype)="xs:date" and  string-length($value)>0) then
                validatorutil:isInvalidDate($value, $elemSchemaDef)
            else
                fn:false()
    return $isInvalid
};
(:~
 : Check minsize and maxsize for String values.
 : @param $value Element value
 : @param $schemaDef xs:restriction element from XML Schema
 : return True if element is invalid.
 :)
declare function validatorutil:isInvalidString($value as xs:string, $schemaDef as element(xs:restriction), $exceptions as element(exceptions)) as xs:boolean {
    let $min_size := $schemaDef/xs:minLength/@value
    let $max_size := $schemaDef/xs:maxLength/@value

    let $minException := $exceptions/MinLength
    let $maxException := $exceptions/MaxLength

    let $intMin := if ($min_size castable as xs:integer) then fn:number($min_size) else $errors:INVALID_NUMBER
    let $intMax := if ($max_size castable as xs:integer) then fn:number($max_size) else $errors:INVALID_NUMBER

    let $isInvalid :=
        if ($intMin != $errors:INVALID_NUMBER and string-length($value) < $intMin) then
            if ($minException) then
                false()
            else
                true()
        else
            false()

    let $isInvalid :=
        if ($isInvalid = fn:false()) then
            if ($intMax != $errors:INVALID_NUMBER and string-length($value) > $intMax) then
                if ($maxException) then
                    false()
                else
                    true()
            else
                fn:false()
        else
            $isInvalid
    return
        $isInvalid
};
(:~
 : Check boolean values.
 : @param $value Element value
 : @param $schemaDef xs:restriction element from XML Schema
 : return True if element value is invalid.
 :)
declare function validatorutil:isInvalidBoolean($value as xs:string, $schemaDef as element(xs:restriction))
as xs:boolean
{
    let $isInvalid :=
        if ($value castable as xs:boolean or common:containsStr($xmlutil:ALLOWED_BOOLEAN_VALUES, fn:lower-case($value))) then
            fn:false()
        else
            fn:true()
    return
        $isInvalid
};
(:~
 : Check decimal values - min/max values, total digits.
 : @param $value Element value
 : @param $schemaDef xs:restriction element from XML Schema
 : return True if element is invalid.
 :)
declare function validatorutil:isInvalidDecimal($value as xs:string, $schemaDef as element(xs:restriction))
as xs:boolean
{
    let $min_val := $schemaDef/xs:minInclusive/@value
    let $max_val := $schemaDef/xs:maxInclusive/@value
    let $totalDigits := $schemaDef/xs:totalDigits/@value

    let $decimalMinVal := if ($min_val castable as xs:decimal) then fn:number($min_val) else $errors:INVALID_NUMBER
    let $decimalMaxVal := if ($max_val castable as xs:decimal) then fn:number($max_val) else $errors:INVALID_NUMBER
    let $intTotalDigits := if ($totalDigits castable as xs:integer) then fn:number($totalDigits) else $errors:INVALID_NUMBER
    let $decimalValue := if ($value castable as xs:decimal or $value castable as xs:float) then fn:number($value) else $errors:INVALID_NUMBER

    let $invalid := ()
    (: the value can be xs:decimal or s:float :)
    let $invalid := if($value castable as xs:decimal or $value castable as xs:float  or  $value = "") then  $invalid else fn:insert-before($invalid,1,fn:true())

    let $invalid := if( $decimalMinVal=$errors:INVALID_NUMBER or $decimalValue=$errors:INVALID_NUMBER or $value = "" or $decimalValue >= $decimalMinVal) then $invalid else fn:insert-before($invalid,1,fn:true())
    let $invalid := if( $decimalMaxVal=$errors:INVALID_NUMBER or $decimalValue=$errors:INVALID_NUMBER or $value = "" or $decimalValue <= $decimalMaxVal) then $invalid else fn:insert-before($invalid,1,fn:true())
    (: check totalDigits only, if it xs:decimal, otherwise it is xs:float or empty or erroneous :)
    let $valueTotalDigits := common:countTotalDigits($value)
    let $valueTotalDigits := if($valueTotalDigits castable as xs:integer) then $valueTotalDigits else 0
(:  don't check total digits for decimals :)
(:  let $invalid := if( $totalDigits=$errors:INVALID_NUMBER or $value = "" or ($valueTotalDigits <= $totalDigits and $value castable as xs:decimal) or ($value castable as xs:float and not($value castable as xs:decimal))) then $invalid else fn:insert-before($invalid,1,fn:true()):)

    return
        not(empty(fn:index-of($invalid,fn:true())))
};
(:~
 : Check decimal values - min/max values, total digits.
 : @param $value Element value
 : @param $schemaDef xs:restriction element from XML Schema
 : @param $determinand names some float values may have exception according to determinand
 : return True if element is invalid.
 :)
declare function validatorutil:isInvalidFloat($value as xs:string, $schemaDef as element(xs:restriction), $determinand as xs:string)
as xs:boolean
{
    let $min_val := $schemaDef/xs:minInclusive/@value
    let $max_val := $schemaDef/xs:maxInclusive/@value

    (: * If Determinand_Nutrients = Temperature (water) or Alkalinity then values can be < 0  :)
    let $exceptions := ('Mean','Minimum','Maximum','Median')
    let $min_val := if ($determinand="alkalinity"
        and (common:containsStr($exceptions, fn:string($schemaDef/../../@name)))) then
            $errors:INVALID_NUMBER
        else
            $min_val

    (: Exception for temperature (water) :)
    let $min_val := if (($determinand = "temperature" or $determinand="temperature (water)")
        and (common:containsStr($exceptions, fn:string($schemaDef/../../@name)))) then
            $xmlutil:MIN_DATATYPE_EXCEPTION_VALUE
        else
            $min_val


    let $decimalMinVal := if ($min_val castable as xs:decimal) then fn:number($min_val) else $errors:INVALID_NUMBER
    let $decimalMaxVal := if ($max_val castable as xs:decimal) then fn:number($max_val) else $errors:INVALID_NUMBER
    let $floatValue := if ($value castable as xs:float) then fn:number($value) else $errors:INVALID_NUMBER

    let $invalid := ()
    let $invalid := if($value castable as xs:float or  $value = "") then  $invalid else fn:insert-before($invalid,1,fn:true())
    let $invalid := if( $decimalMinVal=$errors:INVALID_NUMBER or $floatValue=$errors:INVALID_NUMBER or $value = "" or $floatValue >= $decimalMinVal) then $invalid else fn:insert-before($invalid,1,fn:true())
    let $invalid := if( $decimalMaxVal=$errors:INVALID_NUMBER or $floatValue=$errors:INVALID_NUMBER or $value = "" or $floatValue <= $decimalMaxVal) then $invalid else fn:insert-before($invalid,1,fn:true())
    return
        not(empty(fn:index-of($invalid,fn:true())))
}
;
(:~
 : Check double values - min/max values, total digits.
 : @param $value Element value
 : @param $schemaDef xs:restriction element from XML Schema
 : return True if element is invalid.
 :)
declare function validatorutil:isInvalidDouble($value as xs:string, $schemaDef as element(xs:restriction))
as xs:boolean
{
    let $min_val := $schemaDef/xs:minInclusive/@value
    let $max_val := $schemaDef/xs:maxInclusive/@value

    let $decimalMinVal := if ($min_val castable as xs:decimal) then fn:number($min_val) else $errors:INVALID_NUMBER
    let $decimalMaxVal := if ($max_val castable as xs:decimal) then fn:number($max_val) else $errors:INVALID_NUMBER
    let $doubleValue := if ($value castable as xs:double) then fn:number($value) else $errors:INVALID_NUMBER

    let $invalid := ()
    let $invalid := if($value castable as xs:float or  $value = "") then  $invalid else fn:insert-before($invalid,1,fn:true())
    let $invalid := if( $decimalMinVal=$errors:INVALID_NUMBER or $doubleValue=$errors:INVALID_NUMBER or $value = "" or $doubleValue >= $decimalMinVal) then $invalid else fn:insert-before($invalid,1,fn:true())
    let $invalid := if( $decimalMaxVal=$errors:INVALID_NUMBER or $doubleValue=$errors:INVALID_NUMBER or $value = "" or $doubleValue <= $decimalMaxVal) then $invalid else fn:insert-before($invalid,1,fn:true())

    return
        not(empty(fn:index-of($invalid,fn:true())))
};
(:~
 : Check integer values - min/max values, total digits.
 : @param $value Element value
 : @param $schemaDef xs:restriction element from XML Schema
 : return True if element is invalid.
 :)
declare function validatorutil:isInvalidInteger($value as xs:string, $schemaDef as element(xs:restriction))
as xs:boolean
{
    let $min_val := $schemaDef/xs:minInclusive/@value
    let $max_val := $schemaDef/xs:maxInclusive/@value
    let $totalDigits := $schemaDef/xs:totalDigits/@value

    let $intMinVal := if ($min_val castable as xs:integer) then fn:number($min_val) else $errors:INVALID_NUMBER
    let $intMaxVal := if ($max_val castable as xs:integer) then fn:number($max_val) else $errors:INVALID_NUMBER
    let $intTotalDigits := if ($totalDigits castable as xs:integer) then fn:number($totalDigits) else $errors:INVALID_NUMBER
    let $intValue := if ($value castable as xs:integer) then fn:number($value) else $errors:INVALID_NUMBER

    let $invalid := ()
    let $invalid := if($value castable as xs:integer or  $value = "") then  $invalid else fn:insert-before($invalid,1,fn:true())
    let $invalid := if( $intMinVal=$errors:INVALID_NUMBER or $intValue=$errors:INVALID_NUMBER or $value = "" or $intValue >= $intMinVal) then $invalid else fn:insert-before($invalid,1,fn:true())
    let $invalid := if( $intMaxVal=$errors:INVALID_NUMBER or $intValue=$errors:INVALID_NUMBER or $value = "" or $intValue <= $intMaxVal) then $invalid else fn:insert-before($invalid,1,fn:true())
    let $invalid := if( $intTotalDigits=$errors:INVALID_NUMBER or $value = "" or string-length($value) <= $totalDigits) then $invalid else fn:insert-before($invalid,1,fn:true())

    return
        not(empty(fn:index-of($invalid,fn:true())))
};
(:~
 : Check date values - YYYY-MM-DD format.
 : @param $value Element value
 : @param $schemaDef xs:restriction element from XML Schema
 : return True if element is invalid.
 :)
declare function validatorutil:isInvalidDate($value, $schemaDef as element(xs:restriction)) as xs:boolean {
    let $ret:=
        if (string-length($value)=10) then
            fn:false()
        else
            fn:true()

    let $yy:=
        if ($ret=fn:false() and (fn:substring($value,1,4) castable as xs:integer))
            then fn:number(fn:substring($value,1,4))
            else -999

    let $m:=
        if ($ret=fn:false() and (fn:substring($value,6,2) castable as xs:integer))
            then fn:number(fn:substring($value,6,2))
            else -999

    let $d:=
        if ($ret=fn:false() and (fn:substring($value,9,2) castable as xs:integer))
            then fn:number(fn:substring($value,9,2))
            else -999
    (:check year :)
    let $ret:=
        if ($ret=fn:false() and $m lt 13 and $m gt 0) then
            fn:false()
        else
            fn:true()

    (:check month :)
    let $ret:=
        if ($ret=fn:false() and $yy >= $xmlutil:MIN_VALID_YEAR) then
            fn:false()
        else
            fn:true()

    (:check day :)
    let $ret:=
        if ($ret=fn:false() and $d lt 32 and $d gt 0) then
            fn:false()
        else
            fn:true()

    let $ret:=
        if ($ret=fn:false() and fn:substring($value,5,1)="-" and fn:substring($value,5,1)="-") then
            fn:false()
        else
            fn:true()

    let $ret:=
        if ($ret=fn:false() and $value castable as xs:date) then
            fn:false()
        else
            fn:true()

    return
        $ret
};

declare function validatorutil:getInvalidCodelistValues($row, $metadata as element(Meta)) as xs:string* {
    let $codelists := model:getCodelists($metadata)
    let $table := model:getMetadataTable($metadata)
    let $dataset := model:getMetadataDataset($metadata)

    for $element in $row/*
        let $localName := $element/local-name()
        let $validCodes := $codelists/dd:value-list[@element = $localName and @table = $table and @dataset = $dataset]/string(@code)
        where (not(empty($validCodes)) and not($element/text() = $validCodes))
        return
            $localName
};

(:~
 : Checks if a concept exists in the http://dd.eionet.europa.eu/vocabulary/wise/combinationTableDeterminandUom
 : @param $vocabularyUrl Location of the combinationTableDeterminandUom vocabulary
 : @param $row Row element that includes elements to be checked
 : @param $table the table that needs to match with the vocabulary data
 : @return true if unit exists, false if it doesn't
 :)
declare function validatorutil:checkUnitOfMeasureRdf($determinandUrl, $uomUrl, $observedPropertyUrl, $row, $ddTable, $prefix) as xs:boolean {
    let $determinands := ddutil:getValidRdfConcepts($determinandUrl)
    let $uoms := ddutil:getValidRdfConcepts($uomUrl)

    let $determinand := string($row/*[name() = common:getNameWithPrefix($prefix, "observedPropertyDeterminandCode")][1])
    let $uom := string($row/*[name() = common:getNameWithPrefix($prefix, "resultUom")][1])
    let $x :=
        if ($determinands[property:hasDeterminand/@rdf:resource = concat($observedPropertyUrl, $determinand)
            and property:hasUom/@rdf:resource = $uoms[skos:notation = $uom]/@rdf:about
            and property:hasTable/@rdf:resource = $ddTable]) then
                true()
            else
                false()
    return $x
};

(:~
 : Checks if the reference year is between the years reported in the dataflow_cycles
 : @param $year The Reference year
 : @param $obligation The obligation the data refers to
 : @param $cycleDate The date that the DataFlow refers to
 : @return true if reference year is between the years reported, false if not
 :)
declare function validatorutil:checkReferenceYear($year as xs:string, $obligation as xs:string, $cycleDate as xs:string) {
    let $year :=
        if ($year castable as xs:integer) then
            xs:integer($year)
        else
            0

    let $cyclesUrl := $constants:CYCLES_URL
    let $cycles :=
        if (doc-available($cyclesUrl)) then
            doc($cyclesUrl)
        else
            ()
    let $dateStart := year-from-date($cycles//DataFlow[@RO_ID = $obligation and DataFlowCycle/@Identifier = $cycleDate]/DataFlowCycle/timeValuesLimitDateStart)
    let $dateEnd := year-from-date($cycles//DataFlow[@RO_ID = $obligation and DataFlowCycle/@Identifier = $cycleDate]/DataFlowCycle/timeValuesLimitDateEnd)
    return ($year >= $dateStart and $year <= $dateEnd)
};
declare function validatorutil:checkSamplingPeriod($samplingPeriod, $phenomenonTimeReferenceYear) as xs:string* {
    let $format :=
        if (string-length($samplingPeriod) = 22) then
            1
        else if (string-length($samplingPeriod) = 16) then
            2
        else
            ()
    let $dateString1 :=
        if ($format = 1) then
            substring($samplingPeriod, 1, 10)
        else if ($format = 2) then
            concat(substring($samplingPeriod, 1, 7), "-01")
        else ()
    let $dateString2 :=
            if ($format = 1) then
            substring($samplingPeriod, 13)
        else if ($format = 2) then
            concat(substring($samplingPeriod, 10), "-01")
        else ()
    let $date1 :=
        if ($dateString1 castable as xs:date) then
            xs:date($dateString1)
        else ()
    let $date2 :=
        if ($dateString2 castable as xs:date) then
            xs:date($dateString2)
        else ()
    let $year1 := year-from-date($date1)
    let $year2 := year-from-date($date2)
    let $difference :=
        if ($year1 and $year2) then
            if (functx:is-leap-year($year1) and $date1 < xs:date(concat($year1,"-02-29"))
                    or functx:is-leap-year($year2) and $date2 > xs:date(concat($year2,"-02-29"))) then
                366
            else
                365
        else
            ()
    let $invalidFormat := if (empty($format)) then "1" else ()
    let $invalidStartingYear := if ($year1 > $year2) then "2" else ()
    let $invalidDateDifference :=
        if ($difference) then
            if (($date2 - $date1) div xs:dayTimeDuration("P1D") > $difference) then
                "3"
            else ()
        else
            ()
    let $invalidReferenceYear :=
        if ($year1 != $phenomenonTimeReferenceYear and $year2 != $phenomenonTimeReferenceYear) then
            "4"
        else
            ()
    return
        ($invalidFormat, $invalidStartingYear, $invalidDateDifference, $invalidReferenceYear)
};

declare function validatorutil:checkResultValuesLimit($determinand, $table, $value) {
  let $limitsUrl := $constants:LIMITS_URL
    let $limits :=
        if (doc-available($limitsUrl)) then
            doc($limitsUrl)
        else
            ()
  let $tableSet := $limits//Determinand[@Identifier = $determinand]/Dataset[@Identifier = "WISE-SoE_WaterQuality"]/Table[@Identifier = $table]

  let $MinExclusive := ($value > $tableSet/minExclusive)
  let $MinInclusive := ($value >= $tableSet/minInclusive)
  let $MaxExclusive := ($value >= $tableSet/maxExclusive)
  let $MaxInclusive := ($value >= $tableSet/maxInclusive)
  return ($MinExclusive, $MinInclusive, $MaxExclusive, $MinInclusive) = true()
};

declare function validatorutil:checkResultValuesMathematical($row as element(), $metadata as element()) as xs:string* {
    let $resultMeanValue := model:getValueFromLocalName($row, "resultMeanValue", $metadata)
    let $resultMinimumValue := model:getValueFromLocalName($row, "resultMinimumValue", $metadata)
    let $resultMedianValue := model:getValueFromLocalName($row, "resultMedianValue", $metadata)
    let $resultMaximumValue := model:getValueFromLocalName($row, "resultMaximumValue", $metadata)
    let $resultStandardDeviationValue := model:getValueFromLocalName($row, "resultStandardDeviationValue", $metadata)
    let $resultNumberOfSamples := model:getValueFromLocalName($row, "resultNumberOfSamples", $metadata)
    let $resultQualityNumberOfSamplesBelowLOQ := model:getValueFromLocalName($row, "resultQualityNumberOfSamplesBelowLOQ", $metadata)

    let $resultQualityMinimumBelowLOQ := model:getValueFromLocalName($row, "resultQualityMinimumBelowLOQ", $metadata)
    let $resultQualityMeanBelowLOQ := model:getValueFromLocalName($row, "resultQualityMeanBelowLOQ", $metadata)
    let $resultQualityMedianBelowLOQ := model:getValueFromLocalName($row, "resultQualityMedianBelowLOQ", $metadata)
    let $resultQualityMaximumBelowLOQ := model:getValueFromLocalName($row, "resultQualityMaximumBelowLOQ", $metadata)


    let $invalidCheck1 := if ($resultMeanValue < $resultMinimumValue) then "1" else ()
    let $invalidCheck2 := if ($resultMaximumValue < $resultMeanValue) then "2" else ()
    let $invalidCheck3 := if ($resultMedianValue < $resultMinimumValue) then "3" else ()
    let $invalidCheck4 := if ($resultMaximumValue < $resultMedianValue) then "4" else ()
    let $invalidCheck5 := if ($resultMaximumValue < $resultMinimumValue) then "5" else ()
    let $invalidCheck6 := if ($resultStandardDeviationValue > ($resultMaximumValue - $resultMinimumValue)) then "6" else ()
    let $invalidCheck7 :=
        if ($resultMinimumValue < $resultMaximumValue) then
            if ($resultStandardDeviationValue > 0) then
                ()
            else "7"
        else ()
    let $invalidCheck8 :=
        if ($resultNumberOfSamples = 1) then
            if (count(distinct-values(($resultMinimumValue, $resultMeanValue, $resultMaximumValue, $resultMedianValue))) = 1) then
                ()
            else
                "8"
        else ()
    let $invalidCheck9 :=
        if ($resultNumberOfSamples = 1) then
            if ($resultStandardDeviationValue = 0) then
                ()
            else
                "9"
        else ()
    let $invalidCheck10 := if ($resultQualityNumberOfSamplesBelowLOQ > $resultNumberOfSamples) then "10" else ()
    let $invalidCheck11 :=
        if ($resultQualityNumberOfSamplesBelowLOQ = 0) then
            if (($resultQualityMeanBelowLOQ, $resultQualityMaximumBelowLOQ, $resultQualityMedianBelowLOQ) = true()) then
                "11"
            else
                ()
        else ()
    return ($invalidCheck1, $invalidCheck2, $invalidCheck3, $invalidCheck4, $invalidCheck5, $invalidCheck6, $invalidCheck7, $invalidCheck8,
            $invalidCheck9, $invalidCheck10, $invalidCheck11)

};

declare function validatorutil:checkLoq($row as element(), $metadata as element()) as xs:string {
    let $observedPropertyDeterminandCode := model:getValueFromLocalName($row, "observedPropertyDeterminandCode", $metadata)
    let $determinandCodesUrl := $constants:DETERMINANDS_URL
    let $rdfUrl := concat($determinandCodesUrl,"/rdf")

    let $mandatoryLoq :=
        if (doc-available($rdfUrl)) then
            string(doc($rdfUrl)/rdf:RDF/skos:Concept[@rdf:about = concat($determinandCodesUrl, "/",$observedPropertyDeterminandCode)]/property:mandatoryLoq)
        else ()

    let $procedureLOQValue := model:getValueFromLocalName($row, "procedureLOQValue", $metadata)
    let $resultQualityNumberOfSamplesBelowLOQ := model:getValueFromLocalName($row, "resultQualityNumberOfSamplesBelowLOQ", $metadata)
    let $resultQualityMinimumBelowLOQ := model:getValueFromLocalName($row, "resultQualityMinimumBelowLOQ", $metadata)
    let $resultQualityMeanBelowLOQ := model:getValueFromLocalName($row, "resultQualityMeanBelowLOQ", $metadata)
    let $resultQualityMedianBelowLOQ := model:getValueFromLocalName($row, "resultQualityMedianBelowLOQ", $metadata)
    let $resultQualityMaximumBelowLOQ := model:getValueFromLocalName($row, "resultQualityMaximumBelowLOQ", $metadata)

    let $resultMeanValue := model:getValueFromLocalName($row, "resultMeanValue", $metadata)
    let $resultMinimumValue := model:getValueFromLocalName($row, "resultMinimumValue", $metadata)
    let $resultMedianValue := model:getValueFromLocalName($row, "resultMedianValue", $metadata)
    let $resultMaximumValue := model:getValueFromLocalName($row, "resultMaximumValue", $metadata)

    let $check1 :=
        if ($mandatoryLoq) then
            if (common:isEmpty($procedureLOQValue) and common:isEmpty($resultQualityNumberOfSamplesBelowLOQ)) then
                "1"
            else ()
        else ()
    let $check2 :=
        if ($resultQualityMeanBelowLOQ = true()) then
            if ($resultMeanValue != $procedureLOQValue) then
                "2"
            else
                ()
        else ()
    let $check3 :=
        if ($resultQualityMinimumBelowLOQ = true()) then
            if ($resultMinimumValue != $procedureLOQValue) then
                "3"
            else
                ()
        else ()
    let $check4 :=
        if ($resultQualityMaximumBelowLOQ = true()) then
            if ($resultMaximumValue != $procedureLOQValue) then
                "4"
            else
                ()
        else ()
    let $check5 :=
        if ($resultQualityMedianBelowLOQ = true()) then
            if ($resultMedianValue != $procedureLOQValue) then
                "5"
            else
                ()
        else ()
    return ($check1, $check2, $check3, $check4, $check5)
};

declare function validatorutil:checkSampleDepth($row as element(), $metadata as element()) {
    let $parameterSampleDepth := model:getValueFromLocalName($row, "parameterSampleDepth", $metadata)
    let $monitoringSiteIdentifier := model:getValueFromLocalName($row, "monitoringSiteIdentifier", $metadata)
    let $monitoringSiteIdentifierScheme := model:getValueFromLocalName($row, "monitoringSiteIdentifierScheme", $metadata)
    let $monitoringSitesUrl := $constants:MONITORINGSITES_URL
    let $rdfUrl := concat($monitoringSitesUrl, "/rdf")
    let $hasMaximumDepth :=
        if (doc-available($rdfUrl)) then
            data(doc($rdfUrl)/rdf:RDF/skos:Concept[@rdf:about = concat($monitoringSitesUrl, "/",
                $monitoringSiteIdentifierScheme, $model:DATASET_SEPARATOR, $monitoringSiteIdentifier)]/property:hasMaximumDepth)
        else ()
    let $invalidSampleDepth :=
        $parameterSampleDepth > $hasMaximumDepth
    return $invalidSampleDepth
};




declare function validators:checkMandatoryValues($schema as document-node(), $document as document-node(), $metadata as element(), $rule as element(rule)) as element(Result) {
    let $mandatoryElems := schema:getMandatoryElements($schema)
    let $rows := xmlutil:getAllRows($document)

    return
    <Result>{
        for $row at $pos in $rows
            let $missingElems :=
                for $elemName in $mandatoryElems
                    let $elem := $row/*[name()=$elemName]
                return
                    if (common:isMissingOrEmpty($elem)) then
                        $elemName
                    else ()
            let $exception := ruleutil:checkException($rule, $row, $metadata)
        where (not(empty($missingElems)))
        return
            <Row row-id="{$pos}">{
                for $elem in ruleutil:getRuleElements($rule)
                    let $name := concat(model:getMetadataElemPrefix($metadata), ":", $elem)
                    let $errLevel :=
                        if ($missingElems = $name) then
                            if ($exception) then $errors:EXCEPTION_LEVEL
                            else ruleutil:getRuleErrorLevel($rule)
                        else
                            $errors:OK_LEVEL
                return
                    model:getColumn($elem, xmlutil:getElementValueFromRow($row, $name), $errLevel)
            }</Row>
    }</Result>
};

declare function validators:checkDuplicates($schema as document-node(), $document as document-node(), $metadata as element(), $rule as element(rule)) as element(Result) {
    let $keys := schema:getPrimaryKeys($schema)
    let $rows := xmlutil:getAllRows($document)

    let $checkedRows :=
        for $row at $pos in $rows
            let $PK :=
                for $key in $keys
                return string($row/*[name() = $key][1])
            let $PK := string-join($PK, "##")
            let $res :=
                <Row row-id="{$pos}" key="{$PK}">
                    {$row/child::*}
                </Row>
        return $res
    let $resultKeys := data($checkedRows/@key)
    let $affectedRows :=
        for $row in $checkedRows
        return
            if (count(index-of($resultKeys, string($row/@key))) > 1) then
                $row
            else
                ()
    return
    <Result>{
        for $row in $affectedRows
            return
            <Row row-id="{string($row/@row-id)}">{
                for $elem in ruleutil:getRuleElements($rule)
                    let $name := model:getNameFromLocalName($metadata, $elem)
                    let $errLevel :=
                        if ($keys = $name) then
                            ruleutil:getRuleErrorLevel($rule)
                        else
                            $errors:OK_LEVEL
                return
                    model:getColumn($elem, xmlutil:getElementValueFromRow($row, $name), $errLevel)
             }</Row>
     }</Result>
};

declare function validators:checkDataTypes($schema as document-node(), $schemaContainer as document-node(), $document as document-node(), $metadata as element(), $rule as element(rule)) as element(Result) {
    let $rows := xmlutil:getAllRows($document)

    return
    <Result>{
        for $row at $pos in $rows
            let $invalidElems := validatorutil:getInvalidDataTypeValues($row, $schemaContainer, schema:getAllElements($schema), <exceptions><MaxLength/></exceptions>)
            let $invalidElemKeys := maps:getHashMapKeys($invalidElems)
        where not(empty($invalidElems))
        order by $pos
        return
            <Row row-id="{$pos}">{
                for $elem in ruleutil:getRuleElements($rule)
                    let $name := model:getNameFromLocalName($metadata, $elem)
                    let $isInvalidElem := not(empty(index-of($invalidElemKeys, $name)))
                    let $isInvalid := if(not($isInvalidElem)) then fn:false() else maps:getHashMapBooleanValues($invalidElems, $elem)
                    let $errLevel :=
                        if ($isInvalidElem) then
                            ruleutil:getRuleErrorLevel($rule)
                        else
                            $errors:OK_LEVEL
                return
                    model:getColumn($elem, xmlutil:getElementValueFromRow($row, $name), $errLevel)
            }</Row>
    }</Result>
};

declare function validators:checkCodelistValues($schema as document-node(), $document as document-node(), $metadata as element(), $rule as element(rule)) as element(Result) {
    let $rows := xmlutil:getAllRows($document)

    return
    <Result>{
    for $row at $pos in $rows
        let $invalidElems := validatorutil:getInvalidCodelistValues($row, $metadata)
        let $suggestedElems := model:getCodeListSuggestedElements($metadata)

        where not(empty($invalidElems))
        order by $pos
        return
            <Row row-id="{$pos}">{
            for $elem in ruleutil:getRuleElements($rule)
                let $name := model:getNameFromLocalName($metadata, $elem)
                let $errLevel :=
                    if ($invalidElems = $elem) then
                        if ($suggestedElems = $elem) then
                            $errors:WARNING_LEVEL
                        else
                            ruleutil:getRuleErrorLevel($rule)
                    else $errors:OK_LEVEL
            return
                model:getColumn($elem, xmlutil:getElementValueFromRow($row, $name), $errLevel)
            }</Row>
    }</Result>
};

declare function validators:checkMonitoringFormat($schema as document-node(), $document as document-node(), $metadata as element(), $rule as element(rule)) as element(Result) {
    let $rows := xmlutil:getAllRows($document)
    let $countryCode := model:getReportingCountry($metadata)
    let $identifierName := model:getNameFromLocalName($metadata, "monitoringSiteIdentifier")

    return
    <Result>{
        for $row at $pos in $rows
        where upper-case(substring($row/*[name() = $identifierName],0,3)) != $countryCode or not(matches($row/*[name() = $identifierName], "[a-zA-Z0-9\-_]+"))
        order by $pos
        return
            <Row row-id="{$pos}">{
                for $elem in ruleutil:getRuleElements($rule)
                    let $name := model:getNameFromLocalName($metadata, $elem)
                    let $errLevel := ruleutil:getRuleErrorLevel($rule)
                return
                   model:getColumn($elem, xmlutil:getElementValueFromRow($row, $name), $errLevel)
                }
            </Row>
        }
    </Result>
};

declare function validators:checkMonitoringReference($schema as document-node(), $document as document-node(), $metadata as element(), $rule as element(rule)) as element(Result) {
    let $rows := xmlutil:getAllRows($document)

    let $baseUrl := $constants:MONITORINGSITES_URL
    let $values := ddutil:getValidCodelistValues($baseUrl)

    return
    <Result>{
        for $row at $pos in $rows
        let $rowValue := concat($baseUrl, "/", $row/*[local-name() = "monitoringSiteIdentifierScheme"], $model:DATASET_SEPARATOR, $row/*[local-name() = "monitoringSiteIdentifier"])
        where not($values = $rowValue)
        order by $pos
        return
            <Row row-id="{$pos}">{
                for $elem in ruleutil:getRuleElements($rule)
                    let $name := concat(model:getMetadataElemPrefix($metadata), ":", $elem)
                    let $errLevel := ruleutil:getRuleErrorLevel($rule)
                return
                   model:getColumn($elem, xmlutil:getElementValueFromRow($row, $name), $errLevel)
               }
            </Row>
        }
    </Result>
};

declare function validators:checkUnitOfMeasure($schema as document-node(), $document as document-node(), $metadata as element(), $rule as element(rule)) as element(Result) {
    let $rows := xmlutil:getAllRows($document)
    let $determinandUrl := "http://dd.eionet.europa.eu/vocabulary/wise/QCCombinationTableDeterminandUom"
    let $uomUrl := "http://dd.eionet.europa.eu/vocabulary/wise/Uom"
    let $observedPropertyUrl := "http://dd.eionet.europa.eu/vocabulary/wise/ObservedProperty/"
    let $ddTable := model:getMetadataDDTable($metadata)
    let $prefix := model:getMetadataElemPrefix($metadata)

    return
    <Result>{
        for $row at $pos in $rows
        where not(validatorutil:checkUnitOfMeasureRdf($determinandUrl, $uomUrl, $observedPropertyUrl, $row, $ddTable, $prefix))
        order by $pos
        return
            <Row row-id="{$pos}">{
                for $elem in ruleutil:getRuleElements($rule)
                    let $name := model:getNameFromLocalName($metadata, $elem)
                    let $errLevel :=
                        if ($elem = "resultUom") then
                            ruleutil:getRuleErrorLevel($rule)
                        else
                            $errors:OK_LEVEL
                return
                    model:getColumn($elem, xmlutil:getElementValueFromRow($row, $name), $errLevel)
            }</Row>
    }</Result>
};

declare function validators:checkReferenceYear($schema as document-node(), $document as document-node(), $metadata as element(), $rule as element(rule)) as element(Result) {
    let $rows := xmlutil:getAllRows($document)

    return
    <Result>{
        for $row at $pos in $rows
        where not(validatorutil:checkReferenceYear($row/*[name() = model:getNameFromLocalName($metadata, "phenomenonTimeReferenceYear")], "714", "2015-16"))
        order by $pos
        return
            <Row row-id="{$pos}">{
                for $elem in ruleutil:getRuleElements($rule)
                    let $name := model:getNameFromLocalName($metadata, $elem)
                    let $errLevel :=
                        if ($elem = "phenomenonTimeReferenceYear") then
                            ruleutil:getRuleErrorLevel($rule)
                        else
                            $errors:OK_LEVEL
                return
                    model:getColumn($elem,xmlutil:getElementValueFromRow($row, $name), $errLevel)
            }</Row>
    }</Result>
};

declare function validators:checkSamplingPeriod($schema as document-node(), $document as document-node(), $metadata as element(), $rule as element(rule)) as element(Result) {
    let $rows := xmlutil:getAllRows($document)

    return
    <Result>{
        for $row at $pos in $rows
        let $invalidTypes := validatorutil:validateTypes($metadata, $row, ("parameterSamplingPeriod", "phenomenonTimeReferenceYear"))
        let $invalidRules :=
            if (not($invalidTypes)) then
                validatorutil:checkSamplingPeriod(model:getValueFromLocalName($row, "parameterSamplingPeriod", $metadata), model:getValueFromLocalName($row, "phenomenonTimeReferenceYear", $metadata))
            else
                ()
        where ($invalidTypes or $invalidRules)
        order by $pos
        return
            <Row row-id="{$pos}" invalid="{$invalidTypes}" rules="{maps:createHashMapEntry("rules", $invalidRules)}">{
                    for $elem in ruleutil:getRuleElements($rule)
                        let $name := model:getNameFromLocalName($metadata, $elem)
                        let $errLevel :=
                            if ($elem = "parameterSamplingPeriod") then
                                ruleutil:getRuleErrorLevel($rule)
                            else
                                $errors:OK_LEVEL
                    return
                        model:getColumn($elem, xmlutil:getElementValueFromRow($row, $name), $errLevel)
            }</Row>
    }</Result>
};

declare function validators:checkResultValuesLimit($schema as document-node(), $document as document-node(), $metadata as element(), $rule as element(rule)) as element(Result) {
    let $rows := xmlutil:getAllRows($document)
    let $table := model:getMetadataTable($metadata)

    return
    <Result>{
        for $row at $pos in $rows
            let $determinand := model:getStringValueFromLocalName($row, "observedPropertyDeterminandCode")
            let $invalidTypes := validatorutil:validateTypes($metadata, $row, "observedPropertyDeterminandCode")

            let $minimum := validatorutil:checkResultValuesLimit($determinand, $table, model:getStringValueFromLocalName($row, "resultMinimumValue"))
            let $mean := validatorutil:checkResultValuesLimit($determinand, $table, model:getStringValueFromLocalName($row, "resultMeanValue"))
            let $maximum := validatorutil:checkResultValuesLimit($determinand, $table, model:getStringValueFromLocalName($row, "resultMaximumValue"))
            let $median := validatorutil:checkResultValuesLimit($determinand, $table, model:getStringValueFromLocalName($row, "resultMedianValue"))
        where ($invalidTypes or not($minimum and $mean and $maximum and $median))
        order by $pos
        return
            <Row row-id="{$pos}">{
                for $elem in ruleutil:getRuleElements($rule)
                    let $name := model:getNameFromLocalName($metadata, $elem)
                    let $errLevel := if ($invalidTypes or ($elem = "resultMinimumValue" and not($minimum)) or
                        ($elem = "resultMeanValue" and not($mean)) or
                        ($elem = "resultMaximumValue" and not ($maximum)) or
                        ($elem = "resultMedianValue" and not($median))) then
                            ruleutil:getRuleErrorLevel($rule)
                        else
                            $errors:OK_LEVEL
                    return
                        model:getColumn($elem, xmlutil:getElementValueFromRow($row, $name), $errLevel)
            }</Row>
    }</Result>
};

declare function validators:checkResultValuesMathematical($schema as document-node(), $document as document-node(), $metadata as element(), $rule as element(rule)) as element(Result) {
    let $rows := xmlutil:getAllRows($document)

    return
    <Result>{
        for $row at $pos in $rows
        let $typesSequence := ("resultMeanValue", "resultMinimumValue", "resultMedianValue", "resultMaximumValue",
             "resultStandardDeviationValue", "resultNumberOfSamples", "resultQualityNumberOfSamplesBelowLOQ", "resultQualityMinimumBelowLOQ",
             "resultQualityMeanBelowLOQ", "resultQualityMedianBelowLOQ", "resultQualityMaximumBelowLOQ")
        let $invalidTypes := validatorutil:validateTypes($metadata, $row, $typesSequence)
        let $ruleRelations := (
            maps:createHashMapEntry("1", ("resultMeanValue", "resultMinimumValue")), maps:createHashMapEntry("2", ("resultMaximumValue", "resultMeanValue")),
            maps:createHashMapEntry("3", ("resultMedianValue", "resultMinimumValue")), maps:createHashMapEntry("4", ("resultMaximumValue", "resultMedianValue")),
            maps:createHashMapEntry("5", ("resultMaximumValue", "resultMinimumValue")), maps:createHashMapEntry("6", ("resultStandardDeviationValue", "resultMaximumValue", "resultMinimumValue")),
            maps:createHashMapEntry("7", ("resultMinimumValue", "resultMaximumValue", "resultStandardDeviationValue")), maps:createHashMapEntry("8", ("resultMinimumValue", "resultMeanValue", "resultMaximumValue", "resultMedianValue")),
            maps:createHashMapEntry("9", ("resultStandardDeviationValue")), maps:createHashMapEntry("10", ("resultQualityNumberOfSamplesBelowLOQ", "resultNumberOfSamples")),
            maps:createHashMapEntry("11", ("resultQualityNumberOfSamplesBelowLOQ", "resultQualityMeanBelowLOQ", "resultQualityMaximumBelowLOQ", "resultQualityMedianBelowLOQ")))
        let $invalidRules :=
            if (not($invalidTypes)) then validatorutil:checkResultValuesMathematical($row, $metadata) else ()
        where ($invalidTypes or $invalidRules)
        order by $pos
        return
            <Row row-id="{$pos}" invalid="{$invalidTypes}" rules="{maps:createHashMapEntry("rules", $invalidRules)}">{
                for $elem in ruleutil:getRuleElements($rule)
                    let $name := model:getNameFromLocalName($metadata, $elem)
                    let $affectedElems :=
                        for $r in $invalidRules
                        return
                            maps:getHashMapValues($ruleRelations, $r)
                    let $errLevel :=
                        if (($invalidTypes and $elem = $typesSequence) or ($invalidRules and $elem = $affectedElems)) then
                            ruleutil:getRuleErrorLevel($rule)
                        else
                            $errors:OK_LEVEL
                return
                    model:getColumn($elem, xmlutil:getElementValueFromRow($row, $name), $errLevel)
            }</Row>
        }
    </Result>
};
declare function validators:checkLoq($schema as document-node(), $document as document-node(), $metadata as element(), $rule as element(rule)) as element(Result) {
    let $rows := xmlutil:getAllRows($document)

    return
    <Result>{
        for $row at $pos in $rows
        let $invalidTypes := validatorutil:validateTypes($metadata, $row,
            ("observedPropertyDeterminandCode", "procedureLOQValue", "resultQualityNumberOfSamplesBelowLOQ", "resultQualityMinimumBelowLOQ", "resultQualityMeanBelowLOQ", "resultQualityMedianBelowLOQ",
             "resultQualityMaximumBelowLOQ", "resultMeanValue", "resultMinimumValue", "resultMedianValue", "resultMaximumValue"))
        let $invalidRules :=
            if (not($invalidTypes)) then validatorutil:checkLoq($row, $metadata) else ()
        where ($invalidTypes or $invalidRules)
        order by $pos
        return
            <Row row-id="{$pos}" invalid="{$invalidTypes}" rules="{maps:createHashMapEntry("rules", $invalidRules)}">{
                for $elem in ruleutil:getRuleElements($rule)
                    let $name := concat(model:getMetadataElemPrefix($metadata), ":", $elem)
                    let $errLevel :=
                        if ($elem = ("resultObservedValue", "resultQualityObservedValueBelowLOQ", "procedureLOQValue")) then
                            $errors:ERROR_LEVEL
                        else
                            $errors:OK_LEVEL
                return
                    model:getColumn($elem, xmlutil:getElementValueFromRow($row, $name), $errLevel)
            }</Row>
        }
    </Result>
};

declare function validators:checkSampleDepth($schema as document-node(), $document as document-node(), $metadata as element(), $rule as element(rule)) as element(Result) {
    let $rows := xmlutil:getAllRows($document)

    return
    <Result>{
        for $row at $pos in $rows
        let $invalidTypes := validatorutil:validateTypes($metadata, $row, ("parameterSampleDepth", "monitoringSiteIdentifier", "monitoringSiteIdentifierScheme"))
        let $invalidRules :=
            if (not($invalidTypes)) then validatorutil:checkSampleDepth($row, $metadata) else ()
        where ($invalidTypes or $invalidRules)
        order by $pos
        return
            <Row row-id="{$pos}">{
                for $elem in ruleutil:getRuleElements($rule)
                    let $name := model:getNameFromLocalName($metadata, $elem)
                    let $errLevel :=
                        if ($elem = ("parameterSampleDepth", "maximumDepth")) then
                            $errors:ERROR_LEVEL
                        else
                            $errors:OK_LEVEL
                    let $value :=
                        if ($elem = "maximumDepth") then
                            ddutil:getMonitoringSiteMaximumDepth(model:getValueFromLocalName($row, "monitoringSiteIdentifierScheme", $metadata), model:getValueFromLocalName($row, "monitoringSiteIdentifier", $metadata))
                        else
                            xmlutil:getElementValueFromRow($row, $name)
                return
                    model:getColumn($elem, $value, $errLevel)
            }</Row>
        }
    </Result>
};


(:
 : Module Name: WISE SoE - Water Quality (WISE-4) - Utility methods (Library module)
 :
 : Version:
 : Created:     15 October 2015
 : Copyright:   European Environment Agency
 :)
(:~
 : Common utility methods used by WISE SoE - Water Quality (WISE-4) scripts.
 : Reporting obligation: http://rod.eionet.europa.eu/obligations/714
 :
 : This module contains 1 type of helper methods:
 :      - Rule HELPER methods: QA rules related helper methods
 :
 : @author George Sofianos
 :)


(:Helper global variable for testing environment:)




(: Constant for min data type check that are defined as minValue=0 but can be below zero :)


(:~ Constant used for invalid numeric values.
declare variable $errors:INVALID_NUMBER as xs:integer :=  -99999;:)

(:~ Message displayed for missig values. :)

(:~ declare Content Registry SPARQL endpoint:)

(:~ Separator used in lists expressed as string :)

(:~ URL of XML file with countryies boundaires :)

(:~ EU boundary: min x :)

(:~ EU boundary: min y :)

(:~ EU boundary: max x :)

(:~ EU boundary: max y :)

(:~ declare allowed values for boolean fields :)

(:~ list of EU countries :)

(:~ display fields definitions XML file :)

(: maximum year value in date fields :)

(:~ Minimum year value allowed in period or date fields (YYYY or YYYY-YYYY). :)









declare function xmlutil:getDocument($source_url) as document-node() {
    if (doc-available($source_url)) then
        doc($source_url)
    else
        ()
};

declare function xmlutil:getEnvelopeXML($url as xs:string) as document-node() {
    let $col := fn:tokenize($url,'/')
    let $col := fn:remove($col, fn:count($col))
    let $ret := fn:string-join($col,'/')
    let $ret := fn:concat($ret,'/xml')
    return
        if (fn:doc-available($ret)) then
            doc($ret)
        else if ($xmlutil:TEST_ENV) then
            document {<envelope>
                <countryCode>GR</countryCode>
            </envelope>}
        else
            document {<envelope></envelope>}
};

declare function xmlutil:getAllRows($document as document-node()) as element()*{
    let $namespace := xmlutil:getRowNamespace($document)
    let $QName := QName($namespace, "Row")
    for $child in $document//*
    where node-name($child) = $QName
    return $child
};
declare function xmlutil:getRowNamespace($document as document-node()) as xs:string {
    namespace-uri($document/child::*[1])
};

declare function xmlutil:getRowPrefix($document as document-node()) as xs:string {
    let $namespace := namespace-uri($document/child::*[1])
    for $prefix in in-scope-prefixes($document/child::*[1])
    return
        if (namespace-uri-for-prefix($prefix, $document/child::*[1]) = $namespace) then
            $prefix
        else
            ()
};

(:(\:~
 : Mandatory values QA check. Check if the row has invalid elements. Return the list of invalid element names.
 : @param $rowElement XML Row element to be checked.
 : @param $mandatoryElems List of mandatory element names.
 : @return List of invalid element names.
 :\)
declare function xmlutil:getInvalidMandatoryValues($rowElement as element(dd791:Row),$mandatoryElems as xs:string*)
as xs:string*
{
    for $elemName in $mandatoryElems
    let $isInvalid := xmlutil:isInvalidMandatory($rowElement, $elemName)
    where $isInvalid
    return $elemName
};
(\:~
 : Check if the element exists and it has a value. Return TRUE if everything is OK, otherwise FALSE.
 : @param $rowElement XML Row element to be checked.
 : @param $elementName XML element name to be checked.
 : @return Boolean, true if element is invalid.
 :\)
declare function xmlutil:isInvalidMandatory($rowElement as element(dd791:Row), $elementName as xs:string)
as xs:boolean
{
    let $elem :=  $rowElement/*[name()=$elementName]
    let $isMissing:= common:isMissing($elem)
    let $value:= if($isMissing = fn:true()) then fn:string("") else fn:normalize-space(string-join($elem, ""))

    let $isempty := common:isEmpty($value)
    return $isempty
};:)

(:~
 : Build HTML table rows for displaying countries bounding boxes.
 : @param $countryCodes list of country codes.
 : return HTML tr elements.
 :)
declare function xmlutil:getBoundaries($countryCodes as xs:string*) as element(tr)* {
    let $minMaxRows := xmlutil:getMinMaxRows()
    for $row in $minMaxRows
    where fn:empty(fn:index-of($countryCodes, $row/ISO_2DIGIT)) = fn:false()
    return
        <tr align="right">
            <td>{ data($row/ISO_2DIGIT) }</td>
            <td>{ data($row/minx) }</td>
            <td>{ data($row/maxx) }</td>
            <td>{ data($row/miny) }</td>
            <td>{ data($row/maxy) }</td>
        </tr>
};
(:~
 : Build empty XML for countries boundaries.
 : return XML.
 :)
declare function xmlutil:getEmptyMinMax() as element(root){
    <root>
        <row>
            <ISO_2DIGIT/>
            <CNT_ISO_2D/>
            <MIN_CNTRY_/>
            <minx/>
            <miny/>
            <maxx/>
            <maxy/>
        </row>
    </root>
};
(:~
 : Return all rows from countries boundaries XML.
 : return XML.
 :)
declare function xmlutil:getMinMaxRows() as element(row)* {

    let $minMaxRows :=
        if(fn:doc-available($xmlutil:MIN_MAX_URL)) then
            fn:doc($xmlutil:MIN_MAX_URL)//root/row
        else
            xmlutil:getEmptyMinMax()//root/row
    return $minMaxRows
};
(:~
 : Build HTML table for displaying countries boundaries.
 : @param $elemSchemaUrl XML Schema URL containing element definitions.
 : @param $allElements List of all elements
 : return HTML tr elements.
 :)
declare function xmlutil:buildBoundariesTbl($url as xs:string, $countryCode as xs:string) as element(div){

    let $minMaxXmlAvailable := fn:doc-available($xmlutil:MIN_MAX_URL)
    let $envelopeCountryBoundaries := xmlutil:getBoundaries($countryCode)
    let $boundaries :=
        if(fn:count($envelopeCountryBoundaries) = 0) then
            xmlutil:getBoundaries(doc($url)//child::*/child::*[fn:local-name() = 'CountryCode'])
        else
            $envelopeCountryBoundaries
    let $showEuRow := fn:count($envelopeCountryBoundaries) = 0
    return
       if(empty($boundaries)) then
           <div>
                <div>Station longitude should be in range { $xmlutil:EU_MIN_X } ... { $xmlutil:EU_MAX_X } and latitude in range { $xmlutil:EU_MIN_Y } ... { $xmlutil:EU_MAX_Y }</div>{
                 if( fn:not($minMaxXmlAvailable) ) then
                    <div>Warning! Countries boundaries xml file is unavailable at: {$xmlutil:MIN_MAX_URL}</div>
                else
                    <div/>
           }</div>
        else
            <div>
               <p><strong>Checked boundaries:</strong></p>
               <table border="1" class="datatable">
                    <tr>
                        <th>Country code</th>
                        <th>minx</th>
                        <th>maxx</th>
                        <th>miny</th>
                        <th>maxy</th>
                    </tr>{
                    $boundaries
                    }{
                    if ($showEuRow) then
                        <tr align="right">
                            <td>EU</td>
                            <td>{ $xmlutil:EU_MIN_X }</td>
                            <td>{ $xmlutil:EU_MAX_X }</td>
                            <td>{ $xmlutil:EU_MIN_Y }</td>
                            <td>{ $xmlutil:EU_MAX_Y }</td>
                        </tr>
                    else
                        ()
                }</table>
            </div>
};
(:~
 : Check if value is correct longitude or lattitude.
 : @param $value Element value
 : @param $allBoundaries List of all boundaries
 : @param $isLong true, if check longitude; false, if check lattitude
 : @param $envCountryCode country code retreived from envelope XML
 : @param $rowCountryCode country code retreived from reported row
 : return True if element is invalid.
 :)
declare function xmlutil:isInvalidLongLat($allBoundaries as element(row)*, $strValue as xs:string, $isLong as xs:boolean,
    $envCountryCode as xs:string, $rowCountryCode as xs:string) as xs:boolean {
    let $decimalValue :=
        if ($strValue castable as xs:decimal)
            then xs:decimal($strValue)
        else
            $errors:INVALID_NUMBER

    let $countryCode :=
        if(count($allBoundaries[ISO_2DIGIT = $envCountryCode])>0) then
            $envCountryCode
        else if(count($allBoundaries[ISO_2DIGIT = $rowCountryCode])>0) then
            $rowCountryCode
        else
            "eu"

    let $boundaries := $allBoundaries[ISO_2DIGIT = $countryCode]

    let $isInvalid :=
        if(fn:string-length(fn:normalize-space($strValue)) = 0) then
            fn:false()
        else if($countryCode = "eu" and $isLong) then
            $decimalValue < $xmlutil:EU_MIN_X or $decimalValue > $xmlutil:EU_MAX_X
        else if($countryCode = "eu" and not($isLong)) then
            $decimalValue < $xmlutil:EU_MIN_Y or $decimalValue > $xmlutil:EU_MAX_Y
        else if ($isLong) then
            every $ba in  $boundaries satisfies $decimalValue < xs:decimal($ba/minx)  or  $decimalValue > xs:decimal($ba/maxx)
        else if (not($isLong)) then
            every $ba in  $boundaries satisfies $decimalValue < xs:decimal($ba/miny)  or  $decimalValue > xs:decimal($ba/maxy)
        else
            fn:false()
    return
        $isInvalid
};

(:~
 : @param $row XML Row element to be checked.
 : @param $elements list of XML elements
 : @param $codes List of all fixed values
 : @return List of true/false values
 :)
declare function xmlutil:isInvalidFixedValues($elements as element()*, $codes as xs:string*) as xs:boolean* {
    for $elem in $elements
        let $invalidFixedValues := xmlutil:isInvalidFixedValue($elem, $codes)
        return $invalidFixedValues
};
(:~
 : @param $row XML Row element to be checked.
 : @param $elem XML element to be checked
 : @param $codes List of all fixed values
 : @return true is invalid code value
 :)
declare function xmlutil:isInvalidFixedValue($elem as element(), $codes as xs:string*) as xs:boolean {
    let $value:= xmlutil:parseFixedValue($elem)

    let $notInCodelist := if($value = "") then fn:false() else fn:empty(fn:index-of($codes, lower-case($value)))

    return $notInCodelist
};
declare function xmlutil:parseFixedValue($elem as element()) as xs:string {
    let $isMissing:= common:isMissing($elem)
    let $value:= if($isMissing = fn:true()) then "" else fn:normalize-space(string($elem))

    (: Unit values may contain micro sign. Micro sign and Greek small mu have different ascii codes 181 and 956. Both are valid :)
    let $value := if (fn:starts-with($elem/local-name(), "Unit_")) then fn:replace($value, "&#956;", "&#181;") else $value
    (: Unit values may contain degree sign. The codepoint of Celsius degree could be 176 and 186. Both are valid :)
    let $value := if (fn:starts-with($elem/local-name(), "Unit_")) then fn:replace($value, "&#186;", "&#176;") else $value
    return
        $value
};
(:~
 : Build determinand and units mapping table.
 : @return true is invalid code value
 :)
declare function xmlutil:buildUnitDefs($determinandDefs as element(determinands)) as element(table) {
    let $units := distinct-values($determinandDefs//value[string-length(unit[1]) > 0]/unit)
    return
        <table class="datatable" border="1">
            <tr>
                <th>Unit</th>
                <th>Determinand_Nutrients</th>
            </tr>
            {
            for $pn in $units
                where not(starts-with($pn,"&#956;"))  (: greek mu, symbol 181 is already there :)
                order by $pn
                return
                    <tr>
                        <td>{if (string($pn)="") then "no unit" else string($pn)}</td>
                        <td>{fn:string-join($determinandDefs//value[unit=$pn]/key,", ")}</td>
                    </tr>
            }
        </table>
};
(:~
 : Goes through all elements in one row and reads the data type values
 : @param $row Row element
 : @return List of element names.
 :)
declare function xmlutil:getInvalidOutlierElems($row as element(), $outliers as element(determinands),
    $elemName as xs:string, $determinandElem as xs:string) as xs:string* {
    let $elem :=  $row/*[local-name() = $elemName][1]
    let $detName := $row/*[local-name() = $determinandElem][1]
    let $outlier := $outliers//value[fn:lower-case(key) = fn:lower-case($detName)][1]

    let $isMissing := common:isMissing($elem)
    let $elemValue := if($isMissing = fn:true()) then "" else fn:normalize-space(string($elem))


    let $remarks := fn:lower-case($row/*[local-name() = "Remarks"][1])
    let $confirmedRemark := if (fn:string-length($outlier/remarks) > 0 ) then fn:lower-case($outlier/remarks) else ""
    let $containsConfirmedRemark := if (fn:string-length($confirmedRemark) > 0) then fn:contains($remarks, $confirmedRemark) else fn:false()

    where fn:not(fn:empty($outlier)) and xmlutil:isInvalidOutlierValue($elemValue, $outlier)
        and fn:not($containsConfirmedRemark)
    return
        $elemName
};
(: Check if the node exists and it's value is from the code list. Return TRUE if everything is OK, otherwise FALSE :)
declare function xmlutil:isInvalidOutlierValue($elemValue as xs:string, $outlier as element(value)) as xs:boolean {

    let $numValue := if($elemValue castable as xs:float) then fn:number($elemValue) else $errors:INVALID_NUMBER
    let $minValue := if(not(common:isMissing($outlier/min)) and $outlier/min castable as xs:float) then fn:number($outlier/min) else $errors:INVALID_NUMBER
    let $maxValue := if(not(common:isMissing($outlier/max)) and $outlier/max castable as xs:float) then fn:number($outlier/max) else $errors:INVALID_NUMBER
    let $minEqual := if(not(common:isMissing($outlier/min/@equal)) and $outlier/min/@equal="true") then fn:true() else fn:false()
    let $maxEqual := if(not(common:isMissing($outlier/max/@equal)) and $outlier/max/@equal="true") then fn:true() else fn:false()

    let $isOutlier := $numValue != $errors:INVALID_NUMBER and (
                        ($numValue <= $minValue and $minValue != $errors:INVALID_NUMBER and $minEqual=fn:false())
                         or ($numValue < $minValue and $minValue != $errors:INVALID_NUMBER and $minEqual=fn:true())
                            or  ($numValue >= $maxValue and $maxValue != $errors:INVALID_NUMBER and $maxEqual=fn:false())
                             or   ($numValue > $maxValue and $maxValue != $errors:INVALID_NUMBER and $maxEqual=fn:true()))

    return $isOutlier
};
(:~
 : Build HTML table for outlier definitions
 : @return HTML table
 :)
declare function xmlutil:buildOutlierValuesDefs($determinandDefs as element(determinands)) as element(table) {
    let $outliers := $determinandDefs
    return
        <table class="datatable" border="1">
            <tr>
                <th>Determinand_Nutrients</th>
                <th>Potentially High Mean Value</th>
            </tr>{
                for $pn in $outliers//value[string-length(min)>0 or string-length(max)>0]
                return
                    <tr>
                        <td>{ fn:data($pn/key) }</td>
                        <td>{ if (string-length($pn/min) = 0) then  fn:data($pn/max) else concat("In range &gt;", xmlutil:getOutlierEqualSign($pn/min), fn:data($pn/min), " and &lt; ", xmlutil:getOutlierEqualSign($pn/max), fn:data($pn/max))}</td>
                    </tr>
        }</table>
};


(:~
 : Compare reported country code with reporting country in CDR envelope metadata.
 : Exception: Return false if they are not equal. GB can report also UK codes.
 : @param countryCodeNode
 : @param envelopeCountry
 : @return true if valid country code
 :)
declare function xmlutil:isInvalidCountryCode($countryCodeNode as node(), $envelopeCountry as xs:string) as xs:boolean {
    let $reportedCountryCode :=
        if (not(common:isMissingOrEmpty($countryCodeNode))) then
            if (string($countryCodeNode) = "UK") then
                "GB"
            else
                fn:string($countryCodeNode)
        else
            ""
    let $isInvalid :=
        if ($reportedCountryCode = "") then
            fn:false()
        else
           (lower-case($reportedCountryCode) != fn:lower-case($envelopeCountry))

    return
        $isInvalid
};
(:~
 : Compare 2 country codes and return true if they are equal (exceptional UK and GB).
 : Exception: Return false if they are not equal. GB can report also UK codes.
 : @param countryCodeNode
 : @param stationCountryCode (first 2 characters should be country code)
 : @return true if valid country code
 :)
declare function xmlutil:isInvalidEqualCountryCode($countryCodeNode as node(), $stationCountryCodeNode as node()) as xs:boolean {
    let $reportedCountryCode :=
        if (not(common:isMissingOrEmpty($countryCodeNode)) and string-length($countryCodeNode) = 2) then
            if (lower-case(string($countryCodeNode)) = "uk") then
                "GB"
            else
                fn:string($countryCodeNode)
        else
            ""
    let $stationCountryCode :=
        if (not(common:isMissingOrEmpty($stationCountryCodeNode)) and string-length($stationCountryCodeNode) > 1) then
            fn:substring($stationCountryCodeNode, 1, 2)
        else
            ""
    let $stationCountryCode := if (lower-case($stationCountryCode) = "uk") then "GB" else $stationCountryCode

    let $isInvalid :=
        if ($reportedCountryCode = "") then
            fn:false()
        else
           (lower-case($reportedCountryCode) != fn:lower-case($stationCountryCode))

    return
        $isInvalid
};

declare function xmlutil:getValidCodelistValues($url as xs:string) {
    let $url := concat($url, "/codelist")
    return
       if (doc-available($url)) then
            let $values := doc($url)/codelist/containeditems/value
            let $validValues :=
                for $value in $values
                    return
                        if ($value/status/@id = $xmlutil:INSPIRE_STATUS_VALID) then
                            $value
                        else
                            ()
            return data($validValues/@id)
        else ()
};

declare function xmlutil:getValidRdfValues($url as xs:string) {
    let $url := concat($url, "/rdf")
    return
       if (doc-available($url)) then
            let $values := doc($url)/rdf:RDF/skos:Concept
            let $validValues :=
                for $value in $values
                    return
                        $value
            return $validValues
        else ()
};
(:~
 : Checks if a concept exists in the http://dd.eionet.europa.eu/vocabulary/wise/combinationTableDeterminandUom
 : @param $vocabularyUrl Location of the combinationTableDeterminandUom vocabulary
 : @param $row Row element that includes elements to be checked
 : @param $table the table that needs to match with the vocabulary data
 : @return true if unit exists, false if it doesn't
 :)
declare function xmlutil:checkUnitOfMeasureRdf($vocabularyUrl, $row, $table) {
    let $validRdfValues := xmlutil:getValidRdfValues($vocabularyUrl)
    let $hasDeterminand := data($row/observedPropertyDeterminandCode)
    let $hasUom := data($row/resultUom)
    return exists($validRdfValues[hasDeterminand/@rdf:resource = $hasDeterminand
        and hasUom/@rdf:resource = $hasUom and hasTable/@rdf:resource = $table])
};

(:~
 : If outlier is inclusive returns equal signe otherwise whitespace
 :)
declare function xmlutil:getOutlierEqualSign($pn as node()) as xs:string {
    if(not(common:isMissing($pn/@equal)) and $pn/@equal="true") then '=' else ''
};

declare function xmlutil:getElementValueFromRow($row as element(), $name as xs:string) {
    let $elem := $row/child::*[name() = $name]
    return functx:if-empty($elem, "-empty-")
};

declare function xmlutil:getSchemaUrlFromXML($document as document-node()) {
    let $url := tokenize($document/child::*[1]/@xsi:schemaLocation, " ")[last()]
    let $url :=
        if (empty($url)) then
            tokenize($document/child::*[1]/@xsi:noNamespaceSchemaLocation, " ")[last()]
        else $url
    return
        $url
};

declare function xmlutil:getAuthenticatedUrl($source_url as xs:string, $url2 as xs:string) as xs:string {
    if (contains($source_url, $xmlutil:SOURCE_URL_PARAM)) then
        fn:concat(fn:substring-before($source_url, $xmlutil:SOURCE_URL_PARAM), $xmlutil:SOURCE_URL_PARAM, $url2)
    else
        $url2
};
(:~
 : Module Name: WISE SoE - Emissions (WISE-1) - Envelope checks
 : Obligation: http://rod.eionet.europa.eu/obligations/632
 : @author George Sofianos
 :)



declare variable $source_url as xs:string external;
declare variable $xmlconv:ENVELOPE as document-node() := xmlutil:getDocument($source_url);
(: Rules for checks :)
declare variable $xmlconv:RULES as element(rules) := xmlconv:getRules();
declare variable $xmlconv:ALLOWED_BOOLEAN as xs:string* := ("true", "false", "1", "0");

declare variable $xmlconv:OBLIGATION as xs:string := "http://rod.eionet.europa.eu/obligations/632";
declare variable $xmlconv:DATASET_ID as xs:string := "3351";
declare variable $xmlconv:DATAFLOW as xs:string := "WISE SoE - Emissions (WISE-1)";

declare variable $xmlconv:ENVELOPE_VALID_TABLES :=
    ('http://dd.eionet.europa.eu/v2/dataset/3351/schema-tbl-11057.xsd',
    'http://dd.eionet.europa.eu/v2/dataset/3351/schema-tbl-11074.xsd',
    'http://dd.eionet.europa.eu/v2/dataset/3351/schema-tbl-11075.xsd');


declare function xmlconv:executeChecks($envelopeXml) {
    let $resultCheck1 := xmlconv:executeCheck1($envelopeXml)
    let $resultCheck2 := xmlconv:executeCheck2($envelopeXml)
    let $resultCheck3 := xmlconv:executeCheck3($envelopeXml)

    return ($resultCheck1, $resultCheck2, $resultCheck3)
};

declare function xmlconv:executeCheck1($envelopeXml as document-node()) as element(div) {
    let $ruleCode := "1"
    let $rule := ruleutil:getRule($xmlconv:RULES, "1")
    let $result := xmlconv:checkCheck1($envelopeXml, $rule)

    return
        uiutil:buildEnvelopeTable($xmlconv:ENVELOPE, $rule, $result)
};

declare function xmlconv:executeCheck2($envelopeXml as document-node()) as element(div) {
    let $ruleCode := "2"
    let $rule := ruleutil:getRule($xmlconv:RULES, "2")
    let $result := envelope-common:checkEmptyXML($source_url, $envelopeXml, $rule)
    return
        uiutil:buildEnvelopeTable($xmlconv:ENVELOPE, $rule, $result)
};

declare function xmlconv:executeCheck3($envelopeXml as document-node()) as element(div) {
    let $ruleCode := "3"
    let $rule := ruleutil:getRule($xmlconv:RULES, "3")
    let $result := envelope-common:checkEmptyEnvelope($envelopeXml, $rule)
    return
        uiutil:buildEnvelopeTable($xmlconv:ENVELOPE, $rule, $result)
};

declare function xmlconv:checkCheck1($envelopeXml as document-node(), $rule) as element(Result) {
    let $wrongXmls :=
        for $xml in $envelopeXml//file[@type="text/xml"]
            where (not($xml/@schema = $xmlconv:ENVELOPE_VALID_TABLES))
            return $xml/@name
        return
        <Result> {
            for $file at $pos in $envelopeXml//file[@type="text/xml"]
            return
                <Row row-id="{$pos}">{
                let $errorLevel :=
                    if ($wrongXmls = $file/@name) then
                        ruleutil:getRuleErrorLevel($rule)
                    else
                        string($errors:OK_LEVEL)
                let $res := (
                    1,
                    model:getColumn("File name", string($file/@name), $errors:OK_LEVEL),
                    model:getColumn("Status", errors:getErrorName($errorLevel), $errorLevel)
                    )
                return
                    $res
                }</Row>
        }</Result>
};

 declare function xmlconv:process() as element(div) {
    let $envelopeXml :=
        if (doc-available($source_url)) then
            doc($source_url)
        else ()
    let $isEnvelopeXML := xmlutil:getSchemaUrlFromXML($envelopeXml) = $schema:ENVELOPE_SCHEMA
    let $result :=
        if ($isEnvelopeXML) then
            xmlconv:executeChecks($envelopeXml)
        else
            <div result="1-blocker">{errors:getErrorName(string($errors:BLOCKER_LEVEL))}</div>
    let $errorClass := errors:getResultErrorString($result)
    let $feedbackMessage := errors:getFeedbackMessage($errorClass)

    return
    <div class="feedbacktext">
        { uiutil:buildHeaderSection($xmlconv:RULES, $result, $xmlconv:DATASET_ID, true()) }
        <span id="feedbackStatus" class="{$errorClass}" style="display:none">{$feedbackMessage}</span>
        {$result}
    </div>

};

declare function xmlconv:getRules() as element(rules) {
<rules title="WISE-SOE 2015: Emissions - Envelope Check">
    <group id="content">
        <rule code="1">
        <title>Envelope content test</title>
        <descr>Tests if the schemas of all the XML files in the envelope correspond to the list of schemas allowed for the obligation/dataflow the envelope is assigned to</descr>
        <errorMessage>some the xml files in the envelope don't belong to the {$xmlconv:DATAFLOW} dataset.</errorMessage>
        <errorLevel>{$errors:BLOCKER_LEVEL}</errorLevel>
        <results>
            <summaryTable>{$tables:SUMMARY_EMPTY_TABLE}</summaryTable>
            <resultTable>{$tables:RESULT_SIMPLE}</resultTable>
            <elementsView>File name, Status</elementsView>
            <unit>file</unit>
            <showRow>false</showRow>
        </results>
        </rule>
    </group>
    <group id="status">
        <rule code="2">
            <title>Empty XML check</title>
            <descr>Tests if the envelope contains an empty xml file</descr>
            <errorMessage>some of the xml files in the envelope are empty</errorMessage>
            <errorLevel>{$errors:BLOCKER_LEVEL}</errorLevel>
            <results>
                <summaryTable>{$tables:SUMMARY_EMPTY_TABLE}</summaryTable>
                <resultTable>{$tables:RESULT_SIMPLE}</resultTable>
                <elementsView>File name, Status</elementsView>
                <unit>file</unit>
                <showRow>false</showRow>
            </results>
        </rule>
        <rule code="3">
            <title>Envelope missing XML files</title>
            <descr>Tests if the envelope is missing xml files completely</descr>
            <errorMessage>No XML files are present in the envelope</errorMessage>
            <errorLevel>{$errors:BLOCKER_LEVEL}</errorLevel>
            <results>
                <summaryTable>{$tables:SUMMARY_NULL_TABLE}</summaryTable>
                <resultTable>{$tables:RESULT_SIMPLE}</resultTable>
                <elementsView>File name, Status</elementsView>
                <unit>file</unit>
                <showRow>false</showRow>
            </results>
        </rule>
    </group>
 </rules>
};

xmlconv:process()
