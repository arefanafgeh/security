//SPX-Licence-Identifier: Undefined
pragma solidity ^0.8.19;

contract Uncheckedcontract {
    // since from solidity 0.8.0 overflow/underflow leads to revert this is a contract to make it possible

    function uncheckedtest() public returns(uint256){
        uint256 test = 2^256-1;
        unchecked {
            test +=1;
        }
        return test;
    }
}