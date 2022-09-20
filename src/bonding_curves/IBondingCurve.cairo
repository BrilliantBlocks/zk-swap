%lang starknet

from starkware.cairo.common.uint256 import Uint256


struct PriceCalculation {
    number_tokens: felt,
    current_price: Uint256,
    delta: felt,
}


@contract_interface
namespace IBondingCurve {
    func getTotalPrice(price_calculation: PriceCalculation) -> (total_price: Uint256) {
    }

    func getNewPrice(price_calculation: PriceCalculation) -> (new_price: Uint256) {
    }
}
