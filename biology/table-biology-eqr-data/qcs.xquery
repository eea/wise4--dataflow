xquery version "1.0" encoding "UTF-8";

module namespace biobioeqrd = 'http://converters.eionet.europa.eu/wise/biology/biobiologyEqrData';

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
import module namespace vldwtrbdcat = "http://converters.eionet.europa.eu/wise/common/validators/waterBodyCategory" at '../../wise-common/validators/vld-water-body-category.xquery';
import module namespace vldrefyear = 'http://converters.eionet.europa.eu/wise/common/validators/referenceYear' at '../../wise-common/validators/vld-reference-year.xquery';
import module namespace vldsampleperiod = 'http://converters.eionet.europa.eu/wise/common/validators/samplingPeriod'  at '../../wise-common/validators/vld-sampling-period.xquery';
import module namespace vldwqlbioeqrdres = 'http://converters.eionet.europa.eu/wise/biology/biologyEqrData/validators/resultValueLimits' at '../common/validators/vld-result-value-limits.xquery';
import module namespace vldwqldetwbcat = "http://converters.eionet.europa.eu/wise/biology/common/validators/determinandsAndWaterBodyCategory" at "../common/validators/vld-determinands-water-body-category.xquery";

import module namespace html = 'http://converters.eionet.europa.eu/common/ui/html' at "../../common/ui/html-scripts.xquery";
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at "../../common/ui/util.xquery";
import module namespace uimandatory = "http://converters.eionet.europa.eu/common/ui/mandatory" at "../../common/ui/mandatory.xquery";
import module namespace uiduplicates = 'http://converters.eionet.europa.eu/common/ui/duplicates' at "../../common/ui/duplicates.xquery";
import module namespace uitypes = 'http://converters.eionet.europa.eu/common/ui/types' at "../../common/ui/types.xquery";
import module namespace uiclist = 'http://converters.eionet.europa.eu/common/ui/codelist' at "../../common/ui/codelist.xquery";
import module namespace uimsiteid = 'http://converters.eionet.europa.eu/wise/common/ui/monitoringSiteIdentifier' at '../../wise-common/ui/ui-monitoring-site-identifier.xquery';
import module namespace uiwtrbdcat = "http://converters.eionet.europa.eu/wise/common/ui/waterBodyCategory" at '../../wise-common/ui/ui-water-body-category.xquery';
import module namespace uirefyear = 'http://converters.eionet.europa.eu/wise/common/ui/referenceYear' at '../../wise-common/ui/ui-reference-year.xquery';
import module namespace uisampleperiod = 'http://converters.eionet.europa.eu/wise/common/ui/samplingPeriod'  at '../../wise-common/ui/ui-sampling-period.xquery';
import module namespace uiwqlbioeqrdres = 'http://converters.eionet.europa.eu/wise/biology/biologyEqrData/ui/resultValueLimits' at '../common/ui/ui-result-value-limits.xquery';
import module namespace uiwqldetwbcat = "http://converters.eionet.europa.eu/wise/biology/common/ui/determinandsAndWaterBodyCategory" at "../common/ui/ui-determinands-water-body-category.xquery";

declare variable $biobioeqrd:TABLE-ID := "11115";

