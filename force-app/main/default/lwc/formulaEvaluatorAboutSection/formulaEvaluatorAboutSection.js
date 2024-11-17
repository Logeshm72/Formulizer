import { LightningElement } from 'lwc';
import { getFormulizerData } from 'c/formulaEvaluatorService';

export default class FormulaEvaluatorAboutSection extends LightningElement {

    /**
     * Sets the Formulizer data for the component.
     */
    formulizerDetails = getFormulizerData();

    /**
     * Closes the modal.
     */
    closeHandler(){
        this.dispatchEvent(new CustomEvent('close'))
    }
}