@IsTest
public class DistanceCalculatorControllerTest {
    @IsTest
    static void testGetTravelDetails() {
        // Set up the mock callout
        Test.setMock(HttpCalloutMock.class, new DistanceCalculatorMock());
        
        // Ensure there are existing custom metadata records
        List<TravelRates__mdt> rates = [SELECT DeveloperName, RatePerMile__c FROM TravelRates__mdt];
        System.assertNotEquals(0, rates.size(), 'No custom metadata records found for TravelRates__mdt');
        
        // Define the origin and destination addresses
        String origin = 'Anaheim, CA 92802';
        String destination = '400 Broad St, Seattle, WA 98109';

        // Start test context
        Test.startTest();

        // Call the method and verify results
        Map<String, Object> travelDetails = DistanceCalculatorController.getTravelDetails(origin, destination);

        // Stop test context
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, travelDetails, 'Result should not be null');
        System.assertEquals(1160.0, travelDetails.get('distance'), 'Distance should be 1160 miles');
        System.assertEquals('17 hours 45 mins', travelDetails.get('travelTime'), 'Travel time should be 17 hours 45 mins');
        
        Map<String, Decimal> travelCosts = (Map<String, Decimal>) travelDetails.get('travelCosts');
        System.assertEquals(rates.size(), travelCosts.size(), 'There should be a travel cost for each rate');
        
        // Define a tolerance for comparing decimal values
        Decimal tolerance = 0.01; // Example tolerance of two decimal places
        
        for (TravelRates__mdt rate : rates) {
            Decimal expectedCost = 1160.0 * rate.RatePerMile__c;
            Decimal actualCost = travelCosts.get(rate.DeveloperName);
            
            // Compare expected and actual costs within tolerance
            System.assertEquals(expectedCost.setScale(1), actualCost.setScale(1), 'Travel cost should match the expected cost');
        }
    }
}