//SPX-Licence-Identifier: Undefined

pragma solidity ^0.8.19;

contract dos {

    mapping(uint=>address) winners;
    uint winnerscount;
    mapping(address=>uint) winnersPrizes;
    /**
    Example One.
    One user is a smart contract and on receive function , reverts it . 
    so remaining winners never get their prizes
     */
     function testGriefing() public {
        for(uint i=0;i<winnerscount;i++){
            address(winners[i]).call{value:winnersPrizes[winners[i]]}("");
        }
     }
}