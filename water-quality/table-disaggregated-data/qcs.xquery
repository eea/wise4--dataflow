xquery version "1.0" encoding "UTF-8";

module namespace wqldis = 'http://converters.eionet.europa.eu/wise/waterQuality/disaggregatedData';

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
import module namespace vlduom = "http://converters.eionet.europa.eu/wise/common/validators/unitOfMeasure" at '../../wise-common/validators/vld-unit-of-measure.xquery';
import module namespace vldwqldismpsdate = 'http://converters.eionet.europa.eu/wise/waterQuality/disaggregatedData/validators/samplingDate' at './validators/vld-sampling-date.xquery';
import module namespace vldwqlvallim = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/valueLimits" at "../common/validators/vld-value-limits.xquery";
import module namespace vldwqldisobsvallim = "http://converters.eionet.europa.eu/wise/waterQuality/disaggregatedData/validators/observedValueLimits" at './validators/vld-observed-value-limits.xquery';
import module namespace vldwqldisloq = "http://converters.eionet.europa.eu/wise/waterQuality/disaggregatedData/validators/loq" at "./validators/vld-loq.xquery";
import module namespace vldwqldsmpdpth = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/sampleDepth" at "../common/validators/vld-sample-depth.xquery";

import module namespace html = 'http://converters.eionet.europa.eu/common/ui/html' at "../../common/ui/html-scripts.xquery";
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at "../../common/ui/util.xquery";
import module namespace uimandatory = "http://converters.eionet.europa.eu/common/ui/mandatory" at "../../common/ui/mandatory.xquery";
import module namespace uiduplicates = 'http://converters.eionet.europa.eu/common/ui/duplicates' at "../../common/ui/duplicates.xquery";
import module namespace uitypes = 'http://converters.eionet.europa.eu/common/ui/types' at "../../common/ui/types.xquery";
import module namespace uiclist = 'http://converters.eionet.europa.eu/common/ui/codelist' at "../../common/ui/codelist.xquery";
import module namespace uimsiteid = 'http://converters.eionet.europa.eu/wise/common/ui/monitoringSiteIdentifier' at '../../wise-common/ui/ui-monitoring-site-identifier.xquery';
import module namespace uiuom = "http://converters.eionet.europa.eu/wise/common/ui/unitOfMeasure" at '../../wise-common/ui/ui-unit-of-measure.xquery';
import module namespace uiwqldismpsdate = 'http://converters.eionet.europa.eu/wise/waterQuality/disaggregatedData/ui/samplingDate' at './ui/ui-sampling-date.xquery';
import module namespace uiwqlvallim = "http://converters.eionet.europa.eu/wise/waterQuality/common/ui/valueLimits" at "../common/ui/ui-value-limits.xquery";

declare variable $wqldis:TABLE-ID := "9153";

