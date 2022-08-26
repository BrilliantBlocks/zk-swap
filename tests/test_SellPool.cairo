%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_contract_address

from src.pools.sell.ISellPool import ISellPool
from src.pools.sell.SellPool import NFT

from lib.cairo_contracts.src.openzeppelin.token.erc721.IERC721Metadata import IERC721Metadata
from lib.cairo_contracts.src.openzeppelin.token.erc721.IERC721 import IERC721


const POOL_FACTORY = 123456789
const CURRENT_PRICE = 10
const DELTA = 1

const C1_NAME = 'COLLECTION 1'
const C2_NAME = 'COLLECTION 2'
const C3_NAME = 'COLLECTION 3'
const C1_SYMBOL = 'C1'
const C2_SYMBOL = 'C2'
const C3_SYMBOL = 'C3'
const ERC721_TOKEN_OWNER = 321


@view
func __setup__{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals
    let (ERC721_CONTRACT_OWNER) = get_contract_address()

    %{
        context.linear_curve_class_hash = declare("./src/bonding-curves/linear/LinearCurve.cairo").class_hash

        context.sell_pool_contract_address = deploy_contract("./src/pools/sell/SellPool.cairo", 
            [
                ids.POOL_FACTORY, ids.CURRENT_PRICE, ids.DELTA, context.linear_curve_class_hash
            ]
        ).contract_address


        context.c1_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo", 
            [ 
                ids.C1_NAME, ids.C1_SYMBOL, ids.ERC721_CONTRACT_OWNER
            ]
        ).contract_address

        context.c2_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo", 
            [ 
                ids.C2_NAME, ids.C2_SYMBOL, ids.ERC721_CONTRACT_OWNER
            ]
        ).contract_address

        context.c3_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo", 
            [ 
                ids.C3_NAME, ids.C3_SYMBOL, ids.ERC721_CONTRACT_OWNER
            ]
        ).contract_address

    %}

    local c1_contract_address
    local c2_contract_address
    local c3_contract_address
    %{ 
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.c3_contract_address = context.c3_contract_address
    %}
    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    let NFT_2_1 = Uint256(21, 0)
    let NFT_2_2 = Uint256(22, 0)
    let NFT_3_1 = Uint256(31, 0)
    
    ISellPool.mint(c1_contract_address, ERC721_TOKEN_OWNER, NFT_1_1)
    ISellPool.mint(c1_contract_address, ERC721_TOKEN_OWNER, NFT_1_2)
    ISellPool.mint(c2_contract_address, ERC721_TOKEN_OWNER, NFT_2_1)
    ISellPool.mint(c2_contract_address, ERC721_TOKEN_OWNER, NFT_2_2)
    ISellPool.mint(c3_contract_address, ERC721_TOKEN_OWNER, NFT_3_1)

    return ()
end 


