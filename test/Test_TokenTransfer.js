const TransferHistory = artifacts.require('TransferHistory');
const TokenTransfer = artifacts.require('TokenTransfer');

const DummyInternalCirculationToken = artifacts.require('./DummyInternalCirculationToken.sol');
const DummyERCToken = artifacts.require('./DummyERCToken.sol');

contract('[TEST] TokenTransfer', async (accounts) => {
    const ownerAddress = accounts[0];

    const log = function() {
        console.log('       [LOG]', ...arguments);
    };

    console.log('ownerAddress:', ownerAddress);

    const CORRECT_SIGNATURE =
        '0x1748c75b257a72fba772f43b8b1653b7164c3c68df5ce64ddf80551970baa84c7bdd82ef6016ad373e0f86396f990d24f0fb75b4d35bacb9c32dda87b25ef1931b';
    const CORRECT_ADDRESS = '0x07589435cE9FFb1b7fDA2Ae7bE0452D2cd1cF2fa';
    const CORRECT_TOKEN_QUANTITY = '10';
    const CORRECT_NONCES = 'KwqB9ZhVQeMmRhsbwzEQB_wnNQKqJHWsN2kT';

    let erc_token;
    let point_token;
    let transfer_history;
    let token_transfer;

    it('Deploying Smart Contract', async () => {
        erc_token = await DummyERCToken.new();
        point_token = await DummyInternalCirculationToken.new();
        transfer_history = await TransferHistory.new();

        log('erc_token:', erc_token.address);
        log('point_token:', point_token.address);
        log('transfer_history:', transfer_history.address);

        token_transfer = await TokenTransfer.new(erc_token.address, point_token.address, transfer_history.address);

        log('tokenTransfer:', token_transfer.address);

        await transfer_history.updateTransferDappsAddress.sendTransaction(token_transfer.address);
    });

    it('[Different nonces] Mismatch with address obtained from signature', async () => {
        await erc_token.setDummyAnswer.sendTransaction(true);

        const _signature = CORRECT_SIGNATURE;
        const _to = CORRECT_ADDRESS;
        const _value = CORRECT_TOKEN_QUANTITY;
        const _nonce = 'it4ri0ieFahqu2cieng7bohphach7iniethu'; // Different

        try {
            await token_transfer.transferToken.sendTransaction(_signature, _to, _value, _nonce);
            assert.fail('Expected throw not received');
        } catch (e) {
            log(e.message);
            const reverted = e.message.search('Mismatch with address obtained from signature') >= 0;
            assert.equal(reverted, true);
        }
    });

    it('[Different token quantity] Mismatch with address obtained from signature', async () => {
        await erc_token.setDummyAnswer.sendTransaction(true);

        const _signature = CORRECT_SIGNATURE;
        const _to = CORRECT_ADDRESS;
        const _value = '100'; // Different
        const _nonce = CORRECT_NONCES;

        try {
            await token_transfer.transferToken.sendTransaction(_signature, _to, _value, _nonce);
            assert.fail('Expected throw not received');
        } catch (e) {
            log(e.message);
            const reverted = e.message.search('Mismatch with address obtained from signature') >= 0;
            assert.equal(reverted, true);
        }
    });

    it('[Different address] Mismatch with address obtained from signature', async () => {
        await erc_token.setDummyAnswer.sendTransaction(true);

        const _signature = CORRECT_SIGNATURE;
        const _to = '0x083Cd205ee174D0d0D259c0225be4218EAdcE556'; // Different
        const _value = CORRECT_TOKEN_QUANTITY;
        const _nonce = CORRECT_NONCES;

        try {
            await token_transfer.transferToken.sendTransaction(_signature, _to, _value, _nonce);
            assert.fail('Expected throw not received');
        } catch (e) {
            log(e.message);
            const reverted = e.message.search('Mismatch with address obtained from signature') >= 0;
            assert.equal(reverted, true);
        }
    });

    it('ERC token transfer failure', async () => {
        await erc_token.setDummyAnswer.sendTransaction(false);

        const _signature = CORRECT_SIGNATURE;
        const _to = CORRECT_ADDRESS;
        const _value = CORRECT_TOKEN_QUANTITY;
        const _nonce = CORRECT_NONCES;

        try {
            await token_transfer.transferToken.sendTransaction(_signature, _to, _value, _nonce);
            assert.fail('Expected throw not received');
        } catch (e) {
            log(e.message);
            const reverted = e.message.search('transfer failed') >= 0;
            assert.equal(reverted, true);
        }

        assert.ok(true);
    });

    it('[The first time] Success', async () => {
        await erc_token.setDummyAnswer.sendTransaction(true);

        const _signature = CORRECT_SIGNATURE;
        const _to = CORRECT_ADDRESS;
        const _value = CORRECT_TOKEN_QUANTITY;
        const _nonce = CORRECT_NONCES;

        await token_transfer.transferToken.sendTransaction(_signature, _to, _value, _nonce);

        assert.ok(true);
    });

    it('[Second time fail] Already token remitted', async () => {
        await erc_token.setDummyAnswer.sendTransaction(true);

        const _signature = CORRECT_SIGNATURE;
        const _to = CORRECT_ADDRESS;
        const _value = CORRECT_TOKEN_QUANTITY;
        const _nonce = CORRECT_NONCES;

        try {
            await token_transfer.transferToken.sendTransaction(_signature, _to, _value, _nonce);
            assert.fail('Expected throw not received');
        } catch (e) {
            log(e.message);
            const reverted = e.message.search('Already token remitted') >= 0;
            assert.equal(reverted, true);
        }
    });
});
