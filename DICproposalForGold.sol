//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
// import {IERC721Receiver} from "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../Inventory/Struct.sol";
import "./InvestorProposalForGold.sol";
import "../Admin.sol";

//NOTE: 

//who will set proposal?

                                
contract DICpropsalForGold is ERC721{


    ///////////////////////
      //State Variable //
    //////////////////////

    //address owner;
    address adminAddress;
    uint256 goldId;
    goldDetails details;

    mapping(uint256 goldId => goldDetails) public goldIdToGoldDetails;

    //////////////////
      //Events //
    /////////////////


    // event ProposalContractCreated(
    //     address indexed owner,
    //     uint256 indexed watchId,
    //     address indexed InvestorProposalContract
    // );

    constructor(address _admin) ERC721("GoldNFT", "GOLD") {
       // owner = msg.sender;
        adminAddress = _admin;
    }

  modifier onlyAdmin() {
    require(msg.sender == adminAddress, "Only DIC admin can call this function.");
    _;
}

    ////////////////////
       // Functions //
    ////////////////////

    function mintNFT(address _to, uint256 _goldId) internal returns (bool) {
        _safeMint(_to, _goldId);
        return true;
    }
  
    function setProposalForWatch(
        uint256 _goldQuality,
        uint256 _goldWeight,
        uint256 _assetId,
        uint256 _assetCategoryId,
        uint256 _investmentId,
        uint256 _EstimatedValue,
        uint256 _minRangeLoanAmount,
        uint256 _maxRangeLoanAmount,
        uint256 _minRangeLoanDuration,
        uint256 _maxRangeLoanDuration,
        uint256 _minRangeInterestRate,
        uint256 _maxRangeInterestRate,
        uint256 _loanDuration,
        bool onAuction,
        address _borrower

    ) external onlyAdmin() returns (address) {
        goldId++;
        details.goldId= goldId;
        details.goldQuality = _goldQuality;
        details.goldWeight = _goldWeight;
        details.assetId = _assetId;
        details.assetCategoryId = _assetCategoryId;
        details.investmentId = _investmentId;
        details.EstimatedValue = _EstimatedValue;
        details.minRangeLoanAmount = _minRangeLoanAmount;
        details.maxRangeLoanAmount = _maxRangeLoanAmount;
        details.minRangeLoanDuration = _minRangeLoanDuration;
        details.maxRangeLoanDuration = _maxRangeLoanDuration;
        details.minRangeInterestRate = _minRangeInterestRate;
        details.maxRangeInterestRate = _maxRangeInterestRate;
        details.loanDuration = _loanDuration;
        details.onAuction = true;
        details.borrower = _borrower;

        mintNFT(msg.sender, goldId);
        // emit ItemListedForAuction(
        //     msg.sender,
        //     watchNumber,
        //     _watchName,
        //     _watchPrice,
        //     _askingPrice,
        //     _borrowDuration,
        //     _auctionDuration
        // );

        InvestorProposalForGold getProposal = new InvestorProposalForGold(
            _goldQuality,
            _goldWeight,
             goldId,
            _assetId,
            _assetCategoryId,
            _investmentId,
            _EstimatedValue,
            _minRangeLoanAmount,
            _maxRangeLoanAmount,
            _minRangeLoanDuration,
            _maxRangeLoanDuration,
            _minRangeInterestRate,
            _maxRangeInterestRate,
            _loanDuration,
            true,
            _borrower
        );
       
        goldIdToGoldDetails[goldId] = details;
        //emit AuctionContractCreated(msg.sender, watchNumber, address(getProposal));
        return address(getProposal);
       
    }

}


