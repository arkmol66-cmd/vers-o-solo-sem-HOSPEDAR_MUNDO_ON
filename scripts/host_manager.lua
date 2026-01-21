-- Gerenciador de hospedagem para Mac/Linux
local HostManager = Class(function(self)
    self.is_hosting = false
    self.host_info = {}
    self.stability_level = "normal"
    self.connected_players = {}
    self.auto_reconnect = true
end)

function HostManager:Initialize(platform_detector)
    self.platform_detector = platform_detector
    self.stability_level = GetModConfigData("host_stability") or "normal"
    self.auto_reconnect = GetModConfigData("auto_reconnect")
    self.world_visibility = GetModConfigData("world_visibility") or "mod_only"
    
    print("[HostManager] Inicializado - Estabilidade: " .. self.stability_level)
end

function HostManager:StartHosting()
    if self.is_hosting then
        print("[HostManager] Já está hospedando")
        return false
    end
    
    local platform_info = self.platform_detector:GetHostInfo()
    
    self.host_info = {
        platform = platform_info.platform,
        tag = platform_info.tag,
        host_name = platform_info.player_name,
        world_name = self:GenerateWorldName(),
        start_time = os.time(),
        stability = self.stability_level,
        visibility = self.world_visibility,
        max_players = self:GetMaxPlayers()
    }
    
    self.is_hosting = true
    
    print("[HostManager] Iniciando hospedagem...")
    print("[HostManager] Plataforma: " .. self.host_info.tag)
    print("[HostManager] Mundo: " .. self.host_info.world_name)
    print("[HostManager] Visibilidade: " .. self.world_visibility)
    
    self:ApplyHostStabilitySettings()
    self:RegisterWorldWithMod()
    
    return true
end

function HostManager:StopHosting()
    if not self.is_hosting then
        return false
    end
    
    print("[HostManager] Parando hospedagem...")
    
    -- Notifica jogadores conectados
    self:NotifyPlayersHostStopping()
    
    self.is_hosting = false
    self.connected_players = {}
    
    return true
end

function HostManager:GenerateWorldName()
    local platform = self.platform_detector:GetPlatform()
    local timestamp = os.date("%H%M")
    local platform_names = {
        windows = "Win",
        mac = "Mac", 
        linux = "Linux"
    }
    
    return (platform_names[platform] or "Unknown") .. "_World_" .. timestamp
end

function HostManager:GetMaxPlayers()
    -- Define número máximo baseado na plataforma e estabilidade
    local base_players = {
        windows = 8,
        mac = 6,
        linux = 6
    }
    
    local max_base = base_players[self.platform_detector:GetPlatform()] or 4
    
    -- Ajusta baseado na estabilidade configurada
    if self.stability_level == "max" then
        return math.max(4, max_base - 2) -- Mais conservador
    elseif self.stability_level == "high" then
        return max_base - 1
    else
        return max_base
    end
end

function HostManager:ApplyHostStabilitySettings()
    -- Aplica configurações para melhorar estabilidade
    print("[HostManager] Aplicando configurações de estabilidade: " .. self.stability_level)
    
    if self.stability_level == "max" then
        -- Configurações máximas de estabilidade
        self:SetNetworkOptimizations("conservative")
        self:SetMemoryManagement("aggressive")
        self:SetUpdateFrequency("reduced")
    elseif self.stability_level == "high" then
        -- Configurações altas de estabilidade
        self:SetNetworkOptimizations("balanced")
        self:SetMemoryManagement("normal")
        self:SetUpdateFrequency("normal")
    else
        -- Configurações normais
        self:SetNetworkOptimizations("default")
        self:SetMemoryManagement("default")
        self:SetUpdateFrequency("default")
    end
end

function HostManager:SetNetworkOptimizations(level)
    print("[HostManager] Otimizações de rede: " .. level)
    -- Em implementação real, ajustaria configurações de rede
end

function HostManager:SetMemoryManagement(level)
    print("[HostManager] Gerenciamento de memória: " .. level)
    -- Em implementação real, ajustaria garbage collection e cache
end

function HostManager:SetUpdateFrequency(level)
    print("[HostManager] Frequência de updates: " .. level)
    -- Em implementação real, ajustaria tick rate e sync
end

function HostManager:RegisterWorldWithMod()
    -- Registra o mundo na rede de mods para outros jogadores encontrarem
    local world_data = {
        name = self.host_info.world_name,
        host = self.host_info.host_name,
        platform = self.host_info.platform,
        tag = self.host_info.tag,
        max_players = self.host_info.max_players,
        has_mod = true,
        stable = true,
        visibility = self.world_visibility,
        start_time = self.host_info.start_time
    }
    
    print("[HostManager] Mundo registrado na rede de mods")
    print("[HostManager] Outros jogadores com o mod podem ver seu mundo")
    
    if self.world_visibility == "all" then
        print("[HostManager] EXPERIMENTAL: Tentando tornar visível para todos")
        -- Em implementação real, tentaria registrar em serviços públicos
    end
end

function HostManager:OnPlayerJoined(player)
    if not player then return end
    
    local player_info = {
        id = player.userid or tostring(player.GUID),
        name = player:GetDisplayName() or player.name or "Unknown",
        join_time = os.time(),
        platform = "unknown" -- Seria detectado se o jogador tiver o mod
    }
    
    self.connected_players[player_info.id] = player_info
    
    print("[HostManager] Jogador entrou: " .. player_info.name)
    print("[HostManager] Jogadores conectados: " .. self:GetPlayerCount())
    
    -- Envia informações do host para o jogador
    self:SendHostInfoToPlayer(player)
end

function HostManager:OnPlayerLeft(player)
    if not player then return end
    
    local player_id = player.userid or tostring(player.GUID)
    local player_info = self.connected_players[player_id]
    
    if player_info then
        self.connected_players[player_id] = nil
        print("[HostManager] Jogador saiu: " .. player_info.name)
        print("[HostManager] Jogadores conectados: " .. self:GetPlayerCount())
    end
end

function HostManager:SendHostInfoToPlayer(player)
    -- Envia informações sobre o host para jogadores que entram
    local info_message = string.format(
        "Bem-vindo ao %s hospedado por %s (%s)",
        self.host_info.world_name,
        self.host_info.host_name,
        self.host_info.tag
    )
    
    print("[HostManager] Enviando info para " .. (player:GetDisplayName() or "jogador"))
    -- Em implementação real, enviaria via chat ou interface
end

function HostManager:GetPlayerCount()
    local count = 0
    for _ in pairs(self.connected_players) do
        count = count + 1
    end
    return count
end

function HostManager:NotifyPlayersHostStopping()
    print("[HostManager] Notificando jogadores sobre parada do host...")
    
    for _, player_info in pairs(self.connected_players) do
        print("[HostManager] Notificando: " .. player_info.name)
    end
end

function HostManager:GetHostStatus()
    return {
        is_hosting = self.is_hosting,
        world_name = self.host_info.world_name or "N/A",
        platform = self.host_info.tag or "N/A",
        players = self:GetPlayerCount(),
        max_players = self.host_info.max_players or 0,
        stability = self.stability_level,
        uptime = self.is_hosting and (os.time() - self.host_info.start_time) or 0
    }
end

function HostManager:HandlePlayerDisconnect(player)
    -- Tenta reconectar jogador se configurado
    if self.auto_reconnect and not self.platform_detector:IsHost() then
        print("[HostManager] Tentando reconexão automática...")
        -- Em implementação real, tentaria reconectar
    end
end

return HostManager