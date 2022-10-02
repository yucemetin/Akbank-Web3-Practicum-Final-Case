// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract Atm {
    mapping(address => uint) userWallet;
    
    enum Status {
        Login,
        Logout
    }
    
    struct Users {
        address walletAddress;
        Status status;
    }

    Users[] public users;

    event Login(address indexed user, Status status);
    event Logout(address indexed user, Status status);

    function login() public {
        bool isLogin;
        Status tmp;
        for(uint i = 0; i < users.length; i++) {
           if( users[i].walletAddress == msg.sender) {
               isLogin = true;
               users[i].status = Status.Login;
               tmp = users[i].status;
           } else {
               isLogin = false;
           }
        }

        if(!isLogin) {
            users.push(Users(msg.sender,Status.Login));  
        }

        emit Login(msg.sender,tmp);
       
    }

    function logout(uint _userId) public {
        users[_userId].status = Status.Logout;
        emit Logout(users[_userId].walletAddress,users[_userId].status);
    }

    function sendEther() external payable {
        userWallet[msg.sender] += msg.value;
        
    }

    function withdraw(uint _userId, uint amount) checkUserLogin(_userId) checkOwner(_userId) checkBalanceAndAmount(amount)  external returns(bool) {
        (bool sent,) = payable(users[_userId].walletAddress).call{value: amount}("");
        if(sent) {
            userWallet[msg.sender] -= amount;
        }
       
        return sent;
    }

    function checkUserWallet(uint _userId) checkUser(_userId) external view returns(uint) {
        return userWallet[users[_userId].walletAddress];
    }

    function checkUserStatus(uint _userId) checkUser(_userId) external view returns(Status) {
        return users[_userId].status;
    }

    modifier checkUser(uint _userId) {
        require(_userId < users.length, "Gecersiz kullanici numarasi!!");
        _;
    }

    modifier checkOwner(uint _userId) {
        require(users[_userId].walletAddress == msg.sender,"Baskasinin parasini cekemezsiniz!!");
        _;
    }

    modifier checkBalanceAndAmount(uint _amount) {
        require(userWallet[msg.sender] >= _amount, "Bakiyenizden fazla para cekemezsiniz!!");
        _;
    }

    modifier checkUserLogin(uint _userId) {
        require(users[_userId].status == Status.Login, "Giris yapmaniz gerekiyor.");
        _;
    }
}