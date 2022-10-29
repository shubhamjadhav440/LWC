import { LightningElement,wire,track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import CLASS_FIELD from '@salesforce/schema/Product2.ProductClass';
import FAMILY_FIELD from '@salesforce/schema/Product2.Family';
import TYPE_FIELD from '@salesforce/schema/Product2.Type';
import QUANTITY_FIELD from '@salesforce/schema/Product2.QuantityUnitOfMeasure';
import Prodlist from '@salesforce/apex/ProductList.productL';
import ProdlistC from '@salesforce/apex/ProductList.productC';
import ProdlistF from '@salesforce/apex/ProductList.productF';
import ProdlistT from '@salesforce/apex/ProductList.productT';
import ProdlistQ from '@salesforce/apex/ProductList.productQ';


const columns = [
    {label : 'Name', fieldName : 'Name'},
    {label : 'Product Class', fieldName : 'ProductClass'},
    {label : 'Product Code', fieldName : 'ProductCode'},
    {label : 'Family', fieldName : 'Family'},
    {label : 'Type', fieldName : 'Type'},
    {label : 'Quantity', fieldName : 'QuantityUnitOfMeasure'},
    ];


export default class ListView extends LightningElement {
  
  @track className;
  @track classPick = '';
  @track family;
  @track familyPick = '';
  @track type;
  @track typePick = '';
  @track quantity;
  @track quantityPick = '';
  @track pdata;
  @track columns = columns;
  @track error;

  

  // this is to fetch the picklist values of different picklist fields
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



    handleChange(event){
       this.className = event.target.value
       console.log(this.className);
      ProdlistC({pclass : this.className})
       .then(result =>{
        console.log(result);
        this.pdata = result;
        this.error = undefined;
       })
       .catch(error =>{
        this.error = error;
        this.pdata = undefined; 
       })
    }


    handleChange2(event){
        this.family = event.target.value
        console.log(this.family);
        ProdlistF({family : this.family})
       .then(result =>{
        console.log(result);
        this.pdata = result;
        this.error = undefined;
       })
       .catch(error =>{
        this.error = error;
        this.pdata = undefined;
       })
     }
    
    
     handleChange3(event){
        this.type = event.target.value
        console.log(this.type);
         ProdlistT({type : this.type})
        .then(result =>{
            console.log(result);
         this.pdata = result;
         this.error = undefined;
        })
        .catch(error =>{
         this.error = error;
         this.pdata = undefined;
        })
     }
    
    
     handleChange4(event){
        this.quantity = event.target.value
        console.log(this.quantity); 
        ProdlistQ({quantity : this.quantity})
       .then(result =>{
        console.log(result);
        this.pdata = result;
        this.error = undefined;
       })
       .catch(error =>{
        this.error = error;
        this.pdata = undefined;
       })
         
     }


     @wire(Prodlist)
     prodData({error,data}){
     if(data){
            this.pdata = data;
            this.error = undefined;
        }
        if(error){
            this.error = error;
            this.pdata = undefined;
        }
    }
  
    /*
     @wire(ProdlistQ,{quantity : '$quantity'})
      quantityData({error,data}){
        if(data){
            this.pdata = data;
            this.error = undefined;
        }
        if(error){
            this.error = error;
            this.pdata = undefined;
        }
      }


      @wire(ProdlistT,{type : '$type'})
      typeData({error,data}){
        if(data){
            this.pdata = data;
            this.error = undefined;
        }
        if(error){
            this.error = error;
            this.pdata = undefined;
        }
      }


      @wire(ProdlistF,{family : '$family'})
      familyData({error,data}){
        if(data){
            this.pdata = data;
            this.error = undefined;
        }
        if(error){
            this.error = error;
            this.pdata = undefined;
        }
      }


      @wire(ProdlistC,{pclass : '$className'})
      classNData({error,data}){
        if(data){
            this.pdata = data;
            this.error = undefined;
        }
        if(error){
            this.error = error;
            this.pdata = undefined;
        }
      }
  */ 
}  
  