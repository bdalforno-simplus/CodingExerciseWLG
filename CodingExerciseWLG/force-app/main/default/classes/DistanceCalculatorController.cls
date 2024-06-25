public with sharing class DistanceCalculatorController {
    private static final String GOOGLE_MAPS_API_KEY = API_Configuration__c.getOrgDefaults().GoogleMapsAPIKey__c;
    public static String vHash = 'QnJpYW4gRGFsZm9ybm8K';

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getTravelDetails(String origin, String destination) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://maps.googleapis.com/maps/api/distancematrix/json?origins=' + EncodingUtil.urlEncode(origin, 'UTF-8') + '&destinations=' + EncodingUtil.urlEncode(destination, 'UTF-8') + '&key=' + GOOGLE_MAPS_API_KEY);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            // Check if the response contains the expected data and drill down to get the distance and duration
            if (result.containsKey('rows')) {
                List<Object> rows = (List<Object>) result.get('rows');
                if (!rows.isEmpty()) {
                    Map<String, Object> firstRow = (Map<String, Object>) rows.get(0);
                    List<Object> elements = (List<Object>) firstRow.get('elements');
                    if (!elements.isEmpty()) {
                        Map<String, Object> firstElement = (Map<String, Object>) elements.get(0);
                        if (firstElement.containsKey('distance') && firstElement.containsKey('duration')) {
                            Map<String, Object> distanceData = (Map<String, Object>) firstElement.get('distance');
                            Map<String, Object> durationData = (Map<String, Object>) firstElement.get('duration');
                            Decimal distance = Decimal.valueOf((Integer) distanceData.get('value')) / 1609.34; // Convert meters to miles
                            String travelTime = (String) durationData.get('text');

                            // Calculate cost for each mode of transportation
                            Map<String, Decimal> travelCosts = new Map<String, Decimal>();
                            List<TravelRates__mdt> rates = [SELECT Mode__c, RatePerMile__c FROM TravelRates__mdt];
                            for (TravelRates__mdt rate : rates) {
                                Decimal costOfTravel = distance * rate.RatePerMile__c;
                                travelCosts.put(rate.Mode__c, costOfTravel.setScale(2));
                            }
                            
                            // Return the travel details
                            return new Map<String, Object>{
                                'distance' => distance.setScale(2),
                                'travelTime' => travelTime,
                                'travelCosts' => travelCosts
                            };
                        }
                    }
                }
            }
        }
        throw new AuraHandledException('Unable to fetch travel details. Please check the addresses and try again.');
    }
}