/**
 * @isTest
 * Class for testing the DynamicFormulaEvaluator class.
 * 
 * @author      Logesh M
 * @description This test class contains unit tests for evaluating formulas and querying objects 
 *              through the DynamicFormulaEvaluator. It validates the formula output and error handling 
 *              for unsupported types.
 * @date        11-10-2024
 * @ownedBy     Logesh M
 */
@isTest
public class DynamicFormulaEvaluatorTest {

    /**
     * @testSetup
     * Method to set up test data for Account objects.
     * 
     * Creates a list of Account records for use in formula evaluations. This method is called once 
     * before any of the test methods to set up test data context.
     */
    @testSetup
    static void setupTestData() {
        // Create test Accounts for evaluation
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert testAccounts;
    }

    /**
     * Test method for evaluating a formula with valid input parameters.
     * 
     * This test verifies that the formula evaluation returns results for Account records and
     * ensures that formula output and SObject data are populated in each result.
     */
    @isTest
    static void testEvaluateFormulaWithValidInput() {
        // Test valid formula on Account records
        List<String> globalVars = new List<String>{'User', 'Organization'};
        
        Test.startTest();
        List<DynamicFormulaEvaluator.FormulaEvaluationResult> results = DynamicFormulaEvaluator.evaluateFormula(
            'Name & " - Test"', 
            'String', 
            'Account', 
            false, 
            globalVars
        );
        Test.stopTest();

        System.assert(results.size() > 0, 'Expected formula evaluation to return results');
        for (DynamicFormulaEvaluator.FormulaEvaluationResult result : results) {
            System.assert(result.formulaOutput != null, 'Expected formula output to be populated');
            System.assert(result.objData != null, 'Expected SObject data to be populated');
        }
    }

    /**
     * Test method for retrieving queryable objects.
     * 
     * Verifies that the list of queryable objects is non-null and contains at least one item. Each
     * EntityDefinition in the list is checked for a QualifiedAPIName and IsQueryable flag.
     */
    @isTest
    static void testGetQueryableObjects() {
        // Test retrieval of queryable objects
        Test.startTest();
        List<EntityDefinition> queryableObjects = DynamicFormulaEvaluator.getQueryableObjects();
        Test.stopTest();

        // Assertions to validate that results are as expected
        System.assertNotEquals(null, queryableObjects, 'Expected a non-null list of queryable objects');
        System.assert(queryableObjects.size() > 0, 'Expected at least one queryable object to be returned');
        
        // Further validate that each returned object has required fields
        for (EntityDefinition entityDef : queryableObjects) {
            System.assertNotEquals(null, entityDef.QualifiedAPIName, 'Expected each EntityDefinition to have a QualifiedAPIName');
            System.assertEquals(true, entityDef.IsQueryable, 'Expected each EntityDefinition to be queryable');
        }
    }

    /**
     * Test method for handling unsupported return types in formula evaluation.
     * 
     * This test ensures that an exception is thrown when an unsupported return type is used in the formula.
     * It captures and validates the exception message to confirm correct error handling.
     */
    @isTest
    static void testEvaluateFormulaWithUnsupportedReturnType() {
        Exception expectedException = null;
        try {
            Test.startTest();
            DynamicFormulaEvaluator.evaluateFormula(
                'Name', 
                'UnsupportedType', 
                'Account', 
                false, 
                new List<String>()
            );
            Test.stopTest();
            Assert.fail('The expected error did not happen');
        } catch (Exception e) {
            expectedException = e;
            System.assert(e.getMessage() != null, 'Expected unsupported return type error');
        }
    }
}