// SPDX-License-Identifier: MIT

// 1. Deploy mocks contract khi ở trên local chain
// 2. Giữ theo dõi của địa chỉ contract này xuyên suốt nhiều chain khác nhau
// Sepolia ETH/USD
// Mainnet ETH/USD

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";

import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // Nếu đang ở trên local chain thì deploy mock contract
    // Nếu không thì lấy địa chỉ trực tiếp từ live network

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreatedAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});

        return sepoliaConfig;
    }

    function getOrCreatedAnvilEthConfig() public returns (NetworkConfig memory) {
        // Nếu không có address thì return activeNetworkConfig,
        // nếu đã deploy một contract lên trên local chain rồi thì không cần deploy thêm cái nữa, chưa có mới cần thêm
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // 1. Deploy mock contract
        // 2. Return mock address

        vm.startBroadcast();
        MockV3Aggregator mockFeedPriceData = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockFeedPriceData)});

        return anvilConfig;
    }
}
