xquery version "1.0" encoding "UTF-8";

module namespace wqnwaterabs = 'http://converters.eionet.europa.eu/wise/waterQuantity/waterAbstraction';

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
import module namespace vldtrefperiod = 'http://converters.eionet.europa.eu/wise/common/validators/timeReferencePeriod' at '../../wise-common/validators/vld-time-reference-period.xquery';
import module namespace vldtmprdvolsum = 'http://converters.eionet.europa.eu/wise/common/validators/timePeriodVolumeSum' at '../../wise-common/validators/vld-time-period-volume-sum.xquery';
import module namespace vldwqnrovs = "http://converters.eionet.europa.eu/wise/waterQuantity/common/validators/resultObservedValueSums" at '../common/validators/vld-result-observed-value-sums.xquery';
import module namespace vldvallim = "http://converters.eionet.europa.eu/wise/common/validators/valueLimits" at '../../wise-common/validators/vld-value-limits.xquery';
import module namespace vldwqnobsvallim = "http://converters.eionet.europa.eu/wise/waterQuantity/common/validators/observedValueLimits" at '../common/validators/vld-observed-value-limits.xquery';

import module namespace html = 'http://converters.eionet.europa.eu/common/ui/html' at "../../common/ui/html-scripts.xquery";
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at "../../common/ui/util.xquery";

import module namespace uimandatory = "http://converters.eionet.europa.eu/common/ui/mandatory" at "../../common/ui/mandatory.xquery";
import module namespace uiduplicates = 'http://converters.eionet.europa.eu/common/ui/duplicates' at "../../common/ui/duplicates.xquery";
import module namespace uitypes = 'http://converters.eionet.europa.eu/common/ui/types' at "../../common/ui/types.xquery";
import module namespace uiclist = 'http://converters.eionet.europa.eu/common/ui/codelist' at "../../common/ui/codelist.xquery";
import module namespace uispunitid = 'http://converters.eionet.europa.eu/wise/common/ui/spatialUnitIdentifier' at '../../wise-common/ui/ui-spatial-unit-identifier.xquery';
import module namespace uispunitidsch = 'http://converters.eionet.europa.eu/wise/common/ui/spatialUnitIdentifierScheme' at '../../wise-common/ui/ui-spatial-unit-identifier-scheme.xquery';
import module namespace uitrefperiod = 'http://converters.eionet.europa.eu/wise/common/ui/timeReferencePeriod' at '../../wise-common/ui/ui-time-reference-period.xquery';
import module namespace uitmprdvolsum = 'http://converters.eionet.europa.eu/wise/common/ui/timePeriodVolumeSum' at '../../wise-common/ui/ui-time-period-volume-sum.xquery';
import module namespace uiwqnobsvallim = "http://converters.eionet.europa.eu/wise/waterQuantity/common/ui/observedValueLimits" at '../common/ui/ui-observed-value-limits.xquery';

declare variable $wqnwaterabs:TABLE-ID := "9446";

