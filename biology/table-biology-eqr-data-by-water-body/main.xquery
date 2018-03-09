xquery version "1.0" encoding "UTF-8";

import module namespace biobioeqrdwb = 'http://converters.eionet.europa.eu/wise/biology/biologyEqrDataByWaterBody' at 'qcs.xquery';

declare variable $source_url as xs:string external;

biobioeqrdwb:run-checks($source_url)
