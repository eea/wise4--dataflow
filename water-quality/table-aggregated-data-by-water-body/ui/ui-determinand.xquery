xquery version "1.0" encoding "UTF-8";

module namespace uiwqlagwbdet = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedDataByWaterBody/ui/determinand';

import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace rdfutil = 'http://converters.eionet.europa.eu/common/rdfutil' at '../../../common/rdf-util.xquery';
import module namespace uiutil = 'http://converters.eionet.europa.eu/common/ui/util' at '../../../common/ui/util.xquery';

declare function uiwqlagwbdet:build-determinand-qc-markup(
    $qc as element(qc),
    $model as element(model),
    $columnsToDisplay as element(column)*,
    $validationResult as element(result)
)
as element(div)
{
    let $qcColumn := meta:get-column-by-name($model, 'observedPropertyDeterminandCode')
    return uiutil:build-generic-qc-markup-by-column-values($qc, $qcColumn, $columnsToDisplay, $validationResult)
};

declare function uiwqlagwbdet:compose-determinand-description-markup($vocabularyObservedProperty as element(), $determinandPrefLabel as xs:string)
as element(span)
{
    let $concepts := rdfutil:get-concept-by-prefLabel($vocabularyObservedProperty, $determinandPrefLabel)
    return
        if (empty($concepts)) then
            <span>{ $determinandPrefLabel }</span>
        else
            let $concept := $concepts[1]
            return
                <span>
                    { $determinandPrefLabel } (<a target="_blank" href="{ rdfutil:about($concept) }">{ rdfutil:notation($concept) }</a>)
                </span>
};
