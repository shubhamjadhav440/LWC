import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import cloneEnterpriseCall from '@salesforce/apex/EnterpriseCallController_x7sHub.cloneEnterpriseCall';

export default class CloneEnterpriseCallQuickActionX7sHub extends NavigationMixin(LightningElement) {
  @api recordId;
  statusList = [];

  handleStatusCheck(event) {
    if (event.target.checked) {
      this.statusList.push(event.target.label);
    } else if (this.statusList.indexOf(event.target.label) != -1) {
      this.statusList = this.statusList.filter(e => e !== event.target.label);
    }
  }

  submitReceiver(e) {
    if (this.statusList.length > 0) {
      this.template.querySelector('.status_list_error').style.display = 'none';
      this.template.querySelector('.post_submit_spinner').style.display = 'block';

      cloneEnterpriseCall({recordId: this.recordId, jsonStatusList: JSON.stringify(this.statusList)})
        .then(result => {
          this.navigateToNewRecordPage(result);
        })
        .catch(error => {
          console.log('error:', error);
          this.template.querySelector('.status_list_error').textContent = error.body;
          this.template.querySelector('.status_list_error').style.display = 'block';
          this.template.querySelector('.post_submit_spinner').style.display = 'none';
        });
    } else {
      e.preventDefault();
      this.template.querySelector('.status_list_error').textContent = 'You must check at least 1 box';
      this.template.querySelector('.status_list_error').style.display = 'block';
    }
  }

  navigateToNewRecordPage(recordPageId) {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
          recordId: recordPageId,
          objectApiName: 'Enterprise_Call__c',
          actionName: 'view'
      }
  });
  }
}