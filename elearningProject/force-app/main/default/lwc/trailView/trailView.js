import { LightningElement, api, wire } from 'lwc';

import getTrailWrap from '@salesforce/apex/TrailController.getTrailWrap';

export default class TrailView extends LightningElement {
    
  @api recordId;
  trailName;
  trailDescription;
  trailEstimatedTime;
  trailMaxScore;
  trailProgress;
  trailCompleted;
  modulesWithCheck;
  
  @wire(getTrailWrap, {trailId: '$recordId'})
  showTrailWrap({data, error}){
     // debugger;
    if(data){
        this.trailName = data.trail.Name;
        this.trailDescription = data.trail.Description__c;
        this.trailEstimatedTime = data.trail.Trail_Estimated_Time__c;
        this.trailMaxScore = data.trail.Trail_Max_Score__c;
        if(data.progressTrail) this.trailProgress = data.progressTrail;
        this.trailCompleted = data.progressTrail==100? true : false;
        if(data.modulesWithCheck) this.modulesWithCheck=data.modulesWithCheck;        

    }else if(error){
        console.log('HUBO UN ERROR------>',error);  
    }
  }
} 