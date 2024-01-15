source .env

forge script script/Deploy.s.sol:DeployScript \
    --chain-id 43114 \
    --rpc-url $RPC_AVALANCHE \
    --broadcast \
    --private-key $PRIVATE_KEY \
    --verify \
    --etherscan-api-key $AVALANCHE_API \
    -vvvvv