-- Define a variable to toggle trading
local tradingEnabled = true

-- Function to freeze trading
local function freezeTrading(player)
    if not tradingEnabled then
        player:SendNotification({
            Title = "Trading Disabled",
            Text = "Trading is currently disabled by the owner.",
            Duration = 5
        })
        return false
    end
    return true
end

-- Fake inventory for visual purposes
local fakeInventory = {}

-- Hook into the trade system
local function hookTradeFunctions()
    -- Replace these with the actual trade functions used in Adopt Me
    local tradeInitiateEvent = game.ReplicatedStorage:WaitForChild("InitiateTrade")
    local addItemEvent = game.ReplicatedStorage:WaitForChild("AddItemToTrade")
    local removeItemEvent = game.ReplicatedStorage:WaitForChild("RemoveItemFromTrade")
    local tradeCompleteEvent = game.ReplicatedStorage:WaitForChild("CompleteTrade")

    -- Store the original functions
    local originalAddItemFunction = addItemEvent.OnServerEvent
    local originalRemoveItemFunction = removeItemEvent.OnServerEvent
    local originalTradeCompleteFunction = tradeCompleteEvent.OnServerEvent

    -- Hook the addItemEvent
    addItemEvent.OnServerEvent:Connect(function(player, item)
        if tradingEnabled then
            -- Add the item to the fake inventory
            table.insert(fakeInventory, item)
            -- Call the original function to add the item to the trade
            originalAddItemFunction(player, item)
        end
    end)

    -- Hook the removeItemEvent
    removeItemEvent.OnServerEvent:Connect(function(player, item)
        if tradingEnabled then
            -- Find the item in the fake inventory and remove it
            for i, v in ipairs(fakeInventory) do
                if v == item then
                    table.remove(fakeInventory, i)
                    break
                end
            end
            -- Do not call the original function to fake success
            -- This makes the item disappear for the player without affecting the trade for the other player
        end
    end)

    -- Hook the tradeCompleteEvent
    tradeCompleteEvent.OnServerEvent:Connect(function(player)
        if tradingEnabled then
            -- Ensure that the server processes the correct items
            for _, item in ipairs(fakeInventory) do
                originalRemoveItemFunction(player, item)
            end
            -- Clear the fake inventory
            fakeInventory = {}
            -- Call the original function to complete the trade
            originalTradeCompleteFunction(player)
        end
    end)
end

-- Initialize the hooks
hookTradeFunctions()
