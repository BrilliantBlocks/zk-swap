%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import FALSE, TRUE

from lib.cairo_contracts.src.openzeppelin.token.erc721.IERC721Metadata import IERC721Metadata
from lib.cairo_contracts.src.openzeppelin.token.erc721.IERC721 import IERC721
from lib.cairo_contracts.src.openzeppelin.token.erc20.IERC20 import IERC20

from src.pools.IPool import IPool, NFT, PoolParams
from tests.helper.IMintPool import Collection, IMintPool
from src.utils.Constants import DeltaSign

const C1_NAME = 'COLLECTION 1';
const C2_NAME = 'COLLECTION 2';
const C3_NAME = 'COLLECTION 3';
const ERC20_NAME = 'ERC20 Test Contract';
const C1_SYMBOL = 'C1';
const C2_SYMBOL = 'C2';
const C3_SYMBOL = 'C3';
const ERC20_SYMBOL = 'ERC20';
const DECIMALS = 4;
const INITIAL_SUPPLY_LOW = 500000;
const INITIAL_SUPPLY_HIGH = 0;
const POOL_FACTORY_AND_ERC_CONTRACT_OWNER = 192837465;
const POOL_AND_NFT_OWNER = 123456789;
const NFT_BUYER = 987654321;

@view
func __setup__{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    %{
        context.c1_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo", 
            [ 
                ids.C1_NAME, ids.C1_SYMBOL, ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
        ).contract_address

        context.c2_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo", 
            [ 
                ids.C2_NAME, ids.C2_SYMBOL, ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
        ).contract_address

        context.c3_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo", 
            [ 
                ids.C3_NAME, ids.C3_SYMBOL, ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
        ).contract_address

        context.erc20_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/presets/ERC20Mintable.cairo", 
            [ 
                ids.ERC20_NAME, ids.ERC20_SYMBOL, ids.DECIMALS, ids.INITIAL_SUPPLY_LOW, ids.INITIAL_SUPPLY_HIGH, ids.NFT_BUYER, ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
        ).contract_address


        context.pool_factory_contract_address = deploy_contract("./tests/helper/MintPool.cairo", 
            [
                ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
        ).contract_address

        context.sell_pool_class_hash = declare("./src/pools/SellPool.cairo").class_hash

        context.linear_curve_class_hash = declare("./src/bonding_curves/LinearCurve.cairo").class_hash
    %}

    local sell_pool_class_hash;
    local linear_curve_class_hash;
    local c1_contract_address;
    local c2_contract_address;
    local c3_contract_address;
    local erc20_contract_address;
    local pool_factory_contract_address;
    %{
        ids.sell_pool_class_hash = context.sell_pool_class_hash
        ids.linear_curve_class_hash = context.linear_curve_class_hash 
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.c3_contract_address = context.c3_contract_address
        ids.erc20_contract_address = context.erc20_contract_address
        ids.pool_factory_contract_address = context.pool_factory_contract_address
    %}

    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    let NFT_2_1 = Uint256(21, 0);
    let NFT_2_2 = Uint256(22, 0);
    let NFT_3_1 = Uint256(31, 0);
    tempvar POOL_PARAMS: PoolParams = PoolParams(price=Uint256(100000, 0), delta=10000);

    let (SUPPORTED_COLLECTIONS: felt*) = alloc();
    assert SUPPORTED_COLLECTIONS[0] = c1_contract_address;
    assert SUPPORTED_COLLECTIONS[1] = c2_contract_address;
    assert SUPPORTED_COLLECTIONS[2] = c3_contract_address;

    %{
        POOL_FACTORY_AND_ERC_CONTRACT_OWNER = 192837465
        stop_prank_callable_1 = start_prank(POOL_FACTORY_AND_ERC_CONTRACT_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(POOL_FACTORY_AND_ERC_CONTRACT_OWNER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable_3 = start_prank(POOL_FACTORY_AND_ERC_CONTRACT_OWNER, target_contract_address=ids.c3_contract_address)
        stop_prank_callable_4 = start_prank(POOL_FACTORY_AND_ERC_CONTRACT_OWNER, target_contract_address=ids.erc20_contract_address)
    %}
    IPool.mint(c1_contract_address, POOL_AND_NFT_OWNER, NFT_1_1);
    IPool.mint(c1_contract_address, POOL_AND_NFT_OWNER, NFT_1_2);
    IPool.mint(c2_contract_address, POOL_AND_NFT_OWNER, NFT_2_1);
    IPool.mint(c2_contract_address, POOL_AND_NFT_OWNER, NFT_2_2);
    IPool.mint(c3_contract_address, POOL_AND_NFT_OWNER, NFT_3_1);
    IPool.mint(erc20_contract_address, POOL_AND_NFT_OWNER, Uint256(300000, 0));
    %{
        stop_prank_callable_1() 
        stop_prank_callable_2()
        stop_prank_callable_3()
        stop_prank_callable_4()
    %}

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_1 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.pool_factory_contract_address)
    %}
    let (sell_pool_contract_address) = IMintPool.mint(
        pool_factory_contract_address,
        sell_pool_class_hash,
        linear_curve_class_hash,
        erc20_contract_address,
    );
    %{ stop_prank_callable_1() %}

    %{ context.sell_pool_contract_address = ids.sell_pool_contract_address %}

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_2 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IPool.setPoolParams(sell_pool_contract_address, POOL_PARAMS);
    IPool.addSupportedCollections(sell_pool_contract_address, 3, SUPPORTED_COLLECTIONS);
    %{ stop_prank_callable_2() %}

    return ();
}

@external
func test_initialization_pool_factory{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    alloc_locals;
    local pool_factory_contract_address;
    local sell_pool_contract_address;
    local sell_pool_class_hash;
    %{
        ids.pool_factory_contract_address = context.pool_factory_contract_address 
        ids.sell_pool_contract_address = context.sell_pool_contract_address 
        ids.sell_pool_class_hash = context.sell_pool_class_hash
    %}    

    let (factory_owner) = IMintPool.getFactoryOwner(pool_factory_contract_address);
    let (pool_type_class_hash) = IMintPool.getPoolTypeClassHash(
        pool_factory_contract_address, sell_pool_contract_address
    );
    let (
        collection_array_len: felt, collection_array: Collection*
    ) = IMintPool.getAllCollectionsFromAllPools(pool_factory_contract_address);

    assert factory_owner = POOL_FACTORY_AND_ERC_CONTRACT_OWNER;
    assert pool_type_class_hash = sell_pool_class_hash;
    assert collection_array_len = 0;

    return ();
}

@external
func test_getPoolConfig_with_expected_output{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    alloc_locals;
    local pool_factory_contract_address;
    local sell_pool_contract_address;
    %{ 
        ids.pool_factory_contract_address = context.pool_factory_contract_address 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
    %}

    tempvar POOL_PARAMS: PoolParams = PoolParams(price=Uint256(100000, 0), delta=10000);

    let (pool_factory) = IPool.getPoolFactory(sell_pool_contract_address);
    let (pool_params: PoolParams) = IPool.getPoolConfig(sell_pool_contract_address);

    let (high, low) = split_felt(sell_pool_contract_address);
    let sell_pool_contract_address_token = Uint256(low, high);
    let (pool_owner) = IERC721.ownerOf(
        pool_factory_contract_address, sell_pool_contract_address_token
    );

    assert pool_factory = pool_factory_contract_address;
    assert pool_params.price = POOL_PARAMS.price;
    assert pool_params.delta = POOL_PARAMS.delta;
    assert pool_owner = POOL_AND_NFT_OWNER;

    return ();
}

@external
func test_addNftToPool{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    local pool_factory_contract_address;
    local sell_pool_contract_address;
    local c1_contract_address;
    local c2_contract_address;
    local c3_contract_address;
    %{
        ids.pool_factory_contract_address = context.pool_factory_contract_address
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.c3_contract_address = context.c3_contract_address
    %}

    let COLLECTION_1 = c1_contract_address;
    let COLLECTION_2 = c2_contract_address;
    let COLLECTION_3 = c3_contract_address;
    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    let NFT_2_1 = Uint256(21, 0);
    let NFT_2_2 = Uint256(22, 0);
    let NFT_3_1 = Uint256(31, 0);
    let ZERO_UINT = Uint256(0, 0);
    const ZERO_FELT = 0;
    const COLLECTION_ARRAY_LEN = 2;
    const NFT_COLLECTION_1_ARRAY_LEN = 2;
    const NFT_COLLECTION_2_ARRAY_LEN = 1;

    let (NFT_ARRAY_1: NFT*) = alloc();
    assert NFT_ARRAY_1[0] = NFT(address=COLLECTION_1, id=NFT_1_1);
    assert NFT_ARRAY_1[1] = NFT(address=COLLECTION_2, id=NFT_2_1);
    assert NFT_ARRAY_1[2] = NFT(address=COLLECTION_1, id=NFT_1_2);

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_1 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable_3 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1);
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2);
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_1);
    %{
        stop_prank_callable_1() 
        stop_prank_callable_2()
    %}
    IPool.addNftToPool(sell_pool_contract_address, 3, NFT_ARRAY_1);
    %{ stop_prank_callable_3() %}

    let (start_id_collection_1) = IPool.getStartIdByCollection(
        sell_pool_contract_address, COLLECTION_1
    );
    let (start_id_collection_2) = IPool.getStartIdByCollection(
        sell_pool_contract_address, COLLECTION_2
    );
    let list_element_1: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 1);
    let list_element_2: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 2);
    let list_element_3: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 3);
    let (collection_address_1) = IPool.getCollectionById(sell_pool_contract_address, 0);
    let (collection_address_2) = IPool.getCollectionById(sell_pool_contract_address, 1);
    let (collection_array_len, collection_array) = IPool.getAllCollections(
        sell_pool_contract_address
    );
    let (
        nft_collection_1_id_list_len: felt, nft_collection_1_id_list: Uint256*
    ) = IPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_1);
    let (
        nft_collection_2_id_list_len: felt, nft_collection_2_id_list: Uint256*
    ) = IPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_2);
    let (
        nft_collection_3_id_list_len: felt, nft_collection_3_id_list: Uint256*
    ) = IPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_3);
    let (pool_balance_c1) = IERC721.balanceOf(c1_contract_address, sell_pool_contract_address);
    let (pool_balance_c2) = IERC721.balanceOf(c2_contract_address, sell_pool_contract_address);
    let (new_owner_c1) = IERC721.ownerOf(c1_contract_address, NFT_1_1);
    let (new_owner_c2) = IERC721.ownerOf(c2_contract_address, NFT_2_1);

    assert start_id_collection_1 = 1;
    assert start_id_collection_2 = 2;
    assert list_element_1[0] = NFT_1_1;
    assert list_element_1[1] = 3;
    assert list_element_2[0] = NFT_2_1;
    assert list_element_2[1] = ZERO_FELT;
    assert list_element_3[0] = NFT_1_2;
    assert list_element_3[1] = ZERO_FELT;
    assert collection_address_1 = COLLECTION_1;
    assert collection_address_2 = COLLECTION_2;
    assert collection_array_len = COLLECTION_ARRAY_LEN;
    assert collection_array[0] = COLLECTION_1;
    assert collection_array[1] = COLLECTION_2;
    assert nft_collection_1_id_list_len = NFT_COLLECTION_1_ARRAY_LEN;
    assert nft_collection_1_id_list[0] = NFT_1_1;
    assert nft_collection_1_id_list[1] = NFT_1_2;
    assert nft_collection_2_id_list_len = NFT_COLLECTION_2_ARRAY_LEN;
    assert nft_collection_2_id_list[0] = NFT_2_1;
    assert nft_collection_3_id_list_len = ZERO_FELT;
    assert pool_balance_c1 = Uint256(2, 0);
    assert pool_balance_c2 = Uint256(1, 0);
    assert new_owner_c1 = sell_pool_contract_address;
    assert new_owner_c2 = sell_pool_contract_address;

    let (NFT_ARRAY_2: NFT*) = alloc();
    assert NFT_ARRAY_2[0] = NFT(address=COLLECTION_2, id=NFT_2_2);
    assert NFT_ARRAY_2[1] = NFT(address=COLLECTION_3, id=NFT_3_1);

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_1 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c3_contract_address)
        stop_prank_callable_3 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_2);
    IERC721.approve(c3_contract_address, sell_pool_contract_address, NFT_3_1);
    %{
        stop_prank_callable_1()  
        stop_prank_callable_2()
    %}
    IPool.addNftToPool(sell_pool_contract_address, 2, NFT_ARRAY_2);
    %{ stop_prank_callable_3() %}

    let (ALL_COLLECTIONS_FROM_ALL_POOLS_ARRAY: Collection*) = alloc();
    assert ALL_COLLECTIONS_FROM_ALL_POOLS_ARRAY[0] = Collection(
        collection_address=COLLECTION_1, pool_address=sell_pool_contract_address
    );
    assert ALL_COLLECTIONS_FROM_ALL_POOLS_ARRAY[1] = Collection(
        collection_address=COLLECTION_2, pool_address=sell_pool_contract_address
    );
    assert ALL_COLLECTIONS_FROM_ALL_POOLS_ARRAY[2] = Collection(
        collection_address=COLLECTION_3, pool_address=sell_pool_contract_address
    );

    let (start_id_collection_3) = IPool.getStartIdByCollection(
        sell_pool_contract_address, COLLECTION_3
    );
    let list_element_2: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 2);
    let list_element_4: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 4);
    let list_element_5: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 5);
    let (pool_balance_c3) = IERC721.balanceOf(c3_contract_address, sell_pool_contract_address);
    let (new_owner_c3) = IERC721.ownerOf(c3_contract_address, NFT_3_1);
    let (
        all_collections_from_all_pools_array_len: felt,
        all_collections_from_all_pools_array: Collection*,
    ) = IMintPool.getAllCollectionsFromAllPools(pool_factory_contract_address);

    assert start_id_collection_3 = 5;
    assert list_element_2[0] = NFT_2_1;
    assert list_element_2[1] = 4;
    assert list_element_4[0] = NFT_2_2;
    assert list_element_4[1] = ZERO_FELT;
    assert list_element_5[0] = NFT_3_1;
    assert list_element_5[1] = ZERO_FELT;
    assert pool_balance_c3 = Uint256(1, 0);
    assert new_owner_c3 = sell_pool_contract_address;
    assert all_collections_from_all_pools_array_len = 3;
    assert all_collections_from_all_pools_array[0] = ALL_COLLECTIONS_FROM_ALL_POOLS_ARRAY[0];
    assert all_collections_from_all_pools_array[1] = ALL_COLLECTIONS_FROM_ALL_POOLS_ARRAY[1];
    assert all_collections_from_all_pools_array[2] = ALL_COLLECTIONS_FROM_ALL_POOLS_ARRAY[2];

    return ();
}

