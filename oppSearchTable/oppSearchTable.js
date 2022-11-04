import { LightningElement, api, track, wire } from 'lwc';
import getOpp from '@salesforce/apex/oppSearchTable.searchWord';
import getOpp1 from '@salesforce/apex/oppSearchTable.showD';

/*
const columns = [
    {label : 'Name', fieldName : 'Name'},
    {label : 'Amount', fieldName : 'Amount'},
    {label : 'Stage', fieldName : 'StageName'},
    {label : 'Description', fieldName : 'Description'},
    {label : 'Close Date', fieldName : 'CloseDate'}, 
    {label : 'Account', fieldName : 'Account.Name'},  
    {label : 'Next Step', fieldName : 'Next Step'},
   ];
*/

const columns = [
         {label : 'Name' , fieldName : 'oName'},
         {label : 'Amount' , fieldName : 'oAmount'},
         {label : 'Stage' , fieldName : 'oStageName'},
         {label : 'Description' , fieldName : 'oDescription'},
         {label : 'Close Date' , fieldName : 'oCloseDate'},
         {label : 'Account' , fieldName : 'oAccName'},
         {label : 'Next Step' , fieldName : 'oNextStep'},
];

   export default class OppSearchTable extends LightningElement {
 
    odata = [];
    searchK = '';
    @track columns = columns;  


    @wire (getOpp1)
    opData({error,data}){
    if(data){
           console.log(data);
           console.log('All Data');
           this.odata = data;
           this.error = undefined;
       }
       if(error){
           this.error = error;
           this.odata = undefined;
       }
   }


  


/*
exportData(){
    // Prepare a html table
    let doc = '<table>';
    // Add styles for the table
    doc += '<style>';
    doc += 'table, th, td {';
    doc += '    border: 1px solid black;';
    doc += '    border-collapse: collapse;';
    doc += '}';          
    doc += '</style>';
    // Add all the Table Headers
    doc += '<tr>';
    this.columnHeader.forEach(element => {            
        doc += '<th>'+ element +'</th>'           
    });
    doc += '</tr>';
    // Add the data rows
    this.odata.forEach(record => {
        doc += '<tr>';
        doc += '<th>'+record.Id+'</th>'; 
        doc += '<th>'+record.FirstName+'</th>'; 
        doc += '<th>'+record.LastName+'</th>';
        doc += '<th>'+record.Email+'</th>'; 
        doc += '</tr>';
    });
    doc += '</table>';
    var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
    let downloadElement = document.createElement('a');
    downloadElement.href = element;
    downloadElement.target = '_self';
    // use .csv as extension on below line if you want to export data as csv
    downloadElement.download = 'Contact Data.xls';
    document.body.appendChild(downloadElement);
    downloadElement.click();
}

 */

    csvGenerator(){

    }

    handleChange(event){
        this.searchK = event.target.value;
        console.log(this.searchK); 
        this.searchOpps();
    }
    

    
    searchOpps(){ 
    getOpp({keyword:this.searchK})
    .then(result => {
        console.log(result);
        this.odata = result;
        this.error = undefined;
    })
    .catch(error =>{
        console.log('error');
        console.log(error);
        this.error = error;
        this.odata = undefined;
    })
}
   }  
      