declare function wqldis:run-checks($sourceUrl as xs:string)
as element(div)
{
    let $dataDoc := doc($sourceUrl)
    let $model := meta:get-table-metadata($wqldis:TABLE-ID)
    let $envelope := interop:get-envelope-metadata($sourceUrl)
    let $countryCode := string($envelope//countrycode)
    let $monitoringSitesVocabulary := doc(concat("../xmlfile/", $countryCode, "_MonitoringSite.rdf"))/*
    let $vocabularyUom := doc("http://dd.eionet.europa.eu/vocabulary/wise/Uom/rdf")/*
    let $vocabularyObservedProperty := doc("http://dd.eionet.europa.eu/vocabulary/wise/ObservedProperty/rdf")/*
    let $vocabularyCombinationTableDeterminandUom := doc("http://dd.eionet.europa.eu/vocabulary/wise/QCCombinationTableDeterminandUom/rdf")/*
    let $dataFlowCycles := doc("http://converters.eionet.europa.eu/xmlfile/dataflow_cycles.xml")/*
    let $limitDefinitions := doc("http://converters.eionet.europa.eu/xmlfile/wise_soe_determinand_value_limits.xml")/*
    return wqldis:run-checks($dataDoc, $model, $envelope, $monitoringSitesVocabulary, $vocabularyUom, $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $dataFlowCycles, $limitDefinitions)
};

declare function wqldis:run-checks(
    $dataDoc as document-node(),
    $model as element(model), 
    $envelope as element(envelope),
    $monitoringSitesVocabulary as element(),
    $vocabularyUom as element(),
    $vocabularyObservedProperty as element(),
    $vocabularyCombinationTableDeterminandUom as element(),
    $dataFlowCycles as element(DataFlows),
    $limitDefinitions as element(WiseSoeQc)
)
as element(div)
{
    let $qcs := wqldis:getQcMetadata($model, $envelope, $dataFlowCycles)
    let $dataRows := data:get-rows($dataDoc)
    let $qcResultsMarkup := 
        <div>
            { wqldis:_run-mandatory-field-qc($qcs/qc[@id="qc1"], $model, $dataRows) }
            { wqldis:_run-duplicate-rows-qc($qcs/qc[@id="qc2"], $model, $dataRows) }
            { wqldis:_run-data-types-qc($qcs/qc[@id="qc3"], $model, $dataRows) }
            { wqldis:_run-codelists-qc($qcs/qc[@id="qc4"], $model, $dataRows) }
            { wqldis:_run-monitoring-site-id-format-qc($qcs/qc[@id="qc5"], $model, $envelope, $dataRows) }
            { wqldis:_run-monitoring-site-id-reference-qc($qcs/qc[@id="qc6"], $model, $monitoringSitesVocabulary, $dataRows) }
            { wqldis:_run-unit-of-measure-qc($qcs/qc[@id="qc7"], $model, $vocabularyUom, $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $dataRows) }
            { wqldis:_run-sampling-date-qc($qcs/qc[@id="qc8"], $model, $dataFlowCycles, $dataRows) }
            { wqldis:_run-observed-value-limits-qc($qcs/qc[@id="qc9"], $model, $vocabularyObservedProperty, $limitDefinitions, $dataRows) }
            { wqldis:_run-loq-qc($qcs/qc[@id="qc10"], $model, $vocabularyObservedProperty, $dataRows) }
            { wqldis:_run-sample-depth-qc($qcs/qc[@id="qc11"], $model, $monitoringSitesVocabulary, $dataRows) }
        </div>
    return 
        <div class="feedbacktext"> 
            { html:getCss() }
            { html:getJavascript() }
            <div>
                { uiutil:build-header-and-menu-markup("WISE SoE - Water Quality", "Sample data by monitoring site", $qcs, $qcResultsMarkup) }
                { $qcResultsMarkup }
            </div>
        </div>
};

declare function wqldis:getQcMetadata(
    $model as element(model),
    $envelope as element(envelope),
    $dataFlowCycles as element(DataFlows)
)
as element(qcs)
{
    <qcs>
        { wqldis:_get-mandatory-qc-metadata($model) }
        { wqldis:_get-duplicate-rows-qc-metadata($model) }
        { wqldis:_get-data-types-qc-metadata($model) }
        { wqldis:_get-codelists-qc-metadata($model) }
        { wqldis:_get-monitoring-site-id-format-qc-metadata($model, $envelope) }
        { wqldis:_get-monitoring-site-id-reference-qc-metadata($model) }
        { wqldis:_get-unit-of-measure-qc-metadata() }
        { wqldis:_get-sampling-date-qc-metadata($dataFlowCycles) }
        { wqldis:_get-observed-value-limits-qc-metadata() }
        { wqldis:_get-loq-qc-metadata() }
        { wqldis:_get-sample-depth-qc-metadata() }
    </qcs>
};

declare function wqldis:_get-mandatory-qc-metadata($model as element(model))
as element(qc)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    let $mandatoryColumnString := string-join($mandatoryColumns/meta:get-column-name(.), ", ")
    return
        <qc id="qc1">
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

declare function wqldis:_get-duplicate-rows-qc-metadata($model as element(model))
as element(qc)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $keyColumnsList := string-join($keyColumns/meta:get-column-name(.), ", ")
    return
        <qc id="qc2">
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

declare function wqldis:_get-data-types-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="qc3">
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

declare function wqldis:_get-codelists-qc-metadata($model as element(model))
as element(qc)
{
    let $codelistColumns := meta:get-valuelist-columns($model)
    let $codelistColumnsString := string-join($codelistColumns/meta:get-column-name(.), ", ")
    return
        <qc id="qc4">
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
                <url columnName="procedureAnalysedFraction" value="http://dd.eionet.europa.eu/fixedvalues/elem/75921" />
                <url columnName="procedureAnalysedMedia" value="http://dd.eionet.europa.eu/fixedvalues/elem/75920" />
                <url columnName="resultUom" value="http://dd.eionet.europa.eu/vocabulary/wise/Uom" />
                <url columnName="resultQualityObservedValueBelowLOQ" value="http://dd.eionet.europa.eu/fixedvalues/elem/75896" />
                <url columnName="procedureAnalyticalMethod" value="http://dd.eionet.europa.eu/fixedvalues/elem/75922" />
                <url columnName="resultObservationStatus" value="http://dd.eionet.europa.eu/fixedvalues/elem/77669" />
            </codelistUrls>
        </qc>
};

declare function wqldis:_get-monitoring-site-id-format-qc-metadata($model as element(model), $envelope as element(envelope))
as element(qc)
{
    let $countryCode := valconv:convertCountryCode($envelope/countrycode)
    return
        <qc id="qc5">
            <caption>5. Monitoring site identifier format test</caption>
            <description>
                Tested correctness of the monitoringSiteIdentifier value format:
                <ol>
                    <li>
                        The country code part of the identifier value must match the one of the reporting country { $countryCode }
                    </li>
                    <li>
                        <![CDATA[
                        The identifier value can't contain punctuation marks, white space or other special characters, including accented characters, except for "-" or "_". Presence of two or more consecutive "-" or "_" characters ("--" or "__"), or their combination ("_-" or "-_"), is however not allowed. The identifier value must use only upper case letters. The third character, following the 2-letter country code, and the last character can't be "-" or "_". The total length of the identifier can't exceed 42 characters. (Regular expressions: ^[A-Z]{2}[0-9A-Z]{1}([0-9A-Z_\-]{0,38}[0-9A-Z]{1}){0,1}$ and ^([A-Z0-9](\-|_)?)+$)
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

declare function wqldis:_get-monitoring-site-id-reference-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="qc6">
        <caption>6. Monitoring site identifier reference test</caption>
        <description>
            Tested presence of the monitoringSiteIdentifier and its respective monitoringSiteIdntifierScheme in the <a target="_blank" href="http://dd.eionet.europa.eu/vocabulary/wise/MonitoringSite">official reference list</a>. The list has been created from the previously reported data on monitoring sites.
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

declare function wqldis:_get-unit-of-measure-qc-metadata()
as element(qc)
{
    <qc id="qc7">
        <caption>7. Unit of measure test</caption>
        <description>
            Tested whether corect resultUom Values have been used for the observed determinands. The test also detects determinands which are not expected to be reported in this table.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - incorrect resultUom values have been reported for some of the determinands or unexpected determinands have been reported.
            </message>
        </onBlocker>
    </qc>
};

declare function wqldis:_get-sampling-date-qc-metadata($dataFlowCycles as element(DataFlows))
as element(qc)
{
    let $flowCycle := vldwqldismpsdate:get-data-flow-cycle($dataFlowCycles)
    let $dateStart := string($flowCycle/timeValuesLimitDateStart)
    let $dateEnd := string($flowCycle/timeValuesLimitDateEnd)
    return
        <qc id="qc8">
            <caption>8. Sampling date test</caption>
            <description>
                Tested whether the phenomenonTimeSamplingDate value is from the expected range ({ $dateStart } - { $dateEnd })
            </description>
            <onSuccess>
                <message>OK - data passed the test.</message>
            </onSuccess>
            <onWarning>
                <message>WARNING - some of the reported phenomenonTimeSamplingDate values are outside the expected range. The detected records will not be processed.</message>
            </onWarning>
        </qc>
};

declare function wqldis:_get-observed-value-limits-qc-metadata()
as element(qc)
{
    <qc id="qc9">
        <caption>9. Observed value limits test</caption>
        <description>
            Tested whether the resultObservedValue is within the acceptable value ranges for the respective determinands.
            <br/><br/>
            Values can be confirmed as correct by providing an appropriate flag in the field resultObservationStatus. Please be aware that confirmation won't be accepted if the value defies logic (e.g. negative concentration, pH above 14,...)
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onInfo>
            <message>
                INFO - some of the reported resultObservedValue are outside the value range expected for the respective determinands but have been confirmed as valid in the resultObservationStatus field.
            </message>
        </onInfo>
        <onWarning>
            <message>
                WARNING - some of the reported resultObservedValue are outside the value range expected for the respective determinands.
            </message>
        </onWarning>
        <onError>
            <message>
                ERROR - some of the reported resultObservedValue are outside the value range acceptable for the respective determinands.
            </message>
        </onError>
        <onBlocker>
            <message>
                BLOCKER - some of the reported resultObservedValue are outside the value range acceptable for the respective determinands.
            </message>
        </onBlocker>
    </qc>
};

declare function wqldis:_get-loq-qc-metadata()
as element(qc)
{
    <qc id="qc10">
        <caption>10. LOQ test</caption>
        <description>
            Tested correctness of values in the LOQ fields:
            <ol>
                <li>procedureLOQValue must be reported for hazardous substances and  selected determinands for physico-chemical conditions</li>
                <li>if resultQualityObservedValueBelowLOQ is True (or 1) then resultObservedValue = procedureLOQValue</li>
            </ol>
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onError>
            <message>
                ERROR - some errors have been detected in the LOQ fields.
            </message>
        </onError>
    </qc>
};

declare function wqldis:_get-sample-depth-qc-metadata()
as element(qc)
{
    <qc id="qc11">
        <caption>11. Sample depth test</caption>
        <description>
            Tested the reported parameterSampleDepth value against the maximum sampling depth value reported for the respective monitoring site.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onError>
            <message>
                ERROR - some of the reported parameterSampleDepth values are higher than the maximum sampling depth values reported for the respective monitoring stations.
            </message>
        </onError>
    </qc>
};

declare function wqldis:_run-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $columnExceptions, $dataRows)
    let $colunsToDisplay := ($mandatoryColumns, $model/columns/column[meta:get-column-name(.) = ('resultObservationStatus', 'Remarks')])
    return uimandatory:build-mandatory-column-qc-markup($qc, $colunsToDisplay, $validationResult)
};

declare function wqldis:_run-duplicate-rows-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $validationResult := vldduplicates:validate-duplicate-rows($dataRows, $keyColumns)
    let $columnsToDisplay := ($keyColumns, $model/columns/column[meta:get-column-name(.) = ('resultUom', 'resultObservedValue', 'resultObservationStatus', 'Remarks')])
    return uiduplicates:build-duplicate-rows-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function wqldis:_run-data-types-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $typeExceptions := $qc/typeExceptions
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtypes:validate-data-types($model, $dataRows, $typeExceptions)
    return uitypes:build-data-types-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function wqldis:_run-codelists-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
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

declare function wqldis:_run-monitoring-site-id-format-qc($qc as element(qc), $model as element(model), $envelope as element(envelope), $dataRows as element(dataRow)*)
as element(div)
{
    let $monitoringSiteIdColumn := $model/columns/column[meta:get-column-name(.) = 'monitoringSiteIdentifier']
    let $monitoringSiteIdSchemeColumn := $model/columns/column[meta:get-column-name(.) = 'monitoringSiteIdentifierScheme']
    let $validationResult :=  vldmsiteid:validate-monitoring-site-identifier-format($monitoringSiteIdColumn, $envelope, $dataRows)
    return uimsiteid:build-monitoring-site-id-format-qc-markup($qc, $monitoringSiteIdColumn, $monitoringSiteIdSchemeColumn, $validationResult)
};

declare function wqldis:_run-monitoring-site-id-reference-qc(
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

declare function wqldis:_run-unit-of-measure-qc(
    $qc as element(qc), 
    $model as element(model),
    $vocabularyUom as element(),
    $vocabularyObservedProperty as element(),
    $vocabularyCombinationTableDeterminandUom as element(), 
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnResultUom := $model/columns/column[meta:get-column-name(.) = 'resultUom']
    let $columnObservedPropertyDeterminandCode := $model/columns/column[meta:get-column-name(.) = 'observedPropertyDeterminandCode']
    let $tableName := "http://dd.eionet.europa.eu/vocabulary/datadictionary/ddTables/WISE-SoE_WaterQuality.DisaggregatedData"
    let $columnsToDisplay := (
        meta:get-primary-key-columns($model),
        meta:get-columns-by-names($model,('resultUom', 'resultObservedValue', 'resultObservationStatus', 'Remarks'))
    )
    let $validationResult := vlduom:validate-unit-of-measure($columnResultUom, $columnObservedPropertyDeterminandCode, $tableName, 
            $vocabularyUom, $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $dataRows)
    return uiuom:build-unit-of-measure-qc-markup($qc, $columnResultUom, $columnObservedPropertyDeterminandCode, $tableName, $vocabularyUom, 
                $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $columnsToDisplay, $validationResult)
};

declare function wqldis:_run-sampling-date-qc(
    $qc as element(qc), 
    $model as element(model),
    $dataFlowCycles as element(DataFlows),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnsToDisplay := (meta:get-primary-key-columns($model), meta:get-columns-by-names($model, ('resultUom', 'resultObservedValue', 'resultObservationStatus', 'Remarks')))
    let $validationResult := vldwqldismpsdate:validate-sampling-date($model, $dataFlowCycles, $dataRows)
    return uiwqldismpsdate:build-sampling-date-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function wqldis:_run-observed-value-limits-qc(
    $qc as element(qc), 
    $model as element(model),
    $vocabularyObservedProperty as element(),
    $limitDefinitions as element(WiseSoeQc),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $limitsList := vldwqlvallim:get-limits($limitDefinitions, "WISE-SoE_WaterQuality", "DisaggregatedData")
    let $columnObservedPropertyDeterminandCode := meta:get-column-by-name($model, "observedPropertyDeterminandCode")
    let $columnsToDisplay := (meta:get-primary-key-columns($model), meta:get-columns-by-names($model, ('resultUom', 'resultObservedValue', 'resultObservationStatus', 'Remarks')))
    let $validationResult := vldwqldisobsvallim:validate-observed-value-limits($model, $limitsList, $dataRows)
    return uiwqlvallim:build-value-limits-qc-markup($qc, $columnObservedPropertyDeterminandCode, $limitsList, $vocabularyObservedProperty, $columnsToDisplay, $validationResult)
};

declare function wqldis:_run-loq-qc(
    $qc as element(qc), 
    $model as element(model),
    $vocabularyObservedProperty as element(),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnsToDisplay := (
        meta:get-primary-key-columns($model), 
        meta:get-columns-by-names($model, ("resultUom", "resultObservedValue", "resultQualityObservedValueBelowLOQ", "procedureLOQValue", "resultObservationStatus", "Remarks"))
    )
    let $validationResult := vldwqldisloq:validate-loq($model, $vocabularyObservedProperty, $dataRows)
    return uiutil:build-generic-qc-markup-by-tag-values($qc, "Error", $columnsToDisplay, $validationResult)
};

declare function wqldis:_run-sample-depth-qc(
    $qc as element(qc), 
    $model as element(model),
    $vocabularyMonitoringSites as element(),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $validationResult := vldwqldsmpdpth:validate-sample-depth($model, $vocabularyMonitoringSites, $dataRows)
    let $columnsToDisplay := (
        meta:get-primary-key-columns($model), 
        meta:get-columns-by-names($model, ("resultUom", "resultObservedValue", "parameterSampleDepth")),
        vldwqldsmpdpth:create-max-depth-pseudo-column()
    )
    return uiutil:build-generic-qc-markup-without-checkbox-table($qc, $columnsToDisplay, $validationResult)
};
