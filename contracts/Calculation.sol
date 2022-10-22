// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "prb-math/contracts/PRBMathUD60x18.sol";
// import "./ConversionRate.sol";

contract Calculation {
using PRBMathUD60x18 for uint256;
uint256 internal constant SCALE = 1e18;
    function getCalculc(uint five , uint ex_show_price) public pure returns(uint256)
    {
          uint amount = five * ex_show_price;
          uint number = amount / 100;
          return (ex_show_price - number);
    }
}