## SUBJECT
--------------------------------------
UnderFlow/OverFlow
--------------------------------------
Awesome — you’re asking exactly the right questions if you want to become a serious smart contract developer!  
Let's dive deep into **Integer Overflows and Underflows** in Solidity, from **beginner** to **advanced** level — step-by-step. 🚀

---

# 🧠 1. What Are Integer Overflows and Underflows?

Solidity deals with **fixed-size integers**, like `uint8`, `uint256`, etc.

| Type    | Range |
|---------|-------|
| `uint8` | 0 to 255 |
| `uint256` | 0 to 2^256 - 1 |

Because of this **fixed size**, integers can **overflow** or **underflow** if you go beyond their limit.

---

## ⚡️ Overflow Example

Suppose you have:

```solidity
uint8 a = 255;
a = a + 1; 
```

Expected value: 256? ❌  
Actual value: **0**! ⚠️

👉 It **wraps around** back to 0.

---

## ⚡️ Underflow Example

```solidity
uint8 b = 0;
b = b - 1;
```

Expected value: -1? ❌  
Actual value: **255**! ⚠️

👉 It **wraps around** to the maximum value.

---

# ⚠️ 2. Why Are Overflows/Underflows Dangerous?

Attackers can **exploit** this behavior to **manipulate balances, counters, votes, shares, etc.**  
This leads to **loss of funds**, broken protocols, and vulnerabilities.

For example:  
If a smart contract does:

```solidity
balances[msg.sender] -= amount;
```

and the attacker triggers an **underflow**, suddenly their balance becomes **huge**.

They can **withdraw** or **transfer** massive fake balances.

---

# 🧱 3. Historical Real Hack Example

In 2018, an ERC20 token called **BECToken** was hacked because of an underflow bug:  
An attacker **created trillions of tokens** from **zero** by exploiting underflow.

They called `transfer()` in such a way that their balance became massive, and drained the contract.

**Millions of dollars** were lost.

---

# 🛡 4. How Solidity Handles Overflows Now

Starting from **Solidity 0.8.0**, **overflow and underflow automatically revert** the transaction. ✅

Example:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeMathExample {
    function testOverflow() public pure returns (uint8) {
        uint8 a = 255;
        a = a + 1; // 🚫 Reverts automatically
        return a;
    }
}
```

⚡️ No manual checking needed — if overflow happens, **execution fails** immediately.

---

# 📜 5. Pre-0.8.0 — How Developers Handled It Before

Before Solidity 0.8.0, people had to **manually protect** against overflows/underflows.

They used a library called **SafeMath**:

```solidity
using SafeMath for uint256;

uint256 c = a.add(b); // Automatically checks for overflow
```

SafeMath internally would do:

```solidity
function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "Addition Overflow");
    return c;
}
```

But now **you don’t need SafeMath** anymore if you’re using Solidity 0.8.0 or later! 🎉

---

# 🛠 6. Advanced Techniques and Situations

✅ Solidity 0.8.0 also provides **unchecked blocks** when you **want to allow** overflow for gas optimization:

```solidity
pragma solidity ^0.8.0;

