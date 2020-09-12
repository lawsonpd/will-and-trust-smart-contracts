# will-smart-contract
Solidity smart contract that performs the basic function of a will.

This contract allows the owner (a benefactor or power of attorney) to store funds in a will and add beneficiaries who can withdraw the funds when the will is active. 

After the contract is deployed, the owner has the following functions available through the interface:

* add beneficiaries

* deposit funds

* activate will

Beneficiaries are added using their addresses, one at a time.

Funds can be added as many times as wanted. The exception is that after the will has been activated - meaning the funds are available for withdrawal by the beneficiaries - funds can no longer be deposited. This makes sense from a practical standpoint, but also it avoids any complicated logic in the case where some beneficiaries have withdrawn funds already and others have not (meaning the allocation would need to be recalculated with that in mind).

There are a number of checks to ensure that relevant functionality is only available to the owner or the beneficiary making a call. For example, only the owner can activate the will and only the beneficiary can see their own balance.

In this simple will implementation, a withdrawal can be made only once and all of the allotted funds are transferred in a lump sum to the beneficiary (msg.sender) making the withdrawal. This implementation also automatically divides the funds equally among beneficiaries. Since Solidity doesn't yet have full support for floating point values, it was difficult to design a way for the owner to specify a unique percentage for each beneficiary.
