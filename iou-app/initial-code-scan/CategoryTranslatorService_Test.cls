@IsTest
private class CategoryTranslatorService_Test {
    @IsTest
    static void should_be_categorized_as_Ineffectual_Test() {
        Test.startTest();
        String result = CategoryTranslatorService.translate('ApexUnitTestClassShouldHaveAsserts');
        Test.stopTest();

        Assert.areEqual('Ineffectual Tests', result);
    }

    @IsTest
    static void should_be_categorized_as_Cost_to_Understand_and_Maintain() {
        Test.startTest();
        String result = CategoryTranslatorService.translate('CognitiveComplexity');
        Test.stopTest();

        Assert.areEqual('Cost to Understand & Maintain', result);
    }

    @IsTest
    static void should_be_categorized_as_Cost_to_Change_and_Test() {
        Test.startTest();
        String result = CategoryTranslatorService.translate('CyclomaticComplexity');
        Test.stopTest();

        Assert.areEqual('Cost to Change & Test', result);
    }

    @IsTest
    static void should_be_categorized_as_Code_Smell() {
        Test.startTest();
        String result = CategoryTranslatorService.translate('ForLoopsMustUseBraces');
        Test.stopTest();

        Assert.areEqual('Code Smell', result);
    }

    @IsTest
    static void should_be_categorized_as_Bad_Practice() {
        Test.startTest();
        String result = CategoryTranslatorService.translate('ApexUnitTestMethodShouldHaveIsTestAnnotation');
        Test.stopTest();

        Assert.areEqual('Bad Practice', result);
    }
}
