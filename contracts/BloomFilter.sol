pragma solidity ^0.4.9;

contract BloomFilter {
    int array_size = 512;
    int bits_per_entry = 8;
    int bitcount = 512 * bits_per_entry;
    int hashes = 13;
    uint8[] filter;
    address owner;
    constructor () public {
        owner = msg.sender;
        filter = new uint8[](512);
    }
    
    function toBytes(address a) private pure returns (bytes b){
       assembly {
            let m := mload(0x40)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
            mstore(0x40, add(m, 52))
            b := m
       }
    }

    function addone(address s) public {
        require (owner == msg.sender) ;
        int digest = int(sha256(toBytes(s)));

        for (int i = 0; i < hashes; i++) {
            int a = digest & (bitcount - 1);
            filter[uint8(a / bits_per_entry)] |= (2 ** uint8(a % bits_per_entry));
            digest >>= (bits_per_entry / hashes);
        }        
    }
    function set(uint8[] newBloom) public {
        require (owner == msg.sender) ;
        filter = newBloom;
    }
    function get() public view returns (uint8[]){
        return filter ;
    }




    function test(address s) public view returns (bool) {
        int digest = int(sha256(toBytes(s)));
        for (int i = 0; i < hashes; i++) {
            int a = digest & (bitcount - 1);
            if ((filter[uint8(a / bits_per_entry)] & (2 ** uint8(a % bits_per_entry))) <= 0) {
                return false;
            }
            digest >>= (bits_per_entry / hashes);
        }
        return true;
    }
    function assure_address(address s) public view {
        assert(!test(s));                
    }
}
