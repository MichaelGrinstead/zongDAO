//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

import "./zongToken.sol";

contract zongICO is zongToken { 

    address public admin;
    address payable public deposit;
    uint tokenPrice = 0.001 ether; //1 eth = 1000 zongtoken
    uint public hardCap = 300 ether;
    uint public raisedAmount;
    uint public saleStart = block.timestamp;
    uint public saleEnd = block.timestamp + 604800;
    uint public tokenTradeStart = saleEnd + 604800;
    uint public maxInvestment = 5 ether;
    uint public minInvestment = 0.1 ether;

    enum State{beforeStart, running, afterEnd, halted}
    State public icoState;

    constructor(address payable _deposit){
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.beforeStart;

    }

    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }

    function halt() public onlyAdmin{
        icoState = State.halted;
    }

    function resume() public onlyAdmin{
        icoState = State.running;
    }

    // function changeDepositAddress(address payable newDeposit) public onlyAdmin{
    //     deposit = newDeposit;
    // }

    function getCurrentState() public view returns(State) {
        if(icoState == State.halted){
            return State.halted;
        }else if(block.timestamp < saleStart){
            return State.beforeStart;
        }else if(block.timestamp >= saleStart && block.timestamp <= saleEnd){
            return State.running;
        }else{
            return State.afterEnd;
        }
    }

    event Invest(address investor, uint value, uint tokens);

    function invest() payable public returns(bool){
        icoState = getCurrentState();
        require(icoState == State.running);

        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        raisedAmount += msg.value;
        require(raisedAmount <= hardCap);

        uint tokens = msg.value/tokenPrice;

        balances[msg.sender] += tokens;
        balances[founder] -= tokens;

        deposit.transfer(msg.value);
        emit Invest(msg.sender, msg.value, tokens);

        return true;        
    }
    
    receive() payable external{
            invest();
        }


}