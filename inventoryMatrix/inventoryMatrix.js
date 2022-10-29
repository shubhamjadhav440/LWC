import { LightningElement,wire,track,api } from 'lwc';
import Project from '@salesforce/apex/InventoryMatrix.getProject';
import Cluster from '@salesforce/apex/InventoryMatrix.getCluster';
import Tower from '@salesforce/apex/InventoryMatrix.getTower';
import Wing from '@salesforce/apex/InventoryMatrix.getWing';
import Unit from '@salesforce/apex/InventoryMatrix.getUnits';


let i = 0;
let j = 0;
let k = 0;
let l = 0;
let m = 0;
let u = 0;
export default class InventoryMatrix extends LightningElement {
    @track columns = [
        {label : 'Id', fieldName : 'Id'},
        {label : 'Name', fieldName : 'Name'}
    ];
        
    
    projectN = '' ;
    clusterN = '';
    towerN = '';
    wingN = '';
    unitN = '';
    @track pdata ;
    @track pList = [];
    @track cList = [];
    @track tList = [];
    @track wList = [];
    @track uList = [];
    @track udata;




    //List of Unit
   @wire(Unit,{wName: '$wingN'})
   udata({error,data}){
   if(data){
    console.log(data);
    this.uList = data;
    for(u=0; u<data.length; u++){
       // console.log('Unit Name : '+data[u].Name);
        this.uList = [...this.uList, {value : data[u].Id, label : data[u].Name}];
    }
    console.log(this.uList);
   }
   if(error){
    console.log(error);
    this.error = error;
   }
   }


   quoteCall(event){
    
   }


  //List of cluster
    @wire(Cluster,{pName: '$projectN'})
    cdata({error,data}){
        if(data){
            console.log(data);
            for(j=0;j<data.length;j++){
                console.log('Name: '+data[j].Name);
                this.cList = [...this.cList, {value : data[j].Id, label: data[j].Name}];
            }
        }
        if(error){
            console.log(error);
            this.error = error;
        }
    };
  

    //List of tower
    @wire(Tower,{cName: '$clusterN'})
    tdata({error,data}){
        if(data){
            console.log(data);
            for(k=0;k<data.length;k++){
                console.log('Name: '+data[k].Name);
                this.tList = [...this.tList, {value : data[k].Id, label: data[k].Name}];
            }
        }
        if(error){
            console.log(error);
            this.error = error;
        }
    };



    //List of wings
    @wire(Wing,{tName: '$towerN'})
    wdata({error,data}){
        if(data){
            console.log(data);
            for(l=0;l<data.length;l++){
                console.log('Name: '+data[l].Name);
                this.wList = [...this.wList, {value : data[l].Id, label: data[l].Name}];
            }
        }
        if(error){
            console.log(error);
            this.error = error;
        }
    };



    //List of Projects
    @wire(Project)
    projectName({error,data}){
        if(data){
        console.log(data);
        for(i=0; i<data.length;i++){
        console.log('Name : '+ data[i].Name);
        this.pList = [...this.pList ,{ value: data[i].Id , label: data[i].Name}];
        }
        this.error = undefined;
        }
        if(error){
            console.log(error);
            this.error = error;
        }
    }


    get statusOptions(){
        console.log('This is working for Project brooooooooo!!!!!!!!');
        console.log(this.pList);
        return this.pList;
    }


    handleChange(event){
        console.log(event.target.value)
        this.projectN = event.target.value;
        console.log("change "+ this.projectN);
 }

 handleChange1(event){
    console.log(event.target.value)
    this.clusterN = event.target.value;
    console.log("change 2 : "+this.clusterN);
 }

 handleChange2(event){
    console.log(event.target.value)
    this.towerN = event.target.value;
    console.log("change 3 : "+this.towerN);
 }


 handleChange3(event){
    console.log(event.target.value)
    this.wingN = event.target.value;
    console.log("change 4 : "+this.wingN);
    this.searchUnits();
 }



 
 //List of units
  searchUnits(){
    Unit({wName: this.wingN})
    .then(result => {
    //    console.log(result);
        this.udata = result;
        this.error = undefined;
    })
    .catch(error =>{
        console.log(error);
        this.error = error;
        this.udata = undefined;
    })
  }
  

} 