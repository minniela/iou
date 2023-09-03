public with sharing class CategoryTranslatorService {

    public static String translate(String pmdCategory) {
        String translatedCategory = '';
        
        if (isIneffectualTest(pmdCategory)) {
            translatedCategory = 'Ineffectual Tests';
        }
        else if (isDifficultToMaintain(pmdCategory)) {
            translatedCategory = 'Cost to Understand & Maintain';
        }
        else if (isDifficultToTest(pmdCategory)) {
            translatedCategory = 'Cost to Change & Test';
        }
        else if (isCodeSmell(pmdCategory)) {
            translatedCategory = 'Code Smell';
        }
        else if (isBadPractice(pmdCategory)) {
            translatedCategory = 'Bad Practice';
        }

        return translatedCategory;
    }

    private static Boolean isIneffectualTest(String pmdCategory) {
        return pmdCategory.equals('ApexUnitTestClassShouldHaveAsserts');
    }

    private static Boolean isDifficultToMaintain(String pmdCategory) {
        return pmdCategory.equals('CognitiveComplexity');
    }

    private static Boolean isDifficultToTest(String pmdCategory) {
        return pmdCategory.equals('CyclomaticComplexity');
    }

    private static Boolean isCodeSmell(String pmdCategory) {
        List<String> codeSmells = new List<String>{
            'UnusedLocalVariable', 'EmptyWhileStmt', 'EmptyTryOrFinallyBlock', 'EmptyStatementBlock', 'EmptyIfStmt',
            'EmptyCatchBlock', 'UnusedMethod', 'NcssMethodCount', 'ExcessiveParameterList', 'AvoidDeeplyNestedIfStmts',
            'WhileLoopsMustUseBraces', 'OneDeclarationPerLine', 'IfStmtsMustUseBraces', 'IfElseStmtsMustUseBraces',
            'ForLoopsMustUseBraces'
        };
        return codeSmells.contains(pmdCategory);
    }

    private static Boolean isBadPractice(String pmdCategory) {
        List<String> badPractices = new List<String>{
            'OperationWithLimitsInLoop', 'AvoidDebugStatements', 'OverrideBothEqualsAndHashcode',
            'MethodWithSameNameAsEnclosingClass', 'AvoidNonExistentAnnotations', 'AvoidHardcodingId',
            'AvoidDirectAccessTriggerMap', 'AvoidLogicInTrigger', 'ApexUnitTestShouldNotUseSeeAllDataTrue',
            'ApexUnitTestMethodShouldHaveIsTestAnnotation'
        };
        return badPractices.contains(pmdCategory``);
    }
}
