def account_login():
	password = input('password:')
	if password == '12345':
		print('Login success!')
	else:
	    print('wrong password or invalid input!')
	    account_login()
account_login()