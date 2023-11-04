source .env

forge script script/Deploy.s.sol:DeployScript \
    --chain-id 42161 \
    --rpc-url $RPC_ARBITRUM \
    --broadcast \
    --private-key $PRIVATE_KEY \
    --verify \
    --etherscan-api-key $ARBISCAN_API \
    -vvvvv