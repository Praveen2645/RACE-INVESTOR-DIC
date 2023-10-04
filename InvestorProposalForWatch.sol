//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

//import {ERC20} from"../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "contracts/Inventory/Struct.sol";


contract InvestorProposalForWatch is ERC20{ 

    //////////////////
      // errors //
    /////////////////

    error InvestorProposalForWatch__InvalidDetailsOrProposalExpired();
    error InvestorProposalForWatch__NotBorrower();
    error InvestorProposalForWatch__PropsalNumberNotExist();
    error InvestorProposalForWatch__AmountLessThanProposal();
    error InvestorProposalForWatch__PropsalDoesNotExist();
    error InvestorProposalForWatch__LoanProposalNotEndedOrRemainingAmountNotFulfilled();
    error InvestorProposalForWatch__onlyInvestorOfThisProposalCanCall();
    error InvestorProposalForWatch__AmountClaimedForThisProposal();
    error InvestorProposalForWatch__proposalIsClaimedByBorrower();


    //////////////////////
     //State Variable //
    /////////////////////

    uint256 private constant THIRTY_DAY_EPOCH = 2629743; //number of seconds in thirty days
    uint256 private constant ANNUAL_INTEREST_RATE_FACTOR = 1200; // used to convert the annual interest rate to a monthly rate 
    uint256 private constant MONTHLY_iNTEREST_RATE_DENOMINATOR = 12;
    uint256 private constant CUSHION_PERIOD = 5 days;
    uint256 private constant ONE_DAY_EPOCH = 86400;//seconds in one day
    uint256 public _remainingAmount;  
    uint256 EMIsPaid; // months of EMI borrower had paid
    uint256 penalty = 1; // penalty paid by borrower for late payment, in % per day
    uint256 public nextEpochToPay; // next timestamp to pay for borrower
    uint256 public proposalNum;
    bool public setForEMI;

    //////////////////
       //Events //
    /////////////////

    //   event ProposalSubmitted(
    //     uint256 indexed proposalNum,
    //     uint256 indexed amount,
    //     uint256 interestRate,
    //     address indexed investor
    // );

        // event ProposalApproved(uint256 indexed proposalNum);
        // event FundsClaimedByBorrower(uint256 proposalNum,address investor, uint256 amount);
        // event FundsWithdrawn(uint256 indexed proposalNum, address indexed investor, uint256 indexed amount);
        // event DebtTokensClaimed(uint256 indexed proposalNum,address indexed investor,uint256 amount);
        // event EMITransferred(uint256 indexed emisPaid, uint256 indexed nextEpochToPay);

     ////////////////////
    // modifiers //
    ///////////////////

       modifier onlyBorrower(){
        if(msg.sender !=details.borrower){
            revert InvestorProposalForWatch__NotBorrower();
        }
        _;
        
    }
    
      struct itemDetails {
        uint256 watchId; // change it into id
        uint256 assetId;
        uint256 assetCategoryId;
        uint256 investmentId;
        uint256 EstimatedValue;
        uint256 minRangeLoanAmount;
        uint256 maxRangeLoanAmount;
        uint256 minRangeLoanDuration;
        uint256 maxRangeLoanDuration;
        uint256 minRangeInterestRate;
        uint256 maxRangeInterestRate;
        // uint256 loanDuration; 
        //uint256 manufactureYear;
        string watchBrand;
        string modelName;
        bool onAuction;
        address borrower;
    }

 

    itemDetails public details;
    proposalDetails detailsProposer;
    //watchAuction auctionContract = watchAuction(details.watchAuctionContract);
    mapping(uint256 emiPaid => uint256 timestamp) public s_EMIPaidToTimestamps;
    mapping(uint256 proposalNumber => proposalDetails) public s_proposalNumberToProposalDetails;
  
    proposalDetails[] public s_acceptedProposalsArray;


    constructor(
        string memory _watchBrand,
        string memory _modelName,
        uint256 watchId,
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
    ) ERC20("PROPOSAL_DEBT_TOKEN", "DEBT_TOKEN") {
        
        //details.watchId= watchId;
        details.watchBrand = _watchBrand;
        details.modelName = _modelName;
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
        // details.loanDuration = _loanDuration; 
        details.onAuction = true;  //name change
        details.borrower = _borrower;
        
        EMIsPaid = 0; 
        _remainingAmount = details.EstimatedValue;
    }

    ////////////////////
      // Functions //
    ////////////////////

    function addItems(uint256 _assetId, uint256 _assetCategoryId, uint256 _investmentId) external {

    }

    /*
     * @param: _to: the investor's address to mint debt token
     * @param _amount: number of tokens to mint
     */

    function mintToken(address _to, uint256 _amount) internal returns (bool) {
        _mint(_to, _amount);
        return true;
    }


    //////////////////////////////////////
      // External & public Functions //
    /////////////////////////////////////

    /*
     * @param _interestRate: interest rate payable per year
     */

    function investorOffersProposal(uint256 _interestRate,uint256 _amount,uint256 _time) external payable { 
         // require(
        //     msg.value > 0 &&
        //         msg.value <= details.askingPrice &&
        //         _interestRate > 0 &&
        //         block.timestamp < details.auctionDuration,
        //     "either of the details are incorrect or auction is expired"
        // );
       
        if (!(msg.value > 0 &&
      msg.value <= details.EstimatedValue &&
      _interestRate > 0 &&
      _time >= details.minRangeLoanDuration || _time <= details.maxRangeLoanDuration)) { 
    revert InvestorProposalForWatch__InvalidDetailsOrProposalExpired();
}
        detailsProposer.amount = _amount;
        detailsProposer.interestRate = _interestRate;
        detailsProposer.proposalDuration = _time;
        detailsProposer.investor = msg.sender;
        detailsProposer.approved = false;
        detailsProposer.claimed = false;
        proposalNum++;
        s_proposalNumberToProposalDetails[proposalNum] = detailsProposer;
        //emit ProposalSubmitted(proposalNum, _amount, _interestRate, msg.sender);
    }

    /*
     * @param _proposalNum: proposalNUm which is accepted by the borrower
     * @notice the function can only be called by the borrower
     * @notice after proposal is successfully approved, investor of that proposalNum
     * cannot claim the ETH
     */


    function approveProposals(
        uint256 _proposalNum
    ) external onlyBorrower returns (bool) {
        //require(_proposalNum <= proposalNum, "proposal number does not exist");
        if (_proposalNum > proposalNum){
            revert InvestorProposalForWatch__PropsalNumberNotExist();
        }
           // require(
        //     _remainingAmount >= proposalMapping[_proposalNum].amount,
        //     "remaining amount is less than proposal"
        // );
       if (_remainingAmount < s_proposalNumberToProposalDetails[_proposalNum].amount){
            revert InvestorProposalForWatch__AmountLessThanProposal();

        } 
        if (s_proposalNumberToProposalDetails[_proposalNum].approved ==true){
            revert InvestorProposalForWatch__AmountLessThanProposal(); ///make an error--------------------

        } 
         
        s_proposalNumberToProposalDetails[_proposalNum].approved = true;
        _remainingAmount -= s_proposalNumberToProposalDetails[_proposalNum].amount;
        s_acceptedProposalsArray.push(s_proposalNumberToProposalDetails[_proposalNum]);
        
        if (_remainingAmount == 0) {
            nextEpochToPay = THIRTY_DAY_EPOCH + block.timestamp;
            setForEMI = true;
        }
        //emit ProposalApproved(_proposalNum);
        return true;
    }


    /*
     * @param _proposalNum: proposalNum of investor who is claiming ETH
     * @notice The function can only be called by the investor who has submitted
     * his offer and had got proposalNum
     * @notice The function can only be called when auction gets over and borrower approves
     * amount of proposals which equat to its asking amount (_remainingAmount)
     */

    function investorWithdrawAmountIfProposalNotSelected(
        uint256 _proposalNum
    ) external payable returns (bool) {
        //require(_proposalNum <= proposalNum, "proposal does not exist");
       
        if (_proposalNum > proposalNum) {
            revert InvestorProposalForWatch__PropsalDoesNotExist();
    }

        // require(
        //     details.auctionDuration < block.timestamp && _remainingAmount == 0,
        //     "auction is not ended yet or remaining amount is not fulfilled"
        // );
        
   
     if (_remainingAmount == 0) { // changes here
    revert InvestorProposalForWatch__LoanProposalNotEndedOrRemainingAmountNotFulfilled();
}

        // require(
        //     s_proposalNumberToProposalDetails[_proposalNum].investor == msg.sender,
        //     "only investor of this proposal can call this function"
        // );
        if (s_proposalNumberToProposalDetails[_proposalNum].investor != msg.sender) {
        revert InvestorProposalForWatch__onlyInvestorOfThisProposalCanCall();
    }

        // require(
        //     s_proposalNumberToProposalDetails[_proposalNum].claimed != true,
        //     "amount of this proposal is claimed"
        // );
        if (s_proposalNumberToProposalDetails[_proposalNum].claimed == true){
            revert InvestorProposalForWatch__AmountClaimedForThisProposal();
        }
        // require(
        //     s_proposalNumberToProposalDetails[_proposalNum].approved != true,
        //     "this proposer is claimed by borrower"
        // );
        if(s_proposalNumberToProposalDetails[_proposalNum].approved == true){
            revert InvestorProposalForWatch__proposalIsClaimedByBorrower();
        }

        (bool sent, ) = msg.sender.call{
            value: s_proposalNumberToProposalDetails[_proposalNum].amount
        }("");
        require(sent, "Failed to send Ether");
        s_proposalNumberToProposalDetails[_proposalNum].approved == true;
        
        //emit FundsClaimedByBorrower(_proposalNum, msg.sender, s_proposalNumberToProposalDetails[_proposalNum].amount);
        return true;
    }

    /*
     * @param _proposalNum: proposalNum of investor which borrower has approved
     * @notice The function can only be called by the borrower
     * @notice borrower can claim ETH after loanProposal is ended and proposal approves
     * amount of proposals which equal to its asking amount (_remainingAmount)
     */

    function borrowerClaimFunds(
        uint256 _proposalNum
    ) external payable onlyBorrower returns (bool) {
        require(_proposalNum <= proposalNum, "proposal does not exist");
        require(
            s_proposalNumberToProposalDetails[_proposalNum].approved == true,
            "proposal is not approved"
        );

        require(
            s_proposalNumberToProposalDetails[_proposalNum].claimed != true,
            "amount of this proposal is claimed"
        );

        require(_remainingAmount == 0, "remaining amount should be zero ");

        (bool sent, ) = msg.sender.call{
            value: s_proposalNumberToProposalDetails[_proposalNum].amount
        }("");
        s_proposalNumberToProposalDetails[_proposalNum].claimed = true;
         //emit FundsClaimedByBorrower(_proposalNum, msg.sender, s_proposalNumberToProposalDetails[_proposalNum].amount);
        return sent;
    }

    /*
     * @param _proposalNum: proposalNum of accepted proposal by borrower
     * @notice The contract allows investor to claim debt token after their propsoal is accepted
     * @notice the contract can be called when auction is ended and proposal approves
     * amount of proposals which equat to its asking amount (_remainingAmount)
     */

    function investorClaimDebtToken(
        uint256 _proposalNum
    ) external returns (bool) {
        require(_proposalNum <= proposalNum, "proposal does not exist");
        require(
            s_proposalNumberToProposalDetails[_proposalNum].approved == true,
            "proposal is not approved"
        );
        require(
            s_proposalNumberToProposalDetails[_proposalNum].investor == msg.sender,
            "caller is not investor if this proposal"
        );

        mintToken(msg.sender, s_proposalNumberToProposalDetails[_proposalNum].amount);
        //emit DebtTokensClaimed(_proposalNum, msg.sender, s_proposalNumberToProposalDetails[_proposalNum].amount);

        return true;
    }

    // @dev note that transfer function is build to support ETH currently
    function transferEMIamountToInvestors() public payable returns (bool) {
        // use output of calculateEMI
        require(setForEMI == true, "Contract is not set to give EMI Now");
        require(EMIsPaid >= details.minRangeLoanDuration && EMIsPaid <= details.maxRangeLoanDuration, "NO EMI IS LEFT");
        

        uint totalSupplyDebtToken = totalSupply();

        for (uint i = 0; i < s_acceptedProposalsArray.length; i++) {
            uint _tokenBal = balanceOf(s_acceptedProposalsArray[i].investor);
            uint EMIToPay = returnEMI(
                s_acceptedProposalsArray[i].amount,
                s_acceptedProposalsArray[i].interestRate
            );

            uint _toPay = (_tokenBal * EMIToPay) / totalSupplyDebtToken;

            (bool sent, ) = s_acceptedProposalsArray[i].investor.call{
                value: _toPay
            }("");
            require(sent, "Failed to send Ether");
        }
        EMIsPaid += 1;
        nextEpochToPay += THIRTY_DAY_EPOCH;
        s_EMIPaidToTimestamps[EMIsPaid] = block.timestamp;
       // emit EMITransferred(EMIsPaid, nextEpochToPay);
        return true;
    }

    /*
     * @param principal: principal amount given by the investor to borrower
     * @param interestRate: interestRate proided by the investor
     * @notice The function returns EMI of next installment
     * - For example if you want to pay EMI on time, i.e. within 30 days + 5 days of cushion
     *   your EMI would be of 30 days and no penalty
     * - If you want to pay EMI late, you have to pay penalty on EMI, which is calculated per day elapsed
     */

    function returnEMI(
        uint principal,
        uint interestRate
    ) public view returns (uint) {
        if (block.timestamp < nextEpochToPay + CUSHION_PERIOD) {
            return calculateEMI(principal, interestRate);
        } else {
            uint daysElapsed = (block.timestamp - (nextEpochToPay + CUSHION_PERIOD)) /
                ONE_DAY_EPOCH;
        
            return
                calculateEMI(principal, interestRate) +
                (((daysElapsed * penalty) * calculateEMI(principal, interestRate)) /
                    100);
        }
    }

    /*
     * @notice the function provides timestamps of next EMI to be paid by borrower
     * @output nextEpochToPay: it is 30 days
     * @output nextEpochToPay + 5 days is the cusion of which user has to finally pay EMI
     * else penalty would be imposed 
     */

    function nextEMITimestampToBePaid() public view returns (uint, uint) {
        return (nextEpochToPay, nextEpochToPay + CUSHION_PERIOD);
    }

    ////////////////////////////
    // Internal Functions //
    ////////////////////////////

    /*
     * @param principal: principal amount of the borrowing funds
     * @param interestRate: interest rate in % offered by investor
     * @param time: Time of EMI in months

    */
    function calculateEMI(
        uint principal,
        uint interestRate
    ) internal view returns (uint) {
        //@dev note that time is in months and calculation is done via simple interest
        // Ensure interestRate is a valid positive number
       require(interestRate > 0, "Interest rate must be greater than zero");

       // Ensure minRangeLoanDuration is within a valid range
    require(
        details.minRangeLoanDuration <= details.maxRangeLoanDuration,
       "Invalid loan duration range"
    );

     // Ensure principal is within a valid range
    require(
         principal >= details.minRangeLoanAmount &&
       principal <= details.maxRangeLoanAmount,
        "Principal amount is not within the valid range"
    );

        uint EMI = 
        ((principal +(principal * interestRate *  details.maxRangeLoanDuration) /
            ANNUAL_INTEREST_RATE_FACTOR) / MONTHLY_iNTEREST_RATE_DENOMINATOR) * 2; //need to improve

        return EMI;
    }
}
