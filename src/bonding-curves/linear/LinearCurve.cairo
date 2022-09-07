%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.uint256 import Uint256



@view
func getTotalPrice{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        number_items: felt,
        current_price: Uint256,
        delta: felt
    ) -> (
        total_price: Uint256
    ):
    alloc_locals

    local counter = number_items * (number_items - 1) * delta + 2 * current_price.low * number_items
    let (total_price_low, _) = unsigned_div_rem(counter, 2)
    let total_price = Uint256(total_price_low, 0)
    
    return (total_price)
end


@view
func getNewPrice{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        number_items: felt,
        current_price: Uint256,
        delta: felt
    ) -> (
        new_price: Uint256
    ):
    alloc_locals
    local new_price_low = current_price.low + delta * number_items
    let new_price = Uint256(new_price_low, 0)
    
    return (new_price)
end

