%lang starknet

from src.ISellPool import ISellPool
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc


const OWNER = 123456789
const CURRENT_PRICE = 10
const DELTA = 1
const COLLECTION_1 = 1111111111
const COLLECTION_2 = 2222222222
const NFT_1_1 = 11
const NFT_1_2 = 12
const NFT_2_1 = 21


@view
func __setup__():
    %{
        context.contract_address = deploy_contract("./src/SellPool.cairo", 
            [
                ids.OWNER, ids.CURRENT_PRICE, ids.DELTA, 3, ids.COLLECTION_1, ids.COLLECTION_2, ids.COLLECTION_1, 3, ids.NFT_1_1, ids.NFT_2_1, ids.NFT_1_2
            ]
        ).contract_address
    %}
    return ()
end


@external
func test_initialization_with_expected_output{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    tempvar contract_address
    %{ ids.contract_address = context.contract_address %}

    const OWNER = 123456789
    const CURRENT_PRICE = 10
    const DELTA = 1
    const COLLECTION_1 = 1111111111
    const COLLECTION_2 = 2222222222
    const COLLECTION_3 = 3333333333
    const NFT_1_1 = 11
    const NFT_1_2 = 12
    const NFT_2_1 = 21
    const ZERO_ID = 0
    const LIST_ELEMENT_ID_COLLECTION_1_NFT_1_1 = 1
    const LIST_ELEMENT_ID_COLLECTION_2_NFT_2_1 = 2
    const LIST_ELEMENT_ID_COLLECTION_1_NFT_1_2 = 3
    const COLLECTION_1_ID = 0
    const COLLECTION_2_ID = 1
    const COLLECTION_ARRAY_LEN = 2
    const NFT_COLLECTION_1_ARRAY_LEN = 2
    const NFT_COLLECTION_2_ARRAY_LEN = 1


    let (owner) = ISellPool.get_pool_owner(contract_address)
    let (current_price) = ISellPool.get_current_price(contract_address)
    let (delta) = ISellPool.get_delta(contract_address)
    let (start_id_collection_1) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_1)
    let (start_id_collection_2) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_2)
    let (list_element_1_1) = ISellPool.get_list_element_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_1_NFT_1_1)
    let (list_element_2_1) = ISellPool.get_list_element_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_2_NFT_2_1)
    let (list_element_1_2) = ISellPool.get_list_element_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_1_NFT_1_2)
    let (collection_address_1) = ISellPool.get_collection_by_id(contract_address, COLLECTION_1_ID)
    let (collection_address_2) = ISellPool.get_collection_by_id(contract_address, COLLECTION_2_ID)
    let (collection_array_len, collection_array) = ISellPool.get_all_collections(contract_address)
    let (nft_collection_1_array_len, nft_collection_1_array) = ISellPool.get_all_nfts_of_collection(contract_address, COLLECTION_1)
    let (nft_collection_2_array_len, nft_collection_2_array) = ISellPool.get_all_nfts_of_collection(contract_address, COLLECTION_2)
    let (nft_collection_3_array_len, nft_collection_3_array) = ISellPool.get_all_nfts_of_collection(contract_address, COLLECTION_3)

    assert owner = OWNER
    assert current_price = CURRENT_PRICE
    assert delta = DELTA
    assert start_id_collection_1 = LIST_ELEMENT_ID_COLLECTION_1_NFT_1_1
    assert start_id_collection_2 = LIST_ELEMENT_ID_COLLECTION_2_NFT_2_1
    assert list_element_1_1[0] = NFT_1_1
    assert list_element_1_1[1] = LIST_ELEMENT_ID_COLLECTION_1_NFT_1_2
    assert list_element_2_1[0] = NFT_2_1
    assert list_element_2_1[1] = ZERO_ID
    assert list_element_1_2[0] = NFT_1_2
    assert list_element_1_2[1] = ZERO_ID
    assert collection_address_1 = COLLECTION_1
    assert collection_address_2 = COLLECTION_2
    assert collection_array_len = COLLECTION_ARRAY_LEN
    assert collection_array[0] = COLLECTION_1
    assert collection_array[1] = COLLECTION_2
    assert nft_collection_1_array_len = NFT_COLLECTION_1_ARRAY_LEN
    assert nft_collection_1_array[0] = NFT_1_1
    assert nft_collection_1_array[1] = NFT_1_2
    assert nft_collection_2_array_len = NFT_COLLECTION_2_ARRAY_LEN
    assert nft_collection_2_array[0] = NFT_2_1
    assert nft_collection_3_array_len = ZERO_ID
    
    return ()
