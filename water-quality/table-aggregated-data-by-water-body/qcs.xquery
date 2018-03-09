xquery version "1.0" encoding "UTF-8";

module namespace wqlagwb = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedDataByWaterBody';

import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../common/data.xquery";
import module namespace interop = "http://converters.eionet.europa.eu/common/interop" at "../../common/interop.xquery";
import module namespace meta = "http://converters.eionet.europa.eu/common/meta" at "../../common/meta.xquery";
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../common/qclevels.xquery';
import module namespace valconv = "http://converters.eionet.europa.eu/common/valueConversion" at "../../common/value-conversion.xquery";

import module namespace vldmandatory = "http://converters.eionet.europa.eu/common/validators/mandatory" at "../../common/validators/mandatory.xquery";
import module namespace vldduplicates = 'http://converters.eionet.europa.eu/common/validators/duplicates' at "../../common/validators/duplicates.xquery";
import module namespace vldtypes = 'http://converters.eionet.europa.eu/common/validators/types' at "../../common/validators/types.xquery";
import module namespace vldclist = 'http://converters.eionet.europa.eu/common/validators/codelist' at "../../common/validators/codelist.xquery";
import module namespace vldwbodyid = 'http://converters.eionet.europa.eu/wise/common/validators/waterBodyIdentifier' at '../../wise-common/validators/vld-water-body-identifier.xquery';
import module namespace vldwtrbdcat = "http://converters.eionet.europa.eu/wise/common/validators/waterBodyCategory" at '../../wise-common/validators/vld-water-body-category.xquery';
import module namespace vldwqlagwbdet = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedDataByWaterBody/validators/determinand' at './validators/vld-determinand.xquery';
import module namespace vlduom = "http://converters.eionet.europa.eu/wise/common/validators/unitOfMeasure" at '../../wise-common/validators/vld-unit-of-measure.xquery';
import module namespace vldrefyear = 'http://converters.eionet.europa.eu/wise/common/validators/referenceYear' at '../../wise-common/validators/vld-reference-year.xquery';
import module namespace vldsampleperiod = 'http://converters.eionet.europa.eu/wise/common/validators/samplingPeriod'  at '../../wise-common/validators/vld-sampling-period.xquery';
import module namespace vldwqlvallim = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/valueLimits" at "../common/validators/vld-value-limits.xquery";
import module namespace vldwqlagwbrvlim = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedDataByWaterBody/validators/resultValuesLimits' at './validators/vld-result-values-limits.xquery';
import module namespace vldwqlrvmath = 'http://converters.eionet.europa.eu/wise/waterQuality/common/validators/resultValuesMathRules' at '../common/validators/vld-result-values-mathematical.xquery';
import module namespace vldwqlagwbloq = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedDataByWaterBody/validators/loq' at './validators/vld-loq.xquery';
import module namespace vldwqlagwbstclass = "http://converters.eionet.europa.eu/wise/waterQuality/aggregatedDataByWaterBody/validators/siteClass" at './validators/vld-site-class.xquery';
import module namespace vldwqlagwbnss = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedDataByWaterBody/validators/numberOfSitesSum' at './validators/vld-number-of-sites-sum.xquery';

import module namespace html = 'http://converters.eionet.europa.eu/common/ui/html' at "../../common/ui/html-scripts.xquery";
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at "../../common/ui/util.xquery";

