/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */
import {LightningElement, api, wire, track} from 'lwc';

import {NavigationMixin, CurrentPageReference} from 'lightning/navigation';
import {registerListener, unregisterAllListeners, inLexMode, reduceErrors} from 'c/x7sShrUtils';
import getLocationSummary from '@salesforce/apex/AccountController_x7sHub.getLocationSummary';

import loginUserId from '@salesforce/user/Id';



export default class accountOverviewTreeGridX7sHub extends LightningElement {
    @api gatherBy = 'userID';
    @api header;
    @api iconLink;
    @api iconAltText;
    @api accountName = 'Account Name';
    @api status = 'Status';
    @api state = 'State';
    @api noOfTrainedEmplorees = 'No. of Trained Employees';
    @api amountFinanced = 'Amount Financed';
	@api customClass = '';
    @api loginUserId = loginUserId;
    @api noDataMessage = 'No account data found.'
    

	error;
    map=[];
    linkUrl;
    queryId;
    displayTreegrid
    @track treeGridData;
    @track columnData;

	@wire(CurrentPageReference) pageRef;

	connectedCallback() {
		registerListener("adventureBanner", this.handleBanner, this);

        this.columnData = [
            {
                type: 'url',
                fieldName: '_url',
                label: this.accountName,
                initialWidth: 230,
                typeAttributes: {
                   label: { fieldName: 'name' },
                   alignment: 'left'
                },
                cellAttributes: {
                    class: 'cell-text-align_left'
                }
            },
            {
                type: 'text',
                fieldName: 'onBoardingStatus',
                label: this.status,
                typeAttributes: {
                    alignment: 'left'
                 },
                cellAttributes: {
                    class: 'cell-text-align_left'
                }
            },
            {
                type: 'text',
                fieldName: 'billingState',
                label: this.state,
            },
            {
                type: 'text',
                fieldName: 'certifiedContacts',
                label: this.noOfTrainedEmplorees,
            },
            {
                type: 'currency',
                fieldName: 'lastMonthRevenue',
                label: this.amountFinanced,
                initialWidth: 130,
            }
        ];
        this.checkUrl();

        this.getlocation(this.gatherBy, this.queryId);
	}

	disconnectedCallback() {
		unregisterAllListeners(this);
	}

    checkUrl(){
        let tempUrl = window.location.href;
        if(tempUrl.includes('account-overview')){
            this.linkUrl = tempUrl.split('account-overview')[0];
            this.queryId = this.loginUserId;

        }else if(tempUrl.includes('account/')){
            let temp = tempUrl.split('account/');
            this.linkUrl = temp[0];
            let accountId = temp[1].split('/')[0];
            this.queryId = accountId;
        }
    }

    getlocation(type, id){
        getLocationSummary({type: type, id: id})
        .then(data => {
            if(data && JSON.parse(data).length>0){
                let count = 0;
                let newData = JSON.parse(data)

                // Culculate numbers of hierarchyLevel
                newData.forEach(element => {
                    element._url = this.linkUrl+ 'account/' + element.id;
                    element._children = [];
                    if(element.hierarchyLevel > count){
                        count = element.hierarchyLevel;
                    }
                });

                // Create empty arrays in map (array of arrays)
                for(let i = 0; i < count; i++){
                    let emptyArray = [];
                    this.map[i] = emptyArray;
                }

                // Allocate data into array of arrays based of the hierarchyLevel
                newData.forEach(elm =>{
                    let tempLevel = elm.hierarchyLevel;
                    this.map[tempLevel-1].push(elm)
                })

                // create nested data structure
                for(let i = 0; i < this.map.length-1 ; i++){
                    let j = this.map.length -i-1;
                    //  If no children record, remove _children property
                    this.map[j].forEach(item => {
                        if(item._children.length === 0){
                            delete item._children
                        }
                        // Use current data's parentId match one level higher hierarchyLevel's Id 
                        let tempIndex = this.map[j-1].findIndex(object => {
                            return object.id === item.parentId
                        })
                        if(tempIndex !== -1){
                            this.map[j-1][tempIndex]._children.push(item); 
                            // Roll up value of revenue field
                            this.map[j-1][tempIndex].lastMonthRevenue = this.map[j-1][tempIndex].lastMonthRevenue + item.lastMonthRevenue;
                        }
                    })

                }
                // Remove empty arrays in map
                let num =0;
                this.map.forEach(item => {
                    if(item.length === 0){
                        num++;
                    }
                })

                this.map = this.map.slice(num, this.map.length)
                this.treeGridData = this.map[0];
            }
		})
		.catch(error => {
			console.log(error)
            this.error = reduceErrors(error);
            this.certifiedUserData = undefined;
		})
    }

    addCommas(num) {
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

}