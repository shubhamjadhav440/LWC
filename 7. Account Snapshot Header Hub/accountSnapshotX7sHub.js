import { LightningElement, api, wire } from 'lwc';
import { data } from './data'; // Mocked data
import getKeyMetricsSnapshot from '@salesforce/apex/HomePageController_x7sHub.getKeyMetricsSnapshot';
import getEdgeSnapshot from '@salesforce/apex/HomePageController_x7sHub.getEdgeSnapshot';
import getSnapshotsLastModifiedDate from '@salesforce/apex/HomePageController_x7sHub.getSnapshotsLastModifiedDate';
import userId from '@salesforce/user/Id';

export default class AccountSnapshotX7sHub extends LightningElement {
  @api numberOfMonthsOptions = 5;
  @api displayMetricsChange = false;
  @api keyMetricsHeader = 'Key Metrics';
  @api snapEdgeMetricsHeader = 'Snap Edge';
  @api financingDataPageLinkLabel = 'View All Financing Data';
  @api financingDataPageApi = 'loans_and_financing__c';
  @api snapEdgeDataPageLinkLabel = 'View All Snap EDGE Data';
  @api snapEdgeDataPageApi = 'snap_edge__c';
  @api loansFunded = 'Loans Funded';
  @api amountFinanced = 'Amount Financed';
  @api applications='Applications';
  @api approved='Approved';
  @api totalEdgeRevenue='Total Edge Revenue';
  @api totalEdgeRevenueYTD='Total Edge Revenue YTD';
  @api ofTotalRevenue='% of Total Revenue';
  @api lastMonth='Last Month: ';
  @api lastYear='Last Year: ';

  @api userId = userId;
  @api keyMetricsCurrentMonth;

  @api keyMetrics;
  @api snapEdgeMetrics;

  @api keyMetricsMonth;
  @api keyMetricsYear;
  @api snapEdgeMonth;
  @api snapEdgeYear;

  snapEdgeTotalPercentageCurrentMonth = 0;
  snapEdgeTotalPercentagePreviousMonth = 0;

  isLoading = false;
  isKeyMetricsLoading = false;
  isSnapEdgeMetricsLoading = false;

  @wire(getSnapshotsLastModifiedDate)
  wiredSnapshotsLastModifiedDate;

  get lastModifiedDate() {
    if (this.wiredSnapshotsLastModifiedDate && this.wiredSnapshotsLastModifiedDate.data) {
      return JSON.parse(this.wiredSnapshotsLastModifiedDate.data);
    }
    return false;
  }

  @wire(getKeyMetricsSnapshot, { userId: '$userId', monthNumber: '$keyMetricsMonth', year: '$keyMetricsYear' })
  wiredKeyMetricsSnapshot({ error, data }) {
    if (data) {
      this.isKeyMetricsLoading = false;
      const metrics = JSON.parse(data);
      if (!metrics.currentMonth || !metrics.previousMonth) {
        this.keyMetrics = false;
      } else {
        this.keyMetrics = this.setMetricDataObjectValues(metrics);
      }
    } else if (error) {
      this.isKeyMetricsLoading = false;
      console.error('getKeyMetricsSnapshot error', error);
    }
  }

  @wire(getEdgeSnapshot, { userId: '$userId', monthNumber: '$snapEdgeMonth', year: '$snapEdgeYear' })
  wiredEdgeSnapshot({ error, data }) {
    if (data) {
      this.isSnapEdgeMetricsLoading = false;
      const metrics = JSON.parse(data);
      this.snapEdgeMetrics = this.setMetricDataObjectValues(metrics);

      /**
       * Calculate % OF TOTAL REVENUE
       */
      const currentAmountFinanced = this.keyMetrics ? this.keyMetrics.currentMonth.amountFinanced : 0;
      if (metrics.currentMonthTotalEdgeRevenue >= 0 && currentAmountFinanced >= 0 ) {
        const currentTotalResult = Math.round((metrics.currentMonthTotalEdgeRevenue / currentAmountFinanced) * 100);

        if (isNaN(currentTotalResult)  || currentTotalResult === Infinity) {
          this.snapEdgeTotalPercentageCurrentMonth = 0;
        } else {
          this.snapEdgeTotalPercentageCurrentMonth = parseInt(currentTotalResult, 10);
        }
      }

      const previousAmountFinanced = this.keyMetrics ? this.keyMetrics.previousMonth.amountFinanced : 0;
      if (metrics.previousMonthTotalEdgeRevenue >= 0  && previousAmountFinanced >= 0 ) {
        const prevTotalResult = Math.ceil((metrics.previousMonthTotalEdgeRevenue / previousAmountFinanced) * 100);

        if (isNaN(prevTotalResult) || prevTotalResult === Infinity) {
          this.snapEdgeTotalPercentagePreviousMonth = 0;
        } else {
          this.snapEdgeTotalPercentagePreviousMonth = parseInt(prevTotalResult, 10);
        }
      }
    } else if (error) {
      this.isSnapEdgeMetricsLoading = false;
      console.error('getEdgeSnapshot error', error);
    }
  }

  connectedCallback(){
    this.isKeyMetricsLoading = true;
    this.isSnapEdgeMetricsLoading = true;
  }

  /**
   * Recursively check if a nested object has values that are not type 'number'
   * and replace them with 0 if so.
   * @param {*} obj 
   */
  setMetricDataObjectValues = (obj) => {
    const nestedObject = Object.assign({}, obj);

    Object.keys(obj).forEach(key => {
      if (typeof obj[key] === 'object' && obj[key] !== null) {
          this.setMetricDataObjectValues(obj[key])
      } else {
        if (typeof obj[key] !== 'number') {
          obj[key] = 0;
        }
      }
    });

    return nestedObject;
  }

  get isCurrency(){
    return true;
  }

  get isPercentage(){
    return true;
  }

  handleMonthChange(event) {
    this.keyMetricsMonth = parseInt(event.detail.month, 10);
    this.keyMetricsYear = event.detail.year;
    this.snapEdgeMonth = parseInt(event.detail.month, 10);
    this.snapEdgeYear = event.detail.year;
  }

}