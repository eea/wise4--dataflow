xquery version "1.0" encoding "UTF-8";

module namespace emissions_directdischarges = 'http://converters.eionet.europa.eu/wise/emissions/directdischarges';

import module namespace interop = "http://converters.eionet.europa.eu/common/interop" at "../../common/interop.xquery";
import module namespace meta = "http://converters.eionet.europa.eu/common/meta" at "../../common/meta.xquery";
import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../common/data.xquery";
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../common/qclevels.xquery';
import module namespace valconv = "http://converters.eionet.europa.eu/common/valueConversion" at "../../common/value-conversion.xquery";

import module namespace vldmandatory = "http://converters.eionet.europa.eu/common/validators/mandatory" at "../../common/validators/mandatory.xquery";
import module namespace vldduplicates = 'http://converters.eionet.europa.eu/common/validators/duplicates' at "../../common/validators/duplicates.xquery";
import module namespace vldtypes = 'http://converters.eionet.europa.eu/common/validators/types' at "../../common/validators/types.xquery";
import module namespace vldclist = 'http://converters.eionet.europa.eu/common/validators/codelist' at "../../common/validators/codelist.xquery";
import module namespace vldwbodyid = 'http://converters.eionet.europa.eu/wise/common/validators/waterBodyIdentifier' at '../../wise-common/validators/vld-water-body-identifier.xquery';
import module namespace vldrefyear = 'http://converters.eionet.europa.eu/wise/common/validators/referenceYear' at '../../wise-common/validators/vld-reference-year.xquery';

import module namespace html = 'http://converters.eionet.europa.eu/common/ui/html' at "../../common/ui/html-scripts.xquery";
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at "../../common/ui/util.xquery";

import module namespace uimandatory = "http://converters.eionet.europa.eu/common/ui/mandatory" at "../../common/ui/mandatory.xquery";
import module namespace uiduplicates = 'http://converters.eionet.europa.eu/common/ui/duplicates' at "../../common/ui/duplicates.xquery";
import module namespace uitypes = 'http://converters.eionet.europa.eu/common/ui/types' at "../../common/ui/types.xquery";
import module namespace uiclist = 'http://converters.eionet.europa.eu/common/ui/codelist' at "../../common/ui/codelist.xquery";
import module namespace uiwbodyid = 'http://converters.eionet.europa.eu/wise/common/ui/waterBodyIdentifier' at '../../wise-common/ui/ui-water-body-identifier.xquery';
import module namespace uirefyear = 'http://converters.eionet.europa.eu/wise/common/ui/referenceYear' at '../../wise-common/ui/ui-reference-year.xquery';

declare variable $emissions_directdischarges:TABLE-ID := "11075";

