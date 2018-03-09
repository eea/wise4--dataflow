xquery version "1.0" encoding "UTF-8";

module namespace emissions_riverineinputloads = 'http://converters.eionet.europa.eu/wise/emissions/riverineinputloads';

import module namespace html = 'http://converters.eionet.europa.eu/common/ui/html' at "../../common/ui/html-scripts.xquery";
import module namespace interop = "http://converters.eionet.europa.eu/common/interop" at "../../common/interop.xquery";
import module namespace meta = "http://converters.eionet.europa.eu/common/meta" at "../../common/meta.xquery";
import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../common/data.xquery";
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../common/qclevels.xquery';
import module namespace valconv = "http://converters.eionet.europa.eu/common/valueConversion" at "../../common/value-conversion.xquery";

import module namespace vldmandatory = "http://converters.eionet.europa.eu/common/validators/mandatory" at "../../common/validators/mandatory.xquery";
import module namespace vldduplicates = 'http://converters.eionet.europa.eu/common/validators/duplicates' at "../../common/validators/duplicates.xquery";
import module namespace vldtypes = 'http://converters.eionet.europa.eu/common/validators/types' at "../../common/validators/types.xquery";
import module namespace vldclist = 'http://converters.eionet.europa.eu/common/validators/codelist' at "../../common/validators/codelist.xquery";
import module namespace vldmsiteid = 'http://converters.eionet.europa.eu/wise/common/validators/monitoringSiteIdentifier' at '../../wise-common/validators/vld-monitoring-site-identifier.xquery';
import module namespace vldrefyear = 'http://converters.eionet.europa.eu/wise/common/validators/referenceYear' at '../../wise-common/validators/vld-reference-year.xquery';

import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at "../../common/ui/util.xquery";
import module namespace uimandatory = "http://converters.eionet.europa.eu/common/ui/mandatory" at "../../common/ui/mandatory.xquery";
import module namespace uiduplicates = 'http://converters.eionet.europa.eu/common/ui/duplicates' at "../../common/ui/duplicates.xquery";
import module namespace uitypes = 'http://converters.eionet.europa.eu/common/ui/types' at "../../common/ui/types.xquery";
import module namespace uiclist = 'http://converters.eionet.europa.eu/common/ui/codelist' at "../../common/ui/codelist.xquery";
import module namespace uimsiteid = 'http://converters.eionet.europa.eu/wise/common/ui/monitoringSiteIdentifier' at '../../wise-common/ui/ui-monitoring-site-identifier.xquery';
import module namespace uirefyear = 'http://converters.eionet.europa.eu/wise/common/ui/referenceYear' at '../../wise-common/ui/ui-reference-year.xquery';

declare variable $emissions_riverineinputloads:TABLE-ID := "11074";

