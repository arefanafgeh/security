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
            withdrawbox[winners[i]] += winnersPrizes[winners[i]];
            delete winnersPrizes[winners[i]];
            delete winners[i];
        }
     }
     function withdraw() public {
        uint amount = withdrawbox[msg.sender];
        withdrawbox[msg.sender] = 0;
        (bool success , ) = address(msg.sender).call{value:amount}("");
        require(success, "Withdraw failed");
     }


        address highestbidder;
        uint highestbid = 0;
        /**
        If old highest bidder is a contract that refuses the payment through a fallback function , 
        then the whole method reverts and no one ever can place a higher bid */
     function biddingthathalts() public{
        require(msg.value>highestbid ,"Must bid higher");
        if(highestbidder!=address(0)){
            address(highestbidder).transfer(value:highestbid);
        }
        highestbidder = msg.sender;
        highestbid = msg.value;
     }


     function fixbiddinghalts() public{
        require(msg.value>highestbid ,"Must bid higher");
        if(highestbidder!=address(0)){
            withdrawbox[highestbidder] += highestbid;
        }
        highestbidder = msg.sender;
        highestbid = msg.value;
     }
     
}