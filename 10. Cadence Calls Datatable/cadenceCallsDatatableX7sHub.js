import LightningDatatable from 'lightning/datatable';
import nameColumn from './nameColumn.html';

export default class CadenceCallsDatatableX7sHub extends LightningDatatable {
  static customTypes = {
    nameColumn: {
      template: nameColumn,
      typeAttributes: ['name', 'id']
    }
  }
}