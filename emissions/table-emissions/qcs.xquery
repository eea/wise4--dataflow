xquery version "1.0" encoding "UTF-8";

module namespace emissions = 'http://converters.eionet.europa.eu/wise/emissions/emissions';

import module namespace interop = "http://converters.eionet.europa.eu/common/interop" at "../../common/interop.xquery";
import module namespace meta = "http://converters.eionet.europa.eu/common/meta" at "../../common/meta.xquery";
import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../common/data.xquery";
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../common/qclevels.xquery';
import module namespace valconv = "http://converters.eionet.europa.eu/common/valueConversion" at "../../common/value-conversion.xquery";

import module namespace vldmandatory = "http://converters.eionet.europa.eu/common/validators/mandatory" at "../../common/validators/mandatory.xquery";
import module namespace vldduplicates = 'http://converters.eionet.europa.eu/common/validators/duplicates' at "../../common/validators/duplicates.xquery";
import module namespace vldtypes = 'http://converters.eionet.europa.eu/common/validators/types' at "../../common/validators/types.xquery";
import module namespace vldclist = 'http://converters.eionet.europa.eu/common/validators/codelist' at "../../common/validators/codelist.xquery";
import module namespace vldspunitid = 'http://converters.eionet.europa.eu/wise/common/validators/spatialUnitIdentifier' at '../../wise-common/validators/vld-spatial-unit-identifier.xquery';
import module namespace vldspunitidsch = 'http://converters.eionet.europa.eu/wise/common/validators/spatialUnitIdentifierScheme' at '../../wise-common/validators/vld-spatial-unit-identifier-scheme.xquery';
import module namespace vldemisemistrefprd = "http://converters.eionet.europa.eu/wise/emissions/emissions/validators/timeReferencePeriod" at './validators/vld-time-reference-period.xquery';
import module namespace vlduom = "http://converters.eionet.europa.eu/wise/common/validators/unitOfMeasure" at '../../wise-common/validators/vld-unit-of-measure.xquery';
import module namespace vldemisemismethod = "http://converters.eionet.europa.eu/wise/emissions/emissions/validators/emissionsMethod" at './validators/vld-emissions-method.xquery';

import module namespace html = 'http://converters.eionet.europa.eu/common/ui/html' at "../../common/ui/html-scripts.xquery";
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at "../../common/ui/util.xquery";

import module namespace uimandatory = "http://converters.eionet.europa.eu/common/ui/mandatory" at "../../common/ui/mandatory.xquery";
import module namespace uiduplicates = 'http://converters.eionet.europa.eu/common/ui/duplicates' at "../../common/ui/duplicates.xquery";
import module namespace uitypes = 'http://converters.eionet.europa.eu/common/ui/types' at "../../common/ui/types.xquery";
import module namespace uiclist = 'http://converters.eionet.europa.eu/common/ui/codelist' at "../../common/ui/codelist.xquery";
import module namespace uispunitid = 'http://converters.eionet.europa.eu/wise/common/ui/spatialUnitIdentifier' at '../../wise-common/ui/ui-spatial-unit-identifier.xquery';
import module namespace uispunitidsch = 'http://converters.eionet.europa.eu/wise/common/ui/spatialUnitIdentifierScheme' at '../../wise-common/ui/ui-spatial-unit-identifier-scheme.xquery';
import module namespace uiemisemistrefprd = "http://converters.eionet.europa.eu/wise/emissions/emissions/ui/timeReferencePeriod" at './ui/ui-time-reference-period.xquery';
import module namespace uiuom = "http://converters.eionet.europa.eu/wise/common/ui/unitOfMeasure" at '../../wise-common/ui/ui-unit-of-measure.xquery';
import module namespace uiemisemismethod = "http://converters.eionet.europa.eu/wise/emissions/emissions/ui/emissionsMethod" at './ui/ui-emissions-method.xquery';

declare variable $emissions:TABLE-ID := "11057";

