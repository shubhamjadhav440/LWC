import LightningDatatable from 'lightning/datatable';
import locationColumn from './locationColumn.html';

export default class accountOverviewListDatatableX7sHub extends LightningDatatable {
  static customTypes = {

    locationColumn: {
      template: locationColumn,
      typeAttributes: ['locationName', 'locationId']
    }
  }
}