declare function biobioeqrd:run-checks($sourceUrl as xs:string)
as element(div)
{
    let $fullDoc := doc($sourceUrl)
    let $dataDoc := $fullDoc//*:BiologyEQRData

    let $model := meta:get-table-metadata($biobioeqrd:TABLE-ID)
    let $envelope := interop:get-envelope-metadata($sourceUrl)
    let $monitoringSitesVocabulary := doc("http://dd.eionet.europa.eu/vocabulary/wise/MonitoringSite/rdf")/*
    let $vocabularyObservedPropertyBiologyEQR := doc("http://dd.eionet.europa.eu/vocabulary/wise/ObservedPropertyBiologyEQR/rdf")/*
    let $dataFlowCycles := doc("http://converters.eionet.europa.eu/xmlfile/dataflow_cycles.xml")/*
    return biobioeqrd:run-checks($dataDoc, $model, $envelope, $monitoringSitesVocabulary, $vocabularyObservedPropertyBiologyEQR, $dataFlowCycles)
};

declare function biobioeqrd:run-checks(
    $dataDoc as element()*,
    $model as element(model), 
    $envelope as element(envelope),
    $monitoringSitesVocabulary as element(),
    $vocabularyObservedPropertyBiologyEQR as element(),
    $dataFlowCycles as element(DataFlows)
)
as element(div)
{
    let $qcs := biobioeqrd:getQcMetadata($model, $envelope, $dataFlowCycles)
    let $dataRows := data:get-rows($dataDoc)
    let $qcResultsMarkup := 
        <div>
            { biobioeqrd:_run-mandatory-field-qc($qcs/qc[@id="wqlbioeqrdqc1"], $model, $dataRows) }
            { biobioeqrd:_run-duplicate-rows-qc($qcs/qc[@id="wqlbioeqrdqc2"], $model, $dataRows) }
            { biobioeqrd:_run-data-types-qc($qcs/qc[@id="wqlbioeqrdqc3"], $model, $dataRows) }
            { biobioeqrd:_run-codelists-qc($qcs/qc[@id="wqlbioeqrdqc4"], $model, $dataRows) }
            { biobioeqrd:_run-monitoring-site-id-format-qc($qcs/qc[@id="wqlbioeqrdqc5"], $model, $envelope, $dataRows) }
            { biobioeqrd:_run-monitoring-site-id-reference-qc($qcs/qc[@id="wqlbioeqrdqc6"], $model, $monitoringSitesVocabulary, $dataRows) }
            { biobioeqrd:_run-water-body-category-qc($qcs/qc[@id="wqlbioeqrdqc7"], $model, $dataRows) }
            { biobioeqrd:_run-reference-year-qc($qcs/qc[@id="wqlbioeqrdqc8"], $model, $dataFlowCycles, $dataRows) }
            { biobioeqrd:_run-sampling-period-qc($qcs/qc[@id="wqlbioeqrdqc9"], $model, $dataRows) }
            { biobioeqrd:_run-result-value-limits-qc($qcs/qc[@id="wqlbioeqrdqc10"], $model, $dataRows) }
            { biobioeqrd:_run-determinands-and-water-body-category-qc($qcs/qc[@id="wqlbioeqrdqc11"], $model, $vocabularyObservedPropertyBiologyEQR, $dataRows) }
        </div>
    return 
        <div class="feedbacktext">
            { html:getCss() }
            { html:getJavascript() }
            <div>
                { uiutil:build-header-and-menu-markup("WISE SoE - Biology in transitional and coastal waters", "Biology EQR data", $qcs, $qcResultsMarkup) }
                { $qcResultsMarkup }
            </div>
        </div>
};

declare function biobioeqrd:getQcMetadata(
    $model as element(model),
    $envelope as element(envelope),
    $dataFlowCycles as element(DataFlows)
)
as element(qcs)
{
    <qcs>
        { biobioeqrd:_get-mandatory-qc-metadata($model) }
        { biobioeqrd:_get-duplicate-rows-qc-metadata($model) }
        { biobioeqrd:_get-data-types-qc-metadata($model) }
        { biobioeqrd:_get-codelists-qc-metadata($model) }
        { biobioeqrd:_get-monitoring-site-id-format-qc-metadata($envelope) }
        { biobioeqrd:_get-monitoring-site-id-reference-qc-metadata() }
        { biobioeqrd:_get-water-body-category-qc-metadata() }
        { biobioeqrd:_get-reference-year-qc-metadata($dataFlowCycles) }
        { biobioeqrd:_get-sampling-period-qc-metadata() }
        { biobioeqrd:_get-result-value-limits-qc-metadata() }
        { biobioeqrd:_get-determinands-and-water-body-category-qc-metadata() }
    </qcs>
};

declare function biobioeqrd:_get-mandatory-qc-metadata($model as element(model))
as element(qc)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    let $mandatoryColumnString := string-join($mandatoryColumns/meta:get-column-name(.), ", ")
    let $exceptionColumnNames := ("resultObservedValue", "resultUom", "resultQualityObservedValueBelowLOQ")
    let $dependencyColumnName := "resultObservationStatus"
    return
        <qc id="wqlbioeqrdqc1">
            <caption>1. Mandatory values test</caption>
            <description>
                Tested the presence of mandatory values - { $mandatoryColumnString }.
                <br/><br/>
                In addition, it is also prefered that at least one of the following values is provided - resultEQRValue, resultNormalisedEQRValue
            </description>
            <columnExceptions>
                <columnException columnName="resultEQRValue" onMatch="{ $qclevels:OK }" onMissmatch="{ $qclevels:WARNING }">
                    <dependencies>
                        <dependency columnName="resultNormalisedEQRValue" />
                    </dependencies>
                </columnException>
                <columnException columnName="resultNormalisedEQRValue" onMatch="{ $qclevels:OK }" onMissmatch="{ $qclevels:WARNING }">
                    <dependencies>
                        <dependency columnName="resultEQRValue" />
                    </dependencies>
                </columnException>
                {
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
            <onWarning>
                <message>WARNING - some prefered values are mising.</message>
            </onWarning>
            <onBlocker>
                <message>BLOCKER - some mandatory values are missing.</message>
            </onBlocker>
        </qc>
};

declare function biobioeqrd:_get-duplicate-rows-qc-metadata($model as element(model))
as element(qc)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $keyColumnsList := string-join($keyColumns/meta:get-column-name(.), ", ")
    return
        <qc id="wqlbioeqrdqc2">
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

declare function biobioeqrd:_get-data-types-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="wqlbioeqrdqc3">
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

declare function biobioeqrd:_get-codelists-qc-metadata($model as element(model))
as element(qc)
{
    let $codelistColumns := meta:get-valuelist-columns($model)
    let $codelistColumnsString := string-join($codelistColumns/meta:get-column-name(.), ", ")
    return
        <qc id="wqlbioeqrdqc4">
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
                <url columnName="observedPropertyDeterminandBiologyEQRCode" value="http://dd.eionet.europa.eu/vocabulary/wise/ObservedPropertyBiologyEQR" />
                <url columnName="resultEcologicalStatusClassValue" value="http://dd.eionet.europa.eu/fixedvalues/elem/76069" />
                <url columnName="resultObservationStatus" value="http://dd.eionet.europa.eu/fixedvalues/elem/77669" />
                <url columnName="ClassificationSystem" value="http://dd.eionet.europa.eu/vocabulary/wise/ClassificationSystem" />
            </codelistUrls>
        </qc>
};

declare function biobioeqrd:_get-monitoring-site-id-format-qc-metadata($envelope as element(envelope))
as element(qc)
{
    let $countryCode := valconv:convertCountryCode($envelope/countrycode)
    return
        <qc id="wqlbioeqrdqc5">
            <caption>5. Monitoring site identifier format test</caption>
            <description>
                Tested correctness of the monitoringSiteIdentifier value format:
                <ol>
                    <li>
                        The country code part of the identifier value must match the one of the reporting country { $countryCode }, except use "UK" instead of "GB" and use "EL" instead of "GR"
                    </li>
                    <li>
                        <![CDATA[
                        The identifier value can't contain punctuation marks, white space or other special characters, including accented characters, except for "-" or "_". It must use only upper case letters. The third character, following the 2-letter country code, can't be "-" or "_". The total length of the identifier can't exceed 42 characters. (Regular expression: [A-Z]{2}[0-9A-Z]{1}[0-9A-Z-_]{0,39})
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

declare function biobioeqrd:_get-monitoring-site-id-reference-qc-metadata()
as element(qc)
{
    <qc id="wqlbioeqrdqc6">
        <caption>6. Monitoring site identifier reference test</caption>
        <description>
            Tested presence of the monitoringSiteIdentifier and its respective monitoringSiteIdntifierScheme in the <a target="_blank" href="http://dd.eionet.europa.eu/vocabulary/wise/monitoringSite">official reference list</a>. The list has been created from the previously reported data on monitoring sites.
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

declare function biobioeqrd:_get-water-body-category-qc-metadata()
as element(qc)
{
    <qc id="wqlbioeqrdqc7">
        <caption>7. Water body category test</caption>
        <description>
            Tested whether data are reported only from inland surface water bodies (parameterWaterBodyCategory is TW or CW)
        </description>
        <validCategories>
            <category value="TW" />
            <category value="CW" />
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

declare function biobioeqrd:_get-reference-year-qc-metadata($dataFlowCycles as element(DataFlows))
as element(qc)
{
    let $dataFlowCycle := vldrefyear:get-data-flow-cycle($dataFlowCycles)
    let $yearStart := vldrefyear:get-start-year($dataFlowCycle)
    let $yearEnd := vldrefyear:get-end-year($dataFlowCycle)
    return
        <qc id="wqlbioeqrdqc8">
            <caption>8. Reference year test</caption>
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

declare function biobioeqrd:_get-sampling-period-qc-metadata()
as element(qc)
{
    <qc id="wqlbioeqrdqc9">
        <caption>9. Sampling period test</caption>
        <description>
            Tested whether the parameterSamplingPeriod value
            <ol>
                <li>is provided in the requested format (YYYY-MM-DD--YYYY-MM-DD or YYYY-MM--YYYY-MM)</li>
                <li>starting date is not higher than ending year.</li>
                <li>represents a period of maximum one year.</li>
                <li>matches with the value provided in the phenomenonTimeReferenceYear field.</li>
            </ol>
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onError>
            <message>
                ERROR - some of the reported parameterSamplingPeriod values do not follow some of the constraints.
            </message>
        </onError>
    </qc>
};

declare function biobioeqrd:_get-result-value-limits-qc-metadata()
as element(qc)
{
    <qc id="wqlbioeqrdqc10">
        <caption>10. Result values - limits test</caption>
        <description>
            <![CDATA[
            Tested whether the resultEQRValue are within the acceptable value ranges for the EQR scale (<=1.5).
            ]]>
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onInfo>
            <message>
                INFO - some of the reported resultEQRValue appears not to be in EQR scale but have been confirmed as valid.
            </message>
        </onInfo>
        <onWarning>
            <message>
                WARNING - some of the reported resultEQRValue appears not to be in EQR scale.
            </message>
        </onWarning>
    </qc>
};

declare function biobioeqrd:_get-determinands-and-water-body-category-qc-metadata()
as element(qc)
{
    <qc id="wqlbioeqrdqc11">
        <caption>11. Determinands and Water body category test</caption>
        <description>
            Tested whether only relevant observedPropertyDeterminandBiologyEQRCode is reported in the given water body category:
            <ol>
                <li>TW: Phytoplankton, Macroalgae, Angiosperms, Invertebrates and Fish</li>
                <li>CW: Phytoplankton, Macroalgae, Angiosperms, and Invertebrates</li>
            </ol>
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported observedPropertyDeterminandBiologyEQRCode values are not relevant for given water body catagory.
            </message>
        </onBlocker>
    </qc>
};

declare function biobioeqrd:_run-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $mandatoryColumns := (meta:get-mandatory-columns($model), meta:get-columns-by-names($model, ('resultEQRValue', 'resultNormalisedEQRValue')))
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $mandatoryColumns, $columnExceptions, $dataRows)
    let $columnsToDisplay := $model/columns/column
    return uimandatory:build-mandatory-column-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function biobioeqrd:_run-duplicate-rows-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $validationResult := vldduplicates:validate-duplicate-rows($dataRows, $keyColumns)
    let $columnsToDisplay := $model/columns/column
    return uiduplicates:build-duplicate-rows-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function biobioeqrd:_run-data-types-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $typeExceptions := $qc/typeExceptions
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtypes:validate-data-types($model, $dataRows, $typeExceptions)
    return uitypes:build-data-types-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function biobioeqrd:_run-codelists-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $columnsToDisplay := $model/columns/column
    let $codelistUrls := $qc/codelistUrls
    let $exceptions := $qc/codelistExceptions/*
    let $validationResult :=  vldclist:validate-codelists($model, $exceptions, $dataRows)
    return uiclist:build-codelists-markup($qc, $model, $columnsToDisplay, $codelistUrls, $validationResult)
};

declare function biobioeqrd:_run-monitoring-site-id-format-qc($qc as element(qc), $model as element(model), $envelope as element(envelope), $dataRows as element(dataRow)*)
as element(div)
{
    let $monitoringSiteIdColumn := $model/columns/column[meta:get-column-name(.) = 'monitoringSiteIdentifier']
    let $monitoringSiteIdSchemeColumn := $model/columns/column[meta:get-column-name(.) = 'monitoringSiteIdentifierScheme']
    let $validationResult :=  vldmsiteid:validate-monitoring-site-identifier-format($monitoringSiteIdColumn, $envelope, $dataRows)
    return uimsiteid:build-monitoring-site-id-format-qc-markup($qc, $monitoringSiteIdColumn, $monitoringSiteIdSchemeColumn, $validationResult)
};

declare function biobioeqrd:_run-monitoring-site-id-reference-qc(
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

declare function biobioeqrd:_run-water-body-category-qc(
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

declare function biobioeqrd:_run-reference-year-qc(
    $qc as element(qc), 
    $model as element(model),
    $dataFlowCycles as element(DataFlows),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnReferenceYear := meta:get-column-by-name($model, "phenomenonTimeReferenceYear")
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldrefyear:validate-reference-year-biology-2017($columnReferenceYear, $dataFlowCycles, $dataRows)
    return uirefyear:build-reference-year-qc-markup($qc, $columnReferenceYear, $columnsToDisplay, $validationResult)
};

declare function biobioeqrd:_run-sampling-period-qc(
    $qc as element(qc), 
    $model as element(model),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnSamplingPeriod := meta:get-column-by-name($model, "parameterSamplingPeriod")
    let $columnReferenceYear := meta:get-column-by-name($model, "phenomenonTimeReferenceYear")
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldsampleperiod:validate-sampling-period($columnSamplingPeriod, $columnReferenceYear, $dataRows)
    return uisampleperiod:build-sampling-period-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function biobioeqrd:_run-result-value-limits-qc(
    $qc as element(qc), 
    $model as element(model),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldwqlbioeqrdres:validate-result-value-limits($model, $dataRows)
    return uiwqlbioeqrdres:build-result-value-limits-qc-markup($qc, $columnsToDisplay,$validationResult)
};

declare function biobioeqrd:_run-determinands-and-water-body-category-qc(
    $qc as element(qc), 
    $model as element(model),
    $vocabularyObservedPropertyBiologyEQR as element(),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldwqldetwbcat:validate-determinands-and-water-body-category($model, $dataRows)
    return uiwqldetwbcat:build-determinands-and-water-body-category-qc-markup($qc, $model, $vocabularyObservedPropertyBiologyEQR, $columnsToDisplay, $validationResult)
};