declare function emissions_directdischarges:run-checks($sourceUrl as xs:string)
as element(div)
{
    let $fullDoc := doc($sourceUrl)
    let $dataDoc := $fullDoc//*:DirectDischarges

    let $model := meta:get-table-metadata($emissions_directdischarges:TABLE-ID)
    let $envelope := interop:get-envelope-metadata($sourceUrl)
    let $dataFlowCycles := doc("http://converters.eionet.europa.eu/xmlfile/dataflow_cycles.xml")/*
    let $vocabularyWaterBodies := doc("../xmlfile/2017_WaterBody.rdf")/*
    return emissions_directdischarges:run-checks($dataDoc, $model, $envelope, $dataFlowCycles, $vocabularyWaterBodies)
};

declare function emissions_directdischarges:run-checks(
    $dataDoc as element()*,
    $model as element(model),
    $envelope as element(envelope),
    $dataFlowCycles as element(DataFlows),
    $vocabularyWaterBodies as element()
)
as element(div)
{
    let $qcs := emissions_directdischarges:getQcMetadata($model, $envelope, $dataFlowCycles)
    let $dataRows := data:get-rows($dataDoc)
    let $qcResultsMarkup :=
        <div>
            { emissions_directdischarges:_run-mandatory-field-qc($qcs/qc[@id="eddqc1"], $model, $dataRows) }
            { emissions_directdischarges:_run-duplicate-rows-qc($qcs/qc[@id="eddqc2"], $model, $dataRows) }
            { emissions_directdischarges:_run-data-types-qc($qcs/qc[@id="eddqc3"], $model, $dataRows) }
            { emissions_directdischarges:_run-codelists-qc($qcs/qc[@id="eddqc4"], $model, $dataRows) }
            { emissions_directdischarges:_run-water-body-id-format-qc($qcs/qc[@id="eddqc5a"], $model, $envelope, $dataRows) }
            { emissions_directdischarges:_run-water-body-id-reference-qc($qcs/qc[@id="eddqc5b"], $model, $vocabularyWaterBodies, $dataRows) }
            { emissions_directdischarges:_run-reference-year-qc($qcs/qc[@id="eddqc6"], $model, $dataFlowCycles, $dataRows) }
        </div>
    return
        <div class="feedbacktext">
            { html:getCss() }
            { html:getJavascript() }
            <div>
                { uiutil:build-header-and-menu-markup("WISE SoE - Emissions", "DirectDischarges", $qcs, $qcResultsMarkup) }
                { $qcResultsMarkup }
            </div>
        </div>
};

declare function emissions_directdischarges:getQcMetadata(
    $model as element(model),
    $envelope as element(envelope),
    $dataFlowCycles as element(DataFlows)
)
as element(qcs)
{
    <qcs>
        { emissions_directdischarges:_get-mandatory-qc-metadata($model) }
        { emissions_directdischarges:_get-duplicate-rows-qc-metadata($model) }
        { emissions_directdischarges:_get-data-types-qc-metadata($model) }
        { emissions_directdischarges:_get-codelists-qc-metadata($model) }
        { emissions_directdischarges:_get-body-water-id-format-qc-metadata($model, $envelope) }
        { emissions_directdischarges:_get-body-water-id-reference-qc-metadata($model) }
        { emissions_directdischarges:_get-reference-year-qc-metadata($dataFlowCycles) }
    </qcs>
};

declare function emissions_directdischarges:_get-mandatory-qc-metadata($model as element(model))
as element(qc)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    let $mandatoryColumnString := string-join($mandatoryColumns/meta:get-column-name(.), ", ")
    let $exceptionColumnNames := ("resultEmissionsValue", "resultEmissionsUom")
    let $dependencyColumnName := "resultObservationStatus"

    return
        <qc id="eddqc1">
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
                                <value>W</value>
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

declare function emissions_directdischarges:_get-duplicate-rows-qc-metadata($model as element(model))
as element(qc)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $keyColumnsList := string-join($keyColumns/meta:get-column-name(.), ", ")
    return
        <qc id="eddqc2">
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

declare function emissions_directdischarges:_get-data-types-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="eddqc3">
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

declare function emissions_directdischarges:_get-codelists-qc-metadata($model as element(model))
as element(qc)
{
    let $codelistColumns := meta:get-valuelist-columns($model)
    let $codelistColumnsString := string-join($codelistColumns/meta:get-column-name(.), ", ")
    return
        <qc id="eddqc4">
            <caption>4. Valid codes test</caption>
            <description>
                Tested the correctness of values against the respective codelists. Checked values are { $codelistColumnsString }.
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
                <url columnName="waterBodyIdentifierScheme" value="http://dd.eionet.europa.eu/fixedvalues/elem/75872" />
                <url columnName="observedPropertyDeterminandCode" value="http://dd.eionet.europa.eu/vocabulary/wise/ObservedProperty/view" />
                <url columnName="resultEmissionsUom" value="http://dd.eionet.europa.eu/vocabulary/wise/UomEmissions/view" />
                <url columnName="procedureEstimateDetail" value="http://dd.eionet.europa.eu/fixedvalues/elem/92771" />
                <url columnName="parameterEmissionsSourceCategory" value="http://dd.eionet.europa.eu/vocabulary/wise/EmissionsSourceCategory/view" />
                <url columnName="resultObservationStatus" value="http://dd.eionet.europa.eu/fixedvalues/elem/95711" />
            </codelistUrls>
        </qc>
};

declare function emissions_directdischarges:_get-body-water-id-format-qc-metadata($model as element(model), $envelope as element(envelope))
as element(qc)
{
    let $countryCode := valconv:convertCountryCode($envelope/countrycode)
    return
        <qc id="eddqc5a">
            <caption>5.1 Water body identifier format test</caption>
            <description>
                Tested correctness of the waterBodyIdentifier value format:
                <ol>
                    <li>
                        The country code part of the identifier value must match the one of the reporting country { $countryCode }, except use "UK" instead of "GB" and use "EL" instead of "GR".
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
                <message>
                    BLOCKER - some of the waterBodyIdentifier values are either incorrectly formated or identify water bodies that belong to a different country.
                </message>
            </onBlocker>
        </qc>
};

declare function emissions_directdischarges:_get-body-water-id-reference-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="eddqc5b">
        <caption>5.2 Water body identifier reference test</caption>
        <description>
            Tested presence of the waterBodyIdentifier, and its respective waterBodyIdentifierScheme, in the <a target="_blank" href="http://dd.eionet.europa.eu/vocabulary/wise/WaterBody">official reference list</a>. The list has been created from the previously reported data on water bodies.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onWarning>
            <message>
                WARNING - some of the waterBodyIdentifier values are missing in the reference list. Please assure that it is not due to an error and that they are reported under WFD, or report them under WISE Spatial data reporting.
            </message>
        </onWarning>
        <onBlocker>
            <message>
                BLOCKER - some of the waterBodyIdentifier values are missing in the reference list. Please assure that it is not due to an error and that they are reported under WFD, or report them under WISE Spatial data reporting.
            </message>
        </onBlocker>

    </qc>
};

declare function emissions_directdischarges:_get-reference-year-qc-metadata($dataFlowCycles as element(DataFlows))
as element(qc)
{
    let $dataFlowCycle := vldrefyear:get-data-flow-cycle_emission_2017($dataFlowCycles)
    let $yearStart := vldrefyear:get-start-year($dataFlowCycle)
    let $yearEnd := vldrefyear:get-end-year($dataFlowCycle)
    return
        <qc id="eddqc6">
            <caption>6. Reference year test</caption>
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
            <onBlocker>
                <message>
                    BLOCKER - some of the reported phenomenonTimeReferenceYear values are outside the expected range. The detected records will not be processed.
                </message>
            </onBlocker>
        </qc>
};

declare function emissions_directdischarges:_run-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $columnExceptions, $dataRows)
    let $colunsToDisplay := $model/columns/column
    return uimandatory:build-mandatory-column-qc-markup($qc, $colunsToDisplay, $validationResult)
};

declare function emissions_directdischarges:_run-conditional-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $mandatoryColumns := meta:get-columns-by-names($model, ('resultEmissionsValue'))
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $mandatoryColumns, $columnExceptions, $dataRows)
    let $colunsToDisplay := $model/columns/column
    return uimandatory:build-mandatory-column-qc-markup($qc, $colunsToDisplay, $validationResult)
};

declare function emissions_directdischarges:_run-duplicate-rows-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $validationResult := vldduplicates:validate-duplicate-rows($dataRows, $keyColumns)
    let $columnsToDisplay := $model/columns/column
    return uiduplicates:build-duplicate-rows-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function emissions_directdischarges:_run-data-types-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $typeExceptions := $qc/typeExceptions
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtypes:validate-data-types($model, $dataRows, $typeExceptions)
    return uitypes:build-data-types-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function emissions_directdischarges:_run-codelists-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $exceptions := $qc/codelistExceptions/*
    let $columnsToDisplay := $model/columns/column
    let $codelistUrls := $qc/codelistUrls
    let $validationResult :=  vldclist:validate-codelists($model, $exceptions, $dataRows)
    return uiclist:build-codelists-markup($qc, $model, $columnsToDisplay, $codelistUrls, $validationResult)
};

declare function emissions_directdischarges:_run-water-body-id-format-qc(
        $qc as element(qc),
        $model as element(model),
        $envelope as element(envelope),
        $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnWaterBodyId := $model/columns/column[meta:get-column-name(.) = 'waterBodyIdentifier']
    let $columnWaterBowyIdScheme := $model/columns/column[meta:get-column-name(.) = 'waterBodyIdentifierScheme']
    let $validationResult := vldwbodyid:validate-water-body-identifier-format($columnWaterBodyId, $envelope, $dataRows)
    return uiwbodyid:build-water-body-id-reference-qc-markup($qc, $columnWaterBodyId, $columnWaterBowyIdScheme, $validationResult)
};

declare function emissions_directdischarges:_run-water-body-id-reference-qc(
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

declare function emissions_directdischarges:_run-reference-year-qc(
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