import { LightningElement, track, wire, api } from 'lwc';
import getNameOpp from '@salesforce/apex/dynamicFilterComponent.showD2';
import getDateOpp from '@salesforce/apex/dynamicFilterComponent.showD3';
import getAmtOpp from '@salesforce/apex/dynamicFilterComponent.showD4';
import getDescOpp from '@salesforce/apex/dynamicFilterComponent.showD5';
import generateCSV from '@salesforce/apex/GenerateNewCSV.generateCSV';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
const columns = [
    {label : 'Name' , fieldName : 'oName'},
    {label : 'Amount' , fieldName : 'oAmount'},
    {label : 'Stage' , fieldName : 'oStageName'},
    {label : 'Description' , fieldName : 'oDescription'},
    {label : 'Close Date' , fieldName : 'oCloseDate'},
    {label : 'Account' , fieldName : 'oAccName'},
    {label : 'Next Step' , fieldName : 'oNextStep'},
];


export default class DynamicFilterComponent extends LightningElement {

    @track columns = columns;
    odata = [];
    enterData = false;
    @track accName = '';
    @track accDate = null;
    @track accAmount = null;
    @track accDescription = '';
    @track value = '';
    @track value2 = '';
    @track value3 = '';
    @track filter = '';
    @track filter2 = null;
    @track filter3 = null;
    @track value4 = '';
    showTable = false;
    showModal = false;
    ovalue = [];
    searchTerm = '';
    name;
    email;
    userId = Id;


    get options(){
        return [
         { label : 'equals', value : 'equals'},
         { label : 'not equal to', value : 'not equal to'},
         { label : 'contains', value : 'contains'},
         { label : 'does not contain', value : 'does not contain'},
         { label : 'starts with', value : 'starts with'},
        ];
    }


    get options2(){
        return[
            { label : 'equals', value : 'equals'},
            { label : 'not equal to', value : 'not equal to'},
            { label : 'less than', value : 'less than'},
            { label : 'greater than', value : 'greater than'},
            { label : 'less or equal', value : 'less or equal'},
            { label : 'greater or equal', value : 'greater or equal'},
        ];
    }



    get options3(){
        return[
            { label : 'equals', value : 'equals'},
            { label : 'not equal to', value : 'not equal to'},
            { label : 'less than', value : 'less than'},
            { label : 'greater than', value : 'greater than'},
            { label : 'less or equal', value : 'less or equal'},
            { label : 'greater or equal', value : 'greater or equal'},
        ];
    }
  
    
    get CSVoptions(){
        return [
            {label : 'Name' , value : 'oName'},
            {label : 'Amount' , value : 'oAmount'},
            {label : 'Stage' , value : 'oStageName'},
            {label : 'Description' , value : 'oDescription'},
            {label : 'Close Date' , value : 'oCloseDate'},
            {label : 'Account' , value : 'oAccName'},
            {label : 'Next Step' , value : 'oNextStep'},
        ];
    }


    handleChange(event){
     this.accName = event.target.value;
     this.searchTerm = event.target.value;
     console.log(this.accName);
    }


    handleChange2(event){
        this.accDate = event.target.value;
        this.searchTerm = event.target.value;
        console.log(this.accDate);
    }


    handleChange3(event){
        this.accAmount = event.target.value;
        this.searchTerm = event.target.value;
        console.log(this.accAmount);
    }

    handleChange4(event){
        this.accDescription = event.target.value;
        this.searchTerm = event.target.value;
        console.log(this.accDescription);
    }


    filterChange(event){
     this.filter = event.target.value;
     console.log(this.filter);
    }

    filterChange2(event){
    this.filter2 = event.target.value;
    console.log(this.filter2);
    }

    filterChange3(event){
    this.filter3 = event.target.value;
    console.log(this.filter3);
    }


    /*
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
  */

   searchData(event){
    if(this.accName != '' && this.filter != null){
    console.log('name Search');
    this.searchAccName();
    }
    if(this.accDate != null && this.filter2 != null){
    console.log('date Search');
    this.searchAccDate(); 
    }
    if(this.accAmount != null && this.filter3 != null){
    console.log('amount Search');
    this.searchAccAmount(); 
    }
    if(this.accDescription != ''){
    console.log('description Search');
    this.searchAccDescription();
    }
   }



   searchAccName(){
    getNameOpp({keyword:this.accName,operator:this.filter})
    .then(result=>{
        console.log('result');
        console.log(result);
        this.showTable=true;
        this.odata = result;
        this.error = undefined;
    })
    .catch(error =>{
        console.log('error');
        console.log(error);
        this.showTable=false;
        this.error = error;
        this.odata = undefined;
    })
   }
 

   searchAccDate(){
    getDateOpp({keyword:this.accDate,operator:this.filter2})
    .then(result=>{
        console.log('result');
        console.log(result);
        this.showTable=true;
        this.odata = result;
        this.error = undefined;
    })
    .catch(error =>{
        console.log('error');
        console.log(error);
        this.showTable=false;
        this.error = error;
        this.odata = undefined;
    })
   }


   searchAccAmount(){
    getAmtOpp({keyword:this.accAmount,operator:this.filter3})
    .then(result=>{
        console.log('result');
        console.log(result);
        this.showTable=true;
        this.odata = result;
        this.error = undefined;
    })
    .catch(error =>{
        console.log('error');
        console.log(error);
        this.showTable=false;
        this.error = error;
        this.odata = undefined;
    })
   }

   searchAccDescription(){
    console.log('true');
    console.log(this.accDescription);
    getDescOpp({Description:this.accDescription})
    .then(result=>{
        console.log('result');
        console.log(result);
        this.showTable=true;
        this.odata = result;
        this.error = undefined;
    })
    .catch(error =>{
        console.log('error');
        console.log(error);
        this.showTable=false;
        this.error = error;
        this.odata = undefined;
    })
   }


   @wire(getRecord, { recordId: Id, fields: [NAME_FIELD, EMAIL_FIELD]}) 
   userDetails({error, data}) {
       if (data) {
           this.name = data.fields.Name.value;
           this.email = data.fields.Email.value;
       } else if (error) {
           this.error = error ;
       }
   }

   showModalWindow(){
    console.log('Show Modal');
    console.log(this.showModal);
    this.showModal = true;
    console.log(this.showModal);
   }


   handleOptionsChange(event){
     this.ovalue = event.detail.value;
     console.log(this.ovalue);
   }

   get selectedValues(){
      return this.ovalue.join(',');
   }

   handleOkay(){
    console.log('Move to create CSV');
    this.createCSV();
   }



   createCSV(){
    console.log(this.odata);
    generateCSV({colArray : this.ovalue, apexList : this.odata,searchString:this.searchTerm,uId:userId})
    .then(result=>{
        console.log('result');
        console.log(result);
        this.error = undefined;
    })
    .catch(error =>{
        console.log('error');
        console.log(error);
        this.error = error;
    })
   }
}