end


@external
func test_add_nft_to_pool{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local contract_address
    %{ ids.contract_address = context.contract_address %}

    const COLLECTION_2 = 2222222222
    const COLLECTION_3 = 3333333333
    const NFT_2_1 = 21
    const NFT_2_2 = 22
    const NFT_3_1 = 31
    const ZERO_ID = 0
    const LIST_ELEMENT_ID_COLLECTION_2_NFT_2_1 = 2
    const LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2 = 4
    const LIST_ELEMENT_ID_COLLECTION_3_NFT_3_1 = 5

    let (COLLECTIONS) = alloc()
    assert [COLLECTIONS] = COLLECTION_2
    assert [COLLECTIONS + 1] = COLLECTION_3

    let (NFTS) = alloc()
    assert [NFTS] = NFT_2_2
    assert [NFTS + 1] = NFT_3_1

    ISellPool.add_nft_to_pool(contract_address, 2, COLLECTIONS, 2, NFTS)

    let (start_id_collection_3) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_3)
    let (list_element_2_1) = ISellPool.get_list_element_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_2_NFT_2_1)
    let (list_element_2_2) = ISellPool.get_list_element_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2)
    let (list_element_3_1) = ISellPool.get_list_element_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_3_NFT_3_1)

    assert start_id_collection_3 = LIST_ELEMENT_ID_COLLECTION_3_NFT_3_1
    assert list_element_2_1[0] = NFT_2_1
    assert list_element_2_1[1] = LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2
    assert list_element_2_2[0] = NFT_2_2
    assert list_element_2_2[1] = ZERO_ID
    assert list_element_3_1[0] = NFT_3_1
    assert list_element_3_1[1] = ZERO_ID

    return ()
end


