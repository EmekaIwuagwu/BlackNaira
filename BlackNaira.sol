// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlackNairaToken {
    string public name = "Black Naira";
    string public symbol = "BN";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "Invalid address");
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Not allowed to transfer this amount");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }
}

contract MoneyTransferApp {
    BlackNairaToken public token;
    mapping(address => string) public beneficiaryNames;
    mapping(address => bool) public beneficiaries;

    event BeneficiaryAdded(address indexed beneficiary, string name);
    event BeneficiaryDeleted(address indexed beneficiary);
    event AirtimePurchased(address indexed beneficiary, string mobileOperator, uint256 amount);

    constructor(uint256 initialSupply) {
        token = new BlackNairaToken(initialSupply);
    }

    modifier onlyBeneficiary() {
        require(beneficiaries[msg.sender], "You are not a beneficiary");
        _;
    }

    function addBeneficiary(address _beneficiary, string memory _name) public {
        require(!beneficiaries[_beneficiary], "Beneficiary already exists");
        require(bytes(_name).length > 0, "Name cannot be empty");

        beneficiaries[_beneficiary] = true;
        beneficiaryNames[_beneficiary] = _name;

        emit BeneficiaryAdded(_beneficiary, _name);
    }

    function listBeneficiaries() public view returns (address[] memory) {
        address[] memory beneficiaryList = new address[](totalBeneficiaries());
        uint256 index = 0;
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            if (beneficiaries[i]) {
                beneficiaryList[index] = i;
                index++;
            }
        }
        return beneficiaryList;
    }

    function totalBeneficiaries() public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            if (beneficiaries[i]) {
                count++;
            }
        }
        return count;
    }

    function deleteBeneficiary(address _beneficiary) public {
        require(beneficiaries[_beneficiary], "Beneficiary does not exist");

        delete beneficiaries[_beneficiary];
        delete beneficiaryNames[_beneficiary];

        emit BeneficiaryDeleted(_beneficiary);
    }

    function sendTokens(address _to, uint256 _amount) public onlyBeneficiary {
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Amount must be greater than zero");

        require(token.balanceOf(address(this)) >= _amount, "Insufficient contract balance");

        token.transfer(_to, _amount);
    }

    function returnTokens(uint256 _amount) public onlyBeneficiary {
        require(_amount > 0, "Amount must be greater than zero");

        require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance");

        token.transfer(address(this), _amount);
    }

    function buyAirtime(string memory _mobileOperator, uint256 _amount) public onlyBeneficiary {
        require(_amount > 0, "Amount must be greater than zero");

        // Implement airtime purchase logic here (e.g., interfacing with a third-party service)
        // For demonstration purposes, we'll simply emit an event indicating airtime purchase.

        emit AirtimePurchased(msg.sender, _mobileOperator, _amount);
    }

    // Allowance functions to approve the MoneyTransferApp contract to spend Black Naira tokens

    function approveTokenTransfer(address _spender, uint256 _amount) public onlyBeneficiary {
        require(_spender != address(0), "Invalid address");
        require(_amount > 0, "Amount must be greater than zero");

        token.approve(_spender, _amount);
    }

    function increaseAllowance(address _spender, uint256 _addedValue) public onlyBeneficiary {
        require(_spender != address(0), "Invalid address");
        require(_addedValue > 0, "Added value must be greater than zero");

        uint256 newAllowance = token.allowance(address(this), _spender) + _addedValue;
        token.approve(_spender, newAllowance);
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) public onlyBeneficiary {
        require(_spender != address(0), "Invalid address");
        require(_subtractedValue > 0, "Subtracted value must be greater than zero");

        uint256 currentAllowance = token.allowance(address(this), _spender);
        require(currentAllowance >= _subtractedValue, "Decreased allowance below zero");

        uint256 newAllowance = currentAllowance - _subtractedValue;
        token.approve(_spender, newAllowance);
    }
}
