import { LightningElement,wire,api } from 'lwc';
import getCustomSetting from '@salesforce/apex/Recentdata.getDatas';
import dataC from '@salesforce/apex/Recentdata.enterData';

export default class ChatterFeed extends LightningElement {

    odata = [];
    myArray  = [];
    myArray2 = [];
    newValue = '';

    @wire(getCustomSetting)
    customData({error,data}){
    if(data){
        console.log(data);
        console.log('All Data');
        this.odata = data;
        console.log(this.odata.Recent_Data__c);
       this.myArray = this.odata.Recent_Data__c.split(',');
       this.myArray2 = this.myArray.join('\n');
       console.log(this.myArray2);
     }
    if(error){
        this.error = error;
        this.odata = undefined;
    }
};

handleChange(event){
this.newValue = event.target.value;
console.log(this.newValue);
}

handleClick(){
dataC({dataChange:this.newValue});
}
}