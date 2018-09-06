xquery version "1.0" encoding "UTF-8";

module namespace wqnresvdata = 'http://converters.eionet.europa.eu/wise/waterQuantity/reservoirData';

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
import module namespace vldtrefperiod = 'http://converters.eionet.europa.eu/wise/common/validators/timeReferencePeriod' at '../../wise-common/validators/vld-time-reference-period.xquery';
import module namespace vldvallim = "http://converters.eionet.europa.eu/wise/common/validators/valueLimits" at '../../wise-common/validators/vld-value-limits.xquery';
import module namespace vldwqnobsvallim = "http://converters.eionet.europa.eu/wise/waterQuantity/common/validators/observedValueLimits" at '../common/validators/vld-observed-value-limits.xquery';

import module namespace html = 'http://converters.eionet.europa.eu/common/ui/html' at "../../common/ui/html-scripts.xquery";
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at "../../common/ui/util.xquery";

import module namespace uimandatory = "http://converters.eionet.europa.eu/common/ui/mandatory" at "../../common/ui/mandatory.xquery";
import module namespace uiduplicates = 'http://converters.eionet.europa.eu/common/ui/duplicates' at "../../common/ui/duplicates.xquery";
import module namespace uitypes = 'http://converters.eionet.europa.eu/common/ui/types' at "../../common/ui/types.xquery";
import module namespace uiclist = 'http://converters.eionet.europa.eu/common/ui/codelist' at "../../common/ui/codelist.xquery";
import module namespace uiwbodyid = 'http://converters.eionet.europa.eu/wise/common/ui/waterBodyIdentifier' at '../../wise-common/ui/ui-water-body-identifier.xquery';
import module namespace uitrefperiod = 'http://converters.eionet.europa.eu/wise/common/ui/timeReferencePeriod' at '../../wise-common/ui/ui-time-reference-period.xquery';
import module namespace uiwqnobsvallim = "http://converters.eionet.europa.eu/wise/waterQuantity/common/ui/observedValueLimits" at '../common/ui/ui-observed-value-limits.xquery';

declare variable $wqnresvdata:TABLE-ID := "9708";

