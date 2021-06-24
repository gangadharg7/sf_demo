global class EmailToWorkOrder implements Messaging.InboundEmailHandler {
 global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
         try {
                 WorkOrder wo = new WorkOrder();
                 wo.Description =   email.plainTextBody ;
                 wo.Subject = email.subject;
                 wo.Status = 'New';
                 wo.Time_Zone__c = 'America/Phoenix';
			    // wo.Duration = 1;
                // wo.StartDt_Time__c = system.Datetime.now();
                 List<Contact> con = [select Id,AccountId from contact where Email =: email.fromAddress];
                     if(con.size() > 0){
                         wo.ContactId = con[0].Id;
                         wo.AccountId = con[0].AccountId;
                     }
              AMCDV_shortform__c asf=AMCDV_shortform__c.getInstance();
          SVODLONG_Longform__c slf=SVODLONG_Longform__c.getInstance();
       String DT1 = asf.DELIVERED_TIMESTAMP__c;
       DateTime DT2 = Datetime.valueOf(DT1);
       String s=email.plainTextBody;   
          String sub=email.subject;
          String value='',val='',s3;
          integer dur;
       List<String> myarr=new List<String>();
       myarr=s.split('\n');
    List<string> mylist=new List<string>();
          mylist=sub.split(' ');
          for(integer i=0;i<mylist.size();i++)
          {
              if(mylist.get(i)=='AMCDV' || mylist.get(i)=='Short')
                  value=value+mylist.get(i);
           if(mylist.get(i)=='SVODLONG' || mylist.get(i)=='Long')
                  val=val+mylist.get(i);
           }
          
if(value=='AMCDVShort')
{

      for(integer i=0;i<myarr.size();i++) 
      {
         s3=myarr.get(i);
         
          if(s3.contains(asf.TURN_AROUND__c))
          {
                i=i+1;
                s3=myarr.get(i);
                List<string> st=new List<string>();
                st=s3.split('');
                dur=integer.valueOf(st[4])*24;
                wo.Duration=dur;
                wo.DurationType='Hours';  
                wo.StartDt_Time__c = DT2;
          } 
      }       
}   
if(val=='SVODLONGLong')
{
     for(integer i=0;i<myarr.size();i++) 
      {
         s3=myarr.get(i);
        
          if(s3.contains(slf.TURN_AROUND__c))
          {
                i=i+1;
                s3=myarr.get(i);
                List<string> st=new List<string>();
                st=s3.split('');
                dur=integer.valueOf(st[4])*24;
                wo.Duration=dur;
                wo.DurationType='Hours';                                    
          } 
  }
}        
                     insert wo;
                  
             // Save attachments, if any
         if(email.textAttachments != null)
        {
                    
            List<ContentVersion> cvListem = new List<ContentVersion>();
            List<ContentDocumentLink> cdlListem = new List<ContentDocumentLink>();
            List<ContentDocumentLink> cdlListcase = new List<ContentDocumentLink>();
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
              ContentVersion fContentInsert = new ContentVersion();
              fContentInsert.Title = tAttachment.fileName;
            fContentInsert.VersionData = Blob.valueOf(tAttachment.body);
              fContentInsert.PathOnClient = '/' + tAttachment.fileName ;
              cvListem.add(fContentInsert);
            }
          insert cvListem;
          cvListem = [select id, ContentDocumentId from ContentVersion WHERE Id in :cvListem];
          for (ContentVersion cv : cvListem) {
              ContentDocumentLink cl = new ContentDocumentLink();
              cl.ContentDocumentId = cv.ContentDocumentId;
              cl.LinkedEntityId =   wo.Id ;
              cl.ShareType = 'V';
              cl.Visibility = 'AllUsers';
              cdlListem.add(cl);
          }
           insert cdlListem;
         
        }
        if(email.binaryAttachments != null)
        {
           List<ContentVersion>cvListem = new List<ContentVersion>();
           List<ContentDocumentLink> cdlListem = new List<ContentDocumentLink>();
           List<ContentDocumentLink> cdlListcase = new List<ContentDocumentLink>();
           for (Messaging.InboundEmail.BinaryAttachment binAttach : email.binaryAttachments) {
                ContentVersion fContentInsert = new ContentVersion();
                fContentInsert.Title = binAttach.fileName;
              fContentInsert.VersionData = binAttach.body;
                fContentInsert.PathOnClient = '/' + binAttach.fileName ;
                cvListem.add(fContentInsert);

          }
          insert cvListem;
            
          cvListem = [select id, ContentDocumentId from ContentVersion WHERE Id in :cvListem];
          for (ContentVersion cv : cvListem) {
              ContentDocumentLink cl = new ContentDocumentLink();
              cl.ContentDocumentId = cv.ContentDocumentId;
              cl.LinkedEntityId =   wo.Id; //Shared with record ID
              cl.ShareType = 'V';
              cl.Visibility = 'AllUsers';
              cdlListcase.add(cl);
          }
          insert cdlListcase;

        }
      }//try
        
       catch (Exception e) {
       System.debug('Query Issue: ' + e);
      // new ApexDebugLog().createLog( new ApexDebugLog.Error( 'createCaseService', 'Messaging.InboundEmailHandler', 'Error', e, 'Apex' ) );   
      }   
  
    result.success = true;
    return result;
    }

 }