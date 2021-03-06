------------------------------------------------------------
-- 保存外觀
------------------------------------------------------------
RegisterServerEvent('ARP:SavePlayerSkin')
AddEventHandler('ARP:SavePlayerSkin', function(skin)
    local source = source
    MySQL.Async.execute('UPDATE arp_users SET skin = @skin WHERE identifier = @identifier', {
        ['@identifier'] = GetPlayerIdentifier(source),
        ['@skin'] = json.encode(skin)
    })
end)

------------------------------------------------------------
-- 讀取外觀
------------------------------------------------------------
RegisterServerEvent('ARP:LoadSkin')
AddEventHandler('ARP:LoadSkin', function()
    local source = source
    MySQL.Async.fetchScalar('SELECT skin FROM arp_users WHERE identifier = @identifier', {
        ['@identifier'] = GetPlayerIdentifier(source),
    }, function(result)
        if result then
            local loadskin = json.decode(result)
            TriggerClientEvent('ARP:SetPlayerSkin', source, loadskin)
        end
    end)
end)