declare function emissions_riverineinputloads:run-checks($sourceUrl as xs:string)
as element(div)
{

    let $fullDoc := doc($sourceUrl)
    let $dataDoc := $fullDoc//*:RiverineInputLoads

    let $model := meta:get-table-metadata($emissions_riverineinputloads:TABLE-ID)
    let $envelope := interop:get-envelope-metadata($sourceUrl)
    let $envelopeCountryCode := upper-case(string($envelope/countrycode))
    let $dataFlowCycles := doc("http://converters.eionet.europa.eu/xmlfile/dataflow_cycles.xml")/*
    let $monitoringSitesVocabulary := doc(concat("../xmlfile/", $envelopeCountryCode, "_MonitoringSite.rdf"))/*
    return emissions_riverineinputloads:run-checks($dataDoc, $model, $envelope, $dataFlowCycles, $monitoringSitesVocabulary)
};

declare function emissions_riverineinputloads:run-checks(
    $dataDoc as element()*,
    $model as element(model), 
    $envelope as element(envelope),
    $dataFlowCycles as element(DataFlows),
    $monitoringSitesVocabulary as element()
)
as element(div)
{
    let $qcs := emissions_riverineinputloads:getQcMetadata($model, $envelope, $dataFlowCycles)
    let $dataRows := data:get-rows($dataDoc)
    let $qcResultsMarkup := 
        <div>
            { emissions_riverineinputloads:_run-mandatory-field-qc($qcs/qc[@id="erilqc1"], $model, $dataRows) }
            { emissions_riverineinputloads:_run-duplicate-rows-qc($qcs/qc[@id="erilqc2"], $model, $dataRows) }
            { emissions_riverineinputloads:_run-data-types-qc($qcs/qc[@id="erilqc3"], $model, $dataRows) }
            { emissions_riverineinputloads:_run-codelists-qc($qcs/qc[@id="erilqc4"], $model, $dataRows) }
            { emissions_riverineinputloads:_run-monitoring-site-id-format-qc($qcs/qc[@id="erilqc5"], $model, $envelope, $dataRows) }
            { emissions_riverineinputloads:_run-monitoring-site-id-reference-qc($qcs/qc[@id="erilqc6"], $model, $monitoringSitesVocabulary, $dataRows) }
            { emissions_riverineinputloads:_run-reference-year-qc($qcs/qc[@id="erilqc7"], $model, $dataFlowCycles, $dataRows) }
        </div>
    return 
        <div class="feedbacktext">
            { html:getCss() }
            { html:getJavascript() }
            <div>
                { uiutil:build-header-and-menu-markup("WISE SoE - Emissions", "RiverineInputLoads", $qcs, $qcResultsMarkup) }
                { $qcResultsMarkup }
            </div>
        </div>
};

declare function emissions_riverineinputloads:getQcMetadata(
    $model as element(model),
    $envelope as element(envelope),
    $dataFlowCycles as element(DataFlows)
)
as element(qcs)
{
    <qcs>
        { emissions_riverineinputloads:_get-mandatory-qc-metadata($model) }
        { emissions_riverineinputloads:_get-duplicate-rows-qc-metadata($model) }
        { emissions_riverineinputloads:_get-data-types-qc-metadata($model) }
        { emissions_riverineinputloads:_get-codelists-qc-metadata($model) }
        { emissions_riverineinputloads:_get-monitoring-site-id-format-qc-metadata($envelope) }
        { emissions_riverineinputloads:_get-monitoring-site-id-reference-qc-metadata() }
        { emissions_riverineinputloads:_get-reference-year-qc-metadata($dataFlowCycles) }
    </qcs>
};

declare function emissions_riverineinputloads:_get-mandatory-qc-metadata($model as element(model))
as element(qc)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    let $mandatoryColumnString := string-join($mandatoryColumns/meta:get-column-name(.), ", ")
    let $exceptionColumnNames := ("resultEmissionsValue")
    let $dependencyColumnName := "resultObservationStatus"
    return
        <qc id="erilqc1">
            <caption>1. Mandatory values test</caption>
            <description>
                Tested the presence of mandatory values - { $mandatoryColumnString }.
                <br/><br/>
                Missing resultEmissionsValue can be explained by using an appropriate flag in the resultObservationStatus field.
            </description>
            <columnExceptions> {
                let $dependencies :=
                    <dependencies>
                        <dependency columnName="{ $dependencyColumnName }">
                            <acceptedValues>
                                <value>O</value>
                                <value>M</value>
                                <value>L</value>
                                <value>N</value>
                                <value>Z</value>
                            </acceptedValues>
                        </dependency>
                    </dependencies>
                for $columnName in $exceptionColumnNames
                return
                    <columnException columnName="{ $columnName }" onMatch="{ $qclevels:INFO }">
                        { $dependencies }
                    </columnException>
            }
            </columnExceptions>
            <onSuccess>
                <message>OK - data passed the test.</message>
            </onSuccess>
            <onInfo>
                <message>INFO - some mandatory values are missing but explanation is provided in the resultObservationStatus field.</message>
            </onInfo>
            <onBlocker>
                <message>BLOCKER - some mandatory values are missing.</message>
            </onBlocker>
        </qc>
};

declare function emissions_riverineinputloads:_get-duplicate-rows-qc-metadata($model as element(model))
as element(qc)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $keyColumnsList := string-join($keyColumns/meta:get-column-name(.), ", ")
    return
        <qc id="erilqc2">
            <caption>2. Record uniqueness test</caption>
            <description>Tested uniqueness of the records.  Combination of the values { $keyColumnsList } must be unique for each record in the table. No multiplicities can exist.</description>
            <onSuccess>
                <message>OK - data passed the test.</message>
            </onSuccess>
            <onBlocker>
                <message>BLOCKER - multiplicities have been detected.</message>
            </onBlocker>
        </qc>
};

declare function emissions_riverineinputloads:_get-data-types-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="erilqc3">
        <caption>3. Data types test</caption>
        <description>Tested that the format of reported values matches the Data Dictionary specifications.</description>
        <typeExceptions> {
            for $column in $model/columns/column[@dataType = 'string']
            return
                <typeException columnName="{ meta:get-column-name($column) }" restrictionName="maxLength" qcResult="{ $qclevels:OK }" />
        }
            <typeException columnName="phenomenonTimeSamplingDate" restrictionName="type" qcResult="{ $qclevels:OK }"  />
        </typeExceptions>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>BLOCKER - some of the values are not in the correct format.</message>
        </onBlocker>
    </qc>
};

declare function emissions_riverineinputloads:_run-codelists-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $exceptions := $qc/codelistExceptions/*
    let $columnsToDisplay := $model/columns/column
    let $codelistUrls := $qc/codelistUrls
    let $validationResult :=  vldclist:validate-codelists($model, $exceptions, $dataRows)
    return uiclist:build-codelists-markup($qc, $model, $columnsToDisplay, $codelistUrls, $validationResult)
};

declare function emissions_riverineinputloads:_get-codelists-qc-metadata($model as element(model))
as element(qc)
{
    let $codelistColumns := meta:get-valuelist-columns($model)
    let $codelistColumnsString := string-join($codelistColumns/meta:get-column-name(.), ", ")
    return
        <qc id="erilqc4">
            <caption>4. Valid codes test</caption>
            <description>Tested the correctness of values against the respective codelists. Checked values are { $codelistColumnsString }.</description>
            <onSuccess>
                <message>OK - data passed the test.</message>
            </onSuccess>
            <onWarning>
                <message>WARNING - some of the values do not exist in the respective code lists.</message>
            </onWarning>
            <onBlocker>
                <message>BLOCKER - some of the values do not exist in the respective code lists.</message>
            </onBlocker>
            <codelistUrls>
                <url columnName="monitoringSiteIdentifierScheme" value="http://dd.eionet.europa.eu/fixedvalues/elem/75870" />
                <url columnName="observedPropertyDeterminandCode" value="http://dd.eionet.europa.eu/vocabulary/wise/ObservedProperty" />
                <url columnName="resultEmissionsUom" value="http://dd.eionet.europa.eu/vocabulary/wise/UomEmissions/view" />
                <url columnName="procedureEstimateDetail" value="http://dd.eionet.europa.eu/fixedvalues/elem/92771"/>
                <url columnName="resultObservationStatus" value="http://dd.eionet.europa.eu/fixedvalues/elem/77669" />
            </codelistUrls>
        </qc>
};

declare function emissions_riverineinputloads:_get-monitoring-site-id-format-qc-metadata($envelope as element(envelope))
as element(qc)
{
    let $countryCode := valconv:convertCountryCode($envelope/countrycode)
    return
        <qc id="erilqc5">
            <caption>5. Monitoring site identifier format test</caption>
            <description>
                Tested correctness of the monitoringSiteIdentifier value format:
                <ol>
                    <li>
                        The country code part of the identifier value must match the one of the reporting country { $countryCode }, except use "UK" instead of "GB" and use "EL" instead of "GR".
                    </li>
                    <li>
                        <![CDATA[
                        The identifier value can't contain punctuation marks, white space or other special characters, including accented characters, except for "-" or "_". Presence of two or more consecutive "-" or "_" characters ("--" or "__"), or their combination ("_-" or "-_"), is however not allowed. The identifier value must use only upper case letters. The third character, following the 2-letter country code, and the last character can't be "-" or "_". The total length of the identifier can't exceed 42 characters. (Regular expressions:  [A-Z]{2}[0-9A-Z]{1}[0-9A-Z-_]{0,39})
                        ]]>
                    </li>
                </ol>
            </description>
            <onSuccess>
                <message>OK - data passed the test.</message>
            </onSuccess>
            <onBlocker>
                <message>BLOCKER - some of the monitoringSiteIdentifier values are either incorrectly formated or identify sites that belong to a different country.</message>
            </onBlocker>
        </qc>
};

declare function emissions_riverineinputloads:_get-monitoring-site-id-reference-qc-metadata()
as element(qc)
{
    <qc id="erilqc6">
        <caption>6. Monitoring site identifier reference test</caption>
        <description>
            Tested presence of the monitoringSiteIdentifier and its respective monitoringSiteIdntifierScheme in the <a target="_blank" href="http://dd.eionet.europa.eu/vocabulary/wise/MonitoringSite">official reference list</a>. The list has been created from the previously reported data on monitoring sites.
            <br/>
            Due to the ongoing reporting of WFD data, which includes also update of the monitoring sites, the detected discrepancies are currently not considered as errors. They will be considered as blocker errors in the future reporting cycles.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onWarning>
            <message>WARNING - some of the monitoringSiteIdentifier values are missing in the reference list. Please assure that it is not due to an error and that they are reported under WFD, or report them under WISE Spatial data reporting.</message>
        </onWarning>
    </qc>
};

declare function emissions_riverineinputloads:_get-reference-year-qc-metadata($dataFlowCycles as element(DataFlows))
as element(qc)
{
    let $dataFlowCycle := vldrefyear:get-data-flow-cycle_emission_2017($dataFlowCycles)
    let $yearStart := vldrefyear:get-start-year($dataFlowCycle)
    let $yearEnd := vldrefyear:get-end-year($dataFlowCycle)
    return
        <qc id="erilqc7">
            <caption>7. Reference year test</caption>
            <description>
                Tested whether the phenomenonTimeReferenceYear value is from the expected range ({ $yearStart } - { $yearEnd }).
            </description>
            <onSuccess>
                <message>OK - data passed the test.</message>
            </onSuccess>
            <onWarning>
                <message>
                    WARNING - some of the reported phenomenonTimeReferenceYear values are outside the expected range. The detected records will not be processed.
                </message>
            </onWarning>
        </qc>
};

declare function emissions_riverineinputloads:_run-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $columnExceptions, $dataRows)
    let $colunsToDisplay := $model/columns/column
    return uimandatory:build-mandatory-column-qc-markup($qc, $colunsToDisplay, $validationResult)
};

declare function emissions_riverineinputloads:_run-duplicate-rows-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $validationResult := vldduplicates:validate-duplicate-rows($dataRows, $keyColumns)
    let $columnsToDisplay := $model/columns/column
    return uiduplicates:build-duplicate-rows-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function emissions_riverineinputloads:_run-data-types-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $typeExceptions := $qc/typeExceptions
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtypes:validate-data-types($model, $dataRows, $typeExceptions)
    return uitypes:build-data-types-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function emissions_riverineinputloads:_run-monitoring-site-id-format-qc($qc as element(qc), $model as element(model), $envelope as element(envelope), $dataRows as element(dataRow)*)
as element(div)
{
    let $monitoringSiteIdColumn := $model/columns/column[meta:get-column-name(.) = 'monitoringSiteIdentifier']
    let $monitoringSiteIdSchemeColumn := $model/columns/column[meta:get-column-name(.) = 'monitoringSiteIdentifierScheme']
    let $validationResult :=  vldmsiteid:validate-monitoring-site-identifier-format($monitoringSiteIdColumn, $envelope, $dataRows)
    return uimsiteid:build-monitoring-site-id-format-qc-markup($qc, $monitoringSiteIdColumn, $monitoringSiteIdSchemeColumn, $validationResult)
};

declare function emissions_riverineinputloads:_run-monitoring-site-id-reference-qc(
        $qc as element(qc),
        $model as element(model),
        $monitoringSitesVocabulary as element(),
        $dataRows as element(dataRow)*
)
as element(div)
{
    let $monitoringSiteIdColumn := $model/columns/column[meta:get-column-name(.) = 'monitoringSiteIdentifier']
    let $monitoringSiteIdSchemeColumn := $model/columns/column[meta:get-column-name(.) = 'monitoringSiteIdentifierScheme']
    let $validationResult :=  vldmsiteid:validate-monitoring-site-identifier-reference($monitoringSiteIdColumn, $monitoringSiteIdSchemeColumn, $monitoringSitesVocabulary, $dataRows)
    return uimsiteid:build-monitoring-site-id-reference-qc-markup($qc, $monitoringSiteIdColumn, $monitoringSiteIdSchemeColumn, $validationResult)
};

declare function emissions_riverineinputloads:_run-reference-year-qc(
        $qc as element(qc),
        $model as element(model),
        $dataFlowCycles as element(DataFlows),
        $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnReferenceYear := meta:get-column-by-name($model, "phenomenonTimeReferenceYear")
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldrefyear:validate-reference-year-emissions-2017($columnReferenceYear, $dataFlowCycles, $dataRows)
    return uirefyear:build-reference-year-qc-markup($qc, $columnReferenceYear, $columnsToDisplay, $validationResult)
};
