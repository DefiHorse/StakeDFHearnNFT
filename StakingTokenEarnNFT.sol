// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./lib/NFTPacks.sol";

contract StakingDFHEarnNFT is Pausable, Ownable, ERC721Holder, StakingOptionsNFT, ReentrancyGuard {

    struct userInfoStaking {
        bool isActive;
        uint256 amountStakedToken;
        uint256 startTime;
        uint256 endTime;
        uint256 stakeOptions;
        uint256 fullLockedDays;
        uint256 rewardAmountNFT;
        address contractNFT;
    }

    struct userInfoTotal{
        uint256 totalUserStaked; 
        uint256 totalUserReward;
        uint256 totalUserRewardClaimed;
    }

    ERC20 public token;
    mapping(bytes32 => userInfoStaking) private infoStaking;
    mapping(address => userInfoTotal) private infoTotal;
    mapping(address => uint) public countNFTs;

    event UsersStaking(address indexed user, uint256 indexed option, uint256 id);
    event UserUnstaking(address indexed user, uint256 claimableAmountStake, uint256 indexed option, uint256 indexed id);
    event UserClaimNFTReward(address indexed user, uint256 claimableReward, uint256 indexed option, uint256 indexed id);

    uint256 public totalStaked = 0;
    uint256 public totalClaimedReward = 0;
    uint256 public totalAccumulatedRewardsReleased = 0;

    constructor(ERC20 _token) 
    {
        token = _token;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    
    function userStake(uint256 _ops, uint256 _id) public whenNotPaused nonReentrant {
        bytes32 _value = keccak256(abi.encodePacked(_msgSender(), _ops, _id));
        require(infoStaking[_value].isActive == false, "UserStake: Duplicate id");
        OptionsStaking memory options = infoOptions[_ops];
        require(options.startTime <= block.timestamp, "UserStake: This Event Not Yet Start Time");
        require(block.timestamp <= options.endTime, "UserStake: This Event Over Time");

        uint256 _amountStake = options.amountStakedToken;
        token.transferFrom(msg.sender, address(this), _amountStake);

        uint256 _lockDay =  options.lockDays;
        uint256 _endTime = block.timestamp + _lockDay;
        uint256 _amountReward = options.rewardAmountNFT;
        address _contractNFT = options.contractsNFT;
        userInfoStaking memory info =
                userInfoStaking(
                    true, 
                    _amountStake,
                    block.timestamp,
                    _endTime, 
                    _ops,
                    _lockDay,
                    _amountReward,
                    _contractNFT
                );
            infoStaking[_value] = info;

        totalStaked = totalStaked + _amountStake;
        totalAccumulatedRewardsReleased = totalAccumulatedRewardsReleased + _amountReward;
        countNFTs[_contractNFT] = countNFTs[_contractNFT] + _amountReward;
        emit UsersStaking(msg.sender, _ops, _id);

        userInfoTotal storage infoTotals  = infoTotal[_msgSender()];
        infoTotals.totalUserStaked = infoTotals.totalUserStaked + _amountStake;
        infoTotals.totalUserReward = infoTotals.totalUserReward + _amountReward;
    }

    function userUnstake(uint256 _ops, uint256 _id) public nonReentrant {
        bytes32 _value = keccak256(abi.encodePacked(_msgSender(), _ops,_id));
        userInfoStaking storage info = infoStaking[_value];

        require(info.isActive == true, "UnStaking: Not allowed unstake two times");
        uint256 claimableTokenToken = _calcClaimableToken(_value);
        require(claimableTokenToken > 0, "Unstaking: Nothing to claim");

        token.transfer(msg.sender,claimableTokenToken);

        emit UserUnstaking(msg.sender, claimableTokenToken, _ops, _id);
        OptionsStaking memory options = infoOptions[_ops];
        info.endTime = block.timestamp + options.lockRewardDays;
        info.isActive = false;
    }

    function _calcClaimableToken(bytes32 _value)
        internal
        view 
        returns(uint256 claimableTokenToken)
    {
        userInfoStaking memory info = infoStaking[_value];
        if(!info.isActive) return 0;
        if(block.timestamp < info.endTime) return 0;
        claimableTokenToken = info.amountStakedToken;
    }

    function claimReward(uint256 _ops, uint256 _id) public nonReentrant {
        bytes32 _value = keccak256(abi.encodePacked(_msgSender(), _ops,_id));
        userInfoStaking storage info = infoStaking[_value];
        uint256 _amountRewardedNFT = info.rewardAmountNFT;
        address _contractNFT = info.contractNFT;

        require(info.endTime <= block.timestamp, "ClaimReward: Nothing to claim");
        require(_amountRewardedNFT > 0, "ClaimReward: Nothing to claim");

        for (uint256 i = 0; i < _amountRewardedNFT; i++) {
            uint256 _tokenId = IERC721Enumerable(_contractNFT).tokenOfOwnerByIndex(address(this), 0);
            IERC721(_contractNFT).safeTransferFrom(address(this), msg.sender, _tokenId);
        }
        info.rewardAmountNFT = 0;

        totalClaimedReward = totalClaimedReward + _amountRewardedNFT;

        userInfoTotal storage infoTotals  = infoTotal[_msgSender()];
        infoTotals.totalUserRewardClaimed = infoTotals.totalUserRewardClaimed + _amountRewardedNFT;

        emit UserClaimNFTReward(msg.sender,_amountRewardedNFT, _ops, _id);

    }


    function getInfoUserTotal(address account)
        public 
        view 
        returns (uint256,uint256) 
    {
        userInfoTotal memory info = infoTotal[account];
        return (info.totalUserStaked,info.totalUserReward);
    }

    function getInfoUserStaking(
        address account,
        uint256 _ops,
        uint256 _id
    )
        public
        view 
        returns (bool, uint256, uint256, uint256, uint256, uint256, uint256, address)
    {
        bytes32 _value = keccak256(abi.encodePacked(account, _ops,_id));
        userInfoStaking memory info = infoStaking[_value];       
        return (
            info.isActive,
            info.amountStakedToken,
            info.startTime,
            info.endTime,
            info.stakeOptions,
            info.fullLockedDays,
            info.rewardAmountNFT,
            info.contractNFT
        );
    }

    function getBalanceToken(IERC20 _token) public view returns( uint256 ) {
        return _token.balanceOf(address(this));
    }
    
    // amount BNB
    function withdrawNative(uint256 _amount) public onlyOwner {
        require(_amount > 0 , "_amount must be greater than 0");
        require( address(this).balance >= _amount ,"balanceOfNative:  is not enough");
        payable(msg.sender).transfer(_amount);
    }
    
    function withdrawToken(IERC20 _token, uint256 _amount) public onlyOwner {
        require(_amount > 0 , "_amount must be greater than 0");
        require(_token.balanceOf(address(this)) >= _amount , "balanceOfToken:  is not enough");
        _token.transfer(msg.sender, _amount);
    }
    
    // all BNB
    function withdrawNativeAll() public onlyOwner {
        require(address(this).balance > 0 ,"balanceOfNative:  is equal 0");
        payable(msg.sender).transfer(address(this).balance);
    }
  
    function withdrawTokenAll(IERC20 _token) public onlyOwner {
        require(_token.balanceOf(address(this)) > 0 , "balanceOfToken:  is equal 0");
        _token.transfer(msg.sender, _token.balanceOf(address(this)));
    }

    event Received(address, uint);
    receive () external payable {
        emit Received(msg.sender, msg.value);
    } 

}
