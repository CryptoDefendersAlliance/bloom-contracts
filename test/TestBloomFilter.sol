pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/BloomFilter.sol";


contract TestBloomFilter {
  // address bloomAddress = DeployedAddresses.BloomFilter();
  // BloomFilter bloomFilter = BloomFilter(bloomAddress);
  address constant senderA = 0x26AdDE1A778F9A7645f0F6f325f8E503D0723c46;
  address constant senderB = 0x26AdDE1A778F9A7645f0F6f325f8E503D0723c41;

  function testBloomSimple() public {
        BloomFilter bloomFilter = new BloomFilter();
  		bool notInBloom = bloomFilter.test(senderA);
  		Assert.equal(notInBloom, false, "should not be in bloom");  		
  }
  
  function testBloomAddAndTest() public {
  		BloomFilter bloomFilter = new BloomFilter();
		bloomFilter.addone(senderA);
		bool inBloom = bloomFilter.test(senderA);
		Assert.equal(inBloom, true, "should be in bloom");
  }

  function testBloomAssureAddress() public {
  		BloomFilter bloomFilter = new BloomFilter();
		bloomFilter.addone(senderB);		

		ThrowProxy throwproxy = new ThrowProxy(address(bloomFilter)); 		
		BloomFilter(address(throwproxy)).assure_address(senderA);
		bool res = throwproxy.execute.gas(200000)();
		Assert.equal(res, true, "should not revert");
  }
  
  function testBloomAssureAddressBad() public {
  		BloomFilter bloomFilter = new BloomFilter();
		bloomFilter.addone(senderB);		

		ThrowProxy throwproxy = new ThrowProxy(address(bloomFilter)); 		
		BloomFilter(address(throwproxy)).assure_address(senderB);
		bool res = throwproxy.execute.gas(200000)();
		Assert.equal(res, false, "should revert");
  }


}



// Proxy contract for testing throws
contract ThrowProxy {
  address public target;
  bytes data;

  function ThrowProxy(address _target) public {
    target = _target;
  }

  //prime the data using the fallback function.
  function() public {
    data = msg.data;
  }

  function execute() public returns (bool) {
    return target.call(data);
  }
}