import { LightningElement, wire, track } from 'lwc';
import accList from '@salesforce/apex/AccList.getList';
import newAList from '@salesforce/apex/AccList.getSet';

let i = 0;

export default class SelectParams extends LightningElement {

    @track columns = [
        {label : 'Id', fieldName : 'Id'},
        {label : 'Name', fieldName : 'Name'}
    ];
    
    
    table1 = true;
    table2 = false;
    @track pList = [];
    selectedIds = [];
    @track currentRecord = [];
    @track aList;


    @wire(accList)
    getAcc({error,data}){
        if(data){
        console.log(data)
        this.aList = data;
        this.error = undefined;
        }
        if(error){
        this.error = error;
        this.aList = undefined;
        }
    }


    handleClick(){
        var selectedRecords = this.template.querySelector('lightning-datatable').getSelectedRows();
         if(selectedRecords.length > 0){
            console.log('Selected Records are ',selectedRecords);
          
            for(let i=0;i<selectedRecords.length;i++){
                this.currentRecord = [...this.currentRecord, {value : selectedRecords[i].Id, Name : selectedRecords[i].Name, Id : selectedRecords[i].Id}];
             }
        

            console.log('hero');
          //  alert('The records are : '+this.currentRecord);
            // alert(this.selectedIds);
        }
        this.table1 = false;
        this.table2 = true;
        console.log('true');
}

finishClick(){

}





}