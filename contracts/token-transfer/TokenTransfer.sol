pragma solidity >=0.4.21<0.6.0;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";
import "zeppelin-solidity/contracts/ECRecovery.sol";

import "../transfer-history/TransferHistoryInterface.sol";
import "../other-interface/InternalCirculationTokenInterface.sol";
import "../other-interface/ERC223ContractReceiverIF.sol";

contract TokenTransfer {
    // Load library
    using SafeMath for uint256;
    using ECRecovery for bytes32;

    address public owner;

    // ERC Token Contract Address
    address public ercToken;

    // Point Token Contract Address
    address public pointToken;

    // History Dapps Address
    address public historyDapps;

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
    constructor(address _ercToken, address _pointToken, address _historyDapps) public {
        // The owner address is maintained.
        owner = msg.sender;

        ercToken = _ercToken;
        pointToken = _pointToken;
        historyDapps = _historyDapps;

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
    function tokenFallback(address _from, uint256 _value, bytes _data) external returns (bool) {
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
    function transferToken(bytes _signature, address _to, uint256 _value, string _nonce) external onlyOwner returns (bool success) {
        // Verify signature
        // Recalculate hash value
        bytes32 hashedTx = InternalCirculationTokenInterface(pointToken).requestTokenTransfer(_to, _value, _nonce);

        // Identify the requester's ETH Address
        address _user = hashedTx.recover(_signature);

        require(_user != address(0));

        // the argument `_to` and
        // the value obtained by calculation from the signature are the same ETH address
        //
        // If they are different, it is judged that the user's request has not been transmitted correctly
        require(_user == _to);

        // Not being transferred
        require(TransferHistoryInterface(historyDapps).isTokenTransferred(_signature) == false);

        // InternalCirculationTokenInterface -> ERCToken
        uint256 ercTokenValue = _value.mul(exchangeLateToERCToken);

        success = ERC20Basic(ercToken).transfer(_to, ercTokenValue);

        // record
        if (success) {
            TransferHistoryInterface(historyDapps).recordAsTokenTransferred(_signature);
        }
        return success;

    }

    // ---------------------------------------------
    // Destruction of a contract (only owner)
    // ---------------------------------------------
    function destory() public onlyOwner {
        selfdestruct(owner);
    }

}