contract UncheckedExample {
    function addUnchecked(uint256 a, uint256 b) public pure returns (uint256) {
        unchecked {
            return a + b; // No overflow check to save gas
        }
    }
}
```

**Use carefully**: only where you are 100% sure overflow is impossible.

Example: Loop counters.

---

# 📚 7. Summary Table

| Concept         | Solidity <0.8.0 | Solidity >=0.8.0 |
|-----------------|------------------|------------------|
| Overflows happen? | ✅ Yes | ❌ No (reverts) |
| Need SafeMath? | ✅ Yes | ❌ No |
| Can manually allow overflow? | ❌ No | ✅ Yes (with `unchecked`) |

---

# 🚀 8. Key Takeaways

- Overflow = going above max → wrap to 0
- Underflow = going below 0 → wrap to max
- Before Solidity 0.8.0: **dangerous**, needed **SafeMath**
- After Solidity 0.8.0: **automatic safety** by default
- Use `unchecked` **only** when you're sure it's safe
- Attacks exploiting overflow have happened **many times** in history!

---

# 🎯 Quick Quiz for You (to be a real pro):

1. What happens if you add 1 to a `uint256` at its maximum value today?
2. Why might you still use `unchecked` even though overflow protection exists?
3. What kind of smart contracts should be extremely careful with overflow/underflow bugs?


---

## SUBJECT
--------------------------------------
DOS attack
--------------------------------------

Alright! 🔥  
You’re asking the right things — "Denial-of-Service (DoS) risks" are **super important** if you want to become an *expert Solidity developer*.  
Let’s break it down from **beginner to advanced**, step-by-step.

---

# 🛑 1. What is Denial-of-Service (DoS)?

In general, **DoS = making a system unavailable**.

In **smart contracts**, **Denial-of-Service** means:
- Making a smart contract **stuck**, **blocked**, or **unusable**.
- Preventing **others** from using the contract **normally**.
- Sometimes **no money gets stolen**, but **nobody can interact anymore** (which can be catastrophic).

---

# 🧠 2. Common Types of DoS Attacks in Solidity

There are a few classic DoS attack patterns you need to know:

| Type | Description | Example |
|-----|------------|---------|
| Gas Limit Attack | Force the contract to use too much gas, making it fail. | A loop grows infinitely and breaks execution. |
| Revert Attack | Cause a function to revert intentionally. | A critical function keeps failing forever. |
| Blocking Attack | Take an important slot/resource and refuse to release it. | Locking a winning prize or auction. |

---

# ⚡ 3. Classic Real-World Examples

## Example 1: DoS with **Revert in External Call**
Imagine a simple reward system:

```solidity
function payout() public {
    for (uint i = 0; i < winners.length; i++) {
        winners[i].call{value: rewardAmount}("");
    }
}
```

🚨 Problem:
- If even **ONE** `winners[i]` is a malicious contract that **reverts** during `call()`, 
- The **entire payout** loop **breaks**.
- None of the remaining winners get paid.

This is called **Griefing**.

---

## Example 2: DoS with **Blocklist**
Auction contract:

```solidity
function bid() public payable {
    require(msg.value > highestBid, "Bid too low");
    if (highestBidder != address(0)) {
        payable(highestBidder).transfer(highestBid);
    }
    highestBid = msg.value;
    highestBidder = msg.sender;
}
```

🚨 Problem:
- What if the current `highestBidder` is a contract that **refuses** to accept ETH (reverts on `transfer`)?
- Then `payable(highestBidder).transfer(highestBid);` will **fail**, and **nobody can outbid** anymore!

**Auction gets permanently frozen**!

---

# 🛡 4. How to Protect Against DoS Risks

✅ **Pull over Push Payments**  
Instead of pushing ETH to winners immediately (push pattern),  
you let winners **come and claim** their rewards themselves (pull pattern).

Example:

```solidity
mapping(address => uint) public pendingWithdrawals;

function payout() public {
    for (uint i = 0; i < winners.length; i++) {
        pendingWithdrawals[winners[i]] += rewardAmount;
    }
}

function withdraw() public {
    uint amount = pendingWithdrawals[msg.sender];
    pendingWithdrawals[msg.sender] = 0;
    payable(msg.sender).transfer(amount);
}
```

✅ **Careful with External Calls**  
- **Always put external calls at the end** of the function.
- **Always handle errors** properly.
- **Use `call` instead of `transfer` or `send`** in newer Solidity (but check success manually).

✅ **Limit Looping Based on State**  
- If you're looping over arrays, **limit** the number of iterations.
- Avoid growing arrays infinitely.

✅ **Use "Pull-Based" Winner Patterns** in Auctions and Contests.

✅ **Design for Partial Failures**  
- Don't let one malicious participant break the entire system.

---

# 🎯 5. Advanced DoS Concepts

## A. Gas Limit DoS (Especially on Loops)
Smart contracts have a **block gas limit** (e.g., 30M gas per block).

If your contract loops over a **very large list** (like thousands of users),  
the gas may exceed the block limit → transaction will **always fail**.

Advanced Safe Pattern:
- Use **pagination** or **batch processing**.
- Process **small parts** of data in multiple transactions.

## B. Storage Lock DoS
A malicious user could store huge data (or create huge mappings) inside your contract.
Result:  
- Reading data becomes very expensive.
- Gas prices become unbearable.

Advanced mitigation:
- Limit user-created mappings.
- Charge fees for storage-heavy actions.

---

# 💀 6. Real Case Study: King of the Ether Throne (Old 2016 Contract)

**The King contract** would reward whoever sent the most ETH by making them the "King".

But someone deployed a contract that **refused to accept ETH** when they were dethroned!

Result:  
- Nobody could ever claim the throne after them.
- Contract permanently broken.
- **Millions stuck**.

---

# 🛠 7. Quick Checklist for DoS-Proof Smart Contract Development

✅ Avoid writing loops over dynamic arrays without limits.  
✅ Always use **pull payment** models when transferring ETH or tokens.  
✅ Handle failed external calls gracefully — **do not revert whole function**.  
✅ Keep critical functions **minimal**, **simple**, and **non-external dependent**.  
✅ Always audit fallback functions of external contracts you're interacting with.  
✅ Always assume **external contracts are malicious**.

---

# 📚 8. Quick Example of a Safe Pattern for Payouts

```solidity
function distributeRewards(address[] memory recipients, uint amount) public onlyOwner {
    for (uint i = 0; i < recipients.length; i++) {
        pendingWithdrawals[recipients[i]] += amount;
    }
}