import module namespace uimandatory = "http://converters.eionet.europa.eu/common/ui/mandatory" at "../../common/ui/mandatory.xquery";
import module namespace uiduplicates = 'http://converters.eionet.europa.eu/common/ui/duplicates' at "../../common/ui/duplicates.xquery";
import module namespace uitypes = 'http://converters.eionet.europa.eu/common/ui/types' at "../../common/ui/types.xquery";
import module namespace uiclist = 'http://converters.eionet.europa.eu/common/ui/codelist' at "../../common/ui/codelist.xquery";
import module namespace uiwbodyid = 'http://converters.eionet.europa.eu/wise/common/ui/waterBodyIdentifier' at '../../wise-common/ui/ui-water-body-identifier.xquery';
import module namespace uiwtrbdcat = "http://converters.eionet.europa.eu/wise/common/ui/waterBodyCategory" at '../../wise-common/ui/ui-water-body-category.xquery';
import module namespace uiwqlagwbdet = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedDataByWaterBody/ui/determinand' at './ui/ui-determinand.xquery';
import module namespace uiuom = "http://converters.eionet.europa.eu/wise/common/ui/unitOfMeasure" at '../../wise-common/ui/ui-unit-of-measure.xquery';
import module namespace uirefyear = 'http://converters.eionet.europa.eu/wise/common/ui/referenceYear' at '../../wise-common/ui/ui-reference-year.xquery';
import module namespace uisampleperiod = 'http://converters.eionet.europa.eu/wise/common/ui/samplingPeriod'  at '../../wise-common/ui/ui-sampling-period.xquery';
import module namespace uiwqlvallim = "http://converters.eionet.europa.eu/wise/waterQuality/common/ui/valueLimits" at "../common/ui/ui-value-limits.xquery";
import module namespace uiwqlrvmath = 'http://converters.eionet.europa.eu/wise/waterQuality/common/ui/resultValuesMathRules' at '../common/ui/ui-result-values-mathematical.xquery';
import module namespace uiwqlagwbstclass = "http://converters.eionet.europa.eu/wise/waterQuality/aggregatedDataByWaterBody/ui/siteClass" at './ui/ui-site-class.xquery';

declare variable $wqlagwb:TABLE-ID := "9324";

