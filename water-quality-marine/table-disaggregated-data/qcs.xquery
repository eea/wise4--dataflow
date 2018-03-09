xquery version "1.0" encoding "UTF-8";

module namespace wqlmdis = 'http://converters.eionet.europa.eu/wise/waterQualityMarine/disaggregatedData';

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

import module namespace vldwqlmdismpsdate = 'http://converters.eionet.europa.eu/wise/waterQualityMarine/disaggregatedData/validators/samplingDate' at './validators/vld-sampling-date.xquery';

import module namespace html = 'http://converters.eionet.europa.eu/common/ui/html' at "../../common/ui/html-scripts.xquery";
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at "../../common/ui/util.xquery";
import module namespace uimandatory = "http://converters.eionet.europa.eu/common/ui/mandatory" at "../../common/ui/mandatory.xquery";
import module namespace uiduplicates = 'http://converters.eionet.europa.eu/common/ui/duplicates' at "../../common/ui/duplicates.xquery";
import module namespace uitypes = 'http://converters.eionet.europa.eu/common/ui/types' at "../../common/ui/types.xquery";
import module namespace uiclist = 'http://converters.eionet.europa.eu/common/ui/codelist' at "../../common/ui/codelist.xquery";
import module namespace uimsiteid = 'http://converters.eionet.europa.eu/wise/common/ui/monitoringSiteIdentifier' at '../../wise-common/ui/ui-monitoring-site-identifier.xquery';
import module namespace uiwqlmdismpsdate = 'http://converters.eionet.europa.eu/wise/waterQualityMarine/disaggregatedData/ui/samplingDate' at './ui/ui-sampling-date.xquery';

declare variable $wqlmdis:TABLE-ID := "11122";

