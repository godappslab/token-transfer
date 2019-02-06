const TokenTransfer = artifacts.require('./token-transfer/TokenTransfer.sol');

const _ercToken = '0xxxxxxxxxxxxxxxxxxxxx';
const _pointToken = '0xxxxxxxxxxxxxxxxxxxxx';
const _historyDapps = '0xxxxxxxxxxxxxxxxxxxxx';

module.exports = (deployer, network) => {
    if (network === 'test') {
        return;
    }
    deployer.deploy(TokenTransfer, _ercToken, _pointToken, _historyDapps);
};
