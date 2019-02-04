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

    // ERCトークンへの交換レート
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

    // ERC223向けのinterface

    struct TKN {
        address sender;
        uint256 value;
        bytes data;
        //        bytes4 sig;
    }

    // @dev Standard ERC223 function that will handle incoming token transfers.
    // @params _from  Token sender address.
    // @params _value Amount of tokens.
    // @params _data  Transaction metadata.
    function tokenFallback(address _from, uint256 _value, bytes _data) external returns (bool) {
        // 指定のERC223トークン以外は受け取らない
        //        require(msg.sender == ercToken);

        TKN memory tkn;
        tkn.sender = _from;
        tkn.value = _value;
        tkn.data = _data;
        //        uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
        //        tkn.sig = bytes4(u);

        /* tkn variable is analogue of msg variable of Ether transaction
        *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
        *  tkn.value the number of tokens that were sent   (analogue of msg.value)
        *  tkn.data is data of token transaction   (analogue of msg.data)
        *  tkn.sig is 4 bytes signature of function
        *  if data of token transaction is a function execution
        */
        return true;

    }

    // @title ERCトークンを支払う
    // @params _signature
    // @params _to
    // @params _value
    // @params _nonce
    function transferToken(bytes _signature, address _to, uint256 _value, string _nonce) external onlyOwner returns (bool success) {
        /// 署名の妥当性を検証

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

        // 支払済みではないことを確認
        require(TransferHistoryInterface(historyDapps).isTokenTransferred(_signature) == false);

        // InternalCirculationTokenInterface -> ERCToken換算
        uint256 ercTokenValue = _value.mul(exchangeLateToERCToken);

        // ToDo イベント通知するか否か？

        success = ERC20Basic(ercToken).transfer(_to, ercTokenValue);

        // トークンを配布

        // 支払いを記録
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
