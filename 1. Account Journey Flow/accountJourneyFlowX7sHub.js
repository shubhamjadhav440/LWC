import { LightningElement, api, wire } from 'lwc';
import reduceErrors from 'c/x7sShrUtils';
import getCurrentJourneyStage from '@salesforce/apex/HomePageController_x7sHub.getCurrentJourneyStage';
import loginUserId from '@salesforce/user/Id';

export default class AccountJourneyFlowX7sHub extends LightningElement {
    @api accountJourneyHeader;

    @api stageTitle1;
    @api stageIconLinkNotCompleted1;
    @api stageIconLinkActive1;
    @api stageIconLinkCompleted1;
    @api stageIconAltText1;
    @api stageDescription1;

    @api stageTitle2;
    @api stageIconLinkNotCompleted2;
    @api stageIconLinkActive2;
    @api stageIconLinkCompleted2;
    @api stageIconAltText2;
    @api stageDescription2;

    @api stageTitle3;
    @api stageIconLinkNotCompleted3;
    @api stageIconLinkActive3;
    @api stageIconLinkCompleted3;
    @api stageIconAltText3;
    @api stageDescription3;

    @api stageTitle4;
    @api stageIconLinkNotCompleted4;
    @api stageIconLinkActive4;
    @api stageIconLinkCompleted4;
    @api stageIconAltText4;
    @api stageDescription4;

    @api loginUserId = loginUserId;

    stageIconLink1;
    stageIconLink2;
    stageIconLink3;
    stageIconLink4;

    activeStage;
    stageData;

    @wire(getCurrentJourneyStage, {userId: '$loginUserId'})
    wiredStage({ error, data }) {
        if (data) {
            this.stageData = JSON.parse(data);
            this.activeStage = this.stageData.journeyStage;
            this.checkActiveStage();
        } else if (error) {
            this.error = reduceErrors(error);
        }
    }

    renderedCallback() {
        this.stageIconLink1 = this.stageIconLinkNotCompleted1;
        this.stageIconLink2 = this.stageIconLinkNotCompleted2;
        this.stageIconLink3 = this.stageIconLinkNotCompleted3;
        this.stageIconLink4 = this.stageIconLinkNotCompleted4;
    }

    checkActiveStage() {
        if (this.activeStage) {
            Array.from(this.template.querySelectorAll('.account-journey_stage')).every((stage, index) => {
                if (this.activeStage === stage.dataset.stage) {
                    stage.classList.add('stage-active');
                    stage.querySelector('.account-journey_stage-icon').src = this[`stageIconLinkActive${index + 1}`];
                    return false;
                } else {
                    stage.classList.add('stage-completed');
                    stage.querySelector(`.account-journey_stage-icon`).src = this[`stageIconLinkCompleted${index + 1}`];
                    return true;
                }
            });
        }
    }
}