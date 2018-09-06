xquery version "1.0" encoding "UTF-8";

module namespace wqlbioeqrd = 'http://converters.eionet.europa.eu/wise/waterQuality/biologyEqrData';

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
import module namespace vldwqlbioeqrdres = 'http://converters.eionet.europa.eu/wise/waterQuality/biologyEqrData/validators/resultValueLimits' at './validators/vld-result-value-limits.xquery';
import module namespace vldwqldetwbcat = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/determinandsAndWaterBodyCategory" at "../common/validators/vld-determinands-water-body-category.xquery";

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
import module namespace uiwqlbioeqrdres = 'http://converters.eionet.europa.eu/wise/waterQuality/biologyEqrData/ui/resultValueLimits' at './ui/ui-result-value-limits.xquery';
import module namespace uiwqldetwbcat = "http://converters.eionet.europa.eu/wise/waterQuality/common/ui/determinandsAndWaterBodyCategory" at "../common/ui/ui-determinands-water-body-category.xquery";

declare variable $wqlbioeqrd:TABLE-ID := "9325";

declare function wqlbioeqrd:run-checks($sourceUrl as xs:string)
as element(div)
{
    let $dataDoc := doc($sourceUrl)/*:BiologyEQRData
    let $model := meta:get-table-metadata($wqlbioeqrd:TABLE-ID)
    let $envelope := interop:get-envelope-metadata($sourceUrl)
    let $monitoringSitesVocabulary := doc("../xmlfile/MonitoringSite.rdf")/*
    let $vocabularyObservedPropertyBiologyEQR := doc("http://dd.eionet.europa.eu/vocabulary/wise/ObservedPropertyBiologyEQR/rdf")/*
    let $dataFlowCycles := doc("http://converters.eionet.europa.eu/xmlfile/dataflow_cycles.xml")/*
    return wqlbioeqrd:run-checks($dataDoc, $model, $envelope, $monitoringSitesVocabulary, $vocabularyObservedPropertyBiologyEQR, $dataFlowCycles)
};

declare function wqlbioeqrd:run-checks(
    $dataDoc as element()*,
    $model as element(model), 
    $envelope as element(envelope),
    $monitoringSitesVocabulary as element(),
    $vocabularyObservedPropertyBiologyEQR as element(),
    $dataFlowCycles as element(DataFlows)
)
as element(div)
{
    let $qcs := wqlbioeqrd:getQcMetadata($model, $envelope, $dataFlowCycles)
    let $dataRows := data:get-rows($dataDoc)
    let $qcResultsMarkup := 
        <div>
            { wqlbioeqrd:_run-mandatory-field-qc($qcs/qc[@id="qc1"], $model, $dataRows) }
            { wqlbioeqrd:_run-duplicate-rows-qc($qcs/qc[@id="qc2"], $model, $dataRows) }
            { wqlbioeqrd:_run-data-types-qc($qcs/qc[@id="qc3"], $model, $dataRows) }
            { wqlbioeqrd:_run-codelists-qc($qcs/qc[@id="qc4"], $model, $dataRows) }
            { wqlbioeqrd:_run-monitoring-site-id-format-qc($qcs/qc[@id="qc5"], $model, $envelope, $dataRows) }
            { wqlbioeqrd:_run-monitoring-site-id-reference-qc($qcs/qc[@id="qc6"], $model, $monitoringSitesVocabulary, $dataRows) }
            { wqlbioeqrd:_run-water-body-category-qc($qcs/qc[@id="qc7"], $model, $dataRows) }
            { wqlbioeqrd:_run-reference-year-qc($qcs/qc[@id="qc8"], $model, $dataFlowCycles, $dataRows) }
            { wqlbioeqrd:_run-sampling-period-qc($qcs/qc[@id="qc9"], $model, $dataRows) }
            { wqlbioeqrd:_run-result-value-limits-qc($qcs/qc[@id="qc10"], $model, $dataRows) }
            { wqlbioeqrd:_run-determinands-and-water-body-category-qc($qcs/qc[@id="qc11"], $model, $vocabularyObservedPropertyBiologyEQR, $dataRows) }
        </div>
    return 
        <div class="feedbacktext"> 
            { html:getCss() }
            { html:getJavascript() }
            <div>
                { uiutil:build-header-and-menu-markup("WISE SoE - Water Quality", "Annual biology EQR data by monitoring site", $qcs, $qcResultsMarkup) }
                { $qcResultsMarkup }
            </div>
        </div>
};

declare function wqlbioeqrd:getQcMetadata(
    $model as element(model),
    $envelope as element(envelope),
    $dataFlowCycles as element(DataFlows)
)
as element(qcs)
{
    <qcs>
        { wqlbioeqrd:_get-mandatory-qc-metadata($model) }
        { wqlbioeqrd:_get-duplicate-rows-qc-metadata($model) }
        { wqlbioeqrd:_get-data-types-qc-metadata($model) }
        { wqlbioeqrd:_get-codelists-qc-metadata($model) }
        { wqlbioeqrd:_get-monitoring-site-id-format-qc-metadata($envelope) }
        { wqlbioeqrd:_get-monitoring-site-id-reference-qc-metadata() }
        { wqlbioeqrd:_get-water-body-category-qc-metadata() }
        { wqlbioeqrd:_get-reference-year-qc-metadata($dataFlowCycles) }
        { wqlbioeqrd:_get-sampling-period-qc-metadata() }
        { wqlbioeqrd:_get-result-value-limits-qc-metadata() }
        { wqlbioeqrd:_get-determinands-and-water-body-category-qc-metadata() }
    </qcs>
};

declare function wqlbioeqrd:_get-mandatory-qc-metadata($model as element(model))
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
            </columnExceptions>
            <onSuccess>
                <message>OK - data passed the test.</message>
            </onSuccess>
            <onWarning>
                <message>WARNING - some prefered values are mising.</message>
            </onWarning>
            <onBlocker>
                <message>BLOCKER - some mandatory values are missing.</message>
            </onBlocker>
        </qc>
};

declare function wqlbioeqrd:_get-duplicate-rows-qc-metadata($model as element(model))
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

declare function wqlbioeqrd:_get-data-types-qc-metadata($model as element(model))
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

declare function wqlbioeqrd:_get-codelists-qc-metadata($model as element(model))
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
                <url columnName="observedPropertyDeterminandBiologyEQRCode" value="http://dd.eionet.europa.eu/vocabulary/wise/ObservedPropertyBiologyEQR" />
                <url columnName="resultEcologicalStatusClassValue" value="http://dd.eionet.europa.eu/fixedvalues/elem/76069" />
                <url columnName="resultObservationStatus" value="http://dd.eionet.europa.eu/fixedvalues/elem/77669" />
            </codelistUrls>
        </qc>
};

declare function wqlbioeqrd:_get-monitoring-site-id-format-qc-metadata($envelope as element(envelope))
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

declare function wqlbioeqrd:_get-monitoring-site-id-reference-qc-metadata()
as element(qc)
{
    <qc id="qc6">
        <caption>6. Monitoring site identifier reference test</caption>
        <description>
            Tested presence of the monitoringSiteIdentifier and its respective monitoringSiteIdntifierScheme in the <a target="_blank" href="http://dd.eionet.europa.eu/vocabulary/wise/MonitoringSite">official reference list</a>. The list has been created from the previously reported data on monitoring sites.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onWarning>
            <message>WARNING - some of the monitoringSiteIdentifier values are missing in the reference list. Please assure that it is not due to an error and that they are reported under WFD, or report them under WISE Spatial data reporting.</message>
        </onWarning>
        <onBlocker>
            <message>BLOCKER - some of the monitoringSiteIdentifier values are missing in the reference list. Please assure that it is not due to an error and that they are reported under WFD, or report them under WISE Spatial data reporting.</message>
        </onBlocker>
    </qc>
};

declare function wqlbioeqrd:_get-water-body-category-qc-metadata()
as element(qc)
{
    <qc id="qc7">
        <caption>7. Water body category test</caption>
        <description>
            Tested whether data are reported only from inland surface water bodies (parameterWaterBodyCategory is LW or RW)
        </description>
        <validCategories>
            <category value="LW" />
            <category value="RW" />
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

declare function wqlbioeqrd:_get-reference-year-qc-metadata($dataFlowCycles as element(DataFlows))
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

declare function wqlbioeqrd:_get-sampling-period-qc-metadata()
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

declare function wqlbioeqrd:_get-result-value-limits-qc-metadata()
as element(qc)
{
    <qc id="qc10">
        <caption>10. Result values - limits test</caption>
        <description>
            <![CDATA[
            Tested whether the resultEQRValue are within the expected value ranges for the EQR scale (<=1.5).
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

declare function wqlbioeqrd:_get-determinands-and-water-body-category-qc-metadata()
as element(qc)
{
    <qc id="qc11">
        <caption>11. Determinands and Water body category test</caption>
        <description>
            Tested whether only relevant observedPropertyDeterminandBiologyEQRCode is reported in the given water body category:
            <ol>
                <li>LW: only Macrophyte and Phytoplankton</li>
                <li>RW: only Invertebrate and Phytobenthos</li>
            </ol>
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onError>
            <message>
                ERROR - some of the reported observedPropertyDeterminandBiologyEQRCode values are not relevant for given water body catagory.
            </message>
        </onError>
    </qc>
};

declare function wqlbioeqrd:_run-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $mandatoryColumns := (meta:get-mandatory-columns($model), meta:get-columns-by-names($model, ('resultEQRValue', 'resultNormalisedEQRValue')))
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $mandatoryColumns, $columnExceptions, $dataRows)
    let $colunsToDisplay := $model/columns/column
    return uimandatory:build-mandatory-column-qc-markup($qc, $colunsToDisplay, $validationResult)
};

declare function wqlbioeqrd:_run-duplicate-rows-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $validationResult := vldduplicates:validate-duplicate-rows($dataRows, $keyColumns)
    let $columnsToDisplay := $model/columns/column
    return uiduplicates:build-duplicate-rows-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function wqlbioeqrd:_run-data-types-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $typeExceptions := $qc/typeExceptions
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtypes:validate-data-types($model, $dataRows, $typeExceptions)
    return uitypes:build-data-types-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function wqlbioeqrd:_run-codelists-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $columnsToDisplay := $model/columns/column
    let $codelistUrls := $qc/codelistUrls
    let $validationResult :=  vldclist:validate-codelists($model, $dataRows)
    return uiclist:build-codelists-markup($qc, $model, $columnsToDisplay, $codelistUrls, $validationResult)
};

declare function wqlbioeqrd:_run-monitoring-site-id-format-qc($qc as element(qc), $model as element(model), $envelope as element(envelope), $dataRows as element(dataRow)*)
as element(div)
{
    let $monitoringSiteIdColumn := $model/columns/column[meta:get-column-name(.) = 'monitoringSiteIdentifier']
    let $monitoringSiteIdSchemeColumn := $model/columns/column[meta:get-column-name(.) = 'monitoringSiteIdentifierScheme']
    let $validationResult :=  vldmsiteid:validate-monitoring-site-identifier-format($monitoringSiteIdColumn, $envelope, $dataRows)
    return uimsiteid:build-monitoring-site-id-format-qc-markup($qc, $monitoringSiteIdColumn, $monitoringSiteIdSchemeColumn, $validationResult)
};

declare function wqlbioeqrd:_run-monitoring-site-id-reference-qc(
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

declare function wqlbioeqrd:_run-water-body-category-qc(
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

declare function wqlbioeqrd:_run-reference-year-qc(
    $qc as element(qc), 
    $model as element(model),
    $dataFlowCycles as element(DataFlows),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnReferenceYear := meta:get-column-by-name($model, "phenomenonTimeReferenceYear")
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldrefyear:validate-reference-year($columnReferenceYear, $dataFlowCycles, $dataRows)
    return uirefyear:build-reference-year-qc-markup($qc, $columnReferenceYear, $columnsToDisplay, $validationResult)
};

declare function wqlbioeqrd:_run-sampling-period-qc(
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

declare function wqlbioeqrd:_run-result-value-limits-qc(
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

declare function wqlbioeqrd:_run-determinands-and-water-body-category-qc(
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
