%lang starknet

from src.SellPool import pool_owner, current_price, delta, nft_collection, collection_by_nft
from src.SellPool import add_nft_to_pool, remove_nft_from_pool
from starkware.cairo.common.cairo_builtins import HashBuiltin


@external
func test_initialization{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    
    let (owner_before) = pool_owner.read()
    let (current_price_before) = current_price.read()
    let (delta_before) = delta.read()
    let (nft_collection_before) = nft_collection.read()
    let (collection_by_nft_before) = collection_by_nft.read(0)
    
    assert owner_before = 0
    assert current_price_before = 0
    assert delta_before = 0
    assert nft_collection_before = 0
    assert collection_by_nft_before = 0

    #constructor(12345, 10, 1, 111, 2, 20, 30)

    # let (owner_after) = pool_owner.read()
    # let (current_price_after) = current_price.read()
    # let (delta_after) = delta.read()
    # let (nft_collection_after) = nft_collection.read()
    # let (collection_by_nft_after) = collection_by_nft.read(20)

    # assert owner_after = 12345
    # assert current_price_after = 10
    # assert delta_after = 1
    # assert nft_collection_after = 111
    # assert collection_by_nft_after = 111
    
    return ()
end