@external
func test_removeNftFromPool{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    local sell_pool_contract_address;
    local c1_contract_address;
    local c2_contract_address;
    local c3_contract_address;
    %{
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.c3_contract_address = context.c3_contract_address
    %}

    tempvar POOL_PARAMS: PoolParams = PoolParams(price=Uint256(10, 0), delta=1);
    let COLLECTION_1 = c1_contract_address;
    let COLLECTION_2 = c2_contract_address;
    let COLLECTION_3 = c3_contract_address;
    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    let NFT_2_1 = Uint256(21, 0);
    let NFT_2_2 = Uint256(22, 0);
    let NFT_3_1 = Uint256(31, 0);
    let ZERO_UINT = Uint256(0, 0);
    const ZERO_FELT = 0;

    let (NFT_ARRAY_ADD: NFT*) = alloc();

    assert NFT_ARRAY_ADD[0] = NFT(address=COLLECTION_1, id=NFT_1_1);
    assert NFT_ARRAY_ADD[1] = NFT(address=COLLECTION_2, id=NFT_2_1);
    assert NFT_ARRAY_ADD[2] = NFT(address=COLLECTION_1, id=NFT_1_2);
    assert NFT_ARRAY_ADD[3] = NFT(address=COLLECTION_2, id=NFT_2_2);
    assert NFT_ARRAY_ADD[4] = NFT(address=COLLECTION_3, id=NFT_3_1);

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_1 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable_3 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c3_contract_address)
        stop_prank_callable_4 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1);
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2);
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_1);
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_2);
    IERC721.approve(c3_contract_address, sell_pool_contract_address, NFT_3_1);
    %{
        stop_prank_callable_1() 
        stop_prank_callable_2() 
        stop_prank_callable_3()
    %}
    IPool.addNftToPool(sell_pool_contract_address, 5, NFT_ARRAY_ADD);
    %{ stop_prank_callable_4() %}

    let (start_id_collection_1) = IPool.getStartIdByCollection(
        sell_pool_contract_address, COLLECTION_1
    );
    let (start_id_collection_2) = IPool.getStartIdByCollection(
        sell_pool_contract_address, COLLECTION_2
    );
    let (start_id_collection_3) = IPool.getStartIdByCollection(
        sell_pool_contract_address, COLLECTION_3
    );
    let list_element_1: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 1);
    let list_element_2: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 2);
    let list_element_3: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 3);
    let list_element_4: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 4);
    let list_element_5: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 5);
    let (collection_address_1) = IPool.getCollectionById(sell_pool_contract_address, 0);
    let (collection_address_2) = IPool.getCollectionById(sell_pool_contract_address, 1);
    let (collection_array_len, collection_array) = IPool.getAllCollections(
        sell_pool_contract_address
    );
    let (
        nft_collection_1_id_list_len: felt, nft_collection_1_id_list: Uint256*
    ) = IPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_1);
    let (
        nft_collection_2_id_list_len: felt, nft_collection_2_id_list: Uint256*
    ) = IPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_2);
    let (
        nft_collection_3_id_list_len: felt, nft_collection_3_id_list: Uint256*
    ) = IPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_3);
    let (pool_balance_c1) = IERC721.balanceOf(c1_contract_address, sell_pool_contract_address);

    assert start_id_collection_1 = 1;
    assert start_id_collection_2 = 2;
    assert start_id_collection_3 = 5;
    assert list_element_1[0] = NFT_1_1;
    assert list_element_1[1] = 3;
    assert list_element_2[0] = NFT_2_1;
    assert list_element_2[1] = 4;
    assert list_element_3[0] = NFT_1_2;
    assert list_element_3[1] = ZERO_FELT;
    assert list_element_4[0] = NFT_2_2;
    assert list_element_4[1] = ZERO_FELT;
    assert list_element_5[0] = NFT_3_1;
    assert list_element_5[1] = ZERO_FELT;
    assert collection_address_1 = COLLECTION_1;
    assert collection_address_2 = COLLECTION_2;
    assert collection_array_len = 3;
    assert collection_array[0] = COLLECTION_1;
    assert collection_array[1] = COLLECTION_2;
    assert collection_array[2] = COLLECTION_3;
    assert nft_collection_1_id_list_len = 2;
    assert nft_collection_1_id_list[0] = NFT_1_1;
    assert nft_collection_1_id_list[1] = NFT_1_2;
    assert nft_collection_2_id_list_len = 2;
    assert nft_collection_2_id_list[0] = NFT_2_1;
    assert nft_collection_2_id_list[1] = NFT_2_2;
    assert nft_collection_3_id_list_len = 1;
    assert nft_collection_3_id_list[0] = NFT_3_1;
    assert pool_balance_c1 = Uint256(2, 0);

    let (NFT_ARRAY_REMOVE: NFT*) = alloc();
    assert NFT_ARRAY_REMOVE[0] = NFT(address=COLLECTION_1, id=NFT_1_2);
    assert NFT_ARRAY_REMOVE[1] = NFT(address=COLLECTION_2, id=NFT_2_1);

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IPool.removeNftFromPool(sell_pool_contract_address, 2, NFT_ARRAY_REMOVE);
    %{ stop_prank_callable() %}

    let (new_start_id_collection_1) = IPool.getStartIdByCollection(
        sell_pool_contract_address, COLLECTION_1
    );
    let (new_start_id_collection_2) = IPool.getStartIdByCollection(
        sell_pool_contract_address, COLLECTION_2
    );
    let list_element_1: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 1);
    let list_element_2: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 2);
    let list_element_3: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 3);
    let list_element_4: (Uint256, felt) = IPool.getListElementById(sell_pool_contract_address, 4);
    let (collection_array_len, collection_array) = IPool.getAllCollections(
        sell_pool_contract_address
    );
    let (
        nft_collection_1_id_list_len: felt, nft_collection_1_id_list: Uint256*
    ) = IPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_1);
    let (
        nft_collection_2_id_list_len: felt, nft_collection_2_id_list: Uint256*
    ) = IPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_2);
    let (
        nft_collection_3_id_list_len: felt, nft_collection_3_id_list: Uint256*
    ) = IPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_3);
    let (pool_balance_c1) = IERC721.balanceOf(c1_contract_address, sell_pool_contract_address);
    let (pool_balance_c2) = IERC721.balanceOf(c2_contract_address, sell_pool_contract_address);
    let (new_owner_c1) = IERC721.ownerOf(c1_contract_address, NFT_1_2);
    let (new_owner_c2) = IERC721.ownerOf(c2_contract_address, NFT_2_1);

    assert new_start_id_collection_1 = 1;
    assert new_start_id_collection_2 = 4;
    assert list_element_1[0] = NFT_1_1;
    assert list_element_1[1] = ZERO_FELT;
    assert list_element_2[0] = ZERO_UINT;
    assert list_element_2[1] = ZERO_FELT;
    assert list_element_3[0] = ZERO_UINT;
    assert list_element_3[1] = ZERO_FELT;
    assert list_element_4[0] = NFT_2_2;
    assert list_element_4[1] = ZERO_FELT;
    assert list_element_5[0] = NFT_3_1;
    assert list_element_5[1] = ZERO_FELT;
    assert collection_array_len = 3;
    assert collection_array[0] = COLLECTION_1;
    assert collection_array[1] = COLLECTION_2;
    assert collection_array[2] = COLLECTION_3;
    assert nft_collection_1_id_list_len = 1;
    assert nft_collection_1_id_list[0] = NFT_1_1;
    assert nft_collection_2_id_list_len = 1;
    assert nft_collection_2_id_list[0] = NFT_2_2;
    assert nft_collection_3_id_list_len = 1;
    assert nft_collection_3_id_list[0] = NFT_3_1;
    assert pool_balance_c1 = Uint256(1, 0);
    assert pool_balance_c2 = Uint256(1, 0);
    assert new_owner_c1 = POOL_AND_NFT_OWNER;
    assert new_owner_c2 = POOL_AND_NFT_OWNER;

    return ();
}

