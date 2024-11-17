/**
* @description       : Class for evaluating dynamic formulas on Salesforce records.
*                      This utility class supports the evaluation of complex formulas across 
*                      various data types, custom global variables, and dynamic queries on 
*                      standard and custom Salesforce objects.
*
* @createdDate       : 11-07-2024
* @createdBy         : Logesh M
* @last modified on  : 11-10-2024
* @last modified by  : Logesh M
* 
* @owner             : Logesh M
* @version           : 1.0
*/
public with sharing class DynamicFormulaEvaluator {
    
    /**
* @description Evaluates a formula on records of a specified Salesforce object type.
*              Supports custom global variables and handles null values as specified.
* @param enteredFormula The formula to evaluate.
* @param returnType Expected return type of the formula.
* @param objType API name of the Salesforce object to query and evaluate the formula on.
* @param handleBlankValues Boolean indicating if numeric null values should be treated as zero.
* @param globalVariablesList List of global variables to be used in the formula.
* @return List of FormulaEvaluationResult objects, each containing the evaluated formula output and the associated record data.
* @throws AuraHandledException if formula evaluation or querying fails.
**/
    @AuraEnabled
    public static List<FormulaEvaluationResult> evaluateFormula(
        String enteredFormula,
        String returnType,
        String objType,
        Boolean handleBlankValues,
        List<String> globalVariablesList
    ) {
        List<FormulaEvaluationResult> evaluationResults = new List<FormulaEvaluationResult>();
        
        if (String.isBlank(enteredFormula) || String.isBlank(returnType) || String.isBlank(objType)) {
            throw new AuraHandledException('Formula, return type, and object type must be provided.');
        }
        
        try {
            Schema.sObjectType sObjectType = Schema.getGlobalDescribe().get(objType);
            if (sObjectType == null) {
                throw new AuraHandledException('Invalid object type: ' + objType);
            }
            
            // Initialize FormulaEval.FormulaInstance variables
            FormulaEval.FormulaInstance formulaWithGlobals;
            FormulaEval.FormulaInstance formulaWithoutGlobals;
            
            if (globalVariablesList != null && !globalVariablesList.isEmpty()) {
                formulaWithGlobals = Formula.builder()
                    .withReturnType(getFormulaReturnType(returnType))
                    .withType(sObjectType)
                    .withFormula(enteredFormula)
                    .treatNumericNullAsZero(handleBlankValues)
                    .withGlobalVariables(mapToFormulaGlobals(globalVariablesList))
                    .build();
            }
            
            // Default formula (in case no global variables are provided)
            String sanitizedFormula = sanitizeFormula(enteredFormula);
            String finalFormula = String.isBlank(sanitizedFormula) ? 'Id' : sanitizedFormula;
            
            formulaWithoutGlobals = Formula.builder()
                .withReturnType(getFormulaReturnType(returnType))
                .withType(sObjectType)
                .withFormula(finalFormula)
                .treatNumericNullAsZero(handleBlankValues)
                .build();
            
            // Generate dynamic SOQL based on referenced fields
            Set<String> referencedFields = formulaWithoutGlobals.getReferencedFields();
            String fieldList = String.join(referencedFields, ', ');
            
            if (String.isBlank(fieldList)) {
                fieldList = 'Id';
            }
            
            String queryStr = 'SELECT ' + fieldList + ' FROM ' + String.escapeSingleQuotes(objType) + ' ORDER BY CreatedDate DESC LIMIT 20';
            List<SObject> records = Database.query(queryStr, AccessLevel.USER_MODE);
            
            for (SObject record : records) {
                Object formulaOutput = evaluateFormulaInstance(formulaWithGlobals != null ? formulaWithGlobals : formulaWithoutGlobals, record);                
                FormulaEvaluationResult wrapper = new FormulaEvaluationResult();
                wrapper.objData = record;
                wrapper.formulaOutput = formulaOutput;
                evaluationResults.add(wrapper);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error evaluating formula: ' + e.getMessage());
        }
        
        return evaluationResults;
    }
    
    /**
* @description Helper method to sanitize the formula by removing invalid global variable references.
* @param formula The formula to sanitize.
* @return The sanitized formula string.
**/
    private static String sanitizeFormula(String formula) {
        String sanitized = formula.replaceAll('\\$\\w+\\.\\w+', '').replaceAll('&+', '&').replaceAll('^&|&$', '');
        return sanitized;
    }
    
    /**
* @description Evaluates a formula instance on a given SObject record.
* @param formulaInstance The formula instance to evaluate.
* @param record The SObject record on which the formula is evaluated.
* @return The result of the formula evaluation as a String.
**/
    private static Object evaluateFormulaInstance(FormulaEval.FormulaInstance formulaInstance, SObject record) {
        try {
            return formulaInstance.evaluate(record);
        } catch (Exception e) {
            throw new AuraHandledException('Error evaluating formula on record: ' + e.getMessage());
        }
    }
    
    /**
* @description Converts the input return type string to a FormulaEval.FormulaReturnType.
* @param inputType The return type as a string.
* @return The corresponding FormulaEval.FormulaReturnType enum.
**/
    public static FormulaEval.FormulaReturnType getFormulaReturnType(String inputType) {
        switch on inputType {
            when 'String' { return FormulaEval.FormulaReturnType.STRING; }
            when 'Integer' { return FormulaEval.FormulaReturnType.INTEGER; }
            when 'DateTime' { return FormulaEval.FormulaReturnType.DATETIME; }
            when 'Time' { return FormulaEval.FormulaReturnType.TIME; }
            when 'Date' { return FormulaEval.FormulaReturnType.DATE; }
            when 'Boolean' { return FormulaEval.FormulaReturnType.BOOLEAN; }
            when 'Decimal' { return FormulaEval.FormulaReturnType.DECIMAL; }
            when 'Double' { return FormulaEval.FormulaReturnType.DOUBLE; }
            when 'Id' { return FormulaEval.FormulaReturnType.ID; }
            when 'Long' { return FormulaEval.FormulaReturnType.LONG; }
            when else { throw new IllegalArgumentException('Unsupported return type: ' + inputType); }
        }
    }
    
    /**
* @description Maps input global variable names to FormulaEval.FormulaGlobal enums.
* @param globalVariables List of global variable names.
* @return List of FormulaEval.FormulaGlobal enums.
**/
    public static List<FormulaEval.FormulaGlobal> mapToFormulaGlobals(List<String> globalVariables) {
        List<FormulaEval.FormulaGlobal> formulaGlobals = new List<FormulaEval.FormulaGlobal>();
        
        if (globalVariables == null || globalVariables.isEmpty()) {
            return formulaGlobals;
        }
        
        for (String gVariable : globalVariables) {
            switch on gVariable {
                when 'Label' { formulaGlobals.add(FormulaEval.FormulaGlobal.LABEL); }
                when 'Organization' { formulaGlobals.add(FormulaEval.FormulaGlobal.ORGANIZATION); }
                when 'Permission' { formulaGlobals.add(FormulaEval.FormulaGlobal.PERMISSION); }
                when 'Profile' { formulaGlobals.add(FormulaEval.FormulaGlobal.PROFILE); }
                when 'Setup' { formulaGlobals.add(FormulaEval.FormulaGlobal.SETUP); }
                when 'System' { formulaGlobals.add(FormulaEval.FormulaGlobal.SYSTEM); }
                when 'User' { formulaGlobals.add(FormulaEval.FormulaGlobal.USER); }
                when  else { throw new IllegalArgumentException('Unsupported global variable: ' + gVariable); }
            }
        }
        
        return formulaGlobals;
    }
    
    /**
* @description Retrieves all queryable objects in the Salesforce org.
* @return List of EntityDefinition objects representing queryable objects.
* @throws AuraHandledException if the query fails.
**/
    @AuraEnabled
    public static List<EntityDefinition> getQueryableObjects() {
        try {
            return [SELECT QualifiedAPIName, IsQueryable FROM EntityDefinition WHERE IsQueryable = TRUE AND IsCustomizable = TRUE ORDER BY QualifiedAPIName];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving objects: ' + e.getMessage());
        }
    }
    
    /**
* @description Wrapper class to hold SObject data and evaluated formula output.
**/
    public class FormulaEvaluationResult {
        @AuraEnabled
        public SObject objData { get; set; }
        @AuraEnabled
        public Object formulaOutput { get; set; }
    }
}