public with sharing class UserController {
    //public static List<Account> fetchAccounts() {
    //Qyery 10 accounts
    //  List<Account> accList = [SELECT Id, Name, BillingState, 
    //  Website, Phone, Industry, Type from Account LIMIT 10];
    //return list of accounts
    //   return accList;
    // }
    @AuraEnabled
    
    public static List<workOrder> getAllWorkorder(){
        
        List<workOrder> workOrderLists = [Select ID,Subject,StartDate,EndDate from workOrder];
        return workOrderLists; 
    }  
    //         		
    @AuraEnabled
    
    public static List<User> getAllUser(){
        
        List<User> userList = [Select Id,Name from User where IsActive=true];
        return userList; 
    }
    
    
}