@external
func test_editPoolParams_with_expected_output{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    alloc_locals;
    local sell_pool_contract_address;
    %{ ids.sell_pool_contract_address = context.sell_pool_contract_address %}

    tempvar POOL_PARAMS: PoolParams = PoolParams(price=Uint256(100000, 0), delta=10000);
    tempvar NEW_POOL_PARAMS: PoolParams = PoolParams(price=Uint256(150000, 0), delta=20000);

    let (old_pool_params) = IPool.getPoolConfig(sell_pool_contract_address);

    assert old_pool_params.price = POOL_PARAMS.price;
    assert old_pool_params.delta = POOL_PARAMS.delta;

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IPool.setPoolParams(sell_pool_contract_address, NEW_POOL_PARAMS);
    %{ stop_prank_callable() %}

    let (new_pool_params) = IPool.getPoolConfig(sell_pool_contract_address);

    assert new_pool_params.price = NEW_POOL_PARAMS.price;
    assert new_pool_params.delta = NEW_POOL_PARAMS.delta;

    return ();
}

@external
func test_buyNfts{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    local sell_pool_contract_address;
    local c1_contract_address;
    local erc20_contract_address;
    %{
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let COLLECTION_1 = c1_contract_address;
    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    let OLD_ETH_BALANCE = Uint256(0, 0);
    let NEW_ETH_BALANCE = Uint256(210000, 0);
    let OLD_PRICE = Uint256(100000, 0);
    let NEW_PRICE = Uint256(120000, 0);
    let TOTAL_PRICE = Uint256(210000, 0);

    let (NFT_ARRAY: NFT*) = alloc();
    assert NFT_ARRAY[0] = NFT(address=COLLECTION_1, id=NFT_1_1);
    assert NFT_ARRAY[1] = NFT(address=COLLECTION_1, id=NFT_1_2);

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_1 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1);
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2);
    %{ stop_prank_callable_1() %}
    IPool.addNftToPool(sell_pool_contract_address, 2, NFT_ARRAY);
    %{ stop_prank_callable_2() %}

    let (old_eth_balance) = IPool.getEthBalance(sell_pool_contract_address);
    let (start_id_collection_1) = IPool.getStartIdByCollection(
        sell_pool_contract_address, COLLECTION_1
    );
    let (old_pool_params) = IPool.getPoolConfig(sell_pool_contract_address);
    let (pool_balance_before) = IERC721.balanceOf(c1_contract_address, sell_pool_contract_address);
    let (owner_before) = IERC721.ownerOf(c1_contract_address, NFT_1_1);
    let (erc20_balance_nft_buyer_before) = IERC20.balanceOf(erc20_contract_address, NFT_BUYER);

    assert old_eth_balance = OLD_ETH_BALANCE;
    assert start_id_collection_1 = 1;
    assert old_pool_params.price = OLD_PRICE;
    assert pool_balance_before = Uint256(2, 0);
    assert owner_before = sell_pool_contract_address;
    assert erc20_balance_nft_buyer_before = Uint256(500000, 0);

    %{
        PRANK_NFT_BUYER = 987654321
        stop_prank_callable_1 = start_prank(PRANK_NFT_BUYER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_NFT_BUYER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, TOTAL_PRICE);
    %{ stop_prank_callable_1() %}
    IPool.buyNfts(sell_pool_contract_address, 2, NFT_ARRAY);
    %{ stop_prank_callable_2() %}

    let (new_eth_balance) = IPool.getEthBalance(sell_pool_contract_address);
    let (new_start_id_collection_1) = IPool.getStartIdByCollection(
        sell_pool_contract_address, COLLECTION_1
    );
    let (new_pool_params) = IPool.getPoolConfig(sell_pool_contract_address);
    let (pool_balance_after) = IERC721.balanceOf(c1_contract_address, sell_pool_contract_address);
    let (owner_after) = IERC721.ownerOf(c1_contract_address, NFT_1_1);
    let (erc20_balance_nft_buyer_after) = IERC20.balanceOf(erc20_contract_address, NFT_BUYER);

    assert new_eth_balance = NEW_ETH_BALANCE;
    assert new_start_id_collection_1 = 0;
    assert new_pool_params.price = NEW_PRICE;
    assert pool_balance_after = Uint256(0, 0);
    assert owner_after = NFT_BUYER;
    assert erc20_balance_nft_buyer_after = Uint256(290000, 0);

    return ();
}

