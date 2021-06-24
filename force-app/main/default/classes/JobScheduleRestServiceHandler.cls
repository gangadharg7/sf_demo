public class JobScheduleRestServiceHandler {

    public static String createJob(String jobId) {
        String status = null;
        String endPoint = 'https://rtis-api-dev.vitac.com/api/v1/JobSchedules';
        RestUtility.postAPICall(endPoint, jobId, null, null);
        return status;
    }
    
    public class CreateJobJson{
         String clientId;
         String programName;
         String wonumber;
         String jobId;
    }
}