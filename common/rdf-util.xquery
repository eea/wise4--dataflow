xquery version "1.0" encoding "UTF-8";

module namespace rdfutil = 'http://converters.eionet.europa.eu/common/rdfutil';

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace adms = "http://www.w3.org/ns/adms#";
declare namespace prop = "http://dd.eionet.europa.eu/property/";

declare function rdfutil:conceptsLoq($rdfelement as element()) as xs:string* {
    for $x in $rdfelement/skos:Concept[adms:status/@rdf:resource[ends-with(., "/valid") or ends-with(., "/stable") or ends-with(., "/experimental")]]
    let $table := $x/prop:hasTable/@rdf:resource/string()
    let $determinand := $x/prop:hasDeterminand/@rdf:resource/string()
    return string-join(($determinand, $table), "#")
};
declare function rdfutil:conceptsUom($rdfelement as element()) as xs:string* {
    for $x in $rdfelement/skos:Concept[adms:status/@rdf:resource[ends-with(., "/valid") or ends-with(., "/stable") or ends-with(., "/experimental")]]
    let $uom := $x/prop:hasUom/@rdf:resource/string()
    let $table := $x/prop:hasTable/@rdf:resource/string()
    let $determinand := $x/prop:hasDeterminand/@rdf:resource/string()
    return string-join(($determinand, $uom, $table), "#")
};

declare function rdfutil:concepts($rdfelement as element())
as element(skos:Concept)*
{
    for $concept in $rdfelement/skos:Concept
    let $status := rdfutil:status($concept)
    where fn:ends-with($status, "/valid") or fn:ends-with($status, "/stable") or fn:ends-with($status, "/experimental")
    return $concept
};

declare function rdfutil:about($rdfelement as element())
as xs:string
{
    string($rdfelement/@rdf:about)
};

declare function rdfutil:resource($rdfelement as element())
as xs:string
{
    string($rdfelement/@rdf:resource)
};

declare function rdfutil:notation($concept as element(skos:Concept))
as xs:string
{
    string($concept/skos:notation)
};

declare function rdfutil:status($concept as element(skos:Concept))
as xs:string
{
    (:rdfutil:resource($concept/adms:status):)
    let $r := $concept/adms:status
    return
        if (count($r) >= 1) then
            rdfutil:resource($r[1])
        else
            ""
};

declare function rdfutil:get-concept-by-notation($vocabulary as element(rdf:RDF), $notation as xs:string)
as element(skos:Concept)?
{
    let $notationLowerCase := lower-case($notation)
    return rdfutil:concepts($vocabulary)[lower-case(skos:notation) = $notationLowerCase]
};

declare function rdfutil:get-concept-uri-by-notation($vocabulary as element(rdf:RDF), $notation as xs:string)
as xs:string?
{   
    let $concept := rdfutil:get-concept-by-notation($vocabulary, $notation)
    return if (empty($concept)) then () else rdfutil:about($concept)
};

declare function rdfutil:get-concept-by-concept-uri($vocabulary as element(rdf:RDF), $conceptUri as xs:string)
as element(skos:Concept)?
{
    let $conceptUriLowerCase := lower-case($conceptUri)
    return rdfutil:concepts($vocabulary)[lower-case(rdfutil:about(.)) = $conceptUriLowerCase]
};

declare function rdfutil:get-notation-by-concept-uri($vocabulary as element(rdf:RDF), $conceptUri as xs:string)
as xs:string?
{
    let $concept := rdfutil:get-concept-by-concept-uri($vocabulary, $conceptUri)
    return if (empty($concept)) then () else string($concept/skos:notation) 
};

declare function rdfutil:get-concept-by-prefLabel($vocabulary as element(rdf:RDF), $prefLabel as xs:string)
as element(skos:Concept)*
{
    let $prefLabelLowerCase := lower-case($prefLabel)
    return rdfutil:concepts($vocabulary)[lower-case(string(./skos:prefLabel)) = $prefLabelLowerCase]
};