function withdrawRewards() public {
    uint amount = pendingWithdrawals[msg.sender];
    require(amount > 0, "No rewards");
    pendingWithdrawals[msg.sender] = 0;
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent, "Failed to send Ether");
}
```

This way:
- Even if one user refuses to withdraw or has a broken wallet, **it doesn't affect anyone else**.
- Gas usage is manageable.
- Failures are isolated.

---

# 🎯 Quick Summary

👉 DoS attacks = making contracts unusable.  
👉 Main causes = external calls, looping too much, revert attacks.  
👉 Main solution = **pull payments**, **safe design**, **limit loops**.  
👉 **Assume external addresses/contracts can be hostile.**  
👉 Always protect gas, avoid giant storage explosions, and make critical functions fail-safe.

---

# 🔥 Tiny Brain Challenge For You:

**Question:**  
Suppose you're designing a DeFi prize pool.  
Would you pay winners automatically, or let them claim manually? Why?


## SUBJECT
--------------------------------------
Unchecked external calls
--------------------------------------
Alright, let's dive into **Unchecked External Calls** in Solidity.  
I'll explain it from beginner to advanced, nice and clear. 🧠✨

---

## 🌟 What Are External Calls in Solidity?

In Solidity, when your smart contract **calls** another **external** address (whether a user wallet or another contract), you are doing an **external call**.

You can make an external call using:
- `.transfer()`
- `.send()`
- `.call()`

Example:
```solidity
(bool success, ) = otherContractAddress.call{value: 1 ether}("");
require(success, "Transfer failed");
```

---

## ⚡ What Is an *Unchecked* External Call?

An **unchecked external call** means:

- You call another address or contract.
- You **don't** check if the call **succeeded** or **failed**.
- You **continue execution** regardless of what happened.

🚨 **Danger:** If the external call fails and you don't check, your contract may behave incorrectly, lose funds, or be vulnerable to attack.

Example of a BAD unchecked call:
```solidity
recipient.call{value: amount}(""); // ❌ No success check
```

This code **does not check** if `call` returned `true` (success) or `false` (fail)!  
So even if sending money fails, your contract **thinks everything is fine** and keeps going.

---

## 📛 Why Is This Dangerous?

- **Fund loss:** You might think you've paid someone, but payment failed.
- **Logic break:** You may update important state based on a failed action.
- **Attack surface:** Attackers can exploit this to **mess up your contract's behavior**.

---

## ✅ How to Handle External Calls Safely

👉 Always **check the success** of an external call!

Safe way:
```solidity
(bool success, ) = recipient.call{value: amount}("");
require(success, "ETH transfer failed");
```

- If sending ETH fails, `require` will revert the transaction.
- Your contract won't continue execution with bad assumptions.

---

## 🧠 Real-World Problems from Unchecked External Calls

1. **DAO Hack (2016)** — unchecked external behavior contributed to the massive DAO exploit.
2. **Auction Contracts:** Like you learned earlier — if refunding ETH to a bidder fails and isn't handled properly, it **freezes the auction** forever!

---

## 🔥 Advanced Techniques: Pull Payments

Instead of sending ETH immediately (risky), a **more advanced and safer** pattern is:
- Record the amount **owed** to a user.
- Let the user **withdraw** it themselves.

Example:
```solidity
mapping(address => uint) public pendingWithdrawals;

