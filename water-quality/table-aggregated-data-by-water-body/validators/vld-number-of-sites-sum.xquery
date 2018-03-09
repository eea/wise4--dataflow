xquery version "1.0" encoding "UTF-8";

module namespace vldwqlagwbnss = 'http://converters.eionet.europa.eu/wise/waterQuality/aggregatedDataByWaterBody/validators/numberOfSitesSum';

import module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions' at '../../../common/data-extensions.xquery';
import module namespace meta = 'http://converters.eionet.europa.eu/common/meta' at '../../../common/meta.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at '../../../common/qclevels.xquery';
import module namespace vldres = 'http://converters.eionet.europa.eu/common/validators/validationResult' at '../../../common/validators/validation-result.xquery';

declare function vldwqlagwbnss:validate-number-of-sites-sum($model as element(model), $dataRows as element(dataRow)*)
as element(result)
{
    let $columnResultNumberOfSamples := meta:get-column-by-name($model, "resultNumberOfSamples")
    let $columnResultMeanValue := meta:get-column-by-name($model, "resultMeanValue")
    let $columnsResultNumbersPerSiteClass := meta:get-columns-by-names($model, 
        ("resultNumberOfSitesClass1", "resultNumberOfSitesClass2", "resultNumberOfSitesClass3", "resultNumberOfSitesClass4", "resultNumberOfSitesClass5")
    )
    let $resultRows :=
        for $dataRow in $dataRows
        let $resultNumberOfSamples := datax:get-row-integer-value($dataRow, $columnResultNumberOfSamples)
        return
            if (empty($resultNumberOfSamples)) then
                ()
            else
                let $resultNumbersPerSiteClass := 
                    for $columnResultNumberPerSiteClass in $columnsResultNumbersPerSiteClass
                    return datax:get-row-integer-value($dataRow, $columnResultNumberPerSiteClass)
                return
                    if (empty($resultNumbersPerSiteClass) or $resultNumberOfSamples >= sum($resultNumbersPerSiteClass)) then
                        ()
                    else
                        let $flaggedColumns := (
                            vldres:create-flagged-column($columnResultNumberOfSamples, $qclevels:BLOCKER),
                            vldres:create-flagged-column($columnResultMeanValue, $qclevels:BLOCKER),
                            for $columnResultNumberPerSiteClass in $columnsResultNumbersPerSiteClass
                            return vldres:create-flagged-column($columnResultNumberPerSiteClass, $qclevels:BLOCKER)
                        )
                        return vldres:create-result-row($dataRow, $flaggedColumns)
    return vldres:create-result($resultRows)
};
