const TransferHistory = artifacts.require('./transfer-history/TransferHistory.sol');

module.exports = (deployer) => {
    deployer.deploy(TransferHistory);
};
