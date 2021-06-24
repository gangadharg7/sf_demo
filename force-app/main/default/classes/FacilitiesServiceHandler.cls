/*
 * Created By: Gangadhar G.
 * Created Date: May 21, 2021
 * Description: This class gets the Facility data from the external system via REST API call. 
*/

public class FacilitiesServiceHandler {
    
    @AuraEnabled(cacheable=true)
    public static String getFacilities(String type){
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_RTM_Integration__c) ) return 'Custom Settings Enabled.';
        
        String response = null;
        try{
            // Get the REST endpoint and authentication token from metadata
            Map<String, Object> authMap = AthenticationUtility.getVssAuthDetails();
            String token = (String)authMap.get('token');
            String endPoint = (String)authMap.get('endPoint');
            endPoint = endPoint + '/api/customer/' + type + '/facilities';
            System.debug('end point:' + endPoint);
            HttpRequest requestParam = new HttpRequest();
            requestParam.setEndpoint(endpoint);
            requestParam.setHeader('Authorization', 'Bearer ' + token);
            requestParam.setMethod('GET');
            requestParam.setTimeout(120000);
            Http httpObj = new Http();
            HttpResponse res = httpObj.send(requestParam);
            System.debug('API response code:' + res.getStatusCode());
            if(res.getStatusCode() == 200){
                String resultSet = res.getBody();                
                List<Object> jsonList = (List<Object>)Json.deserializeUntyped(resultSet);
                ResponseJSONWrapper wrapper = new ResponseJSONWrapper(); 
                DataList dataList = new DataList();
                List<ResponseData> resList = new List<ResponseData>();
                ResponseData resData = null;
                for(Object obj : jsonList){
                    Map<String,Object> mapObj = (Map<string,Object>)obj;
                    Integer facilityId = (Integer)mapObj.get('facilityId');
                    String name = (String)mapObj.get('name');
                    Boolean isActive = (Boolean)mapObj.get('isActive');
                    Boolean isVChipEnabled = (Boolean)mapObj.get('isVChipEnabled');
                    
                    List<Object> encoderList = (List<Object>)mapObj.get('encoderInfo');
                    Map<String,Object> encoderMap = (Map<String,Object>)encoderList.get(0);
                    String protocol = (String)encoderMap.get('protocol');
                    
                    resData = new ResponseData();
                    resData.facilityId = facilityId;
                    resData.name = name;
                    resData.isActive = isActive;
                    resData.isVChipEnabled = isVChipEnabled;
                    resData.protocol = protocol;
                    resList.add(resData);
                }
                response = JSON.serialize(resList);
                // Log API success or failure info into the Apex Debug Log 
                // String cls, String routine, String recId, String msg, String respId, String obj)
                if(cs.Debug_Success_Message__c){
                    new ApexDebugLog().createLog(new ApexDebugLog.Information('FacilitiesServiceHandler','getFacilities','URL : '+endPoint+',\n'+'Method : getFacilities ' + 'Req Body : NULL','Get Facilities List Request','Integration','Response Code : '+res.getStatusCode()+',\n'+ 'Response Body : NULL','Get Facilities List'));    
                }
            }else{
                // Log API error info into the Apex Debug Log
                new ApexDebugLog().createLog(new ApexDebugLog.Error('FacilitiesServiceHandler','createErrorLog', NULL, 'Exception while getting facility details, status code:' + res.getStatusCode(), NULL,'Work Order', 'Failed - Get Facilities List'));
                
                response = 'Exception while getting facility details, status code:' + res.getStatusCode();
            }
        }catch(Exception e){
            // Log API exception details info into the Apex Debug Log
            new ApexDebugLog().createLog(new ApexDebugLog.Error('FacilitiesServiceHandler','getFacilities',type,e.getMessage(),'Integration','Work Order', 'Failed - Get Facilities List'));
            System.debug('Exception while getting facility details:' + e.getMessage());
            response = 'Exception while getting facility details:' + e.getMessage();
        }
        return response;
    }
    
    public class ResponseData {
        public Integer facilityId;
        public String name;
        public Boolean isActive;
        public Boolean isVChipEnabled;
        public String protocol;
    }
    public class DataList {
        public List<ResponseData> resList;
    }
    public class ResponseJSONWrapper {
        public DataList dataList;
    }
}