/**
 *  @description       : Formula Evaluator Service LWC Component
    @author            : Logesh M
    @last modified on  : 09-28-2024
    @last modified by  : Logesh M
 */

/**
 * Description: Service Component for the Formulizer Information
 * @returns {Object}
 */
const getFormulizerData = () => {
   return {
        Title: 'Welcome To Formulizer!',
        Description: 'Formulizer is a powerful and intuitive app designed for Salesforce users who need to quickly and accurately evaluate formulas against specific records. With Formulizer, users can input formula text, select return type, select an object, and instantly receive calculated results based on the selected record. This tool simplifies the process of testing and validating formulas by providing real-time feedback, making it an essential utility for Salesforce admins, developers, and consultants.',
        Steps: 'Select the object, choose the return type, enter the formula, click "Formulize," and instantly see the formula response!',
        Examples: [
            {
                formulaTitle: '(Sample Formula) Account - Determine Customer Priority Based on Rating',
                formula: 'IF(TEXT(Rating) = "Hot", "Priority Customer", IF(TEXT(Rating) = "Warm", "Potential for Upsell", IF(TEXT(Rating) = "Cold", "Low Priority", "No Rating Provided")))',
                object: 'Account',
                returntype: 'String',
                expectedOutput: 'Returns a custom message based on the Rating field of the Account. If the rating is Hot, the output will be "Priority Customer"; if Warm, it will be "Potential for Upsell"; if Cold, it will be "Low Priority"; and if no rating is available, it will return "No Rating Provided".'
            },
            {
                formulaTitle: '(Sample Formula) Case - Calculating Response Due Date',
                formula: 'CASE( Priority, "High", CreatedDate + (1/24), "Medium", CreatedDate + (4/24), "Low", CreatedDate + (8/24), NULL)',
                object: 'Case',
                returntype: 'DateTime',
                expectedOutput: 'Calculates the Response Due Date based on Priority: adds 1 hour for High, 4 hours for Medium, 8 hours for Low; returns NULL if Priority is not set.'
            }
        ]
    }

}

/**
 * Description: Service Component for the Formulizer Return Types
 * @returns {Array}
 */
const getFormulaReturnTypes = () =>{
   return ['String', 'Integer', 'Time', 'DateTime', 'Boolean', 'Decimal', 'Double', 'Id', 'Date', 'Long'];
}

export {getFormulizerData, getFormulaReturnTypes}