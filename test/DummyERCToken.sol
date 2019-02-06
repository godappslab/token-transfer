pragma solidity >=0.4.21<0.6.0;

contract DummyERCToken {
    address private to;
    uint256 private value;

    bool private _dummyAnswer;

    constructor() public {
        _dummyAnswer = true;
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {
        to = _to;
        value = _value;
        if (_dummyAnswer == false) {
            revert("transfer failed");
        }
        return _dummyAnswer;
    }

    function setDummyAnswer(bool _newAnswer) public {
        _dummyAnswer = _newAnswer;
    }
}
