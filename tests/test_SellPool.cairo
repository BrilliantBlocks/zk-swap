%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

from src.ISellPool import ISellPool
from src.SellPool import NFT


const FACTORY = 123456789
const CURRENT_PRICE = 10
const DELTA = 1


@view
func __setup__():
    %{
        context.contract_address = deploy_contract("./src/SellPool.cairo", 
            [
                ids.FACTORY, ids.CURRENT_PRICE, ids.DELTA
            ]
        ).contract_address
    %}
    return ()
end


@external
func test_initialization_with_expected_output{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local contract_address
    %{ ids.contract_address = context.contract_address %}

    const FACTORY = 123456789
    const CURRENT_PRICE = 10
    const DELTA = 1

    let (factory) = ISellPool.get_pool_factory(contract_address)
    let (current_price) = ISellPool.get_current_price(contract_address)
    let (delta) = ISellPool.get_delta(contract_address)
    
    assert factory = FACTORY
    assert current_price = CURRENT_PRICE
    assert delta = DELTA
    
    return ()
end


@external
func test_add_nft_to_pool{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local contract_address
    %{ ids.contract_address = context.contract_address %}

    const FACTORY = 123456789
    const CURRENT_PRICE = 10
    const DELTA = 1
    const COLLECTION_1 = 1111111111
    const COLLECTION_2 = 2222222222
    const COLLECTION_3 = 3333333333
    const NFT_1_1 = 11
    const NFT_1_2 = 12
    const NFT_2_1 = 21
    const NFT_2_2 = 22
    const NFT_3_1 = 31
    const ZERO_ID = 0
    const COLLECTION_ARRAY_LEN = 2
    const NFT_COLLECTION_1_ARRAY_LEN = 2
    const NFT_COLLECTION_2_ARRAY_LEN = 1

    let (NFT_ARRAY_1 : NFT*) = alloc()

    assert NFT_ARRAY_1[0] = NFT(address = COLLECTION_1, id = NFT_1_1)
    assert NFT_ARRAY_1[1] = NFT(address = COLLECTION_2, id = NFT_2_1)
    assert NFT_ARRAY_1[2] = NFT(address = COLLECTION_1, id = NFT_1_2)
    
    ISellPool.add_nft_to_pool(contract_address, 3, NFT_ARRAY_1)

    let (factory) = ISellPool.get_pool_factory(contract_address)
    let (current_price) = ISellPool.get_current_price(contract_address)
    let (delta) = ISellPool.get_delta(contract_address)
    let (start_id_collection_1) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_1)
    let (start_id_collection_2) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_2)
    let (list_element_1) = ISellPool.get_list_element_by_id(contract_address, 1)
    let (list_element_2) = ISellPool.get_list_element_by_id(contract_address, 2)
    let (list_element_3) = ISellPool.get_list_element_by_id(contract_address, 3)
    let (collection_address_1) = ISellPool.get_collection_by_id(contract_address, 0)
    let (collection_address_2) = ISellPool.get_collection_by_id(contract_address, 1)
    let (collection_array_len, collection_array) = ISellPool.get_all_collections(contract_address)
    let (nft_collection_1_id_list_len, nft_collection_1_id_list) = ISellPool.get_all_nfts_of_collection(contract_address, COLLECTION_1)
    let (nft_collection_2_id_list_len, nft_collection_2_id_list) = ISellPool.get_all_nfts_of_collection(contract_address, COLLECTION_2)
    let (nft_collection_3_id_list_len, nft_collection_3_id_list) = ISellPool.get_all_nfts_of_collection(contract_address, COLLECTION_3)

    assert factory = FACTORY
    assert current_price = CURRENT_PRICE
    assert delta = DELTA
    assert start_id_collection_1 = 1
    assert start_id_collection_2 = 2
    assert list_element_1[0] = NFT_1_1
    assert list_element_1[1] = 3
    assert list_element_2[0] = NFT_2_1
    assert list_element_2[1] = ZERO_ID
    assert list_element_3[0] = NFT_1_2
    assert list_element_3[1] = ZERO_ID
    assert collection_address_1 = COLLECTION_1
    assert collection_address_2 = COLLECTION_2
    assert collection_array_len = COLLECTION_ARRAY_LEN
    assert collection_array[0] = COLLECTION_1
    assert collection_array[1] = COLLECTION_2
    assert nft_collection_1_id_list_len = NFT_COLLECTION_1_ARRAY_LEN
    assert nft_collection_1_id_list[0] = NFT_1_1
    assert nft_collection_1_id_list[1] = NFT_1_2
    assert nft_collection_2_id_list_len = NFT_COLLECTION_2_ARRAY_LEN
    assert nft_collection_2_id_list[0] = NFT_2_1
    assert nft_collection_3_id_list_len = ZERO_ID

    let (NFT_ARRAY_2 : NFT*) = alloc()

    assert NFT_ARRAY_2[0] = NFT(address = COLLECTION_2, id = NFT_2_2)
    assert NFT_ARRAY_2[1] = NFT(address = COLLECTION_3, id = NFT_3_1)
    
    ISellPool.add_nft_to_pool(contract_address, 2, NFT_ARRAY_2)

    let (start_id_collection_3) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_3)
    let (list_element_2) = ISellPool.get_list_element_by_id(contract_address, 2)
    let (list_element_4) = ISellPool.get_list_element_by_id(contract_address, 4)
    let (list_element_5) = ISellPool.get_list_element_by_id(contract_address, 5)

    assert start_id_collection_3 = 5
    assert list_element_2[0] = NFT_2_1
    assert list_element_2[1] = 4
    assert list_element_4[0] = NFT_2_2
    assert list_element_4[1] = ZERO_ID
    assert list_element_5[0] = NFT_3_1
    assert list_element_5[1] = ZERO_ID
    
    return ()
