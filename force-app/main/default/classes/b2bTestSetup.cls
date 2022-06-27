@IsTest
public class b2bTestSetup {
	public static final String CATEGORY = 'Test Category';
	public static final String SUBCATEGORY = 'Test Subcategory';
	public static final String PRODUCT_NAME = 'test prod name';
	public static final String PRODUCT_SKU = 'sku';
	public static final Decimal PRODUCT_PRICE = 10;

	public static final String B2C_ACCOUNTGROUPNAME = 'PortalAccount';
	public static final String B2C_PRICELIST = 'B2BPricelist';
	public static final String B2C_CONTACTFIRSTNAME = 'B2B';
	public static final String B2C_CONTACTLASTNAME = 'Contact';
	public static final String B2C_EMAIL = 'b2b.contact@gecurrent.com.acumen';
	public static final String B2C_STOREFRONT = 'DefaultStore';
	public static final String B2C_PORTAL_TYPE = 'Agent';

	public static final String WFH_ACCOUNTGROUPNAME = 'TestCompany';
	public static final String WFH_PRICELIST = 'TestCompanyPricelist';
	public static final String WFH_CONTACTFIRSTNAME = 'WFH';
	public static final String WFH_CONTACTLASTNAME = 'Contact';
	public static final String WFH_EMAIL = 'wfh.contact@gecurrent.com.acumen';

	public static String cartEncId = '000000';
	public static String cartAdjustmentReason;

	public static final Profile B2C_PROFILE = [SELECT Id FROM Profile WHERE Name = 'B2B Storefront Registered Users'];
	//public static RecordTypeInfo B2C_ACCOUNT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2C_Customer');

