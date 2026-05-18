global class ApexCallFromCustomButton {
    webservice static void print(Id accId){
        System.debug('@@@ : Yes ' + accId);
    }
}