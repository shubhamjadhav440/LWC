import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class accountOverviewListTableLocationColumn extends NavigationMixin(LightningElement) {
  @api locationName;
  @api locationId;

  handleAccountDetailNavigation(event){
    event.preventDefault();
    const recordId = event.target.dataset.recordId;
    /**
     * Navigate to the account record detail page.
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