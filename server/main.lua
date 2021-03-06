------------------------------------------------------------
-- 登入
------------------------------------------------------------
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local identifiers = GetPlayerIdentifiers(source)
    local identifier
    deferrals.defer()

    for _, id in ipairs(identifiers) do 
        if string.match(id, 'steam:') then
            identifier = id
            break
        end
    end

    Wait(0)

    if not identifier then
        deferrals.done('您尚未連接到Steam')
    else
        deferrals.done()
        PlayerJoin(source)
    end
end)

------------------------------------------------------------
-- 註冊 Steam
------------------------------------------------------------
function PlayerJoin(playerId)
    local identifier

    for _, id in ipairs(GetPlayerIdentifiers(playerId)) do 
        if string.match(id, 'steam:') then
            identifier = id 
            break
        end
    end

    if identifier then
        MySQL.Async.fetchScalar('SELECT 1 FROM arp_users WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        }, function(result)
            if result then
            else
                MySQL.Async.execute('INSERT INTO arp_users (identifier) VALUES (@identifier)', {
                    ['@identifier'] = identifier
                })
            end
        end)
    end
end

------------------------------------------------------------
-- 紀錄玩家位置/生成
------------------------------------------------------------
RegisterServerEvent('ARP:UpdatePosition')
AddEventHandler('ARP:UpdatePosition', function(PosX, PosY, PosZ)
    MySQL.Async.execute('UPDATE arp_users SET position = @position WHERE identifier = @identifier', {
        ['@identifier'] = GetPlayerIdentifier(source),
        ['@position'] = '{' .. PosX .. ', ' .. PosY .. ', ' .. PosZ .. '}',
    })
end)

RegisterServerEvent('ARP:SpawnPlayer')
AddEventHandler('ARP:SpawnPlayer', function()
    local source = source
    MySQL.Async.fetchAll('SELECT * FROM arp_users WHERE identifier = @identifier', {
        ['@identifier'] = GetPlayerIdentifier(source),
    }, function(result)
        for k, v in ipairs(result) do 
            if v.skin ~= nil then
                local Spawnpos = json.decode(v.position)
                TriggerClientEvent('ARP:lastPosition', source, Spawnpos[1], Spawnpos[2], Spawnpos[3], true)
            else
                TriggerClientEvent('ARP:lastPosition', source, -269.4, -955.3, 31.2, false)
            end
        end
    end)
end)