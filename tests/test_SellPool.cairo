%lang starknet

from src.ISellPool import ISellPool
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc



const OWNER = 123456789
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
const LIST_ELEMENT_ID_COLLECTION_1_NFT_1_1 = 1
const LIST_ELEMENT_ID_COLLECTION_2_NFT_2_1 = 2
const LIST_ELEMENT_ID_COLLECTION_1_NFT_1_2 = 3
const LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2 = 4
const LIST_ELEMENT_ID_COLLECTION_3_NFT_3_1 = 5



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

    let (owner) = ISellPool.get_pool_owner(contract_address)
    let (current_price) = ISellPool.get_current_price(contract_address)
    let (delta) = ISellPool.get_delta(contract_address)
    let (start_id_collection_1) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_1)
    let (start_id_collection_2) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_2)
    let (tuple_1_1) = ISellPool.get_tupel_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_1_NFT_1_1)
    let (tuple_2_1) = ISellPool.get_tupel_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_2_NFT_2_1)
    let (tuple_1_2) = ISellPool.get_tupel_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_1_NFT_1_2)

    assert owner = OWNER
    assert current_price = CURRENT_PRICE
    assert delta = DELTA
    assert start_id_collection_1 = LIST_ELEMENT_ID_COLLECTION_1_NFT_1_1
    assert start_id_collection_2 = LIST_ELEMENT_ID_COLLECTION_2_NFT_2_1
    assert tuple_1_1[0] = NFT_1_1
    assert tuple_1_1[1] = LIST_ELEMENT_ID_COLLECTION_1_NFT_1_2
    assert tuple_2_1[0] = NFT_2_1
    assert tuple_2_1[1] = ZERO_ID
    assert tuple_1_2[0] = NFT_1_2
    assert tuple_1_2[1] = ZERO_ID
    
    return ()
end


@external
func test_add_nft_to_pool{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local contract_address
    %{ ids.contract_address = context.contract_address %}

    let (COLLECTIONS) = alloc()
    assert [COLLECTIONS] = COLLECTION_2
    assert [COLLECTIONS + 1] = COLLECTION_3

    let (NFTS) = alloc()
    assert [NFTS] = NFT_2_2
    assert [NFTS + 1] = NFT_3_1

    ISellPool.add_nft_to_pool(contract_address, 2, COLLECTIONS, 2, NFTS)

    let (start_id_collection_3) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_3)
    let (tuple_2_1) = ISellPool.get_tupel_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_2_NFT_2_1)
    let (tuple_2_2) = ISellPool.get_tupel_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2)
    let (tuple_3_1) = ISellPool.get_tupel_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_3_NFT_3_1)

    assert start_id_collection_3 = LIST_ELEMENT_ID_COLLECTION_3_NFT_3_1
    assert tuple_2_1[0] = NFT_2_1
    assert tuple_2_1[1] = LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2
    assert tuple_2_2[0] = NFT_2_2
    assert tuple_2_2[1] = ZERO_ID
    assert tuple_3_1[0] = NFT_3_1
    assert tuple_3_1[1] = ZERO_ID

    return ()
end


@external
func test_mismatch_array_lengths{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local contract_address
    %{ ids.contract_address = context.contract_address %}

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

    let (COLLECTIONS_ADD) = alloc()
    assert [COLLECTIONS_ADD] = COLLECTION_2
    assert [COLLECTIONS_ADD + 1] = COLLECTION_3

    let (NFTS_ADD) = alloc()
    assert [NFTS_ADD] = NFT_2_2
    assert [NFTS_ADD + 1] = NFT_3_1

    ISellPool.add_nft_to_pool(contract_address, 2, COLLECTIONS_ADD, 2, NFTS_ADD)

    let (start_id_collection_3) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_3)
    let (tuple_2_1) = ISellPool.get_tupel_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_2_NFT_2_1)
    let (tuple_2_2) = ISellPool.get_tupel_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2)
    let (tuple_3_1) = ISellPool.get_tupel_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_3_NFT_3_1)

    assert start_id_collection_3 = LIST_ELEMENT_ID_COLLECTION_3_NFT_3_1
    assert tuple_2_1[0] = NFT_2_1
    assert tuple_2_1[1] = LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2
    assert tuple_2_2[0] = NFT_2_2
    assert tuple_2_2[1] = ZERO_ID
    assert tuple_3_1[0] = NFT_3_1
    assert tuple_3_1[1] = ZERO_ID


    let (COLLECTIONS_REMOVE) = alloc()
    assert [COLLECTIONS_REMOVE] = COLLECTION_1
    assert [COLLECTIONS_REMOVE + 1] = COLLECTION_2

    let (NFTS_REMOVE) = alloc()
    assert [NFTS_REMOVE] = NFT_1_2
    assert [NFTS_REMOVE + 1] = NFT_2_1

    ISellPool.remove_nft_from_pool(contract_address, 2, COLLECTIONS_REMOVE, 2, NFTS_REMOVE)

    let (new_start_id_collection_1) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_1)
    let (new_start_id_collection_2) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_2)
    let (tuple_1_1) = ISellPool.get_tupel_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_1_NFT_1_1)
    let (tuple_1_2) = ISellPool.get_tupel_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_1_NFT_1_2)
    let (tuple_2_1) = ISellPool.get_tupel_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_2_NFT_2_1)
    let (tuple_2_2) = ISellPool.get_tupel_by_id(contract_address, LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2)
    

    assert new_start_id_collection_1 = LIST_ELEMENT_ID_COLLECTION_1_NFT_1_1
    assert new_start_id_collection_2 = LIST_ELEMENT_ID_COLLECTION_2_NFT_2_2
    
    assert tuple_1_1[0] = NFT_1_1
    assert tuple_1_1[1] = ZERO_ID
    assert tuple_1_2[0] = ZERO_ID
    assert tuple_1_2[1] = ZERO_ID
    assert tuple_2_1[0] = ZERO_ID
    assert tuple_2_1[1] = ZERO_ID
    assert tuple_2_2[0] = NFT_2_2
    assert tuple_2_2[1] = ZERO_ID

    return ()
end


# @external
# func test_negative_values{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

#     alloc_locals 

#     local contract_address
#     %{ ids.contract_address = context.contract_address %}

#     let (NEGATIVE_COLLECTIONS) = alloc()
#     assert [NEGATIVE_COLLECTIONS] = COLLECTION_2
#     assert [NEGATIVE_COLLECTIONS + 1] = COLLECTION_2

#     let (NEGATIVE_NFTS) = alloc()
#     assert [NEGATIVE_NFTS] = NFT_2_2
#     assert [NEGATIVE_NFTS + 1] = -1

#     %{ expect_revert(error_message="Values cannot be negative.") %}
#     ISellPool.add_nft_to_pool(contract_address, 2, NEGATIVE_COLLECTIONS, 2, NEGATIVE_NFTS)

#     return ()
# end