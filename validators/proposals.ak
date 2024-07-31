use aiken/builtin
use aiken/bytearray
use aiken/dict
use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/transaction.{
  InlineDatum, Mint, Output, ScriptContext, Spend, Transaction,
}
use aiken/transaction/credential.{ScriptCredential, VerificationKey}
use aiken/transaction/value.{AssetName, PolicyId}

type Proposal {
  owner: Hash<Blake2b_224, VerificationKey>,
  data: Data,
}

const proposal_asset_name = "PROPOSAL"

type CollateralValue {
  policy_id: PolicyId,
  asset_name: AssetName,
  quantity: Int,
}

fn add_collateral_value(collateral_value: CollateralValue) {
  let CollateralValue { policy_id, asset_name, quantity } = collateral_value
  value.add(_, policy_id, asset_name, quantity)
}

validator(required_collateral: CollateralValue) {
  fn new_proposal(proposal: Proposal, context: ScriptContext) -> Bool {
    expect ScriptContext {
      transaction: Transaction { inputs, outputs, mint, .. },
      purpose: Mint(policy_id),
    } = context
    // for simplicity we take 0th output
    expect [proposal_output, ..] = outputs
    expect Output {
      value: proposal_value,
      datum: InlineDatum(proposal_datum),
      reference_script: None,
      address: proposal_address,
    } = proposal_output
    expect Proposal { owner, data }: Proposal = proposal_datum
    let proposal_id = builtin.serialise_data(builtin.head_list(inputs))
    and {
      bytearray.length(owner) == 28,
      ((
        proposal_value
          |> value.without_lovelace
      ) == (
        value.from_asset(policy_id, proposal_asset_name, 1)
          |> add_collateral_value(required_collateral)
      ))?,
      (proposal_address.payment_credential == ScriptCredential(policy_id))?,
      ((
        mint
          |> value.from_minted_value
          |> value.tokens(policy_id)
          |> dict.to_pairs
      ) == [Pair(proposal_asset_name, 1)])?,
    }
  }

  fn reclaim_collateral(
    datum: Proposal,
    redeemer,
    context: ScriptContext,
  ) -> Bool {
    expect ScriptContext {
      transaction: Transaction { extra_signatories, .. },
      purpose: Spend(input),
    } = context
    let proposal_accepted = True
    and {
      list.has(extra_signatories, datum.owner),
      proposal_accepted,
    }
  }
}
