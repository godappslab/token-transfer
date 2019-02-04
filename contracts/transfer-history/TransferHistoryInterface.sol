pragma solidity >=0.4.21<0.6.0;

interface TransferHistoryInterface {
    function isTokenTransferred(bytes _signature) external view returns (bool);
    function recordAsTokenTransferred(bytes _signature) external returns (bool);
    function updateTransferDappsAddress(address _newTransferDapps) external returns (bool);
}
