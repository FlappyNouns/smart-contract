// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {VennFirewallConsumer} from "@ironblocks/firewall-consumer/contracts/consumers/VennFirewallConsumer.sol";

contract FLPCoin is ERC20, Ownable, VennFirewallConsumer {
    uint256 public mintingPrice=0.001 ether; // 铸币价格

    event TokensMinted(address indexed user, uint256 amountt);

    constructor() ERC20("FLPCoin", "FLPC") Ownable(msg.sender) {
        _mint(msg.sender, 1000 * 10**decimals()); // 初始给owner 1000个FLPC
    }

    // 铸币函数
    function mintTokens(uint256 score) firewallProtected external {
        // require(msg.value >= amount * mintingPrice, "Insufficient ETH sent");
        require(score>0, "Score must larger than 0");
        _mint(msg.sender, score * 10**decimals()); // 铸造新的代币并发送给用户

        emit TokensMinted(msg.sender, score * 10**decimals());
    }

}