function bid() public payable {
    require(msg.value > highestBid, "Bid too low");

    if (highestBidder != address(0)) {
        pendingWithdrawals[highestBidder] += highestBid;
    }

    highestBid = msg.value;
    highestBidder = msg.sender;
}

function withdraw() public {
    uint amount = pendingWithdrawals[msg.sender];
    require(amount > 0, "Nothing to withdraw");

    pendingWithdrawals[msg.sender] = 0;
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Withdraw failed");
}
```

✅ This pattern **protects** your contract from external call failures.

---

## 🧩 Summary

| Concept                | Safe? | Notes                                    |
|-------------------------|-------|-----------------------------------------|
| `.transfer()`           | ✅    | Safe but has 2300 gas limit.             |
| `.send()`               | 🚫    | You must manually check success.         |
| `.call{value:}`          | ✅    | Safe IF you manually check success.      |
| Unchecked external call | 🚫    | Very dangerous! Never skip success checks. |
| Pull Payment pattern    | ✅✅   | Very safe. Recommended for ETH refunds.  |

---


## SUBJECT
--------------------------------------
upgradeable contracts & Upgradeability flaws (if relevant)
--------------------------------------

explained In a different Repo

https://github.com/arefanafgeh/upgradablecontract

## SUBJECT
--------------------------------------
Logic errors or overlooked edge cases
--------------------------------------

Great — let’s now dive deep into **logic errors and overlooked edge cases** in Solidity smart contracts. These issues are **not compiler errors** or **security vulnerabilities per se**, but are often **the root cause of exploits**, **funds being locked**, or **protocols behaving incorrectly**.

---

## 🔍 What Are Logic Errors?

Logic errors are **mistakes in the developer’s reasoning or assumptions** about how the code works or should behave. These bugs **don’t throw errors during compilation** or basic testing but often appear:

* In production (when edge cases hit)
* Under specific inputs, states, or ordering of transactions
* With interaction between contracts or users

---

# ⚠️ Common Logic Errors & Overlooked Edge Cases

---

## 1. 🧮 Incorrect Assumptions About Arithmetic

### ❌ Mistake:

```solidity
function withdraw(uint256 amount) external {
    require(balance[msg.sender] >= amount, "Insufficient");
    balance[msg.sender] -= amount;
    payable(msg.sender).transfer(amount);
}
```

### ✅ What’s Wrong?

If another contract calls this in a reentrant fashion, balance gets deducted **after** the transfer — classic **reentrancy logic flaw**, even without `.call`.

Also:

* Doesn’t handle `amount == 0`
* No `nonReentrant` protection

---

## 2. 🔁 Infinite Loop Risk with Dynamic Arrays

### ❌ Mistake:

```solidity
address[] public users;

function clearAllUsers() external onlyOwner {
    for (uint256 i = 0; i < users.length; i++) {
        delete users[i];
    }
}
```

### ✅ What’s Wrong?

* If `users.length > 1000`, gas will exceed block limit = function fails forever.
* Funds or access can get locked if system depends on this.

✅ Use **pagination** or batch deletions.

---

## 3. 💸 Funds Getting Stuck (Poor Withdraw Logic)

### ❌ Mistake:

```solidity
function claim() external {
    require(claimable[msg.sender] > 0, "Nothing to claim");
    uint256 amount = claimable[msg.sender];
    claimable[msg.sender] = 0;
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent, "Transfer failed");
}
```

### ✅ What’s the Edge Case?

* **If `msg.sender` is a contract with fallback that reverts**, claim fails and user can **never claim again**
* Funds get stuck permanently unless admin writes a rescue

✅ Use a pull-based model with optional rescue logic

---

## 4. ⏳ Timestamp Misuse

### ❌ Mistake:

```solidity
if (block.timestamp % 2 == 0) {
    // Give reward
}
```

### ✅ What’s the Issue?

* `block.timestamp` is **manipulatable by miners** within \~15 seconds.
* Using it in critical logic (lottery, randomness, betting) can be **gamed**.

✅ Use verifiable randomness or commit-reveal for time-sensitive features.

---

## 5. 🧊 Forgotten Initialization

### ❌ Mistake:

```solidity
contract MyUpgradeable is Ownable {
    function initialize() external {
        owner = msg.sender;
    }
}
```

### ✅ What’s Wrong?

* If `initialize()` is public/external and not `initializer`, **anyone can call it** first.
* Massive risk in upgradeable contracts where constructors don’t run.

✅ Always use `initializer` modifier and OpenZeppelin's `Initializable`

---

## 6. 🧱 Incorrect Storage Layout in Upgrades

### ❌ Mistake:

```solidity
// V1
uint256 public count;

