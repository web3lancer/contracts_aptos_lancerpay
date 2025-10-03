#!/bin/bash

# Aptos Payment System Deployment Script
set -e

echo "🚀 Starting Aptos Payment System Deployment..."

# Check if aptos CLI is installed
if ! command -v aptos &> /dev/null; then
    echo "❌ Aptos CLI is not installed. Please install it first:"
    echo "   curl -fsSL \"https://aptos.dev/scripts/install_cli.py\" | python3"
    exit 1
fi

# Set network (default to testnet)
NETWORK=${1:-testnet}
echo "📡 Network: $NETWORK"

# Navigate to contract directory
cd "$(dirname "$0")/../contract"

# Initialize Aptos if not already done
if [ ! -f ".aptos/config.yaml" ]; then
    echo "🔑 Initializing Aptos configuration..."
    aptos init --network $NETWORK
fi

# Compile the contract
echo "🔨 Compiling contract..."
aptos move compile

# Test the contract
echo "🧪 Running tests..."
aptos move test

# Publish the contract
echo "📦 Publishing contract to $NETWORK..."
aptos move publish --assume-yes

echo "✅ Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Copy the module address from the output above"
echo "   2. Set NEXT_PUBLIC_APTOS_MODULE_ADDRESS in your .env file"
echo "   3. Deploy your Next.js application"
