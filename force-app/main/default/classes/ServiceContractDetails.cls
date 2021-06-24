public without sharing class ServiceContractDetails {
    @AuraEnabled(cacheable=true)

    public static List<ContractLineItem> getPrimaryProducts(String ContractId, String Language){ 

        return [select Id, Product_Name__c, Product_SubCategory__c,PricebookEntryId,Emergency_Time_Interval__c,Min_Guarantee_Lead_Time__c
                FROM ContractLineItem
                WHERE ServiceContractId =:ContractId and Translation_Language__c = :Language AND Is_Primary__c = True 
                ORDER by CreatedDate DESC ];
    }

   	@AuraEnabled(cacheable=true)
    public static List<ContractLineItem> getGVPrimaryProducts(String ContractId){ 

        return [select Id, Product_Name__c, Product_SubCategory__c,PricebookEntryId,GV_Service_Id__c
                FROM ContractLineItem
                WHERE ServiceContractId =:ContractId
                ORDER by CreatedDate DESC ];
        // and Product_SubCategory__c != 'Emergency'
    }

    @AuraEnabled(cacheable=true)
    public static List<ContractLineItem> getEmergencyPrimaryProducts(String ContractId){ 

        return [select Id, Product_Name__c, Product_SubCategory__c,PricebookEntryId
                FROM ContractLineItem
                WHERE ServiceContractId =:ContractId and Product_SubCategory__c = 'Emergency'
                ORDER by CreatedDate DESC ];
    }

    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getWorkOrderDetails(String WorkOrderId){ 

        return [select Id,AccountId,Airing_Network__c,ServiceContractId,Invoice_Contact__c,Booking_Contact__c,Day_of_Contact__c,Additional_Email__c,Language__c,
                Type__c,Subject,Time_Zone__c,StartDt_Time__c,Duration,Description,Event_Start_Date__c,Event_Start_Time__c,Recur_Day_of_Month__c,
                Recurrence_Day_of_Week_Integer__c, Recurrence_End_Date__c, Recurrence_Instance__c, Recurrence_Interval__c, Recurrence_Type__c,
                Recurring_Days_of_Week_String__c,Event_Type__c,Entered_Start__c,Primary_Audio__c,Primary_Encoder__c,Back_up_Audio__c,Back_up_Encoder__c,
                Primary_Facility__c,Secondary_Facility__c,Primary_Facility_Protocol__c,Secondary_Facility_Protocol__c,Primary_Facility_Id__c,Secondary_Facility_Id__c,
                Destroy_Transcript_After_Event__c,Participant_Can_Save_Transcript__c,Participant_Can_View_Transcript__c,Notes__c,Purchase_Order_Number__c,Prep_Notes__c,
                Conference_URL__c,Conference_Phone__c,Conference_Password__c,Conference_Access_Code__c,Omit_Details_in_Confirmation__c,
                Caption_URL__c,View_URL__c,Channel__c,API_Token__c
                FROM WorkOrder
                WHERE Id =:WorkOrderId];
    }

   @AuraEnabled(cacheable=true)

    public static List<WorkOrderLineItem> getWOPrimaryProduct(String WorkOrderId){ 

        return [select Id,Contract_Line_Item__c
                FROM WorkOrderLineItem
                WHERE WorkOrderId =:WorkOrderId and Is_Primary__c = true];
    }
    
   @AuraEnabled(cacheable=true)

    public static List<WorkOrderLineItem> getWOSecondaryProduct(String WorkOrderId){ 

        return [select Id,PricebookEntryId,Delivery_Method__c,Instructions_for_Delivery__c,Contract_Line_Item__c
                FROM WorkOrderLineItem
                WHERE WorkOrderId =:WorkOrderId and Is_Primary__c = false];
    }    
    
    @AuraEnabled(cacheable=true)

    public static List<ServiceContract> getContractDetails(String accountId){ 

        return [select Id, Name, NameDescription__c, Pricebook2Id,Stop_at_Booked_End_Time__c
                FROM ServiceContract
                WHERE AccountId =:accountId and Status = 'Active'
               ];
    }


    @AuraEnabled(cacheable=true)

    public static List<Secondary_Product__c> getSecondaryProducts(String ContractLineItemId){ 
/*
        return [select Id,Name,PricebookEntryId__c,Product__c,Include_Selection__c,Contract_Line_Item_Id__c,Delivery_method__c,File_Format__c,File_Service_Type__c,Instructions_for_Delivery__c
                FROM Secondary_Product__c
                WHERE Contract_Line_Item_Id__c=:ContractLineItemId
               ];
*/
        return [select Id,Name,Parent_Price_Book_Product_Id__c,Service_Contract_Line_Item_Id__c,PricebookEntryId__c,Product__c,Include_Selection__c,Contract_Line_Item_Id__c,Delivery_method__c,File_Format__c,File_Service_Type__c,Instructions_for_Delivery__c
                FROM Secondary_Product__c
                WHERE Contract_Line_Item_Id__c=:ContractLineItemId
               ];
    }

    @AuraEnabled(cacheable=true)

    public static List<Program__c> getPrograms(String ContractId){ 

        return [select Name
                FROM Program__c
                WHERE Service_Contract_Id__c=:ContractId
               ];
    }
    
    @AuraEnabled(cacheable=true)

    public static List<String> getLanguages(String ContractId){ 

        List<ContractLineItem> lstContractLineItem = new List<ContractLineItem>();
        List<String> setLanguage = new List<String>();
        lstContractLineItem = [select Translation_Language__c FROM ContractLineItem WHERE ServiceContractId=:ContractId AND Is_Primary__c = True];
        for (Integer i = 0; i< lstContractLineItem.size(); i++)
		{
            if(!setLanguage.contains(lstContractLineItem[i].Translation_Language__c)){
            	setLanguage.add(lstContractLineItem[i].Translation_Language__c);    
            }
		    
		}
        
        return setLanguage;
 /*       
        return [select Translation_Language__c
                FROM ContractLineItem
                WHERE ServiceContractId=:ContractId AND Is_Primary__c = True
               ]; */
    }
    
    @AuraEnabled(cacheable=true)

    public static List<String> getOrderTypes(String ContractId){ 
		List<ContractLineItem> lstContractLineItem = new List<ContractLineItem>();
        List<String> setCategory = new List<String>();
        lstContractLineItem = [select Product_Category__c FROM ContractLineItem WHERE ServiceContractId=:ContractId AND Is_Primary__c = True];
        for (Integer i = 0; i< lstContractLineItem.size(); i++)
		{
            if(!setCategory.contains(lstContractLineItem[i].Product_Category__c)){
            	setCategory.add(lstContractLineItem[i].Product_Category__c);    
            }
		    
		}
        return setCategory;
        /*
        return [select Product_Category__c
                FROM ContractLineItem
                WHERE ServiceContractId=:ContractId AND Is_Primary__c = True
               ]; */
    }    

    @AuraEnabled(cacheable=true)
    public static List<String> getAiringNetworks(String accountId){ 
		
        Account a = [select Airing_NetWork__c FROM Account where Id =:accountId];
        //List<String> airingNetworks = a.split(';');
        return a.Airing_NetWork__c.split(';');
    }

    @AuraEnabled(cacheable=true)
    public static List<Service_Contract_Contact__c> getInvoiceContact(String ContractId){ 

        return [select Name, Contact_Id__c
                FROM Service_Contract_Contact__c 
                WHERE Service_Contract_Id__c=:ContractId and Type__c includes ('Invoicing')
               ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Service_Contract_Contact__c> getBookingContact(String ContractId){ 

        return [select Id,Name, Contact_Id__c, Contact_Email__c, Contact_Name__c, Contact_Phone__c
                FROM Service_Contract_Contact__c 
                WHERE Service_Contract_Id__c=:ContractId and Type__c includes ('Booking')
               ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Account_Attachments__c> getCommonPrepFiles(String AccountId){ 

        return [SELECT Name, File_Link__c, (SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, ContentDocument.ContentSize 
       					FROM ContentDocumentLinks) FROM Account_Attachments__c where PrepAccount__c = :AccountId and type__c='Common Prep'
               ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Account_Attachments__c> getGlobalPOFiles(String AccountId){ 

        return [SELECT Name, File_Link__c, (SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, ContentDocument.ContentSize 
       					FROM ContentDocumentLinks) FROM Account_Attachments__c where Account__c = :AccountId and type__c='Global PO'
               ];
    }
    
    @AuraEnabled(cacheable=true)
        public static List<Account_Attachments__c> getEventPrepInfo(String WorkOrderId){ 

        return [SELECT Name, File_Link__c, (SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, ContentDocument.ContentSize 
       					FROM ContentDocumentLinks) FROM Account_Attachments__c where Work_Order__c = :WorkOrderId and type__c='Event Prep'
               ];
    }    
    
    @AuraEnabled(cacheable=true)
    public static List<Account_Facility__c> getFacilities(String AccountId){ 

        return [SELECT Id, Facility_Name__c, Facility_Connections__c FROM Account_Facility__c where Account__c = :AccountId
               ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Facility_Connection__c> getFacilityConnections(){ 
        return [SELECT Id,Name, Type__c, Connection__c FROM Facility_Connection__c];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getAccountAttachmentsRecordTypeId(String RecordName){ 
        return [SELECT Id FROM RecordType WHERE sObjectType = 'Account_Attachments__c' AND Name = :RecordName];
    }
    
  @AuraEnabled  
   public static string saveAttachment(Account_Attachments__c attachRec, string file, string fileName) {  
     try{  
       Insert attachRec;  
       String base64File = EncodingUtil.urlDecode(file, 'UTF-8');     
       ContentVersion contentVersionRec = new ContentVersion();  
       contentVersionRec.Title = fileName;  
       contentVersionRec.PathOnClient = '/' + fileName;  
       contentVersionRec.FirstPublishLocationId = attachRec.Id;  
       contentVersionRec.VersionData = EncodingUtil.base64Decode(base64File);  
       contentVersionRec.IsMajorVersion = true;  
       Insert contentVersionRec;  
     } catch(Exception ex){  
       system.debug('Exception===>'+ex.getMessage());  
     }  
     return attachRec.Id;  
   }

   @AuraEnabled  
   public static list<Id> saveAttachments(Account_Attachments__c attachRec, list<Object> filesToInsert) {  
       Insert attachRec;  
       list<Id> lstCntVerIds = new list<Id>();
       List<ContentVersion> lstVersionsToInsert = new List<ContentVersion>();
        for (Object file : filesToInsert) {
            FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);
            ContentVersion objCntVersion = new ContentVersion();
            objCntVersion.PathOnClient = '/' + fileData.Title;
            objCntVersion.Title = fileData.Title;
            objCntVersion.VersionData = fileData.VersionData;
            objCntVersion.FirstPublishLocationId = attachRec.Id;
            objCntVersion.IsMajorVersion = true; 
            lstVersionsToInsert.add(objCntVersion);
        }
        list<Database.saveResult> res = Database.insert(lstVersionsToInsert);
        for (Database.SaveResult saveResult : res) {
            if(saveResult.isSuccess()) {
                lstCntVerIds.add(saveResult.getId());
            }
        }
        return lstCntVerIds;  
   }

@AuraEnabled  
   public static string createProgram(String ProgramName, String SCId) {  
       Program__c Program = new Program__c();
       Program.Name = ProgramName;
       Program.Service_Contract__c = SCId;
       insert Program;
	   return Program.Id;  
   }
    
 @AuraEnabled  
   public static string createWOLineItem(WorkOrderLineItem attachRec) {  
       Insert attachRec;  
	   return attachRec.Id;  
   }

 @AuraEnabled  
   public static string createWorkOrder(WorkOrder attachRec) {  
       Insert attachRec;  
	   return attachRec.Id;  
   } 
    
 @AuraEnabled  
   public static string updateWorkOrder(WorkOrder attachRec) {  
       update attachRec;  
	   return attachRec.Id;  
   } 
   
   @AuraEnabled  
   public static string createWOLineItemNew(List<WorkOrderLineItem> attachRec) {  
        List<WorkOrderLineItem> woLineItem = new List<WorkOrderLineItem>();
        for(WorkOrderLineItem woli: attachRec){
            woLineItem.add(woli);
        }
        if(!woLineItem.isEmpty()){
            Insert woLineItem;    
        }
        return 'success';
   }
    
   @AuraEnabled 
   public static string deleteContentDocument(String conDocId){
    List<ContentDocument> listToDelete = new List<ContentDocument>();
    listToDelete.add(new ContentDocument(
        Id = conDocId
    ));
    delete listToDelete;
    return 'success';
   }

    public class FileInfo {
        public String Title;
        public Blob VersionData;
    }
}