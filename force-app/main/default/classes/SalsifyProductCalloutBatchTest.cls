@isTest(SeeAllData=False)
public class SalsifyProductCalloutBatchTest {
    @testSetup static void test1(){
        Test.startTest();
        Case c1= new Case();
        insert c1;
        Attachment attachment = new Attachment();
        //Attachment at1 = [select ParentId from Attachment LIMIT 1] ;

 	   // String ContentsString ='[ {"SKU or Family": [  {"id": 147385256,"external_id": "SKU","name": "SKU","parent_id": null,"target_field_id": 5390805,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-0b7eee2e-ad1f-4681-b9b1-957cd0c27b4e","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"SKU": [  "17704"],"Catalog Number": [  "F28T8/CW/4 6PK"],"Item Status - US": [  "02 - General Availability"],"UPC": [  "43168980777"],"PH4 Configuration": [  "LFL LEVEL 4 DEFAULT"],"PH5 Intelligence": [  "LFL T8 APPLIANCE"],"Lumens": [  "1350"],"Lumens UOM": [  "lm"],"Wattage (W)": [  "19"],"Wattage UOM": [  "W"],"Efficacy": [  "71.05263157894737"],"Optical Distribution": [  "1"],"BUG Rating": [  "1"],"Color Temperature": [  "4100"],"CCT UOM": [  "K"],"CRI": [  "60"],"Wattage Replacement": [  "0-100"],"Wattage Replacement UOM": [  "W"],"Suggested Replacement SKU/Family": [  ""],"Length": [  "28"],"Length UOM": [  "In"],"Width": [  "1.09"],"Width UOM": [  "In"],"Height": [  "1.09"],"Height UOM": [  "In"],"Diameter": [  "1"],"Diameter UOM": [  "In"],"MOL UOM": [  "In"],"Weight": [  "0.343"],"Weight UOM": [  "Lb"],"Suitable Frame Dimensions UOM In": [  "In"],"Frame Hole Size UOM In": [  "In"],"Inside Diameter UOM In": [  "In"],"Accessories & Options": [  "In"],"Ceiling Hole Min Size UOM In": [  "In"],"Ceiling Hole Max Size UOM In": [  "In"],"Light Output PPF UOM": [  "(μmol/s)"],"Voltage (V)": [  "1"],"Efficacy (μmol/J) UOM": [  "(μmol/s)"],"Item Length Metric": [  "711.2"],"Item Length UOM": [  "mm"],"Item Width Metric": [  "27.686"],"Item Width UOM": [  "mm"],"Item Height Metric": [  "27.686"],"Item Height UOM": [  "mm"],"Item Diameter Metric": [  "25.4"],"Item Color": [  "mm"],"Lamp MOL UOM": [  "mm"],"Item Weight Metric": [  "0.155555555555555555555555555555555556"],"Item Weight UOM": [  "kg"],"Suitable Frame Dimensions UOM mm": [  "mm"],"Frame Hole Size UOM mm": [  "mm"],"Inside Diameter UOM mm": [  "mm"],"Outside Diameter UOM mm": [  "mm"],"Ceiling Hole Min Size UOM mm": [  "mm"],"Ceiling Hole Max Size UOM mm": [  "mm"]  }, {"SKU or Family": [  {"id": 147385257,"external_id": "Family","name": "Family","parent_id": null,"target_field_id": 5390805,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-bb439dc4-0b65-463f-9a8d-14a9ab10a475","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Family": [  "ABC"],"Catalog Logic": [  "Lumination® LUS series"],"Commercial Launch Date": [  "2017-01-01"],"Country of Origin": [  "Mexico"],"Manufacturer": [  "GE Current, a Daintree company"],"PH1 Product Line": [  "INDOOR FIXTURES - LED"],"PH2 Application": [  "INDOOR SUSPENDED"],"PH3 Family": [  "LUS ULTRON SUSPENDED"],"Technology Enabled": [  "TriGain®;Daintree"],"Taxonomy": [  {"id": 147385261,"external_id": "Fixtures","name": "Fixtures","parent_id": null,"target_field_id": 5391037,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-82ac6d67-1ede-40e7-8468-769f453c736d","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Brand": [  "Lumination®"],"Family Features & Benefits Bullets": [  "Toolless replaceable light enginenMultiple distributions – Aisle, Wide, Very Wide, Wall WashnExclusive reveal® TriGain®  technology – standardnFast toolless quick connect for easy installs, plus anti-snaking lever to adjust for STRAIGHT continuous runsnUp to 400ft run length with one power drop!n3500K, 4000K and 5000K color temperaturenLumen output: 4,200-24,000nAvailable in 4 and 8 lengthsnUp to 165 LPW efficacynIntegrated occupancy and daylight harvesting sensors avaialblen0-10V dimming standardn5-year limited system warranty standard"],"Family Applications": [  "Retail"],"Product Description Short": [  "Lumination® LUS Series LED luminaire is an energy-efficient, low maintenance alternative to traditional fluorescent lighting in a variety of commercial and low bay lighting applications. The LUS series offers customers a superior mix of value and performance."],"Product Description Long": [  "Currents Lumination® LUS series comes standard with Trigain®  to bring out the best colors. It is uniquely positioned to provide a performance of 165 LPW while delivering an astonishing 90CRI and an R9 value of 90. The fixture comes in a minimalistic form factor, making it ideal for installation in several settings and scenarios. Moreover, the LUS offers customization of color finish as well as a range of beam distributions specific to your needs. This is achieved through a sophisticated diffusers."],"Warranty": [  "5 year limited warranty"],"Programs": [  "123"],"Family Icons": [  ""],"Product Category": [  "Indoor"],"Product Subcategory": [  "Suspended"],"Bulb Base Type": [  "N/A"],"Bulb Shape": [  "N/A"],"Operating Life (Hrs)": [  "N/A"],"Operating Life UOM": [  "hours"],"Lumen Maintenance Rating": [  "L70 @ 100,000 hours"],"Lensing Description": [  "Polycarbonate"],"Housing Description": [  "Extruded aluminum body"],"Paint/Finish Description": [  "Powder coat Painted Housing"],"Material": [  "111"],"Vibration Rating UOM": [  "G"],"Input Frequency": [  "50/60"],"Input Frequency UOM": [  "Hz"],"Driver / Ballast Type": [  "Class 2 and Class 1(for high lumen skus) LED driver rated for 50,000 hours"],"System Power Factor": [  ">0.9"],"THD": [  "<20%"],"Surge protection": [  "100 kHz ring wave, 2.5 kV level"],"Environmental Conditions": [  "Damp "],"Operating Temp range": [  "-10 to 35"],"Operating Temp UOM": [  "°C"],"Storage Temp": [  "-40 to 70"],"Storage Temp UOM": [  "°C"],"Family Modules/Configurations": [  "4 & 8 ft for both Continuous or Independent runs"],"Lumen Range": [  "4,200 - 24,000"],"Lumen Range UOM": [  "lm"],"Voltage Offering": [  "120-277;347"],"Voltage Offering UOM": [  "V"],"Wattage Range": [  "0-100"],"Wattage Range UOM": [  "W"],"Efficacy Range": [  "Up to 165"],"Efficacy Range UOM": [  "LPW"],"CCT Offering": [  "3000;3500;4000;5000"],"CCT Offering UOM": [  "K"],"CRI Offering": [  "83;90 TriGain®"],"Optics & Distributions": [  "Aisle;Wide;Very Wide;Wall Wash;Uplight"],"SAP Product Hierarchy": [  "RLM5005026000001"],"Controls & Sensors": [  "Daintree Control Options;Daintree Integrated Sensor Options;Other Integrated Sensor/Controls Available;0-10V Standard Dimming"],"Color Offering": [  "White;Black;Silver;Red"],"Mounting Options": [  "Suspension or Direct Mount"],"Family Accessories & Options": [  "Emergency Light;Power cord kit;Suspended kits;Starter kits;Reflector Wings"],"Associated Parts": [  "123"],"Related Products": [  ""],"Suggested Traditional Replacement": [  "LFL"],"Suggested Replacement SKU/Family": [  ""],"Instabase Directory Link": [  "https://instabase.lightinganalysts.com/IITC/?uid=902-PF5BFFYPSR7BDEHGXV26PTEG&selectedIDBs=1663,1665,1667,1669&textSrch=LUS%20LUMINATION&expand=1&setView=0&sam=1#tabs-Search"],"Energy Certifications": [  "DLC Premium;DLC Standard"],"Safety Certifications": [  "cULus"],"Region Certifications": [  "NOM"],"Misc Certifications": [  ""],"Regulatory": [  "DLC qualified models available Please refer to http://www.designlights.org/QPL for complete information"],"BAA or TAA Compliant": [  ""],"IP Rating": [  "IP20"],"NSF Rated": [  "false"],"RoHS": [  "true"],"Length UOM": [  "In"],"Width UOM": [  "In"],"Height UOM": [  "In"],"Diameter UOM": [  "In"],"Weight UOM": [  "Lb"],"UOS Package Length UOM In": [  "In"],"UOS Package Width UOM In": [  "In"],"UOS Package Height UOM In": [  "In"],"UOS Package Weight UOM Lb": [  "Lb"],"Case Package Length UOM In": [  "In"],"Case Package Width UOM In": [  "In"],"Case Package Height UOM In": [  "In"],"Case Package Weight UOM Lb": [  "Lb"],"Standard Pack Quantity UOM": [  "Lamps"],"AC Input Voltage UOM": [  "V"],"Light Output Range UOM": [  "(μmol/s)"],"Family Spectra": [  ""],"Operating Voltage Range UOM": [  "V"],"Minimum Light Intensity UOM": [  "cd"],"Maximum Light Intensity UOM": [  "cd"],"Product Images": ["{"salsify_digital_asset_id": "afe50645662dc53ad37b14a11b2a0df351ea7e8a", "Applications": "", "Image URL": "http://images.salsify.com/image/upload/s--wiDDTIz4--/gan8uxwosa7dp51stlb5.jpg", "Brand": "", "Image Type": "Main Image", "Alt Text": "" },{"salsify_digital_asset_id": "11734b1057da54f845e7303cdfcbe5da47105593", "Applications": "", "Image URL": "http://images.salsify.com/image/upload/s--WJ_WMAi1--/dwtjtkby8gv4bpet5rzs.jpg", "Brand": "", "Image Type": "Bottom View", "Alt Text": "" },{"salsify_digital_asset_id": "bf732164791eccc92f1b6d64a7e90f39e1f26bc3", "Applications": "", "Image URL": "http://images.salsify.com/image/upload/s--LxdE30Ij--/fwfjnnvkpxibtbwohyj3.jpg", "Brand": "", "Image Type": "Side View", "Alt Text": "" }"],"Performance Levels Distribution": [  ""],"Lamp Appearance ": [  ""],"Lumens per Module UOM": [  "lm"],"Lumens per Foot UOM": [  "lm/ft"],"Watts per Module UOM": [  "W"],"Item Length UOM": [  "mm"],"Item Width UOM": [  "mm"],"Item Height UOM": [  "mm"],"Item Diameter UOM": [  "mm"],"Item Weight UOM": [  "kg"],"UOS Package Length UOM mm": [  "mm"],"UOS Package Width UOM mm": [  "mm"],"UOS Package Height UOM mm": [  "mm"],"UOS Package Weight UOM mm": [  "kg"],"Case Package Length UOM mm": [  "mm"],"Case Package Width UOM mm": [  "mm"],"Case Package Height UOM mm": [  "mm"],"Case Package Weight UOM kg": [  "kg"],"Technology Type": [  "Traditional"],"Product23 Images": [  ""],"Product Documents": [  ""],"Certifications": [  "cULus;No;NOM;DLC Premium"],"Disinfection Product": [  "false"],"Effective Projected Area": ["abc"],"Product Shape": [  "4 & 8 ft for both Continuous or Independent runs"],"UL Type": ["A"],"Website Link": [  "https://products.gecurrent.com/indoor-lighting/suspended/lumination-lus-series-ultron-suspended"]  }]'; 
 	    //String ContentsString ='[ {"SKU or Family": [  {"id": 147385256,"external_id": "SKU","name": "SKU","parent_id": null,"target_field_id": 5390805,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-0b7eee2e-ad1f-4681-b9b1-957cd0c27b4e","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"SKU": [  "17704"],"Country of Origin": [  "Mexico"],"Manufacturer": [  "GE Current, a Daintree company"],"PH1 Product Line": [  "INDOOR FIXTURES - LED"],"PH2 Application": [  "INDOOR SUSPENDED"],"PH3 Family": [  "LUS ULTRON SUSPENDED"],"Technology Enabled": [  "TriGain®;Daintree"],"Taxonomy": [  {"id": 147385261,"external_id": "Fixtures","name": "Fixtures","parent_id": null,"target_field_id": 5391037,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-82ac6d67-1ede-40e7-8468-769f453c736d","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Brand": [  "Lumination®"],"Family Features & Benefits Bullets": [  "Toolless replaceable light enginenMultiple distributions – Aisle, Wide, Very Wide, Wall WashnExclusive reveal® TriGain®  technology – standardnFast toolless quick connect for easy installs, plus anti-snaking lever to adjust for STRAIGHT continuous runsnUp to 400ft run length with one power drop!n3500K, 4000K and 5000K color temperaturenLumen output: 4,200-24,000nAvailable in 4 and 8 lengthsnUp to 165 LPW efficacynIntegrated occupancy and daylight harvesting sensors avaialblen0-10V dimming standardn5-year limited system warranty standard"],"Family Applications": [  "Retail"],"Product Description Short": [  "Lumination® LUS Series LED luminaire is an energy-efficient, low maintenance alternative to traditional fluorescent lighting in a variety of commercial and low bay lighting applications. The LUS series offers customers a superior mix of value and performance."],"Product Description Long": [  "Currents Lumination® LUS series comes standard with Trigain®  to bring out the best colors. It is uniquely positioned to provide a performance of 165 LPW while delivering an astonishing 90CRI and an R9 value of 90. The fixture comes in a minimalistic form factor, making it ideal for installation in several settings and scenarios. Moreover, the LUS offers customization of color finish as well as a range of beam distributions specific to your needs. This is achieved through a sophisticated diffusers."],"Warranty": [  "5 year limited warranty"],"Programs": [  "123"],"Family Icons": [  ""],"Product Category": [  "Indoor"],"Product Subcategory": [  "Suspended"],"Bulb Base Type": [  "N/A"],"Bulb Shape": [  "N/A"],"Operating Life (Hrs)": [  "N/A"],"Operating Life UOM": [  "hours"],"Lumen Maintenance Rating": [  "L70 @ 100,000 hours"],"Lensing Description": [  "Polycarbonate"],"Housing Description": [  "Extruded aluminum body"],"Paint/Finish Description": [  "Powder coat Painted Housing"],"Material": [  "111"],"Vibration Rating UOM": [  "G"],"Input Frequency": [  "50/60"],"Input Frequency UOM": [  "Hz"],"Driver / Ballast Type": [  "Class 2 and Class 1(for high lumen skus) LED driver rated for 50,000 hours"],"System Power Factor": [  ">0.9"],"THD": [  "<20%"],"Surge protection": [  "100 kHz ring wave, 2.5 kV level"],"Environmental Conditions": [  "Damp "],"Operating Temp range": [  "-10 to 35"],"Operating Temp UOM": [  "°C"],"Storage Temp": [  "-40 to 70"],"Storage Temp UOM": [  "°C"],"Family Modules/Configurations": [  "4 & 8 ft for both Continuous or Independent runs"],"Lumen Range": [  "4,200 - 24,000"],"Lumen Range UOM": [  "lm"],"Voltage Offering": [  "120-277;347"],"Voltage Offering UOM": [  "V"],"Wattage Range": [  "0-100"],"Wattage Range UOM": [  "W"],"Efficacy Range": [  "Up to 165"],"Efficacy Range UOM": [  "LPW"],"CCT Offering": [  "3000;3500;4000;5000"],"CCT Offering UOM": [  "K"],"CRI Offering": [  "83;90 TriGain®"],"Optics & Distributions": [  "Aisle;Wide;Very Wide;Wall Wash;Uplight"],"SAP Product Hierarchy": [  "RLM5005026000001"],"Controls & Sensors": [  "Daintree Control Options;Daintree Integrated Sensor Options;Other Integrated Sensor/Controls Available;0-10V Standard Dimming"],"Color Offering": [  "White;Black;Silver;Red"],"Mounting Options": [  "Suspension or Direct Mount"],"Family Accessories & Options": [  "Emergency Light;Power cord kit;Suspended kits;Starter kits;Reflector Wings"],"Associated Parts": [  "123"],"Related Products": [  ""],"Suggested Traditional Replacement": [  "LFL"],"Suggested Replacement SKU/Family": [  ""],"Instabase Directory Link": [  "https://instabase.lightinganalysts.com/IITC/?uid=902-PF5BFFYPSR7BDEHGXV26PTEG&selectedIDBs=1663,1665,1667,1669&textSrch=LUS%20LUMINATION&expand=1&setView=0&sam=1#tabs-Search"],"Energy Certifications": [  "DLC Premium;DLC Standard"],"Safety Certifications": [  "cULus"],"Region Certifications": [  "NOM"],"Misc Certifications": [  ""],"Regulatory": [  "DLC qualified models available Please refer to http://www.designlights.org/QPL for complete information"],"BAA or TAA Compliant": [  ""],"IP Rating": [  "IP20"],"NSF Rated": [  "false"],"RoHS": [  "true"],"Length UOM": [  "In"],"Width UOM": [  "In"],"Height UOM": [  "In"],"Diameter UOM": [  "In"],"Weight UOM": [  "Lb"],"UOS Package Length UOM In": [  "In"],"UOS Package Width UOM In": [  "In"],"UOS Package Height UOM In": [  "In"],"UOS Package Weight UOM Lb": [  "Lb"],"Case Package Length UOM In": [  "In"],"Case Package Width UOM In": [  "In"],"Case Package Height UOM In": [  "In"],"Case Package Weight UOM Lb": [  "Lb"],"Standard Pack Quantity UOM": [  "Lamps"],"AC Input Voltage UOM": [  "V"],"Light Output Range UOM": [  "(μmol/s)"],"Family Spectra": [  ""],"Operating Voltage Range UOM": [  "V"],"Minimum Light Intensity UOM": [  "cd"],"Maximum Light Intensity UOM": [  "cd"],"Nominal Power UOM": [  "W"],"Performance Levels Distribution": [  ""],"Lamp Appearance ": [  ""],"Lumens per Module UOM": [  "lm"],"Lumens per Foot UOM": [  "lm/ft"],"Watts per Module UOM": [  "W"],"Item Length UOM": [  "mm"],"Item Width UOM": [  "mm"],"Item Height UOM": [  "mm"],"Item Diameter UOM": [  "mm"],"Item Weight UOM": [  "kg"],"UOS Package Length UOM mm": [  "mm"],"UOS Package Width UOM mm": [  "mm"],"UOS Package Height UOM mm": [  "mm"],"UOS Package Weight UOM mm": [  "kg"],"Case Package Length UOM mm": [  "mm"],"Case Package Width UOM mm": [  "mm"],"Case Package Height UOM mm": [  "mm"],"Case Package Weight UOM kg": [  "kg"],"Technology Type": [  "Traditional"],"Product Images": [  ""],"Product Documents": [  ""],"Certifications": [  "cULus;No;NOM;DLC Premium"],"Disinfection Product": [  "false"],"Effective Projected Area": ["abc"],"Product Shape": [  "4 & 8 ft for both Continuous or Independent runs"],"UL Type": ["A"],"Website Link": [  "https://products.gecurrent.com/indoor-lighting/suspended/lumination-lus-series-ultron-suspended"],"Catalog Number": [  "F28T8/CW/4 6PK"],"Item Status - US": [  "02 - General Availability"],"UPC": [  "43168980777"],"PH4 Configuration": [  "LFL LEVEL 4 DEFAULT"],"PH5 Intelligence": [  "LFL T8 APPLIANCE"],"Lumens": [  "1350"],"Lumens UOM": [  "lm"],"Wattage (W)": [  "19"],"Wattage UOM": [  "W"],"Efficacy": [  "71.05263157894737"],"Optical Distribution": [  "1"],"BUG Rating": [  "1"],"Color Temperature": [  "4100"],"CCT UOM": [  "K"],"CRI": [  "60"],"Wattage Replacement": [  "0-100"],"Wattage Replacement UOM": [  "W"],"Suggested Replacement SKU/Family": [  ""],"Length": [  "28"],"Length UOM": [  "In"],"Width": [  "1.09"],"Width UOM": [  "In"],"Height": [  "1.09"],"Height UOM": [  "In"],"Diameter": [  "1"],"Diameter UOM": [  "In"],"MOL UOM": [  "In"],"Weight": [  "0.343"],"Weight UOM": [  "Lb"],"Suitable Frame Dimensions UOM In": [  "In"],"Frame Hole Size UOM In": [  "In"],"Inside Diameter UOM In": [  "In"],"Accessories & Options": [  "In"],"Ceiling Hole Min Size UOM In": [  "In"],"Ceiling Hole Max Size UOM In": [  "In"],"Light Output PPF UOM": [  "(μmol/s)"],"Voltage (V)": [  "1"],"Efficacy (μmol/J) UOM": [  "(μmol/s)"],"Item Length Metric": [  "711.2"],"Item Length UOM": [  "mm"],"Item Width Metric": [  "27.686"],"Item Width UOM": [  "mm"],"Item Height Metric": [  "27.686"],"Item Height UOM": [  "mm"],"Item Diameter Metric": [  "25.4"],"Item Color": [  "mm"],"Lamp MOL UOM": [  "mm"],"Item Weight Metric": [  "0.155555555555555555555555555555555556"],"Item Weight UOM": [  "kg"],"Suitable Frame Dimensions UOM mm": [  "mm"],"Frame Hole Size UOM mm": [  "mm"],"Inside Diameter UOM mm": [  "mm"],"Outside Diameter UOM mm": [  "mm"],"Ceiling Hole Min Size UOM mm": [  "mm"],"Ceiling Hole Max Size UOM mm": [  "mm"]  }, {"SKU or Family": [  {"id": 147385257,"external_id": "Family","name": "Family","parent_id": null,"target_field_id": 5390805,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-bb439dc4-0b65-463f-9a8d-14a9ab10a475","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Family": [  "ABC"],"Catalog Logic": [  "Lumination® LUS series"],"Commercial Launch Date": [  "2017-01-01"],"Country of Origin": [  "Mexico"],"Manufacturer": [  "GE Current, a Daintree company"],"PH1 Product Line": [  "INDOOR FIXTURES - LED"],"PH2 Application": [  "INDOOR SUSPENDED"],"PH3 Family": [  "LUS ULTRON SUSPENDED"],"Technology Enabled": [  "TriGain®;Daintree"],"Taxonomy": [  {"id": 147385261,"external_id": "Fixtures","name": "Fixtures","parent_id": null,"target_field_id": 5391037,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-82ac6d67-1ede-40e7-8468-769f453c736d","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Brand": [  "Lumination®"],"Family Features & Benefits Bullets": [  "Toolless replaceable light enginenMultiple distributions – Aisle, Wide, Very Wide, Wall WashnExclusive reveal® TriGain®  technology – standardnFast toolless quick connect for easy installs, plus anti-snaking lever to adjust for STRAIGHT continuous runsnUp to 400ft run length with one power drop!n3500K, 4000K and 5000K color temperaturenLumen output: 4,200-24,000nAvailable in 4 and 8 lengthsnUp to 165 LPW efficacynIntegrated occupancy and daylight harvesting sensors avaialblen0-10V dimming standardn5-year limited system warranty standard"],"Family Applications": [  "Retail"],"Product Description Short": [  "Lumination® LUS Series LED luminaire is an energy-efficient, low maintenance alternative to traditional fluorescent lighting in a variety of commercial and low bay lighting applications. The LUS series offers customers a superior mix of value and performance."],"Product Description Long": [  "Currents Lumination® LUS series comes standard with Trigain®  to bring out the best colors. It is uniquely positioned to provide a performance of 165 LPW while delivering an astonishing 90CRI and an R9 value of 90. The fixture comes in a minimalistic form factor, making it ideal for installation in several settings and scenarios. Moreover, the LUS offers customization of color finish as well as a range of beam distributions specific to your needs. This is achieved through a sophisticated diffusers."],"Warranty": [  "5 year limited warranty"],"Programs": [  "123"],"Family Icons": [  ""],"Product Category": [  "Indoor"],"Product Subcategory": [  "Suspended"],"Bulb Base Type": [  "N/A"],"Bulb Shape": [  "N/A"],"Operating Life (Hrs)": [  "N/A"],"Operating Life UOM": [  "hours"],"Lumen Maintenance Rating": [  "L70 @ 100,000 hours"],"Lensing Description": [  "Polycarbonate"],"Housing Description": [  "Extruded aluminum body"],"Paint/Finish Description": [  "Powder coat Painted Housing"],"Material": [  "111"],"Vibration Rating UOM": [  "G"],"Input Frequency": [  "50/60"],"Input Frequency UOM": [  "Hz"],"Driver / Ballast Type": [  "Class 2 and Class 1(for high lumen skus) LED driver rated for 50,000 hours"],"System Power Factor": [  ">0.9"],"THD": [  "<20%"],"Surge protection": [  "100 kHz ring wave, 2.5 kV level"],"Environmental Conditions": [  "Damp "],"Operating Temp range": [  "-10 to 35"],"Operating Temp UOM": [  "°C"],"Storage Temp": [  "-40 to 70"],"Storage Temp UOM": [  "°C"],"Family Modules/Configurations": [  "4 & 8 ft for both Continuous or Independent runs"],"Lumen Range": [  "4,200 - 24,000"],"Lumen Range UOM": [  "lm"],"Voltage Offering": [  "120-277;347"],"Voltage Offering UOM": [  "V"],"Wattage Range": [  "0-100"],"Wattage Range UOM": [  "W"],"Efficacy Range": [  "Up to 165"],"Efficacy Range UOM": [  "LPW"],"CCT Offering": [  "3000;3500;4000;5000"],"CCT Offering UOM": [  "K"],"CRI Offering": [  "83;90 TriGain®"],"Optics & Distributions": [  "Aisle;Wide;Very Wide;Wall Wash;Uplight"],"SAP Product Hierarchy": [  "RLM5005026000001"],"Controls & Sensors": [  "Daintree Control Options;Daintree Integrated Sensor Options;Other Integrated Sensor/Controls Available;0-10V Standard Dimming"],"Color Offering": [  "White;Black;Silver;Red"],"Mounting Options": [  "Suspension or Direct Mount"],"Family Accessories & Options": [  "Emergency Light;Power cord kit;Suspended kits;Starter kits;Reflector Wings"],"Associated Parts": [  "123"],"Related Products": [  ""],"Suggested Traditional Replacement": [  "LFL"],"Suggested Replacement SKU/Family": [  ""],"Instabase Directory Link": [  "https://instabase.lightinganalysts.com/IITC/?uid=902-PF5BFFYPSR7BDEHGXV26PTEG&selectedIDBs=1663,1665,1667,1669&textSrch=LUS%20LUMINATION&expand=1&setView=0&sam=1#tabs-Search"],"Energy Certifications": [  "DLC Premium;DLC Standard"],"Safety Certifications": [  "cULus"],"Region Certifications": [  "NOM"],"Misc Certifications": [  ""],"Regulatory": [  "DLC qualified models available Please refer to http://www.designlights.org/QPL for complete information"],"BAA or TAA Compliant": [  ""],"IP Rating": [  "IP20"],"NSF Rated": [  "false"],"RoHS": [  "true"],"Length UOM": [  "In"],"Width UOM": [  "In"],"Height UOM": [  "In"],"Diameter UOM": [  "In"],"Weight UOM": [  "Lb"],"UOS Package Length UOM In": [  "In"],"UOS Package Width UOM In": [  "In"],"UOS Package Height UOM In": [  "In"],"UOS Package Weight UOM Lb": [  "Lb"],"Case Package Length UOM In": [  "In"],"Case Package Width UOM In": [  "In"],"Case Package Height UOM In": [  "In"],"Case Package Weight UOM Lb": [  "Lb"],"Standard Pack Quantity UOM": [  "Lamps"],"AC Input Voltage UOM": [  "V"],"Light Output Range UOM": [  "(μmol/s)"],"Family Spectra": [  ""],"Operating Voltage Range UOM": [  "V"],"Minimum Light Intensity UOM": [  "cd"],"Maximum Light Intensity UOM": [  "cd"],"Nominal Power UOM": [  "W"],"Performance Levels Distribution": [  ""],"Lamp Appearance ": [  ""],"Lumens per Module UOM": [  "lm"],"Lumens per Foot UOM": [  "lm/ft"],"Watts per Module UOM": [  "W"],"Item Length UOM": [  "mm"],"Item Width UOM": [  "mm"],"Item Height UOM": [  "mm"],"Item Diameter UOM": [  "mm"],"Item Weight UOM": [  "kg"],"UOS Package Length UOM mm": [  "mm"],"UOS Package Width UOM mm": [  "mm"],"UOS Package Height UOM mm": [  "mm"],"UOS Package Weight UOM mm": [  "kg"],"Case Package Length UOM mm": [  "mm"],"Case Package Width UOM mm": [  "mm"],"Case Package Height UOM mm": [  "mm"],"Case Package Weight UOM kg": [  "kg"],"Technology Type": [  "Traditional"],"Product Images": [  ""],"Product Documents": [  ""],"Certifications": [  "cULus;No;NOM;DLC Premium"],"Disinfection Product": [  "false"],"Effective Projected Area": ["abc"],"Product Shape": [  "4 & 8 ft for both Continuous or Independent runs"],"UL Type": ["A"],"Website Link": [  "https://products.gecurrent.com/indoor-lighting/suspended/lumination-lus-series-ultron-suspended"]  }]'; 
 	  //  String ContentsString ='[ {"SKU or Family": [  {"id": 147385256,"external_id": "SKU","name": "SKU","parent_id": null,"target_field_id": 5390805,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-0b7eee2e-ad1f-4681-b9b1-957cd0c27b4e","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"SKU": [  "17704"],"GTM Family ID":[  "ABC"],"Country of Origin": [  "Mexico"],"Manufacturer": [  "GE Current, a Daintree company"],"PH1 Product Line": [  "INDOOR FIXTURES - LED"],"PH2 Application": [  "INDOOR SUSPENDED"],"PH3 Family": [  "LUS ULTRON SUSPENDED"],"Technology Enabled": [  "TriGain®;Daintree"],"Taxonomy": [  {"id": 147385261,"external_id": "Fixtures","name": "Fixtures","parent_id": null,"target_field_id": 5391037,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-82ac6d67-1ede-40e7-8468-769f453c736d","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Brand": [  "Lumination®"],"Family Features & Benefits Bullets": [  "Toolless replaceable light enginenMultiple distributions – Aisle, Wide, Very Wide, Wall WashnExclusive reveal® TriGain®  technology – standardnFast toolless quick connect for easy installs, plus anti-snaking lever to adjust for STRAIGHT continuous runsnUp to 400ft run length with one power drop!n3500K, 4000K and 5000K color temperaturenLumen output: 4,200-24,000nAvailable in 4 and 8 lengthsnUp to 165 LPW efficacynIntegrated occupancy and daylight harvesting sensors avaialblen0-10V dimming standardn5-year limited system warranty standard"],"Family Applications": [  "Retail"],"Product Description Short": [  "Lumination® LUS Series LED luminaire is an energy-efficient, low maintenance alternative to traditional fluorescent lighting in a variety of commercial and low bay lighting applications. The LUS series offers customers a superior mix of value and performance."],"Product Description Long": [  "Currents Lumination® LUS series comes standard with Trigain®  to bring out the best colors. It is uniquely positioned to provide a performance of 165 LPW while delivering an astonishing 90CRI and an R9 value of 90. The fixture comes in a minimalistic form factor, making it ideal for installation in several settings and scenarios. Moreover, the LUS offers customization of color finish as well as a range of beam distributions specific to your needs. This is achieved through a sophisticated diffusers."],"Warranty": [  "5 year limited warranty"],"Programs": [  "123"],"Family Icons": [  ""],"Product Category": [  "Indoor"],"Product Subcategory": [  "Suspended"],"Bulb Base Type": [  "N/A"],"Bulb Shape": [  "N/A"],"Operating Life (Hrs)": [  "N/A"],"Operating Life UOM": [  "hours"],"Lumen Maintenance Rating": [  "L70 @ 100,000 hours"],"Lensing Description": [  "Polycarbonate"],"Housing Description": [  "Extruded aluminum body"],"Paint/Finish Description": [  "Powder coat Painted Housing"],"Material": [  "111"],"Vibration Rating UOM": [  "G"],"Input Frequency": [  "50/60"],"Input Frequency UOM": [  "Hz"],"Driver / Ballast Type": [  "Class 2 and Class 1(for high lumen skus) LED driver rated for 50,000 hours"],"System Power Factor": [  ">0.9"],"THD": [  "<20%"],"Surge protection": [  "100 kHz ring wave, 2.5 kV level"],"Environmental Conditions": [  "Damp "],"Operating Temp range": [  "-10 to 35"],"Operating Temp UOM": [  "°C"],"Storage Temp": [  "-40 to 70"],"Storage Temp UOM": [  "°C"],"Family Modules/Configurations": [  "4 & 8 ft for both Continuous or Independent runs"],"Lumen Range": [  "4,200 - 24,000"],"Lumen Range UOM": [  "lm"],"Voltage Offering": [  "120-277;347"],"Voltage Offering UOM": [  "V"],"Wattage Range": [  "0-100"],"Wattage Range UOM": [  "W"],"Efficacy Range": [  "Up to 165"],"Efficacy Range UOM": [  "LPW"],"CCT Offering": [  "3000;3500;4000;5000"],"CCT Offering UOM": [  "K"],"CRI Offering": [  "83;90 TriGain®"],"Optics & Distributions": [  "Aisle;Wide;Very Wide;Wall Wash;Uplight"],"SAP Product Hierarchy": [  "RLM5005026000001"],"Controls & Sensors": [  "Daintree Control Options;Daintree Integrated Sensor Options;Other Integrated Sensor/Controls Available;0-10V Standard Dimming"],"Color Offering": [  "White;Black;Silver;Red"],"Mounting Options": [  "Suspension or Direct Mount"],"Family Accessories & Options": [  "Emergency Light;Power cord kit;Suspended kits;Starter kits;Reflector Wings"],"Associated Parts": [  "123"],"Related Products": [  ""],"Suggested Traditional Replacement": [  "LFL"],"Suggested Replacement SKU/Family": [  ""],"Instabase Directory Link": [  "https://instabase.lightinganalysts.com/IITC/?uid=902-PF5BFFYPSR7BDEHGXV26PTEG&selectedIDBs=1663,1665,1667,1669&textSrch=LUS%20LUMINATION&expand=1&setView=0&sam=1#tabs-Search"],"Energy Certifications": [  "DLC Premium;DLC Standard"],"Safety Certifications": [  "cULus"],"Region Certifications": [  "NOM"],"Misc Certifications": [  ""],"Regulatory": [  "DLC qualified models available Please refer to http://www.designlights.org/QPL for complete information"],"BAA or TAA Compliant": [  ""],"IP Rating": [  "IP20"],"NSF Rated": [  "false"],"RoHS": [  "true"],"Length UOM": [  "In"],"Width UOM": [  "In"],"Height UOM": [  "In"],"Diameter UOM": [  "In"],"Weight UOM": [  "Lb"],"UOS Package Length UOM In": [  "In"],"UOS Package Width UOM In": [  "In"],"UOS Package Height UOM In": [  "In"],"UOS Package Weight UOM Lb": [  "Lb"],"Case Package Length UOM In": [  "In"],"Case Package Width UOM In": [  "In"],"Case Package Height UOM In": [  "In"],"Case Package Weight UOM Lb": [  "Lb"],"Standard Pack Quantity UOM": [  "Lamps"],"AC Input Voltage UOM": [  "V"],"Light Output Range UOM": [  "(μmol/s)"],"Family Spectra": [  ""],"Operating Voltage Range UOM": [  "V"],"Minimum Light Intensity UOM": [  "cd"],"Maximum Light Intensity UOM": [  "cd"],"Nominal Power UOM": [  "W"],"Performance Levels Distribution": [  ""],"Lamp Appearance ": [  ""],"Lumens per Module UOM": [  "lm"],"Lumens per Foot UOM": [  "lm/ft"],"Watts per Module UOM": [  "W"],"Item Length UOM": [  "mm"],"Item Width UOM": [  "mm"],"Item Height UOM": [  "mm"],"Item Diameter UOM": [  "mm"],"Item Weight UOM": [  "kg"],"UOS Package Length UOM mm": [  "mm"],"UOS Package Width UOM mm": [  "mm"],"UOS Package Height UOM mm": [  "mm"],"UOS Package Weight UOM mm": [  "kg"],"Case Package Length UOM mm": [  "mm"],"Case Package Width UOM mm": [  "mm"],"Case Package Height UOM mm": [  "mm"],"Case Package Weight UOM kg": [  "kg"],"Technology Type": [  "Traditional"],"Product Images": [  ""],"Product Documents": [  ""],"Certifications": [  "cULus;No;NOM;DLC Premium"],"Disinfection Product": [  "false"],"Effective Projected Area": ["abc"],"Product Shape": [  "4 & 8 ft for both Continuous or Independent runs"],"UL Type": ["A"],"Website Link": [  "https://products.gecurrent.com/indoor-lighting/suspended/lumination-lus-series-ultron-suspended"],"Catalog Number": [  "F28T8/CW/4 6PK"],"Item Status - US": [  "02 - General Availability"],"UPC": [  "43168980777"],"PH4 Configuration": [  "LFL LEVEL 4 DEFAULT"],"PH5 Intelligence": [  "LFL T8 APPLIANCE"],"Lumens": [  "1350"],"Lumens UOM": [  "lm"],"Wattage (W)": [  "19"],"Wattage UOM": [  "W"],"Efficacy": [  "71.05263157894737"],"Optical Distribution": [  "1"],"BUG Rating": [  "1"],"Color Temperature": [  "4100"],"CCT UOM": [  "K"],"CRI": [  "60"],"Wattage Replacement": [  "0-100"],"Wattage Replacement UOM": [  "W"],"Suggested Replacement SKU/Family": [  ""],"Length": [  "28"],"Length UOM": [  "In"],"Width": [  "1.09"],"Width UOM": [  "In"],"Height": [  "1.09"],"Height UOM": [  "In"],"Diameter": [  "1"],"Diameter UOM": [  "In"],"MOL UOM": [  "In"],"Weight": [  "0.343"],"Weight UOM": [  "Lb"],"Suitable Frame Dimensions UOM In": [  "In"],"Frame Hole Size UOM In": [  "In"],"Inside Diameter UOM In": [  "In"],"Accessories & Options": [  "In"],"Ceiling Hole Min Size UOM In": [  "In"],"Ceiling Hole Max Size UOM In": [  "In"],"Light Output PPF UOM": [  "(μmol/s)"],"Voltage (V)": [  "1"],"Efficacy (μmol/J) UOM": [  "(μmol/s)"],"Item Length Metric": [  "711.2"],"Item Length UOM": [  "mm"],"Item Width Metric": [  "27.686"],"Item Width UOM": [  "mm"],"Item Height Metric": [  "27.686"],"Item Height UOM": [  "mm"],"Item Diameter Metric": [  "25.4"],"Item Color": [  "mm"],"Lamp MOL UOM": [  "mm"],"Item Weight Metric": [  "0.155555555555555555555555555555555556"],"Item Weight UOM": [  "kg"],"Suitable Frame Dimensions UOM mm": [  "mm"],"Frame Hole Size UOM mm": [  "mm"],"Inside Diameter UOM mm": [  "mm"],"Outside Diameter UOM mm": [  "mm"],"Ceiling Hole Min Size UOM mm": [  "mm"],"Ceiling Hole Max Size UOM mm": [  "mm"]  }, {"SKU or Family": [  {"id": 147385257,"external_id": "Family","name": "Family","parent_id": null,"target_field_id": 5390805,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-bb439dc4-0b65-463f-9a8d-14a9ab10a475","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Family": [  "ABC"],"GTM Family ID":[  "ABC"],"Catalog Logic": [  "Lumination® LUS series"],"Commercial Launch Date": [  "2017-01-01"],"Country of Origin": [  "Mexico"],"Manufacturer": [  "GE Current, a Daintree company"],"PH1 Product Line": [  "INDOOR FIXTURES - LED"],"PH2 Application": [  "INDOOR SUSPENDED"],"PH3 Family": [  "LUS ULTRON SUSPENDED"],"Technology Enabled": [  "TriGain®;Daintree"],"Taxonomy": [  {"id": 147385261,"external_id": "Fixtures","name": "Fixtures","parent_id": null,"target_field_id": 5391037,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-82ac6d67-1ede-40e7-8468-769f453c736d","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Brand": [  "Lumination®"],"Family Features & Benefits Bullets": [  "Toolless replaceable light enginenMultiple distributions – Aisle, Wide, Very Wide, Wall WashnExclusive reveal® TriGain®  technology – standardnFast toolless quick connect for easy installs, plus anti-snaking lever to adjust for STRAIGHT continuous runsnUp to 400ft run length with one power drop!n3500K, 4000K and 5000K color temperaturenLumen output: 4,200-24,000nAvailable in 4 and 8 lengthsnUp to 165 LPW efficacynIntegrated occupancy and daylight harvesting sensors avaialblen0-10V dimming standardn5-year limited system warranty standard"],"Family Applications": [  "Retail"],"Product Description Short": [  "Lumination® LUS Series LED luminaire is an energy-efficient, low maintenance alternative to traditional fluorescent lighting in a variety of commercial and low bay lighting applications. The LUS series offers customers a superior mix of value and performance."],"Product Description Long": [  "Currents Lumination® LUS series comes standard with Trigain®  to bring out the best colors. It is uniquely positioned to provide a performance of 165 LPW while delivering an astonishing 90CRI and an R9 value of 90. The fixture comes in a minimalistic form factor, making it ideal for installation in several settings and scenarios. Moreover, the LUS offers customization of color finish as well as a range of beam distributions specific to your needs. This is achieved through a sophisticated diffusers."],"Warranty": [  "5 year limited warranty"],"Programs": [  "123"],"Family Icons": [  ""],"Product Category": [  "Indoor"],"Product Subcategory": [  "Suspended"],"Bulb Base Type": [  "N/A"],"Bulb Shape": [  "N/A"],"Operating Life (Hrs)": [  "N/A"],"Operating Life UOM": [  "hours"],"Lumen Maintenance Rating": [  "L70 @ 100,000 hours"],"Lensing Description": [  "Polycarbonate"],"Housing Description": [  "Extruded aluminum body"],"Paint/Finish Description": [  "Powder coat Painted Housing"],"Material": [  "111"],"Vibration Rating UOM": [  "G"],"Input Frequency": [  "50/60"],"Input Frequency UOM": [  "Hz"],"Driver / Ballast Type": [  "Class 2 and Class 1(for high lumen skus) LED driver rated for 50,000 hours"],"System Power Factor": [  ">0.9"],"THD": [  "<20%"],"Surge protection": [  "100 kHz ring wave, 2.5 kV level"],"Environmental Conditions": [  "Damp "],"Operating Temp range": [  "-10 to 35"],"Operating Temp UOM": [  "°C"],"Storage Temp": [  "-40 to 70"],"Storage Temp UOM": [  "°C"],"Family Modules/Configurations": [  "4 & 8 ft for both Continuous or Independent runs"],"Lumen Range": [  "4,200 - 24,000"],"Lumen Range UOM": [  "lm"],"Voltage Offering": [  "120-277;347"],"Voltage Offering UOM": [  "V"],"Wattage Range": [  "0-100"],"Wattage Range UOM": [  "W"],"Efficacy Range": [  "Up to 165"],"Efficacy Range UOM": [  "LPW"],"CCT Offering": [  "3000;3500;4000;5000"],"CCT Offering UOM": [  "K"],"CRI Offering": [  "83;90 TriGain®"],"Optics & Distributions": [  "Aisle;Wide;Very Wide;Wall Wash;Uplight"],"SAP Product Hierarchy": [  "RLM5005026000001"],"Controls & Sensors": [  "Daintree Control Options;Daintree Integrated Sensor Options;Other Integrated Sensor/Controls Available;0-10V Standard Dimming"],"Color Offering": [  "White;Black;Silver;Red"],"Mounting Options": [  "Suspension or Direct Mount"],"Family Accessories & Options": [  "Emergency Light;Power cord kit;Suspended kits;Starter kits;Reflector Wings"],"Associated Parts": [  "123"],"Related Products": [  ""],"Suggested Traditional Replacement": [  "LFL"],"Suggested Replacement SKU/Family": [  ""],"Instabase Directory Link": [  "https://instabase.lightinganalysts.com/IITC/?uid=902-PF5BFFYPSR7BDEHGXV26PTEG&selectedIDBs=1663,1665,1667,1669&textSrch=LUS%20LUMINATION&expand=1&setView=0&sam=1#tabs-Search"],"Energy Certifications": [  "DLC Premium;DLC Standard"],"Safety Certifications": [  "cULus"],"Region Certifications": [  "NOM"],"Misc Certifications": [  ""],"Regulatory": [  "DLC qualified models available Please refer to http://www.designlights.org/QPL for complete information"],"BAA or TAA Compliant": [  ""],"IP Rating": [  "IP20"],"NSF Rated": [  "false"],"RoHS": [  "true"],"Length UOM": [  "In"],"Width UOM": [  "In"],"Height UOM": [  "In"],"Diameter UOM": [  "In"],"Weight UOM": [  "Lb"],"UOS Package Length UOM In": [  "In"],"UOS Package Width UOM In": [  "In"],"UOS Package Height UOM In": [  "In"],"UOS Package Weight UOM Lb": [  "Lb"],"Case Package Length UOM In": [  "In"],"Case Package Width UOM In": [  "In"],"Case Package Height UOM In": [  "In"],"Case Package Weight UOM Lb": [  "Lb"],"Standard Pack Quantity UOM": [  "Lamps"],"AC Input Voltage UOM": [  "V"],"Light Output Range UOM": [  "(μmol/s)"],"Family Spectra": [  ""],"Operating Voltage Range UOM": [  "V"],"Minimum Light Intensity UOM": [  "cd"],"Maximum Light Intensity UOM": [  "cd"],"Nominal Power UOM": [  "W"],"Performance Levels Distribution": [  ""],"Lamp Appearance ": [  ""],"Lumens per Module UOM": [  "lm"],"Lumens per Foot UOM": [  "lm/ft"],"Watts per Module UOM": [  "W"],"Item Length UOM": [  "mm"],"Item Width UOM": [  "mm"],"Item Height UOM": [  "mm"],"Item Diameter UOM": [  "mm"],"Item Weight UOM": [  "kg"],"UOS Package Length UOM mm": [  "mm"],"UOS Package Width UOM mm": [  "mm"],"UOS Package Height UOM mm": [  "mm"],"UOS Package Weight UOM mm": [  "kg"],"Case Package Length UOM mm": [  "mm"],"Case Package Width UOM mm": [  "mm"],"Case Package Height UOM mm": [  "mm"],"Case Package Weight UOM kg": [  "kg"],"Technology Type": [  "Traditional"],"Product Images": [  ""],"Product Documents": [  ""],"Certifications": [  "cULus;No;NOM;DLC Premium"],"Disinfection Product": [  "false"],"Effective Projected Area": ["abc"],"Product Shape": [  "4 & 8 ft for both Continuous or Independent runs"],"UL Type": ["A"],"Website Link": [  "https://products.gecurrent.com/indoor-lighting/suspended/lumination-lus-series-ultron-suspended"]  }]'; 
 	 String ContentsString ='[ {"SKU or Family": [  {"id": 147385256,"external_id": "SKU","name": "SKU","parent_id": null,"target_field_id": 5390805,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-0b7eee2e-ad1f-4681-b9b1-957cd0c27b4e","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"SKU": [  "17704"],"GTM Family ID":[  "ABC"],"SKU Configuration":[  "Test"],"Country of Origin": [  "Mexico"],"Manufacturer": [  "GE Current, a Daintree company"],"PH1 Product Line": [  "INDOOR FIXTURES - LED"],"PH2 Application": [  "INDOOR SUSPENDED"],"PH3 Family": [  "LUS ULTRON SUSPENDED"],"Technology Enabled": [  "TriGain®;Daintree"],"Taxonomy": [  {"id": 147385261,"external_id": "Fixtures","name": "Fixtures","parent_id": null,"target_field_id": 5391037,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-82ac6d67-1ede-40e7-8468-769f453c736d","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Brand": [  "Lumination®"],"Family Features & Benefits Bullets": [  "Toolless replaceable light enginenMultiple distributions – Aisle, Wide, Very Wide, Wall WashnExclusive reveal® TriGain®  technology – standardnFast toolless quick connect for easy installs, plus anti-snaking lever to adjust for STRAIGHT continuous runsnUp to 400ft run length with one power drop!n3500K, 4000K and 5000K color temperaturenLumen output: 4,200-24,000nAvailable in 4 and 8 lengthsnUp to 165 LPW efficacynIntegrated occupancy and daylight harvesting sensors avaialblen0-10V dimming standardn5-year limited system warranty standard"],"Family Applications": [  "Retail"],"Product Description Short": [  "Lumination® LUS Series LED luminaire is an energy-efficient, low maintenance alternative to traditional fluorescent lighting in a variety of commercial and low bay lighting applications. The LUS series offers customers a superior mix of value and performance."],"Product Description Long": [  "Currents Lumination® LUS series comes standard with Trigain®  to bring out the best colors. It is uniquely positioned to provide a performance of 165 LPW while delivering an astonishing 90CRI and an R9 value of 90. The fixture comes in a minimalistic form factor, making it ideal for installation in several settings and scenarios. Moreover, the LUS offers customization of color finish as well as a range of beam distributions specific to your needs. This is achieved through a sophisticated diffusers."],"Warranty": [  "5 year limited warranty"],"Programs": [  "123"],"Family Icons": [  ""],"Product Category": [  "Indoor"],"Product Subcategory": [  "Suspended"],"Bulb Base Type": [  "N/A"],"Bulb Shape": [  "N/A"],"Operating Life (Hrs)": [  "N/A"],"Operating Life UOM": [  "hours"],"Lumen Maintenance Rating": [  "L70 @ 100,000 hours"],"Lensing Description": [  "Polycarbonate"],"Housing Description": [  "Extruded aluminum body"],"Paint/Finish Description": [  "Powder coat Painted Housing"],"Material": [  "111"],"Vibration Rating UOM": [  "G"],"Input Frequency": [  "50/60"],"Input Frequency UOM": [  "Hz"],"Driver / Ballast Type": [  "Class 2 and Class 1(for high lumen skus) LED driver rated for 50,000 hours"],"System Power Factor": [  ">0.9"],"THD": [  "<20%"],"Surge protection": [  "100 kHz ring wave, 2.5 kV level"],"Environmental Conditions": [  "Damp "],"Operating Temp range": [  "-10 to 35"],"Operating Temp UOM": [  "°C"],"Storage Temp": [  "-40 to 70"],"Storage Temp UOM": [  "°C"],"Family Modules/Configurations": [  "4 & 8 ft for both Continuous or Independent runs"],"Lumen Range": [  "4,200 - 24,000"],"Lumen Range UOM": [  "lm"],"Voltage Offering": [  "120-277;347"],"Voltage Offering UOM": [  "V"],"Wattage Range": [  "0-100"],"Wattage Range UOM": [  "W"],"Efficacy Range": [  "Up to 165"],"Efficacy Range UOM": [  "LPW"],"CCT Offering": [  "3000;3500;4000;5000"],"CCT Offering UOM": [  "K"],"CRI Offering": [  "83;90 TriGain®"],"Optics & Distributions": [  "Aisle;Wide;Very Wide;Wall Wash;Uplight"],"SAP Product Hierarchy": [  "RLM5005026000001"],"Controls & Sensors": [  "Daintree Control Options;Daintree Integrated Sensor Options;Other Integrated Sensor/Controls Available;0-10V Standard Dimming"],"Color Offering": [  "White;Black;Silver;Red"],"Mounting Options": [  "Suspension or Direct Mount"],"Family Accessories & Options": [  "Emergency Light;Power cord kit;Suspended kits;Starter kits;Reflector Wings"],"Associated Parts": [  "123"],"Related Products": [  ""],"Suggested Traditional Replacement": [  "LFL"],"Suggested Replacement SKU/Family": [  ""],"Instabase Directory Link": [  "https://instabase.lightinganalysts.com/IITC/?uid=902-PF5BFFYPSR7BDEHGXV26PTEG&selectedIDBs=1663,1665,1667,1669&textSrch=LUS%20LUMINATION&expand=1&setView=0&sam=1#tabs-Search"],"Energy Certifications": [  "DLC Premium;DLC Standard"],"Safety Certifications": [  "cULus"],"Region Certifications": [  "NOM"],"Misc Certifications": [  ""],"Regulatory": [  "DLC qualified models available Please refer to http://www.designlights.org/QPL for complete information"],"BAA or TAA Compliant": [  ""],"IP Rating": [  "IP20"],"NSF Rated": [  "false"],"RoHS": [  "true"],"Length UOM": [  "In"],"Width UOM": [  "In"],"Height UOM": [  "In"],"Diameter UOM": [  "In"],"Weight UOM": [  "Lb"],"UOS Package Length UOM In": [  "In"],"UOS Package Width UOM In": [  "In"],"UOS Package Height UOM In": [  "In"],"UOS Package Weight UOM Lb": [  "Lb"],"Case Package Length UOM In": [  "In"],"Case Package Width UOM In": [  "In"],"Case Package Height UOM In": [  "In"],"Case Package Weight UOM Lb": [  "Lb"],"Standard Pack Quantity UOM": [  "Lamps"],"AC Input Voltage UOM": [  "V"],"Light Output Range UOM": [  "(μmol/s)"],"Family Spectra": [  ""],"Operating Voltage Range UOM": [  "V"],"Minimum Light Intensity UOM": [  "cd"],"Maximum Light Intensity UOM": [  "cd"],"Nominal Power UOM": [  "W"],"Performance Levels Distribution": [  ""],"Lamp Appearance ": [  ""],"Lumens per Module UOM": [  "lm"],"Lumens per Foot UOM": [  "lm/ft"],"Watts per Module UOM": [  "W"],"Item Length UOM": [  "mm"],"Item Width UOM": [  "mm"],"Item Height UOM": [  "mm"],"Item Diameter UOM": [  "mm"],"Item Weight UOM": [  "kg"],"UOS Package Length UOM mm": [  "mm"],"UOS Package Width UOM mm": [  "mm"],"UOS Package Height UOM mm": [  "mm"],"UOS Package Weight UOM mm": [  "kg"],"Case Package Length UOM mm": [  "mm"],"Case Package Width UOM mm": [  "mm"],"Case Package Height UOM mm": [  "mm"],"Case Package Weight UOM kg": [  "kg"],"Technology Type": [  "Traditional"],"Product Images": [  ""],"Product Documents": [  ""],"Certifications": [  "cULus;No;NOM;DLC Premium"],"Disinfection Product": [  "false"],"Effective Projected Area": ["abc"],"Product Shape": [  "4 & 8 ft for both Continuous or Independent runs"],"UL Type": ["A"],"Website Link": [  "https://products.gecurrent.com/indoor-lighting/suspended/lumination-lus-series-ultron-suspended"],"Catalog Number": [  "F28T8/CW/4 6PK"],"Item Status - US": [  "02 - General Availability"],"UPC": [  "43168980777"],"PH4 Configuration": [  "LFL LEVEL 4 DEFAULT"],"PH5 Intelligence": [  "LFL T8 APPLIANCE"],"Lumens": [  "1350"],"Lumens UOM": [  "lm"],"Wattage (W)": [  "19"],"Wattage UOM": [  "W"],"Efficacy": [  "71.05263157894737"],"Optical Distribution": [  "1"],"BUG Rating": [  "1"],"Color Temperature": [  "4100"],"CCT UOM": [  "K"],"CRI": [  "60"],"Wattage Replacement": [  "0-100"],"Wattage Replacement UOM": [  "W"],"Suggested Replacement SKU/Family": [  ""],"Length": [  "28"],"Length UOM": [  "In"],"Width": [  "1.09"],"Width UOM": [  "In"],"Height": [  "1.09"],"Height UOM": [  "In"],"Diameter": [  "1"],"Diameter UOM": [  "In"],"MOL UOM": [  "In"],"Weight": [  "0.343"],"Weight UOM": [  "Lb"],"Suitable Frame Dimensions UOM In": [  "In"],"Frame Hole Size UOM In": [  "In"],"Inside Diameter UOM In": [  "In"],"Accessories & Options": [  "In"],"Ceiling Hole Min Size UOM In": [  "In"],"Ceiling Hole Max Size UOM In": [  "In"],"Light Output PPF UOM": [  "(μmol/s)"],"Voltage (V)": [  "1"],"Efficacy (μmol/J) UOM": [  "(μmol/s)"],"Item Length Metric": [  "711.2"],"Item Length UOM": [  "mm"],"Item Width Metric": [  "27.686"],"Item Width UOM": [  "mm"],"Item Height Metric": [  "27.686"],"Item Height UOM": [  "mm"],"Item Diameter Metric": [  "25.4"],"Item Color": [  "mm"],"Lamp MOL UOM": [  "mm"],"Item Weight Metric": [  "0.155555555555555555555555555555555556"],"Item Weight UOM": [  "kg"],"Suitable Frame Dimensions UOM mm": [  "mm"],"Frame Hole Size UOM mm": [  "mm"],"Inside Diameter UOM mm": [  "mm"],"Outside Diameter UOM mm": [  "mm"],"Ceiling Hole Min Size UOM mm": [  "mm"],"Ceiling Hole Max Size UOM mm": [  "mm"]  }, {"SKU or Family": [  {"id": 147385257,"external_id": "Family","name": "Family","parent_id": null,"target_field_id": 5390805,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-bb439dc4-0b65-463f-9a8d-14a9ab10a475","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Family": [  "ABC"],"GTM Family ID":[  "ABC"],"Catalog Logic": [  "Lumination® LUS series"],"Commercial Launch Date": [  "2017-01-01"],"Country of Origin": [  "Mexico"],"Manufacturer": [  "GE Current, a Daintree company"],"PH1 Product Line": [  "INDOOR FIXTURES - LED"],"PH2 Application": [  "INDOOR SUSPENDED"],"PH3 Family": [  "LUS ULTRON SUSPENDED"],"Technology Enabled": [  "TriGain®;Daintree"],"Taxonomy": [  {"id": 147385261,"external_id": "Fixtures","name": "Fixtures","parent_id": null,"target_field_id": 5391037,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-82ac6d67-1ede-40e7-8468-769f453c736d","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Brand": [  "Lumination®"],"Family Features & Benefits Bullets": [  "Toolless replaceable light enginenMultiple distributions – Aisle, Wide, Very Wide, Wall WashnExclusive reveal® TriGain®  technology – standardnFast toolless quick connect for easy installs, plus anti-snaking lever to adjust for STRAIGHT continuous runsnUp to 400ft run length with one power drop!n3500K, 4000K and 5000K color temperaturenLumen output: 4,200-24,000nAvailable in 4 and 8 lengthsnUp to 165 LPW efficacynIntegrated occupancy and daylight harvesting sensors avaialblen0-10V dimming standardn5-year limited system warranty standard"],"Family Applications": [  "Retail"],"Product Description Short": [  "Lumination® LUS Series LED luminaire is an energy-efficient, low maintenance alternative to traditional fluorescent lighting in a variety of commercial and low bay lighting applications. The LUS series offers customers a superior mix of value and performance."],"Product Description Long": [  "Currents Lumination® LUS series comes standard with Trigain®  to bring out the best colors. It is uniquely positioned to provide a performance of 165 LPW while delivering an astonishing 90CRI and an R9 value of 90. The fixture comes in a minimalistic form factor, making it ideal for installation in several settings and scenarios. Moreover, the LUS offers customization of color finish as well as a range of beam distributions specific to your needs. This is achieved through a sophisticated diffusers."],"Warranty": [  "5 year limited warranty"],"Programs": [  "123"],"Family Icons": [  ""],"Product Category": [  "Indoor"],"Product Subcategory": [  "Suspended"],"Bulb Base Type": [  "N/A"],"Bulb Shape": [  "N/A"],"Operating Life (Hrs)": [  "N/A"],"Operating Life UOM": [  "hours"],"Lumen Maintenance Rating": [  "L70 @ 100,000 hours"],"Lensing Description": [  "Polycarbonate"],"Housing Description": [  "Extruded aluminum body"],"Paint/Finish Description": [  "Powder coat Painted Housing"],"Material": [  "111"],"Vibration Rating UOM": [  "G"],"Input Frequency": [  "50/60"],"Input Frequency UOM": [  "Hz"],"Driver / Ballast Type": [  "Class 2 and Class 1(for high lumen skus) LED driver rated for 50,000 hours"],"System Power Factor": [  ">0.9"],"THD": [  "<20%"],"Surge protection": [  "100 kHz ring wave, 2.5 kV level"],"Environmental Conditions": [  "Damp "],"Operating Temp range": [  "-10 to 35"],"Operating Temp UOM": [  "°C"],"Storage Temp": [  "-40 to 70"],"Storage Temp UOM": [  "°C"],"Family Modules/Configurations": [  "4 & 8 ft for both Continuous or Independent runs"],"Lumen Range": [  "4,200 - 24,000"],"Lumen Range UOM": [  "lm"],"Voltage Offering": [  "120-277;347"],"Voltage Offering UOM": [  "V"],"Wattage Range": [  "0-100"],"Wattage Range UOM": [  "W"],"Efficacy Range": [  "Up to 165"],"Efficacy Range UOM": [  "LPW"],"CCT Offering": [  "3000;3500;4000;5000"],"CCT Offering UOM": [  "K"],"CRI Offering": [  "83;90 TriGain®"],"Optics & Distributions": [  "Aisle;Wide;Very Wide;Wall Wash;Uplight"],"SAP Product Hierarchy": [  "RLM5005026000001"],"Controls & Sensors": [  "Daintree Control Options;Daintree Integrated Sensor Options;Other Integrated Sensor/Controls Available;0-10V Standard Dimming"],"Color Offering": [  "White;Black;Silver;Red"],"Mounting Options": [  "Suspension or Direct Mount"],"Family Accessories & Options": [  "Emergency Light;Power cord kit;Suspended kits;Starter kits;Reflector Wings"],"Associated Parts": [  "123"],"Related Products": [  ""],"Suggested Traditional Replacement": [  "LFL"],"Suggested Replacement SKU/Family": [  ""],"Instabase Directory Link": [  "https://instabase.lightinganalysts.com/IITC/?uid=902-PF5BFFYPSR7BDEHGXV26PTEG&selectedIDBs=1663,1665,1667,1669&textSrch=LUS%20LUMINATION&expand=1&setView=0&sam=1#tabs-Search"],"Energy Certifications": [  "DLC Premium;DLC Standard"],"Safety Certifications": [  "cULus"],"Region Certifications": [  "NOM"],"Misc Certifications": [  ""],"Regulatory": [  "DLC qualified models available Please refer to http://www.designlights.org/QPL for complete information"],"BAA or TAA Compliant": [  ""],"IP Rating": [  "IP20"],"NSF Rated": [  "false"],"RoHS": [  "true"],"Length UOM": [  "In"],"Width UOM": [  "In"],"Height UOM": [  "In"],"Diameter UOM": [  "In"],"Weight UOM": [  "Lb"],"UOS Package Length UOM In": [  "In"],"UOS Package Width UOM In": [  "In"],"UOS Package Height UOM In": [  "In"],"UOS Package Weight UOM Lb": [  "Lb"],"Case Package Length UOM In": [  "In"],"Case Package Width UOM In": [  "In"],"Case Package Height UOM In": [  "In"],"Case Package Weight UOM Lb": [  "Lb"],"Standard Pack Quantity UOM": [  "Lamps"],"AC Input Voltage UOM": [  "V"],"Light Output Range UOM": [  "(μmol/s)"],"Family Spectra": [  ""],"Operating Voltage Range UOM": [  "V"],"Minimum Light Intensity UOM": [  "cd"],"Maximum Light Intensity UOM": [  "cd"],"Nominal Power UOM": [  "W"],"Performance Levels Distribution": [  ""],"Lamp Appearance ": [  ""],"Lumens per Module UOM": [  "lm"],"Lumens per Foot UOM": [  "lm/ft"],"Watts per Module UOM": [  "W"],"Item Length UOM": [  "mm"],"Item Width UOM": [  "mm"],"Item Height UOM": [  "mm"],"Item Diameter UOM": [  "mm"],"Item Weight UOM": [  "kg"],"UOS Package Length UOM mm": [  "mm"],"UOS Package Width UOM mm": [  "mm"],"UOS Package Height UOM mm": [  "mm"],"UOS Package Weight UOM mm": [  "kg"],"Case Package Length UOM mm": [  "mm"],"Case Package Width UOM mm": [  "mm"],"Case Package Height UOM mm": [  "mm"],"Case Package Weight UOM kg": [  "kg"],"Technology Type": [  "Traditional"],"Product Images": [  ""],"Product Documents": [  ""],"Certifications": [  "cULus;No;NOM;DLC Premium"],"Disinfection Product": [  "false"],"Effective Projected Area": ["abc"],"Product Shape": [  "4 & 8 ft for both Continuous or Independent runs"],"UL Type": ["A"],"Website Link": [  "https://products.gecurrent.com/indoor-lighting/suspended/lumination-lus-series-ultron-suspended"]  }]'; 
 	    //String ContentsString ='[ {"SKU or Family": [  {"id": 147385256,"external_id": "SKU","name": "SKU","parent_id": null,"target_field_id": 5390805,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-0b7eee2e-ad1f-4681-b9b1-957cd0c27b4e","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"SKU": [  "17704"],"GTM Family ID":[  "ABC"],"ProLine":[  "Test1"],[  "QuickShip":[  "True"],"Accessory SKU":["Test"],"SKU Configuration":[  "Test"],"Country of Origin": [  "Mexico"],"Manufacturer": [  "GE Current, a Daintree company"],"PH1 Product Line": [  "INDOOR FIXTURES - LED"],"PH2 Application": [  "INDOOR SUSPENDED"],"PH3 Family": [  "LUS ULTRON SUSPENDED"],"Technology Enabled": [  "TriGain®;Daintree"],"Taxonomy": [  {"id": 147385261,"external_id": "Fixtures","name": "Fixtures","parent_id": null,"target_field_id": 5391037,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-82ac6d67-1ede-40e7-8468-769f453c736d","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Brand": [  "Lumination®"],"Family Features & Benefits Bullets": [  "Toolless replaceable light enginenMultiple distributions – Aisle, Wide, Very Wide, Wall WashnExclusive reveal® TriGain®  technology – standardnFast toolless quick connect for easy installs, plus anti-snaking lever to adjust for STRAIGHT continuous runsnUp to 400ft run length with one power drop!n3500K, 4000K and 5000K color temperaturenLumen output: 4,200-24,000nAvailable in 4 and 8 lengthsnUp to 165 LPW efficacynIntegrated occupancy and daylight harvesting sensors avaialblen0-10V dimming standardn5-year limited system warranty standard"],"Family Applications": [  "Retail"],"Product Description Short": [  "Lumination® LUS Series LED luminaire is an energy-efficient, low maintenance alternative to traditional fluorescent lighting in a variety of commercial and low bay lighting applications. The LUS series offers customers a superior mix of value and performance."],"Product Description Long": [  "Currents Lumination® LUS series comes standard with Trigain®  to bring out the best colors. It is uniquely positioned to provide a performance of 165 LPW while delivering an astonishing 90CRI and an R9 value of 90. The fixture comes in a minimalistic form factor, making it ideal for installation in several settings and scenarios. Moreover, the LUS offers customization of color finish as well as a range of beam distributions specific to your needs. This is achieved through a sophisticated diffusers."],"Warranty": [  "5 year limited warranty"],"Programs": [  "123"],"Family Icons": [  ""],"Product Category": [  "Indoor"],"Product Subcategory": [  "Suspended"],"Bulb Base Type": [  "N/A"],"Bulb Shape": [  "N/A"],"Operating Life (Hrs)": [  "N/A"],"Operating Life UOM": [  "hours"],"Lumen Maintenance Rating": [  "L70 @ 100,000 hours"],"Lensing Description": [  "Polycarbonate"],"Housing Description": [  "Extruded aluminum body"],"Paint/Finish Description": [  "Powder coat Painted Housing"],"Material": [  "111"],"Vibration Rating UOM": [  "G"],"Input Frequency": [  "50/60"],"Input Frequency UOM": [  "Hz"],"Driver / Ballast Type": [  "Class 2 and Class 1(for high lumen skus) LED driver rated for 50,000 hours"],"System Power Factor": [  ">0.9"],"THD": [  "<20%"],"Surge protection": [  "100 kHz ring wave, 2.5 kV level"],"Environmental Conditions": [  "Damp "],"Operating Temp range": [  "-10 to 35"],"Operating Temp UOM": [  "°C"],"Storage Temp": [  "-40 to 70"],"Storage Temp UOM": [  "°C"],"Family Modules/Configurations": [  "4 & 8 ft for both Continuous or Independent runs"],"Lumen Range": [  "4,200 - 24,000"],"Lumen Range UOM": [  "lm"],"Voltage Offering": [  "120-277;347"],"Voltage Offering UOM": [  "V"],"Wattage Range": [  "0-100"],"Wattage Range UOM": [  "W"],"Efficacy Range": [  "Up to 165"],"Efficacy Range UOM": [  "LPW"],"CCT Offering": [  "3000;3500;4000;5000"],"CCT Offering UOM": [  "K"],"CRI Offering": [  "83;90 TriGain®"],"Optics & Distributions": [  "Aisle;Wide;Very Wide;Wall Wash;Uplight"],"SAP Product Hierarchy": [  "RLM5005026000001"],"Controls & Sensors": [  "Daintree Control Options;Daintree Integrated Sensor Options;Other Integrated Sensor/Controls Available;0-10V Standard Dimming"],"Color Offering": [  "White;Black;Silver;Red"],"Mounting Options": [  "Suspension or Direct Mount"],"Family Accessories & Options": [  "Emergency Light;Power cord kit;Suspended kits;Starter kits;Reflector Wings"],"Associated Parts": [  "123"],"Related Products": [  ""],"Suggested Traditional Replacement": [  "LFL"],"Suggested Replacement SKU/Family": [  ""],"Instabase Directory Link": [  "https://instabase.lightinganalysts.com/IITC/?uid=902-PF5BFFYPSR7BDEHGXV26PTEG&selectedIDBs=1663,1665,1667,1669&textSrch=LUS%20LUMINATION&expand=1&setView=0&sam=1#tabs-Search"],"Energy Certifications": [  "DLC Premium;DLC Standard"],"Safety Certifications": [  "cULus"],"Region Certifications": [  "NOM"],"Misc Certifications": [  ""],"Regulatory": [  "DLC qualified models available Please refer to http://www.designlights.org/QPL for complete information"],"BAA or TAA Compliant": [  ""],"IP Rating": [  "IP20"],"NSF Rated": [  "false"],"RoHS": [  "true"],"Length UOM": [  "In"],"Width UOM": [  "In"],"Height UOM": [  "In"],"Diameter UOM": [  "In"],"Weight UOM": [  "Lb"],"UOS Package Length UOM In": [  "In"],"UOS Package Width UOM In": [  "In"],"UOS Package Height UOM In": [  "In"],"UOS Package Weight UOM Lb": [  "Lb"],"Case Package Length UOM In": [  "In"],"Case Package Width UOM In": [  "In"],"Case Package Height UOM In": [  "In"],"Case Package Weight UOM Lb": [  "Lb"],"Standard Pack Quantity UOM": [  "Lamps"],"AC Input Voltage UOM": [  "V"],"Light Output Range UOM": [  "(μmol/s)"],"Family Spectra": [  ""],"Operating Voltage Range UOM": [  "V"],"Minimum Light Intensity UOM": [  "cd"],"Maximum Light Intensity UOM": [  "cd"],"Nominal Power UOM": [  "W"],"Performance Levels Distribution": [  ""],"Lamp Appearance ": [  ""],"Lumens per Module UOM": [  "lm"],"Lumens per Foot UOM": [  "lm/ft"],"Watts per Module UOM": [  "W"],"Item Length UOM": [  "mm"],"Item Width UOM": [  "mm"],"Item Height UOM": [  "mm"],"Item Diameter UOM": [  "mm"],"Item Weight UOM": [  "kg"],"UOS Package Length UOM mm": [  "mm"],"UOS Package Width UOM mm": [  "mm"],"UOS Package Height UOM mm": [  "mm"],"UOS Package Weight UOM mm": [  "kg"],"Case Package Length UOM mm": [  "mm"],"Case Package Width UOM mm": [  "mm"],"Case Package Height UOM mm": [  "mm"],"Case Package Weight UOM kg": [  "kg"],"Technology Type": [  "Traditional"],"Product Images": [  ""],"Product Documents": [  ""],"Certifications": [  "cULus;No;NOM;DLC Premium"],"Disinfection Product": [  "false"],"Effective Projected Area": ["abc"],"Product Shape": [  "4 & 8 ft for both Continuous or Independent runs"],"UL Type": ["A"],"Website Link": [  "https://products.gecurrent.com/indoor-lighting/suspended/lumination-lus-series-ultron-suspended"],"Catalog Number": [  "F28T8/CW/4 6PK"],"Item Status - US": [  "02 - General Availability"],"UPC": [  "43168980777"],"PH4 Configuration": [  "LFL LEVEL 4 DEFAULT"],"PH5 Intelligence": [  "LFL T8 APPLIANCE"],"Lumens": [  "1350"],"Lumens UOM": [  "lm"],"Wattage (W)": [  "19"],"Wattage UOM": [  "W"],"Efficacy": [  "71.05263157894737"],"Optical Distribution": [  "1"],"BUG Rating": [  "1"],"Color Temperature": [  "4100"],"CCT UOM": [  "K"],"CRI": [  "60"],"Wattage Replacement": [  "0-100"],"Wattage Replacement UOM": [  "W"],"Suggested Replacement SKU/Family": [  ""],"Length": [  "28"],"Length UOM": [  "In"],"Width": [  "1.09"],"Width UOM": [  "In"],"Height": [  "1.09"],"Height UOM": [  "In"],"Diameter": [  "1"],"Diameter UOM": [  "In"],"MOL UOM": [  "In"],"Weight": [  "0.343"],"Weight UOM": [  "Lb"],"Suitable Frame Dimensions UOM In": [  "In"],"Frame Hole Size UOM In": [  "In"],"Inside Diameter UOM In": [  "In"],"Accessories & Options": [  "In"],"Ceiling Hole Min Size UOM In": [  "In"],"Ceiling Hole Max Size UOM In": [  "In"],"Light Output PPF UOM": [  "(μmol/s)"],"Voltage (V)": [  "1"],"Efficacy (μmol/J) UOM": [  "(μmol/s)"],"Item Length Metric": [  "711.2"],"Item Length UOM": [  "mm"],"Item Width Metric": [  "27.686"],"Item Width UOM": [  "mm"],"Item Height Metric": [  "27.686"],"Item Height UOM": [  "mm"],"Item Diameter Metric": [  "25.4"],"Item Color": [  "mm"],"Lamp MOL UOM": [  "mm"],"Item Weight Metric": [  "0.155555555555555555555555555555555556"],"Item Weight UOM": [  "kg"],"Suitable Frame Dimensions UOM mm": [  "mm"],"Frame Hole Size UOM mm": [  "mm"],"Inside Diameter UOM mm": [  "mm"],"Outside Diameter UOM mm": [  "mm"],"Ceiling Hole Min Size UOM mm": [  "mm"],"Ceiling Hole Max Size UOM mm": [  "mm"]  }, {"SKU or Family": [  {"id": 147385257,"external_id": "Family","name": "Family","parent_id": null,"target_field_id": 5390805,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-bb439dc4-0b65-463f-9a8d-14a9ab10a475","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Family": [  "ABC"],"GTM Family ID":[  "ABC"],"Catalog Logic": [  "Lumination® LUS series"],"Commercial Launch Date": [  "2017-01-01"],"Country of Origin": [  "Mexico"],"Manufacturer": [  "GE Current, a Daintree company"],"PH1 Product Line": [  "INDOOR FIXTURES - LED"],"PH2 Application": [  "INDOOR SUSPENDED"],"PH3 Family": [  "LUS ULTRON SUSPENDED"],"Technology Enabled": [  "TriGain®;Daintree"],"Taxonomy": [  {"id": 147385261,"external_id": "Fixtures","name": "Fixtures","parent_id": null,"target_field_id": 5391037,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-82ac6d67-1ede-40e7-8468-769f453c736d","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Brand": [  "Lumination®"],"Family Features & Benefits Bullets": [  "Toolless replaceable light enginenMultiple distributions – Aisle, Wide, Very Wide, Wall WashnExclusive reveal® TriGain®  technology – standardnFast toolless quick connect for easy installs, plus anti-snaking lever to adjust for STRAIGHT continuous runsnUp to 400ft run length with one power drop!n3500K, 4000K and 5000K color temperaturenLumen output: 4,200-24,000nAvailable in 4 and 8 lengthsnUp to 165 LPW efficacynIntegrated occupancy and daylight harvesting sensors avaialblen0-10V dimming standardn5-year limited system warranty standard"],"Family Applications": [  "Retail"],"Product Description Short": [  "Lumination® LUS Series LED luminaire is an energy-efficient, low maintenance alternative to traditional fluorescent lighting in a variety of commercial and low bay lighting applications. The LUS series offers customers a superior mix of value and performance."],"Product Description Long": [  "Currents Lumination® LUS series comes standard with Trigain®  to bring out the best colors. It is uniquely positioned to provide a performance of 165 LPW while delivering an astonishing 90CRI and an R9 value of 90. The fixture comes in a minimalistic form factor, making it ideal for installation in several settings and scenarios. Moreover, the LUS offers customization of color finish as well as a range of beam distributions specific to your needs. This is achieved through a sophisticated diffusers."],"Warranty": [  "5 year limited warranty"],"Programs": [  "123"],"Family Icons": [  ""],"Product Category": [  "Indoor"],"Product Subcategory": [  "Suspended"],"Bulb Base Type": [  "N/A"],"Bulb Shape": [  "N/A"],"Operating Life (Hrs)": [  "N/A"],"Operating Life UOM": [  "hours"],"Lumen Maintenance Rating": [  "L70 @ 100,000 hours"],"Lensing Description": [  "Polycarbonate"],"Housing Description": [  "Extruded aluminum body"],"Paint/Finish Description": [  "Powder coat Painted Housing"],"Material": [  "111"],"Vibration Rating UOM": [  "G"],"Input Frequency": [  "50/60"],"Input Frequency UOM": [  "Hz"],"Driver / Ballast Type": [  "Class 2 and Class 1(for high lumen skus) LED driver rated for 50,000 hours"],"System Power Factor": [  ">0.9"],"THD": [  "<20%"],"Surge protection": [  "100 kHz ring wave, 2.5 kV level"],"Environmental Conditions": [  "Damp "],"Operating Temp range": [  "-10 to 35"],"Operating Temp UOM": [  "°C"],"Storage Temp": [  "-40 to 70"],"Storage Temp UOM": [  "°C"],"Family Modules/Configurations": [  "4 & 8 ft for both Continuous or Independent runs"],"Lumen Range": [  "4,200 - 24,000"],"Lumen Range UOM": [  "lm"],"Voltage Offering": [  "120-277;347"],"Voltage Offering UOM": [  "V"],"Wattage Range": [  "0-100"],"Wattage Range UOM": [  "W"],"Efficacy Range": [  "Up to 165"],"Efficacy Range UOM": [  "LPW"],"CCT Offering": [  "3000;3500;4000;5000"],"CCT Offering UOM": [  "K"],"CRI Offering": [  "83;90 TriGain®"],"Optics & Distributions": [  "Aisle;Wide;Very Wide;Wall Wash;Uplight"],"SAP Product Hierarchy": [  "RLM5005026000001"],"Controls & Sensors": [  "Daintree Control Options;Daintree Integrated Sensor Options;Other Integrated Sensor/Controls Available;0-10V Standard Dimming"],"Color Offering": [  "White;Black;Silver;Red"],"Mounting Options": [  "Suspension or Direct Mount"],"Family Accessories & Options": [  "Emergency Light;Power cord kit;Suspended kits;Starter kits;Reflector Wings"],"Associated Parts": [  "123"],"Related Products": [  ""],"Suggested Traditional Replacement": [  "LFL"],"Suggested Replacement SKU/Family": [  ""],"Instabase Directory Link": [  "https://instabase.lightinganalysts.com/IITC/?uid=902-PF5BFFYPSR7BDEHGXV26PTEG&selectedIDBs=1663,1665,1667,1669&textSrch=LUS%20LUMINATION&expand=1&setView=0&sam=1#tabs-Search"],"Energy Certifications": [  "DLC Premium;DLC Standard"],"Safety Certifications": [  "cULus"],"Region Certifications": [  "NOM"],"Misc Certifications": [  ""],"Regulatory": [  "DLC qualified models available Please refer to http://www.designlights.org/QPL for complete information"],"BAA or TAA Compliant": [  ""],"IP Rating": [  "IP20"],"NSF Rated": [  "false"],"RoHS": [  "true"],"Length UOM": [  "In"],"Width UOM": [  "In"],"Height UOM": [  "In"],"Diameter UOM": [  "In"],"Weight UOM": [  "Lb"],"UOS Package Length UOM In": [  "In"],"UOS Package Width UOM In": [  "In"],"UOS Package Height UOM In": [  "In"],"UOS Package Weight UOM Lb": [  "Lb"],"Case Package Length UOM In": [  "In"],"Case Package Width UOM In": [  "In"],"Case Package Height UOM In": [  "In"],"Case Package Weight UOM Lb": [  "Lb"],"Standard Pack Quantity UOM": [  "Lamps"],"AC Input Voltage UOM": [  "V"],"Light Output Range UOM": [  "(μmol/s)"],"Family Spectra": [  ""],"Operating Voltage Range UOM": [  "V"],"Minimum Light Intensity UOM": [  "cd"],"Maximum Light Intensity UOM": [  "cd"],"Nominal Power UOM": [  "W"],"Performance Levels Distribution": [  ""],"Lamp Appearance ": [  ""],"Lumens per Module UOM": [  "lm"],"Lumens per Foot UOM": [  "lm/ft"],"Watts per Module UOM": [  "W"],"Item Length UOM": [  "mm"],"Item Width UOM": [  "mm"],"Item Height UOM": [  "mm"],"Item Diameter UOM": [  "mm"],"Item Weight UOM": [  "kg"],"UOS Package Length UOM mm": [  "mm"],"UOS Package Width UOM mm": [  "mm"],"UOS Package Height UOM mm": [  "mm"],"UOS Package Weight UOM mm": [  "kg"],"Case Package Length UOM mm": [  "mm"],"Case Package Width UOM mm": [  "mm"],"Case Package Height UOM mm": [  "mm"],"Case Package Weight UOM kg": [  "kg"],"Technology Type": [  "Traditional"],"Product Images": [  ""],"Product Documents": [  ""],"Certifications": [  "cULus;No;NOM;DLC Premium"],"Disinfection Product": [  "false"],"Effective Projected Area": ["abc"],"Product Shape": [  "4 & 8 ft for both Continuous or Independent runs"],"UL Type": ["A"],"Website Link": [  "https://products.gecurrent.com/indoor-lighting/suspended/lumination-lus-series-ultron-suspended"]  }]'; 
        
        attachment.Body = Blob.valueOf(ContentsString);
        attachment.Name = String.valueOf('SFCC_Output_Test.Json');
        attachment.ParentId = c1.Id;
        insert attachment;
        
      //Database.delete([Select id From ccrz__E_Product__c]);
      

       /* List<ccrz__E_Product__c> ProdList1= [select ccrz__SKU__c from ccrz__E_Product__c Where ccrz__SKU__c='17704'] ;
        if(ProdList1.Size() !=0){
          delete ProdList1;
          }*/
        
        
      
            ccrz__E_Product__c p1 = new ccrz__E_Product__c(ccrz__SKU__c= '17704', Name= 'ProdTest',GTM_Product_Family__c='ABC',ProductHierarchy__c='RLM5005026000001',ccrz__ProductStatus__c='Released');
            insert p1;
        
        ccrz__E_Spec__c a1 = new ccrz__E_Spec__c();
        a1.ccrz__DisplayName__c='Lumens';   
        a1.Name='Lumens';
        insert a1;
        
        ccrz__E_Spec__c az1 = new ccrz__E_Spec__c();
        az1.ccrz__DisplayName__c='QuickShip';   
        az1.Name='QuickShip';
        insert az1;
       
            ccrz__E_Spec__c az11 = new ccrz__E_Spec__c();
        az11.ccrz__DisplayName__c='ProLine';   
        az11.Name='ProLine';
        insert az11;
        
        ccrz__E_Spec__c az12 = new ccrz__E_Spec__c();
        az12.ccrz__DisplayName__c='Accessory SKU';   
        az12.Name='Accessory SKU';
        insert az12;
        
        ccrz__E_Spec__c c11 = new ccrz__E_Spec__c();
        c11.ccrz__DisplayName__c='Efficacy (μmol/J)';   
        c11.Name='Efficacy (μmol/J)';
        insert c11;
        
        ccrz__E_Spec__c c2 = new ccrz__E_Spec__c();
        c2.ccrz__DisplayName__c='Efficacy';   
        c2.Name='Efficacy';
        insert c2;
        
        ccrz__E_Spec__c c3 = new ccrz__E_Spec__c();
        c3.ccrz__DisplayName__c='UV Output';   
        c3.Name='UV Output';
        insert c3;
        
        ccrz__E_Spec__c c4 = new ccrz__E_Spec__c();
        c4.ccrz__DisplayName__c='UV Range';   
        c4.Name='UV Range';
        insert c4;
        
        ccrz__E_Spec__c c5 = new ccrz__E_Spec__c();
        c5.ccrz__DisplayName__c='Light Output PPF';   
        c5.Name='Light Output PPF';
        insert c5;
        
        ccrz__E_Spec__c c6 = new ccrz__E_Spec__c();
        c6.ccrz__DisplayName__c='Spectra';   
        c6.Name='Spectra';
        insert c6;
        
        ccrz__E_Spec__c c7 = new ccrz__E_Spec__c();
        c7.ccrz__DisplayName__c='Estimated Lead Time';   
        c7.Name='Estimated Lead Time';
        insert c7;
        
            /*ccrz__E_ProductSpec__c a2=new ccrz__E_ProductSpec__c();
        a2.ccrz__Product__c=p1.id;
        a2.ccrz__Spec__c=a1.id;
        a2.ccrz__SpecValue__c='123';
        insert a2;*/    
            
        ccrz__E_Category__c a3=new ccrz__E_Category__c();
        a3.ccrz__CategoryID__c='SUSPENDED*INDOOR';
        a3.Name='SUSPENDED';
        insert a3;
        
        ccrz__E_ProductCategory__c a4=new ccrz__E_ProductCategory__c();
        a4.ccrz__Product__c=p1.id;
        a4.ccrz__Category__c=a3.id;
        //a4.CategoryValue__c='Test';
        insert a4;
        
        ccrz__E_ProductMedia__c a5=new ccrz__E_ProductMedia__c();
        a5.ccrz__Product__c=p1.id;
        a5.ccrz__ProductDescription__c='test2';
        a5.ccrz__MediaType__c='Warranty';
        insert a5;
        
        ccrz__E_Spec__c a6 = new ccrz__E_Spec__c();
        a6.ccrz__DisplayName__c='UL Type';   
        a6.Name='UL Type';
        insert a6;
        
        ccrz__E_Spec__c a61 = new ccrz__E_Spec__c();
        a61.ccrz__DisplayName__c='Country of Origin';   
        a61.Name='Country of Origin';
        insert a61;
        /*
        ccrz__E_ProductSpec__c a611=new ccrz__E_ProductSpec__c();
        a611.ccrz__Product__c=p1.id;
        a611.ccrz__Spec__c=a61.id;
        a611.ccrz__SpecValue__c='123';
        insert a611;  
       */ 
        ccrz__E_Spec__c b1 = new ccrz__E_Spec__c();
        b1.ccrz__DisplayName__c='Product Subcategory';   
        b1.Name='Product Subcategory';
        insert b1;
        /*ccrz__E_ProductSpec__c b11=new ccrz__E_ProductSpec__c();
        b11.ccrz__Product__c=p1.id;
        b11.ccrz__Spec__c=b1.id;
        b11.ccrz__SpecValue__c='123';
        insert b11;*/
        
        ccrz__E_Spec__c b2 = new ccrz__E_Spec__c();
        b2.ccrz__DisplayName__c='Product Category';   
        b2.Name='Product Category';
        insert b2;
        /*ccrz__E_ProductSpec__c b21=new ccrz__E_ProductSpec__c();
        b21.ccrz__Product__c=p1.id;
        b21.ccrz__Spec__c=b2.id;
        b21.ccrz__SpecValue__c='123';
        insert b21;*/
        
        ccrz__E_Spec__c b3 = new ccrz__E_Spec__c();
        b3.ccrz__DisplayName__c='Family Applications';   
        b3.Name='Family Applications';
        insert b3;
        /*ccrz__E_ProductSpec__c b31=new ccrz__E_ProductSpec__c();
        b31.ccrz__Product__c=p1.id;
        b31.ccrz__Spec__c=b3.id;
        b31.ccrz__SpecValue__c='123';
        insert b31;*/
        
        
        ccrz__E_Spec__c b4 = new ccrz__E_Spec__c();
        b4.ccrz__DisplayName__c='Brand';   
        b4.Name='Brand';
        insert b4;
        /*ccrz__E_ProductSpec__c b41=new ccrz__E_ProductSpec__c();
        b41.ccrz__Product__c=p1.id;
        b41.ccrz__Spec__c=b4.id;
        b41.ccrz__SpecValue__c='123';
        insert b41;*/
        
        ccrz__E_Spec__c b5 = new ccrz__E_Spec__c();
        b5.ccrz__DisplayName__c='Warranty';   
        b5.Name='Warranty';
        insert b5;
        /*ccrz__E_ProductSpec__c b51=new ccrz__E_ProductSpec__c();
        b51.ccrz__Product__c=p1.id;
        b51.ccrz__Spec__c=b5.id;
        b51.ccrz__SpecValue__c='123';
        insert b51;*/
        
        
        ccrz__E_Spec__c b6 = new ccrz__E_Spec__c();
        b6.ccrz__DisplayName__c='Lensing Description';   
        b6.Name='Lensing Description';
        insert b6;
        /*ccrz__E_ProductSpec__c b61=new ccrz__E_ProductSpec__c();
        b61.ccrz__Product__c=p1.id;
        b61.ccrz__Spec__c=b6.id;
        b61.ccrz__SpecValue__c='123';
        insert b61;*/
        
        
        
        ccrz__E_Spec__c b7 = new ccrz__E_Spec__c();
        b7.ccrz__DisplayName__c='Housing Description';   
        b7.Name='Housing Description';
        insert b7;
        /*ccrz__E_ProductSpec__c b71=new ccrz__E_ProductSpec__c();
        b71.ccrz__Product__c=p1.id;
        b71.ccrz__Spec__c=b7.id;
        b71.ccrz__SpecValue__c='123';
        insert b71;*/
        
        
        ccrz__E_Spec__c b8 = new ccrz__E_Spec__c();
        b8.ccrz__DisplayName__c='PH3 Family';   
        b8.Name='PH3 Family';
        insert b8;
       /* ccrz__E_ProductSpec__c b81=new ccrz__E_ProductSpec__c();
        b81.ccrz__Product__c=p1.id;
        b81.ccrz__Spec__c=b8.id;
        b81.ccrz__SpecValue__c='123';
        insert b81;*/
        
        
        ccrz__E_Spec__c b9 = new ccrz__E_Spec__c();
        b9.ccrz__DisplayName__c='PH2 Application';   
        b9.Name='PH2 Application';
        insert b9;
        /*ccrz__E_ProductSpec__c b91=new ccrz__E_ProductSpec__c();
        b91.ccrz__Product__c=p1.id;
        b91.ccrz__Spec__c=b9.id;
        b91.ccrz__SpecValue__c='123';
        insert b91;*/
        ccrz__E_Spec__c b11 = new ccrz__E_Spec__c();
        b11.ccrz__DisplayName__c='Product Family';   
        b11.Name='Product Family';
        insert b11;
        
        
        
        ccrz__E_Spec__c b0 = new ccrz__E_Spec__c();
        b0.ccrz__DisplayName__c='PH1 Product Line';   
        b0.Name='PH1 Product Line';
        insert b0;
        
        /*ccrz__E_ProductSpec__c b01=new ccrz__E_ProductSpec__c();
        b01.ccrz__Product__c=p1.id;
        b01.ccrz__Spec__c=b0.id;
        b01.ccrz__SpecValue__c='123';
        insert b01;*/
        
        
        
        ccrz__E_Spec__c a7 = new ccrz__E_Spec__c();
        a7.ccrz__DisplayName__c='Bulb Base Type';   
        a7.Name='Bulb Base Type';
        insert a7;
        
        ccrz__E_Spec__c a8 = new ccrz__E_Spec__c();
        a8.ccrz__DisplayName__c='Bulb Shape';   
        a8.Name='Bulb Shape';
        insert a8;
        
        ccrz__E_Spec__c a9 = new ccrz__E_Spec__c();
        a9.ccrz__DisplayName__c='Operating Life (Hrs)';   
        a9.Name='Operating Life (Hrs)';
        insert a9;
        
        ccrz__E_Spec__c a10 = new ccrz__E_Spec__c();
        a10.ccrz__DisplayName__c='Effective Projected Area (EPA)';   
        a10.Name='Effective Projected Area (EPA)';
        insert a10;
        
        ccrz__E_Spec__c a11 = new ccrz__E_Spec__c();
        a11.ccrz__DisplayName__c='Paint/Finish Description';   
        a11.Name='Paint/Finish Description';
        insert a11;
        
        ccrz__E_Spec__c a12 = new ccrz__E_Spec__c();
        a12.ccrz__DisplayName__c='Operating Temp Range (°C)';   
        a12.Name='Operating Temp Range (°C)';
        insert a12;
        
        ccrz__E_Spec__c a13 = new ccrz__E_Spec__c();
        a13.ccrz__DisplayName__c='Associated Parts';   
        a13.Name='Associated Parts';
        insert a13;
        
        ccrz__E_Spec__c a14 = new ccrz__E_Spec__c();
        a14.ccrz__DisplayName__c='Technology Enabled';   
        a14.Name='Technology Enabled';
        insert a14;
        
        ccrz__E_Spec__c a15 = new ccrz__E_Spec__c();
        a15.ccrz__DisplayName__c='Programs';   
        a15.Name='Programs';
        insert a15;
        
        ccrz__E_Spec__c a16 = new ccrz__E_Spec__c();
        a16.ccrz__DisplayName__c='Material';   
        a16.Name='Material';
        insert a16;
        
        ccrz__E_Spec__c a17 = new ccrz__E_Spec__c();
        a17.ccrz__DisplayName__c='Environmental Conditions';   
        a17.Name='Environmental Conditions';
        insert a17;
        
        ccrz__E_Spec__c a18 = new ccrz__E_Spec__c();
        a18.ccrz__DisplayName__c='Regulatory';   
        a18.Name='Regulatory';
        insert a18;
        
        ccrz__E_Spec__c a19 = new ccrz__E_Spec__c();
        a19.ccrz__DisplayName__c='Certifications';   
        a19.Name='Certifications';
        insert a19;
        
        ccrz__E_Spec__c a20 = new ccrz__E_Spec__c();
        a20.ccrz__DisplayName__c='Product Shape';   
        a20.Name='Product Shape';
        insert a20;
        
        ccrz__E_Spec__c a20z = new ccrz__E_Spec__c();
        a20z.ccrz__DisplayName__c='Shape';   
        a20z.Name='Shape';
        insert a20z;
       /* 
        ccrz__E_Category__c a21=new ccrz__E_Category__c();
        a21.ccrz__CategoryID__c='MEXICO*COUNTRY-OF-ORIGIN';
        a21.Name='Mexico';
        insert a21;
        */
        ccrz__E_Category__c a22=new ccrz__E_Category__c();
        a22.ccrz__CategoryID__c='INDOOR FIXTURES - LED*PH1 PRODUCT LINE';
        a22.Name='INDOOR FIXTURES - LED';
        insert a22;
        
        ccrz__E_Category__c a23=new ccrz__E_Category__c();
        a23.ccrz__CategoryID__c='LUS ULTRON SUSPENDED*PH3 FAMILY';
        a23.Name='LUS ULTRON SUSPENDED';
        insert a23;
        
        ccrz__E_Category__c a25=new ccrz__E_Category__c();
        a25.ccrz__CategoryID__c='LUMINATION®*BRAND';
        a25.Name='Lumination®';
        insert a25;
        
        ccrz__E_Category__c a26=new ccrz__E_Category__c();
        a26.ccrz__CategoryID__c='RETAIL*FAMILY APPLICATIONS';
        a26.Name='Retail';
        insert a26;
        
      	ccrz__E_Category__c a27=new ccrz__E_Category__c();
        a27.ccrz__CategoryID__c='INDOOR SUSPENDED*PH2 APPLICATION';
        a27.Name='INDOOR SUSPENDED';
        insert a27;
        
        
        ccrz__E_Category__c a28=new ccrz__E_Category__c();
        a28.ccrz__CategoryID__c='PRODUCT SUBCATEGORY';
        a28.Name='PRODUCT SUBCATEGORY';
        insert a28;
        
		ccrz__E_Spec__c a29 = new ccrz__E_Spec__c();
        a29.ccrz__DisplayName__c='Wattage (W)';   
        a29.Name='Wattage (W)';
        insert a29;
        
        ccrz__E_Spec__c a31 = new ccrz__E_Spec__c();
        a31.ccrz__DisplayName__c='Voltage (V)';   
        a31.Name='Voltage (V)';
        insert a31;
        
        ccrz__E_Spec__c a30 = new ccrz__E_Spec__c();
        a30.ccrz__DisplayName__c='Color Temperature';   
        a30.Name='Color Temperature';
        insert a30;
        
        ccrz__E_Spec__c a32 = new ccrz__E_Spec__c();
        a32.ccrz__DisplayName__c='CRI';   
        a32.Name='CRI';
        insert a32;
        
        ccrz__E_Spec__c a33 = new ccrz__E_Spec__c();
        a33.ccrz__DisplayName__c='Optical Distribution';   
        a33.Name='Optical Distribution';
        insert a33;
        
        ccrz__E_Spec__c a34 = new ccrz__E_Spec__c();
        a34.ccrz__DisplayName__c='BUG Rating';   
        a34.Name='BUG Rating';
        insert a34;
        
        ccrz__E_Spec__c a35 = new ccrz__E_Spec__c();
        a35.ccrz__DisplayName__c='Item Color';   
        a35.Name='Item Color';
        insert a35;
        
        ccrz__E_Spec__c a36 = new ccrz__E_Spec__c();
        a36.ccrz__DisplayName__c='Accessories & Options';   
        a36.Name='Accessories & Options';
        insert a36;
        
		ccrz__E_Category__c a37=new ccrz__E_Category__c();
        a37.ccrz__CategoryID__c='LFL LEVEL 4 DEFAULT*CONFIGURATION';
        a37.Name='LFL LEVEL 4 DEFAULT';
        insert a37;

        ccrz__E_Category__c a38=new ccrz__E_Category__c();
        a38.ccrz__CategoryID__c='LFL T8 APPLIANCE*INTELLIGENCE';
        a38.Name='LFL T8 APPLIANCE';
        insert a38;        
        /*
        ccrz__E_Category__c a39=new ccrz__E_Category__c();
        a39.ccrz__CategoryID__c='COUNTRY-OF-ORIGIN';
        a39.Name='COUNTRY-OF-ORIGIN';
        insert a39;
        */
        ccrz__E_Category__c a40=new ccrz__E_Category__c();
        a40.ccrz__CategoryID__c='PH1 PRODUCT LINE';
        a40.Name='PH1 PRODUCT LINE';
        insert a40;
        
        ccrz__E_Category__c a41=new ccrz__E_Category__c();
        a41.ccrz__CategoryID__c='PH3 FAMILY';
        a41.Name='PH3 FAMILY';
        insert a41;
        
        ccrz__E_Category__c a42=new ccrz__E_Category__c();
        a42.ccrz__CategoryID__c='BRAND';
        a42.Name='BRAND';
        insert a42;
        
        ccrz__E_Category__c a43=new ccrz__E_Category__c();
        a43.ccrz__CategoryID__c='FAMILY Applications';
        a43.Name='FAMILY APPLICATIONS';
        insert a43;
        
      	ccrz__E_Category__c a44=new ccrz__E_Category__c();
        a44.ccrz__CategoryID__c='PH2 APPLICATION';
        a44.Name='PH2 APPLICATION';
        insert a44;
        
        ccrz__E_Category__c a45=new ccrz__E_Category__c();
        a45.ccrz__CategoryID__c='PH4 CONFIGURATION';
        a45.Name='PH4 CONFIGURATION';
        insert a45;

        ccrz__E_Category__c a46=new ccrz__E_Category__c();
        a46.ccrz__CategoryID__c='PH5 INTELLIGENCE';
        a46.Name='PH5 INTELLIGENCE';
        insert a46;        
        
        ccrz__E_Category__c a47=new ccrz__E_Category__c();
        a47.ccrz__CategoryID__c='INDOOR';
        a47.Name='INDOOR';
        insert a47;
        
            
        ccrz__E_Category__c a48=new ccrz__E_Category__c();
        a48.ccrz__CategoryID__c='PRODUCTS';
        a48.Name='PRODUCTS';
        insert a48;

        ccrz__E_Category__c a49=new ccrz__E_Category__c();
        a49.ccrz__CategoryID__c='LUMINATION® LUS SERIES*FAMILY';
        a49.Name='LUMINATION® LUS SERIES';
        insert a49;
        
        ccrz__E_Category__c a50=new ccrz__E_Category__c();
        a50.ccrz__CategoryID__c='FAMILY';
        a50.Name='FAMILY';
        insert a50;
        
        String prodJSON='{"ccrz__SKU__c":"17705","Name":"ProdTest2","GTM_Product_Family__c":"ABC","ProductHierarchy__c":"RLM5005026000001","CreatedDate":"2012-10-04T17:54:26.000+0000","LastModifiedDate":"2012-10-04T17:54:26.000+0000"}';
        ccrz__E_Product__c c = (ccrz__E_Product__c) JSON.deserialize(prodJSON, ccrz__E_Product__c.class); 
        ccrz__E_Product__c p2 = new ccrz__E_Product__c();
        p2.ccrz__SKU__c=c.ccrz__SKU__c;
        p2.ProductHierarchy__c=c.ProductHierarchy__c;
        p2.GTM_Product_Family__c=c.GTM_Product_Family__c;
        p2.CreatedDate=c.CreatedDate;
        p2.LastModifiedDate=c.LastModifiedDate;
		p2.Name=c.Name;
        p2.ccrz__ProductStatus__c='Released';
        insert p2;
        Date myDate = Date.today();
     Time myTime = Time.newInstance(8, 0, 0, 0);
    DateTime dt1 = DateTime.newInstanceGMT(myDate, myTime);
        ccrz__E_Product__c p3 = new ccrz__E_Product__c(Id=p2.id);
         System.debug(p3.ccrz__SKU__c);
        System.debug(p3.CreatedDate); 
        ccrz__E_Product__c p4 = new ccrz__E_Product__c();
        p4.ccrz__SKU__c='123456';
        p4.ProductHierarchy__c=c.ProductHierarchy__c;
        p4.GTM_Product_Family__c=c.GTM_Product_Family__c;
        p4.CreatedDate=dt1;
        p4.LastModifiedDate=dt1;
        p4.ccrz__ProductStatus__c='Released';
		p4.Name='Test';
        insert p4;
         /*Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
          Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
                
                customMetadata.fullName = 'Family_Record__mdt.ABC';
                customMetadata.label = 'ABC';
                
                
                Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                customField.field = 'Record__c';
                // customField.value = string.valueOf(family1);
                customField.value = '{"SKU or Family": [  {"id": 147385257,"external_id": "Family","name": "Family","parent_id": null,"target_field_id": 5390805,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-bb439dc4-0b65-463f-9a8d-14a9ab10a475","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Family": [  "ABC"],"Catalog Logic": [  "Lumination® LUS series"],"Commercial Launch Date": [  "2017-01-01"],"Country of Origin": [  "Mexico"],"Manufacturer": [  "GE Current, a Daintree company"],"PH1 Product Line": [  "INDOOR FIXTURES - LED"],"PH2 Application": [  "INDOOR SUSPENDED"],"PH3 Family": [  "LUS ULTRON SUSPENDED"],"Technology Enabled": [  "TriGain®;Daintree"],"Taxonomy": [  {"id": 147385261,"external_id": "Fixtures","name": "Fixtures","parent_id": null,"target_field_id": 5391037,"created_at": "2020-12-22T20:05:42.414Z","updated_at": "2020-12-22T20:05:42.762Z","classifier_ids_cache": [],"applicable_scopes": [],"selectable": true,"system_id": "s-82ac6d67-1ede-40e7-8468-769f453c736d","destroyed_at": null,"classifier_exclusion_value_ids": []  }],"Brand": [  "Lumination®"],"Family Features & Benefits Bullets": [  "Toolless replaceable light enginenMultiple distributions – Aisle, Wide, Very Wide, Wall WashnExclusive reveal® TriGain®  technology – standardnFast toolless quick connect for easy installs, plus anti-snaking lever to adjust for STRAIGHT continuous runsnUp to 400ft run length with one power drop!n3500K, 4000K and 5000K color temperaturenLumen output: 4,200-24,000nAvailable in 4 and 8 lengthsnUp to 165 LPW efficacynIntegrated occupancy and daylight harvesting sensors avaialblen0-10V dimming standardn5-year limited system warranty standard"],"Family Applications": [  "Retail;Factory / Industrial;Commercial Offices"],"Product Description Short": [  "Lumination® LUS Series LED luminaire is an energy-efficient, low maintenance alternative to traditional fluorescent lighting in a variety of commercial and low bay lighting applications. The LUS series offers customers a superior mix of value and performance."],"Product Description Long": [  "Currents Lumination® LUS series comes standard with Trigain®  to bring out the best colors. It is uniquely positioned to provide a performance of 165 LPW while delivering an astonishing 90CRI and an R9 value of 90. The fixture comes in a minimalistic form factor, making it ideal for installation in several settings and scenarios. Moreover, the LUS offers customization of color finish as well as a range of beam distributions specific to your needs. This is achieved through a sophisticated diffusers."],"Warranty": [  "5 year limited warranty"],"Programs": [  ""],"Family Icons": [  ""],"Product Category": [  "Indoor"],"Product Subcategory": [  "Suspended"],"Bulb Base Type": [  "N/A"],"Bulb Shape": [  "N/A"],"Operating Life (Hrs)": [  "N/A"],"Operating Life UOM": [  "hours"],"Lumen Maintenance Rating": [  "L70 @ 100,000 hours"],"Lensing Description": [  "Polycarbonate"],"Housing Description": [  "Extruded aluminum body"],"Paint/Finish Description": [  "Powder coat Painted Housing"],"Material": [  ""],"Vibration Rating UOM": [  "G"],"Input Frequency": [  "50/60"],"Input Frequency UOM": [  "Hz"],"Driver / Ballast Type": [  "Class 2 and Class 1(for high lumen skus) LED driver rated for 50,000 hours"],"System Power Factor": [  ">0.9"],"THD": [  "<20%"],"Surge protection": [  "100 kHz ring wave, 2.5 kV level"],"Environmental Conditions": [  "Damp "],"Operating Temp range": [  "-10 to 35"],"Operating Temp UOM": [  "°C"],"Storage Temp": [  "-40 to 70"],"Storage Temp UOM": [  "°C"],"Family Modules/Configurations": [  "4 & 8 ft for both Continuous or Independent runs"],"Lumen Range": [  "4,200 - 24,000"],"Lumen Range UOM": [  "lm"],"Voltage Offering": [  "120-277;347"],"Voltage Offering UOM": [  "V"],"Wattage Range": [  "0-100"],"Wattage Range UOM": [  "W"],"Efficacy Range": [  "Up to 165"],"Efficacy Range UOM": [  "LPW"],"CCT Offering": [  "3000;3500;4000;5000"],"CCT Offering UOM": [  "K"],"CRI Offering": [  "83;90 TriGain®"],"Optics & Distributions": [  "Aisle;Wide;Very Wide;Wall Wash;Uplight"],"Daintree Offering": [  "Daintree Networked;Daintree EZ Connect;Daintree One"],"Controls & Sensors": [  "Daintree Control Options;Daintree Integrated Sensor Options;Other Integrated Sensor/Controls Available;0-10V Standard Dimming"],"Color Offering": [  "White;Black;Silver;Red"],"Mounting Options": [  "Suspension or Direct Mount"],"Family Accessories & Options": [  "Emergency Light;Power cord kit;Suspended kits;Starter kits;Reflector Wings"],"Associated Parts": [  ""],"Related Products": [  ""],"Suggested Traditional Replacement": [  "LFL"],"Suggested Replacement SKU/Family": [  ""],"Instabase Directory Link": [  "https://instabase.lightinganalysts.com/IITC/?uid=902-PF5BFFYPSR7BDEHGXV26PTEG&selectedIDBs=1663,1665,1667,1669&textSrch=LUS%20LUMINATION&expand=1&setView=0&sam=1#tabs-Search"],"Energy Certifications": [  "DLC Premium;DLC Standard"],"Safety Certifications": [  "cULus"],"Region Certifications": [  "NOM"],"Misc Certifications": [  ""],"Regulatory": [  "DLC qualified models available Please refer to http://www.designlights.org/QPL for complete information"],"BAA or TAA Compliant": [  ""],"IP Rating": [  "IP20"],"NSF Rated": [  "false"],"RoHS": [  "true"],"Length UOM": [  "In"],"Width UOM": [  "In"],"Height UOM": [  "In"],"Diameter UOM": [  "In"],"Weight UOM": [  "Lb"],"UOS Package Length UOM In": [  "In"],"UOS Package Width UOM In": [  "In"],"UOS Package Height UOM In": [  "In"],"UOS Package Weight UOM Lb": [  "Lb"],"Case Package Length UOM In": [  "In"],"Case Package Width UOM In": [  "In"],"Case Package Height UOM In": [  "In"],"Case Package Weight UOM Lb": [  "Lb"],"Standard Pack Quantity UOM": [  "Lamps"],"AC Input Voltage UOM": [  "V"],"Light Output Range UOM": [  "(μmol/s)"],"Family Spectra": [  ""],"Operating Voltage Range UOM": [  "V"],"Minimum Light Intensity UOM": [  "cd"],"Maximum Light Intensity UOM": [  "cd"],"Nominal Power UOM": [  "W"],"Performance Levels Distribution": [  ""],"Lamp Appearance ": [  ""],"Lumens per Module UOM": [  "lm"],"Lumens per Foot UOM": [  "lm/ft"],"Watts per Module UOM": [  "W"],"Item Length UOM": [  "mm"],"Item Width UOM": [  "mm"],"Item Height UOM": [  "mm"],"Item Diameter UOM": [  "mm"],"Item Weight UOM": [  "kg"],"UOS Package Length UOM mm": [  "mm"],"UOS Package Width UOM mm": [  "mm"],"UOS Package Height UOM mm": [  "mm"],"UOS Package Weight UOM mm": [  "kg"],"Case Package Length UOM mm": [  "mm"],"Case Package Width UOM mm": [  "mm"],"Case Package Height UOM mm": [  "mm"],"Case Package Weight UOM kg": [  "kg"],"Technology Type": [  "Traditional"],"Product Images": [  ""],"Product Documents": [  ""],"Certifications": [  "cULus;No;NOM;DLC Premium"],"Disinfection Product": [  "false"],"Product Shape": [  "4 & 8 ft for both Continuous or Independent runs"],"Website Link": [  "https://products.gecurrent.com/indoor-lighting/suspended/lumination-lus-series-ultron-suspended"]  }';
                customMetadata.values.add(customField);
                mdContainer.addMetadata(customMetadata);
                CustomMetadataCallback callback = new CustomMetadataCallback();
           	 Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);*/
        
        SalsifyProductCalloutBatch myBatchObject = new SalsifyProductCalloutBatch();
        Database.executeBatch(myBatchObject,199);
        

        Test.stopTest();
        
        
    }
    @isTest static void test2(){
        
        Test.startTest();
        SalsifyProductCalloutBatch myBatchObject2 = new SalsifyProductCalloutBatch();
        Database.executeBatch(myBatchObject2,199);
        Test.stopTest();
    }
}