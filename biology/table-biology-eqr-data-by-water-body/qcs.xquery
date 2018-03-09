xquery version "1.0" encoding "UTF-8";

module namespace biobioeqrdwb = 'http://converters.eionet.europa.eu/wise/biology/biologyEqrDataByWaterBody';

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
import module namespace uiwbodyid = 'http://converters.eionet.europa.eu/wise/common/ui/waterBodyIdentifier' at '../../wise-common/ui/ui-water-body-identifier.xquery';
import module namespace uiwtrbdcat = "http://converters.eionet.europa.eu/wise/common/ui/waterBodyCategory" at '../../wise-common/ui/ui-water-body-category.xquery';
import module namespace uirefyear = 'http://converters.eionet.europa.eu/wise/common/ui/referenceYear' at '../../wise-common/ui/ui-reference-year.xquery';
import module namespace uisampleperiod = 'http://converters.eionet.europa.eu/wise/common/ui/samplingPeriod'  at '../../wise-common/ui/ui-sampling-period.xquery';
import module namespace uiwqlbioeqrdres = 'http://converters.eionet.europa.eu/wise/biology/biologyEqrData/ui/resultValueLimits' at '../common/ui/ui-result-value-limits.xquery';
import module namespace uiwqldetwbcat = "http://converters.eionet.europa.eu/wise/biology/common/ui/determinandsAndWaterBodyCategory" at "../common/ui/ui-determinands-water-body-category.xquery";

declare variable $biobioeqrdwb:TABLE-ID := "11117";

