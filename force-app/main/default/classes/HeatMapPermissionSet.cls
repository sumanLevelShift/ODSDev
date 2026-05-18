public class HeatMapPermissionSet {
    Public static void createPermissionSet(string label,string name){
        try{
            
            PermissionSet ps = new PermissionSet();
            ps.Label=label;
            ps.Name=name;
            insert ps;
            
            ConnectedApplication ca=[SELECT Id,name FROM ConnectedApplication where Name=:'DemandBlue Heat Map' limit 1];
            
            SetupEntityAccess sea = new SetupEntityAccess(ParentId = ps.Id,SetupEntityId = ca.Id);
            insert sea; 
        }catch(Exception e){
            System.debug('message -'+e.getMessage());
            System.debug('message line number -'+e.getLineNumber());
        }
    }
    Public static void removePermissionSet(string name){
        try{
            PermissionSet ps=[Select id,Label,Name From PermissionSet where Name=:name limit 1];
            ConnectedApplication ca=[SELECT Id,name FROM ConnectedApplication where Name=:'DemandBlue Heat Map' limit 1];
            SetupEntityAccess sea=[Select id,ParentId,SetupEntityId From SetupEntityAccess where ParentId =: ps.Id and SetupEntityId =: ca.Id limit 1];
            delete sea; 
            delete ps;
        }catch(Exception e){
            System.debug('message -'+e.getMessage());
            System.debug('message line number -'+e.getLineNumber());
        }
    }
    }