xquery version "1.0" encoding "UTF-8";

module namespace wqlbioeqrcp = 'http://converters.eionet.europa.eu/wise/waterQuality/biologyEqrClassificationProcedure';

import module namespace interop = "http://converters.eionet.europa.eu/common/interop" at "../../common/interop.xquery";
import module namespace meta = "http://converters.eionet.europa.eu/common/meta" at "../../common/meta.xquery";
import module namespace data = "http://converters.eionet.europa.eu/common/data" at "../../common/data.xquery";
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../common/qclevels.xquery';

import module namespace vldmandatory = "http://converters.eionet.europa.eu/common/validators/mandatory" at "../../common/validators/mandatory.xquery";
import module namespace vldduplicates = 'http://converters.eionet.europa.eu/common/validators/duplicates' at "../../common/validators/duplicates.xquery";
import module namespace vldtypes = 'http://converters.eionet.europa.eu/common/validators/types' at "../../common/validators/types.xquery";
import module namespace vldclist = 'http://converters.eionet.europa.eu/common/validators/codelist' at "../../common/validators/codelist.xquery";
import module namespace vldcountrycode = 'http://converters.eionet.europa.eu/wise/common/validators/countryCode' at '../../wise-common/validators/vld-country-code.xquery';
import module namespace vldwtrbdcat = "http://converters.eionet.europa.eu/wise/common/validators/waterBodyCategory" at '../../wise-common/validators/vld-water-body-category.xquery';
import module namespace vldwqldetwbcat = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/determinandsAndWaterBodyCategory" at "../common/validators/vld-determinands-water-body-category.xquery";
import module namespace vldwqlbioeqrcpbvmath = 'http://converters.eionet.europa.eu/wise/waterQuality/biologyEqrClassificationProcedure/validators/boundaryValuesMathRules' at './validators/vld-boundary-values-mathematical.xquery';

import module namespace html = 'http://converters.eionet.europa.eu/common/ui/html' at "../../common/ui/html-scripts.xquery";
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at "../../common/ui/util.xquery";
import module namespace uimandatory = "http://converters.eionet.europa.eu/common/ui/mandatory" at "../../common/ui/mandatory.xquery";
import module namespace uiduplicates = 'http://converters.eionet.europa.eu/common/ui/duplicates' at "../../common/ui/duplicates.xquery";
import module namespace uitypes = 'http://converters.eionet.europa.eu/common/ui/types' at "../../common/ui/types.xquery";
import module namespace uiclist = 'http://converters.eionet.europa.eu/common/ui/codelist' at "../../common/ui/codelist.xquery";
import module namespace uicountrycode = 'http://converters.eionet.europa.eu/wise/common/ui/countryCode' at '../../wise-common/ui/ui-country-code.xquery';
import module namespace uiwtrbdcat = "http://converters.eionet.europa.eu/wise/common/ui/waterBodyCategory" at '../../wise-common/ui/ui-water-body-category.xquery';
import module namespace uiwqldetwbcat = "http://converters.eionet.europa.eu/wise/waterQuality/common/ui/determinandsAndWaterBodyCategory" at "../common/ui/ui-determinands-water-body-category.xquery";
import module namespace uiwqlbioeqrcpbvmath = 'http://converters.eionet.europa.eu/wise/waterQuality/biologyEqrClassificationProcedure/ui/boundaryValuesMathRules' at './ui/ui-boundary-values-mathematical.xquery';

declare variable $wqlbioeqrcp:TABLE-ID := "9326";

