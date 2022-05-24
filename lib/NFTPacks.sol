// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingOptionsNFT is Ownable {

    struct OptionsStaking {
        uint256 amountStakedToken;
        uint256 lockDays;
        address contractsNFT;
        uint256 rewardAmountNFT;
        uint256 startTime;
        uint256 endTime;
        uint256 lockRewardDays;
    }

    uint256 public countIdOptions = 16;

    mapping(uint256 => OptionsStaking) public infoOptions;

    constructor() {
        address heroic= 0x53558FDD7299bEc18C002c9b4F1782882790Fd70;
        address titan= 0x636bd7fb7F62BE7B14b972755cdD507ECDc88243;
        address poseidon= 0x762Ece63CC2da926724541e6C3e5A3960C8c480d;
        address chaos= 0x466b3D36D0E2593BbD5F496695641A374c909F8C;

        infoOptions[0] = OptionsStaking(uint256(10000000000000000000),uint256(300),heroic,uint256(1),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[1] = OptionsStaking(uint256(20000000000000000000),uint256(450),heroic,uint256(2),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[2] = OptionsStaking(uint256(30000000000000000000),uint256(600),heroic,uint256(3),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[3] = OptionsStaking(uint256(40000000000000000000),uint256(700),heroic,uint256(3),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[4] = OptionsStaking(uint256(10000000000000000000),uint256(300),titan,uint256(1),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[5] = OptionsStaking(uint256(20000000000000000000),uint256(450),titan,uint256(2),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[6] = OptionsStaking(uint256(30000000000000000000),uint256(600),titan,uint256(3),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[7] = OptionsStaking(uint256(40000000000000000000),uint256(700),titan,uint256(3),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[8] = OptionsStaking(uint256(10000000000000000000),uint256(300),poseidon,uint256(1),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[9] = OptionsStaking(uint256(20000000000000000000),uint256(450),poseidon,uint256(2),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[10] = OptionsStaking(uint256(30000000000000000000),uint256(600),poseidon,uint256(3),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[11] = OptionsStaking(uint256(40000000000000000000),uint256(700),poseidon,uint256(3),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[12] = OptionsStaking(uint256(10000000000000000000),uint256(300),chaos,uint256(1),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[13] = OptionsStaking(uint256(20000000000000000000),uint256(450),chaos,uint256(2),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[14] = OptionsStaking(uint256(30000000000000000000),uint256(600),chaos,uint256(3),uint256(1649934077),uint256(1682849182),uint256(0));
        infoOptions[15] = OptionsStaking(uint256(40000000000000000000),uint256(700),chaos,uint256(3),uint256(1649934077),uint256(1682849182),uint256(0));

    }

    function setOptions(
        uint256[] memory _optionInfoAmountStakedToken,
        uint256[] memory _optionInfoDay,
        address[] memory _optionInfocontractsNFT,
        uint256[] memory _optionInfoStartTime, 
        uint256[] memory _optionInfoEndTime,
        uint256[] memory _optionInfoRewardAmountNFT,
        uint256[] memory _optionInfoLockRewardDay
    ) public onlyOwner{
        require(_optionInfoAmountStakedToken.length == _optionInfoDay.length, "SetOptions: The inputs have the same length");
        require(_optionInfoAmountStakedToken.length == _optionInfocontractsNFT.length, "SetOptions: The inputs have the same length");
        require(_optionInfoAmountStakedToken.length == _optionInfoStartTime.length, "SetOptions: The inputs have the same length");
        require(_optionInfoAmountStakedToken.length == _optionInfoEndTime.length, "SetOptions: The inputs have the same length");
        require(_optionInfoAmountStakedToken.length == _optionInfoRewardAmountNFT.length, "SetOptions: The inputs have the same length");
        require(_optionInfoAmountStakedToken.length == _optionInfoLockRewardDay.length, "SetOptions: The inputs have the same length");
        for(uint256 i=0; i < _optionInfoDay.length; i++){
            OptionsStaking memory info = OptionsStaking(
                _optionInfoAmountStakedToken[i], 
                _optionInfoDay[i], 
                _optionInfocontractsNFT[i],
                _optionInfoStartTime[i],
                _optionInfoEndTime[i],
                _optionInfoRewardAmountNFT[i],
                _optionInfoLockRewardDay[i]
            );
            infoOptions[countIdOptions] = info;
            countIdOptions+=1;
        }
    }

    function editOptions(uint256 _ops,uint256 _startTime, uint256 _endTime) public onlyOwner{
        require(_startTime > 0, "EditOptions: The startTime is not valid");
        require(_endTime > 0, "EditOptions: The endTime is not valid");
        require(_startTime < _endTime, "EditOptions: The startTime is not valid");
        infoOptions[_ops].startTime = _startTime;
        infoOptions[_ops].endTime = _endTime;
    }
}
