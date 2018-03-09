xquery version "1.0" encoding "UTF-8";

module namespace wqlagg = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedData';

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
import module namespace vldrefyear = 'http://converters.eionet.europa.eu/wise/common/validators/referenceYear' at '../../wise-common/validators/vld-reference-year.xquery';
import module namespace vldsampleperiod = 'http://converters.eionet.europa.eu/wise/common/validators/samplingPeriod'  at '../../wise-common/validators/vld-sampling-period.xquery';
import module namespace vldwqlvallim = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/valueLimits" at "../common/validators/vld-value-limits.xquery";
import module namespace vldwqlaggrvlim = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedData/validators/resultValuesLimits' at './validators/vld-result-values-limits.xquery'; 
import module namespace vldwqlrvmath = 'http://converters.eionet.europa.eu/wise/waterQuality/common/validators/resultValuesMathRules' at '../common/validators/vld-result-values-mathematical.xquery';
import module namespace vldwqlaggloq = "http://converters.eionet.europa.eu/wise/waterQuality/aggregatedData/validators/loq" at './validators/vld-loq.xquery';
import module namespace vldwqldsmpdpth = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/sampleDepth" at "../common/validators/vld-sample-depth.xquery";

import module namespace html = 'http://converters.eionet.europa.eu/common/ui/html' at "../../common/ui/html-scripts.xquery";
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at "../../common/ui/util.xquery";
import module namespace uimandatory = "http://converters.eionet.europa.eu/common/ui/mandatory" at "../../common/ui/mandatory.xquery";
import module namespace uiduplicates = 'http://converters.eionet.europa.eu/common/ui/duplicates' at "../../common/ui/duplicates.xquery";
import module namespace uitypes = 'http://converters.eionet.europa.eu/common/ui/types' at "../../common/ui/types.xquery";
import module namespace uiclist = 'http://converters.eionet.europa.eu/common/ui/codelist' at "../../common/ui/codelist.xquery";
import module namespace uimsiteid = 'http://converters.eionet.europa.eu/wise/common/ui/monitoringSiteIdentifier' at '../../wise-common/ui/ui-monitoring-site-identifier.xquery';
import module namespace uiuom = "http://converters.eionet.europa.eu/wise/common/ui/unitOfMeasure" at '../../wise-common/ui/ui-unit-of-measure.xquery';
import module namespace uirefyear = 'http://converters.eionet.europa.eu/wise/common/ui/referenceYear' at '../../wise-common/ui/ui-reference-year.xquery';
import module namespace uiwqlvallim = "http://converters.eionet.europa.eu/wise/waterQuality/common/ui/valueLimits" at "../common/ui/ui-value-limits.xquery";
import module namespace uiwqlrvmath = 'http://converters.eionet.europa.eu/wise/waterQuality/common/ui/resultValuesMathRules' at '../common/ui/ui-result-values-mathematical.xquery';

import module namespace uisampleperiod = 'http://converters.eionet.europa.eu/wise/common/ui/samplingPeriod'  at '../../wise-common/ui/ui-sampling-period.xquery';

declare variable $wqlagg:TABLE-ID := "9323";

