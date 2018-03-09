xquery version "1.0" encoding "UTF-8";

module namespace vldwqlloq = "http://converters.eionet.europa.eu/wise/waterQuality/common/validators/loq";

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at '../../../common/data.xquery';
import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace rdfutil = 'http://converters.eionet.europa.eu/common/rdfutil' at '../../../common/rdf-util.xquery';

declare variable $vldwqlloq:_OBSERVATION-STATUSES := ("O", "M", "L", "N");

declare function vldwqlloq:is-valid-by-qc-1(
    $columnObservedPropertyDeterminandCode as element(column),
    $columnResultObservationStatus as element(column),
    $columnProcedureLOQValue as element(column),
    $tableName as xs:string,
    $concepts as xs:string*,
    $dataRow as element(dataRow)
)
as xs:boolean
{
    let $determinand := datax:get-row-value($dataRow, $columnObservedPropertyDeterminandCode)
    return
        if (empty($determinand)) then
            true()
        else
            let $observationStatus := datax:get-row-value($dataRow, $columnResultObservationStatus)
            let $isMandatory := (empty($observationStatus) or not(upper-case($observationStatus) = $vldwqlloq:_OBSERVATION-STATUSES)) and
                vldwqlloq:_has-mandatory-loq-in-table($concepts, $determinand, $tableName)
            return not($isMandatory) or not(data:is-empty-cell($dataRow, $columnProcedureLOQValue))
};

declare function vldwqlloq:_has-mandatory-loq-in-table($concepts as xs:string*, $determinand as xs:string, $tableName as xs:string)
as xs:boolean
{
    let $x := string-join(($determinand, $tableName), "#")
    return
        if (not($x = $concepts)) then
            false()
        else
            true()
    (:let $concept := rdfutil:get-concept-by-notation($vocabularyObservedProperty, $determinand)
    return not(empty($concept/*[local-name(.) = "hasMandatoryLoqInTables" and lower-case(rdfutil:resource(.)) =  lower-case($tableName)])):)
};
