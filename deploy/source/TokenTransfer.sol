pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECDSA {
    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    /**
     * toEthSignedMessageHash
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
     * and hash the result
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

interface TransferHistoryInterface {
    function isTokenTransferred(bytes calldata _signature) external view returns (bool);
    function recordAsTokenTransferred(bytes calldata _signature) external returns (bool);
    function updateTransferDappsAddress(address _newTransferDapps) external returns (bool);
}

interface InternalDistributionTokenInterface {
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
    function acceptTokenTransfer(bytes calldata _signature, address _requested_user, uint256 _value, string calldata _nonce)
        external
        returns (bool success);

    // @title A function that generates a hash value of a request to which a user sends a token (executed by the user of the token)
    // @params _requested_user ETH address that requested token transfer
    // @params _value Number of tokens
    // @params _nonce One-time string
    // @return bytes32 Hash value
    // @dev The user signs the hash value obtained from this function and hands it over to the owner outside the system
    function requestTokenTransfer(address _requested_user, uint256 _value, string calldata _nonce) external view returns (bytes32);

    // @title Returns whether it is a used signature
    // @params _signature Signature string
    // @return bool Used or not
    function isUsedSignature(bytes calldata _signature) external view returns (bool);

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
    function tokenFallback(address _from, uint256 _value, bytes calldata _data) external returns (bool);
}

contract TokenTransfer {
    // Load library
    using SafeMath for uint256;
    using ECDSA for bytes32;

    address public owner;

    // ERC Token Contract Address
    address public ercToken;

    // Internal Token Contract Address
    address public internalDistributionToken;

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
        internalDistributionToken = _internalCirculationToken;
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
            InternalDistributionTokenInterface(internalDistributionToken).isUsedSignature(_signature) == true,
            "Must be a used signature in the internal circulation token"
        );

        // Recalculate hash value
        bytes32 hashedTx = InternalDistributionTokenInterface(internalDistributionToken).requestTokenTransfer(_to, _value, _nonce);

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

        // InternalDistributionTokenInterface -> ERCToken
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