declare function wqnresvdata:run-checks($sourceUrl as xs:string)
as element(div)
{
    let $dataDoc := doc($sourceUrl)/*:ReservoirData
    let $model := meta:get-table-metadata($wqnresvdata:TABLE-ID)
    let $envelope := interop:get-envelope-metadata($sourceUrl)
    let $vocabularySurfaceWaterBodies := doc("../xmlfile/SurfaceWaterBody.rdf")/*
    let $dataFlowCycles := doc("http://converters.eionet.europa.eu/xmlfile/dataflow_cycles.xml")/*
    let $limitDefinitions := doc("http://converters.eionet.europa.eu/xmlfile/wise_soe_determinand_value_limits.xml")/*
    return wqnresvdata:run-checks($dataDoc, $model, $envelope, $vocabularySurfaceWaterBodies, $dataFlowCycles, $limitDefinitions)
};

declare function wqnresvdata:run-checks(
    $dataDoc as element()*,
    $model as element(model), 
    $envelope as element(envelope),
    $vocabularySurfaceWaterBodies as element(),
    $dataFlowCycles as element(DataFlows),
    $limitDefinitions as element(WiseSoeQc)
)
as element(div)
{
    let $qcs := wqnresvdata:getQcMetadata($model, $envelope, $dataFlowCycles)
    let $dataRows := data:get-rows($dataDoc)
    let $qcResultsMarkup := 
        <div>
            { wqnresvdata:_run-mandatory-field-qc($qcs/qc[@id="qc1"], $model, $dataRows) }
            { wqnresvdata:_run-duplicate-rows-qc($qcs/qc[@id="qc2"], $model, $dataRows) }
            { wqnresvdata:_run-data-types-qc($qcs/qc[@id="qc3"], $model, $dataRows) }
            { wqnresvdata:_run-codelists-qc($qcs/qc[@id="qc4"], $model, $dataRows) }
            { wqnresvdata:_run-water-body-id-format-qc($qcs/qc[@id="qc5"], $model, $envelope, $dataRows) }
            { wqnresvdata:_run-water-body-id-reference-qc($qcs/qc[@id="qc6"], $model, $vocabularySurfaceWaterBodies, $dataRows) }
            { wqnresvdata:_run-time-reference-period-qc($qcs/qc[@id="qc7"], $model, $dataFlowCycles, $dataRows) }
            { wqnresvdata:_run-observed-value-limits-qc($qcs/qc[@id="qc8"], $model, $limitDefinitions, $dataRows) }
        </div>
    return 
        <div class="feedbacktext"> 
            { html:getCss() }
            { html:getJavascript() }
            <div>
                { uiutil:build-header-and-menu-markup("WISE SoE - Water Quantity", "Reservoir Data", $qcs, $qcResultsMarkup) }
                { $qcResultsMarkup }
            </div>
        </div>
};

declare function wqnresvdata:getQcMetadata(
    $model as element(model),
    $envelope as element(envelope),
    $dataFlowCycles as element(DataFlows)
)
as element(qcs)
{
    <qcs>
        { wqnresvdata:_get-mandatory-qc-metadata($model) }
        { wqnresvdata:_get-duplicate-rows-qc-metadata($model) }
        { wqnresvdata:_get-data-types-qc-metadata($model) }
        { wqnresvdata:_get-codelists-qc-metadata($model) }
        { wqnresvdata:_get-water-body-id-format-qc-metadata($envelope) }
        { wqnresvdata:_get-water-body-id-reference-qc-metadata() }
        { wqnresvdata:_get-time-reference-period-qc-metadata($dataFlowCycles) }
        { wqnresvdata:_get-observed-value-limits-qc-metadata() }
    </qcs>
};

declare function wqnresvdata:_get-mandatory-qc-metadata($model as element(model))
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

declare function wqnresvdata:_get-duplicate-rows-qc-metadata($model as element(model))
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

declare function wqnresvdata:_get-data-types-qc-metadata($model as element(model))
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

declare function wqnresvdata:_get-codelists-qc-metadata($model as element(model))
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
                <url columnName="observedProperty" value="http://dd.eionet.europa.eu/fixedvalues/elem/84111" />
                <url columnName="resultObservationStatus" value="http://dd.eionet.europa.eu/fixedvalues/elem/77669" />
            </codelistUrls>
        </qc>
};

declare function wqnresvdata:_get-water-body-id-format-qc-metadata($envelope as element(envelope))
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
                <message>
                    BLOCKER - some of the waterBodyIdentifier values are either incorrectly formated or identify sites that belong to a different country.
                </message>
            </onBlocker>
        </qc>
};

declare function wqnresvdata:_get-water-body-id-reference-qc-metadata()
as element(qc)
{
    <qc id="qc6">
        <caption>6. Water body identifier reference test</caption>
        <description>
            Tested presence of the waterBodyIdentifier and its respective waterBodyIdentifierScheme in the <a target="_blank" href="http://dd.eionet.europa.eu/vocabulary/wise/SurfaceWaterBody/">official reference list</a>. The list has been created from the previously reported data on surface water bodies.
            <br/>
            Due to the ongoing reporting of WFD data, which includes also update of the monitoring sites, the detected discrepancies are currently not considered as errors. They will be considered as blocker errors in the future reporting cycles.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onWarning>
            <message>
                WARNING - some of the waterBodyIdentifier values are missing in the reference list. Please assure that it is not due to an error and that they are reported under WFD, or report them under WISE Spatial data reporting.
            </message>
        </onWarning>
    </qc>
};

declare function wqnresvdata:_get-time-reference-period-qc-metadata($dataFlowCycles as element(DataFlows))
as element(qc)
{
    let $flowCycle := vldtrefperiod:get-data-flow-cycle($dataFlowCycles)
    let $dateStart := vldtrefperiod:get-start-date($flowCycle)
    let $dateEnd := vldtrefperiod:get-end-date($flowCycle)
    return
        <qc id="qc7">
            <caption>7. Time reference period test</caption>
            <description>
                Tested whether the phenomenonTimePeriod value:
                <ol>
                    <li>
                        is provided in the requested format (YYYY-MM-DD, YYYY-MM, YYYY or YYYY-MM--YYYY-MM);
                    </li>
                    <li>
                        is from the expected range ({ $dateStart } - { $dateEnd })
                    </li>
                    <li>
                        if reported in YYYY-MM--YYYY-MM format, it represents a quarter period (1st YYYY-01--YYYY-03, 2nd YYYY-04--YYYY-06, 3rd YYYY-07--YYYY-09, 4th YYYY-10--YYYY-12)
                    </li>
                </ol>
            </description>
            <onSuccess>
                <message>OK - data passed the test.</message>
            </onSuccess>
            <onBlocker>
                <message>
                    BLOCKER - some of the reported phenomenonTimePeriod do not follow the criteria.
                </message>
            </onBlocker>
        </qc>
};

declare function wqnresvdata:_get-observed-value-limits-qc-metadata()
as element(qc)
{
    <qc id="qc8">
        <caption>8. Observed value limits test</caption>
        <description>
            Tested whether the resultObservedValue is within the acceptable value ranges for the respective parameter.
            <br/><br/>
            Values can be confirmed as correct by providing an appropriate flag in the field resultObservationStatus. Please be aware that confirmation won't be accepted if the value defies logic (e.g. negative values)
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onInfo>
            <message>
                INFO - some of the reported resultObservedValue are outside the value range expected for the respective parameters but have been confirmed as valid in the resultObservationStatus field.
            </message>
        </onInfo>
        <onWarning>
            <message>
                WARNING - some of the reported resultObservedValue are outside the value range expected for the respective parameters.
            </message>
        </onWarning>
        <onError>
            <message>
                ERROR - some of the reported resultObservedValue are outside the value range acceptable for the respective parameters.
            </message>
        </onError>
        <onBlocker>
            <message>
                BLOCKER - some of the reported resultObservedValue are outside the value range acceptable for the respective parameters.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnresvdata:_run-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $columnExceptions, $dataRows)
    let $colunsToDisplay := $model/columns/column
    return uimandatory:build-mandatory-column-qc-markup($qc, $colunsToDisplay, $validationResult)
};

declare function wqnresvdata:_run-duplicate-rows-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $validationResult := vldduplicates:validate-duplicate-rows($dataRows, $keyColumns)
    let $columnsToDisplay := $model/columns/column
    return uiduplicates:build-duplicate-rows-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function wqnresvdata:_run-data-types-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $typeExceptions := $qc/typeExceptions
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtypes:validate-data-types($model, $dataRows, $typeExceptions)
    return uitypes:build-data-types-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function wqnresvdata:_run-codelists-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $additionalColumnNames := ("resultObservedValue", "Remarks")
    let $columnsToDisplay := $model/columns/column
    let $codelistUrls := $qc/codelistUrls
    let $validationResult :=  vldclist:validate-codelists($model, $dataRows)
    return uiclist:build-codelists-markup($qc, $model, $columnsToDisplay, $codelistUrls, $validationResult)
};

declare function wqnresvdata:_run-water-body-id-format-qc(
    $qc as element(qc), 
    $model as element(model), 
    $envelope as element(envelope), 
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnThematicId := $model/columns/column[meta:get-column-name(.) = 'waterBodyIdentifier']
    let $columnThematicIdScheme := $model/columns/column[meta:get-column-name(.) = 'waterBodyIdentifierScheme']
    let $validationResult :=  vldwbodyid:validate-water-body-identifier-format($columnThematicId, $envelope, $dataRows)
    return uiwbodyid:build-water-body-id-format-qc-markup($qc, $columnThematicId, $columnThematicIdScheme, $validationResult)
};

declare function wqnresvdata:_run-water-body-id-reference-qc(
    $qc as element(qc), 
    $model as element(model), 
    $vocabularyThematicIds as element(), 
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnThematicId := $model/columns/column[meta:get-column-name(.) = 'waterBodyIdentifier']
    let $columnThematicIdScheme := $model/columns/column[meta:get-column-name(.) = 'waterBodyIdentifierScheme']
    let $validationResult :=  vldwbodyid:validate-water-body-identifier-reference($columnThematicId, $columnThematicIdScheme, $vocabularyThematicIds, $dataRows)
    return uiwbodyid:build-water-body-id-reference-qc-markup($qc, $columnThematicId, $columnThematicIdScheme, $validationResult)
};

declare function wqnresvdata:_run-time-reference-period-qc(
    $qc as element(qc), 
    $model as element(model),
    $dataFlowCycles as element(DataFlows),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnPhenomenonTimePeriod := meta:get-column-by-name($model, "phenomenonTimePeriod")
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtrefperiod:validate-time-reference-period($columnPhenomenonTimePeriod, $dataFlowCycles, $dataRows)
    return uitrefperiod:build-time-reference-period-qc-markup($qc, $columnPhenomenonTimePeriod, $columnsToDisplay, $validationResult)
};

declare function wqnresvdata:_run-observed-value-limits-qc(
    $qc as element(qc), 
    $model as element(model),
    $limitDefinitions as element(WiseSoeQc),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $limitsList := vldvallim:get-limits($limitDefinitions, "WISE-SoE_WaterQuantity", "ReservoirData")
    let $columnResultObservedValue := meta:get-column-by-name($model, "resultObservedValue")
    let $columnObservedProperty := meta:get-column-by-name($model, "observedProperty")
    let $columnResultObservationStatus := meta:get-column-by-name($model, "resultObservationStatus")
    let $infoColumnUrl := "http://dd.eionet.europa.eu/dataelements/84111"
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldwqnobsvallim:validate-observed-value-limits($columnResultObservedValue, $columnObservedProperty, $columnResultObservationStatus, $limitsList, $dataRows)
    return uiwqnobsvallim:build-observed-value-limits-qc-markup($qc, $columnObservedProperty, $limitsList, $infoColumnUrl, $columnsToDisplay, $validationResult)
};
