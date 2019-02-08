pragma solidity >=0.4.24<0.6.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECRecovery {

  /**
   * @dev Recover signer address from a message by using their signature
   * @param _hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param _sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 _hash, bytes _sig)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Check the signature length
    if (_sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      r := mload(add(_sig, 32))
      s := mload(add(_sig, 64))
      v := byte(0, mload(add(_sig, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      // solium-disable-next-line arg-overflow
      return ecrecover(_hash, v, r, s);
    }
  }

  /**
   * toEthSignedMessageHash
   * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
   * and hash the result
   */
  function toEthSignedMessageHash(bytes32 _hash)
    internal
    pure
    returns (bytes32)
  {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
    );
  }
}

interface TransferHistoryInterface {
    function isTokenTransferred(bytes _signature) external view returns (bool);
    function recordAsTokenTransferred(bytes _signature) external returns (bool);
    function updateTransferDappsAddress(address _newTransferDapps) external returns (bool);
}

interface InternalCirculationTokenInterface {
    // Required methods

    // @title Is the ETH address of the argument the distributor of the token?
    // @param _account
    // @return bool (true:owner false:not owner)
    function isDistributor(address _account) external view returns (bool);

    // @title A function that adds the ETH address of the argument to the distributor list of the token
    // @param _account ETH address you want to add
    // @return bool
    function addToDistributor(address _account) external returns (bool success);

    // @title A function that excludes the ETH address of the argument from the distributor list of the token
    // @param _account ETH address you want to delete
    // @return bool
    function deleteFromDistributor(address _account) external returns (bool success);

    // @title A function that accepts a user's transfer request (executed by the contract owner)
    // @param bytes memory _signature
    // @param address _requested_user
    // @param uint256 _value
    // @param string _nonce
    // @return bool
    function acceptTokenTransfer(bytes _signature, address _requested_user, uint256 _value, string _nonce) external returns (bool success);

    // @title A function that generates a hash value of a request to which a user sends a token (executed by the user of the token)
    // @params _requested_user ETH address that requested token transfer
    // @params _value Number of tokens
    // @params _nonce One-time string
    // @return bytes32 Hash value
    // @dev The user signs the hash value obtained from this function and hands it over to the owner outside the system
    function requestTokenTransfer(address _requested_user, uint256 _value, string _nonce) external view returns (bytes32);

    // @title Returns whether it is a used signature
    // @params _signature Signature string
    // @return bool Used or not
    function isUsedSignature(bytes _signature) external view returns (bool);

    // Events

    // token assignment from owner to distributor
    event Allocate(address indexed from, address indexed to, uint256 value);

    // tokens from distributor to users
    event Distribute(address indexed from, address indexed to, uint256 value);

    // tokens from distributor to owner
    event BackTo(address indexed from, address indexed to, uint256 value);

    // owner accepted the token from the user
    event Exchange(address indexed from, address indexed to, uint256 value, bytes signature, string nonce);

    event AddedToDistributor(address indexed account);
    event DeletedFromDistributor(address indexed account);
}

/* https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/Receiver_Interface.sol */
interface ERC223ContractReceiverIF {
    function tokenFallback(address _from, uint256 _value, bytes _data) external returns (bool);
}

contract TokenTransfer {
    // Load library
    using SafeMath for uint256;
    using ECRecovery for bytes32;

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
    function tokenFallback(address _from, uint256 _value, bytes _data) external view returns (bool) {
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

        success = ERC20Basic(ercToken).transfer(_to, ercTokenValue);

        // record
        if (success) {
            TransferHistoryInterface(transferHistory).recordAsTokenTransferred(_signature);
        }
        return success;

    }

    // @title Send all tokens to the owner
    function withdraw() external onlyOwner returns (bool success) {
        uint256 balance = ERC20Basic(ercToken).balanceOf(address(this));
        success = ERC20Basic(ercToken).transfer(owner, balance);
        return success;
    }

    // ---------------------------------------------
    // Destruction of a contract (only owner)
    // ---------------------------------------------
    function destory() public onlyOwner {
        selfdestruct(owner);
    }

}