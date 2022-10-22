//We will provide insurance for only (Physical assets)
/* For now we will only provide vehicle insurance car */
//Comprehensive insurance

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./ConversionRate.sol";
import "./Calculation.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error WrongWorthOfEth(uint256 amount);

contract EverInsurance is Calculation {
  uint256 public constant s_MIN_USD = 100 * 10**18;
  uint256 public constant addOns_zeroDeprication = 30 * 10**18;
  uint256 public constant addOns_engineCover = 20 * 10**18;
  uint256 public constant addOns_keyLoss = 20 * 10**18;
  uint256 public counter;
  AggregatorV3Interface public priceFeed;

  enum stage{pending,fulfilled,rejected,claimed}
  mapping(uint => mapping(bool =>stage)) public claim;
  
  using ConversionRate for uint256;

  struct insurance {
    string products;
    uint256 ex_ShowRoomPrice;
    uint256 idv;
    uint256 howOld;
    uint256 whatInsuranceisThis;
    address payable owner;
    bool isclaimed;
    bool zeroDeprication;
    bool engineCover;
    bool keyLoss;
    uint256 insuranceID;
    uint256 totalAmountPaid;
  }

  insurance[] public insurances;

  event InsuranedYourProduct(
    address owner,
    string indexed product,
    uint256 indexed howOld,
    uint256 indexed idv
  );

  constructor(address _priceFeed){
      priceFeed = AggregatorV3Interface(_priceFeed);
  }

  function getInsurance(
    string memory _product,
    uint256 _ex_ShowRoomPrice,
    uint256 _howOldInMonths,
    bool _zeroDeprication,
    bool _engineCover,
    bool _lostkey
  ) public payable {
    uint256 totalAmount = s_MIN_USD;

    if (_zeroDeprication) {
      totalAmount = totalAmount + addOns_zeroDeprication;
    }
    if (_engineCover) {
      totalAmount = totalAmount + addOns_engineCover;
    }
    if (_lostkey) {
      totalAmount = totalAmount + addOns_keyLoss;
    }
    uint256 amount = calculateIdv(_howOldInMonths, _ex_ShowRoomPrice);
    require(msg.value.getConversionRate(priceFeed) >= totalAmount,"WrongWorthOfEth");
    insurance memory newInsurance = insurance({
      products: _product,
      ex_ShowRoomPrice: _ex_ShowRoomPrice,
      idv: amount,
      howOld: _howOldInMonths,
      whatInsuranceisThis: 1,
      owner: payable(msg.sender),
      isclaimed: false,
      zeroDeprication: _zeroDeprication,
      engineCover: _engineCover,
      keyLoss: _lostkey,
      insuranceID: counter,
      totalAmountPaid: msg.value
    });
    insurances.push(newInsurance);
    counter += 1;
    emit InsuranedYourProduct(msg.sender, _product, _howOldInMonths, amount);
  }
  function ReInsurance(uint256 _counter) public payable {
    insurance storage insurancesss = insurances[_counter];
    require(msg.sender == insurancesss.owner, "You are not Owner");
    uint256 newamount;
    if (!insurancesss.isclaimed) {
      if (
        insurancesss.whatInsuranceisThis <= 3 &&
        insurancesss.whatInsuranceisThis > 0
      ) {
        newamount = getCalculc(10, insurancesss.totalAmountPaid);
      } else if (
        insurancesss.whatInsuranceisThis <= 3 &&
        insurancesss.whatInsuranceisThis > 5
      ) {
        newamount = getCalculc(20, insurancesss.totalAmountPaid);
      } else {
        newamount = getCalculc(40, insurancesss.totalAmountPaid);
      }
    } else {
      newamount = insurancesss.totalAmountPaid;
    }
    require(msg.value >= newamount, "o");
    uint256 number = insurancesss.howOld + 12;
    insurancesss.idv = calculateIdv(number, insurancesss.ex_ShowRoomPrice);
    insurancesss.howOld = number;
    insurancesss.whatInsuranceisThis = insurancesss.whatInsuranceisThis + 1;
    insurancesss.totalAmountPaid = insurancesss.totalAmountPaid + msg.value;
  }

  function calculateIdv(uint256 months, uint256 price)
    internal
    pure
    returns (uint256)
  {
    if (months <= 6 && months >= 0) {
      return getCalculc(5, price);
    } else if (months <= 12 && months >= 6) {
      return getCalculc(15, price);
    } else if (months <= 24 && months >= 12) {
      return getCalculc(20, price);
    } else if (months <= 36 && months >= 24) {
      return getCalculc(30, price);
    } else if (months <= 48 && months >= 36) {
      return getCalculc(40, price);
    } else {
      return getCalculc(50, price);
    }
  }

  function USDtoWEI(uint256 usdtoWei) public view returns (uint256) {
    uint number = 1;
    uint256 priceOfEth = number.getConversionRate(priceFeed);
    uint256 oneWei = PRBMath.mulDiv(1e18, SCALE, priceOfEth);
    uint256 weiPrice = oneWei / 10**18;
    return weiPrice * usdtoWei;
  }
  
  function makeAClaim(uint insuranceId) external {
      insurance storage newins = insurances[0];
      require(msg.sender == newins.owner , "You are not owner");
      claim[insuranceId][true] = stage.pending;
  }  
}