end


@external
func test_remove_nft_from_pool{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local contract_address
    %{ ids.contract_address = context.contract_address %}

    const FACTORY = 123456789
    const CURRENT_PRICE = 10
    const DELTA = 1
    const COLLECTION_1 = 1111111111
    const COLLECTION_2 = 2222222222
    const COLLECTION_3 = 3333333333
    const NFT_1_1 = 11
    const NFT_1_2 = 12
    const NFT_2_1 = 21
    const NFT_2_2 = 22
    const NFT_3_1 = 31
    const ZERO_ID = 0

    let (NFT_ARRAY_ADD : NFT*) = alloc()

    assert NFT_ARRAY_ADD[0] = NFT(address = COLLECTION_1, id = NFT_1_1)
    assert NFT_ARRAY_ADD[1] = NFT(address = COLLECTION_2, id = NFT_2_1)
    assert NFT_ARRAY_ADD[2] = NFT(address = COLLECTION_1, id = NFT_1_2)
    assert NFT_ARRAY_ADD[3] = NFT(address = COLLECTION_2, id = NFT_2_2)
    assert NFT_ARRAY_ADD[4] = NFT(address = COLLECTION_3, id = NFT_3_1)
    
    ISellPool.add_nft_to_pool(contract_address, 5, NFT_ARRAY_ADD)

    let (factory) = ISellPool.get_pool_factory(contract_address)
    let (current_price) = ISellPool.get_current_price(contract_address)
    let (delta) = ISellPool.get_delta(contract_address)
    let (start_id_collection_1) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_1)
    let (start_id_collection_2) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_2)
    let (start_id_collection_3) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_3)
    let (list_element_1) = ISellPool.get_list_element_by_id(contract_address, 1)
    let (list_element_2) = ISellPool.get_list_element_by_id(contract_address, 2)
    let (list_element_3) = ISellPool.get_list_element_by_id(contract_address, 3)
    let (list_element_4) = ISellPool.get_list_element_by_id(contract_address, 4)
    let (list_element_5) = ISellPool.get_list_element_by_id(contract_address, 5)
    let (collection_address_1) = ISellPool.get_collection_by_id(contract_address, 0)
    let (collection_address_2) = ISellPool.get_collection_by_id(contract_address, 1)
    let (collection_array_len, collection_array) = ISellPool.get_all_collections(contract_address)
    let (nft_collection_1_id_list_len, nft_collection_1_id_list) = ISellPool.get_all_nfts_of_collection(contract_address, COLLECTION_1)
    let (nft_collection_2_id_list_len, nft_collection_2_id_list) = ISellPool.get_all_nfts_of_collection(contract_address, COLLECTION_2)
    let (nft_collection_3_id_list_len, nft_collection_3_id_list) = ISellPool.get_all_nfts_of_collection(contract_address, COLLECTION_3)

    assert factory = FACTORY
    assert current_price = CURRENT_PRICE
    assert delta = DELTA
    assert start_id_collection_1 = 1
    assert start_id_collection_2 = 2
    assert start_id_collection_3 = 5
    assert list_element_1[0] = NFT_1_1
    assert list_element_1[1] = 3
    assert list_element_2[0] = NFT_2_1
    assert list_element_2[1] = 4
    assert list_element_3[0] = NFT_1_2
    assert list_element_3[1] = ZERO_ID
    assert list_element_4[0] = NFT_2_2
    assert list_element_4[1] = ZERO_ID
    assert list_element_5[0] = NFT_3_1
    assert list_element_5[1] = ZERO_ID
    assert collection_address_1 = COLLECTION_1
    assert collection_address_2 = COLLECTION_2
    assert collection_array_len = 3
    assert collection_array[0] = COLLECTION_1
    assert collection_array[1] = COLLECTION_2
    assert collection_array[2] = COLLECTION_3
    assert nft_collection_1_id_list_len = 2
    assert nft_collection_1_id_list[0] = NFT_1_1
    assert nft_collection_1_id_list[1] = NFT_1_2
    assert nft_collection_2_id_list_len = 2
    assert nft_collection_2_id_list[0] = NFT_2_1
    assert nft_collection_2_id_list[1] = NFT_2_2
    assert nft_collection_3_id_list_len = 1
    assert nft_collection_3_id_list[0] = NFT_3_1


    let (NFT_ARRAY_REMOVE : NFT*) = alloc()

    assert NFT_ARRAY_REMOVE[0] = NFT(address = COLLECTION_1, id = NFT_1_2)
    assert NFT_ARRAY_REMOVE[1] = NFT(address = COLLECTION_2, id = NFT_2_1)
    
    ISellPool.remove_nft_from_pool(contract_address, 2, NFT_ARRAY_REMOVE)

    let (new_start_id_collection_1) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_1)
    let (new_start_id_collection_2) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_2)
    let (list_element_1) = ISellPool.get_list_element_by_id(contract_address, 1)
    let (list_element_2) = ISellPool.get_list_element_by_id(contract_address, 2)
    let (list_element_3) = ISellPool.get_list_element_by_id(contract_address, 3)
    let (list_element_4) = ISellPool.get_list_element_by_id(contract_address, 4)
    let (collection_array_len, collection_array) = ISellPool.get_all_collections(contract_address)
    let (nft_collection_1_id_list_len, nft_collection_1_id_list) = ISellPool.get_all_nfts_of_collection(contract_address, COLLECTION_1)
    let (nft_collection_2_id_list_len, nft_collection_2_id_list) = ISellPool.get_all_nfts_of_collection(contract_address, COLLECTION_2)
    let (nft_collection_3_id_list_len, nft_collection_3_id_list) = ISellPool.get_all_nfts_of_collection(contract_address, COLLECTION_3)
    
    assert new_start_id_collection_1 = 1
    assert new_start_id_collection_2 = 4
    assert list_element_1[0] = NFT_1_1
    assert list_element_1[1] = ZERO_ID
    assert list_element_2[0] = ZERO_ID
    assert list_element_2[1] = ZERO_ID
    assert list_element_3[0] = ZERO_ID
    assert list_element_3[1] = ZERO_ID
    assert list_element_4[0] = NFT_2_2
    assert list_element_4[1] = ZERO_ID
    assert list_element_5[0] = NFT_3_1
    assert list_element_5[1] = ZERO_ID
    assert collection_array_len = 3
    assert collection_array[0] = COLLECTION_1
    assert collection_array[1] = COLLECTION_2
    assert collection_array[2] = COLLECTION_3
    assert nft_collection_1_id_list_len = 1
    assert nft_collection_1_id_list[0] = NFT_1_1
    assert nft_collection_2_id_list_len = 1
    assert nft_collection_2_id_list[0] = NFT_2_2
    assert nft_collection_3_id_list_len = 1
    assert nft_collection_3_id_list[0] = NFT_3_1
    
    return ()
