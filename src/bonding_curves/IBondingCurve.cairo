%lang starknet

from starkware.cairo.common.uint256 import Uint256


@contract_interface
namespace IBondingCurve {
    func getTotalPrice(number_tokens: felt, current_price: Uint256, delta: felt) -> (total_price: Uint256) {
    }

    func getNewPrice(number_tokens: felt, current_price: Uint256, delta: felt) -> (new_price: Uint256) {
    }
}
