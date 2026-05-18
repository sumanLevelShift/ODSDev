public class AnimalLocator {
    
    public static String getAnimalNameById(Integer animalId){
        String animalName;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals/' + animalId);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserializes the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            // Cast the values in the 'animals' key as a list
            // Parse JSON response
            JSONParser parser = JSON.createParser(response.getBody());
            Double grandTotal = 0.0;
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'Name')) {
                        // Get the value.
                        parser.nextToken();
                        // Compute the grand total price for all invoices.
                        animalName = parser.getText();
                    }
            }
        }
        System.debug('##### Animal name is - ' + animalName);
        return animalName;
    }
}