import {api, LightningElement} from 'lwc';
import loadMaterialMastersFromDatabase from '@salesforce/apex/MaterialMasterLoader.loadMaterialMastersFromDatabase';

export default class MaterialLookup extends LightningElement {
    @api label;
    @api disabled;
    @api placeholder = 'Search Product Masters...';
    @api required;
    _selectedMaterial;
    @api searchBySkuNumber = false;
    @api errorMessage;
    @api accountId;
    @api returnType;
    @api productFamilies;
    @api messageWhenInvalidMaterial = 'Invalid Material';

    searchText;
    displayText;
    materials;
    options;
    isLoading = false;

    @api get selectedMaterial() {
        return this._selectedMaterial;
    }

    set selectedMaterial(value) {
        console.log('SelectedMaterial set: ' + JSON.stringify(value));
        this._selectedMaterial = value;
        try {
            this.displayText = this._selectedMaterial.GE_LGT_EM_MaterialDescription__c;
        } catch(e) {
            this.displayText = null;
        }
    }

    @api reportValidity() {
        return this.template.querySelector('c-lookup').reportValidity();
    }

    get selectedValue() {
        return 'this.displayText';
    }

    async handleMaterialChange(event) {
        try {
            this.searchText = event.detail.value.trim();
            console.log('Product Families passed for Search: '+this.productFamilies);
            console.log(`searchText`, this.searchText);
            console.log(this.returnType);
            if (this.searchText != null && this.searchText.length >= 3) {
                console.log('searching');
                this.isLoading = true;
                let records;
                if (this.returnType != null || this.returnType != undefined) {
                    records = await loadMaterialMastersFromDatabase({
                        productFamilies: this.productFamilies,
                        searchText: this.searchText,
                        returnType: this.returnType,

                    });
                    console.log(records.length);
                }
                if (this.searchText !== event.detail.value.trim()) {
                    return;
                }
                this.options = null;
                //console.log(`records`, records);

                if (records != null && records.length > 0) {
                    this.options = [];
                    this.materials = records;
                    for (let i = 0; i < records.length; i++) {
                        this.options.push(records[i].GE_LGT_EM_MaterialDescription__c + '<br/><small>' + records[i].GE_LGT_EM_SAP_MaterialNumber__c + '</small>');
                    }
                    this.options = [...this.options];
                }
            } else if (this.options != null) {
                this.options = null;
            }
        } catch (error) {
            console.error(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleMaterialSelect(event) {
        try {
            event.stopPropagation();
            const index = event.detail.index;
            //this.displayText = this.materials[index].GE_LGT_EM_MaterialDescription__c;
            console.log(`selected material`, JSON.parse(JSON.stringify(this.materials[index])));
            this.dispatchEvent(new CustomEvent('select', {
                detail: {
                    selectedMaterial: this.materials[index],
                    selectedMaterialID: this.materials[index].Id,
                    selectedMaterialDescription: this.materials[index].GE_LGT_EM_MaterialDescription__c,
                    selectedMaterialNumber: this.materials[index].GE_LGT_EM_SAP_MaterialNumber__c,
                    selectedMaterialQuantityPerUnit: this.materials[index].Quantity_per_Unit__c != null ? this.materials[index].Quantity_per_Unit__c : 1
                }
            }))
        } catch (error) {
            console.error(error);
        }
    }
}