trigger UpdateInstanceName on Case (after insert) {
    List<Case> Updateinstance = new List<Case>();
    string defaultMaildID = system.label.SF_Incidents_From_Email_Id;
    for (Case c : Trigger.new){
        if(c.SuppliedEmail == defaultMaildID)
        {
            string a=c.Description;
            String [] arrayOfProducts = new List<String>();
            String [] arrayOfProductslower = new List<String>();
            String [] arrayOfPro = new List<String>();
            arrayOfProducts = a.split('\n');  
            arrayOfProductslower = a.toLowerCase().split('\n');
            integer s = arrayOfProductslower.indexOf('impacted instances')+1;
            if(s<=0){
                s = arrayOfProductslower.indexOf('impacted instances:')+1;
            }
            integer e = arrayOfProductslower.indexOf('impacted services') ;
            
            
            if(e<=0){
                e = arrayOfProductslower.indexOf('impacted services:') ;
            }
            for(integer i=s;i< e;i++)
            {
                if(arrayOfProducts[i] != '')
                {
                    arrayOfPro.Add(arrayOfProducts[i]);
                }
            }
            string databinded = string.join(arrayOfPro,',');
            Case cs = new Case();
            cs.Instance_Names__c= databinded;
            cs.Id=c.Id;
            cs.Status = 'closed';
            Updateinstance.add(cs);   
        }
    }
     update Updateinstance;
}