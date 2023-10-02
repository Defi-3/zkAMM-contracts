// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./interfaces/IZkAmmPair.sol";
import "./libraries/TransferHelper.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ZkAmmPair is IZkAmmPair, ERC20 {
    address public immutable token0;
    address public immutable token1;
    address public zkGraph;

    uint256 public reserve0;
    uint256 public reserve1;
    uint256 public nextRequestId;
    mapping(uint256 => bytes) public requestParams;


    modifier onlyZkGraph() {
        require(msg.sender == zkGraph, "only zkGraph");
        _;
    }
    
    constructor(address tokenA, address tokenB) ERC20("ZK AMM", "ZK-AMM") {
        require(tokenA != tokenB, 'IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        emit Setup(token0, token1);
    }

    function setGraph(address graph) external override {
        require(graph != address(0), "zero address");
        zkGraph = graph;
    }

    function addInitLiquidity(
        address recipient, 
        uint256 amount0, 
        uint256 amount1
    ) external override {
        require(recipient != address(0), "zero address");
        require(amount0 > 0 && amount1 > 0, "zero amount");
        require(reserve0 == 0 && reserve1 == 0, "already init");

        uint256 balance0 = IERC20(token0).balanceOf(msg.sender);
        uint256 balance1 = IERC20(token1).balanceOf(msg.sender);
        require(balance0 >= amount0 && balance1 >= amount1, "not enough balance");

        nextRequestId++;
        requestParams[nextRequestId] = abi.encode(msg.sender, recipient, amount0, amount1);

        emit AddInitLiquidity(msg.sender, recipient, amount0, amount1, nextRequestId);
    }

    function addInitLiquidityCallback(
        uint256 requestId,
        uint256 liquidity
    ) external override onlyZkGraph {
        (
            address payer, 
            address recipient, 
            uint256 amount0, 
            uint256 amount1
        ) = abi.decode(requestParams[requestId], (address, address, uint256, uint256));
        require(payer != address(0) && recipient != address(0), "zero address");
        require(amount0 > 0 && amount1 > 0, "zero amount");
        require(liquidity > 0, "zero liquidity");
        require(reserve0 == 0 && reserve1 == 0, "already init");

        TransferHelper.safeTransferFrom(token0, payer, address(this), amount0);
        TransferHelper.safeTransferFrom(token1, payer, address(this), amount1);

        reserve0 = amount0;
        reserve1 = amount1;

        _mint(recipient, liquidity);
        emit LiquidityAdded(payer, recipient, amount0, amount1, liquidity, requestId);
        delete requestParams[requestId];
    }

    function addLiquidity(address recipient, uint256 amount0) external override {
        require(recipient != address(0), "zero address");
        require(amount0 > 0, "zero amount");
        require(reserve0 > 0 && reserve1 > 0, "not init");

        uint256 balance0 = IERC20(token0).balanceOf(msg.sender);
        require(balance0 >= amount0, "not enough balance");

        nextRequestId++;
        requestParams[nextRequestId] = abi.encode(msg.sender, recipient, amount0);

        uint256 _totalSupply = totalSupply();
        emit AddLiquidity(msg.sender, recipient, amount0, reserve0, reserve1, _totalSupply, nextRequestId);
    }

    function addLiquidityCallback(
        uint256 requestId,
        uint256 amount1,
        uint256 liquidity
    ) external override onlyZkGraph {
        (
            address payer, 
            address recipient, 
            uint256 amount0
        ) = abi.decode(requestParams[requestId], (address, address, uint256));
        require(payer != address(0) && recipient != address(0), "zero address");
        require(amount0 > 0 && amount1 > 0, "zero amount");
        require(liquidity > 0, "zero liquidity");
        require(reserve0 > 0 && reserve1 > 0, "not init");

        TransferHelper.safeTransferFrom(token0, payer, address(this), amount0);
        TransferHelper.safeTransferFrom(token1, payer, address(this), amount1);

        reserve0 += amount0;
        reserve1 += amount1;

        _mint(recipient, liquidity);
        emit LiquidityAdded(payer, recipient, amount0, amount1, liquidity, requestId);
        delete requestParams[requestId];
    }

    function removeLiquidity(address recipient, uint liquidity) external override {
        require(recipient != address(0), "zero address");
        require(balanceOf(msg.sender) >= liquidity, "insufficient liquidity");

        nextRequestId++;
        requestParams[nextRequestId] = abi.encode(msg.sender, recipient, liquidity);

        uint256 _totalSupply = totalSupply();
        emit RemoveLiquidity(msg.sender, recipient, liquidity, reserve0, reserve1, _totalSupply, nextRequestId);
    }

    function removeLiquidityCallback(
        uint256 requestId,
        uint256 amount0,
        uint256 amount1
    ) external override onlyZkGraph {
        (
            address sender, 
            address recipient, 
            uint256 liquidity
        ) = abi.decode(requestParams[requestId], (address, address, uint256));
        require(sender != address(0) && recipient != address(0), "zero address");
        require(liquidity > 0, "zero liquidity");
        require(amount0 > 0 && amount1 > 0, "zero amount");
        require(balanceOf(sender) >= liquidity, "insufficient liquidity");

        _burn(sender, liquidity);
        reserve0 -= amount0;
        reserve1 -= amount1;

        TransferHelper.safeTransfer(token0, recipient, amount0);
        TransferHelper.safeTransfer(token1, recipient, amount1);
        emit LiquidityRemoved(sender, recipient, liquidity, amount0, amount1, requestId);
        delete requestParams[requestId];
    }

    function swap(address recipient, bool zeroForOne, uint256 amountIn) external override {
        require(recipient != address(0), "zero address");
        require(amountIn > 0, "zero amountIn");

        uint256 balance;
        if (zeroForOne) {
            balance = IERC20(token0).balanceOf(msg.sender);
        } else {
            balance = IERC20(token1).balanceOf(msg.sender);
        }
        require(balance >= amountIn, "not enough balance");

        nextRequestId++;
        requestParams[nextRequestId] = abi.encode(msg.sender, recipient, zeroForOne, amountIn);

        emit Swap(msg.sender, recipient, zeroForOne, amountIn, reserve0, reserve1, nextRequestId);
    }

    function swapCallback(
        uint256 requestId,
        uint256 amountOut
    ) external override onlyZkGraph {
        (
            address payer, 
            address recipient, 
            bool zeroForOne,
            uint256 amountIn
        ) = abi.decode(requestParams[requestId], (address, address, bool, uint256));
        require(payer != address(0) && recipient != address(0), "zero address");

        address tokenIn;
        address tokenOut;
        if (zeroForOne) {
            tokenIn = token0;
            tokenOut = token1;

            reserve0 += amountIn;
            reserve1 -= amountOut;
        } else {
            tokenIn = token1;
            tokenOut = token0;

            reserve1 += amountIn;
            reserve0 -= amountOut;
        }
        TransferHelper.safeTransferFrom(tokenIn, payer, address(this), amountIn);
        TransferHelper.safeTransfer(tokenOut, recipient, amountOut);

        emit Swapped(payer, recipient, zeroForOne, amountIn, amountOut, requestId);
        delete requestParams[requestId];
    }
}