@isTest
private class VITAC_MilestoneWOTimeCalculatorTest {

    @isTest static void testPositiveValue() {
        Id woTestId = '0WO3B000000N2zFWAS'; 
        //Id t = '';
      
        // Select an existing milestone type to test with
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        
        //System.assertEquals(mt.Id, t);
        
        VITAC_MilestoneWOTimeCalculator calculator = new VITAC_MilestoneWOTimeCalculator();
        Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(woTestId, mt.Id);
        
        if(mt.name != null && mt.Name.equals('m1')) {
            System.assertEquals(actualTriggerTime, 7);
        }
        else {
            System.assertEquals(actualTriggerTime, 5);
        }
    }
}