pragma solidity ^0.4.0;

import "./Owned.sol";
import "./StandardToken.sol";

contract MetaCoin is owned, StandardToken {
    uint256 public sellPrice;
    uint256 public buyPrice;

    mapping(address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);

    function MetaCoin(uint256 initialSupply, string tokenName, string tokenSympol) public
    StandardToken(initialSupply, tokenName, tokenSympol) {}

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);

    }

    function mintToken(address _target, uint256 _mintAmount) onlyOwner public {

        balanceOf[_target] += _mintAmount;
        totalSupply += _mintAmount;
        emit Transfer(0, this, _mintAmount);
        emit Transfer(this, _target, _mintAmount);


    }

    function freezeAccount(address _target, bool freeze) onlyOwner public {
        frozenAccount[_target] = freeze;
        emit FrozenFunds(_target, freeze);
    }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    function buy() payable public {
        uint amount = msg.value / buyPrice;
        _transfer(this, msg.sender, amount);
    }

    function sell(uint256 amount) payable public {
        require(balanceOf[msg.sender] >= amount * sellPrice);
        _transfer(msg.sender, this, amount);
        msg.sender.transfer(amount * sellPrice);
    }
}
