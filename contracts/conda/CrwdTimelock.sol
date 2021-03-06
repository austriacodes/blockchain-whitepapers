pragma solidity ^0.4.11;


import 'zeppelin/token/ERC20Basic.sol';
import './CrwdToken.sol';


contract CrwdTimelock {
    using SafeMath for uint256;

    mapping(address => uint256) public balances;

    uint256 public assignedBalance;
    // beneficiary of tokens after they are released
    address public controller;

    // timestamp when token release is enabled
    uint public releaseTime;

    CrwdToken token;

    function CrwdTimelock(CrwdToken _token, address _controller, uint _releaseTime) {
        require(_releaseTime > now);
        token = _token;
        controller = _controller;
        releaseTime = _releaseTime;
    }

    function assignToBeneficiary(address _beneficiary, uint256 _amount) {
        require(msg.sender == controller);
        assignedBalance = assignedBalance.sub(balances[_beneficiary]);
        //balanceOf(this) will be 0 until the Operational Phase has been reached, no need for explicit check
        require(token.balanceOf(this) >= assignedBalance.add(_amount));
        balances[_beneficiary] = _amount;
        //balance is set, not added, gives _controller the power to set any balance, even 0
        assignedBalance = assignedBalance.add(balances[_beneficiary]);
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release(address _beneficiary) {
        require(now >= releaseTime);
        uint amount = balances[_beneficiary];
        require(amount > 0);
        token.transfer(_beneficiary, amount);
        assignedBalance = assignedBalance.sub(amount);
        balances[_beneficiary] = 0;

    }
}
