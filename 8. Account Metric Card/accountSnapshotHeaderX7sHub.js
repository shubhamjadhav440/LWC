import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { fireEvent, registerListener } from 'c/x7sShrUtils';
import { CurrentPageReference } from 'lightning/navigation';

export default class AccountSnapshotHeaderX7sHub extends NavigationMixin(LightningElement) {
  @api header;
  @api viewAllLabel;
  @api viewAllPageApiName;
  @api numberOfMonthsOptions;
  @api metricsType;
  @api noComboBox = false;

  @wire(CurrentPageReference) pageRef;

  monthOptions;
  selectedMonth;
  monthText = '';

  connectedCallback() {
    this.generateMonthOptions();
    this.setInitialMonthYear();
    registerListener('updatesnapmonth', this.handleSiblingEvent, this);
  }

  handlePageNavigate(event) {
    event.stopPropagation();
    this[NavigationMixin.Navigate]({
      type: 'comm__namedPage',
      attributes: {
        name: this.viewAllPageApiName,
      }
    });
  }

  generateMonthOptions(){
    const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    const months = [];
    const today = new Date();
    let date;
    let month;
    let year;
    
    // Picklist options for previous months including current month. Min 3.
    const iterator = this.numberOfMonthsOptions > 3 ? this.numberOfMonthsOptions : 3;
    for (let i = iterator; i >= 0; i -= 1) {
      date = new Date(today.getFullYear(), today.getMonth() - i, 1);
      month = monthNames[date.getMonth()];
      year = date.getFullYear();
      months.push({ label: `${month} ${year}`, value: `${(date.getMonth() + 1)}`, year: year });
    }

    this.monthOptions = [...months].reverse();
    this.selectedMonth = this.monthOptions[0].value;
    this.monthText = this.monthOptions[0].label;
  }

  setInitialMonthYear() {   
    this.dispatchEvent(new CustomEvent('monthchange', { detail: { 
        month: this.monthOptions[0].value, // Type: String.
        year:  this.monthOptions[0].year, // Type: Integer.
        type: this.metricsType // Type: String.
      } 
    }));

  }

  fireMonthTextEvent(){
    fireEvent(this.pageRef, 'updatesnapmonth', this.monthText);
  }

  handleChange(event) {
    this.selectedMonth = event.detail.value;
    const activeMonth = this.monthOptions.find(month => month.value === this.selectedMonth);
    this.monthText = activeMonth.label;
    this.fireMonthTextEvent();

    this.dispatchEvent(new CustomEvent('monthchange', { detail: { 
        month: event.detail.value, // Type: String.
        year: activeMonth?.year, // Type: Integer.
        type: this.metricsType // Type: String.
      } 
    }));
  }

  handleSiblingEvent(siblingData){
    this.monthText = siblingData;
  }
}