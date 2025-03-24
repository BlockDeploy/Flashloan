Instructions for Using FlashLoan
Description: FlashLoan is a basic Solidity 0.6.6 contract for flash loans,
enabling borrowing of ETH or ERC-20 tokens without collateral for arbitrage and DeFi strategies on Ethereum Mainnet.
The loan is granted on the condition that you repay the amount plus a 0.09% fee within the same transaction, or it reverts.
How it works: You call requestFlashLoan, specifying the token and amount. The contract sends you the
funds, you use them (e.g., for a DEX swap), and then repay with the fee via the executeFlashLoan function in your
contract. This is a popular DeFi tool as of March 2025.
Advantages: No collateral required, instant execution, supports ETH and ERC-20, easy to integrate.
What it offers: The ability to profit from price differences or other operations without initial capital.

Compilation: Go to the "Deploy Contracts" page in BlockDeploy,
paste the code into the "Contract Code" field (it uses the IERC20 interface for tokens),
select Solidity version 0.6.6 from the dropdown menu,
click "Compile" — the "ABI" and "Bytecode" fields will populate automatically.

Deployment: In the "Deploy Contract" section:
- Select the "Ethereum (Mainnet)" network,
- Enter the private key of a wallet with ETH to pay for gas in the "Private Key" field,
- The constructor requires no parameters, click "Deploy",
- Review the network and fee in the modal window and confirm.
After deployment, you’ll get the contract address (e.g., 0xYourFlashLoanAddress) in the BlockDeploy logs.

How to Use FlashLoan:

Fund the Contract: Send ETH or ERC-20 tokens (e.g., DAI: 0x6B175474E89094C44Da98b954EedeAC495271d0F)
to the contract address (0xYourFlashLoanAddress) via MetaMask or another wallet.
Create a Borrower: Write your own contract with the function executeFlashLoan(address token, uint amount, uint totalRepayment),
where you implement your strategy (e.g., arbitrage) and repay the amount plus the fee.
Request a Loan: From your contract, call requestFlashLoan,
specifying the token (0x0 for ETH or the token address) and amount (e.g., 1000000000000000000 for 1 ETH).
Repay the Loan: In executeFlashLoan, send back the tokens or ETH to the contract
(amount + 0.09%, e.g., 1.009 ETH for a 1 ETH loan).
Check Balance: Call getBalance,
specifying the token address (or 0x0 for ETH), to see the current liquidity pool.
Withdraw Funds: The owner can call withdraw,
specifying the token and amount, to retrieve accumulated fees or remaining funds.
Example Workflow:
- You send 10 ETH to the contract.
- Your contract calls requestFlashLoan(0x0, 10000000000000000000) (10 ETH).
- In executeFlashLoan, you swap 10 ETH for DAI on Uniswap, then back to 10.2 ETH on Sushiswap.
- You repay 10.009 ETH (10 + 0.09% fee), keeping 0.191 ETH as profit.
The contract receives the fee, and you earn profit without initial capital.