declare function wqlmdis:run-checks($sourceUrl as xs:string)
as element(div)
{
    let $fullDoc := doc($sourceUrl)
    let $dataDoc := $fullDoc//*:DisaggregatedData

    let $model := meta:get-table-metadata($wqlmdis:TABLE-ID)
    let $envelope := interop:get-envelope-metadata($sourceUrl)
    let $countryCode := string($envelope//countrycode)
    let $monitoringSitesVocabulary := doc(concat("../xmlfile/", $countryCode, "_MonitoringSite.rdf"))/*
    let $dataFlowCycles := doc("http://converters.eionet.europa.eu/xmlfile/dataflow_cycles.xml")/*

    return wqlmdis:run-checks($dataDoc, $model, $envelope, $monitoringSitesVocabulary, $dataFlowCycles)
};

declare function wqlmdis:run-checks(
    $dataDoc as element()*,
    $model as element(model), 
    $envelope as element(envelope),
    $monitoringSitesVocabulary as element(),
    $dataFlowCycles as element(DataFlows)
)
as element(div)
{
    let $qcs := wqlmdis:getQcMetadata($model, $envelope, $dataFlowCycles)
    let $dataRows := data:get-rows($dataDoc)
    let $qcResultsMarkup := 
        <div>
            { wqlmdis:_run-mandatory-field-qc($qcs/qc[@id="wqldisqc1"], $model, $dataRows) }
            { wqlmdis:_run-duplicate-rows-qc($qcs/qc[@id="wqldisqc2"], $model, $dataRows) }
            { wqlmdis:_run-data-types-qc($qcs/qc[@id="wqldisqc3"], $model, $dataRows) }
            { wqlmdis:_run-codelists-qc($qcs/qc[@id="wqldisqc4"], $model, $dataRows) }
            { wqlmdis:_run-monitoring-site-id-format-qc($qcs/qc[@id="wqldisqc5"], $model, $envelope, $dataRows) }
            { wqlmdis:_run-monitoring-site-id-reference-qc($qcs/qc[@id="wqldisqc6"], $model, $monitoringSitesVocabulary, $dataRows) }
            { wqlmdis:_run-sampling-date-qc($qcs/qc[@id="wqldisqc7"], $model, $dataFlowCycles, $dataRows) }
        </div>
    return 
        <div class="feedbacktext"> 
            { html:getCss() }
            { html:getJavascript() }
            <div>
                { uiutil:build-header-and-menu-markup("WISE SoE - Water quality in transitional, coastal and marine waters", "Disaggregated Data", $qcs, $qcResultsMarkup) }
                { $qcResultsMarkup }
            </div>
        </div>
};

declare function wqlmdis:getQcMetadata(
    $model as element(model),
    $envelope as element(envelope),
    $dataFlowCycles as element(DataFlows)
)
as element(qcs)
{
    <qcs>
        { wqlmdis:_get-mandatory-qc-metadata($model) }
        { wqlmdis:_get-duplicate-rows-qc-metadata($model) }
        { wqlmdis:_get-data-types-qc-metadata($model) }
        { wqlmdis:_get-codelists-qc-metadata($model) }
        { wqlmdis:_get-monitoring-site-id-format-qc-metadata($model, $envelope) }
        { wqlmdis:_get-monitoring-site-id-reference-qc-metadata($model) }
        { wqlmdis:_get-sampling-date-qc-metadata($dataFlowCycles) }
    </qcs>
};

declare function wqlmdis:_get-mandatory-qc-metadata($model as element(model))
as element(qc)
{
    let $mandatoryColumns := (meta:get-mandatory-columns($model), meta:get-columns-by-names($model, ('sampleIdentifier')))
    let $mandatoryColumnString := string-join($mandatoryColumns/meta:get-column-name(.), ", ")
    return
        <qc id="wqldisqc1">
            <caption>1. Mandatory values test</caption>
            <description>
                Tested the presence of mandatory values - { $mandatoryColumnString }.
                <br/><br/>
                Missing resultObservedValue can be explained by using an appropriate flag in the resultObservationStatus field.
            </description>
            <columnExceptions>
                <columnException columnName="resultObservedValue" onMatch="{ $qclevels:INFO }">
                    <dependencies>
                        <dependency columnName="resultObservationStatus">
                            <acceptedValues>
                                <value>O</value>
                                <value>M</value>
                                <value>L</value>
                                <value>N</value>
                                <value>Z</value>
                            </acceptedValues>
                        </dependency>
                    </dependencies>
                </columnException>
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

declare function wqlmdis:_get-duplicate-rows-qc-metadata($model as element(model))
as element(qc)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $keyColumnsList := string-join($keyColumns/meta:get-column-name(.), ", ")
    return
        <qc id="wqldisqc2">
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

declare function wqlmdis:_get-data-types-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="wqldisqc3">
        <caption>3. Data types test</caption>
        <description>Tested that the format of reported values matches the Data Dictionary specifications.</description>
        <typeExceptions> {
                for $column in $model/columns/column[@dataType = 'string']
                return
                    <typeException columnName="{ meta:get-column-name($column) }" restrictionName="maxLength" qcResult="{ $qclevels:OK }" />
            }
        </typeExceptions>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>BLOCKER - some of the values are not in the correct format.</message>
        </onBlocker>
    </qc>
};

declare function wqlmdis:_get-codelists-qc-metadata($model as element(model))
as element(qc)
{
    let $codelistColumns := meta:get-valuelist-columns($model)
    let $codelistColumnsString := string-join($codelistColumns/meta:get-column-name(.), ", ")
    return
        <qc id="wqldisqc4">
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
                <url columnName="parameterWaterBodyCategory" value="http://dd.eionet.europa.eu/vocabulary/wise/WFDWaterBodyCategory" />
                <url columnName="observedPropertyDeterminandCode" value="http://dd.eionet.europa.eu/vocabulary/wise/ObservedProperty" />
                <url columnName="resultUom" value="http://dd.eionet.europa.eu/vocabulary/wise/Uom" />
                <url columnName="procedureAnalysedMatrix" value="http://dd.eionet.europa.eu/vocabulary/wise/Matrix" />
                <url columnName="resultQualityObservedValueBelowLOQ" value="http://dd.eionet.europa.eu/fixedvalues/elem/75896" />
                <url columnName="resultObservationStatus" value="http://dd.eionet.europa.eu/fixedvalues/elem/77669" />
                <url columnName="parameterSpecies" value="http://dd.eionet.europa.eu/fixedvalues/elem/87972" />
            </codelistUrls>
        </qc>
};

declare function wqlmdis:_get-monitoring-site-id-format-qc-metadata($model as element(model), $envelope as element(envelope))
as element(qc)
{
    let $countryCode := valconv:convertCountryCode($envelope/countrycode)
    return
        <qc id="wqldisqc5">
            <caption>5. Monitoring site identifier format test</caption>
            <description>
                Tested correctness of the monitoringSiteIdentifier value format:
                <ol>
                    <li>
                        The country code part of the identifier value must match the one of the reporting country { $countryCode }, except use "UK" instead of "GB" and use "EL" instead of "GR"
                    </li>
                    <li>
                        <![CDATA[
                        The identifier value can't contain punctuation marks, white space or other special characters, including accented characters, except for "-" or "_".  It must use only upper case letters. The third character, following the 2-letter country code, can't be "-" or "_". The total length of the identifier can't exceed 42 characters. (Regular expression: [A-Z]{2}[0-9A-Z]{1}[0-9A-Z-_]{0,39})
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

declare function wqlmdis:_get-monitoring-site-id-reference-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="wqldisqc6">
        <caption>6. Monitoring site identifier reference test</caption>
        <description>
            Tested presence of the monitoringSiteIdentifier and its respective monitoringSiteIdntifierScheme in the <a target="_blank" href="http://dd.eionet.europa.eu/vocabulary/wise/monitoringSite">official reference list</a>. The list has been created from the previously reported data on monitoring sites.
            <br/><br/>
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

declare function wqlmdis:_get-sampling-date-qc-metadata($dataFlowCycles as element(DataFlows))
as element(qc)
{
    let $flowCycle := vldwqlmdismpsdate:get-data-flow-cycle($dataFlowCycles)
    let $dateStart := string(year-from-date(xs:date($flowCycle/timeValuesLimitDateStart)))
    let $dateEnd := string(year-from-date(xs:date($flowCycle/timeValuesLimitDateEnd)))
    return
        <qc id="wqldisqc7">
            <caption>7. Sampling date test</caption>
            <description>
                Tested whether the phenomenonTimeSamplingDate value is from the expected range ({ $dateStart } - { $dateEnd }).
            </description>
            <onSuccess>
                <message>OK - data passed the test.</message>
            </onSuccess>
            <onWarning>
                <message>WARNING - some of the reported phenomenonTimeSamplingDate values are outside the expected range. The detected records will not be processed.</message>
            </onWarning>
        </qc>
};

declare function wqlmdis:_run-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $columnExceptions, $dataRows)
    let $colunsToDisplay := ($mandatoryColumns, $model/columns/column[meta:get-column-name(.) = ('resultObservationStatus', 'Remarks')])
    return uimandatory:build-mandatory-column-qc-markup($qc, $colunsToDisplay, $validationResult)
};

declare function wqlmdis:_run-duplicate-rows-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $validationResult := vldduplicates:validate-duplicate-rows($dataRows, $keyColumns)
    let $columnsToDisplay := ($keyColumns, $model/columns/column[meta:get-column-name(.) = ('resultUom', 'resultObservedValue', 'resultObservationStatus', 'Remarks')])
    return uiduplicates:build-duplicate-rows-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function wqlmdis:_run-data-types-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $typeExceptions := $qc/typeExceptions
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtypes:validate-data-types($model, $dataRows, $typeExceptions)
    return uitypes:build-data-types-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function wqlmdis:_run-codelists-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $additionalColumnNames := ("resultObservedValue", "Remarks")
    let $columnsToDisplay :=
        for $column in $model/columns/column
        where meta:is-primary-key-column($column)
                or meta:is-valuelist-column($column)
                or meta:get-column-name($column) = $additionalColumnNames
        return $column
    let $codelistUrls := $qc/codelistUrls
    let $validationResult :=  vldclist:validate-codelists($model, $dataRows)
    return uiclist:build-codelists-markup($qc, $model, $columnsToDisplay, $codelistUrls, $validationResult)
};

declare function wqlmdis:_run-monitoring-site-id-format-qc($qc as element(qc), $model as element(model), $envelope as element(envelope), $dataRows as element(dataRow)*)
as element(div)
{
    let $monitoringSiteIdColumn := $model/columns/column[meta:get-column-name(.) = 'monitoringSiteIdentifier']
    let $monitoringSiteIdSchemeColumn := $model/columns/column[meta:get-column-name(.) = 'monitoringSiteIdentifierScheme']
    let $validationResult :=  vldmsiteid:validate-monitoring-site-identifier-format($monitoringSiteIdColumn, $envelope, $dataRows)
    return uimsiteid:build-monitoring-site-id-format-qc-markup($qc, $monitoringSiteIdColumn, $monitoringSiteIdSchemeColumn, $validationResult)
};

declare function wqlmdis:_run-monitoring-site-id-reference-qc(
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

declare function wqlmdis:_run-sampling-date-qc(
    $qc as element(qc), 
    $model as element(model),
    $dataFlowCycles as element(DataFlows),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnsToDisplay := (meta:get-primary-key-columns($model), meta:get-columns-by-names($model, ('resultUom', 'resultObservedValue', 'resultObservationStatus', 'Remarks')))
    let $validationResult := vldwqlmdismpsdate:validate-sampling-date($model, $dataFlowCycles, $dataRows)
    return uiwqlmdismpsdate:build-sampling-date-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};
