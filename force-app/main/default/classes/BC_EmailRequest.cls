public class BC_EmailRequest {
    public String emailType;
    public String accountId;
    public List<id> timesheetId;
    public String errorMessage;
    public Date startDate;
    public Date endDate;
    
    public BC_EmailRequest(String type, String accId, List<id> tsId, String msg, Date sDate, Date eDate) {
        this.emailType = type;
        this.accountId = accId;
        this.timesheetId = tsId;
        this.errorMessage = msg;
        this.startDate = sDate;
        this.endDate = eDate;
    }
}