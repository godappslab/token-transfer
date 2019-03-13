pragma solidity ^0.5.0;

interface TransferHistoryInterface {
    function isTokenTransferred(bytes calldata _signature) external view returns (bool);
    function recordAsTokenTransferred(bytes calldata _signature) external returns (bool);
    function updateTransferDappsAddress(address _newTransferDapps) external returns (bool);
}
