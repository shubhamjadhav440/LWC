import { LightningElement, api, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { columns } from './columns';
import getCadenceCallLogsInPages from '@salesforce/apex/HubController_x7sHub.getCadenceCallLogsInPages';

export default class CadenceCallsTableX7sHub extends LightningElement {
  @api header = 'Call Log';
  @api headerIconLink = '/sfsites/c/resource/brandingIcons_x7sHub/icons/SVG/call-log_green.svg';
  @api headerIconAltText = 'Two people talking';
  @api noDataMessage = 'No cadence data found.';
  @api previousLabel = 'Prev';
  @api nextLabel = 'Next';
  @api recordsPerPage = 20; 
  @api paginationSize = 5; // number of pages to show at a time (number of page number buttons)
  @api allDataJson = '[]';
  @api userId = Id;

  isLoading = false;
  data;
  columns = columns;

  page = 1;    // current page number
  pages = [];  // size of data/perPage
  pageData=[];

  defaultSortDirection = 'asc';
  sortDirection = 'asc';
  sortedBy;

  _isPagesSet = false;
  _isLoaded = false;

  @wire(getCadenceCallLogsInPages, { userId: '$userId', pageNumber: '$page', recordsPerPage: '$recordsPerPage' })
  wiredGetTrainingDataInPages({ error, data }) {
      if (data) {
        const dataParsed = JSON.parse(data);
        const totalRecordsCount = dataParsed?.totalRecords;
        this.data = dataParsed?.records;


        if (!this._isPagesSet && totalRecordsCount) {
          this.setPages(totalRecordsCount);
          this.renderPaginationButtons();
          this._isPagesSet = true;
        }

        this.isLoading = false;
      } else if (error) {
        this.isLoading = false;
        console.error('getCadenceCallLogsInPages error', error);
      }
  }


  connectedCallback(){
    this.isLoading = true;
  }

  renderedCallback() {
    if (this._isLoaded) {
      return;
    }
    this._isLoaded = true;
    this.renderPaginationButtons();
  }

  /**
   * apply button variant 'brand' for current page
   */
   renderPaginationButtons = () => {
    this.template.querySelectorAll('button').forEach((btn) => {
      this.page === parseInt(btn.dataset.id, 10) ? btn.classList.add('slds-button_brand') : btn.classList.remove('slds-button_brand');
    });
  };

  setPages = (totalRecordsCount) => {
    const numberOfPages = Math.ceil(totalRecordsCount / this.recordsPerPage);

    for (let index = 1; index <= numberOfPages; index++) {
        this.pages.push(index);
    }
  };

  onNext = () => {
    ++this.page;
    this.renderPaginationButtons();
  };

  onPrev = () => {
    --this.page;
    this.renderPaginationButtons();
  };

  onPageClick = (e) => {
    this.page = parseInt(e.target.dataset.id, 10);
    this.renderPaginationButtons();
  };

  // get pagesList() {
  //   let mid = Math.floor(this.paginationSize / 2) + 1;
  //   if (this.page > mid) {
  //     return this.pages.slice(this.page - mid, this.page + mid - 1);
  //   }
  //   return this.pages.slice(0, this.paginationSize);
  // }
  get pagesList() {
    let mid = Math.floor(this.paginationSize / 2) + 1;
 
    if (this.page > mid) {

      let temp = this.pages.slice(this.page - mid, this.page + mid - 1);
      this.pageData=[];
      temp.forEach(elm => {
        if(this.page === 1 && elm === 1){
          let tempData = {'index': elm, 'class': 'slds-button slds-button_neutral slds-button_brand'}
          this.pageData.push(tempData)
        }else{
          let tempData = {'index': elm, 'class': 'slds-button slds-button_neutral'}
          this.pageData.push(tempData)
        }
      });
      return this.pageData;
    }

    let temp = this.pages.slice(0, this.paginationSize);
    this.pageData=[];
    temp.forEach(elm => {
      if(this.page === 1 && elm === 1){
        let tempData = {'index': elm, 'class': 'slds-button slds-button_neutral slds-button_brand'}
        this.pageData.push(tempData)
      }else{
        let tempData = {'index': elm, 'class': 'slds-button slds-button_neutral'}
        this.pageData.push(tempData)
      }
    });
    return this.pageData;
  }

  get hasPrev() {
    return this.page > 1;
  }

  get hasNext() {
    return this.page < this.pages.length
  }

  get isData() {
    return this.data && this.data.length > 0;
  }

  sortBy(field, reverse, primer) {
    const key = primer
      ? function (x) {
      return primer(x[field]);
      }
      : function (x) {
      return x[field];
    };

    return function (a, b) {
      a = key(a);
      b = key(b);
      return reverse * ((a > b) - (b > a));
    };
  }

  onHandleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.data];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
    this.data = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

}