// V2
uint256 public count;
bool public isEnabled;
```

Then upgrade to V2 → storage layout corrupts!

✅ Use **fixed storage slot layout** with a shared struct and **never change order** unless you fully understand storage layout.

---

## 7. 🔄 Reuse of `msg.sender`/`tx.origin` in MetaTx or Contracts

### ❌ Mistake:

```solidity
function isAdmin() public view returns (bool) {
    return admins[tx.origin];
}
```

### ✅ Problem:

* `tx.origin` traverses all calls — can be **spoofed in phishing attacks**
* Breaks in **Meta Transactions** or **contract-to-contract calls**

✅ Use `msg.sender`, never `tx.origin` for authentication.

---

## 8. 🧾 Trusting Return Values

### ❌ Mistake:

```solidity
token.transfer(to, amount); // ERC20
```

### ✅ What's Wrong?

* Many tokens like USDT **don’t return a boolean**
* Or **return false instead of revert** on failure

✅ Always check:

```solidity
require(token.transfer(to, amount), "Transfer failed");
```

Or better: use `SafeERC20` from OpenZeppelin.

---

## 9. 🔗 External Calls Without Error Bubbling

### ❌ Mistake:

```solidity
(bool success, bytes memory data) = someContract.call(abi.encodeWithSelector(...));
require(success);
```

### ✅ What’s the Edge Case?

* You lose the **original revert reason**. No debugging or visibility.
* Makes audits and dev time worse.

✅ Use:

```solidity
if (!success) {
    assembly {
        revert(add(data, 32), mload(data))
    }
}
```

---

## 10. ⏱ Time-Based Features That Can Never Trigger

### ❌ Example:

```solidity
function unlock() public {
    require(block.timestamp > startTime + 365 days, "Too early");
}
```

### ✅ Problem:

* If `startTime` is never set, or accidentally set in the future, unlocks never happen.

✅ Always validate inputs & provide emergency mechanisms.

---

## ⚒ Real-World Bug Inspired By Logic Error

### 🎯 YAM Protocol Bug (2020)

```solidity
// storage overwritten during rebase (logic error)
totalSupply = totalSupply + delta;
```

Problem: `delta` was too large, resulting in an overflow **despite using SafeMath**, because it was inside an `unchecked` block (Solidity 0.6.x).

Result: **\$750,000+** lost.

---

## ✅ Best Practices to Prevent Logic Errors

* ✅ **Unit + Fuzz Testing** with tools like Foundry
* ✅ Use `assert()` for invariants
* ✅ Add `require()` for all assumptions
* ✅ Avoid external calls in the middle of function logic
* ✅ Always validate user inputs and contract states
* ✅ Code audits + code reviews
* ✅ Have a well-documented fallback/emergency plan (e.g., `sweepFunds()`)

---

Now codes with fixes:


Perfect. Let’s now walk through **each of the logic error examples** and show the correct **solution code snippets** alongside the explanation. This way, you can directly apply or test the improvements.

---

## **1. Reentrancy Risk Due to Wrong Order**

### ❌ Buggy Code:

```solidity
function withdraw(uint256 amount) external {
    require(balance[msg.sender] >= amount, "Insufficient");
    balance[msg.sender] -= amount;
    payable(msg.sender).transfer(amount);
}
```

### ✅ Fixed Code (Proper order + protection):

```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

function withdraw(uint256 amount) external nonReentrant {
    require(balance[msg.sender] >= amount && amount > 0, "Invalid amount");
    
    balance[msg.sender] -= amount;
    
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent, "Transfer failed");
}
```

---

## **2. Infinite Loop in Large Arrays**

### ❌ Buggy Code:

```solidity
for (uint256 i = 0; i < users.length; i++) {
    delete users[i];
}
```

### ✅ Fixed Code (Batch clearing with pagination):

```solidity
uint256 public clearIndex;

