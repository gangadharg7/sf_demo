public with sharing class ContactManager {
        @AuraEnabled(cacheable=true)

        public static List<Contact> getContact(Integer numberofRecords, String wClause){ 
            return [select id, LastName, FirstName, Phone, Email from Contact ORDER by CreatedDate DESC LIMIT:numberofRecords];
        }
}