	public static Map<String,Object> setupPortalUsers() {
		Map<String,Map<String,Object>> testData = new Map<String,Map<String,Object>>{
			ccrz.ccApiTestData.LOGIC_SETTINGS => new Map<String,Object>{
				'DefaultStore' => new Map<String,Object>{
					'ccLogicCartAddTo' => 'c.ccLogicCartAddToExtension',
					'ccLogicProductPricing' => 'c.ccLogicProductPricingExtension',
					'ccLogicCartPlace' => 'c.ccLogicCartPlaceExtension'
				}
			},
			ccrz.ccApiTestData.ACCOUNTGROUP_DATA => new Map<String,Object>{
				ccrz.ccApiTestData.ACCOUNTGROUP_LIST => new List<Map<String,Object>>{
					new Map<String,Object>{
						'name' => B2C_ACCOUNTGROUPNAME,
						'ccrz__dataId__c' => B2C_ACCOUNTGROUPNAME
					},
					new Map<String,Object>{
						'name' => WFH_ACCOUNTGROUPNAME,
						'ccrz__dataId__c' => WFH_ACCOUNTGROUPNAME
					}
				}
			},
			ccrz.ccApiTestData.PRICELIST_DATA => new Map<String,Object>{
				ccrz.ccApiTestData.PRICELIST_LIST => new List<Map<String,Object>>{
					new Map<String,Object>{
						'name' => B2C_PRICELIST,
						'ccrz__dataId__c' => B2C_PRICELIST,
						'ccrz__desc__c' => B2C_ACCOUNTGROUPNAME + ' Pricelist',
						'ccrz__Enabled__c' => true,
						'ccrz__StartDate__c' => Date.today().addDays(-10),
						'ccrz__EndDate__c' => Date.today().addDays(10),
						'ccrz__Storefront__c' => 'Store',
						'ccrz__CurrencyISOCode__c' => 'USD',
						'ccrz__PricelistId__c' => B2C_PRICELIST
					},
					new Map<String,Object>{
						'name' => WFH_PRICELIST,
						'ccrz__dataId__c' => WFH_PRICELIST,
						'ccrz__desc__c' => WFH_ACCOUNTGROUPNAME + ' Pricelist',
						'ccrz__Enabled__c' => true,
						'ccrz__StartDate__c' => Date.today().addDays(-10),
						'ccrz__EndDate__c' => Date.today().addDays(10),
						'ccrz__Storefront__c' => 'Store',
						'ccrz__CurrencyISOCode__c' => 'USD',
						'ccrz__PricelistId__c' => WFH_PRICELIST
					}
				}
			},
			ccrz.ccApiTestData.AGPL_DATA => new Map<String,Object>{
				ccrz.ccApiTestData.AGPL_LIST => new List<Map<String,Object>>{
					new Map<String,Object>{
						'ccrz__dataId__c' => B2C_ACCOUNTGROUPNAME + B2C_PRICELIST,
						'ccrz__Enable__c' => true,
						'ccrz__StartDate__c' => Date.today().addDays(-10),
						'ccrz__EndDate__c' => Date.today().addDays(10),
						'ccrz__Sequence__c' => 100,
						'ccrz__Pricelist__r' => new ccrz__E_Pricelist__c(ccrz__dataId__c = B2C_PRICELIST),
						'ccrz__AccountGroup__r' => new ccrz__E_Pricelist__c(ccrz__dataId__c = B2C_ACCOUNTGROUPNAME)
					},
					new Map<String,Object>{
						'ccrz__dataId__c' => WFH_ACCOUNTGROUPNAME + WFH_PRICELIST,
						'ccrz__Enable__c' => true,
						'ccrz__StartDate__c' => Date.today().addDays(-10),
						'ccrz__EndDate__c' => Date.today().addDays(10),
						'ccrz__Sequence__c' => 100,
						'ccrz__Pricelist__r' => new ccrz__E_Pricelist__c(ccrz__dataId__c = WFH_PRICELIST),
						'ccrz__AccountGroup__r' => new ccrz__E_Pricelist__c(ccrz__dataId__c = WFH_ACCOUNTGROUPNAME)
					}
				}
			},
			ccrz.ccApiTestData.CATEGORY_DATA => new Map<String,Object>{
				ccrz.ccApiTestData.CATEGORY_LIST => new List<Map<String,Object>>{
					new Map<String,Object>{
						'ccrz__dataId__c' => CATEGORY,
						'ccrz__CategoryID__c' => '0',
						'ccrz__EndDate__c' => Date.today().addDays(10),
						'ccrz__LongDescRT__c' => CATEGORY,
						'ccrz__SEOId__c' => CATEGORY,
						'ccrz__Sequence__c' => 0,
						'ccrz__ShortDescRT__c' => CATEGORY,
						'ccrz__StartDate__c' => Date.today().addDays(-10)
					},
					new Map<String,Object>{
						'ccrz__dataId__c' => SUBCATEGORY,
						'ccrz__CategoryID__c' => '1',
						'ccrz__EndDate__c' => Date.today().addDays(10),
						'ccrz__LongDescRT__c' => SUBCATEGORY,
						'ccrz__SEOId__c' => SUBCATEGORY,
						'ccrz__Sequence__c' => 0,
						'ccrz__ShortDescRT__c' => SUBCATEGORY,
						'ccrz__StartDate__c' => Date.today().addDays(-10)
					}
				},
				ccrz.ccApiTestData.CATEGORYUPD_LIST => new List<Map<String,Object>>{
					new Map<String,Object>{
						'ccrz__dataId__c' => SUBCATEGORY,
						'ccrz__ParentCategory__r' => new ccrz__E_Category__c(ccrz__dataId__c = CATEGORY)
					}
				}
			},
			ccrz.ccApiTestData.ACCOUNT_DATA => new Map<String,Object>{
				ccrz.ccApiTestData.ACCOUNT_LIST => new List<Map<String,Object>>{
					new Map<String,Object>{
						'name' => B2C_CONTACTFIRSTNAME + B2C_CONTACTLASTNAME,
						'ccrz__dataId__c' => B2C_CONTACTFIRSTNAME + B2C_CONTACTLASTNAME,
						'ccrz__E_AccountGroup__r' => new ccrz__E_AccountGroup__c(ccrz__dataId__c = B2C_ACCOUNTGROUPNAME),
						'Site_ID__c' => '11235349'
						//'RecordTypeId' => B2C_ACCOUNT.getRecordTypeId()
					},
					new Map<String,Object>{
						'name' => WFH_CONTACTFIRSTNAME + WFH_CONTACTLASTNAME,
						'ccrz__dataId__c' => WFH_CONTACTFIRSTNAME + WFH_CONTACTLASTNAME,
						'ccrz__E_AccountGroup__r' => new ccrz__E_AccountGroup__c(ccrz__dataId__c = WFH_ACCOUNTGROUPNAME),
						'Site_ID__c' => '11235348',
						'CDA_Number__c' => 11111
						//'RecordTypeId' => B2C_ACCOUNT.getRecordTypeId()
					}
				}
			},
			ccrz.ccApiTestData.CONTACT_DATA => new Map<String,Object>{
				ccrz.ccApiTestData.CONTACT_LIST => new List<Map<String,Object>>{
					new Map<String,Object>{
						'ccrz__dataId__c' => B2C_CONTACTFIRSTNAME + ' ' + B2C_CONTACTLASTNAME,
						'account' => new Account(ccrz__dataId__c = B2C_CONTACTFIRSTNAME + B2C_CONTACTLASTNAME),
						'email' => B2C_EMAIL,
						'lastName' => B2C_CONTACTLASTNAME,
						'firstName' => B2C_CONTACTFIRSTNAME,
						'Portal_User_Type__c' => B2C_PORTAL_TYPE
					},
					new Map<String,Object>{
						'ccrz__dataId__c' => WFH_CONTACTFIRSTNAME + ' ' + WFH_CONTACTLASTNAME,
						'account' => new Account(ccrz__dataId__c = WFH_CONTACTFIRSTNAME + WFH_CONTACTLASTNAME),
						'email' => WFH_EMAIL,
						'lastName' => WFH_CONTACTLASTNAME,
						'firstName' => WFH_CONTACTFIRSTNAME,
						'Portal_User_Type__c' => B2C_PORTAL_TYPE
					}
				}
			},
			ccrz.ccApiTestData.USER_DATA => new Map<String,Object>{
				ccrz.ccApiTestData.USER_LIST => new List<Map<String,Object>>{
					new Map<String,Object>{
						'email' => B2C_EMAIL,
						'lastName' => B2C_CONTACTFIRSTNAME,
						'firstName' => B2C_CONTACTLASTNAME,
						'alias' => B2C_CONTACTFIRSTNAME.left(1) + B2C_CONTACTLASTNAME.left(3),
						'languageLocaleKey' => 'en_US',
						'localeSIDKey' => 'en_US',
						'emailEncodingKey' => 'UTF-8',
						'profileId' => B2C_PROFILE.Id,
						'username' => System.currentTimeMillis() + B2C_EMAIL,
						'ccrz__CC_CurrencyCode__c' => 'USD',
						'contact' => new Contact(ccrz__dataId__c = B2C_CONTACTFIRSTNAME + ' ' + B2C_CONTACTLASTNAME),
						'timezoneSIDKey' => 'GMT',
						'ccrz__DataId__c' => B2C_CONTACTFIRSTNAME + B2C_CONTACTLASTNAME

					},
					new Map<String,Object>{
						'email' => WFH_EMAIL,
						'lastName' => WFH_CONTACTFIRSTNAME,
						'firstName' => WFH_CONTACTLASTNAME,
						'alias' => WFH_CONTACTFIRSTNAME.left(1) + WFH_CONTACTLASTNAME.left(3),
						'languageLocaleKey' => 'en_US',
						'localeSIDKey' => 'en_US',
						'emailEncodingKey' => 'UTF-8',
						'profileId' => B2C_PROFILE.Id,
						'username' => System.currentTimeMillis() + WFH_EMAIL,
						'ccrz__CC_CurrencyCode__c' => 'USD',
						'contact' => new Contact(ccrz__dataId__c = WFH_CONTACTFIRSTNAME + ' ' + WFH_CONTACTLASTNAME),
						'timezoneSIDKey' => 'GMT',
						'ccrz__DataId__c' => WFH_CONTACTFIRSTNAME + WFH_CONTACTLASTNAME
					}
				}
			},
			ccrz.ccApiTestData.DATAOPTIONS => new Map<String,Object>{
				ccrz.ccApiTestData.INSERTDATA => true,
				ccrz.ccApiTestData.LOADDEFAULTS => false
			}
		};
		
		UserRole userRole = [Select Id From UserRole WHERE PortalType='None' Limit 1];
		User admin = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE AND UserRoleId != NULL LIMIT 1];
		admin.UserRoleId = userRole.Id;
		update admin;

