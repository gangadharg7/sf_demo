public class DateUtility {
    
    //Convert Datetime field to String format.
    public static String formatDateTime(Datetime inputDate){
        String cDate = null;
        if(inputDate != null){
        	cDate = inputDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');    
        }
        return cDate;
    }
}