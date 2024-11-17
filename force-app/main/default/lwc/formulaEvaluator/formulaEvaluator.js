import { LightningElement } from 'lwc';
import formulaResults from '@salesforce/apex/DynamicFormulaEvaluator.evaluateFormula';
import LightningAlert from 'lightning/alert';
import { getFormulaReturnTypes } from 'c/formulaEvaluatorService';
import getAllObjects from '@salesforce/apex/DynamicFormulaEvaluator.getQueryableObjects';

export default class FormulaEvaluator extends LightningElement {
    /**
     * Initializes the variables used in the component.
     */
    formulaResults = [];
    isLoading = false;
    columns = [];
    returnTypeOptions = [];
    objectOptions = [];
    formulizerResults = undefined;
    copied = false;
    copyFormulaMessage = 'Copy Formula!';
    iconName = 'utility:copy_to_clipboard';
    returnDataTypes = getFormulaReturnTypes();
    selectedObject = '';
    selectedReturnType = '';
    enteredFormula = '';
    handleBlankValues = false;

    /**
     * ConnectedCallback method called when component is initialized. Sets up return type options and fetches objects.
     */
    connectedCallback() {
        this.initializeReturnTypeOptions();
        this.fetchObjects();
    }

    /**
     * Initializes the return type options using data fetched from the imported service.
     */
    initializeReturnTypeOptions() {
        this.returnTypeOptions = this.returnDataTypes.map(label => ({ label, value: label }));
    }

    /**
     * Fetches Salesforce objects for selection. Calls Apex method to retrieve objects, maps them to options format.
     */
    fetchObjects() {
        getAllObjects()
            .then(results => {
                this.objectOptions = results.map(objName => ({
                    label: objName.QualifiedApiName,
                    value: objName.QualifiedApiName
                }));
            })
            .catch(error => {
                this.handleAlertClick(error.body.message, 'error', 'Error retrieving object list');
            });
    }

    /**
     * Returns whether the formulizer button should be disabled based on the completeness of required inputs.
     */
    get isFormulizerButtonDisabled() {
        return !(this.selectedObject && this.selectedReturnType && this.enteredFormula);
    }

    /**
     * Handles changes to input fields, updating the corresponding properties based on field label.
     * @param {Event} event - The change event from the input fields.
     */
    handleInputChange(event) {
        const fieldName = event.target.label;
        switch (fieldName) {
            case 'Object':
                this.selectedObject = event.target.value;
                break;
            case 'Formula Return Type':
                this.selectedReturnType = event.target.value;
                break;
            case 'Enter Your Formula':
                this.enteredFormula = event.target.value;
                break;
            case 'Handle Blank Field Values in Formula':
                this.handleBlankValues = event.target.checked;
                break;
        }
    }

    /**
     * Copies the entered formula to the clipboard and updates the copy message.
     */
    copyToClipboard() {
        const formulaToCopy = this.enteredFormula || 'No formula entered';
        this.copyFormulaMessage = 'Formula Copied!';
    
        navigator.clipboard.writeText(formulaToCopy).then(() => {
            this.iconName = 'utility:success';
    
            // Revert icon back to the original after 2 seconds
            setTimeout(() => {
                this.iconName = 'utility:copy_to_clipboard';
                this.copyFormulaMessage = 'Copy formula!';
            }, 2000);
        }).catch(error => {
            const errorMessage = error.message || 'Failed to copy formula';
            this.handleAlertClick(errorMessage, 'error', 'Copy Error');
        });
    }

    /**
     * Handles the formulizer button click event. Processes and sends data to Apex to evaluate formula.
     */
    async formulizeHandler() {
        const globalVariableMatches = (this.enteredFormula.match(/\$[a-zA-Z]+/g) || []).map(match => match.slice(1));
        this.isLoading = true;

        try {
            this.formulaResults = await formulaResults({
                enteredFormula: this.enteredFormula,
                returnType: this.selectedReturnType,
                objType: this.selectedObject,
                handleBlankValues: this.handleBlankValues,
                globalVariablesList: JSON.stringify(globalVariableMatches)
            });

            this.prepareColumnsAndData();
            this.isLoading = false;
        } catch (error) {
            this.formulaResults = undefined;
            this.handleAlertClick(error.body.message, 'error', 'Formula Validation Error');
        }
    }

    /**
     * Prepares columns and data for display based on the result from Apex. 
     * Flattens nested data for compatibility with datatable component.
     */
    prepareColumnsAndData() {
        const allKeys = new Set();

        // Helper function to flatten nested objects
        const flattenObject = (obj, prefix = '') => {
            return Object.entries(obj).reduce((acc, [key, value]) => {
                const fullKey = prefix ? `${prefix}.${key}` : key;
                if (value && typeof value === 'object') {
                    Object.assign(acc, flattenObject(value, fullKey));
                } else {
                    acc[fullKey] = value;
                }
                return acc;
            }, {});
        };

        this.formulaResults.forEach(item => {
            const flattenedData = flattenObject(item.objData);
            Object.keys(flattenedData).forEach(key => allKeys.add(key));
        });

        this.columns = Array.from(allKeys).map(key => ({ label: key, fieldName: key }));
        this.columns.push({ label: 'Formula Response', fieldName: 'formulaResponse', type: 'text' });

        this.formulizerResults = this.formulaResults.map(item => ({
            ...flattenObject(item.objData),
            formulaResponse: item.formulaOutput
        }));
    }

    /**
     * Shows an alert with a custom message, theme, and label.
     * @param {string} message - The alert message to be displayed.
     * @param {string} theme - The theme of the alert ('error', 'info', etc.).
     * @param {string} label - The label for the alert.
     */
    handleAlertClick(message, theme, label) {
        LightningAlert.open({
            message,
            theme,
            label
        }).then((result) => { //Alert has been closed
            this.isLoading = false;
        });
    }
}