@external
func test_buyNfts_from_different_collections{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    alloc_locals;
    local sell_pool_contract_address;
    local c1_contract_address;
    local c2_contract_address;
    local erc20_contract_address;
    %{
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    let NFT_2_1 = Uint256(21, 0);
    let NFT_2_2 = Uint256(22, 0);
    let NEW_PRICE = Uint256(140000, 0);
    let TOTAL_PRICE = Uint256(460000, 0);

    let (NFT_ARRAY: NFT*) = alloc();
    assert NFT_ARRAY[0] = NFT(address=c1_contract_address, id=NFT_1_1);
    assert NFT_ARRAY[1] = NFT(address=c1_contract_address, id=NFT_1_2);
    assert NFT_ARRAY[2] = NFT(address=c2_contract_address, id=NFT_2_1);
    assert NFT_ARRAY[3] = NFT(address=c2_contract_address, id=NFT_2_2);

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_1 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable_3 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1);
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2);
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_1);
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_2);
    %{
        stop_prank_callable_1() 
        stop_prank_callable_2()
    %}
    IPool.addNftToPool(sell_pool_contract_address, 4, NFT_ARRAY);
    %{ stop_prank_callable_3() %}

    %{
        PRANK_NFT_BUYER = 987654321
        stop_prank_callable_1 = start_prank(PRANK_NFT_BUYER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_NFT_BUYER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, TOTAL_PRICE);
    %{ stop_prank_callable_1() %}
    IPool.buyNfts(sell_pool_contract_address, 4, NFT_ARRAY);
    %{ stop_prank_callable_2() %}

    let (new_eth_balance) = IPool.getEthBalance(sell_pool_contract_address);
    let (new_start_id_collection_1) = IPool.getStartIdByCollection(
        sell_pool_contract_address, c1_contract_address
    );
    let (new_pool_params) = IPool.getPoolConfig(sell_pool_contract_address);
    let (pool_balance_after) = IERC721.balanceOf(c1_contract_address, sell_pool_contract_address);
    let (owner_after) = IERC721.ownerOf(c1_contract_address, NFT_1_1);
    let (erc20_balance_nft_buyer_after) = IERC20.balanceOf(erc20_contract_address, NFT_BUYER);

    assert new_eth_balance = TOTAL_PRICE;
    assert new_start_id_collection_1 = 0;
    assert new_pool_params.price = NEW_PRICE;
    assert pool_balance_after = Uint256(0, 0);
    assert owner_after = NFT_BUYER;
    assert erc20_balance_nft_buyer_after = Uint256(40000, 0);

    return ();
}

