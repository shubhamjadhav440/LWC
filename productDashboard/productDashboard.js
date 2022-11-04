import { LightningElement } from 'lwc';
import productData from '@salesforce/resourceUrl/Products';

export default class ProductDashboard extends LightningElement {

    wires = productData+'/Wires.png';
    bearings = productData+'/Bearing.png';
    drives = productData+'/Drives.png';
    gearhead = productData+'/GearHead.png';
    gearboxes = productData+'/Gearboxes.png';
    lighting = productData+'/Lighting.png';
    lubricants = productData+'/Lubricants.png';
    motors = productData+'/Motors.png';
    personalSafety = productData+'/PersonalSafetyProducts.png';
    pneumatics = productData+'/Pneumatics.png';
    solar = productData+'/Solar.png';
    switchgears = productData+'/Switchgears.png';
}