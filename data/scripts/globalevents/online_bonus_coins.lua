-- Online Bonus: concede 1 coin (não transferível) a cada 6 minutos

local onlineBonusCoins = GlobalEvent("OnlineBonusCoins")

function onlineBonusCoins.onThink(interval)
    local players = Game.getPlayers()
    if #players == 0 then
        return true
    end

    for _, player in ipairs(players) do
        -- Evita premiar grupos staff (igual ao padrão usado em outros sistemas)
        if player:getGroup():getId() <= GROUP_TYPE_SENIORTUTOR then
            -- Adiciona coin normal (não transferível) e atualiza UI do store
            player:addCoinsBalance(1, true)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você recebeu 1 coin por estar online.")
        end
    end
    return true
end

-- 6 minutos
onlineBonusCoins:interval(6 * 60 * 1000)
onlineBonusCoins:register()