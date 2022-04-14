import { LightningElement, api, wire } from 'lwc';
/* import NAME_FIELD from '@salesforce/schema/Trail__c.Name';
import DESCRIPTION_FIELD from '@salesforce/schema/Trail__c.Description__c';
import TRAILTIME_FIELD from '@salesforce/schema/Trail__c.Trail_Estimated_Time__c';
import TRAILSCORE_FIELD from '@salesforce/schema/Trail__c.Trail_Max_Score__c'; */
import getTrail from '@salesforce/apex/TrailController.getTrail';

/* const FIELDS = [
    'Trail__c.Name',
    'Trail__c.Description__c',
    'Trail__c.Trail_Estimated_Time__c',
    'Trail__c.Trail_Max_Score__c',
]; */

export default class TrailView extends LightningElement {
    
  @api recordId;

  @wire(getTrail, {trailId : '$recordId'/* , fields : FIELDS */})
  trail;

get name() {
    //console.log('hay console.log: ',this.trail.data);
    return this.trail.data?.Name || '';
    }

get description() {
    return this.trail.data?.Description__c || '';
    }

get trailTime() {
    return this.trail.data?.Trail_Estimated_Time__c || '';
    }

get trailScore() {
    return this.trail.data?.Trail_Max_Score__c || '';
    }

get fulltrail() {
        return this.trail.data;
    }
}