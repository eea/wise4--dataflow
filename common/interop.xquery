xquery version "1.0" encoding "UTF-8";

module namespace interop = 'http://converters.eionet.europa.eu/common/interop';

declare variable $interop:_TEST-MODE as xs:boolean := true();

declare function interop:get-envelope-metadata($sourceUrl as xs:string)
as element(envelope)
{
    let $envelopeUrl := interop:_source-url-to-envelope-url($sourceUrl)
    return 
        if (not($interop:_TEST-MODE)) then
            doc($envelopeUrl)/envelope
        else
            if (doc-available($envelopeUrl)) then
                doc($envelopeUrl)/envelope
            else
                <envelope>
                    <countrycode>XX</countrycode>
                </envelope>
};

declare function interop:_source-url-to-envelope-url($sourceUrl as xs:string)
as xs:string
{
    let $sourceUrlParts := fn:tokenize($sourceUrl, "/")
    let $envelopeUrlParts := fn:remove($sourceUrlParts, fn:count($sourceUrlParts))
    return concat(string-join($envelopeUrlParts, "/"), "/xml")
};

declare function interop:load-from-envelope($envelope as element(envelope), $tableId as xs:string, $sourceUrl as xs:string) {
    let $file := $envelope/file[contains(@schema, $tableId) and string-length(@link)>0]
    let $link := resolve-uri($file/@link, base-uri($envelope))
    return doc($link)
};
