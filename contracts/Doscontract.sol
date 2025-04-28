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

    mapping(address=>uint) withdrawbox;
     function fixGreifing() public{
        for(uint i=0;i<winnerscount;i++){
            withdrawbox[winners[i]] = winnersPrizes[winners[i]];
            delete winnersPrizes[winners[i]];
            delete winners[i];
        }
     }
     function withdraw() public {
        uint amount = withdrawbox[msg.sender];
        withdrawbox[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
     }
}