// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract FlashLoan {
    address public owner;
    uint public fee = 9; // 0.09% fee (9 / 10000)

    event FlashLoanRequested(address indexed borrower, address token, uint amount, uint feePaid);
    event FundsReceived(address indexed sender, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }

    // Request a flash loan (ETH or tokens)
    function requestFlashLoan(address token, uint amount) external payable {
        uint balanceBefore;
        uint feeAmount = (amount * fee) / 10000;
        uint totalRepayment = amount + feeAmount;

        if (token == address(0)) { // For ETH
            balanceBefore = address(this).balance;
            require(balanceBefore >= amount, "Insufficient ETH balance");
            (bool sent, ) = msg.sender.call{value: amount}("");
            require(sent, "ETH transfer failed");
        } else { // For ERC-20 tokens
            balanceBefore = IERC20(token).balanceOf(address(this));
            require(balanceBefore >= amount, "Insufficient token balance");
            require(IERC20(token).transfer(msg.sender, amount), "Token transfer failed");
        }

        // Call the borrower's function to perform actions and repay
        (bool success, ) = msg.sender.call(
            abi.encodeWithSignature("executeFlashLoan(address,uint256,uint256)", token, amount, totalRepayment)
        );
        require(success, "Flash loan execution failed");

        // Verify repayment
        if (token == address(0)) {
            require(address(this).balance >= balanceBefore + feeAmount, "ETH not repaid");
        } else {
            require(IERC20(token).balanceOf(address(this)) >= balanceBefore + feeAmount, "Tokens not repaid");
        }

        emit FlashLoanRequested(msg.sender, token, amount, feeAmount);
    }

    // Withdraw funds by the owner
    function withdraw(address token, uint amount) external onlyOwner {
        if (token == address(0)) {
            (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "ETH withdrawal failed");
        } else {
            require(IERC20(token).transfer(msg.sender, amount), "Token withdrawal failed");
        }
    }

    // Check the contract's balance
    function getBalance(address token) external view returns (uint) {
        if (token == address(0)) {
            return address(this).balance;
        } else {
            return IERC20(token).balanceOf(address(this));
        }
    }
}