declare function biobioeqrdwb:run-checks($sourceUrl as xs:string)
as element(div)
{
    let $fullDoc := doc($sourceUrl)
    let $dataDoc := $fullDoc/*:BiologyEQRDataByWaterBody

    let $model := meta:get-table-metadata($biobioeqrdwb:TABLE-ID)
    let $envelope := interop:get-envelope-metadata($sourceUrl)
    let $vocabularyWaterBodies := doc("../xmlfile/2017_WaterBody.rdf")/*
    let $vocabularyObservedProperty := doc("http://dd.eionet.europa.eu/vocabulary/wise/ObservedProperty/rdf")/*
    let $dataFlowCycles := doc("http://converters.eionet.europa.eu/xmlfile/dataflow_cycles.xml")/*
    return biobioeqrdwb:run-checks($dataDoc, $model, $envelope, $vocabularyWaterBodies, $vocabularyObservedProperty, $dataFlowCycles)
};

declare function biobioeqrdwb:run-checks(
    $dataDoc as element()*,
    $model as element(model),
    $envelope as element(envelope),
    $vocabularyWaterBodies as element(),
    $vocabularyObservedProperty as element(),
    $dataFlowCycles as element(DataFlows)
)
as element(div)
{
    let $qcs := biobioeqrdwb:getQcMetadata($model, $envelope, $dataFlowCycles)
    let $dataRows := data:get-rows($dataDoc)
    let $qcResultsMarkup := 
        <div>
            { biobioeqrdwb:_run-mandatory-field-qc($qcs/qc[@id="wqlagwbqc1"], $model, $dataRows) }
            { biobioeqrdwb:_run-duplicate-rows-qc($qcs/qc[@id="wqlagwbqc2"], $model, $dataRows) }
            { biobioeqrdwb:_run-data-types-qc($qcs/qc[@id="wqlagwbqc3"], $model, $dataRows) }
            { biobioeqrdwb:_run-codelists-qc($qcs/qc[@id="wqlagwbqc4"], $model, $dataRows) }
            { biobioeqrdwb:_run-water-body-id-format-qc($qcs/qc[@id="wqlagwbqc5"], $model, $envelope, $dataRows) }
            { biobioeqrdwb:_run-water-body-id-reference-qc($qcs/qc[@id="wqlagwbqc6"], $model, $vocabularyWaterBodies, $dataRows) }
            { biobioeqrdwb:_run-water-body-category-qc($qcs/qc[@id="wqlagwbqc7"], $model, $dataRows) }
            { biobioeqrdwb:_run-reference-year-qc($qcs/qc[@id="wqlagwbqc8"], $model, $dataFlowCycles, $dataRows) }
            { biobioeqrdwb:_run-sampling-period-qc($qcs/qc[@id="wqlagwbqc9"], $model, $dataRows) }
            { biobioeqrdwb:_run-result-values-limits-qc($qcs/qc[@id="wqlagwbqc10"], $model, $dataRows) }
            { biobioeqrdwb:_run-determinands-and-water-body-category-qc($qcs/qc[@id="wqlagwbqc11"], $model, $vocabularyObservedProperty, $dataRows) }
        </div>
    return 
        <div class="feedbacktext">
            { html:getCss() }
            { html:getJavascript() }
            <div>
                { uiutil:build-header-and-menu-markup("WISE SoE - Biology in transitional and coastal waters", "Biology EQR data by water body", $qcs, $qcResultsMarkup) }
                { $qcResultsMarkup }
            </div>
        </div>
};

declare function biobioeqrdwb:getQcMetadata(
    $model as element(model), 
    $envelope as element(envelope),
    $dataFlowCycles as element(DataFlows)
)
as element(qcs)
{
    <qcs>
        { biobioeqrdwb:_get-mandatory-qc-metadata($model) }
        { biobioeqrdwb:_get-duplicate-rows-qc-metadata($model) }
        { biobioeqrdwb:_get-data-types-qc-metadata($model) }
        { biobioeqrdwb:_get-codelists-qc-metadata($model) }
        { biobioeqrdwb:_get-water-body-id-format-qc-metadata($model, $envelope) }
        { biobioeqrdwb:_get-water-body-id-reference-qc-metadata($model) }
        { biobioeqrdwb:_get-water-body-category-qc-metadata($model) }
        { biobioeqrdwb:_get-reference-year-qc-metadata($dataFlowCycles) }
        { biobioeqrdwb:_get-sampling-period-qc-metadata() }
        { biobioeqrdwb:_get-result-values-limits-qc-metadata() }
        { biobioeqrdwb:_get-determinands-and-water-body-category-qc-metadata() }
    </qcs>
};

declare function biobioeqrdwb:_get-mandatory-qc-metadata($model as element(model))
as element(qc)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    let $mandatoryColumnString := string-join($mandatoryColumns/meta:get-column-name(.), ", ")
    let $exceptionColumnNames := ("resultObservedValue", "resultUom", "resultQualityObservedValueBelowLOQ")
    let $dependencyColumnName := "resultObservationStatus"
    return
        <qc id="wqlagwbqc1">
            <caption>1. Mandatory values test</caption>
            <description>
                Tested the presence of mandatory values - { $mandatoryColumnString }. 
                <br/><br/>
                In addition, it is also prefered that one of the following values is provided - resultEQRValue, resultNormalisedEQRValue
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

declare function biobioeqrdwb:_get-duplicate-rows-qc-metadata($model as element(model))
as element(qc)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $keyColumnsList := string-join($keyColumns/meta:get-column-name(.), ", ")
    return
        <qc id="wqlagwbqc2">
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

declare function biobioeqrdwb:_get-data-types-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="wqlagwbqc3">
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

declare function biobioeqrdwb:_get-codelists-qc-metadata($model as element(model))
as element(qc)
{
    let $codelistColumns := meta:get-valuelist-columns($model)
    let $codelistColumnsString := string-join($codelistColumns/meta:get-column-name(.), ", ")
    return
        <qc id="wqlagwbqc4">
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

declare function biobioeqrdwb:_get-water-body-id-format-qc-metadata($model as element(model), $envelope as element(envelope))
as element(qc)
{
    let $countryCode := valconv:convertCountryCode($envelope/countrycode)
    return
        <qc id="wqlagwbqc5">
            <caption>5. Water body identifier format test</caption>
            <description>
                Tested correctness of the waterBodyIdentifier value format:
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
                <message>BLOCKER - some of the waterBodyIdentifier values are either incorrectly formated or identify water bodies that belong to a different country.</message>
            </onBlocker>
        </qc>
};

declare function biobioeqrdwb:_get-water-body-id-reference-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="wqlagwbqc6">
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

declare function biobioeqrdwb:_get-water-body-category-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="wqlagwbqc7">
        <caption>7. Water body category test</caption>
        <description>
            Tested whether the data reported are from transitional or coastal waters (parameterWaterBodyCategory is TW or CW)
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

declare function biobioeqrdwb:_get-reference-year-qc-metadata($dataFlowCycles as element(DataFlows))
as element(qc)
{
    let $dataFlowCycle := vldrefyear:get-data-flow-cycle($dataFlowCycles)
    let $yearStart := vldrefyear:get-start-year($dataFlowCycle)
    let $yearEnd := vldrefyear:get-end-year($dataFlowCycle)
    return
        <qc id="wqlagwbqc8">
            <caption>8. Reference year test</caption>
            <description>
                Tested whether the phenomenonTimeReferenceYear value is from the expected range ({ $yearStart } - { $yearEnd }) in <a target="_blank" href="http://converters.eionet.europa.eu/xmlfile/dataflow_cycles.xml">dataflow_cycles.xml</a> where DataFlow RO_ID="630" and DataFlowCycle Identifier="2017".
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

declare function biobioeqrdwb:_get-sampling-period-qc-metadata()
as element(qc)
{
    <qc id="wqlagwbqc9">
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
        <onBlocker>
            <message>
                BLOCKER - some of the reported parameterSamplingPeriod values do not follow some of the constraints.
            </message>
        </onBlocker>
    </qc>
};

declare function biobioeqrdwb:_get-result-values-limits-qc-metadata()
as element(qc)
{
    <qc id="wqlagwbqc10">
        <caption>10. Result values - limits test</caption>
        <description>
            Tested whether the resultEQRValue are within the acceptable value ranges for the EQR scale (&lt;=1.5).
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

declare function biobioeqrdwb:_get-determinands-and-water-body-category-qc-metadata()
as element(qc)
{
    <qc id="wqlagwbqc11">
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
                BLOCKER - some of the reported observedPropertyDeterminandBiologyEQRCode values are not relevant for the given water body catagory.
            </message>
        </onBlocker>
    </qc>
};

declare function biobioeqrdwb:_run-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $columnExceptions, $dataRows)
    let $colunsToDisplay := ($mandatoryColumns, meta:get-columns-by-names($model, ('parameterSamplingPeriod', 'resultObservationStatus', 'Remarks')))
    return uimandatory:build-mandatory-column-qc-markup($qc, $colunsToDisplay, $validationResult)
};

declare function biobioeqrdwb:_run-duplicate-rows-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $validationResult := vldduplicates:validate-duplicate-rows($dataRows, $keyColumns)
    let $columnsToDisplay := ($keyColumns, meta:get-columns-by-names($model, ("resultUom", "parameterSamplingPeriod", "resultMeanValue", "resultObservationStatus", "Remarks")))
    return uiduplicates:build-duplicate-rows-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function biobioeqrdwb:_run-data-types-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $typeExceptions := $qc/typeExceptions
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtypes:validate-data-types($model, $dataRows, $typeExceptions)
    return uitypes:build-data-types-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function biobioeqrdwb:_run-codelists-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
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

declare function biobioeqrdwb:_run-water-body-id-format-qc(
        $qc as element(qc),
        $model as element(model),
        $envelope as element(envelope),
        $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnWaterBodyId := $model/columns/column[meta:get-column-name(.) = 'waterBodyIdentifier']
    let $columnWaterBodyIdScheme := $model/columns/column[meta:get-column-name(.) = 'waterBodyIdentifierScheme']
    let $validationResult :=  vldwbodyid:validate-water-body-identifier-format($columnWaterBodyId, $envelope, $dataRows)
    return uiwbodyid:build-water-body-id-format-qc-markup($qc, $columnWaterBodyId, $columnWaterBodyIdScheme, $validationResult)
};

declare function biobioeqrdwb:_run-water-body-id-reference-qc(
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

declare function biobioeqrdwb:_run-water-body-category-qc(
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

declare function biobioeqrdwb:_run-reference-year-qc(
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

declare function biobioeqrdwb:_run-sampling-period-qc(
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

declare function biobioeqrdwb:_run-result-values-limits-qc(
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

declare function biobioeqrdwb:_run-determinands-and-water-body-category-qc(
        $qc as element(qc),
        $model as element(model),
        $vocabularyObservedProperty as element(),
        $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldwqldetwbcat:validate-determinands-and-water-body-category($model, $dataRows)
    return uiwqldetwbcat:build-determinands-and-water-body-category-qc-markup($qc, $model, $vocabularyObservedProperty, $columnsToDisplay, $validationResult)
};
