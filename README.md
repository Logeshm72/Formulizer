**What is Formulizer?
**

Formulizer is a powerful, intuitive Salesforce app that allows users to test and validate formulas directly against real records, no more repetitive steps of saving, deploying, and verifying formulas in Salesforce. Formulizer is a productivity-boosting tool designed for admins, developers, and consultants. It streamlines the formula testing process, offering real-time evaluation and results, making it faster and easier to refine formulas while reducing errors.


**How to Use Formulizer?
**

Step 1: Install Formulizer
Choose the appropriate installation link based on your Salesforce environment:

Production/Developer: [Install Formulizer](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tdM00000064iTQAQ)
Sandbox: [Install Formulizer](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tdM00000064iTQAQ)
Step 2: Assign Permissions
Add the user to the Formulizer Access Permission Set to grant access.
Step 3: Access the Formulizer Tab
Navigate to the Formulizer tab in Salesforce to start testing your formulas.


**How Formulizer Works?
**
![Salesforce Formulizer](https://github.com/user-attachments/assets/e640e613-fdc9-47e6-bd7a-2a21ac460f43)


Input Your Formula Text
Type or paste the formula directly into the Formulizer’s input box.
Select the Return Type
Choose the expected return type (e.g., String, Integer, Boolean, etc.).
Pick the Salesforce Object
Select the relevant object to evaluate the formula against (e.g., Account, Opportunity, or custom objects).
Get Results Instantly
Choose a record to test your formula, and the results will appear in real-time without any need to deploy changes.

**Why Formulizer is BETA?
**
The core functionality of Formulizer relies on the [FormulaEval namespace](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_namespace_formulaeval.htm) provided by Salesforce, which is itself in BETA. Once Salesforce promotes FormulaEval to General Availability (GA), Formulizer will also follow suit.

**Anatomy of Formulizer
**
1. Object Picklist
Only standard and custom objects that are both queryable and customizable are included in the picklist.

2. Return Type
Supported return types include: String, Integer, Time, DateTime, Boolean, Decimal, Double, Id, Date, and Long.

3. Enter Your Formula
This is the input area where you can enter a formula to test its functionality on existing records.

Formula Limits:
Bound by the Salesforce formula character limit (3,900 characters), including spaces, return characters, and comments.
Note: The compile size limit does not apply.
4. Handle Blank Field Values in Formula
Checked: Blank fields are treated as zero.
Unchecked: Blank fields are treated as blank.
5. Supported Global Variables
Global variables supported by Formulizer: Organization, Permission, Profile, Setup, System, and User (e.g., $User.Email).

6. Results Section
If the formula compiles successfully, results are displayed in a Lightning DataTable format for easy review and analysis.


**Constraints**

1. OLS (Object-Level Security)
Users without permission to view or edit an object cannot access its records or fields through Formulizer.
2. FLS (Field-Level Security)
Specific fields within an object are excluded if users do not have access to view or edit them.
3. Limit of 20 Records
Formulizer processes and evaluates only 20 records per operation.
Reason for Limit:
Performance: Ensures efficient processing.
Consistency: Guarantees predictable and stable behavior.
Implication: Only the first 20 records (ordered by CreatedDate DESC) are evaluated, encouraging users to refine their queries to focus on the most relevant data.


**Known Limitations
**
1. Unsupported Global Variables
Formulizer does not support:

API: Integration-related variables.
Custom Metadata: Dynamic configuration references.
User Role: Role-specific logic in formulas.
2. No Comments Allowed
Comments must be removed from formulas for successful compilation.

