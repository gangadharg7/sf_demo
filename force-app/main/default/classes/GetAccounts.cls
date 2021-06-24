@RestResource(urlMapping='/Accounts/*')
global with sharing class GetAccounts{
    @HttpGet
    global static Account getAccount(){
        RestRequest request = RestContext.request;
        String accountId =  request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        system.debug(accountId);
        Account objAccount = [SELECT Id,Name,(SELECT Id,Name FROM Contacts) FROM Account WHERE Id = :accountId LIMIT 1];
        return objAccount;
    }
}