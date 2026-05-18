public class ODS_Invoice_SubscriptionEC
{
    public String terms {get; set;}
    public String accServId {get; set;}
    public String BillStreet {get; set;}
    public String BillCity {get; set;}
    public String BillState {get; set;}
    public String BillCountry {get; set;}
    public String BillPostalCode {get; set;}
    public Double totAmt {get; set;}
    public List<wrapInvComp> lInvTablComp {get; set;}
    public String currentDate {get{return String.valueOf(String.valueOf(System.today().month()+'/'+System.today().day()+'/'+System.today().year()));} set;}
    public String invNumb {get; set;}
    public String accNumb {get; set;}
    public String dueDate {get{return String.valueOf(System.today().addMonths(1).month()+'/'+System.today().day()+'/'+System.today().year());} set;}
    public String billPerd {get;set;}
    public String refr {get;set;}
    public String project {get;set;}
    public String mont {get;set;}
    
    Double rate = 0;
    
    public ODS_Invoice_SubscriptionEC() {
        accServId = String.valueOf(ApexPages.currentPage().getParameters().get('AccServId'));
        terms = String.valueOf(ApexPages.currentPage().getParameters().get('term'));
        String descr = 'Subscription fee';        
        BillStreet = String.valueOf(ApexPages.currentPage().getParameters().get('billToStr'));
        BillCity = String.valueOf(ApexPages.currentPage().getParameters().get('billToCty'));
        BillState = String.valueOf(ApexPages.currentPage().getParameters().get('billToStat'));
        BillCountry = String.valueOf(ApexPages.currentPage().getParameters().get('billToCtry'));
        BillPostalCode = String.valueOf(ApexPages.currentPage().getParameters().get('billToPcod'));
        invNumb = String.valueOf(ApexPages.currentPage().getParameters().get('invNumb'));
        accNumb = String.valueOf(ApexPages.currentPage().getParameters().get('accNumb'));
        billPerd = String.valueOf(ApexPages.currentPage().getParameters().get('billPerd'));
        String sDate = ApexPages.currentPage().getParameters().get('startDt');
        String eDate = ApexPages.currentPage().getParameters().get('endDt');
        String subscType = String.valueOf(ApexPages.currentPage().getParameters().get('subsType'));
        refr = ApexPages.currentPage().getParameters().get('ref');
        project = ApexPages.currentPage().getParameters().get('proj');
        mont = ApexPages.currentPage().getParameters().get('mnths');
        
        Date startDate = Date.valueOf(sDate);
        Date endDate = Date.valueOf(eDate);
        //Integer monthsBtw = startDate.monthsBetween(endDate);
        Integer monthsBtw = String.isNotBlank(mont) ? Integer.valueOf(mont) : 1;
        Double contractMult = 0;
            if(monthsBtw != null && monthsBtw != 0) contractMult = monthsBtw;
               
        String rte = ApexPages.currentPage().getParameters().get('hrlyRate');
            if(String.isNotBlank(rte)) rte = rte; else rte='0';   
        rate = Double.valueOf(rte);
        String dis = ApexPages.currentPage().getParameters().get('discFee'); 
            if(String.isNotBlank(dis)) dis = dis; else dis='0';   
        Double discount = Double.valueOf(dis);
        
        System.debug('@@Acc Serv Id recvd: '+accServId);
        System.debug('@@Inv nmber recvd: '+invNumb);
        System.debug('@@Billing perd recvd: '+billPerd);
        System.debug('@@SubsType recvd: '+subscType);
        System.debug('@@hrly rate recvd: '+rte);
        System.debug('@@Discount recvd: '+dis);
        
        Double finalAmt = 0;
        
        lInvTablComp = new List<wrapInvComp>();        
        if(discount != 0) {
            if(subscType.equalsIgnoreCase('upfront')) {
                finalAmt = (rate*contractMult);
                descr = descr+' (x'+String.valueOf(Integer.valueOf(contractMult))+' months)';
            }else {
                finalAmt = (rate);
            }
            lInvTablComp.add(new wrapInvComp('1',descr,String.valueOf(rate),String.valueOf(finalAmt)));
            lInvTablComp.add(new wrapInvComp('','LESS: Discount fee',String.valueOf(discount),String.valueOf(-discount)));
            totAmt = calcTotalAmt(lInvTablComp);
        }else {
            if(subscType.equalsIgnoreCase('upfront')) {
                finalAmt = (rate*contractMult);
                descr = descr+' (x'+String.valueOf(Integer.valueOf(contractMult))+' months)';
            }else {
                finalAmt = rate;
            }
            lInvTablComp.add(new wrapInvComp('1',descr,String.valueOf(rate),String.valueOf(finalAmt)));
            totAmt = calcTotalAmt(lInvTablComp);
        }
        System.debug('@@Total amount calculated: '+totAmt);
        System.debug('@@Constructed wrapper: '+lInvTablComp);    
    }
    
    private Double calcTotalAmt(List<wrapInvComp> lWrap) {
        System.debug('@@received invoice list:'+lWrap);
        Double sumAmt = 0;
        if(!lWrap.isEmpty()) {
            for(wrapInvComp w:lWrap) {
                if(String.isNotBlank(w.amount)) sumAmt+=Double.valueOf(w.amount);
            }
        }
        return sumAmt;
    }
   
    //Final wrapper with complete line item numbers
    public class wrapInvComp
    {
        public String itemNum {get;set;}
        public String description {get; set;}
        public String rate {get; set;}
        public String amount {get; set;}
        
        public wrapInvComp(String itmNo,String description,String rate,String amount) {
            this.itemNum = itmNo;
            this.description = description;
            this.rate = rate;
            this.amount = amount;
        }
    }        
}