var Splitter = artifacts.require("./Splitter.sol");

contract('Testing my Splitter contract', accounts => {

	//console.log(accounts);

	var contract;
	var owner = accounts[0];
	var receiver1 = accounts[1];
	var receiver2 = accounts[2];
	var part1;
	var part2;
	var amount = 30;

	beforeEach(function() {
		//No need to pass values
		return Splitter.new({from:owner})
		.then(function(instance){
			contract = instance;
		});
	});


	it("Should be owned by owner", function(){
		return contract.owner({from: owner})
		.then (function(_owner){
			assert.strictEqual(_owner, owner, "Error: Not the same owner!");
		});
	});

	it("isKilled should be false at the beginning", function(){
		return contract.isKilled({from: owner})
		.then(function(_isKilled){
			assert.strictEqual(_isKilled, false, "Error: isKilled should be false!");
		});

	});

	it("Change isKilled value", function(){
		return contract.killContract(true, {from: owner})
		.then (function(){
			return contract.isKilled({from:owner});
		})
		.then(function(_isKilled){
			assert.strictEqual(_isKilled, true, "Error: is Killed should be true");
		});
	});

	
	//This test is not working as intended.
    
	/*it("Check withdraw", function(){
		var initialBalance = web3.eth.getBalance(accounts[1]);
	 	console.log("Account_1 Initial Balance: ", initialBalance);

	 	return contract.split(receiver1, receiver2, {from: owner, value: amount})
	 	.then(function(txt){
	 		return contract.withdraw({from:accounts[1]});
	 	})
	 	.then(function(){
	 		return contract.address1({from:owner});
	 	})
	 	.then(function(_receiver1){
	 		var newBalance = web3.eth.getBalance(_receiver1);
	 		console.log("Account 1 New Balance: ", newBalance , " receiver: ", _receiver1);
	 		assert.equal(newBalance, initialBalance, "Error: Incorrect Balance");
	 	});
	}); */

	it("Check both receivers's addresses and balances", function(){

		return contract.split(receiver1, receiver2, {from: owner, value: amount})
		.then(function(txt){
			return contract.address1({from: owner});
		})
		.then(function(_receiver1){
			//console.log("Receiver 1: " + _receiver1);
			assert.strictEqual(_receiver1, receiver1, "Error: first receiver's address is wrong");
		})
		.then(function(){
			return contract.getSplitBalance.call(receiver1, {from:owner});
		})
		.then(function(_part1){
			part1 = _part1.toNumber();

			//console.log("Split value 1: ", part1);
			assert.strictEqual(part1, amount/2, "Error: receiver1's balance is wrong");
			return contract.address2({from:owner});
		})
		.then(function(_receiver2){
			//console.log("Receiver 2: " + _receiver2);
			assert.strictEqual(_receiver2, receiver2, "Error: second receiver's address is wrong");
		})
		.then(function(){
			return contract.getSplitBalance.call(receiver2, {from:owner});
		})
		.then(function(_part2){
			part2 = _part2.toNumber();
			//console.log("Split value 2: ", part1);
			assert.equal(part1, amount/2, "Error: receiver1's balance is wrong");
			assert.equal(amount, part1 + part2, "Total amount is not correct");
		});
	});
});