declare function wqnwaterabs:run-checks($sourceUrl as xs:string)
as element(div)
{
    let $dataDoc := doc($sourceUrl)/*:WaterAbstraction
    let $model := meta:get-table-metadata($wqnwaterabs:TABLE-ID)
    let $envelope := interop:get-envelope-metadata($sourceUrl)
    let $vocabularySpatialUnits := doc("http://dd.eionet.europa.eu/vocabulary/wise/SpatialUnit/rdf")/*
    let $dataFlowCycles := doc("http://converters.eionet.europa.eu/xmlfile/dataflow_cycles.xml")/*
    let $limitDefinitions := doc("http://converters.eionet.europa.eu/xmlfile/wise_soe_determinand_value_limits.xml")/*
    return wqnwaterabs:run-checks($dataDoc, $model, $envelope, $vocabularySpatialUnits, $dataFlowCycles, $limitDefinitions)
};

declare function wqnwaterabs:run-checks(
    $dataDoc as element()*,
    $model as element(model), 
    $envelope as element(envelope),
    $vocabularySpatialUnits as element(),
    $dataFlowCycles as element(DataFlows),
    $limitDefinitions as element(WiseSoeQc)
)
as element(div)
{
    let $qcs := wqnwaterabs:getQcMetadata($model, $envelope, $dataFlowCycles)
    let $dataRows := data:get-rows($dataDoc)
    let $qcResultsMarkup := 
        <div>
            { wqnwaterabs:_run-mandatory-field-qc($qcs/qc[@id="qc1"], $model, $dataRows) }
            { wqnwaterabs:_run-duplicate-rows-qc($qcs/qc[@id="qc2"], $model, $dataRows) }
            { wqnwaterabs:_run-data-types-qc($qcs/qc[@id="qc3"], $model, $dataRows) }
            { wqnwaterabs:_run-codelists-qc($qcs/qc[@id="qc4"], $model, $dataRows) }
            { wqnwaterabs:_run-spatial-unit-id-format-qc($qcs/qc[@id="qc5a"], $model, $envelope, $dataRows) }
            { wqnwaterabs:_run-spatial-unit-id-reference-qc($qcs/qc[@id="qc5b"], $model, $vocabularySpatialUnits, $dataRows) }
            { wqnwaterabs:_run-spatial-unit-id-scheme-qc($qcs/qc[@id="qc6"], $model, $dataRows) }
            { wqnwaterabs:_run-time-reference-period-qc($qcs/qc[@id="qc7"], $model, $dataFlowCycles, $dataRows) }
            { wqnwaterabs:_run-time-period-volume-sum-qc($qcs/qc[@id="qc8"], $model, $dataRows) }
            { wqnwaterabs:_run-9-01-qc($qcs/qc[@id="qc9a"], $model, $dataRows) }
            { wqnwaterabs:_run-9-02-qc($qcs/qc[@id="qc9b"], $model, $dataRows) }
            { wqnwaterabs:_run-9-03-qc($qcs/qc[@id="qc9c"], $model, $dataRows) }
            { wqnwaterabs:_run-9-04-qc($qcs/qc[@id="qc9d"], $model, $dataRows) }
            { wqnwaterabs:_run-9-05-qc($qcs/qc[@id="qc9e"], $model, $dataRows) }
            { wqnwaterabs:_run-9-06-qc($qcs/qc[@id="qc9f"], $model, $dataRows) }
            { wqnwaterabs:_run-9-07-qc($qcs/qc[@id="qc9g"], $model, $dataRows) }
            { wqnwaterabs:_run-9-08-qc($qcs/qc[@id="qc9h"], $model, $dataRows) }
            { wqnwaterabs:_run-9-09-qc($qcs/qc[@id="qc9i"], $model, $dataRows) }
            { wqnwaterabs:_run-9-10-qc($qcs/qc[@id="qc9j"], $model, $dataRows) }
            { wqnwaterabs:_run-9-11-qc($qcs/qc[@id="qc9k"], $model, $dataRows) }
            { wqnwaterabs:_run-9-12-qc($qcs/qc[@id="qc9l"], $model, $dataRows) }
            { wqnwaterabs:_run-observed-volume-limits-qc($qcs/qc[@id="qc10"], $model, $limitDefinitions, $dataRows) }
        </div>
    return 
        <div class="feedbacktext"> 
            { html:getCss() }
            { html:getJavascript() }
            <div>
                { uiutil:build-header-and-menu-markup("WISE SoE - Water Quantity", "Water Abstraction", $qcs, $qcResultsMarkup) }
                { $qcResultsMarkup }
            </div>
        </div>
};

declare function wqnwaterabs:getQcMetadata(
    $model as element(model),
    $envelope as element(envelope),
    $dataFlowCycles as element(DataFlows)
)
as element(qcs)
{
    <qcs>
        { wqnwaterabs:_get-mandatory-qc-metadata($model) }
        { wqnwaterabs:_get-duplicate-rows-qc-metadata($model) }
        { wqnwaterabs:_get-data-types-qc-metadata($model) }
        { wqnwaterabs:_get-codelists-qc-metadata($model) }
        { wqnwaterabs:_get-spatial-unit-id-format-qc-metadata($envelope) }
        { wqnwaterabs:_get-spatial-unit-id-reference-qc-metadata() }
        { wqnwaterabs:_get-spatial-unit-id-scheme-qc-metadata() }
        { wqnwaterabs:_get-time-reference-period-qc-metadata($dataFlowCycles) }
        { wqnwaterabs:_get-time-period-volume-sum-qc-metadata() }
        { wqnwaterabs:_get-9-01-qc-metadata() }
        { wqnwaterabs:_get-9-02-qc-metadata() }
        { wqnwaterabs:_get-9-03-qc-metadata() }
        { wqnwaterabs:_get-9-04-qc-metadata() }
        { wqnwaterabs:_get-9-05-qc-metadata() }
        { wqnwaterabs:_get-9-06-qc-metadata() }
        { wqnwaterabs:_get-9-07-qc-metadata() }
        { wqnwaterabs:_get-9-08-qc-metadata() }
        { wqnwaterabs:_get-9-09-qc-metadata() }
        { wqnwaterabs:_get-9-10-qc-metadata() }
        { wqnwaterabs:_get-9-11-qc-metadata() }
        { wqnwaterabs:_get-9-12-qc-metadata() }
        { wqnwaterabs:_get-observed-volume-limits-qc-metadata() }
    </qcs>
};

declare function wqnwaterabs:_get-mandatory-qc-metadata($model as element(model))
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
                <columnException columnName="resultObservedVolume" onMatch="{ $qclevels:INFO }">
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

declare function wqnwaterabs:_get-duplicate-rows-qc-metadata($model as element(model))
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

declare function wqnwaterabs:_get-data-types-qc-metadata($model as element(model))
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

declare function wqnwaterabs:_get-codelists-qc-metadata($model as element(model))
as element(qc)
{
    let $codelistColumns := meta:get-valuelist-columns($model)
    let $codelistColumnsString := string-join($codelistColumns/meta:get-column-name(.), ", ")
    return
        <qc id="qc4">
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
                <url columnName="spatialUnitIdentifier" value="http://dd.eionet.europa.eu/vocabulary/wise/SpatialUnit/view" />
                <url columnName="spatialUnitIdentifierScheme" value="http://dd.eionet.europa.eu/vocabulary/wise/IdentifierScheme/view" />
                <url columnName="observedProperty" value="http://dd.eionet.europa.eu/fixedvalues/elem/84123" />
                <url columnName="resultObservationStatus" value="http://dd.eionet.europa.eu/fixedvalues/elem/77669" />
            </codelistUrls>
        </qc>
};

declare function wqnwaterabs:_get-spatial-unit-id-format-qc-metadata($envelope as element(envelope))
as element(qc)
{
    let $countryCode := valconv:convertCountryCode($envelope/countrycode)
    return
        <qc id="qc5a">
            <caption>5.1 Spatial unit identifier format test</caption>
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

declare function wqnwaterabs:_get-spatial-unit-id-reference-qc-metadata()
as element(qc)
{
    <qc id="qc5b">
        <caption>5.2 Spatial unit identifier reference test</caption>
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

declare function wqnwaterabs:_get-spatial-unit-id-scheme-qc-metadata()
as element(qc)
{
    <qc id="qc6">
        <caption>6. Spatial unit identifier scheme test</caption>
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

declare function wqnwaterabs:_get-time-reference-period-qc-metadata($dataFlowCycles as element(DataFlows))
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

declare function wqnwaterabs:_get-time-period-volume-sum-qc-metadata()
as element(qc)
{
    <qc id="qc8">
         <caption>8. Time period volume sum test</caption>
        <description>
            Tested whether the sum of monthly volume values doesn't exceed the corresponding annual volume value.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported annual volume values are lower than the sum of the coresponding monthly values.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnwaterabs:_get-9-01-qc-metadata()
as element(qc)
{
    <qc id="qc9a">
         <caption>
            9.01 Parameter volume mathematical relation rules test - total surface water abstraction, abstraction from artificial reservoirs
        </caption>
        <description>
            Tested whether the ABS_SW volume value isn't lower than ABS_SW_RES volume value reported from the same spatial unit and time period.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported ABS_SW_RES volume values exceed the corresponding ABS_SW volume values.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnwaterabs:_get-9-02-qc-metadata()
as element(qc)
{
    <qc id="qc9b">
         <caption>
            9.02 Parameter volume mathematical relation rules test - total surface water abstraction, abstraction from lakes
        </caption>
        <description>
            Tested whether the ABS_SW volume value isn't lower than ABS_SW_LAKE volume value reported from the same spatial unit and time period.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported ABS_SW_LAKE volume values exceed the corresponding ABS_SW volume values.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnwaterabs:_get-9-03-qc-metadata()
as element(qc)
{
    <qc id="qc9c">
         <caption>
            9.03 Parameter volume mathematical relation rules test - total surface water abstraction, abstraction from rivers
        </caption>
        <description>
            Tested whether the ABS_SW volume value isn't lower than ABS_SW_RIV volume value reported from the same spatial unit and time period.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported ABS_SW_RIV volume values exceed the corresponding ABS_SW volume values.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnwaterabs:_get-9-04-qc-metadata()
as element(qc)
{
    <qc id="qc9d">
         <caption>
            9.04 Parameter volume mathematical relation rules test - total surface water abstraction, sectoral surface water abstractions
        </caption>
        <description>
            Tested whether the ABS_SW volume value isn't lower than sum of sectoral surface water abstraction volume values (ABS_SW_NACE_A + ABS_SW_NACE_B + ABS_SW_NACE_C + ABS_SW_NACE_D + ABS_SW_NACE_E36 + ABS_SW_NACE_F + ABS_SW_NACE_I + ABS_SW_OTHER + ABS_SW_DOM) reported from the same spatial unit and time period.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported ABS_SW volume values are lower than sum of the corresponding sectoral surface water abstraction volume values.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnwaterabs:_get-9-05-qc-metadata()
as element(qc)
{
    <qc id="qc9e">
         <caption>
            9.05 Parameter volume mathematical relation rules test - surface water for NACE A, NACE_A011_A013 for irrigation, NACE_A0322 for aquaculture
        </caption>
        <description>
            Tested whether the surface water NACE A volume value isn't lower than sum of NACE_A011_A013 and NACE_A0322 volume values reported from the same spatial unit and time period.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported ABS_SW_NACE_A volume values are lower than sum of the corresponding ABS_SW_NACE_A011_A013 and ABS_SW_NACE_A0322 volume values.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnwaterabs:_get-9-06-qc-metadata()
as element(qc)
{
    <qc id="qc9f">
         <caption>
            9.06 Parameter volume mathematical relation rules test - surface water for NACE C, NACE C cooling
        </caption>
        <description>
            Tested whether the ABS_SW_NACE_C volume value isn't lower than ABS_SW_NACE_C_CL volume value reported from the same spatial unit and time period.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported ABS_SW_NACE_C_CL volume values exceed the corresponding ABS_SW_NACE_C volume values.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnwaterabs:_get-9-07-qc-metadata()
as element(qc)
{
    <qc id="qc9g">
         <caption>
            9.07 Parameter volume mathematical relation rules test - surface water for NACE D, NACE D cooling
        </caption>
        <description>
            Tested whether the ABS_SW_NACE_D volume value isn't lower than ABS_SW_NACE_D_CL volume value reported from the same spatial unit and time period.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported ABS_SW_NACE_D_CL volume values exceed the corresponding ABS_SW_NACE_D volume values.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnwaterabs:_get-9-08-qc-metadata()
as element(qc)
{
    <qc id="qc9h">
         <caption>
            9.08 Parameter volume mathematical relation rules test - surface water for NACE D, NACE D hydropower
        </caption>
        <description>
            Tested whether the ABS_SW_NACE_D volume value isn't lower than ABS_SW_NACE_D3511_HYDR volume value reported from the same spatial unit and time period.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported ABS_SW_NACE_D3511_HYDR volume values exceed the corresponding ABS_SW_NACE_D volume values.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnwaterabs:_get-9-09-qc-metadata()
as element(qc)
{
    <qc id="qc9i">
         <caption>
            9.09 Parameter volume mathematical relation rules test - total groundwater abstraction, sectoral groundwater abstractions
        </caption>
        <description>
            Tested whether the ABS_GW volume value isn't lower than sum of sectoral groundwater abstraction volume values (ABS_GW_NACE_A + ABS_GW_NACE_B + ABS_GW_NACE_C +ABS_GW_NACE_D + ABS_GW_NACE_E36 + ABS_GW_NACE_F + ABS_GW_NACE_I + ABS_GW_OTHER + ABS_GW_DOM) reported from the same spatial unit and time period.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported ABS_GW volume values are lower than sum of the corresponding sectoral groundwater abstraction volume values.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnwaterabs:_get-9-10-qc-metadata()
as element(qc)
{
    <qc id="qc9j">
         <caption>
            9.10 Parameter volume mathematical relation rules test - groundwater for NACE A, NACE_A011_A013 for irrigation, NACE_A0322 for aquaculture
        </caption>
        <description>
            Tested whether the groundwater NACE A volume value isn't lower than sum of NACE_A011_A013 and NACE_A0322 volume values reported from the same spatial unit and time period.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported ABS_GW_NACE_A volume values are lower than sum of the corresponding ABS_GW_NACE_A011_A013 and ABS_GW_NACE_A0322 volume values.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnwaterabs:_get-9-11-qc-metadata()
as element(qc)
{
    <qc id="qc9k">
         <caption>
            9.11 Parameter volume mathematical relation rules test - groundwater for NACE C, NACE C cooling
        </caption>
        <description>
            Tested whether the ABS_GW_NACE_C volume value isn't lower than ABS_GW_NACE_C_CL volume value reported from the same spatial unit and time period.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported ABS_GW_NACE_C_CL volume values exceed the corresponding ABS_GW_NACE_C volume values.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnwaterabs:_get-9-12-qc-metadata()
as element(qc)
{
    <qc id="qc9l">
         <caption>
            9.12 Parameter volume mathematical relation rules test - surface water for NACE D, NACE D cooling
        </caption>
        <description>
            Tested whether the ABS_GW_NACE_D volume value isn't lower than ABS_GW_NACE_D_CL volume value reported from the same spatial unit and time period.
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the reported ABS_GW_NACE_D_CL volume values exceed the corresponding ABS_GW_NACE_D volume values.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnwaterabs:_get-observed-volume-limits-qc-metadata()
as element(qc)
{
    <qc id="qc10">
        <caption>10. Observed volume limits test</caption>
        <description>
            Tested whether the resultObservedVolume is within the acceptable value ranges for the respective parameter.
            <br/><br/>
            Values can be confirmed as correct by providing an appropriate flag in the field resultObservationStatus. Please be aware that confirmation won't be accepted if the value defies logic (e.g. negative values)
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onInfo>
            <message>
                INFO - some of the reported resultObservedVolume are outside the value range expected for the respective parameters but have been confirmed as valid in the resultObservationStatus field.
            </message>
        </onInfo>
        <onWarning>
            <message>
                WARNING - some of the reported resultObservedVolume are outside the value range expected for the respective parameters.
            </message>
        </onWarning>
        <onError>
            <message>
                ERROR - some of the reported resultObservedVolume are outside the value range acceptable for the respective parameters.
            </message>
        </onError>
        <onBlocker>
            <message>
                BLOCKER - some of the reported resultObservedVolume are outside the value range acceptable for the respective parameters.
            </message>
        </onBlocker>
    </qc>
};

declare function wqnwaterabs:_run-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $mandatoryColumns := meta:get-mandatory-columns($model)
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $columnExceptions, $dataRows)
    let $colunsToDisplay := $model/columns/column
    return uimandatory:build-mandatory-column-qc-markup($qc, $colunsToDisplay, $validationResult)
};

declare function wqnwaterabs:_run-duplicate-rows-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $validationResult := vldduplicates:validate-duplicate-rows($dataRows, $keyColumns)
    let $columnsToDisplay := $model/columns/column
    return uiduplicates:build-duplicate-rows-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function wqnwaterabs:_run-data-types-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $typeExceptions := $qc/typeExceptions
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtypes:validate-data-types($model, $dataRows, $typeExceptions)
    return uitypes:build-data-types-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function wqnwaterabs:_run-codelists-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $columnsToDisplay := $model/columns/column
    let $codelistUrls := $qc/codelistUrls
    let $exceptions := $qc/codelistExceptions/*
    let $validationResult :=  vldclist:validate-codelists($model, $exceptions, $dataRows)
    return uiclist:build-codelists-markup($qc, $model, $columnsToDisplay, $codelistUrls, $validationResult)
};

declare function wqnwaterabs:_run-spatial-unit-id-format-qc($qc as element(qc), $model as element(model), $envelope as element(envelope), $dataRows as element(dataRow)*)
as element(div)
{
    let $columnSpatialUnitId := $model/columns/column[meta:get-column-name(.) = 'spatialUnitIdentifier']
    let $columnSpatialUnitIdScheme := $model/columns/column[meta:get-column-name(.) = 'spatialUnitIdentifierScheme']
    let $validationResult :=  vldspunitid:validate-spatial-unit-identifier-format($columnSpatialUnitId, $columnSpatialUnitIdScheme, $envelope, $dataRows)
    return uispunitid:build-spatial-unit-id-format-qc-markup($qc, $columnSpatialUnitId, $columnSpatialUnitIdScheme, $validationResult)
};

declare function wqnwaterabs:_run-spatial-unit-id-reference-qc(
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

declare function wqnwaterabs:_run-spatial-unit-id-scheme-qc(
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

declare function wqnwaterabs:_run-time-reference-period-qc(
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

declare function wqnwaterabs:_run-time-period-volume-sum-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $columnSpUnitId := meta:get-column-by-name($model, "spatialUnitIdentifier")
    let $columnSpUnitIdScheme := meta:get-column-by-name($model, "spatialUnitIdentifierScheme")
    let $columnParameter := meta:get-column-by-name($model, "observedProperty")  
    let $columnPTimePeriod := meta:get-column-by-name($model, "phenomenonTimePeriod") 
    let $columnResultObservedVolume := meta:get-column-by-name($model, "resultObservedVolume")
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtmprdvolsum:validate-time-period-volume-sum(
        $columnSpUnitId, $columnSpUnitIdScheme, $columnParameter, 
        $columnPTimePeriod, $columnResultObservedVolume, $dataRows
    )
    return uitmprdvolsum:build-time-period-volume-sum-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function wqnwaterabs:_run-result-observed-value-sums-qc(
    $qc as element(qc), 
    $model as element(model),
    $allowableParameterValues as xs:string*,
    $totalParameterValue as xs:string, 
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $columnSpUnitId := meta:get-column-by-name($model, "spatialUnitIdentifier")
    let $columnSpUnitIdScheme := meta:get-column-by-name($model, "spatialUnitIdentifierScheme")
    let $columnTimePeriod := meta:get-column-by-name($model, "phenomenonTimePeriod")
    let $columnParameter := meta:get-column-by-name($model, "observedProperty")
    let $columnResultValue := meta:get-column-by-name($model, "resultObservedVolume")
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldwqnrovs:validate-result-observed-value-sums(
        $columnSpUnitId, $columnSpUnitIdScheme, $columnTimePeriod, $columnParameter, $columnResultValue, 
        $allowableParameterValues, $totalParameterValue, $dataRows
    )
    return uiutil:build-generic-qc-markup-without-checkbox-table($qc, $columnsToDisplay, $validationResult)
};

declare function wqnwaterabs:_run-9-01-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $allowableParameterValues := ("ABS_SW_RES")
    let $totalParameterValue := "ABS_SW"
    return wqnwaterabs:_run-result-observed-value-sums-qc($qc, $model, $allowableParameterValues, $totalParameterValue, $dataRows)
};

declare function wqnwaterabs:_run-9-02-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $allowableParameterValues := ("ABS_SW_LAKE")
    let $totalParameterValue := "ABS_SW"
    return wqnwaterabs:_run-result-observed-value-sums-qc($qc, $model, $allowableParameterValues, $totalParameterValue, $dataRows)
};

declare function wqnwaterabs:_run-9-03-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $allowableParameterValues := ("ABS_SW_RIV")
    let $totalParameterValue := "ABS_SW"
    return wqnwaterabs:_run-result-observed-value-sums-qc($qc, $model, $allowableParameterValues, $totalParameterValue, $dataRows)
};

declare function wqnwaterabs:_run-9-04-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $allowableParameterValues := ("ABS_SW_NACE_A", "ABS_SW_NACE_B", "ABS_SW_NACE_C", "ABS_SW_NACE_D", "ABS_SW_NACE_E36", "ABS_SW_NACE_F", "ABS_SW_NACE_I", "ABS_SW_OTHER", "ABS_SW_DOM")
    let $totalParameterValue := "ABS_SW"
    return wqnwaterabs:_run-result-observed-value-sums-qc($qc, $model, $allowableParameterValues, $totalParameterValue, $dataRows)
};

declare function wqnwaterabs:_run-9-05-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $allowableParameterValues := ("ABS_SW_NACE_A011_A013", "ABS_SW_NACE_A0322")
    let $totalParameterValue := "ABS_SW_NACE_A"
    return wqnwaterabs:_run-result-observed-value-sums-qc($qc, $model, $allowableParameterValues, $totalParameterValue, $dataRows)
};

declare function wqnwaterabs:_run-9-06-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $allowableParameterValues := ("ABS_SW_NACE_C_CL")
    let $totalParameterValue := "ABS_SW_NACE_C"
    return wqnwaterabs:_run-result-observed-value-sums-qc($qc, $model, $allowableParameterValues, $totalParameterValue, $dataRows)
};

declare function wqnwaterabs:_run-9-07-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $allowableParameterValues := ("ABS_SW_NACE_D_CL")
    let $totalParameterValue := "ABS_SW_NACE_D"
    return wqnwaterabs:_run-result-observed-value-sums-qc($qc, $model, $allowableParameterValues, $totalParameterValue, $dataRows)
};

declare function wqnwaterabs:_run-9-08-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $allowableParameterValues := ("ABS_SW_NACE_D3511_HYDR")
    let $totalParameterValue := "ABS_SW_NACE_D"
    return wqnwaterabs:_run-result-observed-value-sums-qc($qc, $model, $allowableParameterValues, $totalParameterValue, $dataRows)
};

declare function wqnwaterabs:_run-9-09-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $allowableParameterValues := ("ABS_GW_NACE_A", "ABS_GW_NACE_B", "ABS_GW_NACE_C", "ABS_GW_NACE_D", "ABS_GW_NACE_E36", "ABS_GW_NACE_F", "ABS_GW_NACE_I", "ABS_GW_OTHER", "ABS_GW_DOM")
    let $totalParameterValue := "ABS_GW"
    return wqnwaterabs:_run-result-observed-value-sums-qc($qc, $model, $allowableParameterValues, $totalParameterValue, $dataRows)
};

declare function wqnwaterabs:_run-9-10-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $allowableParameterValues := ("ABS_GW_NACE_A011_A013", "ABS_GW_NACE_A0322")
    let $totalParameterValue := "ABS_GW_NACE_A"
    return wqnwaterabs:_run-result-observed-value-sums-qc($qc, $model, $allowableParameterValues, $totalParameterValue, $dataRows)
};

declare function wqnwaterabs:_run-9-11-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $allowableParameterValues := ("ABS_GW_NACE_C_CL")
    let $totalParameterValue := "ABS_GW_NACE_C"
    return wqnwaterabs:_run-result-observed-value-sums-qc($qc, $model, $allowableParameterValues, $totalParameterValue, $dataRows)
};

declare function wqnwaterabs:_run-9-12-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $allowableParameterValues := ("ABS_GW_NACE_D_CL")
    let $totalParameterValue := "ABS_GW_NACE_D"
    return wqnwaterabs:_run-result-observed-value-sums-qc($qc, $model, $allowableParameterValues, $totalParameterValue, $dataRows)
};

declare function wqnwaterabs:_run-observed-volume-limits-qc(
    $qc as element(qc), 
    $model as element(model),
    $limitDefinitions as element(WiseSoeQc),
    $dataRows as element(dataRow)*
)
as element(div)
{
    let $limitsList := vldvallim:get-limits($limitDefinitions, "WISE-SoE_WaterQuantity", "WaterAbstraction")
    let $columnResultObservedValue := meta:get-column-by-name($model, "resultObservedVolume")
    let $columnObservedProperty := meta:get-column-by-name($model, "observedProperty")
    let $columnResultObservationStatus := meta:get-column-by-name($model, "resultObservationStatus")
    let $infoColumnUrl := "http://dd.eionet.europa.eu/dataelements/84123"
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldwqnobsvallim:validate-observed-value-limits($columnResultObservedValue, $columnObservedProperty, $columnResultObservationStatus, $limitsList, $dataRows)
    return uiwqnobsvallim:build-observed-value-limits-qc-markup($qc, $columnObservedProperty, $limitsList, $infoColumnUrl, $columnsToDisplay, $validationResult)
};