@external
func test_initialization_ERC721{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local c1_contract_address
    local c2_contract_address
    local c3_contract_address
    %{ 
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.c3_contract_address = context.c3_contract_address
    %}

    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    let NFT_2_1 = Uint256(21, 0)
    let NFT_2_2 = Uint256(22, 0)
    let NFT_3_1 = Uint256(31, 0)

    let (c1_balance) = IERC721.balanceOf(c1_contract_address, ERC721_TOKEN_OWNER)
    let (c2_balance) = IERC721.balanceOf(c2_contract_address, ERC721_TOKEN_OWNER)
    let (c3_balance) = IERC721.balanceOf(c3_contract_address, ERC721_TOKEN_OWNER)
    let (c1_token_owner) = IERC721.ownerOf(c1_contract_address, NFT_1_1)
    let (c2_token_owner) = IERC721.ownerOf(c2_contract_address, NFT_2_1)
    let (c3_token_owner) = IERC721.ownerOf(c3_contract_address, NFT_3_1)
    
    assert c1_balance = Uint256(2, 0)
    assert c2_balance = Uint256(2, 0)
    assert c3_balance = Uint256(1, 0)
    assert c1_token_owner = ERC721_TOKEN_OWNER
    assert c2_token_owner = ERC721_TOKEN_OWNER
    assert c3_token_owner = ERC721_TOKEN_OWNER
    
    return ()
end


@external
func test_initialization_with_expected_output{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local sell_pool_contract_address
    %{ ids.sell_pool_contract_address = context.sell_pool_contract_address %}

    let (pool_factory) = ISellPool.getPoolFactory(sell_pool_contract_address)
    let (current_price, delta) = ISellPool.getPoolConfig(sell_pool_contract_address)
    
    assert pool_factory = POOL_FACTORY
    assert current_price = CURRENT_PRICE
    assert delta = DELTA
    
    return ()
end


@external
func test_getPoolConfig_with_expected_output{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local sell_pool_contract_address
    %{ ids.sell_pool_contract_address = context.sell_pool_contract_address %}

    let (pool_factory) = ISellPool.getPoolFactory(sell_pool_contract_address)
    let (current_price, delta) = ISellPool.getPoolConfig(sell_pool_contract_address)

    assert pool_factory = POOL_FACTORY
    assert current_price = CURRENT_PRICE
    assert delta = DELTA

    return ()
end


@external
func test_addNftToPool{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local c1_contract_address
    local c2_contract_address
    local c3_contract_address

    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.c3_contract_address = context.c3_contract_address
    %}

    let COLLECTION_1 = c1_contract_address
    let COLLECTION_2 = c2_contract_address
    let COLLECTION_3 = c3_contract_address
    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    let NFT_2_1 = Uint256(21, 0)
    let NFT_2_2 = Uint256(22, 0)
    let NFT_3_1 = Uint256(31, 0)
    let ZERO_UINT = Uint256(0, 0)
    const ZERO_FELT = 0
    const COLLECTION_ARRAY_LEN = 2
    const NFT_COLLECTION_1_ARRAY_LEN = 2
    const NFT_COLLECTION_2_ARRAY_LEN = 1

    let (NFT_ARRAY_1 : NFT*) = alloc()
    assert NFT_ARRAY_1[0] = NFT(address = COLLECTION_1, id = NFT_1_1)
    assert NFT_ARRAY_1[1] = NFT(address = COLLECTION_2, id = NFT_2_1)
    assert NFT_ARRAY_1[2] = NFT(address = COLLECTION_1, id = NFT_1_2)

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.setApprovalForAll(c1_contract_address, sell_pool_contract_address, 1)
    IERC721.setApprovalForAll(c2_contract_address, sell_pool_contract_address, 1)
    ISellPool.addNftToPool(sell_pool_contract_address, 3, NFT_ARRAY_1)
    %{ stop_prank_callable() %}

    let (pool_factory) = ISellPool.getPoolFactory(sell_pool_contract_address)
    let (current_price, delta) = ISellPool.getPoolConfig(sell_pool_contract_address)
    let (start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_1)
    let (start_id_collection_2) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_2)
    let list_element_1 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 1)
    let list_element_2 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 2)
    let list_element_3 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 3)
    let (collection_address_1) = ISellPool.getCollectionById(sell_pool_contract_address, 0)
    let (collection_address_2) = ISellPool.getCollectionById(sell_pool_contract_address, 1)
    let (collection_array_len, collection_array) = ISellPool.getAllCollections(sell_pool_contract_address)
    let (nft_collection_1_id_list_len: felt, nft_collection_1_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_1)
    let (nft_collection_2_id_list_len: felt, nft_collection_2_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_2)
    let (nft_collection_3_id_list_len: felt, nft_collection_3_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_3)
    let (pool_balance_c1) = IERC721.balanceOf(c1_contract_address, sell_pool_contract_address)
    let (pool_balance_c2) = IERC721.balanceOf(c2_contract_address, sell_pool_contract_address)
    let (new_owner_c1) = IERC721.ownerOf(c1_contract_address, NFT_1_1)
    let (new_owner_c2) = IERC721.ownerOf(c2_contract_address, NFT_2_1)

    assert pool_factory = POOL_FACTORY
    assert current_price = CURRENT_PRICE
    assert delta = DELTA
    assert start_id_collection_1 = 1
    assert start_id_collection_2 = 2
    assert list_element_1[0] = NFT_1_1
    assert list_element_1[1] = 3
    assert list_element_2[0] = NFT_2_1
    assert list_element_2[1] = ZERO_FELT
    assert list_element_3[0] = NFT_1_2
    assert list_element_3[1] = ZERO_FELT
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
    assert nft_collection_3_id_list_len = ZERO_FELT
    assert pool_balance_c1 = Uint256(2, 0)
    assert pool_balance_c2 = Uint256(1, 0)
    assert new_owner_c1 = sell_pool_contract_address
    assert new_owner_c2 = sell_pool_contract_address

    let (NFT_ARRAY_2 : NFT*) = alloc()
    assert NFT_ARRAY_2[0] = NFT(address = COLLECTION_2, id = NFT_2_2)
    assert NFT_ARRAY_2[1] = NFT(address = COLLECTION_3, id = NFT_3_1)

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c3_contract_address)
        stop_prank_callable = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.setApprovalForAll(c3_contract_address, sell_pool_contract_address, 1)
    ISellPool.addNftToPool(sell_pool_contract_address, 2, NFT_ARRAY_2)
    %{ stop_prank_callable() %}

    let (start_id_collection_3) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_3)
    let list_element_2 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 2)
    let list_element_4 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 4)
    let list_element_5 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 5)
    let (pool_balance_c3) = IERC721.balanceOf(c3_contract_address, sell_pool_contract_address)
    let (new_owner_c3) = IERC721.ownerOf(c3_contract_address, NFT_3_1)

    assert start_id_collection_3 = 5
    assert list_element_2[0] = NFT_2_1
    assert list_element_2[1] = 4
    assert list_element_4[0] = NFT_2_2
    assert list_element_4[1] = ZERO_FELT
    assert list_element_5[0] = NFT_3_1
    assert list_element_5[1] = ZERO_FELT
    assert pool_balance_c3 = Uint256(1, 0)
    assert new_owner_c3 = sell_pool_contract_address
    
    return ()
