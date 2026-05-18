public class PaginationCC
{
    public List<Account> lAcc{get;set;}
    public List<WrapperClass> lWrapperClass{get;set;}
    public List<SelectOption> loption{get;set;}
    public String Qry;
    public Integer noOfRecords{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer deepesh{get;set;}
    
    public PaginationCC(){
        lAcc = new List<Account>();
        lWrapperClass = new List<WrapperClass>();
        loption = new List<SelectOption>();
        noOfRecords = 5;
        runQuery();
        loadNoOfRecPerPage();
    }
    public void runQuery(){
        /*lAcc = [SELECT id, name, phone FROM Account LIMIT 10];
        for(Account a: lAcc){
            lWrapperClass.add(new WrapperClass(a, true));
        }*/
        Qry = 'SELECT id, name, phone FROM Account LIMIT 200';
    }
    public void loadNoOfRecPerPage(){
        for(String s: System.Label.noOfRecPerPage.split(',')){
            loption.add(new SelectOption(s,s));
        }
    }
    public class WrapperClass{
        public Account acc{get;set;}
        public Boolean selected{get;set;}
        
        public WrapperClass(Account a, Boolean b){
            this.acc = a;
            this.selected = b;
        }
    }
    public ApexPages.StandardSetController stdSetController{
        get{
            if(stdSetController == null){
                stdSetController = new ApexPages.StandardSetController(Database.getQueryLocator(Qry));
            }
            stdSetController.setPageSize(noOfRecords);
            totalRecords= stdSetController.getResultSize();
            totalPages = Integer.valueOf(math.ceil(totalRecords/noOfRecords));
            return stdSetController;
        }
        set;
    }
    public List<WrapperClass> getAccounts(){
        lWrapperClass = new List<WrapperClass>();
        for(Account a : (List<Account>)stdSetController .getRecords()){
            lWrapperClass.add(new WrapperClass(a,false));
        }
        return lWrapperClass;
    }
    
    
}