function clearUsersBatch(uint256 batchSize) external onlyOwner {
    for (uint256 i = 0; i < batchSize && clearIndex < users.length; i++) {
        delete users[clearIndex];
        clearIndex++;
    }
}
```

---

## **3. Funds Get Stuck If Transfer Fails**

### ❌ Buggy Code:

```solidity
claimable[msg.sender] = 0;
(bool sent, ) = msg.sender.call{value: amount}("");
require(sent, "Transfer failed");
```

### ✅ Fixed Code (Pull-based + fallback):

```solidity
function claim() external {
    uint256 amount = claimable[msg.sender];
    require(amount > 0, "Nothing to claim");

    claimable[msg.sender] = 0;

    (bool success, ) = msg.sender.call{value: amount}("");
    if (!success) {
        // Refund to fallback address or log for manual rescue
        emit ClaimFailed(msg.sender, amount);
        claimable[msg.sender] = amount;
    }
}
```

---

## **4. Timestamp Manipulation**

### ❌ Buggy Code:

```solidity
if (block.timestamp % 2 == 0) {
    // Give reward
}
```

### ✅ Fixed Code (Avoid timestamp reliance):

Use **Chainlink VRF** or **commit-reveal pattern** for fair randomness.

Or:

```solidity
// Use blockhash with user seed (not perfect, but better)
function getPseudoRandom(uint256 userSeed) internal view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender, userSeed)));
}
```

---

## **5. Unprotected Initialization**

### ❌ Buggy Code:

```solidity
function initialize() external {
    owner = msg.sender;
}
```

### ✅ Fixed Code (Using OpenZeppelin `Initializable`):

```solidity
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MyUpgradeable is Initializable, OwnableUpgradeable {
    function initialize() public initializer {
        __Ownable_init(); // Optional: for OZ's OwnableUpgradeable
    }
}
```

---

## **6. Storage Layout Changes in Upgrades**

### ❌ Buggy Upgrade:

```solidity
// V2 accidentally shifts layout
uint256 public count;
bool public isEnabled;
```

### ✅ Fixed Code (Storage gap or consistent struct):

```solidity
// V1
contract V1 {
    uint256 public count;
    uint256[49] private __gap; // Reserve space
}

// V2
contract V2 {
    uint256 public count;
    bool public isEnabled;
    uint256[48] private __gap;
}
```

✅ Or use **Diamond Storage** (struct in a known slot) for large upgrades.

---

## **7. Misusing `tx.origin`**

### ❌ Buggy Code:

```solidity
function isAdmin() public view returns (bool) {
    return admins[tx.origin];
}
```

### ✅ Fixed Code:

```solidity
function isAdmin() public view returns (bool) {
    return admins[msg.sender];
}
```

✅ Also supports MetaTx and proxies better.

---

## **8. Not Checking Return Value**

### ❌ Buggy Code:

```solidity
token.transfer(to, amount);
```

### ✅ Fixed Code:

```solidity
require(token.transfer(to, amount), "Transfer failed");
```

✅ Or using OpenZeppelin:

```solidity
using SafeERC20 for IERC20;

token.safeTransfer(to, amount);
```

---

## **9. Losing Original Error Message from External Call**

### ❌ Buggy Code:

```solidity
require(success);
```

### ✅ Fixed Code (Bubble revert reason):

```solidity
(bool success, bytes memory data) = someContract.call(...);
if (!success) {
    assembly {
        revert(add(data, 32), mload(data))
    }
}
```

---

## **10. Time-based Unlocks That Might Never Trigger**

### ❌ Buggy Code:

```solidity
require(block.timestamp > startTime + 365 days, "Too early");
```

### ✅ Fixed Code:

```solidity
require(startTime > 0 && block.timestamp > startTime + 365 days, "Not unlocked");
```

✅ Add emergency override:

```solidity
function emergencyUnlock() external onlyOwner {
    startTime = block.timestamp - 366 days;
}
```

---



## SUBJECT
--------------------------------------
Timestamp dependence / block manipulation
--------------------------------------

