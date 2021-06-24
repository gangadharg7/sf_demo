@RestResource(urlMapping='/UpsertAccount/*')
global without sharing class UpsertAccount 
{
    public class Account{
        public Double totalPrice {get; set;}
        public DateTime statementDate {get; set;}
        public String contactnumber {get; set;}
        public List<Contact> Contacts {get; set;}
        public Integer invoiceNumber {get; set;}
    }
}