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
        _number_items: felt,
        _current_price: Uint256,
        _delta: felt
    ) -> (
        _total_price: Uint256
    ):
    alloc_locals

    local _counter = _number_items * (_number_items - 1) * _delta + 2 * _current_price.low * _number_items
    let (_total_price_low, _) = unsigned_div_rem(_counter, 2)
    let _total_price = Uint256(_total_price_low, 0)
    
    return (_total_price)
end


@view
func getNewPrice{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _number_items: felt,
        _current_price: Uint256,
        _delta: felt
    ) -> (
        _new_price: Uint256
    ):
    alloc_locals
    local _new_price_low = _current_price.low + _delta * _number_items
    let _new_price = Uint256(_new_price_low, 0)
    
    return (_new_price)
end

