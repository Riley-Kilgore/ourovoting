use aiken/hash.{Blake2b_224, Hash}
use aiken/transaction.{
  InlineDatum, Mint, Output, OutputReference, ScriptContext, Spend, Transaction,
}
use aiken/transaction/credential.{Script}

type AssetClass {
  policyId: Hash<Blake2b_224, Script>,
  assetName: ByteArray,
}

type Redeemer {
  Stake
  Unstake
}

validator(quorum_nft: AssetClass) {
  // Staking is to mint and lock
  fn stake(redeemer: Redeemer, context: ScriptContext) -> Bool {
    when redeemer is {
      Stake -> todo
      Unstake -> todo
    }
  }

  fn unstake(datum, redeemer, context: ScriptContext) -> Bool {
    todo
  }
}
