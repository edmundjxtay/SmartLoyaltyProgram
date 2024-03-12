// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Strings.sol";

contract SmartLoyaltyProgram {
    
    address public contractOwner; //create public variable owner to store contract owner address
    uint256 public rewardCounter; //create public variable rewardCounter to store the number of rewards in the program
    

    // Mapping to store loyalty points balances for customers
    mapping(address => uint256) public loyaltyPoints;
    // Mapping to keep track of customers
    mapping(address => bool) public isCustomer;

    // Event function to log account creation
    event AccountCreated(address indexed customer, uint256 initialPoints);
    // Event function to log points earned
    event PointsEarned(address indexed customer, uint256 pointsEarned);
    // Event function to log points redeemed for a reward
    event PointsRedeemed(address indexed customer, uint256 pointsSpent, string reward);

    constructor() {
        contractOwner = msg.sender; // Set the contract creator as the owner
        rewardCounter = 1; // Initialize the reward counter
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only the owner can call this function");
        _;
    }

    // Modifier to restrict access to registered customers
    modifier onlyCustomer() {
        require(isCustomer[msg.sender], "You need to be a customer to perform this action");
        _;
    }

    // Function to allow customers to create an account
    function createAccount() public {
        require(!isCustomer[msg.sender], "Account already exists");//check if account already created
        isCustomer[msg.sender] = true;//set to true upon account created
        loyaltyPoints[msg.sender] = 100; // Initial 100 loyalty points
        emit AccountCreated(msg.sender, 100);//display account address and initial points
    }

    // Function for the owner to add a reward
    function addReward(string memory rewardDescription, uint256 pointCost) public onlyOwner {
        rewardCounter++;//increment counter
        emit PointsRedeemed(msg.sender, pointCost, rewardDescription);//display the reward added
    }

    // Function for customers to earn points
    function earnPoints(uint256 points) public onlyCustomer {
        loyaltyPoints[msg.sender] += points; //increment loyalty points
        emit PointsEarned(msg.sender, points);//display account address and points added
    }

    // Function to check a customer's loyalty point balance
    function checkPoints() public view onlyCustomer returns (uint256) {
        return loyaltyPoints[msg.sender];
    }

    // Function for customers to redeem points for a reward
    function redeemPoints(uint256 points, uint256 rewardId) public onlyCustomer {
        require(loyaltyPoints[msg.sender] >= points, "Not enough points to redeem this reward");//check if enough points to redeem
        require(rewardId <= rewardCounter, "Invalid reward ID");//check if reward id is valid

        loyaltyPoints[msg.sender] -= points;//deduct points upon successful redemption
        string memory rewardDescription = string(abi.encodePacked("Reward ID: ", Strings.toString(rewardId)));//retrieve the reward description
        emit PointsRedeemed(msg.sender, points, rewardDescription);//display points redeemed and what reward redeemed
    }
}