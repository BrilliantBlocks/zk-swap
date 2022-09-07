%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, split_felt
from starkware.cairo.common.uint256 import Uint256, uint256_mul, uint256_sub, uint256_add, uint256_unsigned_div_rem



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

    let (number_items_uint) = convertFeltToUint(number_items)
    let (delta_uint) = convertFeltToUint(delta)

    let (a, _) = uint256_mul(number_items_uint, delta_uint)
    let (b) = uint256_sub(number_items_uint, Uint256(1,0))
    let (x, _) = uint256_mul(a, b)
    let (c, _) = uint256_mul(current_price, number_items_uint)
    let (y, _) = uint256_mul(c, Uint256(2,0))
    let (counter, _) = uint256_add(x, y)
    let (total_price, _) = uint256_unsigned_div_rem(counter, Uint256(2,0))

    # local counter = number_items * (number_items - 1) * delta + 2 * current_price.low * number_items
    # let (total_price_low, _) = unsigned_div_rem(counter, 2)
    # let total_price = Uint256(total_price_low, 0)
    
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

    let (number_items_uint) = convertFeltToUint(number_items)
    let (delta_uint) = convertFeltToUint(delta)

    let (x, _) = uint256_mul(number_items_uint, delta_uint)
    let (new_price, _) = uint256_add(current_price, x)

    # local new_price_low = current_price.low + delta * number_items
    # let new_price = Uint256(new_price_low, 0)
    
    return (new_price)
end


func convertFeltToUint{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        input: felt
    ) -> (
        output: Uint256
    ):

    let (output_high, output_low) = split_felt(input)
    let output = Uint256(output_low, output_high)
    
    return (output)
end
