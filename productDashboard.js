import { LightningElement } from 'lwc';
/*import wires from '@salesforce/resourceUrl/Wires';
import switchgears from '@salesforce/resourceUrl/Switchgears';
import solar from '@salesforce/resourceUrl/Solar';
import pneumatics from '@salesforce/resourceUrl/Pnuematics';
import personalSafety from '@salesforce/resourceUrl/PersonalSafetyProducts';
import motors from '@salesforce/resourceUrl/Motors';
import lubricants from '@salesforce/resourceUrl/Lubricants';
import lightning from '@salesforce/resourceUrl/Lightning';
import gearboxes from '@salesforce/resourceUrl/Gearboxes';
import gearhead from '@salesforce/resourceUrl/GearHead';
import drives from '@salesforce/resourceUrl/Drives';
import bearings from '@salesforce/resourceUrl/Bearings';
*/
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
