import { LightningElement,wire,track,api } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import CLASS_FIELD from '@salesforce/schema/Product2.ProductClass';
import FAMILY_FIELD from '@salesforce/schema/Product2.Family';
import TYPE_FIELD from '@salesforce/schema/Product2.Type';
import QUANTITY_FIELD from '@salesforce/schema/Product2.QuantityUnitOfMeasure';
import Prodlist from '@salesforce/apex/ProductList.productL';
import ProductAll from '@salesforce/apex/ProductList.productAll';

const columns = [
    {label : 'Name', fieldName : 'Name'},
    {label : 'Product Class', fieldName : 'ProductClass'},
    {label : 'Product Code', fieldName : 'ProductCode'},
    {label : 'Family', fieldName : 'Family'},
    {label : 'Type', fieldName : 'Type'},
    {label : 'Quantity', fieldName : 'QuantityUnitOfMeasure'},
    ];


export default class ListViewCombined extends LightningElement {

    className = null;
    prodName = '';
    @track classPick = '';
    family = null;
    @track familyPick = '';
    type = null;
    @track typePick = '';
    quantity = null;
    @track quantityPick = '';
    @track pdata;
    @track columns = columns;
    @track error;
    searchable = [];
    




    @wire(getObjectInfo, { objectApiName : PRODUCT_OBJECT})
    productMetadata;
  
  

    @wire(getPicklistValues,
        {
            recordTypeId: '$productMetadata.data.defaultRecordTypeId',
            fieldApiName: FAMILY_FIELD
        }
    )
    FamilyValues({data,error}){
        if(data){
            console.log('The values are ',data.values);
            this.familyPick = data.values;
            this.error = undefined; 
        }
        if(error){
            console.log('Error fetching values due to ${error}');
            this.error = error;
            this.familyPick = undefined;
        }
    };



    @wire(getPicklistValues,
        {
            recordTypeId: '$productMetadata.data.defaultRecordTypeId',
            fieldApiName: CLASS_FIELD
        }
    )
    ClassValues({data,error}){
        if(data){
            console.log('The values are ',data.values);
            this.classPick = data.values;
            this.error = undefined; 
        }
        if(error){
            console.log('Error fetching values due to ${error}');
            this.error = error;
            this.classPick = undefined;
        }
    };




    @wire(getPicklistValues,
        {
            recordTypeId: '$productMetadata.data.defaultRecordTypeId',
            fieldApiName: TYPE_FIELD
        }
    )
    TypeValues({data,error}){
        if(data){
            console.log('The values are ',data.values);
            this.typePick = data.values;
            this.error = undefined; 
        }
        if(error){
            console.log('Error fetching values due to ${error}');
            this.error = error;
            this.typePick = undefined;
        }
    };
 
   

    @wire(getPicklistValues,
        {
            recordTypeId: '$productMetadata.data.defaultRecordTypeId',
            fieldApiName: QUANTITY_FIELD
        }
    )
    QuantityValues({data,error}){
        if(data){
            console.log('The values are ',data.values);
            this.quantityPick = data.values;
            this.error = undefined; 
        }
        if(error){
            console.log('Error fetching values due to ${error}');
            this.error = error;
            this.quantityPick = undefined;
        }
    };


    
    @wire(Prodlist)
     prodData({error,data}){
     if(data){
            console.log('All Data');
            this.pdata = data;
            this.error = undefined;
        }
        if(error){
            this.error = error;
            this.pdata = undefined;
        }
    }
    /*
*/



/*  

    @wire(ProductAll, {
        className:"$className",
        family:"$family",
        type:"$type",
        quantity:"$quantity"
    })
    wiredSObjects({data,error}) {
        if(data){
            this.pdata = data;
            this.error = undefined;
        }
        if(error){
            console.log(error);
            this.error = error;
            this.pdata = undefined;
        }
    }
*/





    handleChange(event){
        console.log(event.target)
        this.className = event.target.value;
        console.log("change", this[event.target.name]);
       this.searchProducts();
        
        /* 
        ProductAll({className: "$className",family: "$family" ,type: "$type", quantity: "$quantity"})
        .then(result => {
            console.log('result');
            console.log(result);
            this.pdata = result;
            this.error = undefined;
        })
        .catch(error =>{
            console.log('error');
            console.log(error);
            this.error = error;
            this.pdata = undefined;
        })
        */

    }



    searchProducts(){
        ProductAll({className: this.className,family: this.family ,type: this.type, quantity: this.quantity, pName: this.prodName})
        .then(result => {
            console.log('result');
            console.log(result);
            this.pdata = result;
            this.error = undefined;
        })
        .catch(error =>{
            console.log('error');
            console.log(error);
            this.error = error;
            this.pdata = undefined;
        })
    }

    
    handleChange2(event){
        this.family = event.target.value
        console.log(this.family);
        this.searchProducts();
     }
    
    
     handleChange3(event){
        this.type = event.target.value
        console.log(this.type);
        this.searchProducts();
     }
    
    
     handleChange4(event){
        this.quantity = event.target.value
        console.log(this.quantity); 
        this.searchProducts();
     }
 

     handleChange5(event){
        this.prodName = event.target.value
        console.log(this.prodName); 
        this.searchProducts();
     }

}