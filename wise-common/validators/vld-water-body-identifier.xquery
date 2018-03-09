xquery version "1.0" encoding "UTF-8";

module namespace vldwbodyid = 'http://converters.eionet.europa.eu/wise/common/validators/waterBodyIdentifier';

import module namespace vldinterid = 'http://converters.eionet.europa.eu/wise/common/validators/internationalIdentifier' at './vld-international-identifier.xquery';

declare function vldwbodyid:validate-water-body-identifier-format(
    $column as element(column), 
    $envelope as element(envelope), 
    $dataRows as element(dataRow)*
)
as element(result)
{
    vldinterid:validate-international-identifier-format($column, $envelope, $dataRows)
};

declare function vldwbodyid:validate-water-body-identifier-reference(
    $columnWaterBodyIdentifier as element(column),
    $columnWaterBodyIdentifierScheme as element(column),
    $vocabularyWaterBodies as element(),
    $dataRows as element(dataRow)*
)
as element(result)
{
    let $schemeUrlPrefix := "http://dd.eionet.europa.eu/vocabulary/wise/WaterBody/"
    return vldinterid:validate-international-identifier-reference(
        $columnWaterBodyIdentifier,
        $columnWaterBodyIdentifierScheme,
        $vocabularyWaterBodies,
        $schemeUrlPrefix,
        $dataRows
    )
};
