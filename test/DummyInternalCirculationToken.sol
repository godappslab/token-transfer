pragma solidity >=0.4.21<0.6.0;

contract DummyInternalCirculationToken {
    address public myAddress;

    constructor() public {}

    // @title A function that generates a hash value of a request to which a user sends a token (executed by the user of the token)
    // @params _requested_user ETH address that requested token transfer
    // @params _value Number of tokens
    // @params _nonce One-time string
    // @return bytes32 Hash value
    // @dev The user signs the hash value obtained from this function and hands it over to the owner outside the system
    function requestTokenTransfer(address _requested_user, uint256 _value, string _nonce) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(address(0x6BAC50cf16c5f2a027B4F318E881479A95bEd3AA), bytes4(0x8210d627), _requested_user, _value, _nonce));
    }

}
