import { LightningElement, wire, api } from 'lwc';
import getAccountLogo from '@salesforce/apex/HubController_x7sHub.getAccountLogo';
import userId from '@salesforce/user/Id';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_NAME from '@salesforce/schema/User.Account.Name'; 

export default class AccountLogoX7sHub extends LightningElement {
    @api userId = userId;
    @api displayVerticalLine = false;

    @wire(getAccountLogo, { userId: '$userId' })
    accountLogo;

    @wire(getRecord, { recordId: '$userId', fields: [ACCOUNT_NAME]})
    user;

    get logoAltText() {
        const accountName = getFieldValue(this.user.data, ACCOUNT_NAME);
        return accountName ? `${accountName} logo` : 'account logo';
    }
}