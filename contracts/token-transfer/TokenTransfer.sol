pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";

import "../transfer-history/TransferHistoryInterface.sol";
import "../other-interface/InternalCirculationTokenInterface.sol";
import "../other-interface/ERC223ContractReceiverIF.sol";

contract TokenTransfer {
    // Load library
    using SafeMath for uint256;
    using ECDSA for bytes32;

    address public owner;

    // ERC Token Contract Address
    address public ercToken;

    // Internal Token Contract Address
    address public internalCirculationToken;

    // History Dapps Address
    address public transferHistory;

    // Exchange rate to ERC token
    uint256 public exchangeLateToERCToken = 1;

    // ---------------------------------------------
    // Modification : Only an owner can carry out.
    // ---------------------------------------------
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // ---------------------------------------------
    // Constructor
    // ---------------------------------------------
    constructor(address _ercToken, address _internalCirculationToken, address _transferHistory) public {
        // The owner address is maintained.
        owner = msg.sender;

        ercToken = _ercToken;
        internalCirculationToken = _internalCirculationToken;
        transferHistory = _transferHistory;

    }

    // for ERC223
    struct TKN {
        address sender;
        uint256 value;
        bytes data;
    }

    // @dev Standard ERC223 function that will handle incoming token transfers.
    // @params _from  Token sender address.
    // @params _value Amount of tokens.
    // @params _data  Transaction metadata.
    function tokenFallback(address _from, uint256 _value, bytes calldata _data) external view returns (bool) {
        // TokenTransfer receives only the specified ERC223 token
        require(msg.sender == ercToken);

        TKN memory tkn;
        tkn.sender = _from;
        tkn.value = _value;
        tkn.data = _data;

        // Response to ERC 223
        return true;

    }

    // @title Send an ERC token
    // @params _signature Signature at the time of exchange request
    // @params _to        Requester
    // @params _value     Amount of exchange (Internal Circulation Token)
    // @params _nonce     Nonce at the time of exchange
    function transferToken(bytes calldata _signature, address _to, uint256 _value, string calldata _nonce) external onlyOwner returns (bool success) {
        // Verify signature

        // It must be a used signature in the internal circulation token
        require(
            InternalCirculationTokenInterface(internalCirculationToken).isUsedSignature(_signature) == true,
            "Must be a used signature in the internal circulation token"
        );

        // Recalculate hash value
        bytes32 hashedTx = InternalCirculationTokenInterface(internalCirculationToken).requestTokenTransfer(_to, _value, _nonce);

        // Identify the requester's ETH Address
        address _user = hashedTx.recover(_signature);

        require(_user != address(0), "Unable to get address from signature");

        // the argument `_to` and
        // the value obtained by calculation from the signature are the same ETH address
        //
        // If they are different, it is judged that the user's request has not been transmitted correctly
        require(_user == _to, "Mismatch with address obtained from signature");

        // Not being transferred
        require(TransferHistoryInterface(transferHistory).isTokenTransferred(_signature) == false, "Already token remitted");

        // InternalCirculationTokenInterface -> ERCToken
        uint256 ercTokenValue = _value.mul(exchangeLateToERCToken);

        success = IERC20(ercToken).transfer(_to, ercTokenValue);

        // record
        if (success) {
            TransferHistoryInterface(transferHistory).recordAsTokenTransferred(_signature);
        }
        return success;

    }

    // @title Send all tokens to the owner
    function withdraw() external onlyOwner returns (bool success) {
        uint256 balance = IERC20(ercToken).balanceOf(address(this));
        success = IERC20(ercToken).transfer(owner, balance);
        return success;
    }

}
