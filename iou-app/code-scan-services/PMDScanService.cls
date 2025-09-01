public without sharing class PMDScanService {

    public static String parseFileName(String unformattedFileName) {
        Integer indexOfFinalDirectory = 0;
        //Windows OS uses the \ separator, Linux based uses /
        if (unformattedFileName.contains('\\')) {
            indexOfFinalDirectory = unformattedFileName.lastIndexOf('\\');
        }
        else {
            indexOfFinalDirectory = unformattedFileName.lastIndexOf('/');
        }
        String trimmedFileName = unformattedFileName.substring(indexOfFinalDirectory + 1);
        return trimmedFileName.remove('.cls').remove('"');
    }

    public static String parseMethodName(String message) {
        Integer iFirstQuote = message.indexOf('\'') + 1; //increment 1 to move index past the single quote
        Integer iLastQuote = message.lastIndexOf('\'');
        String couldBeClassOrMethod = message.substring(iFirstQuote, iLastQuote);
        //for Cognitive Complexity score the method should be the class name without '()'
        String name = couldBeClassOrMethod.contains('(') ?
            couldBeClassOrMethod.substringBefore('(') + '()' : couldBeClassOrMethod;
        return name;
    }

    public static Integer parseComplexityScore(String message) {
        Integer score = 0;
        if (message.contains('cognitive')) {
            String mayRequireMoreParsing = message.substringBetween('cognitive complexity of ', ',');
            String finalString = mayRequireMoreParsing.contains('(') ?
                mayRequireMoreParsing.substringBefore(' (') : mayRequireMoreParsing;
            score = Integer.valueOf(finalString);
        }
        else {
            score = Integer.valueOf(message.substringBetween('cyclomatic complexity of ', '.'));
        }

        return score;
    }

    public class ApexClass {
        public String fileName;
        public List<ApexViolation> violations;
    }

    public class ApexViolation {
        public String ruleName; //todo: rule
        public String message;  //todo: validate parsing rules
        public String category; //todo: deprecate
        public String url;      //todo: deprecate
        public String line;     //todo: deprecate
        public String endLine;  //todo: deprecate
        //todo: file name is now in "locations", which will need to be an inner class as well
    }
}
