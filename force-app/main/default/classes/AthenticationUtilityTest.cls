@isTest
public class AthenticationUtilityTest {
    
    @isTest public static void validateAuthMethods(){
        
        Map<String, Object> rtMap =  AthenticationUtility.getRtAuthDetails();
        Map<String, Object> vssMap =  AthenticationUtility.getVssAuthDetails();
    }
	
}