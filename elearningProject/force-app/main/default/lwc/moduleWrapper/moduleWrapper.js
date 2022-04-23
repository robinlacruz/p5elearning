import { LightningElement, api, wire } from 'lwc';
import getUnitWrapsByMod from '@salesforce/apex/ModuleController.getUnitWrapsByMod';

export default class ModuleWrapper extends LightningElement {
    @api modwrapp;
    @api moduleid;
    unitWraps;


    @wire(getUnitWrapsByMod, {moduleId: '$moduleid'})
    showUnitWrap({data, error}){
    debugger;
    if(data){
        console.log('Lo que llega en data es:',JSON.stringify(data));
        this.unitWraps = data;        

    }else if(error){
        console.log('HUBO UN ERROR------>',error);  
    }
  }

}