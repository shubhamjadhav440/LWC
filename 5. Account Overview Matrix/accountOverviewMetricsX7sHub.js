/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */
import {LightningElement, api, wire} from 'lwc';

import {NavigationMixin, CurrentPageReference} from 'lightning/navigation';
import {registerListener, unregisterAllListeners, inLexMode, reduceErrors} from 'c/x7sShrUtils';
import getAccountOverviewSnapshot from '@salesforce/apex/AccountController_x7sHub.getAccountOverviewSnapshot';

import loginUserId from '@salesforce/user/Id';






export default class accountOverviewMetricsX7sHub extends LightningElement {
	
    @api activeAccount;
    @api inOnboarding;
    @api amountFinanced;
    @api cadenceCallsCompleted;
    @api executiveBusinessReview;
    @api storeVisits;
	@api customClass = '';
    @api loginUserId = loginUserId;

	error;

    accountOverviewData;
    activeAccounts;
    amountFinanced;
    cadenceCallsCompleted;
    eBRCompleted;
    inBoardingAccounts;
    storeVisits;
	

	@wire(CurrentPageReference) pageRef;

    @wire(getAccountOverviewSnapshot, {userId: '$loginUserId'})
    wireAccountOverview({ error, data }) {
        if(data){

            this.accountOverviewData = JSON.parse(data)
            this.activeAccounts = this.addCommas(this.accountOverviewData.activeAccounts);
            this.amountFinanced = this.addCommas(this.accountOverviewData.amountFinanced);
            this.cadenceCallsCompleted = this.addCommas(this.accountOverviewData.cadenceCallsCompleted);
            this.eBRCompleted = this.addCommas(this.accountOverviewData.eBRCompleted);
            this.inBoardingAccounts = this.addCommas(this.accountOverviewData.inBoardingAccounts);
            this.storeVisits = this.addCommas(this.accountOverviewData.storeVisits);

        }else if (error) {
            console.log(error)
            this.error = reduceErrors(error);
            this.certifiedUserData = undefined;
        }
    }




	
	connectedCallback() {
		registerListener("adventureBanner", this.handleBanner, this);
	}
	
	disconnectedCallback() {
		unregisterAllListeners(this);
	}

    addCommas(num) {
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

}