declare function emissions:run-checks($sourceUrl as xs:string)
as element(div)
{
    let $fullDoc := doc($sourceUrl)
    let $dataDoc := $fullDoc/*:Emissions

    let $model := meta:get-table-metadata($emissions:TABLE-ID)
    let $envelope := interop:get-envelope-metadata($sourceUrl)
    let $dataFlowCycles := doc("http://converters.eionet.europa.eu/xmlfile/dataflow_cycles.xml")/*
    let $vocabularySpatialUnits := doc("http://dd.eionet.europa.eu/vocabulary/wise/SpatialUnit/rdf")/*
    let $vocabularyUom := doc("http://dd.eionet.europa.eu/vocabulary/wise/Uom/rdf")/*
    let $vocabularyObservedProperty := doc("http://dd.eionet.europa.eu/vocabulary/wise/ObservedProperty/rdf")/*
    let $vocabularyCombinationTableDeterminandUom := doc("http://dd.eionet.europa.eu/vocabulary/wise/QCCombinationTableDeterminandUom/rdf")/*
    return emissions:run-checks($dataDoc, $model, $envelope, $dataFlowCycles, $vocabularySpatialUnits, $vocabularyUom, $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom)
};

declare function emissions:run-checks(
    $dataDoc as element()*,
    $model as element(model), 
    $envelope as element(envelope),
    $dataFlowCycles as element(DataFlows),
    $vocabularySpatialUnits as element(),
    $vocabularyUom as element(),
    $vocabularyObservedProperty as element(),
    $vocabularyCombinationTableDeterminandUom as element()
)
as element(div)
{
    let $qcs := emissions:getQcMetadata($model, $envelope, $dataFlowCycles)
    let $dataRows := data:get-rows($dataDoc)
    let $qcResultsMarkup := 
        <div>
            { emissions:_run-mandatory-field-qc($qcs/qc[@id="qc1"], $model, $dataRows) }
            { emissions:_run-conditional-mandatory-field-qc($qcs/qc[@id="qc2"], $model, $dataRows) }
            { emissions:_run-duplicate-rows-qc($qcs/qc[@id="qc3"], $model, $dataRows) }
            { emissions:_run-data-types-qc($qcs/qc[@id="qc4"], $model, $dataRows) }
            { emissions:_run-codelists-qc($qcs/qc[@id="qc5"], $model, $dataRows) }
            { emissions:_run-spatial-unit-id-format-qc($qcs/qc[@id="qc6a"], $model, $envelope, $dataRows) }
            { emissions:_run-spatial-unit-id-reference-qc($qcs/qc[@id="qc6b"], $model, $vocabularySpatialUnits, $dataRows) }
            { emissions:_run-spatial-unit-id-scheme-qc($qcs/qc[@id="qc7"], $model, $dataRows) }
            { emissions:_run-time-reference-period-qc($qcs/qc[@id="qc8"], $model, $dataFlowCycles, $dataRows) }
            { emissions:_run-unit-of-measure-qc($qcs/qc[@id="qc9"], $model, $vocabularyUom, $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $dataRows) }
            { emissions:_run-emissions-method-qc($qcs/qc[@id="qc10"], $model, $dataRows) }
        </div>
    return 
        <div class="feedbacktext">
            { html:getCss() }
            { html:getJavascript() }
            <div>
                { uiutil:build-header-and-menu-markup("WISE SoE - Emissions", "Emissions from point and diffuse sources", $qcs, $qcResultsMarkup) }
                { $qcResultsMarkup }
            </div>
        </div>
};

declare function emissions:getQcMetadata(
    $model as element(model),
    $envelope as element(envelope),
    $dataFlowCycles as element(DataFlows)
)
as element(qcs)
{
    <qcs>
        { emissions:_get-mandatory-qc-metadata($model) }
        { emissions:_get-conditional-mandatory-qc-metadata() }
        { emissions:_get-duplicate-rows-qc-metadata($model) }
        { emissions:_get-data-types-qc-metadata($model) }
        { emissions:_get-codelists-qc-metadata($model) }
        { emissions:_get-spatial-unit-id-format-qc-metadata($envelope) }
        { emissions:_get-spatial-unit-id-reference-qc-metadata() }
        { emissions:_get-spatial-unit-id-scheme-qc-metadata() }
        { emissions:_get-time-reference-period-qc-metadata($dataFlowCycles) }
        { emissions:_get-unit-of-measure-qc-metadata() }
        { emissions:_get-emissions-method-qc-metadata() }
    </qcs>
};

declare function emissions:_get-mandatory-qc-metadata($model as element(model))
as element(qc)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    let $mandatoryColumnString := string-join($mandatoryColumns/meta:get-column-name(.), ", ")
    return
        <qc id="qc1">
            <caption>1. Mandatory values test</caption>
            <description>
                Tested the presence of mandatory values - { $mandatoryColumnString }.
            </description>
            <onSuccess>
                <message>OK - data passed the test.</message>
            </onSuccess>
            <onBlocker>
                <message>BLOCKER - some mandatory values are missing.</message>
            </onBlocker>
        </qc>
};

declare function emissions:_get-conditional-mandatory-qc-metadata()
as element(qc)
{
    <qc id="qc2">
        <caption>2. Conditional mandatory values test</caption>
        <description>
            Tested presence of values which are mandatory under certain conditions.
            <ol>
                <li>
                    The parameterEPRTRfacilities value must be present for emissions from those point sources, which are relevant for E-PRTR reporting (PT, U, U2, U22, U23, U24, I, I3, I4, O, O1, O2, O3, O4).
                </li>
                <li>
                    The resultEmissionsValue can be empty only if an appropriate resultObservationStatus flag is used to explain the reason.
                </li>
            </ol>
        </description>
        <columnExceptions>
            <columnException columnName="parameterEPRTRfacilities" onMatch="{ $qclevels:OK }">
                <dependencies>
                    <dependency columnName="parameterEmissionsSourceCategory">
                        <acceptedValues not="true">
                            <value>PT</value>
                            <value>U</value>
                            <value>U2</value>
                            <value>U22</value>
                            <value>U23</value>
                            <value>U24</value>
                            <value>I</value>
                            <value>I3</value>
                            <value>I4</value>
                            <value>O</value>
                            <value>O1</value>
                            <value>O2</value>
                            <value>O3</value>
                            <value>O4</value>
                        </acceptedValues>
                    </dependency>
                </dependencies>
            </columnException>
            <columnException columnName="resultEmissionsValue" onMatch="{ $qclevels:INFO }">
                <dependencies>
                    <dependency columnName="resultObservationStatus">
                        <acceptedValues>
                            <value>O</value>
                            <value>M</value>
                            <value>L</value>
                            <value>N</value>
                            <value>W</value>
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

declare function emissions:_get-duplicate-rows-qc-metadata($model as element(model))
as element(qc)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $keyColumnsList := string-join($keyColumns/meta:get-column-name(.), ", ")
    return
        <qc id="qc3">
            <caption>3. Record uniqueness test</caption>
            <description>Tested uniqueness of the records.  Combination of the values { $keyColumnsList } must be unique for each record in the table. No multiplicities can exist.</description>
            <onSuccess>
                <message>OK - data passed the test.</message>
            </onSuccess>
            <onBlocker>
                <message>BLOCKER - multiplicities have been detected.</message>
            </onBlocker>
        </qc>
};

declare function emissions:_get-data-types-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="qc4">
        <caption>4. Data types test</caption>
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

declare function emissions:_get-codelists-qc-metadata($model as element(model))
as element(qc)
{
    let $codelistColumns := meta:get-valuelist-columns($model)
    let $codelistColumnsString := string-join($codelistColumns/meta:get-column-name(.), ", ")
    return
        <qc id="qc5">
            <caption>5. Valid codes test</caption>
            <description>
                Tested the correctness of values against the respective codelists. Checked values are { $codelistColumnsString }.
                <br/><br/>
                Due to the ongoing reporting of WFD data, which includes also update of the RBDs, the detected discrepancies in spatialUnitIdentifier values are currently not considered as errors. They will be considered as blocker errors in the future reporting cycles.
            </description>
            <codelistExceptions>
                <codelistException columnName="spatialUnitIdentifier" onMatch="{ $qclevels:WARNING }" />
            </codelistExceptions>
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
                <url columnName="spatialUnitIdentifier" value="http://dd.eionet.europa.eu/vocabulary/wise/SpatialUnit/view" />
                <url columnName="spatialUnitIdentifierScheme" value="http://dd.eionet.europa.eu/vocabulary/wise/IdentifierScheme/view" />
                <url columnName="observedPropertyDeterminandCode" value="http://dd.eionet.europa.eu/vocabulary/wise/ObservedProperty/view" />
                <url columnName="parameterEmissionsSourceCategory" value="http://dd.eionet.europa.eu/vocabulary/wise/EmissionsSourceCategory/view" />
                <url columnName="parameterEPRTRfacilities" value="http://dd.eionet.europa.eu/fixedvalues/elem/76302" />
                <url columnName="resultEmissionsUom" value="http://dd.eionet.europa.eu/vocabulary/wise/UomEmissions/view" />
                <url columnName="procedureEmissionsMethod" value="http://dd.eionet.europa.eu/fixedvalues/elem/79309" />
                <url columnName="resultObservationStatus" value="http://dd.eionet.europa.eu/fixedvalues/elem/77669" />
            </codelistUrls>
        </qc>
};

declare function emissions:_get-spatial-unit-id-format-qc-metadata($envelope as element(envelope))
as element(qc)
{
    let $countryCode := valconv:convertCountryCode($envelope/countrycode)
    return
        <qc id="qc6a">
            <caption>6.1 Spatial unit identifier format test</caption>
            <description>
                Tested correctness of the spatialUnitIdentifier value format:
                <ol>
                    <li>
                        The country code part of the identifier value must match the one of the reporting country { $countryCode }
                    </li>
                    <li>
                        <![CDATA[
                        If it is not a country code, the identifier value can't contain punctuation marks, white space or other special characters, including accented characters, except for "-" or "_". Presence of two or more consecutive "-" or "_" characters ("--" or "__"), or their combination ("_-" or "-_"), is however not allowed. The identifier value must use only upper case letters. The third character, following the 2-letter country code, and the last character can't be "-" or "_". The total length of the identifier can't exceed 42 characters. (Regular expressions: ^[A-Z]{2}[0-9A-Z]{1}([0-9A-Z_\-]{0,38}[0-9A-Z]{1}){0,1}$ and ^([A-Z0-9](\-|_)?)+$)
                        ]]>
                    </li>
                    <li>
                        <![CDATA[
                        If it is a country code, the identifier values must use upper case letters and can't be longer than 2 characters. (Regular expression: ^[A-Z]{2}$)
                        ]]>
                    </li>
                </ol>
            </description>
            <onSuccess>
                <message>OK - data passed the test.</message>
            </onSuccess>
            <onBlocker>
                <message>
                    BLOCKER - some of the spatialUnitIdentifier values are either incorrectly formated or identify spatial units that belong to a different country.
                </message>
            </onBlocker>
        </qc>
};

declare function emissions:_get-spatial-unit-id-reference-qc-metadata()
as element(qc)
{
    <qc id="qc6b">
        <caption>6.2 Spatial unit identifier reference test</caption>
        <description>
            Tested presence of the spatialUnitIdentifier and its respective spatialUnitIdentifierScheme in the <a target="_blank" href="http://dd.eionet.europa.eu/vocabulary/wise/SpatialUnit">official reference list</a>. The list has been created from the previously reported data on water bodies.
            <br/><br/>
            Due to the ongoing reporting of WFD data, which includes also update of the RBDs, the detected discrepancies are currently not considered as errors. They will be considered as blocker errors in the future reporting cycles.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onWarning>
            <message>
                WARNING - some of the spatialUnitIdentifier values are missing in the reference list. Please assure that it is not due to an error and that they are reported under WFD, or report them under WISE Spatial data reporting.
            </message>
        </onWarning>
    </qc>
};

declare function emissions:_get-spatial-unit-id-scheme-qc-metadata()
as element(qc)
{
    <qc id="qc7">
        <caption>7. Spatial unit identifier scheme test</caption>
        <description>
            Tested correctness of spatialUnitIdentifierScheme value. The allowable values are countryCode,  euRBDCode, euSubUnitCode, eionetRBDCode and eionetSubUnitCode.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported spatialUnitIdentifierScheme values are not allowed.
            </message>
        </onBlocker>
    </qc>
};

declare function emissions:_get-time-reference-period-qc-metadata($dataFlowCycles as element(DataFlows))
as element(qc)
{
    let $dataFlowCycle := vldemisemistrefprd:get-data-flow-cycle($dataFlowCycles)
    let $yearStart := vldemisemistrefprd:get-start-year($dataFlowCycle)
    let $yearEnd := vldemisemistrefprd:get-end-year($dataFlowCycle)
    return
        <qc id="qc8">
            <caption>8. Time reference period test</caption>
            <description>
                Tested whether the phenomenonTimeReferencePeriod value:
                <ol>
                    <li>is provided in the requested format (YYYY or YYYY--YYYY);</li>
                    <li>if reported as a period, the starting year is not higher than ending year</li>
                    <li>values are from the expected range ({ $yearStart } - { $yearEnd })</li>
                </ol>
            </description>
            <onSuccess>
                <message>OK - data passed the test.</message>
            </onSuccess>
            <onBlocker>
                <message>
                    BLOCKER - some of the reported phenomenonTimeReferencePeriod do not follow the criteria.
                </message>
            </onBlocker>
        </qc>
};

declare function emissions:_get-unit-of-measure-qc-metadata()
as element(qc)
{
    <qc id="qc9">
        <caption>9. Unit of measure test</caption>
        <description>
            Tested whether corect resultEmissionsUom Values have been used for the observed determinands (only kg/a and t/a are expected). The test also detects determinands which are not expected to be reported in this table.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - incorrect resultEmissionsUom values have been reported for some of the determinands or unexpected determinands have been reported.
            </message>
        </onBlocker>
    </qc>
};

declare function emissions:_get-emissions-method-qc-metadata()
as element(qc)
{
    <qc id="qc10">
        <caption>10. Emissions method test</caption>
        <description>
            Tested whether procedureEmissionsMethod has been used correctly:
            <ol>
                <li>Methods calculated, estimated and measured are allowed for point sources.</li>
                <li>Methods estimated and modelled  are allowed for diffuse sources.</li>
            </ol>
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some procedureEmissionsMethod values have been used for incorrect parameterEmissionsSourceCategory.
            </message>
        </onBlocker>
    </qc>
};

declare function emissions:_run-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $columnExceptions, $dataRows)
    let $colunsToDisplay := $model/columns/column
    return uimandatory:build-mandatory-column-qc-markup($qc, $colunsToDisplay, $validationResult)
};

declare function emissions:_run-conditional-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $mandatoryColumns := meta:get-columns-by-names($model, ('parameterEPRTRfacilities', 'resultEmissionsValue'))
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $mandatoryColumns, $columnExceptions, $dataRows)
    let $colunsToDisplay := $model/columns/column
    return uimandatory:build-mandatory-column-qc-markup($qc, $colunsToDisplay, $validationResult)
};

declare function emissions:_run-duplicate-rows-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $validationResult := vldduplicates:validate-duplicate-rows($dataRows, $keyColumns)
    let $columnsToDisplay := $model/columns/column
    return uiduplicates:build-duplicate-rows-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function emissions:_run-data-types-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $typeExceptions := $qc/typeExceptions
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtypes:validate-data-types($model, $dataRows, $typeExceptions)
    return uitypes:build-data-types-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function emissions:_run-codelists-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $exceptions := $qc/codelistExceptions/*
    let $columnsToDisplay := $model/columns/column
    let $codelistUrls := $qc/codelistUrls
    let $validationResult :=  vldclist:validate-codelists($model, $exceptions, $dataRows)
    return uiclist:build-codelists-markup($qc, $model, $columnsToDisplay, $codelistUrls, $validationResult)
};

declare function emissions:_run-spatial-unit-id-format-qc($qc as element(qc), $model as element(model), $envelope as element(envelope), $dataRows as element(dataRow)*)
as element(div)
{
    let $columnSpatialUnitId := $model/columns/column[meta:get-column-name(.) = 'spatialUnitIdentifier']
    let $columnSpatialUnitIdScheme := $model/columns/column[meta:get-column-name(.) = 'spatialUnitIdentifierScheme']
    let $validationResult :=  vldspunitid:validate-spatial-unit-identifier-format($columnSpatialUnitId, $columnSpatialUnitIdScheme, $envelope, $dataRows)
    return uispunitid:build-spatial-unit-id-format-qc-markup($qc, $columnSpatialUnitId, $columnSpatialUnitIdScheme, $validationResult)
};

declare function emissions:_run-spatial-unit-id-reference-qc(
    $qc as element(qc), 
    $model as element(model), 
    $vocabularySpatialUnits as element(), 
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnSpatialUnitId := $model/columns/column[meta:get-column-name(.) = 'spatialUnitIdentifier']
    let $columnSpatialUnitIdScheme := $model/columns/column[meta:get-column-name(.) = 'spatialUnitIdentifierScheme']
    let $validationResult :=  vldspunitid:validate-spatial-unit-identifier-reference($columnSpatialUnitId, $columnSpatialUnitIdScheme, $vocabularySpatialUnits, $dataRows)
    return uispunitid:build-spatial-unit-id-reference-qc-markup($qc, $columnSpatialUnitId, $columnSpatialUnitIdScheme, $validationResult)
};

declare function emissions:_run-spatial-unit-id-scheme-qc(
    $qc as element(qc),
    $model as element(model),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnSpatialUnitIdentifierScheme := $model/columns/column[meta:get-column-name(.) = 'spatialUnitIdentifierScheme']
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldspunitidsch:validate-spatial-unit-identifier-scheme($columnSpatialUnitIdentifierScheme, $dataRows)
    return uispunitidsch:build-spatial-unit-identifier-scheme-qc-markup($qc, $columnSpatialUnitIdentifierScheme, $columnsToDisplay, $validationResult)
};

declare function emissions:_run-time-reference-period-qc(
    $qc as element(qc), 
    $model as element(model),
    $dataFlowCycles as element(DataFlows),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldemisemistrefprd:validate-time-reference-period($model, $dataFlowCycles, $dataRows)
    return uiemisemistrefprd:build-time-reference-period-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function emissions:_run-unit-of-measure-qc(
    $qc as element(qc), 
    $model as element(model),
    $vocabularyUom as element(),
    $vocabularyObservedProperty as element(),
    $vocabularyCombinationTableDeterminandUom as element(), 
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnResultUom := $model/columns/column[meta:get-column-name(.) = 'resultEmissionsUom']
    let $columnObservedPropertyDeterminandCode := $model/columns/column[meta:get-column-name(.) = 'observedPropertyDeterminandCode']
    let $tableName := "http://dd.eionet.europa.eu/vocabulary/datadictionary/ddTables/WISE-SoE_Emissions.Emissions"
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vlduom:validate-unit-of-measure($columnResultUom, $columnObservedPropertyDeterminandCode, $tableName, 
            $vocabularyUom, $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $dataRows)
    return uiuom:build-unit-of-measure-qc-markup($qc, $columnResultUom, $columnObservedPropertyDeterminandCode, $tableName, $vocabularyUom, 
                $vocabularyObservedProperty, $vocabularyCombinationTableDeterminandUom, $columnsToDisplay, $validationResult)
};

declare function emissions:_run-emissions-method-qc(
    $qc as element(qc),
    $model as element(model),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldemisemismethod:validate-emissions-method($model, $dataRows)
    return uiemisemismethod:build-emissions-method-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};