@external
func test_buyNfts_with_unsufficient_eth_balance{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    alloc_locals;
    local sell_pool_contract_address;
    local c1_contract_address;
    local c2_contract_address;
    local c3_contract_address;
    local erc20_contract_address;
    %{
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.c3_contract_address = context.c3_contract_address
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    let NFT_2_1 = Uint256(21, 0);
    let NFT_2_2 = Uint256(22, 0);
    let NFT_3_1 = Uint256(31, 0);
    let TOTAL_PRICE = Uint256(600000, 0);

    let (NFT_ARRAY: NFT*) = alloc();
    assert NFT_ARRAY[0] = NFT(address=c1_contract_address, id=NFT_1_1);
    assert NFT_ARRAY[1] = NFT(address=c1_contract_address, id=NFT_1_2);
    assert NFT_ARRAY[2] = NFT(address=c2_contract_address, id=NFT_2_1);
    assert NFT_ARRAY[3] = NFT(address=c2_contract_address, id=NFT_2_2);
    assert NFT_ARRAY[4] = NFT(address=c3_contract_address, id=NFT_3_1);

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_1 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable_3 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c3_contract_address)
        stop_prank_callable_4 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1);
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2);
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_1);
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_2);
    IERC721.approve(c3_contract_address, sell_pool_contract_address, NFT_3_1);
    %{
        stop_prank_callable_1() 
        stop_prank_callable_2()
        stop_prank_callable_3()
    %}
    IPool.addNftToPool(sell_pool_contract_address, 5, NFT_ARRAY);
    %{ stop_prank_callable_4() %}

    %{
        PRANK_NFT_BUYER = 987654321
        stop_prank_callable_1 = start_prank(PRANK_NFT_BUYER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_NFT_BUYER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, TOTAL_PRICE);
    %{ stop_prank_callable_1() %}

    %{ expect_revert(error_message="ETH balance is not sufficient") %}
    IPool.buyNfts(sell_pool_contract_address, 5, NFT_ARRAY);

    %{ stop_prank_callable_2() %}

    return ();
}

