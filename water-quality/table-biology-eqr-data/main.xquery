xquery version "1.0" encoding "UTF-8";

import module namespace wqlbioeqrd = 'http://converters.eionet.europa.eu/wise/waterQuality/biologyEqrData' at 'qcs.xquery';

declare variable $source_url as xs:string external;

wqlbioeqrd:run-checks($source_url)
