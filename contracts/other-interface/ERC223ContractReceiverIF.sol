pragma solidity >=0.4.24<0.6.0;

/* https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/Receiver_Interface.sol */
interface ERC223ContractReceiverIF {
    function tokenFallback(address _from, uint256 _value, bytes _data) external returns (bool);
}
