xquery version "1.0" encoding "UTF-8";

import module namespace biobioeqrcp = 'http://converters.eionet.europa.eu/wise/biology/biologyEqrClassificationProcedure' at 'qcs.xquery';

declare variable $source_url as xs:string external;

biobioeqrcp:run-checks($source_url)
