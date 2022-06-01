// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
contract Withdrawable is Ownable {

    // amount BNB
    function withdrawNative(uint256 _amount, address _beneficiary) public onlyOwner {
        require(_amount > 0 , "_amount must be greater than 0");
        require( address(this).balance >= _amount ,"balanceOfNative:  is not enough");
        payable(_beneficiary).transfer(_amount);
    }

    function withdrawToken(IERC20 _token, uint256 _amount, address _beneficiary) public onlyOwner {
        require(_amount > 0 , "_amount must be greater than 0");
        require(_token.balanceOf(address(this)) >= _amount , "balanceOfToken:  is not enough");
        _token.transfer(_beneficiary, _amount);
    }

    // all BNB
    function withdrawNativeAll(address _beneficiary) public onlyOwner {
        require(address(this).balance > 0 ,"balanceOfNative:  is equal 0");
        payable(_beneficiary).transfer(address(this).balance);
    }

    function withdrawTokenAll(IERC20 _token, address _beneficiary) public onlyOwner {
        require(_token.balanceOf(address(this)) > 0 , "balanceOfToken:  is equal 0");
        _token.transfer(_beneficiary, _token.balanceOf(address(this)));
    }

    function withdrawNFT(uint256 _tokenId, address _beneficiary, address erc721) public onlyOwner{
        IERC721(erc721).safeTransferFrom(address(this), _beneficiary, _tokenId);
    }

    function withdrawAllNFT(address _beneficiary, address erc721) public onlyOwner{
        uint256 _amountBox = IERC721Enumerable(erc721).balanceOf(address(this));
        for (uint256 i = 0; i < _amountBox; i++) {
            uint256 _tokenId = IERC721Enumerable(erc721).tokenOfOwnerByIndex(address(this), 0);
            IERC721(erc721).safeTransferFrom(address(this), _beneficiary, _tokenId);
        }
    }
    
}