declare function wqlbioeqrcp:run-checks($sourceUrl as xs:string)
as element(div)
{
    let $dataDoc := doc($sourceUrl)/*:BiologyEQRClassificationProcedure
    let $model := meta:get-table-metadata($wqlbioeqrcp:TABLE-ID)
    let $envelope := interop:get-envelope-metadata($sourceUrl)
    let $vocabularyObservedPropertyBiologyEQR := doc("http://dd.eionet.europa.eu/vocabulary/wise/ObservedPropertyBiologyEQR/rdf")/*
    return wqlbioeqrcp:run-checks($dataDoc, $model, $envelope, $vocabularyObservedPropertyBiologyEQR)
};

declare function wqlbioeqrcp:run-checks(
    $dataDoc as element()*,
    $model as element(model), 
    $envelope as element(envelope),
    $vocabularyObservedPropertyBiologyEQR as element()
)
as element(div)
{
    let $qcs := wqlbioeqrcp:getQcMetadata($model, $envelope)
    let $dataRows := data:get-rows($dataDoc)
    let $qcResultsMarkup := 
        <div>
            { wqlbioeqrcp:_run-mandatory-field-qc($qcs/qc[@id="qc1"], $model, $dataRows) }
            { wqlbioeqrcp:_run-duplicate-rows-qc($qcs/qc[@id="qc2"], $model, $dataRows) }
            { wqlbioeqrcp:_run-data-types-qc($qcs/qc[@id="qc3"], $model, $dataRows) }
            { wqlbioeqrcp:_run-codelists-qc($qcs/qc[@id="qc4"], $model, $dataRows) }
            { wqlbioeqrcp:_run-country-code-qc($qcs/qc[@id="qc5"], $model, $envelope, $dataRows) }
            { wqlbioeqrcp:_run-water-body-category-qc($qcs/qc[@id="qc6"], $model, $dataRows) }
            { wqlbioeqrcp:_run-determinands-and-water-body-category-qc($qcs/qc[@id="qc7"], $model, $vocabularyObservedPropertyBiologyEQR, $dataRows) }
            { wqlbioeqrcp:_run-boundary-values-math-rules-qc($qcs/qc[@id="qc8"], $model, $dataRows) }
        </div>
    return 
        <div class="feedbacktext"> 
            { html:getCss() }
            { html:getJavascript() }
            <div>
                { 
                    uiutil:build-header-and-menu-markup(
                        "WISE SoE - Water Quality", 
                        "Classification procedure for ecological status or potential status based on biology EQR data", 
                        $qcs, $qcResultsMarkup
                    ) 
                }
                { $qcResultsMarkup }
            </div>
        </div>
};

declare function wqlbioeqrcp:getQcMetadata($model as element(model), $envelope as element(envelope))
as element(qcs)
{
    <qcs>
        { wqlbioeqrcp:_get-mandatory-qc-metadata($model) }
        { wqlbioeqrcp:_get-duplicate-rows-qc-metadata($model) }
        { wqlbioeqrcp:_get-data-types-qc-metadata($model) }
        { wqlbioeqrcp:_get-codelists-qc-metadata($model) }
        { wqlbioeqrcp:_get-country-code-qc-metadata($envelope) }
        { wqlbioeqrcp:_get-water-body-category-qc-metadata() }
        { wqlbioeqrcp:_get-determinands-and-water-body-category-qc-metadata() }
        { wqlbioeqrcp:_get-boundary-values-math-rules-qc-metadata() }
    </qcs>
};

declare function wqlbioeqrcp:_get-mandatory-qc-metadata($model as element(model))
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
                In addition reporting of  parameterBoundaryValueClasses12, parameterBoundaryValueClasses23, parameterBoundaryValueClasses34 and parameterBoundaryValueClasses45 values is also prefered. Values parameterBoundaryValueClasses34 and parameterBoundaryValueClasses45 could be ommited for AWB and HMWB.
            </description>
            <columnExceptions>
                <columnException columnName="parameterBoundaryValueClasses12" onMatch="{ $qclevels:WARNING }" />
                <columnException columnName="parameterBoundaryValueClasses23" onMatch="{ $qclevels:WARNING }" />
                <columnException columnName="parameterBoundaryValueClasses34" onMatch="{ $qclevels:OK }" onMissmatch="{ $qclevels:WARNING }">
                    <dependencies>
                        <dependency columnName="parameterNaturalAWBHMWB">
                            <acceptedValues>
                                <value>AWB</value>
                                <value>HMWB</value>
                            </acceptedValues>
                        </dependency>
                    </dependencies>
                </columnException>
                <columnException columnName="parameterBoundaryValueClasses45" onMatch="{ $qclevels:OK }" onMissmatch="{ $qclevels:WARNING }">
                    <dependencies>
                        <dependency columnName="parameterNaturalAWBHMWB">
                            <acceptedValues>
                                <value>AWB</value>
                                <value>HMWB</value>
                            </acceptedValues>
                        </dependency>
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

declare function wqlbioeqrcp:_get-duplicate-rows-qc-metadata($model as element(model))
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
            <onWarning>
                <message>WARNING - The following records have a unique combination of the values in the fields "CountryCode", "parameterWaterBodyCategory", "observedPropertyDeterminandBiologyEQRCode" and "parameterNCSWaterBodyType". Please verify that the duplicate records have different values in the "parameterNaturalAWBHMWB" field (i.e. reflect different class boundaries established for natural, artificial or heavily modified water bodies).</message>
            </onWarning>
        </qc>
};

declare function wqlbioeqrcp:_get-data-types-qc-metadata($model as element(model))
as element(qc)
{
    <qc id="qc3">
        <caption>3. Data types test</caption>
        <description>Tested that the format of reported values matches the Data Dictionary specifications.</description>
        <typeExceptions> 
            {
                for $column in $model/columns/column[@dataType = 'string']
                return
                    <typeException columnName="{ meta:get-column-name($column) }" restrictionName="maxLength" qcResult="{ $qclevels:OK }" />
            }
            {
                for $columnName in ()
                return
                    <typeException columnName="{ $columnName }" restrictionName="maxExclusive" qcResult="{ $qclevels:WARNING }" />
            }
        </typeExceptions>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onWarning>
            <message>WARNING - some of the values are outside the expected value limits.</message>
        </onWarning>
        <onBlocker>
            <message>BLOCKER - some of the values are not in the correct format.</message>
        </onBlocker>
    </qc>
};

declare function wqlbioeqrcp:_get-codelists-qc-metadata($model as element(model))
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
                <url columnName="CountryCode" value="http://dd.eionet.europa.eu/fixedvalues/elem/67135" />
                <url columnName="observedPropertyDeterminandBiologyEQRCode" value="http://dd.eionet.europa.eu/vocabulary/wise/ObservedPropertyBiologyEQR" />
                <url columnName="parameterWaterBodyCategory" value="http://dd.eionet.europa.eu/vocabulary/wise/WFDWaterBodyCategory" />
                <url columnName="parameterWFDIntercalibrationWaterBodyType" value="http://dd.eionet.europa.eu/vocabulary/wise/WFDIntercalibrationType" />
                <url columnName="parameterNaturalAWBHMWB" value="http://dd.eionet.europa.eu/fixedvalues/elem/75915" />
                <url columnName="parameterICStatusOfDeterminandBiologyEQR" value="http://dd.eionet.europa.eu/fixedvalues/elem/76100" />
                <url columnName="resultObservationStatus" value="http://dd.eionet.europa.eu/fixedvalues/elem/77669" />
            </codelistUrls>
        </qc>
};

declare function wqlbioeqrcp:_get-country-code-qc-metadata($envelope as element(envelope))
as element(qc)
{
    <qc id="qc5">
        <caption>5. Reporting country code test</caption>
        <description>
            Tested whether the reported CountryCode matches the one of the reporting country ({ string($envelope/countrycode) })
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onBlocker>
            <message>
                BLOCKER - some of the CountryCode values are either incorrect or belong to a different country.
            </message>
        </onBlocker>
    </qc>
};

declare function wqlbioeqrcp:_get-water-body-category-qc-metadata()
as element(qc)
{
    <qc id="qc6">
        <caption>6. Water body category test</caption>
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

declare function wqlbioeqrcp:_get-determinands-and-water-body-category-qc-metadata()
as element(qc)
{
    <qc id="qc7">
        <caption>7. Determinands and Water body category test</caption>
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

declare function wqlbioeqrcp:_get-boundary-values-math-rules-qc-metadata()
as element(qc)
{
    <qc id="qc8">
        <caption>8. Boundary values - mathematical relation rules test</caption>
        <description>
            Tested mathematical relation rules between the result boundary values:
            <ol>
                <li><![CDATA[
                parameterBoundaryValueClasses12 > parameterBoundaryValueClasses23
                ]]></li>
                <li><![CDATA[
                parameterBoundaryValueClasses23 > parameterBoundaryValueClasses34
                ]]></li>
                <li><![CDATA[
                parameterBoundaryValueClasses34 > parameterBoundaryValueClasses45
                ]]></li>
            </ol>
        </description>
        <onSuccess>
            <message>OK - data passed the test.</message>
        </onSuccess>
        <onWarning>
            <message>
                WARNING - some of the mathematical relation rules are broken by the reported boundary values.
            </message>
        </onWarning>
    </qc>
};

declare function wqlbioeqrcp:_run-mandatory-field-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $mandatoryColumns := (
        meta:get-mandatory-columns($model), 
        meta:get-columns-by-names($model, ('parameterBoundaryValueClasses12', 'parameterBoundaryValueClasses23', 'parameterBoundaryValueClasses34', 'parameterBoundaryValueClasses45'))
    )
    let $columnExceptions := $qc/columnExceptions/*
    let $validationResult := vldmandatory:validate-mandatory-columns($model, $mandatoryColumns, $columnExceptions, $dataRows)
    let $colunsToDisplay := $model/columns/column
    return uimandatory:build-mandatory-column-qc-markup($qc, $colunsToDisplay, $validationResult)
};

declare function wqlbioeqrcp:_run-duplicate-rows-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $keyColumns := meta:get-primary-key-columns($model)
    let $validationResult := vldduplicates:validate-duplicate-rows($dataRows, $keyColumns, $qclevels:WARNING)
    let $columnsToDisplay := $model/columns/column
    return uiduplicates:build-duplicate-rows-qc-markup($qc, $columnsToDisplay, $validationResult)
};

declare function wqlbioeqrcp:_run-data-types-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $typeExceptions := $qc/typeExceptions
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldtypes:validate-data-types($model, $dataRows, $typeExceptions)
    return uitypes:build-data-types-qc-markup($qc, $model, $columnsToDisplay, $validationResult)
};

declare function wqlbioeqrcp:_run-codelists-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $columnsToDisplay := $model/columns/column
    let $codelistUrls := $qc/codelistUrls
    let $validationResult :=  vldclist:validate-codelists($model, $dataRows)
    return uiclist:build-codelists-markup($qc, $model, $columnsToDisplay, $codelistUrls, $validationResult)
};

declare function wqlbioeqrcp:_run-country-code-qc($qc as element(qc), $model as element(model), $envelope as element(envelope), $dataRows as element(dataRow)*)
as element(div)
{
    let $columnCountryCode := meta:get-column-by-name($model, 'CountryCode')
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldcountrycode:validate-country-code($columnCountryCode, $envelope, $dataRows)
    return uicountrycode:build-country-code-qc-markup($qc, $columnCountryCode, $columnsToDisplay, $validationResult)
};

declare function wqlbioeqrcp:_run-water-body-category-qc(
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

declare function wqlbioeqrcp:_run-determinands-and-water-body-category-qc(
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

declare function wqlbioeqrcp:_run-boundary-values-math-rules-qc($qc as element(qc), $model as element(model), $dataRows as element(dataRow)*)
as element(div)
{
    let $columnsToDisplay := $model/columns/column
    let $validationResult := vldwqlbioeqrcpbvmath:validate-boundary-values-math-rules($model, $dataRows)
    return uiwqlbioeqrcpbvmath:build-boundary-values-math-rules-qc-markup($qc, $columnsToDisplay, $validationResult)
};
