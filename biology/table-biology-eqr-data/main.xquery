xquery version "1.0" encoding "UTF-8";

import module namespace biobioeqrd = 'http://converters.eionet.europa.eu/wise/biology/biobiologyEqrData' at 'qcs.xquery';

declare variable $source_url as xs:string external;

biobioeqrd:run-checks($source_url)