declare function wqlagwb:run-checks($sourceUrl as xs:string)
as element(div)
{
    let $dataDoc := doc($sourceUrl)
    let $model := meta:get-table-metadata($wqlagwb:TABLE-ID)
    let $envelope := interop:get-envelope-metadata($sourceUrl)
    let $vocabularyWaterBodies := doc("../xmlfile/WaterBody.rdf")/*
    let $vocabularyUom := doc("http://dd.eionet.europa.eu/vocabulary/wise/Uom/rdf")/*
    let $vocabularyObservedProperty := doc("http://dd.eionet.europa.eu/vocabulary/wise/ObservedProperty/rdf")/*
    let $vocabularyCombinationTableDeterminandUom := doc("http://dd.eionet.europa.eu/vocabulary/wise/QCCombinationTableDeterminandUom/rdf")/*
    let $dataFlowCycles := doc("http://converters.eionet.europa.eu/xmlfile/dataflow_cycles.xml")/*
    let $limitDefinitions := doc("http://converters.eionet.europa.eu/xmlfile/wise_soe_determinand_value_limits.xml")/*
    return wqlagwb:run-checks($dataDoc, $model, $envelope, $vocabularyWaterBodies, $vocabularyUom, $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $dataFlowCycles, $limitDefinitions)
};

declare function wqlagwb:run-checks(
    $dataDoc as document-node(),
    $model as element(model),
    $envelope as element(envelope),
    $vocabularyWaterBodies as element(),
    $vocabularyUom as element(),
    $vocabularyObservedProperty as element(),
    $vocabularyCombinationTableDeterminandUom as element(),
    $dataFlowCycles as element(DataFlows),
    $limitDefinitions as element(WiseSoeQc)
)
as element(div)
{
    let $qcs := wqlagwb:getQcMetadata($model, $envelope, $vocabularyObservedProperty, $dataFlowCycles)
    let $dataRows := data:get-rows($dataDoc)
    let $qcResultsMarkup := 
        <div>
            { wqlagwb:_run-mandatory-field-qc($qcs/qc[@id="qc1"], $model, $dataRows) }
            { wqlagwb:_run-duplicate-rows-qc($qcs/qc[@id="qc2"], $model, $dataRows) }
            { wqlagwb:_run-data-types-qc($qcs/qc[@id="qc3"], $model, $dataRows) }
            { wqlagwb:_run-codelists-qc($qcs/qc[@id="qc4"], $model, $dataRows) }
            { wqlagwb:_run-water-body-id-format-qc($qcs/qc[@id="qc5"], $model, $envelope, $dataRows) }
            { wqlagwb:_run-water-body-id-reference-qc($qcs/qc[@id="qc6"], $model, $vocabularyWaterBodies, $dataRows) }
            { wqlagwb:_run-water-body-category-qc($qcs/qc[@id="qc7"], $model, $dataRows) }
            { wqlagwb:_run-determinand-qc($qcs/qc[@id="qc8"], $model, $dataRows) }
            { wqlagwb:_run-unit-of-measure-qc($qcs/qc[@id="qc9"], $model, $vocabularyUom, $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $dataRows) }
            { wqlagwb:_run-reference-year-qc($qcs/qc[@id="qc10"], $model, $dataFlowCycles, $dataRows) }
            { wqlagwb:_run-sampling-period-qc($qcs/qc[@id="qc11"], $model, $dataRows) }
            { wqlagwb:_run-result-values-limits-qc($qcs/qc[@id="qc12"], $model, $vocabularyObservedProperty, $limitDefinitions, $dataRows) }
            { wqlagwb:_run-result-values-math-rules-qc($qcs/qc[@id="qc13"], $model, $dataRows) }
            { wqlagwb:_run-loq-qc($qcs/qc[@id="qc14"], $model, $vocabularyObservedProperty, $dataRows) }
            { wqlagwb:_run-site-class-qc($qcs/qc[@id="qc15"], $model, $dataRows) }
            { wqlagwb:_run-number-of-sites-sum-qc($qcs/qc[@id="qc16"], $model, $dataRows) }
        </div>
    return 
        <div class="feedbacktext"> 
            { html:getCss() }
            { html:getJavascript() }
            <div>
                { uiutil:build-header-and-menu-markup("WISE SoE - Water Quality", "Annual statistics data by water body", $qcs, $qcResultsMarkup) }
                { $qcResultsMarkup }
            </div>
        </div>
};

declare function wqlagwb:getQcMetadata(
    $model as element(model), 
    $envelope as element(envelope),
    $vocabularyObservedProperty as element(), 
    $dataFlowCycles as element(DataFlows)
)
as element(qcs)
{
    <qcs>
        { wqlagwb:_get-mandatory-qc-metadata($model) }
        { wqlagwb:_get-duplicate-rows-qc-metadata($model) }
        { wqlagwb:_get-data-types-qc-metadata($model) }
        { wqlagwb:_get-codelists-qc-metadata($model) }
        { wqlagwb:_get-water-body-id-format-qc-metadata($model, $envelope) }
        { wqlagwb:_get-water-body-id-reference-qc-metadata($model) }
        { wqlagwb:_get-water-body-category-qc-metadata($model) }
        { wqlagwb:_get-determinand-qc-metadata($vocabularyObservedProperty) }
        { wqlagwb:_get-unit-of-measure-qc-metadata() }
        { wqlagwb:_get-reference-year-qc-metadata($dataFlowCycles) }
        { wqlagwb:_get-sampling-period-qc-metadata() }
        { wqlagwb:_get-result-values-limits-qc-metadata() }
        { wqlagwb:_get-result-values-math-rules-qc-metadata() }
        { wqlagwb:_get-loq-qc-metadata() }
        { wqlagwb:_get-site-class-qc-metadata() }
        { wqlagwb:_get-number-of-sites-sum-qc-metadata() }
    </qcs>
};

declare function wqlagwb:_get-mandatory-qc-metadata($model as element(model))
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

declare function wqlagwb:_get-duplicate-rows-qc-metadata($model as element(model))
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

declare function wqlagwb:_get-data-types-qc-metadata($model as element(model))
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

declare function wqlagwb:_get-codelists-qc-metadata($model as element(model))
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
                <url columnName="waterBodyIdentifierScheme" value="http://dd.eionet.europa.eu/fixedvalues/elem/75872" />
                <url columnName="parameterWaterBodyCategory" value="http://dd.eionet.europa.eu/vocabulary/wise/WFDWaterBodyCategory" />
                <url columnName="observedPropertyDeterminandCode" value="http://dd.eionet.europa.eu/vocabulary/wise/ObservedProperty" />
                <url columnName="procedureAnalysedFraction" value="http://dd.eionet.europa.eu/fixedvalues/elem/75921" />
                <url columnName="procedureAnalysedMedia" value="http://dd.eionet.europa.eu/fixedvalues/elem/75920" />
                <url columnName="resultUom" value="http://dd.eionet.europa.eu/vocabulary/wise/Uom" />
                <url columnName="resultQualityMinimumBelowLOQ" value="http://dd.eionet.europa.eu/fixedvalues/elem/75897" />
                <url columnName="resultQualityMeanBelowLOQ" value="http://dd.eionet.europa.eu/fixedvalues/elem/75898" />
                <url columnName="resultQualityMaximumBelowLOQ" value="http://dd.eionet.europa.eu/fixedvalues/elem/75900" />
                <url columnName="resultQualityMedianBelowLOQ" value="http://dd.eionet.europa.eu/fixedvalues/elem/75899" />
                <url columnName="resultObservationStatus" value="http://dd.eionet.europa.eu/fixedvalues/elem/77669" />
            </codelistUrls>
        </qc>
};

declare function wqlagwb:_get-water-body-id-format-qc-metadata($model as element(model), $envelope as element(envelope))
as element(qc)
{
    let $countryCode := valconv:convertCountryCode($envelope/countrycode)
    return
        <qc id="qc5">
            <caption>5. Water body identifier format test</caption>
            <description>
                Tested correctness of the waterBodyIdentifier value format:
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
                <message>BLOCKER - some of the waterBodyIdentifier values are either incorrectly formated or identify water bodies that belong to a different country.</message>
            </onBlocker>
        </qc>
};

declare function wqlagwb:_get-water-body-id-reference-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="qc6">
        <caption>6. Water body identifier reference test</caption>
        <description>
            Tested presence of the waterBodyIdentifier, and its respective waterBodyIdentifierScheme, in the <a target="_blank" href="http://dd.eionet.europa.eu/vocabulary/wise/WaterBody/">official reference list</a>. The list has been created from the previously reported data on water bodies.
            <br/><br/>
            Due to the ongoing reporting of WFD data, which includes also update of the water bodies, the detected discrepancies are currently not considered as errors. They will be considered as blocker errors in the future reporting cycles.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onWarning>
            <message>WARNING - some of the waterBodyIdentifier values are missing in the reference list. Please assure that it is not due to an error and that they are reported under WFD, or report them under WISE Spatial data reporting.</message>
        </onWarning>
    </qc>
};

declare function wqlagwb:_get-water-body-category-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="qc7">
        <caption>7. Water body category test</caption>
        <description>
            Tested whether data are reported only from groundwater bodies (parameterWaterBodyCategory is GW)
        </description>
        <validCategories>
            <category value="GW" />
        </validCategories>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onError>
            <message>
                ERROR - inappropriate parameterWaterBodyCategory values have been detected.
            </message>
        </onError>
    </qc>
};

declare function wqlagwb:_get-determinand-qc-metadata($vocabularyObservedProperty as element())
as element(qc)
{
    <qc id="qc8">
        <caption>8. Determinand test</caption>
        <description>
            Tested whether reported determinands are other than 
            { uiwqlagwbdet:compose-determinand-description-markup($vocabularyObservedProperty, "nitrate") }, 
            { uiwqlagwbdet:compose-determinand-description-markup($vocabularyObservedProperty, "nitrite") }, 
            { uiwqlagwbdet:compose-determinand-description-markup($vocabularyObservedProperty, "ammonium") } and 
            { uiwqlagwbdet:compose-determinand-description-markup($vocabularyObservedProperty, "dissolved oxygen") }.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some unexpected observedPropertyDeterminandCode values have been detected. If possible provide disaggregated data instead.
            </message>
        </onBlocker>
    </qc>
};

declare function wqlagwb:_get-unit-of-measure-qc-metadata()
as element(qc)
{
    <qc id="qc9">
        <caption>9. Unit of measure test</caption>
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

declare function wqlagwb:_get-reference-year-qc-metadata($dataFlowCycles as element(DataFlows))
as element(qc)
{
    let $dataFlowCycle := vldrefyear:get-data-flow-cycle($dataFlowCycles)
    let $yearStart := vldrefyear:get-start-year($dataFlowCycle)
    let $yearEnd := vldrefyear:get-end-year($dataFlowCycle)
    return
        <qc id="qc10">
            <caption>10. Reference year test</caption>
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

declare function wqlagwb:_get-sampling-period-qc-metadata()
as element(qc)
{
    <qc id="qc11">
        <caption>11. Sampling period test</caption>
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

declare function wqlagwb:_get-result-values-limits-qc-metadata()
as element(qc)
{
    <qc id="qc12">
        <caption>12. Result values - limits test</caption>
        <description>
            Tested whether the resultMinimumValue, resultMeanValue, resultMaximumValue and resultMedianValue are within the acceptable value ranges for the respective determinands.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
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

declare function wqlagwb:_get-result-values-math-rules-qc-metadata()
as element(qc)
{
    <qc id="qc13">
        <caption>13. Result values - mathematical relation rules test</caption>
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

declare function wqlagwb:_get-loq-qc-metadata()
as element(qc)
{
    <qc id="qc14">
        <caption>14. LOQ test</caption>
        <description>
            Tested correctness of values in the LOQ fields:
            <ol>
                <li>procedureLOQValue must be reported for Nitrate (CAS_14797-55-8) and Ammonium (CAS_14798-03-9)</li>
                <li>If resultQualityMeanValueBelowLOQ is True (or 1) and procedureLOQValue is provided then resultMeanValue = procedureLOQValue</li>
                <li>If resultQualityMinimumBelowLOQ is True (or 1) and procedureLOQValue is provided then resultMinimumValue = procedureLOQValue</li>
                <li>If resultQualityMaximumBelowLOQ is True (or 1) and procedureLOQValue is provided then resultMaximumValue = procedureLOQValue</li>
                <li>If resultQualityMedianBelowLOQ is True (or 1) and procedureLOQValue is provided then resultMedianValue = procedureLOQValue</li>
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

declare function wqlagwb:_get-site-class-qc-metadata()
as element(qc)
{
    <qc id="qc15">
        <caption>15. Sites class tests</caption>
        <description>
            Tested Class values in relation to their eligibility for the individual determinands.
            <ol>
                <li>Class 4 is not eligible for Dissolved oxygen (EEA_3132-01-2)</li>
                <li>Class 5 is not eligible for Dissolved oxygen (EEA_3132-01-2), Ammonium (CAS_14798-03-9) and Nitrate (CAS_14797-55-8)</li>
            </ol>
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the Class values have been reported for incorrect determinands.
            </message>
        </onBlocker>
    </qc>
};

declare function wqlagwb:_get-number-of-sites-sum-qc-metadata()
as element(qc)
{
    <qc id="qc16">
        <caption>16. Number of sites sum test</caption>
        <description>
            Tests whether the sum of the numbers of sites reported in all classes doesn't exceed the resultNumberOfSamples value.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - in some of the records the sum of number of sites reported in all classess exceeds the resultNumberOfSamples value.
            </message>
        </onBlocker>
    </qc>
};

declare function wqlagwb:_run-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $columnExceptions, $dataRows)
    let $colunsToDisplay := ($mandatoryColumns, meta:get-columns-by-names($model, ('parameterSamplingPeriod', 'resultObservationStatus', 'Remarks')))
    return uimandatory:build-mandatory-column-qc-markup($qc, $colunsToDisplay, $validationResult)
};

declare function wqlagwb:_run-duplicate-rows-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $validationResult := vldduplicates:validate-duplicate-rows($dataRows, $keyColumns)
    let $columnsToDisplay := ($keyColumns, meta:get-columns-by-names($model, ("resultUom", "parameterSamplingPeriod", "resultMeanValue", "resultObservationStatus", "Remarks")))
    return uiduplicates:build-duplicate-rows-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function wqlagwb:_run-data-types-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $typeExceptions := $qc/typeExceptions
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtypes:validate-data-types($model, $dataRows, $typeExceptions)
    return uitypes:build-data-types-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function wqlagwb:_run-codelists-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $additionalColumnNames := ("parameterSamplingPeriod", "resultMeanValue", "Remarks")
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

declare function wqlagwb:_run-water-body-id-format-qc($qc as element(qc), $model as element(model), $envelope as element(envelope), $dataRows as element(dataRow)*)
as element(div)
{
    let $columnWaterBodyId := $model/columns/column[meta:get-column-name(.) = 'waterBodyIdentifier']
    let $columnWaterBodyIdScheme := $model/columns/column[meta:get-column-name(.) = 'waterBodyIdentifierScheme']
    let $validationResult :=  vldwbodyid:validate-water-body-identifier-format($columnWaterBodyId, $envelope, $dataRows)
    return uiwbodyid:build-water-body-id-format-qc-markup($qc, $columnWaterBodyId, $columnWaterBodyIdScheme, $validationResult)
};

declare function wqlagwb:_run-water-body-id-reference-qc(
    $qc as element(qc), 
    $model as element(model), 
    $vocabularyWaterBodies as element(), 
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnWaterBodyId := $model/columns/column[meta:get-column-name(.) = 'waterBodyIdentifier']
    let $columnWaterBodyIdScheme := $model/columns/column[meta:get-column-name(.) = 'waterBodyIdentifierScheme']
    let $validationResult :=  vldwbodyid:validate-water-body-identifier-reference($columnWaterBodyId, $columnWaterBodyIdScheme, $vocabularyWaterBodies, $dataRows)
    return uiwbodyid:build-water-body-id-reference-qc-markup($qc, $columnWaterBodyId, $columnWaterBodyIdScheme, $validationResult)
};

declare function wqlagwb:_run-water-body-category-qc(
    $qc as element(qc), 
    $model as element(model), 
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnWaterBodyCategory := meta:get-column-by-name($model, 'parameterWaterBodyCategory')
    let $validCategories := data($qc/validCategories/category/@value)
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldwtrbdcat:validate-water-body-category($columnWaterBodyCategory, $validCategories, $dataRows)
    return uiwtrbdcat:build-water-body-category-qc-markup($qc, $columnWaterBodyCategory, $columnsToDisplay, $validationResult)
};

declare function wqlagwb:_run-determinand-qc(
    $qc as element(qc), 
    $model as element(model), 
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnsToDisplay := (
        meta:get-primary-key-columns($model), 
        meta:get-columns-by-names($model, ("resultUom", "parameterSamplingPeriod", "resultMeanValue", "resultObservationStatus", "Remarks"))
    )
    let $validationResult := vldwqlagwbdet:validate-determinand($model, $dataRows)
    return uiwqlagwbdet:build-determinand-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function wqlagwb:_run-unit-of-measure-qc(
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
    let $tableName := "http://dd.eionet.europa.eu/vocabulary/datadictionary/ddTables/WISE-SoE_WaterQuality.AggregatedDataByWaterBody"
    let $columnsToDisplay := (
        meta:get-primary-key-columns($model),
        meta:get-columns-by-names($model,("resultUom", "parameterSamplingPeriod", "resultMeanValue", "resultObservationStatus", "Remarks"))
    )
    let $validationResult := vlduom:validate-unit-of-measure($columnResultUom, $columnObservedPropertyDeterminandCode, $tableName, 
            $vocabularyUom, $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $dataRows)
    return uiuom:build-unit-of-measure-qc-markup($qc, $columnResultUom, $columnObservedPropertyDeterminandCode, $tableName, $vocabularyUom, 
                $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $columnsToDisplay, $validationResult)
};

declare function wqlagwb:_run-reference-year-qc(
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

declare function wqlagwb:_run-sampling-period-qc(
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

declare function wqlagwb:_run-result-values-limits-qc(
    $qc as element(qc), 
    $model as element(model),
    $vocabularyObservedProperty as element(),
    $limitDefinitions as element(WiseSoeQc),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $limitsList := vldwqlvallim:get-limits($limitDefinitions, "WISE-SoE_WaterQuality", "AggregatedDataByWaterBody")
    let $columnObservedPropertyDeterminandCode := meta:get-column-by-name($model, "observedPropertyDeterminandCode")
    let $columnsToDisplay := (
        meta:get-primary-key-columns($model),
        meta:get-columns-by-names($model, ("resultUom", "parameterSamplingPeriod", "resultMinimumValue", "resultMeanValue", "resultMaximumValue", "resultMedianValue",  "resultObservationStatus", "Remarks"))
    )
    let $validationResult := vldwqlagwbrvlim:validate-result-values-limits($model, $limitsList, $dataRows)
    return uiwqlvallim:build-value-limits-qc-markup($qc, $columnObservedPropertyDeterminandCode, $limitsList, $vocabularyObservedProperty, $columnsToDisplay, $validationResult)
};

declare function wqlagwb:_run-result-values-math-rules-qc(
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

declare function wqlagwb:_run-loq-qc(
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
    let $validationResult := vldwqlagwbloq:validate-loq($model, $vocabularyObservedProperty, $dataRows)
    return uiutil:build-generic-qc-markup-by-tag-values($qc, "Error type", $columnsToDisplay, $validationResult)
};

declare function wqlagwb:_run-site-class-qc(
    $qc as element(qc), 
    $model as element(model),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnsToDisplay := (
        meta:get-primary-key-columns($model),
        meta:get-columns-by-names($model, (
            "resultUom", "resultObservedValue", "resultNumberOfSitesClass1", "resultNumberOfSitesClass2", 
            "resultNumberOfSitesClass3", "resultNumberOfSitesClass4", "resultNumberOfSitesClass5", 
            "resultObservationStatus", "Remarks"
        ))
    )
    let $validationResult := vldwqlagwbstclass:validate-site-class($model, $dataRows)
    return uiwqlagwbstclass:build-site-class-qc-markup($qc, $columnsToDisplay, $validationResult) 
};

declare function wqlagwb:_run-number-of-sites-sum-qc(
    $qc as element(qc), 
    $model as element(model),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnsToDisplay := (
        meta:get-primary-key-columns($model),
        meta:get-columns-by-names($model, (
            "resultUom", "parameterSamplingPeriod", "resultMeanValue", 
            "resultNumberOfSitesClass1", "resultNumberOfSitesClass2", "resultNumberOfSitesClass3", 
            "resultNumberOfSitesClass4", "resultNumberOfSitesClass5",
            "resultObservationStatus", "Remarks"
        ))
    )
    let $validationResult := vldwqlagwbnss:validate-number-of-sites-sum($model, $dataRows)
    return uiutil:build-generic-qc-markup-without-checkbox-table($qc, $columnsToDisplay, $validationResult)
};