@external
func test_buyNfts_with_toggling_pool_pause{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    alloc_locals;
    local sell_pool_contract_address;
    local c1_contract_address;
    local erc20_contract_address;
    %{
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let COLLECTION_1 = c1_contract_address;
    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    let OLD_ETH_BALANCE = Uint256(0, 0);
    let NEW_ETH_BALANCE = Uint256(210000, 0);
    let OLD_PRICE = Uint256(100000, 0);
    let NEW_PRICE = Uint256(120000, 0);
    let TOTAL_PRICE = Uint256(210000, 0);

    let (NFT_ARRAY: NFT*) = alloc();
    assert NFT_ARRAY[0] = NFT(address=COLLECTION_1, id=NFT_1_1);
    assert NFT_ARRAY[1] = NFT(address=COLLECTION_1, id=NFT_1_2);

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_1 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1);
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2);
    %{ stop_prank_callable_1() %}
    IPool.addNftToPool(sell_pool_contract_address, 2, NFT_ARRAY);
    IPool.togglePause(sell_pool_contract_address);

    let (old_eth_balance) = IPool.getEthBalance(sell_pool_contract_address);
    let (start_id_collection_1) = IPool.getStartIdByCollection(
        sell_pool_contract_address, COLLECTION_1
    );
    let (old_pool_params) = IPool.getPoolConfig(sell_pool_contract_address);
    let (is_paused) = IPool.isPaused(sell_pool_contract_address);

    assert old_eth_balance = OLD_ETH_BALANCE;
    assert start_id_collection_1 = 1;
    assert old_pool_params.price = OLD_PRICE;
    assert is_paused = TRUE;

    IPool.togglePause(sell_pool_contract_address);
    let (is_paused) = IPool.isPaused(sell_pool_contract_address);
    assert is_paused = FALSE;
    %{ stop_prank_callable_2() %}

    %{
        PRANK_NFT_BUYER = 987654321
        stop_prank_callable_1 = start_prank(PRANK_NFT_BUYER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_NFT_BUYER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, TOTAL_PRICE);

    %{ stop_prank_callable_1() %}

    IPool.buyNfts(sell_pool_contract_address, 2, NFT_ARRAY);

    %{ stop_prank_callable_2() %}

    let (new_eth_balance) = IPool.getEthBalance(sell_pool_contract_address);
    let (new_start_id_collection_1) = IPool.getStartIdByCollection(
        sell_pool_contract_address, COLLECTION_1
    );
    let (new_pool_params) = IPool.getPoolConfig(sell_pool_contract_address);
    let (is_paused) = IPool.isPaused(sell_pool_contract_address);

    assert new_eth_balance = NEW_ETH_BALANCE;
    assert new_start_id_collection_1 = 0;
    assert new_pool_params.price = NEW_PRICE;
    assert is_paused = FALSE;

    return ();
}

