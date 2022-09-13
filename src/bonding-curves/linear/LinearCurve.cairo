%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, split_felt
from starkware.cairo.common.uint256 import Uint256, uint256_mul, uint256_sub, uint256_add, uint256_unsigned_div_rem, uint256_eq
from starkware.cairo.common.bool import TRUE, FALSE


# To do: Refactor input parameters as PriceCalculation Struct (with Cairo v0.10.0)

@view
func getTotalPrice{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        number_tokens: felt,
        current_price: Uint256,
        delta: felt
    ) -> (
        total_price: Uint256
    ):
    alloc_locals

    let (number_tokens_uint) = convertFeltToUint(number_tokens)
    let (delta_uint) = convertFeltToUint(delta)

    let (a, a_overflow) = uint256_mul(number_tokens_uint, delta_uint)
    let (b) = uint256_sub(number_tokens_uint, Uint256(1,0))
    let (x, x_overflow) = uint256_mul(a, b)
    let (c, c_overflow) = uint256_mul(current_price, number_tokens_uint)
    let (y, y_overflow) = uint256_mul(c, Uint256(2,0))
    let (counter, counter_overflow) = uint256_add(x, y)
    let (total_price, total_price_overflow) = uint256_unsigned_div_rem(counter, Uint256(2,0))

    assertNoOverflow(a_overflow)
    assertNoOverflow(x_overflow)
    assertNoOverflow(c_overflow)
    assertNoOverflow(y_overflow)
    with_attr error_message("Overflow in price calculation."):
        assert counter_overflow = FALSE
    end
    assertNoOverflow(total_price_overflow)

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
        number_tokens: felt,
        current_price: Uint256,
        delta: felt
    ) -> (
        new_price: Uint256
    ):
    alloc_locals

    let (number_tokens_uint) = convertFeltToUint(number_tokens)
    let (delta_uint) = convertFeltToUint(delta)

    let (x, x_overflow) = uint256_mul(number_tokens_uint, delta_uint)
    let (new_price, new_price_overflow) = uint256_add(current_price, x)
    assertNoOverflow(x_overflow)
    with_attr error_message("Overflow in price calculation."):
        assert new_price_overflow = FALSE
    end

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


func assertNoOverflow{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        input: Uint256
    ) -> ():
    alloc_locals
    local zero: Uint256 = Uint256(0, 0)
    let (no_overflow) = uint256_eq(input, zero)
    with_attr error_message("Overflow in price calculation."):
        assert no_overflow = TRUE
    end
    
    return ()
end
