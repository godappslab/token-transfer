# Implementation for exchanging from Internal Circulation Token to ERC20/223 Token

It is under development.

## 概要

内部流通トークン - [godappslab/internal\-circulation\-token: Implementation of Internal Circulation Token](https://github.com/godappslab/internal-circulation-token) で、ユーザーがオーナーへ内部流通トークンからERC20/223のトークンへの交換をリクエストしたことを受けて、そのユーザーへあらかじめ指定されたERC20/223トークンを送金するÐAppsの実装

## 要点

内部流通トークンを完全で確実にERC20/223トークンへ交換する仕組みを提供します。

## このÐAppsによって実現できること

- 確実な支払いを行うことができる
- 支払いが行われたことを、その記録が改ざんされること無く確認することができる
- 動作のトリガーとなるのは内部流通トークンが発するイベントであるため、無人運転が可能

## 仕様

**TransferHistoryのインターフェース**

*TransferHistory* は記録を実行する *TokenTransfer* ÐAppsのスマートコントラクトのアドレスを管理する。決められているアドレス以外からの、履歴記録は応じない。

アドレスの登録はオーナーが `updateTransferDappsAddress()` 関数を実行することにより設定できる。

```solidity
pragma solidity >=0.4.21<0.6.0;

interface TransferHistoryInterface {
    function isTokenTransferred(bytes _signature) external view returns (bool);
    function recordAsTokenTransferred(bytes _signature) external returns (bool);
    function updateTransferDappsAddress(address _newTransferDapps) external returns (bool);
}
```

**ERC20/223トークン支払いの処理**

![ERC20/223トークン支払いの処理](./docs/sequence-diagram/token-transfer.svg)

<img src="./docs/flowchart/token-transfer.svg" width="300" alt="ERC20/223トークン支払いの処理">

## Test Cases

[Truffle Suite ](https://truffleframework.com/) を利用したテストスクリプトで動作確認を行う。



## 実装

このÐAppsの実装はGitHubにて公開する。

https://github.com/godappslab/token-transfer

## 参考文献