end


@external
func test_removeNftFromPool{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local c1_contract_address
    local c2_contract_address
    local c3_contract_address

    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.c3_contract_address = context.c3_contract_address
    %}

    let COLLECTION_1 = c1_contract_address
    let COLLECTION_2 = c2_contract_address
    let COLLECTION_3 = c3_contract_address
    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    let NFT_2_1 = Uint256(21, 0)
    let NFT_2_2 = Uint256(22, 0)
    let NFT_3_1 = Uint256(31, 0)
    let ZERO_UINT = Uint256(0, 0)
    const ZERO_FELT = 0

    let (NFT_ARRAY_ADD : NFT*) = alloc()

    assert NFT_ARRAY_ADD[0] = NFT(address = COLLECTION_1, id = NFT_1_1)
    assert NFT_ARRAY_ADD[1] = NFT(address = COLLECTION_2, id = NFT_2_1)
    assert NFT_ARRAY_ADD[2] = NFT(address = COLLECTION_1, id = NFT_1_2)
    assert NFT_ARRAY_ADD[3] = NFT(address = COLLECTION_2, id = NFT_2_2)
    assert NFT_ARRAY_ADD[4] = NFT(address = COLLECTION_3, id = NFT_3_1)

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c3_contract_address)
        stop_prank_callable = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.setApprovalForAll(c1_contract_address, sell_pool_contract_address, 1)
    IERC721.setApprovalForAll(c2_contract_address, sell_pool_contract_address, 1)
    IERC721.setApprovalForAll(c3_contract_address, sell_pool_contract_address, 1)
    ISellPool.addNftToPool(sell_pool_contract_address, 5, NFT_ARRAY_ADD)
    %{ stop_prank_callable() %}

    let (pool_factory) = ISellPool.getPoolFactory(sell_pool_contract_address)
    let (current_price, delta) = ISellPool.getPoolConfig(sell_pool_contract_address)
    let (start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_1)
    let (start_id_collection_2) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_2)
    let (start_id_collection_3) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_3)
    let list_element_1 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 1)
    let list_element_2 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 2)
    let list_element_3 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 3)
    let list_element_4 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 4)
    let list_element_5 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 5)
    let (collection_address_1) = ISellPool.getCollectionById(sell_pool_contract_address, 0)
    let (collection_address_2) = ISellPool.getCollectionById(sell_pool_contract_address, 1)
    let (collection_array_len, collection_array) = ISellPool.getAllCollections(sell_pool_contract_address)
    let (nft_collection_1_id_list_len: felt, nft_collection_1_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_1)
    let (nft_collection_2_id_list_len: felt, nft_collection_2_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_2)
    let (nft_collection_3_id_list_len: felt, nft_collection_3_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_3)

    assert pool_factory = POOL_FACTORY
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
    assert list_element_3[1] = ZERO_FELT
    assert list_element_4[0] = NFT_2_2
    assert list_element_4[1] = ZERO_FELT
    assert list_element_5[0] = NFT_3_1
    assert list_element_5[1] = ZERO_FELT
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
    
    ISellPool.removeNftFromPool(sell_pool_contract_address, 2, NFT_ARRAY_REMOVE)

    let (new_start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_1)
    let (new_start_id_collection_2) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_2)
    let list_element_1 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 1)
    let list_element_2 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 2)
    let list_element_3 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 3)
    let list_element_4 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 4)
    let (collection_array_len, collection_array) = ISellPool.getAllCollections(sell_pool_contract_address)
    let (nft_collection_1_id_list_len: felt, nft_collection_1_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_1)
    let (nft_collection_2_id_list_len: felt, nft_collection_2_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_2)
    let (nft_collection_3_id_list_len: felt, nft_collection_3_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_3)
    
    assert new_start_id_collection_1 = 1
    assert new_start_id_collection_2 = 4
    assert list_element_1[0] = NFT_1_1
    assert list_element_1[1] = ZERO_FELT
    assert list_element_2[0] = ZERO_UINT
    assert list_element_2[1] = ZERO_FELT
    assert list_element_3[0] = ZERO_UINT
    assert list_element_3[1] = ZERO_FELT
    assert list_element_4[0] = NFT_2_2
    assert list_element_4[1] = ZERO_FELT
    assert list_element_5[0] = NFT_3_1
    assert list_element_5[1] = ZERO_FELT
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
func test_editPool_with_expected_output{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local sell_pool_contract_address
    %{ ids.sell_pool_contract_address = context.sell_pool_contract_address %}

    const NEW_PRICE = 15
    const NEW_DELTA = 2

    let (old_price, old_delta) = ISellPool.getPoolConfig(sell_pool_contract_address)

    assert old_price = CURRENT_PRICE
    assert old_delta = DELTA

    ISellPool.editPool(sell_pool_contract_address, NEW_PRICE, NEW_DELTA)

    let (new_price, new_delta) = ISellPool.getPoolConfig(sell_pool_contract_address)

    assert new_price = NEW_PRICE
    assert new_delta = NEW_DELTA

    return ()
end


@external
func test_editPool_with_negative_price{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local sell_pool_contract_address
    %{ ids.sell_pool_contract_address = context.sell_pool_contract_address %}

    const NEW_NEGATIVE_PRICE = -15
    const NEW_DELTA = 2

    %{ expect_revert(error_message="Price cannot be negative.") %}
    ISellPool.editPool(sell_pool_contract_address, NEW_NEGATIVE_PRICE, NEW_DELTA)

    return ()
end


@external
func test_buyNfts{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local c1_contract_address

    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
    %}

    let COLLECTION_1 = c1_contract_address
    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    const ZERO_FELT = 0
    const OLD_ETH_BALANCE = 0
    const NEW_ETH_BALANCE = 21
    const OLD_PRICE = 10
    const NEW_PRICE = 12
    
    let (NFT_ARRAY : NFT*) = alloc()
    assert NFT_ARRAY[0] = NFT(address = COLLECTION_1, id = NFT_1_1)
    assert NFT_ARRAY[1] = NFT(address = COLLECTION_1, id = NFT_1_2)

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.setApprovalForAll(c1_contract_address, sell_pool_contract_address, 1)
    ISellPool.addNftToPool(sell_pool_contract_address, 2, NFT_ARRAY)
    %{ stop_prank_callable() %}

    let (old_eth_balance) = ISellPool.getEthBalance(sell_pool_contract_address)
    let (start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_1)
    let (old_price, delta) = ISellPool.getPoolConfig(sell_pool_contract_address)
    
    assert old_eth_balance = OLD_ETH_BALANCE
    assert start_id_collection_1 = 1
    assert old_price = OLD_PRICE

    ISellPool.buyNfts(sell_pool_contract_address, 2, NFT_ARRAY)

    let (new_eth_balance) = ISellPool.getEthBalance(sell_pool_contract_address)
    let (new_start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_1)
    let (new_price, delta) = ISellPool.getPoolConfig(sell_pool_contract_address)
    
    assert new_eth_balance = NEW_ETH_BALANCE
    assert new_start_id_collection_1 = ZERO_FELT
    assert new_price = NEW_PRICE

    return ()
end


@external
func test_buyNfts_with_toggling_pool_pause{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local c1_contract_address

    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
    %}

    let COLLECTION_1 = c1_contract_address
    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    const ZERO_FELT = 0
    const OLD_ETH_BALANCE = 0
    const NEW_ETH_BALANCE = 21
    const OLD_PRICE = 10
    const NEW_PRICE = 12
    
    let (NFT_ARRAY : NFT*) = alloc()
    assert NFT_ARRAY[0] = NFT(address = COLLECTION_1, id = NFT_1_1)
    assert NFT_ARRAY[1] = NFT(address = COLLECTION_1, id = NFT_1_2)
    
    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.setApprovalForAll(c1_contract_address, sell_pool_contract_address, 1)
    ISellPool.addNftToPool(sell_pool_contract_address, 2, NFT_ARRAY)
    %{ stop_prank_callable() %}

    let (old_eth_balance) = ISellPool.getEthBalance(sell_pool_contract_address)
    let (start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_1)
    let (old_price, delta) = ISellPool.getPoolConfig(sell_pool_contract_address)
    let (is_paused) = ISellPool.isPaused(sell_pool_contract_address)
    
    assert old_eth_balance = OLD_ETH_BALANCE
    assert start_id_collection_1 = 1
    assert old_price = OLD_PRICE
    assert is_paused = FALSE

    ISellPool.togglePause(sell_pool_contract_address)
    let (is_paused) = ISellPool.isPaused(sell_pool_contract_address)
    assert is_paused = TRUE

    %{ expect_revert(error_message="Pool is currently paused.") %}
    ISellPool.buyNfts(sell_pool_contract_address, 2, NFT_ARRAY)

    ISellPool.togglePause(sell_pool_contract_address)

    ISellPool.buyNfts(sell_pool_contract_address, 2, NFT_ARRAY)

    let (new_eth_balance) = ISellPool.getEthBalance(sell_pool_contract_address)
    let (new_start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_1)
    let (new_price, delta) = ISellPool.getPoolConfig(sell_pool_contract_address)
    let (is_paused) = ISellPool.isPaused(sell_pool_contract_address)
    
    assert new_eth_balance = NEW_ETH_BALANCE
    assert new_start_id_collection_1 = ZERO_FELT
    assert new_price = NEW_PRICE
    assert is_paused = FALSE

    return ()
end


@external
func test_getNextPrice_with_expected_output{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local sell_pool_contract_address
    %{ ids.sell_pool_contract_address = context.sell_pool_contract_address %}

    const NEXT_PRICE = 11

    let (next_price) = ISellPool.getNextPrice(sell_pool_contract_address)

    assert next_price = NEXT_PRICE

    return ()
end