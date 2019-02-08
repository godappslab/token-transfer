const fs = require('fs');
const TransferHistory = artifacts.require('./transfer-history/TransferHistory');

module.exports = (deployer) => {
    deployer.deploy(TransferHistory).then(() => {
        // Save ABI to file
        fs.mkdirSync('deploy/abi/', { recursive: true });
        fs.writeFileSync('deploy/abi/TransferHistory.json', JSON.stringify(TransferHistory.abi), { flag: 'w' });
    });
};
