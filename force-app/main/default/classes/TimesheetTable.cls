public class TimesheetTable{
    public String InitiativeId {get;set;}
    public String InitiativeName {get;set;}
    public String Description{get;set;}
    public String TPM{get;set;}
    public String Mon{get;set;}
    public String Tue{get;set;}
    public String Wed{get;set;}
    public String Thu{get;set;}
    public String Fri{get;set;}
    public String Sat{get;set;}
    public String Sun{get;set;}
    public String AccSerId{get;set;}
    public String AccId{get;set;}
    public TimesheetTable(string iId,string iName,string des,string tpm,string m,string tu,string w,string th,string f,string sa,string su,string asId,string accId){
        this.InitiativeId=iId;
        this.InitiativeName=iName;
        this.Description=des;
        this.TPM=tpm;
        this.Mon=m;
        this.Tue=tu;
        this.Wed=w;
        this.Thu=th;
        this.Fri=f;
        this.Sat=sa;
        this.Sun=su;
        this.AccSerId=asId;
        this.AccId=accId;
    }
}