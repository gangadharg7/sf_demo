@isTest
public class FacilitiesServiceHandlerTest {
	
    @isTest static void getFacilities() {
       	String response = FacilitiesServiceHandler.getFacilities('LSUA');
        System.debug('response data:' + response);
    }
}