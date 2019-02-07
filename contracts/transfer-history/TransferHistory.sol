pragma solidity >=0.4.24<0.6.0;

import "./TransferHistoryInterface.sol";

contract TransferHistory is TransferHistoryInterface {
    address public owner;

    // Token Transfer Dapps Address
    address public _transferDappsAddress;

    // Signature list after processing (Already transfer)
    mapping(bytes => bool) private usedSignatures;

    // ---------------------------------------------
    // Modification : Only an owner can carry out.
    // ---------------------------------------------
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyTransferDapps() {
        require(msg.sender == _transferDappsAddress);
        _;
    }

    // ---------------------------------------------
    // Constructor
    // ---------------------------------------------
    constructor() public {
        // The owner address is maintained.
        owner = msg.sender;
    }

    // @title Returns whether it is a used signature
    // @params _signature Signature string
    // @return bool Used or not
    function isTokenTransferred(bytes _signature) external view returns (bool) {
        return usedSignatures[_signature];
    }

    // @title
    // @params _signature
    function recordAsTokenTransferred(bytes _signature) external onlyTransferDapps returns (bool) {
        // Record as used signature
        usedSignatures[_signature] = true;
        return this.isTokenTransferred(_signature);
    }

    // @title
    // @params _signature
    function updateTransferDappsAddress(address _newTransferDapps) external onlyOwner returns (bool) {
        _transferDappsAddress = _newTransferDapps;
        return true;
    }

    // ---------------------------------------------
    // Destruction of a contract (only owner)
    // ---------------------------------------------
    function destory() public onlyOwner {
        selfdestruct(owner);
    }
}
