xquery version "1.0" encoding "UTF-8";

module namespace datax = 'http://converters.eionet.europa.eu/common/dataExtensions';

import module namespace data = 'http://converters.eionet.europa.eu/common/data' at './data.xquery';
import module namespace qclevels = 'http://converters.eionet.europa.eu/common/qclevels' at './qclevels.xquery';
import module namespace valconv = 'http://converters.eionet.europa.eu/common/valueConversion' at './value-conversion.xquery';
import module namespace vldtypes = 'http://converters.eionet.europa.eu/common/validators/types' at './validators/types.xquery';

declare function datax:get-row-value($row as element(), $column as element(column))
as xs:string?
{
    let $values := data:get-row-values($row, $column)
    return 
        if (data:is-empty-value($values)) then
            ()
        else
            let $value := $values[1]
            return
                if (vldtypes:validate-by-type($column, $value) != $qclevels:OK) then
                    ()
                else
                    $value
};

declare function datax:get-row-integer-value($row as element(), $column as element(column))
as xs:integer?
{
    xs:integer(datax:get-row-value($row, $column))
};

declare function datax:get-row-decimal-value($row as element(), $column as element(column))
as xs:decimal?
{
    xs:decimal(datax:get-row-value($row, $column))
};

declare function datax:get-row-float-value($row as element(), $column as element(column))
as xs:float?
{
    xs:float(datax:get-row-value($row, $column))
};

declare function datax:get-row-double-value($row as element(), $column as element(column))
as xs:double?
{
    xs:double(datax:get-row-value($row, $column))
};

declare function datax:get-row-date-value($row as element(), $column as element(column))
as xs:date?
{
    xs:date(datax:get-row-value($row, $column))
};

declare function datax:get-row-boolean-value($row as element(), $column as element(column))
as xs:boolean?
{
    valconv:boolean(datax:get-row-value($row, $column))
};