end


@external
func test_edit_pool_with_expected_output{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local contract_address
    %{ ids.contract_address = context.contract_address %}

    const OLD_PRICE = 10
    const OLD_DELTA = 1 
    const NEW_PRICE = 15
    const NEW_DELTA = 2

    let (old_price) = ISellPool.get_current_price(contract_address)
    let (old_delta) = ISellPool.get_delta(contract_address)

    assert old_price = CURRENT_PRICE
    assert old_delta = DELTA

    ISellPool.edit_pool(contract_address, NEW_PRICE, NEW_DELTA)

    let (new_price) = ISellPool.get_current_price(contract_address)
    let (new_delta) = ISellPool.get_delta(contract_address)

    assert new_price = NEW_PRICE
    assert new_delta = NEW_DELTA

    return ()
end


@external
func test_edit_pool_with_negative_price{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local contract_address
    %{ ids.contract_address = context.contract_address %}

    const NEW_NEGATIVE_PRICE = -15
    const NEW_DELTA = 2

    %{ expect_revert(error_message="Price cannot be negative.") %}
    ISellPool.edit_pool(contract_address, NEW_NEGATIVE_PRICE, NEW_DELTA)

    return ()
end


@external
func test_buy_nfts{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local contract_address
    %{ ids.contract_address = context.contract_address %}

    const COLLECTION_1 = 1111111111
    const NFT_1_1 = 11
    const NFT_1_2 = 12
    const ZERO_ID = 0
    const OLD_ETH_BALANCE = 0
    const NEW_ETH_BALANCE = 21
    const OLD_PRICE = 10
    const NEW_PRICE = 12
    
    let (NFT_ARRAY : NFT*) = alloc()

    assert NFT_ARRAY[0] = NFT(address = COLLECTION_1, id = NFT_1_1)
    assert NFT_ARRAY[1] = NFT(address = COLLECTION_1, id = NFT_1_2)
    
    ISellPool.add_nft_to_pool(contract_address, 2, NFT_ARRAY)

    let (old_eth_balance) = ISellPool.get_eth_balance(contract_address)
    let (start_id_collection_1) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_1)
    let (old_price) = ISellPool.get_current_price(contract_address)
    
    assert old_eth_balance = OLD_ETH_BALANCE
    assert start_id_collection_1 = 1
    assert old_price = OLD_PRICE

    ISellPool.buy_nfts(contract_address, 2, NFT_ARRAY)

    let (new_eth_balance) = ISellPool.get_eth_balance(contract_address)
    let (new_start_id_collection_1) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_1)
    let (new_price) = ISellPool.get_current_price(contract_address)
    
    assert new_eth_balance = NEW_ETH_BALANCE
    assert new_start_id_collection_1 = ZERO_ID
    assert new_price = NEW_PRICE

    return ()
end


@external
func test_get_pool_config_with_expected_output{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local contract_address
    %{ ids.contract_address = context.contract_address %}

    let (pool_factory) = ISellPool.get_pool_factory(contract_address)
    let (current_price, delta) = ISellPool.get_pool_config(contract_address)

    assert pool_factory = FACTORY
    assert current_price = CURRENT_PRICE
    assert delta = DELTA

    return ()
end