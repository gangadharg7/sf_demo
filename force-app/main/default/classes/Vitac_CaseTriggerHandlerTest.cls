@isTest
Public class Vitac_CaseTriggerHandlerTest {
    
    
    
     static testMethod void coverMethod(){
        Profile p = [select id from Profile where name = 'System Administrator Custom'];  
        User testUser1 = new User();
        testUser1.Alias = 'testu';
        testUser1.Email='testuser@vitac.com'; 
        testUser1.EmailEncodingKey='UTF-8';
        testUser1.LastName='user';
        testUser1.LanguageLocaleKey='en_US';
        testUser1.TimeZoneSidKey='America/New_York' ;
        testUser1.LocaleSidKey='en_US'; 
        testUser1.ProfileId = p.Id; 
        testUser1.UserName='testuser@vitac.com';
          insert testUser1;
        
        System.runAs(testUser1){
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new Vitac_SamangeMockTest());
            List<Case> caseList=new List<Case>();
            List<Case> caseUpdate=new List<Case>();
            RecordType RecordTypId  = [select id, developerName from RecordType where SobjectType='case' AND developerName ='Internal_Help_Desk'];
            System.debug('RecordTypId'+RecordTypId);
            Case cs=new Case();
            cs.RecordTypeId=RecordTypId.id;
            cs.Subject='test';
            cs.Description='Test';
            cs.Priority='Medium';
            cs.Status='New';
            cs.Origin='Phone';
            caseList.add(cs);
            Insert caseList;
            
            cs.Status='SaManage Ticket - Waiting';
            caseUpdate.add(cs);
            update caseUpdate;
            test.stopTest();
        }
    }
    
	
        

}