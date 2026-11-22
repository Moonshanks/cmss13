
/datum/bank
	var/list/accounts = list()

/datum/bank/proc/add_account(datum/bank_account/A)
	if(!A)
		return FALSE

	if(!A.id)
		return FALSE

	if(accounts[A.id])
		return FALSE

	accounts[A.id] = A
	return TRUE

/datum/bank/proc/get_wallet(account_id, wallet_id)
	if(!account_id || !wallet_id)
		return null

	var/datum/bank_account/A = accounts[account_id]

	if(!A)
		return null

	return A.get_wallet(wallet_id)

/datum/bank/proc/deposit(account_id, wallet_id, amount, from, reason)
	var/datum/wallet/W = get_wallet(account_id, wallet_id)

	if(!W)
		return FALSE

	return W.deposit(amount, from, wallet_id, reason)

/datum/bank/proc/withdraw(account_id, wallet_id, amount, to, reason)
	var/datum/wallet/W = get_wallet(account_id, wallet_id)

	if(!W)
		return FALSE

	return W.withdraw(amount, wallet_id, to, reason)

/datum/bank/proc/transfer(from_account_id, from_wallet_id, to_account_id, to_wallet_id, amount, reason, client/C)
	if(!isnum(amount) || amount <= 0 || amount != round(amount))
		return FALSE

	if(!istext(reason) || !length(reason))
		return FALSE

	var/datum/bank_account/A = accounts[from_account_id]
	var/datum/bank_account/B = accounts[to_account_id]

	if(!A || !B)
		return FALSE

	var/datum/wallet/from_wallet = get_wallet(from_account_id, from_wallet_id)
	var/datum/wallet/to_wallet = get_wallet(to_account_id, to_wallet_id)

	if(!from_wallet || !to_wallet)
		return FALSE

	if(from_wallet == to_wallet)
		return FALSE

	if(!from_wallet.currency_type || from_wallet.currency_type != to_wallet.currency_type)
		return FALSE

	if(from_wallet.balance < amount)
		return FALSE

	if(!A.validate_owner(C))
		return FALSE

	var/datum/transaction/T1 = new
	var/datum/transaction/T2 = new

	T1.id = generate_uuid()
	T1.to = to_wallet_id
	T1.from = from_wallet_id
	T1.timestamp = world.realtime
	T1.amount = -amount
	T1.reason = reason
	T1.balance_after = from_wallet.balance - amount

	T2.id = generate_uuid()
	T2.to = to_wallet_id
	T2.from = from_wallet_id
	T2.timestamp = world.realtime
	T2.amount = amount
	T2.reason = reason
	T2.balance_after = to_wallet.balance + amount

	if(!T1.id || !T2.id)
		return FALSE

	for(var/datum/transaction/existing in from_wallet.transactions)
		if(existing.id == T1.id)
			return FALSE

	for(var/datum/transaction/existing in to_wallet.transactions)
		if(existing.id == T2.id)
			return FALSE

	from_wallet.transactions += T1
	to_wallet.transactions += T2

	from_wallet.balance = T1.balance_after
	to_wallet.balance = T2.balance_after

	return TRUE


/datum/bank_account
	var/id = null
	var/owner = null
	var/owner_type = null
	var/list/wallets = list()

/datum/bank_account/proc/validate_owner(client/C)
	if(owner_type != "player")
		return FALSE

	if(!C || !C.ckey)
		return FALSE

	if(owner != C.ckey)
		return FALSE

	return TRUE

/datum/bank_account/proc/add_wallet(datum/wallet/W)
	if(!W)
		return FALSE

	if(!W.id)
		return FALSE

	if(wallets[W.id])
		return FALSE

	wallets[W.id] = W
	return TRUE

/datum/bank_account/proc/get_wallet(wallet_id)
	if(!wallet_id)
		return null

	return wallets[wallet_id]


/datum/wallet
	var/id = null
	var/owner = null
	var/owner_type = null
	var/currency_type = null
	var/balance = 0
	var/list/transactions = list()

/datum/wallet/proc/add_transaction(datum/transaction/T)
	if(!T || !T.id)
		return FALSE

	for(var/datum/transaction/existing in transactions)
		if(existing.id == T.id)
			return FALSE

	transactions += T

	return TRUE

/datum/wallet/proc/deposit(amount, from, to, reason)
	if(!amount || !isnum(amount))
		return FALSE

	if(amount <= 0 || amount != round(amount))
		return FALSE

	if(!from || !to || !reason || !istext(from) || !istext(to) || !istext(reason))
		return FALSE

	if(to != id)
		return FALSE

	var/datum/transaction/T = new

	T.id = generate_uuid()
	T.to = to
	T.from = from
	T.timestamp = world.realtime
	T.amount = amount
	T.reason = reason
	T.balance_after = balance + amount

	if(!add_transaction(T))
		return FALSE

	balance = T.balance_after

	return TRUE

/datum/wallet/proc/withdraw(amount, from, to, reason)
	if(!amount || !isnum(amount))
		return FALSE

	if(amount <= 0 || amount != round(amount))
		return FALSE

	if(!from || !to || !reason || !istext(from) || !istext(to) || !istext(reason))
		return FALSE

	if(from != id)
		return FALSE

	if(balance < amount)
		return FALSE

	var/datum/transaction/T = new

	T.id = generate_uuid()
	T.to = to
	T.from = from
	T.timestamp = world.realtime
	T.amount = -amount
	T.reason = reason
	T.balance_after = balance - amount

	if(!add_transaction(T))
		return FALSE

	balance = T.balance_after

	return TRUE


/datum/transaction
	var/id = null
	var/to = null
	var/from = null
	var/timestamp = null
	var/amount = 0
	var/reason = null
	var/balance_after = null
