import { LightningElement } from 'lwc';

export default class FormulaEvaluatorHeader extends LightningElement {

    openModal = false;

    /**
     * Opens the modal.
     */
    aboutSectionHandler(){
         this.openModal = true;
    }

    /**
     * Closes the modal.
     */

    modalCloseHandler(){
        this.openModal = false;
    }
}