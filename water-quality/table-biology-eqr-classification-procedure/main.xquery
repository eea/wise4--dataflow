xquery version "1.0" encoding "UTF-8";

import module namespace wqlbioeqrcp = 'http://converters.eionet.europa.eu/wise/waterQuality/biologyEqrClassificationProcedure' at 'qcs.xquery';

declare variable $source_url as xs:string external;

wqlbioeqrcp:run-checks($source_url)
