// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";


contract PegaxyNftStaking is ERC721, Ownable, IERC721Receiver  {
    ERC721 private nft;
    ERC20 private token;

    // uint256 rewardDuration = 1209600;
    uint256 public rewardDuration = 120;
    uint256 public rewardRate = 50000000000000000000;
    uint256 public totalStaked;
    address private treasuryWallet = 0xb221C202cF15E088B5DF9C60e7C919A193830806;
  
  // struct to store a stake's token, owner, and earning values
  struct LpToken {
    uint256 tokenId;
    uint256 timestamp;
    address owner;
    bool isStaked;
  }

  event NFTStaked(address owner, uint256 tokenId, uint256 value);
  event NFTUnstaked(address owner, uint256 tokenId, uint256 value);
  event Claimed(address owner, uint256 amount);

  // maps tokenId to stake
  mapping(uint256 => LpToken) public vault; 

   constructor(address nftContractAddress, address rewardTokenAddress) ERC721("PegaxyLP Token", "PXLP") { 
    nft = ERC721(nftContractAddress);
    token = ERC20(rewardTokenAddress);
  }

  // Mint LP token
  function mintLpToken(uint256 tokenId, address account ) internal {
    _safeMint(account, tokenId);

    vault[tokenId] = LpToken({
        owner: account,
        tokenId: tokenId,
        timestamp: uint256(block.timestamp),
        isStaked: true
      });
  }

  // Burn LP token
  function burnLpToken(uint256 tokenId) internal {
    _burn(tokenId);
     delete vault[tokenId];

  }

// Stake pegaxy tokens function =======================
  function stakePegaxy(uint256[] calldata tokenIds) external {
    uint256 tokenId;
    totalStaked += tokenIds.length;
    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      require(nft.ownerOf(tokenId) == msg.sender, "You are not owner of this token");
      require(vault[tokenId].tokenId == 0, "This token is already staked");

      nft.transferFrom(msg.sender, treasuryWallet, tokenId);
      emit NFTStaked(msg.sender, tokenId, block.timestamp);

      mintLpToken(tokenId, msg.sender);

    }
  }

// Function for unstaking pegaxy tokens =====================
  function unstake(address account, uint256[] calldata tokenIds) internal {
    uint256 tokenId;
    totalStaked -= tokenIds.length;
    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      LpToken memory staked = vault[tokenId];
      require(staked.owner == msg.sender, "You are not owner of this token");
      
      burnLpToken(tokenId);
      emit NFTUnstaked(account, tokenId, block.timestamp);
      nft.transferFrom(treasuryWallet, account, tokenId);
    }
  }

   function stakeReward(uint256 startTimestamp) internal view returns(uint256){
        uint256 time = block.timestamp-startTimestamp;
        require(time >= rewardDuration, "Withdrawal time not reached");
        uint256 remainderTime = time%rewardDuration;
        uint256 totalTimeForReward = time - remainderTime;
        uint256 rewardUnits = totalTimeForReward/rewardDuration;
        return rewardRate * rewardUnits;
    }

  function claim(uint256[] calldata tokenIds) external {
      _claim(msg.sender, tokenIds, false);
  }

  function unstakePegaxy(uint256[] calldata tokenIds) external {
      _claim(msg.sender, tokenIds, true);
  }

  function _claim(address account, uint256[] calldata tokenIds, bool _unstake) internal {
    uint256 tokenId;
    uint256 earned = 0;

    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      LpToken memory staked = vault[tokenId];
      require(staked.owner == account, "not an owner");
      uint256 stakedAt = staked.timestamp;
      earned = stakeReward(stakedAt);
      vault[tokenId] = LpToken({
        owner: account,
        tokenId: uint256(tokenId),
        timestamp: uint256(block.timestamp),
        isStaked: true
      });

    }
    if (earned > 0) {
      token.transferFrom(treasuryWallet,account, earned);
    }
    if (_unstake) {
      unstake(account, tokenIds);
    }
    emit Claimed(account, earned);
  }


  function setTreasuryWallet(address _account) public onlyOwner{
    treasuryWallet = _account;
  }

  function setRewardDuration(uint256 _duration) public onlyOwner{
    rewardDuration = _duration;
  }

  function setRewardRate(uint256 _rate) public onlyOwner{
    rewardRate = _rate;
  }


  function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
      require(from == address(0x0), "Cannot send nfts to Vault directly");
      return IERC721Receiver.onERC721Received.selector;
    }
  
}