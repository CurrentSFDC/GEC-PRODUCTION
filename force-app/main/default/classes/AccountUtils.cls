public without sharing class AccountUtils {
	
	public static string normalizeSso ( string origsso ){
		//As the SSO is Alphanumeric we are chaging the code.
		if ( origsso != null && origsso.length() == 9 && origsso.isAlphanumeric()){  // if ( origsso != null && origsso.right(9).containsOnly('0123456789') )
			origsso = String.valueOf(origsso.right(9));
		}
		
		else {
			origsso = null;
		}

		return origsso;
	}
	
	public static string normalizeCustomerNumber ( string origno ){

		string padstring = '0';

		if ( origno != null && origno.containsOnly('0123456789') && origno.length() < 10 ){
			origno = string.valueOf(long.valueOf(origno));
			integer repeatx = 10 - origno.length();
			origno = padstring.repeat(repeatx) + origno ;
		}

		return origno ;
	}
}