		Map<String, Object> res;
		System.runAs(admin) {
			res = ccrz.ccApiTestData.setupData(testData);
		}
		return res;

		// clients can access inserted data with using below examples vs querying records
		//The list of sObjects inserted as part of setup.
		//List<sObject> listOfSObjectsInserted = (List<sObject>)retData.get(ccrz.ccApiTestData.SOBJECTLIST);

		//The list of ccrz__E_AccountGroup__c objects inserted
		//Map<String,Object> agData = (Map<String,Object>)retData.get(ccrz.ccApiTestData.ACCOUNTGROUP_DATA);
		//List<sObject> agList = (List<sObject>)agData.get(ccrz.ccApiTestData.ACCOUNTGROUP_LIST);
	}

	public static Map<SObjectType, List<Id>> setupPricelist() {
		List<SObject> objectsToInsert = new List<SObject>{
				new ccrz__E_Product__c(
						Name = 'test1',
						ccrz__SKU__c = 'test1',
						ccrz__Quantityperunit__c = 1,
						ccrz__ProductType__c = 'Product',
						ccrz__ProductId__c = 'test1',
						ccrz__Storefront__c = 'Store',
						ccrz__StartDate__c = System.today().addDays(-1),
						ccrz__EndDate__c = System.today().addDays(1),
						ccrz__ProductStatus__c = 'Released'
				),
				new ccrz__E_Product__c(
						Name = 'test2',
						ccrz__SKU__c = 'test2',
						ccrz__Quantityperunit__c = 1,
						ccrz__ProductType__c = 'Product',
						ccrz__ProductId__c = 'test2',
						ccrz__Storefront__c = 'Store',
						ccrz__StartDate__c = System.today().addDays(-1),
						ccrz__EndDate__c = System.today().addDays(1),
						ccrz__ProductStatus__c = 'Released'
				),
				new ccrz__E_Product__c(
					Name = 'requested sku',
					ccrz__SKU__c = 'requestedSku',
					ccrz__Quantityperunit__c = 1,
					ccrz__ProductType__c = PRODUCT_NAME,
					ccrz__ProductId__c = 'requestedSku',
					ccrz__Storefront__c = B2C_STOREFRONT,
					ccrz__StartDate__c = System.today().addDays(-1),
					ccrz__EndDate__c = System.today().addDays(1),
					ccrz__ProductStatus__c = 'Released'
				),
				new ccrz__E_PriceListItem__c(
						ccrz__Pricelist__r = new ccrz__E_PriceList__c(ccrz__DataId__c = b2bTestSetup.B2C_PRICELIST),
						ccrz__RecurringPrice__c = false,
						ccrz__Price__c = b2bTestSetup.PRODUCT_PRICE,
						CurrencyIsoCode = 'USD',
						ccrz__Product__r = new ccrz__E_Product__c(ccrz__ProductId__c = 'test1')
				),
				new ccrz__E_PriceListItem__c(
						ccrz__Pricelist__r = new ccrz__E_PriceList__c(ccrz__DataId__c = b2bTestSetup.B2C_PRICELIST),
						ccrz__RecurringPrice__c = false,
						ccrz__Price__c = b2bTestSetup.PRODUCT_PRICE + 10,
						CurrencyIsoCode = 'USD',
						ccrz__Product__r = new ccrz__E_Product__c(ccrz__ProductId__c = 'test2')
				),
				new ccrz__E_PriceListItem__c(
						ccrz__Pricelist__r = new ccrz__E_PriceList__c(ccrz__DataId__c = b2bTestSetup.B2C_PRICELIST),
						ccrz__RecurringPrice__c = false,
						ccrz__Price__c = b2bTestSetup.PRODUCT_PRICE + 10,
						CurrencyIsoCode = 'USD',
						ccrz__Product__r = new ccrz__E_Product__c(ccrz__ProductId__c = 'requestedSku')
				),
				new ccrz__E_Spec__c(
						Name = 'Sell Price',
						ccrz__DisplayName__c = 'Sell Price',
						ccrz__FilterDisplayName__c = 'Price',
						ccrz__IsComparable__c = true,
						ccrz__FilterType__c = 'Slider',
						ccrz__UseForFilter__c = true
				)
		};
		List<Database.SaveResult> results = Database.insert(objectsToInsert);
		return mapInsertedData(results);
	}

	public static Map<SObjectType, List<Id>> setupCart() {
		List<SObject> objectsToInsert = new List<SObject>{
			new ccrz__E_Product__c(
				Name = PRODUCT_NAME,
				ccrz__SKU__c = PRODUCT_SKU,
				ccrz__Quantityperunit__c = 1,
				ccrz__ProductType__c = PRODUCT_NAME,
				ccrz__ProductId__c = PRODUCT_NAME,
				ccrz__Storefront__c = B2C_STOREFRONT,
				ccrz__StartDate__c = System.today().addDays(-1),
				ccrz__EndDate__c = System.today().addDays(1),
				ccrz__ProductStatus__c = 'Released'
			),
			new ccrz__E_Cart__c(
				ccrz__AdjustmentReason__c = cartAdjustmentReason,
				ccrz__CartId__c = cartEncId,
				ccrz__ActiveCart__c = true,
				ccrz__CartStatus__c = 'Open',
				ccrz__EncryptedId__c = cartEncId,
				ccrz__Account__r = new Account(ccrz__dataId__c = B2C_CONTACTFIRSTNAME + B2C_CONTACTLASTNAME),
				ccrz__User__r = new User(ccrz__DataId__c = B2C_CONTACTFIRSTNAME + B2C_CONTACTLASTNAME),
				ccrz__Name__c='testCart'
			),
			new ccrz__E_CartItem__c(
				ccrz__Cart__r = new ccrz__E_Cart__c(ccrz__CartId__c = cartEncId),
				ccrz__Quantity__c = 1,
				ccrz__OriginalQuantity__c = 1,
				ccrz__Price__c = PRODUCT_PRICE,
				ccrz__SubAmount__c = PRODUCT_PRICE,
				ccrz__Product__r = new ccrz__E_Product__c(ccrz__ProductId__c = PRODUCT_NAME)
			),
			new ccrz__E_ProductCategory__c(
				ccrz__Category__r = new ccrz__E_Category__c(ccrz__DataId__c = SUBCATEGORY),
				ccrz__Product__r = new ccrz__E_Product__c(ccrz__ProductId__c = PRODUCT_NAME),
				ccrz__EndDate__c = Date.today().addDays(10),
				ccrz__StartDate__c = Date.today().addDays(-10)
			),
			new ccrz__E_PriceListItem__c(
				ccrz__Pricelist__r = new ccrz__E_PriceList__c(ccrz__DataId__c = B2C_PRICELIST),
				ccrz__RecurringPrice__c = false,
				ccrz__Price__c = PRODUCT_PRICE,
				CurrencyIsoCode = 'USD',
				ccrz__Product__r = new ccrz__E_Product__c(ccrz__ProductId__c = PRODUCT_NAME)
			)
		};
		List<Database.SaveResult> results = Database.insert(objectsToInsert);
		return mapInsertedData(results);
	}

	private static Map<SObjectType, List<Id>> mapInsertedData(List<Database.SaveResult> results) {
		Map<SObjectType, List<Id>> insertedData = new Map<SObjectType, List<Id>>();
		for(Database.SaveResult sr : results) {
			SObjectType sobjectType = sr.getId().getSobjectType();
			if(!insertedData.containsKey(sobjectType)){
				insertedData.put(sobjectType, new List<Id>());
			}
			insertedData.get(sobjectType).add(sr.getId());
		}
		return insertedData;
	}
}