@IsTest
private class PMDScanService_Test {

    @IsTest
    static void should_parse_file_name_Linux_Scenario() {
        String sampleRawFileName = '"/IdeaProjects/iou-app/force-app/main/default/classes/TestOne.cls"';

        Test.startTest();
        String parsedFileName = PMDScanService.parseFileName(sampleRawFileName);
        Test.stopTest();

        Assert.areEqual('TestOne', parsedFileName);
    }

    @IsTest
    static void should_parse_file_name_Windows_Scenario() {
        String sampleRawFileName = '"\\IdeaProjects\\iou-app\\force-app\\main\\default\\classes\\TestOne.cls"';

        Test.startTest();
        String parsedFileName = PMDScanService.parseFileName(sampleRawFileName);
        Test.stopTest();

        Assert.areEqual('TestOne', parsedFileName);
    }

    @IsTest
    static void should_parse_method_name() {
        String sampleRawMessage = '"The method \'testMethod1(Database.BatchableContext, List<Lead>)\' has a cognitive complexity of 124, current threshold is 15"';

        Test.startTest();
        String parsedMethodName = PMDScanService.parseMethodName(sampleRawMessage);
        Test.stopTest();

        Assert.areEqual('testMethod1()', parsedMethodName);
    }

    @IsTest
    static void should_parse_cognitive_complexity_score() {
        String sampleRawMessage = '"The method \'testMethod1(Database.BatchableContext, List<Lead>)\' has a cognitive complexity of 124, current threshold is 15"';

        Test.startTest();
        Integer parsedComplexityScore = PMDScanService.parseComplexityScore(sampleRawMessage);
        Test.stopTest();

        Assert.areEqual(124, parsedComplexityScore);
    }

    @IsTest
    static void should_parse_cyclomatic_complexity_score() {
        String sampleRawMessage = '"The method \'execute(Database.BatchableContext, List<Lead>)\' has a cyclomatic complexity of 40."';

        Test.startTest();
        Integer parsedComplexityScore = PMDScanService.parseComplexityScore(sampleRawMessage);
        Test.stopTest();

        Assert.areEqual(40, parsedComplexityScore);
    }
}
