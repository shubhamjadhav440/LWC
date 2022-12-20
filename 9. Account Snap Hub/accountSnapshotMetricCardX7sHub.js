import { LightningElement, api } from 'lwc';
import { numberWithCommas } from 'c/x7sShrUtils';
import BRANDING_ICONS from '@salesforce/resourceUrl/brandingIcons_x7sHub';

export default class AccountSnapshotMetricCardX7sHub extends LightningElement {
  @api currentValue;
  @api previousValue;
  @api isCurrency = false;
  @api isPercentage = false;
  @api header;
  @api previousMetricLabel;
  @api displayMetricsChange;

  metricsUp = BRANDING_ICONS + '/icons/SVG/metrics-up_green.svg';
  metricsDown = BRANDING_ICONS + '/icons/SVG/metrics-down_red.svg';

  get currentMetricValue(){
    if (this.isCurrency) {
      return this.addCommas(parseInt(this.currentValue, 10));
    }
    if (this.isPercentage) {
      return `${parseInt(this.currentValue, 10)}%`;
    }
    return numberWithCommas(parseInt(this.currentValue, 10));
  }

  get previousMetricValue(){
    if (this.isCurrency) {
      return this.convertToUSD(parseInt(this.previousValue, 10));
    }
    if (this.isPercentage) {
      return `${parseInt(this.previousValue, 10)}%`;
    }
    return numberWithCommas(parseInt(this.previousValue, 10));
  }

  get metricsDirectionImage() {
    if (!this.displayMetricsChange) return false;

    if (this.currentValue > this.previousValue) {
      return this.metricsUp;
    }
    if (this.currentValue < this.previousValue) {
      return this.metricsDown;
    }
    return null;
  }

  get metricsDirectionImageAltText() {
    if (this.currentValue > this.previousValue) {
      return 'Trending Up';
    } else if (this.currentValue < this.previousValue) {
      return 'Trending Down';
    }
  }

  get diffPercentage() {
    const a = parseInt(this.currentValue, 10);
    const b = parseInt(this.previousValue, 10);
    return this.generateDiffPercent(a, b);
  }

  /**
   * Utility functions.
   */
  generateDiffPercent(a, b) {
    const diffBA = Math.round(((b - a) * 100) / a);
    const diffAB = Math.round(((a - b) * 100) / b );

    if (!Number.isFinite(diffBA) || !Number.isFinite(diffAB)) {
      return '100%';
    }
    return  (a < b ? '-' + diffBA : '+' + diffAB) + "%";
  }

  convertToUSD(value){
    return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' })
    .format(value)
    .replace(/(\.|,)00$/g, '');
  }

  addCommas(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
  
}