//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

//import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
// import {IERC721Receiver} from "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//import "@openzeppelin/contracts/access/AccessControl.sol";
import "../Inventory/Struct.sol";
import "./InvestorProposalForWatch.sol";
import "../Admin.sol";
//import {DIC} from "../DIC.sol";

            //mint only single contract                    
contract DICpropsalForWatch is ERC721{


    ///////////////////////
      //State Variable //
    //////////////////////

    //address owner;
    address adminAddress;
    uint256 watchId;
    watchDetails details;
    

    mapping(uint256 wactchId => watchDetails) public watchIdTowatchDetails;

    //////////////////
      //Events //
    /////////////////

   
    // event ProposalContractCreated(
    //     address indexed owner,
    //     uint256 indexed watchId,
    //     address indexed InvestorProposalContract
    // );

    constructor(address _admin) ERC721("WatchNFT", "WATCH") {
        adminAddress = _admin;
        
    }

  modifier onlyAdmin() {
    require(msg.sender == adminAddress, "Only admin can call this function.");
    _;
}

//

    ////////////////////
       // Functions //
    ////////////////////

    function mintNFT(address _to, uint256 _watchId) internal returns (bool) {
        _safeMint(_to, _watchId);
        return true;
    }
//keep the instance but i want only one contract
    function setProposalForWatch(
        string memory _watchBrand,
        string memory _modelName,
        uint256 id,
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
        watchId++;
        details.id= id;
        details.watchBrand = _watchBrand;
        details.modelName = _modelName;
        details.assetId = _assetId;
        details.assetCategoryId = _assetCategoryId;
        details.investmentId = _investmentId;
        details.EstimatedValue = _EstimatedValue;
        details.minRangeOfLoanAmount = _minRangeLoanAmount;
        details.maxRangeOfLoanAmount = _maxRangeLoanAmount;
        details.minRangeOfLoanDuration = _minRangeLoanDuration;
        details.maxRangeOfLoanDuration = _maxRangeLoanDuration;
        details.minRangeOfInterestRate = _minRangeInterestRate;
        details.maxRangeOfInterestRate = _maxRangeInterestRate;
        details.loanDuration = _loanDuration;
        details.onAuction = true;
        details.borrower = _borrower;

        mintNFT(msg.sender, watchId);
        // emit ItemListedForAuction(
        //     msg.sender,
        //     watchNumber,
        //     _watchName,
        //     _watchPrice,
        //     _askingPrice,
        //     _borrowDuration,
        //     _auctionDuration
        // );

         InvestorProposalForWatch getProposal = new InvestorProposalForWatch(
             _watchBrand,
            _modelName,
          watchId,
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
       
         watchIdTowatchDetails[watchId] = details;
         //emit AuctionContractCreated(msg.sender, watchNumber, address(getProposal));
      return address(getProposal);
    }
}


