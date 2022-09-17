%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_contract_address

from src.pools.sell.ISellPool import ISellPool, NFT, PoolParams
from tests.helper.IMintPool import IMintPool, Collection

from lib.cairo_contracts.src.openzeppelin.token.erc721.IERC721 import IERC721
from lib.cairo_contracts.src.openzeppelin.token.erc20.IERC20 import IERC20

@storage_var
func _buy_pool_contract_address() -> (res: felt) {
}


const C1_NAME = 'COLLECTION 1';
const ERC20_NAME = 'ERC20 Test Contract';
const C1_SYMBOL = 'C1';
const ERC20_SYMBOL = 'ERC20';
const DECIMALS = 18;
const INITIAL_SUPPLY_LOW = 50;
const INITIAL_SUPPLY_HIGH = 0;
const POOL_AND_ERC20_OWNER = 123456789;
const NFT_OWNER_AND_SELLER = 987654321;


@view
func __setup__{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let (POOL_FACTORY_AND_ERC_CONTRACT_OWNER) = get_contract_address();

    %{
    context.c1_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo", 
            [ 
                ids.C1_NAME, ids.C1_SYMBOL, ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
            ).contract_address

    context.c2_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo", 
            [ 
                ids.C1_NAME, ids.C1_SYMBOL, ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
            ).contract_address

    context.erc20_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/presets/ERC20Mintable.cairo", 
            [ 
                ids.ERC20_NAME, ids.ERC20_SYMBOL, ids.DECIMALS, ids.INITIAL_SUPPLY_LOW, ids.INITIAL_SUPPLY_HIGH, ids.POOL_AND_ERC20_OWNER, ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
        ).contract_address
    
    context.pool_factory_contract_address = deploy_contract("./tests/helper/MintPool.cairo", 
            [
                ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
        ).contract_address

    context.buy_pool_class_hash = declare("./src/pools/buy/BuyPool.cairo").class_hash

    context.linear_curve_class_hash = declare("./src/bonding_curves/LinearCurve.cairo").class_hash
    %}

    local buy_pool_class_hash;
    local linear_curve_class_hash;
    local c1_contract_address;
    local c2_contract_address;
    local erc20_contract_address;
    local pool_factory_contract_address;
    %{
        ids.buy_pool_class_hash = context.buy_pool_class_hash
        ids.linear_curve_class_hash = context.linear_curve_class_hash 
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address 
        ids.erc20_contract_address = context.erc20_contract_address
        ids.pool_factory_contract_address = context.pool_factory_contract_address
    %}

    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    let NFT_2_1 = Uint256(21, 0);
    tempvar POOL_PARAMS: PoolParams = PoolParams(price=Uint256(10, 0), delta=1);

    ISellPool.mint(c1_contract_address, NFT_OWNER_AND_SELLER, NFT_1_1);
    ISellPool.mint(c1_contract_address, NFT_OWNER_AND_SELLER, NFT_1_2);
    ISellPool.mint(c2_contract_address, NFT_OWNER_AND_SELLER, NFT_2_1);

    IMintPool.setPoolClassHash(pool_factory_contract_address, buy_pool_class_hash);

    %{
        POOL_AND_ERC20_OWNER = 123456789
        stop_prank_callable_1 = start_prank(POOL_AND_ERC20_OWNER, target_contract_address=ids.pool_factory_contract_address)
    %}
    let (buy_pool_contract_address) = IMintPool.mint(
        pool_factory_contract_address, linear_curve_class_hash, erc20_contract_address
    );
    %{ stop_prank_callable_1() %}

    _buy_pool_contract_address.write(buy_pool_contract_address);

    %{
        POOL_AND_ERC20_OWNER = 123456789
        stop_prank_callable_2 = start_prank(POOL_AND_ERC20_OWNER, target_contract_address=ids.buy_pool_contract_address)
    %}
    ISellPool.setPoolParams(buy_pool_contract_address, POOL_PARAMS);
    %{ stop_prank_callable_2() %}

    return ();
}


@external
func test_initialization_pool_factory{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local pool_factory_contract_address;
    local buy_pool_class_hash;
    %{
        ids.pool_factory_contract_address = context.pool_factory_contract_address 
        ids.buy_pool_class_hash = context.buy_pool_class_hash
    %}

    let (POOL_FACTORY_OWNER) = get_contract_address();

    let (factory_owner) = IMintPool.getFactoryOwner(pool_factory_contract_address);
    let (pool_type_class_hash) = IMintPool.getPoolTypeClassHash(pool_factory_contract_address);
    let (
        collection_array_len: felt, collection_array: Collection*
    ) = IMintPool.getAllCollectionsFromAllPools(pool_factory_contract_address);

    assert factory_owner = POOL_FACTORY_OWNER;
    assert pool_type_class_hash = buy_pool_class_hash;
    assert collection_array_len = 0;

    return ();
}


@external
func test_initialization_ERC_contracts{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local c1_contract_address;
    local c2_contract_address;
    local erc20_contract_address;
    %{
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address 
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    let NFT_2_1 = Uint256(21, 0);

    let (c1_balance) = IERC721.balanceOf(c1_contract_address, NFT_OWNER_AND_SELLER);
    let (c2_balance) = IERC721.balanceOf(c2_contract_address, NFT_OWNER_AND_SELLER);
    let (erc20_balance_pool_owner) = IERC20.balanceOf(erc20_contract_address, POOL_AND_ERC20_OWNER);
    let (c1_token_owner) = IERC721.ownerOf(c1_contract_address, NFT_1_1);
    let (c2_token_owner) = IERC721.ownerOf(c2_contract_address, NFT_2_1);
    let (erc20_total_supply) = IERC20.totalSupply(erc20_contract_address);

    assert c1_balance = Uint256(2, 0);
    assert c2_balance = Uint256(1, 0);
    assert erc20_balance_pool_owner = Uint256(50, 0);
    assert erc20_total_supply = Uint256(50, 0);
    assert c1_token_owner = NFT_OWNER_AND_SELLER;
    assert c2_token_owner = NFT_OWNER_AND_SELLER;

    return ();
}


@external
func test_getPoolConfig_with_expected_output{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local pool_factory_contract_address;
    %{ ids.pool_factory_contract_address = context.pool_factory_contract_address %}

    tempvar POOL_PARAMS: PoolParams = PoolParams(price=Uint256(10, 0), delta=1);

    let (buy_pool_contract_address) = _buy_pool_contract_address.read();
    let (pool_factory) = ISellPool.getPoolFactory(buy_pool_contract_address);
    let (pool_params: PoolParams) = ISellPool.getPoolConfig(buy_pool_contract_address);

    let (high, low) = split_felt(buy_pool_contract_address);
    let buy_pool_contract_address_token = Uint256(low, high);
    let (pool_owner) = IERC721.ownerOf(
        pool_factory_contract_address, buy_pool_contract_address_token
    );

    assert pool_factory = pool_factory_contract_address;
    assert pool_params.price = POOL_PARAMS.price;
    assert pool_params.delta = POOL_PARAMS.delta;
    assert pool_owner = POOL_AND_ERC20_OWNER;

    return ();
}


@external
func test_setSupportedCollections{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local c1_contract_address;
    local c2_contract_address;
    %{
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address 
    %}

    let (buy_pool_contract_address) = _buy_pool_contract_address.read();
    let (c1_is_supported) = ISellPool.checkIfCollectionSupported(buy_pool_contract_address, c1_contract_address);
    let (c2_is_supported) = ISellPool.checkIfCollectionSupported(buy_pool_contract_address, c2_contract_address);

    assert c1_is_supported = FALSE;
    assert c2_is_supported = FALSE;

    let (COLLECTION_ARRAY: felt*) = alloc();
    assert COLLECTION_ARRAY[0] = c1_contract_address;
    assert COLLECTION_ARRAY[1] = c2_contract_address;

    %{
        POOL_AND_ERC20_OWNER = 123456789
        stop_prank_callable = start_prank(POOL_AND_ERC20_OWNER, target_contract_address=ids.buy_pool_contract_address)
    %}
    ISellPool.setSupportedCollections(buy_pool_contract_address, 2, COLLECTION_ARRAY);
    %{ stop_prank_callable() %}

    let (c1_is_supported) = ISellPool.checkIfCollectionSupported(buy_pool_contract_address, c1_contract_address);
    let (c2_is_supported) = ISellPool.checkIfCollectionSupported(buy_pool_contract_address, c2_contract_address);

    assert c1_is_supported = TRUE;
    assert c2_is_supported = TRUE;

    return ();
}