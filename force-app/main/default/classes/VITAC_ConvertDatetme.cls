public class VITAC_ConvertDatetme {
    @InvocableMethod(label='convert datetime to designated timezone')
    
    public static List<List<string>> convertEST_MMDDYYYY_AMPM(List<Datetime> fromDatetime) {
        //get string in AM/PM EST format
        //example format('yyyy-MM-dd hh:mm a', 'America/New_York');
        string toFormat = 'MM/dd/yyyy hh:mm a';
        string toTimezone = 'America/New_York';

        List<List<String>> outDatesList = new List<List<String>>();
        List<String> outDates = new List<String>();

        for(Datetime oDate : fromDatetime) {
            System.debug('oDate = '+oDate);
            //outDates.add(oDate.format(toFormat, toTimezone));
            outDates.add(fromDatetime[0].format(toFormat, toTimezone));
            outDatesList.add(outDates);
        }

        //outDates.add(fromDatetime[0].format(toFormat, toTimezone));

        //outDatesList.add(outDates);
        return outDatesList;
    }
}