@external
func test_cannot_buyNfts_when_pool_paused{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    alloc_locals;
    local sell_pool_contract_address;
    local c1_contract_address;
    local erc20_contract_address;
    %{
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let COLLECTION_1 = c1_contract_address;
    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    let TOTAL_PRICE = Uint256(210000, 0);

    let (NFT_ARRAY: NFT*) = alloc();
    assert NFT_ARRAY[0] = NFT(address=COLLECTION_1, id=NFT_1_1);
    assert NFT_ARRAY[1] = NFT(address=COLLECTION_1, id=NFT_1_2);

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_1 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1);
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2);
    %{ stop_prank_callable_1() %}
    IPool.addNftToPool(sell_pool_contract_address, 2, NFT_ARRAY);
    IPool.togglePause(sell_pool_contract_address);
    %{ stop_prank_callable_2() %}

    let (is_paused) = IPool.isPaused(sell_pool_contract_address);
    assert is_paused = TRUE;

    %{
        PRANK_NFT_BUYER = 987654321
        stop_prank_callable_1 = start_prank(PRANK_NFT_BUYER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_NFT_BUYER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, TOTAL_PRICE);

    %{ stop_prank_callable_1() %}

    %{ expect_revert(error_message="Pool must not be paused") %}
    IPool.buyNfts(sell_pool_contract_address, 2, NFT_ARRAY);

    %{ stop_prank_callable_2() %}

    return ();
}

@external
func test_getNextPrice_with_expected_output{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    alloc_locals;
    local sell_pool_contract_address;
    %{ ids.sell_pool_contract_address = context.sell_pool_contract_address %}

    let NEXT_PRICE = Uint256(110000, 0);

    let (next_price) = IPool.getNextPrice(sell_pool_contract_address, DeltaSign.positive);

    assert next_price = NEXT_PRICE;

    return ();
}

@external
func test_depositEth{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    local sell_pool_contract_address;
    local erc20_contract_address;
    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.erc20_contract_address = context.erc20_contract_address 
    %}

    let ERC20_BALANCE_POOL_OWNER = Uint256(300000, 0);
    let POOL_BALANCE_BEFORE = Uint256(0, 0);
    let POOL_BALANCE_AFTER = Uint256(300000, 0);

    let (pool_balance_before) = IPool.getEthBalance(sell_pool_contract_address);
    assert pool_balance_before = POOL_BALANCE_BEFORE;

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_1 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, ERC20_BALANCE_POOL_OWNER);
    %{ stop_prank_callable_1() %}

    IPool.depositEth(sell_pool_contract_address, ERC20_BALANCE_POOL_OWNER);
    %{ stop_prank_callable_2() %}

    let (pool_balance_after) = IPool.getEthBalance(sell_pool_contract_address);
    assert pool_balance_after = POOL_BALANCE_AFTER;

    return ();
}

@external
func test_depositEth_with_unsufficient_balance{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    alloc_locals;
    local sell_pool_contract_address;
    local erc20_contract_address;
    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.erc20_contract_address = context.erc20_contract_address 
    %}

    let ERC20_BALANCE_POOL_OWNER = Uint256(300000, 0);
    let EXCEEDING_AMOUNT = Uint256(400000, 0);

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_1 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, EXCEEDING_AMOUNT);
    %{ stop_prank_callable_1() %}

    %{ expect_revert(error_message="ETH balance is not sufficient") %}
    IPool.depositEth(sell_pool_contract_address, EXCEEDING_AMOUNT);
    %{ stop_prank_callable_2() %}

    return ();
}

@external
func test_withdrawEth{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    local sell_pool_contract_address;
    local erc20_contract_address;
    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.erc20_contract_address = context.erc20_contract_address 
    %}

    let ERC20_BALANCE_POOL_OWNER = Uint256(300000, 0);
    let POOL_BALANCE_BEFORE = Uint256(0, 0);
    let WITHDRAWAL_BALANCE = Uint256(150000, 0);
    let POOL_BALANCE_AFTER_DEPOSIT = Uint256(300000, 0);
    let POOL_BALANCE_AFTER_WITHDRAWAL = Uint256(150000, 0);
    let POOL_BALANCE_AFTER_WITHDRAWAL_ALL = Uint256(0, 0);

    let (pool_balance_before) = IPool.getEthBalance(sell_pool_contract_address);
    assert pool_balance_before = POOL_BALANCE_BEFORE;

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_1 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, ERC20_BALANCE_POOL_OWNER);
    %{ stop_prank_callable_1() %}
    IPool.depositEth(sell_pool_contract_address, ERC20_BALANCE_POOL_OWNER);

    let (pool_balance_after_deposit) = IPool.getEthBalance(sell_pool_contract_address);
    assert pool_balance_after_deposit = POOL_BALANCE_AFTER_DEPOSIT;

    let (pool_balance_erc20_contract) = IERC20.balanceOf(
        erc20_contract_address, sell_pool_contract_address
    );
    assert pool_balance_erc20_contract = POOL_BALANCE_AFTER_DEPOSIT;

    IPool.withdrawEth(sell_pool_contract_address, WITHDRAWAL_BALANCE);

    let (pool_balance_after_withdrawal) = IPool.getEthBalance(sell_pool_contract_address);
    assert pool_balance_after_withdrawal = POOL_BALANCE_AFTER_WITHDRAWAL;

    IPool.withdrawAllEth(sell_pool_contract_address);

    let (pool_balance_after_withdrawal_all) = IPool.getEthBalance(sell_pool_contract_address);
    assert pool_balance_after_withdrawal_all = POOL_BALANCE_AFTER_WITHDRAWAL_ALL;

    %{ expect_revert(error_message="Pool has no ETH to withdraw") %}
    IPool.withdrawAllEth(sell_pool_contract_address);

    %{ stop_prank_callable_2() %}

    return ();
}

