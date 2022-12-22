import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CadenceCallsTableNameColumn extends NavigationMixin(LightningElement) {
  @api name;
  @api cadenceId;
  @api rowId;

  handleCadenceDetailNavigation(event){
    event.preventDefault();
    const recordId = event.target.dataset.recordId;
    /**
     * Navigate to the contact record detail page.
     */
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId,
        actionName: 'view'
      },
    });
  }
}