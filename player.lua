-- Replace every function there by the ones existing in your file -> qb-core/server/player.lua

-- READ THIS
-- !!! I'm USING quasar exports here !!!
-- !!! If you are using qb-inventory replace qs-inventory by qb-inventory !!!

function self.Functions.AddMoney(moneytype, amount, reason)
        source = self.PlayerData.source
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return end
        if not self.PlayerData.money[moneytype] then return false end
        --self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] + amount
        if moneytype == 'cash' then
            local item = exports['qs-inventory']:GetItemByName(source,'cash')
            if exports['qs-inventory']:HasItem(source,'cash') then
                --local slot = exports['qs-inventory']:GetItemBySlot(self.PlayerData.items,item)
                local slots = exports['qs-inventory']:GetSlotsByItem(self.PlayerData.items,'cash')
                exports['qs-inventory']:AddItem(source,'cash',amount,slots[1])
            else
                exports['qs-inventory']:AddItem(source,'cash',amount)
            end
        else
            self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] + amount
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
            else
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            end
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, false)
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, "add", reason)
            TriggerEvent('QBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, "add", reason)
        end

        return true
    end

function self.Functions.RemoveMoney(moneytype, amount, reason)
        source = self.PlayerData.source
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return end
        if not self.PlayerData.money[moneytype] then return false end
        for _, mtype in pairs(QBCore.Config.Money.DontAllowMinus) do
            if mtype == moneytype and moneytype == not 'cash' then
                if (self.PlayerData.money[moneytype] - amount) < 0 then
                    return false
                end
            end
        end
        --self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount
        if moneytype == 'cash' then
            local item = exports['qs-inventory']:GetItemByName(source,'cash')
            if exports['qs-inventory']:HasItem(source,'cash') then
                local totalmoney = self.Functions.GetMoney('cash')
                if totalmoney >= amount then
                    local slots = exports['qs-inventory']:GetSlotsByItem(self.PlayerData.items,'cash')
                    for k,v in pairs(slots) do
                        local toRemove = math.min(exports['qs-inventory']:GetItemBySlot(source,slots[k]).amount,amount)
                        exports['qs-inventory']:RemoveItem(source,'cash',toRemove,slots[k])
                        amount = amount - toRemove
                    end
                else
                    return false
                end
            else
                return false
            end
        else
            self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
            else
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            end
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, true)
            if moneytype == 'bank' then
                TriggerClientEvent('qb-phone:client:RemoveBankMoney', self.PlayerData.source, amount)
            end
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, "remove", reason)
            TriggerEvent('QBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, "remove", reason)
        end

        return true
    end

    function self.Functions.SetMoney(moneytype, amount, reason)
        source = self.PlayerData.source
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return false end
        if not self.PlayerData.money[moneytype] then return false end
        --local difference = amount - self.PlayerData.money[moneytype]
        --self.PlayerData.money[moneytype] = amount
        local difference = 0
        if moneytype == 'cash' then
            if exports['qs-inventory']:HasItem(source,'cash') then
                local item = exports['qs-inventory']:GetItemByName(source,'cash')
                local slot = exports['qs-inventory']:GetItemBySlot(self.PlayerData.items,item)
                exports['qs-inventory']:RemoveItem(source,'cash',item.amount,slot)
                exports['qs-inventory']:AddItem(source,'cash',amount,slot)
                difference = amount - item.amount
            else
                exports['qs-inventory']:AddItem(source,'cash',amount)
                difference = amount
            end
        else
            difference = amount - self.PlayerData.money[moneytype]
            self.PlayerData.money[moneytype] = amount
        end

        

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'SetMoney', 'green', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') set, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, math.abs(difference), difference < 0)
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, "set", reason)
            TriggerEvent('QBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, "set", reason)
        end

        return true
    end

    function self.Functions.GetMoney(moneytype)
        source = self.PlayerData.source
        if not moneytype then return false end
        moneytype = moneytype:lower()
        if moneytype == 'cash' then
            if exports['qs-inventory']:HasItem(source,'cash') then
                local slots = exports['qs-inventory']:GetSlotsByItem(self.PlayerData.items,'cash')
                local totalmoney = 0
                for k,v in pairs(slots) do
                    totalmoney = totalmoney + exports['qs-inventory']:GetItemBySlot(source,slots[k]).amount
                end
                local item = exports['qs-inventory']:GetItemByName(source,'cash')
                return totalmoney
            else
                return 0
            end
        else
            return self.PlayerData.money[moneytype]
        end 
    end