@external
func test_withdrawEth_with_unsufficient_pool_balance{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    alloc_locals;
    local sell_pool_contract_address;
    local erc20_contract_address;
    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.erc20_contract_address = context.erc20_contract_address 
    %}

    let ERC20_BALANCE_POOL_OWNER = Uint256(300000, 0);
    let POOL_BALANCE_BEFORE = Uint256(0, 0);
    let EXCEEDING_WITHDRAWAL_BALANCE = Uint256(400000, 0);
    let POOL_BALANCE_AFTER_DEPOSIT = Uint256(300000, 0);

    let (pool_balance_before) = IPool.getEthBalance(sell_pool_contract_address);
    assert pool_balance_before = POOL_BALANCE_BEFORE;

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_1 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, ERC20_BALANCE_POOL_OWNER);
    %{ stop_prank_callable_1() %}
    IPool.depositEth(sell_pool_contract_address, ERC20_BALANCE_POOL_OWNER);

    let (pool_balance_after_deposit) = IPool.getEthBalance(sell_pool_contract_address);
    assert pool_balance_after_deposit = POOL_BALANCE_AFTER_DEPOSIT;

    let (pool_balance_erc20_contract) = IERC20.balanceOf(
        erc20_contract_address, sell_pool_contract_address
    );
    assert pool_balance_erc20_contract = POOL_BALANCE_AFTER_DEPOSIT;

    %{ expect_revert(error_message="ETH balance is not sufficient") %}
    IPool.withdrawEth(sell_pool_contract_address, EXCEEDING_WITHDRAWAL_BALANCE);

    %{ stop_prank_callable_2() %}

    return ();
}

@external
func test_getTokenPrices{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    local sell_pool_contract_address;
    %{ ids.sell_pool_contract_address = context.sell_pool_contract_address %}

    const NUMBER_TOKENS = 5;

    let FIRST_PRICE = Uint256(110000, 0);
    let SECOND_PRICE = Uint256(120000, 0);
    let THIRD_PRICE = Uint256(130000, 0);
    let FOURTH_PRICE = Uint256(140000, 0);
    let FIFTH_PRICE = Uint256(150000, 0);

    let (price_array_len: felt, price_array: Uint256*) = IPool.getTokenPrices(
        sell_pool_contract_address, NUMBER_TOKENS, DeltaSign.positive
    );

    assert price_array_len = 5;
    assert price_array[0] = FIRST_PRICE;
    assert price_array[1] = SECOND_PRICE;
    assert price_array[2] = THIRD_PRICE;
    assert price_array[3] = FOURTH_PRICE;
    assert price_array[4] = FIFTH_PRICE;

    return ();
}

@external
func test_getTokenPrices_with_negative_values{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    alloc_locals;
    local sell_pool_contract_address;
    %{ ids.sell_pool_contract_address = context.sell_pool_contract_address %}

    tempvar NEW_POOL_PARAMS: PoolParams = PoolParams(price=Uint256(100000, 0), delta=-50000);
    const NUMBER_TOKENS = 5;

    %{
        POOL_AND_ERC20_OWNER = 123456789
        stop_prank_callable = start_prank(POOL_AND_ERC20_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IPool.setPoolParams(sell_pool_contract_address, NEW_POOL_PARAMS);
    %{ stop_prank_callable() %}

    %{ expect_revert(error_message="The price must not be negative") %}
    let (price_array_len: felt, price_array: Uint256*) = IPool.getTokenPrices(
        sell_pool_contract_address, NUMBER_TOKENS, DeltaSign.positive
    );

    return ();
}

@external
func test_getNextPrice_with_negative_value{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    alloc_locals;
    local sell_pool_contract_address;
    %{ ids.sell_pool_contract_address = context.sell_pool_contract_address %}

    tempvar NEW_POOL_PARAMS: PoolParams = PoolParams(price=Uint256(50000, 0), delta=-60000);
    const NUMBER_TOKENS = 5;

    %{
        POOL_AND_ERC20_OWNER = 123456789
        stop_prank_callable = start_prank(POOL_AND_ERC20_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IPool.setPoolParams(sell_pool_contract_address, NEW_POOL_PARAMS);
    %{ stop_prank_callable() %}

    %{ expect_revert(error_message="The price must not be negative") %}
    let (next_price) = IPool.getNextPrice(sell_pool_contract_address, DeltaSign.positive);

    return ();
}

@external
func test_buyNfts_with_negative_price{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    alloc_locals;
    local sell_pool_contract_address;
    local c1_contract_address;
    local c2_contract_address;
    local c3_contract_address;
    local erc20_contract_address;
    %{
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.c3_contract_address = context.c3_contract_address
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    let NFT_2_1 = Uint256(21, 0);
    let NFT_2_2 = Uint256(22, 0);
    let NFT_3_1 = Uint256(31, 0);
    let TOTAL_PRICE = Uint256(600000, 0);

    let (NFT_ARRAY: NFT*) = alloc();
    assert NFT_ARRAY[0] = NFT(address=c1_contract_address, id=NFT_1_1);
    assert NFT_ARRAY[1] = NFT(address=c1_contract_address, id=NFT_1_2);
    assert NFT_ARRAY[2] = NFT(address=c2_contract_address, id=NFT_2_1);
    assert NFT_ARRAY[3] = NFT(address=c2_contract_address, id=NFT_2_2);
    assert NFT_ARRAY[4] = NFT(address=c3_contract_address, id=NFT_3_1);

    tempvar NEW_POOL_PARAMS: PoolParams = PoolParams(price=Uint256(200000, 0), delta=-70000);

    %{
        PRANK_POOL_AND_NFT_OWNER = 123456789
        stop_prank_callable_1 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable_3 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.c3_contract_address)
        stop_prank_callable_4 = start_prank(PRANK_POOL_AND_NFT_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1);
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2);
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_1);
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_2);
    IERC721.approve(c3_contract_address, sell_pool_contract_address, NFT_3_1);
    %{
        stop_prank_callable_1() 
        stop_prank_callable_2()
        stop_prank_callable_3()
    %}
    IPool.setPoolParams(sell_pool_contract_address, NEW_POOL_PARAMS);
    IPool.addNftToPool(sell_pool_contract_address, 5, NFT_ARRAY);
    %{ stop_prank_callable_4() %}

    %{
        PRANK_NFT_BUYER = 987654321
        stop_prank_callable_1 = start_prank(PRANK_NFT_BUYER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_NFT_BUYER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, TOTAL_PRICE);
    %{ stop_prank_callable_1() %}

    %{ expect_revert(error_message="The price must not be negative") %}
    IPool.buyNfts(sell_pool_contract_address, 5, NFT_ARRAY);

    %{ stop_prank_callable_2() %}

    return ();
}