declare function wqlagg:run-checks($sourceUrl as xs:string)
as element(div)
{
    let $dataDoc := doc($sourceUrl)
    let $model := meta:get-table-metadata($wqlagg:TABLE-ID)
    let $envelope := interop:get-envelope-metadata($sourceUrl)
    let $vocabularyMonitoringSites := doc("../xmlfile/MonitoringSite.rdf")/*
    let $vocabularyUom := doc("http://dd.eionet.europa.eu/vocabulary/wise/Uom/rdf")/*
    let $vocabularyObservedProperty := doc("http://dd.eionet.europa.eu/vocabulary/wise/ObservedProperty/rdf")/*
    let $vocabularyCombinationTableDeterminandUom := doc("http://dd.eionet.europa.eu/vocabulary/wise/QCCombinationTableDeterminandUom/rdf")/*
    let $dataFlowCycles := doc("http://converters.eionet.europa.eu/xmlfile/dataflow_cycles.xml")/*
    let $limitDefinitions := doc("http://converters.eionet.europa.eu/xmlfile/wise_soe_determinand_value_limits.xml")/*
    return wqlagg:run-checks($dataDoc, $model, $envelope, $vocabularyMonitoringSites, $vocabularyUom, $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $dataFlowCycles, $limitDefinitions)
};

declare function wqlagg:run-checks(
    $dataDoc as document-node(),
    $model as element(model), 
    $envelope as element(envelope),
    $vocabularyMonitoringSites as element(),
    $vocabularyUom as element(),
    $vocabularyObservedProperty as element(),
    $vocabularyCombinationTableDeterminandUom as element(),
    $dataFlowCycles as element(DataFlows),
    $limitDefinitions as element(WiseSoeQc)
)
as element(div)
{
    let $qcs := wqlagg:getQcMetadata($model, $envelope, $dataFlowCycles)
    let $dataRows := data:get-rows($dataDoc)
    let $qcResultsMarkup := 
        <div>
            { wqlagg:_run-mandatory-field-qc($qcs/qc[@id="qc1"], $model, $dataRows) }
            { wqlagg:_run-duplicate-rows-qc($qcs/qc[@id="qc2"], $model, $dataRows) }
            { wqlagg:_run-data-types-qc($qcs/qc[@id="qc3"], $model, $dataRows) }
            { wqlagg:_run-codelists-qc($qcs/qc[@id="qc4"], $model, $dataRows) }
            { wqlagg:_run-monitoring-site-id-format-qc($qcs/qc[@id="qc5"], $model, $envelope, $dataRows) }
            { wqlagg:_run-monitoring-site-id-reference-qc($qcs/qc[@id="qc6"], $model, $vocabularyMonitoringSites, $dataRows) }
            { wqlagg:_run-unit-of-measure-qc($qcs/qc[@id="qc7"], $model, $vocabularyUom, $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $dataRows) }
            { wqlagg:_run-reference-year-qc($qcs/qc[@id="qc8"], $model, $dataFlowCycles, $dataRows) }
            { wqlagg:_run-sampling-period-qc($qcs/qc[@id="qc9"], $model, $dataRows) }
            { wqlagg:_run-result-values-limits-qc($qcs/qc[@id="qc10"], $model, $vocabularyObservedProperty, $limitDefinitions, $dataRows) }
            { wqlagg:_run-result-values-math-rules-qc($qcs/qc[@id="qc11"], $model, $dataRows) }
            { wqlagg:_run-loq-qc($qcs/qc[@id="qc12"], $model, $vocabularyObservedProperty, $dataRows) }
            { wqlagg:_run-sample-depth-qc($qcs/qc[@id="qc13"], $model, $vocabularyMonitoringSites, $dataRows) }
        </div>
    return 
        <div class="feedbacktext"> 
            { html:getCss() }
            { html:getJavascript() }
            <div>
                { uiutil:build-header-and-menu-markup("WISE SoE - Water Quality", "Annual statistics data by monitoring site", $qcs, $qcResultsMarkup) }
                { $qcResultsMarkup }
            </div>
        </div>
};

declare function wqlagg:getQcMetadata(
    $model as element(model),
    $envelope as element(envelope),
    $dataFlowCycles as element(DataFlows)
)
as element(qcs)
{
    <qcs>
        { wqlagg:_get-mandatory-qc-metadata($model) }
        { wqlagg:_get-duplicate-rows-qc-metadata($model) }
        { wqlagg:_get-data-types-qc-metadata($model) }
        { wqlagg:_get-codelists-qc-metadata($model) }
        { wqlagg:_get-monitoring-site-id-format-qc-metadata($model, $envelope) }
        { wqlagg:_get-monitoring-site-id-reference-qc-metadata($model) }
        { wqlagg:_get-unit-of-measure-qc-metadata() }
        { wqlagg:_get-reference-year-qc-metadata($dataFlowCycles) }
        { wqlagg:_get-sampling-period-qc-metadata() }
        { wqlagg:_get-result-values-limits-qc-metadata() }
        { wqlagg:_get-result-values-math-rules-qc-metadata() }
        { wqlagg:_get-loq-qc-metadata() }
        { wqlagg:_get-sample-depth-qc-metadata() }
    </qcs>
};

declare function wqlagg:_get-mandatory-qc-metadata($model as element(model))
as element(qc)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    let $mandatoryColumnString := string-join($mandatoryColumns/meta:get-column-name(.), ", ")
    let $exceptionColumnNames := ("resultMinimumValue", "resultMeanValue", "resultMaximumValue", "resultMedianValue")
    let $dependencyColumnName := "resultObservationStatus"
    return
        <qc id="qc1">
            <caption>1. Mandatory values test</caption>
            <description>
                Tested the presence of mandatory values - { $mandatoryColumnString }.
                <br/><br/>
                Missing resultMinimumValue, resultMeanValue, resultMaximumValue and resultMedianValue can be clarified by using an appropriate flag in the resultObservationStatus field.
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

declare function wqlagg:_get-duplicate-rows-qc-metadata($model as element(model))
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

declare function wqlagg:_get-data-types-qc-metadata($model as element(model))
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

declare function wqlagg:_get-codelists-qc-metadata($model as element(model))
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
                <url columnName="resultQualityMinimumBelowLOQ" value="http://dd.eionet.europa.eu/fixedvalues/elem/75897" />
                <url columnName="resultQualityMeanBelowLOQ" value="http://dd.eionet.europa.eu/fixedvalues/elem/75898" />
                <url columnName="resultQualityMaximumBelowLOQ" value="http://dd.eionet.europa.eu/fixedvalues/elem/75900" />
                <url columnName="resultQualityMedianBelowLOQ" value="http://dd.eionet.europa.eu/fixedvalues/elem/75899" />
                <url columnName="procedureAnalyticalMethod" value="http://dd.eionet.europa.eu/fixedvalues/elem/75922" />
                <url columnName="resultObservationStatus" value="http://dd.eionet.europa.eu/fixedvalues/elem/77669" />
            </codelistUrls>
        </qc>
};

declare function wqlagg:_get-monitoring-site-id-format-qc-metadata($model as element(model), $envelope as element(envelope))
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

declare function wqlagg:_get-monitoring-site-id-reference-qc-metadata($model as element(model))
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

declare function wqlagg:_get-unit-of-measure-qc-metadata()
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

declare function wqlagg:_get-reference-year-qc-metadata($dataFlowCycles as element(DataFlows))
as element(qc)
{
    let $dataFlowCycle := vldrefyear:get-data-flow-cycle($dataFlowCycles)
    let $yearStart := vldrefyear:get-start-year($dataFlowCycle)
    let $yearEnd := vldrefyear:get-end-year($dataFlowCycle)
    return
        <qc id="qc8">
            <caption>8. Reference year test</caption>
            <description>
                Tested whether the phenomenonTimeReferenceYear value is from the expected range ({ $yearStart } - { $yearEnd })
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

declare function wqlagg:_get-sampling-period-qc-metadata()
as element(qc)
{
    <qc id="qc9">
        <caption>9. Sampling period test</caption>
        <description>
            Tested whether the parameterSamplingPeriod value
            <ol>
                <li>is provided in the requested format (YYYY-MM-DD--YYYY-MM-DD or YYYY-MM--YYYY-MM)</li>
                <li>starting date is not higher than ending date.</li>
                <li>represents a period of maximum one year.</li>
                <li>matches with the value provided in the phenomenonTimeReferenceYear field.</li>
            </ol>
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported parameterSamplingPeriod values do not follow some of the constraints.
            </message>
        </onBlocker>
    </qc>
};

declare function wqlagg:_get-result-values-limits-qc-metadata()
as element(qc)
{
    <qc id="qc10">
        <caption>10. Result values - limits test</caption>
        <description>
            Tested whether the resultMinimumValue, resultMeanValue, resultMaximumValue and resultMedianValue are within the acceptable value ranges for the respective determinands.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onInfo>
            <message>
                INFO - some of the reported result values are outside the value range expected for the respective determinands but have been confirmed as valid in the resultObservationStatus field.
            </message>
        </onInfo>
        <onWarning>
            <message>
                WARNING - some of the reported result values are outside the value range expected for the respective determinands.
            </message>
        </onWarning>
        <onError>
            <message>
                ERROR - some of the reported result values are outside the value range acceptable for the respective determinands.
            </message>
        </onError>
        <onBlocker>
            <message>
                BLOCKER - some of the reported result values are outside the value range acceptable for the respective determinands.
            </message>
        </onBlocker>
    </qc>
};

declare function wqlagg:_get-result-values-math-rules-qc-metadata()
as element(qc)
{
    <qc id="qc11">
        <caption>11. Result values - mathematical relation rules test</caption>
        <description>
            Tested mathematical relation rules between the result values:
            <ol>
                <li><![CDATA[resultMeanValue >= resultMinimumValue]]></li>
                <li><![CDATA[resultMaximumValue >= resultMeanValue]]></li>
                <li><![CDATA[resultMedianValue >= resultMinimumValue]]></li>
                <li><![CDATA[resultMaximumValue >= resultMedianValue]]></li>
                <li><![CDATA[resultMaximumValue >= resultMinimumValue]]></li>
                <li><![CDATA[resultStandardDeviationValue <= (resultMaximumValue - resultMinimumValue)]]></li>
                <li><![CDATA[If resultMinimumValue < resultMaximumValue Then resultStandardDeviationValue > 0]]></li>
                <li><![CDATA[If resultNumberOfSamples = 1, then resultMinimumValue = resultMeanValue = resultMaximumValue = resultMedianValue]]></li>
                <li><![CDATA[If resultNumberOfSamples = 1, then resultStandardDeviationValue = 0]]></li>
                <li><![CDATA[resultQualityNumberOfSamplesBelowLOQ <= resultNumberOfSamples]]></li>
                <li><![CDATA[If resultQualityNumberOfSamplesBelowLOQ = 0, then resultQualityMinimumBelowLOQ, resultQualityMeanBelowLOQ, resultQualityMaximumBelowLOQ and  resultQualityMedianBelowLOQ = False]]></li>
                <li><![CDATA[If resultNumberOfSamples = 1, then resultQualityMinimumBelowLOQ = resultQualityMeanBelowLOQ = resultQualityMaximumBelowLOQ = resultQualityMedianBelowLOQ]]></li>
                <li><![CDATA[If resultQualityNumberOfSamplesBelowLOQ = resultNumberOfSamples, then resultQualityMinimumBelowLOQ, resultQualityMeanBelowLOQ, resultQualityMaximumBelowLOQ and resultQualityMedianBelowLOQ = True (or 1)]]></li>
            </ol>
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the mathematical relation rules are broken by the reported result values.
            </message>
        </onBlocker>
    </qc>
};

declare function wqlagg:_get-loq-qc-metadata()
as element(qc)
{
    <qc id="qc12">
        <caption>12. LOQ test</caption>
        <description>
            Tested correctness of values in the LOQ fields:
            <ol>
                <li>procedureLOQValue must be reported for hazardous substances and  selected determinands for physico-chemical conditions</li>
                <li>If resultQualityMeanValueBelowLOQ is True (or 1) then resultMeanValue = procedureLOQValue</li>
                <li>If resultQualityMinimumBelowLOQ is True (or 1) then resultMinimumValue = procedureLOQValue</li>
                <li>If resultQualityMaximumBelowLOQ is True (or 1) then resultMaximumValue = procedureLOQValue</li>
                <li>If resultQualityMedianBelowLOQ is True (or 1) then resultMedianValue = procedureLOQValue</li>
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

declare function wqlagg:_get-sample-depth-qc-metadata()
as element(qc)
{
    <qc id="qc13">
        <caption>13. Sample depth test</caption>
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

declare function wqlagg:_run-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $columnExceptions, $dataRows)
    let $colunsToDisplay := ($mandatoryColumns, meta:get-columns-by-names($model, ('parameterSamplingPeriod', 'resultObservationStatus', 'Remarks')))
    return uimandatory:build-mandatory-column-qc-markup($qc, $colunsToDisplay, $validationResult)
};

declare function wqlagg:_run-duplicate-rows-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $validationResult := vldduplicates:validate-duplicate-rows($dataRows, $keyColumns)
    let $columnsToDisplay := ($keyColumns, meta:get-columns-by-names($model, ("resultUom", "parameterSamplingPeriod", "resultMeanValue", "resultObservationStatus", "Remarks")))
    return uiduplicates:build-duplicate-rows-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function wqlagg:_run-data-types-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $typeExceptions := $qc/typeExceptions
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtypes:validate-data-types($model, $dataRows, $typeExceptions)
    return uitypes:build-data-types-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function wqlagg:_run-codelists-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $additionalColumnNames := ('parameterSamplingPeriod', 'resultMeanValue', 'Remarks')
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

declare function wqlagg:_run-monitoring-site-id-format-qc($qc as element(qc), $model as element(model), $envelope as element(envelope), $dataRows as element(dataRow)*)
as element(div)
{
    let $monitoringSiteIdColumn := meta:get-column-by-name($model, 'monitoringSiteIdentifier')
    let $monitoringSiteIdSchemeColumn := meta:get-column-by-name($model, 'monitoringSiteIdentifierScheme')
    let $validationResult :=  vldmsiteid:validate-monitoring-site-identifier-format($monitoringSiteIdColumn, $envelope, $dataRows)
    return uimsiteid:build-monitoring-site-id-format-qc-markup($qc, $monitoringSiteIdColumn, $monitoringSiteIdSchemeColumn, $validationResult)
};

declare function wqlagg:_run-monitoring-site-id-reference-qc(
    $qc as element(qc), 
    $model as element(model), 
    $vocabularyMonitoringSites as element(), 
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $monitoringSiteIdColumn := meta:get-column-by-name($model, 'monitoringSiteIdentifier')
    let $monitoringSiteIdSchemeColumn := meta:get-column-by-name($model, 'monitoringSiteIdentifierScheme')
    let $validationResult :=  vldmsiteid:validate-monitoring-site-identifier-reference($monitoringSiteIdColumn, $monitoringSiteIdSchemeColumn, $vocabularyMonitoringSites, $dataRows)
    return uimsiteid:build-monitoring-site-id-reference-qc-markup($qc, $monitoringSiteIdColumn, $monitoringSiteIdSchemeColumn, $validationResult)
};

declare function wqlagg:_run-unit-of-measure-qc(
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
    let $tableName := "http://dd.eionet.europa.eu/vocabulary/datadictionary/ddTables/WISE-SoE_WaterQuality.AggregatedData"
    let $columnsToDisplay := (
        meta:get-primary-key-columns($model),
        meta:get-columns-by-names($model,('resultUom', 'parameterSamplingPeriod', 'resultMeanValue', 'resultObservationStatus', 'Remarks'))
    )
    let $validationResult := vlduom:validate-unit-of-measure($columnResultUom, $columnObservedPropertyDeterminandCode, $tableName, 
            $vocabularyUom, $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $dataRows)
    return uiuom:build-unit-of-measure-qc-markup($qc, $columnResultUom, $columnObservedPropertyDeterminandCode, $tableName, $vocabularyUom, 
                $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $columnsToDisplay, $validationResult)
};

declare function wqlagg:_run-reference-year-qc(
    $qc as element(qc), 
    $model as element(model),
    $dataFlowCycles as element(DataFlows),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnReferenceYear := meta:get-column-by-name($model, "phenomenonTimeReferenceYear")
    let $columnsToDisplay := (
        meta:get-primary-key-columns($model),
        meta:get-columns-by-names($model, ("resultUom", "parameterSamplingPeriod", "resultMeanValue", "resultObservationStatus", "Remarks"))
    )
    let $validationResult := vldrefyear:validate-reference-year($columnReferenceYear, $dataFlowCycles, $dataRows)
    return uirefyear:build-reference-year-qc-markup($qc, $columnReferenceYear, $columnsToDisplay, $validationResult)
};

declare function wqlagg:_run-sampling-period-qc(
    $qc as element(qc), 
    $model as element(model),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnSamplingPeriod := meta:get-column-by-name($model, "parameterSamplingPeriod")
    let $columnReferenceYear := meta:get-column-by-name($model, "phenomenonTimeReferenceYear")
    let $columnsToDisplay := (
        meta:get-primary-key-columns($model),
        meta:get-columns-by-names($model, ("resultUom", "parameterSamplingPeriod", "resultMeanValue", "resultObservationStatus", "Remarks"))
    )
    let $validationResult := vldsampleperiod:validate-sampling-period($columnSamplingPeriod, $columnReferenceYear, $dataRows)
    return uisampleperiod:build-sampling-period-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function wqlagg:_run-result-values-limits-qc(
    $qc as element(qc), 
    $model as element(model),
    $vocabularyObservedProperty as element(),
    $limitDefinitions as element(WiseSoeQc),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $limitsList := vldwqlvallim:get-limits($limitDefinitions, "WISE-SoE_WaterQuality", "AggregatedData")
    let $columnObservedPropertyDeterminandCode := meta:get-column-by-name($model, "observedPropertyDeterminandCode")
    let $columnsToDisplay := (
        meta:get-primary-key-columns($model),
        meta:get-columns-by-names($model, ("resultUom", "parameterSamplingPeriod", "resultMinimumValue", "resultMeanValue", "resultMaximumValue", "resultMedianValue",  "resultObservationStatus", "Remarks"))
    )
    let $validationResult := vldwqlaggrvlim:validate-result-values-limits($model, $limitsList, $dataRows)
    return uiwqlvallim:build-value-limits-qc-markup($qc, $columnObservedPropertyDeterminandCode, $limitsList, $vocabularyObservedProperty, $columnsToDisplay, $validationResult)
};

declare function wqlagg:_run-result-values-math-rules-qc(
    $qc as element(qc), 
    $model as element(model),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnsToDisplay := (
        meta:get-primary-key-columns($model),
        meta:get-columns-by-names($model, (
            "resultUom", "parameterSamplingPeriod", "resultNumberOfSamples", 
            "resultQualityNumberOfSamplesBelowLOQ", "resultQualityMinimumBelowLOQ", 
            "resultMinimumValue", "resultQualityMeanBelowLOQ", "resultMeanValue", 
            "resultQualityMaximumBelowLOQ", "resultMaximumValue", "resultQualityMedianBelowLOQ", 
            "resultMedianValue", "resultStandardDeviationValue", 
            "resultObservationStatus", "Remarks"
        ))
    )
    let $validationResult := vldwqlrvmath:validate-result-values-math-rules($model, $dataRows)
    return uiwqlrvmath:build-result-values-math-rules-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function wqlagg:_run-loq-qc(
    $qc as element(qc), 
    $model as element(model),
    $vocabularyObservedProperty as element(),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnsToDisplay := (
        meta:get-primary-key-columns($model),
        meta:get-columns-by-names($model, (
            "resultUom", "procedureLOQValue", 
            "resultQualityMinimumBelowLOQ", "resultMinimumValue", "resultQualityMeanBelowLOQ", "resultMeanValue", 
            "resultQualityMaximumBelowLOQ", "resultMaximumValue", "resultQualityMedianBelowLOQ", "resultMedianValue", 
            "resultObservationStatus", "Remarks"
        ))
    )
    let $validationResult := vldwqlaggloq:validate-loq($model, $vocabularyObservedProperty, $dataRows)
    return uiutil:build-generic-qc-markup-by-tag-values($qc, "Error type", $columnsToDisplay, $validationResult)
};

declare function wqlagg:_run-sample-depth-qc(
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