@external
func test_mismatch_array_lengths{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local contract_address
    %{ ids.contract_address = context.contract_address %}

    const COLLECTION_2 = 2222222222
    const COLLECTION_3 = 3333333333
    const NFT_2_2 = 22
    const NFT_3_1 = 31

    let (MISMATCH_COLLECTIONS) = alloc()
    assert [MISMATCH_COLLECTIONS] = COLLECTION_2

    let (MISMATCH_NFTS) = alloc()
    assert [MISMATCH_NFTS] = NFT_2_2
    assert [MISMATCH_NFTS + 1] = NFT_3_1

    %{ expect_revert(error_message="Collection and NFT array lengths don't match.") %}
    ISellPool.add_nft_to_pool(contract_address, 1, MISMATCH_COLLECTIONS, 2, MISMATCH_NFTS)

    return ()
end


@external
func test_remove_nft_from_pool{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local contract_address
    %{ ids.contract_address = context.contract_address %}

    const COLLECTION_1 = 1111111111
    const COLLECTION_2 = 2222222222
    const COLLECTION_3 = 3333333333
    const NFT_1_1 = 11
    const NFT_1_2 = 12
    const NFT_2_1 = 21
    const NFT_2_2 = 22
    const NFT_3_1 = 31
    const ZERO_ID = 0
    const LIST_ELEMENT_ID_COLLECTION_1_NFT_1_1 = 1
    const LIST_ELEMENT_ID_COLLECTION_2_NFT_2_1 = 2
    const LIST_ELEMENT_ID_COLLECTION_1_NFT_1_2 = 3
    const LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2 = 4
    const LIST_ELEMENT_ID_COLLECTION_3_NFT_3_1 = 5

    let (COLLECTIONS_ADD) = alloc()
    assert [COLLECTIONS_ADD] = COLLECTION_2
    assert [COLLECTIONS_ADD + 1] = COLLECTION_3

    let (NFTS_ADD) = alloc()
    assert [NFTS_ADD] = NFT_2_2
    assert [NFTS_ADD + 1] = NFT_3_1

    ISellPool.add_nft_to_pool(contract_address, 2, COLLECTIONS_ADD, 2, NFTS_ADD)

    let (start_id_collection_3) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_3)
    let (list_element_2_1) = ISellPool.get_list_element_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_2_NFT_2_1)
    let (list_element_2_2) = ISellPool.get_list_element_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2)
    let (list_element_3_1) = ISellPool.get_list_element_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_3_NFT_3_1)

    assert start_id_collection_3 = LIST_ELEMENT_ID_COLLECTION_3_NFT_3_1
    assert list_element_2_1[0] = NFT_2_1
    assert list_element_2_1[1] = LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2
    assert list_element_2_2[0] = NFT_2_2
    assert list_element_2_2[1] = ZERO_ID
    assert list_element_3_1[0] = NFT_3_1
    assert list_element_3_1[1] = ZERO_ID


    let (COLLECTIONS_REMOVE) = alloc()
    assert [COLLECTIONS_REMOVE] = COLLECTION_1
    assert [COLLECTIONS_REMOVE + 1] = COLLECTION_2

    let (NFTS_REMOVE) = alloc()
    assert [NFTS_REMOVE] = NFT_1_2
    assert [NFTS_REMOVE + 1] = NFT_2_1

    ISellPool.remove_nft_from_pool(contract_address, 2, COLLECTIONS_REMOVE, 2, NFTS_REMOVE)

    let (new_start_id_collection_1) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_1)
    let (new_start_id_collection_2) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_2)
    let (list_element_1_1) = ISellPool.get_list_element_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_1_NFT_1_1)
    let (list_element_1_2) = ISellPool.get_list_element_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_1_NFT_1_2)
    let (list_element_2_1) = ISellPool.get_list_element_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_2_NFT_2_1)
    let (list_element_2_2) = ISellPool.get_list_element_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2)
    

    assert new_start_id_collection_1 = LIST_ELEMENT_ID_COLLECTION_1_NFT_1_1
    assert new_start_id_collection_2 = LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2
    
    assert list_element_1_1[0] = NFT_1_1
    assert list_element_1_1[1] = ZERO_ID
    assert list_element_1_2[0] = ZERO_ID
    assert list_element_1_2[1] = ZERO_ID
    assert list_element_2_1[0] = ZERO_ID
    assert list_element_2_1[1] = ZERO_ID
    assert list_element_2_2[0] = NFT_2_2
    assert list_element_2_2[1] = ZERO_ID

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

    const ZERO_ID = 0
    const LIST_ELEMENT_ID_COLLECTION_1_NFT_1_1 = 1
    const OLD_ETH_BALANCE = 0
    const NEW_ETH_BALANCE = 21
    
    let (COLLECTIONS_BUY) = alloc()
    assert [COLLECTIONS_BUY] = COLLECTION_1
    assert [COLLECTIONS_BUY + 1] = COLLECTION_1

    let (NFTS_BUY) = alloc()
    assert [NFTS_BUY] = NFT_1_1
    assert [NFTS_BUY + 1] = NFT_1_2

    let (old_eth_balance) = ISellPool.get_eth_balance(contract_address)
    let (start_id_collection_1) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_1)
    assert old_eth_balance = OLD_ETH_BALANCE
    assert start_id_collection_1 = LIST_ELEMENT_ID_COLLECTION_1_NFT_1_1


    ISellPool.buy_nfts(contract_address, 2, COLLECTIONS_BUY, 2, NFTS_BUY)

    let (new_eth_balance) = ISellPool.get_eth_balance(contract_address)
    let (new_start_id_collection_1) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_1)
    #assert new_eth_balance = NEW_ETH_BALANCE
    assert new_start_id_collection_1 = ZERO_ID

    return ()
end