-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
DEFAULT_ZKSYNC_LOCAL_KEY := 0x7726827caac94a7f9e1b160f7ea819f172f7b6f9d2a97f992c38edeab82d4110

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make fund ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install cyfrin/foundry-devops@0.0.11 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit && forge install foundry-rs/forge-std@v1.5.3 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

zkbuild:; forge build --zksync

test :; forge test 

zktest:; forge test --zksync 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

zk-anvil :; npx zksync-cli dev start

# NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast
NETWORK_ARGS_LOCAL := --rpc-url http://localhost:8545 --account defaultKey --broadcast
NETWORK_ARGS_ZK_LOCAL :=  --rpc-url http://127.0.0.1:8011 --private-key $(DEFAULT_ZKSYNC_LOCAL_KEY) --broadcast
NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --account God --sender $(SENDER_ADDRESS) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
    # NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --account God --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy-local:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS_LOCAL)

deploy-sepolia:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

deploy-zk-local:
	@forge create src/FundMe.sol:FundMe --rpc-url http://127.0.0.1:8011 --private-key $(DEFAULT_ZKSYNC_LOCAL_KEY) --constructor-args $(shell forge create test/mock/MockV3Aggregator.sol:MockV3Aggregator --rpc-url http://127.0.0.1:8011 --private-key $(DEFAULT_ZKSYNC_LOCAL_KEY) --constructor-args 8 200000000000 --legacy --zksync | grep "Deployed to:" | awk '{print $$3}') --legacy --zksync

deploy-zk-sepolia:
	@forge create src/FundMe.sol:FundMe --rpc-url $(ZKSYNC_SEPOLIA_RPC_URL) --account God --constructor-args 0xB58634C4465D93A03801693FD6d76997C797e42A --legacy --zksync


# For deploying Interactions.s.sol:FundFundMe as well as for Interactions.s.sol:WithdrawFundMe we have to include a sender's address `--sender <ADDRESS>`.
SENDER_ADDRESS := 0xB58634C4465D93A03801693FD6d76997C797e42A

fund-sepolia:
	@forge script script/Interactions.s.sol:FundFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)

fund-local:
	@forge script script/Interactions.s.sol:FundFundMe --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 $(NETWORK_ARGS_LOCAL)

# fund-zk-local:
# 	@forge script script/Interactions.s.sol:FundFundMe --sender 0x36615Cf349d7F6344891B1e7CA7C72883F5dc049 $(NETWORK_ARGS_ZK_LOCAL) // Not yet working

withdraw-sepolia:
	@forge script script/Interactions.s.sol:WithdrawFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)

withdraw-local:
	@forge script script/Interactions.s.sol:WithdrawFundMe --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 $(NETWORK_ARGS_LOCAL)

# withdraw-zk-local:
# 	@forge script script/Interactions.s.sol:WithdrawFundMe --sender 0x36615Cf349d7F6344891B1e7CA7C72883F5dc049 $(NETWORK_ARGS_ZK_LOCAL) // Not yet working

