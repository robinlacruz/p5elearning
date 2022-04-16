import { LightningElement, api, wire } from 'lwc';
/* import NAME_FIELD from '@salesforce/schema/Trail__c.Name';
import DESCRIPTION_FIELD from '@salesforce/schema/Trail__c.Description__c';
import TRAILTIME_FIELD from '@salesforce/schema/Trail__c.Trail_Estimated_Time__c';
import TRAILSCORE_FIELD from '@salesforce/schema/Trail__c.Trail_Max_Score__c'; */
import getTrail from '@salesforce/apex/TrailController.getTrail';
import getProgressTrail from '@salesforce/apex/TrailController.getProgressTrail';
import getPassedModuleIds from '@salesforce/apex/TrailController.getPassedModuleIds';
import getModules from '@salesforce/apex/TrailController.getModules';

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
  @wire(getProgressTrail, {trailId : '$recordId'})
  progressTrail;
  @wire(getPassedModuleIds, {trailId : '$recordId'})
  passedModuleIds;
  @wire(getModules, {trailId: '$recordId'})
  Modules; 

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

get progressIsFalse() {
    if(this.progressTrail.data==0){
        return true;
        } else if(this.progressTrail.data==100){
        return false;
        }
    }

get progressTrailPerc() {
    if(this.progressTrail.data>0 && this.progressTrail.data<100)
        return this.progressTrail.data;
    }

get numberOfPassedModules() {
        return this.passedModuleIds.data?.length||0;
    }

get NumberOfModules() {
        return this.Modules.data?.length||0;
    }

/* get showTrailWrap() {
    console.log('el trailWrap trae: ',JSON.stringify(this.trailWrap?.data) || 'no hay nada en data');
    return JSON.stringify(this.trailWrapList[0]);
    } */
}