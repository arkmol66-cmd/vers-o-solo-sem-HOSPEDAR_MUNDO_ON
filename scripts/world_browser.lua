-- Navegador de mundos hospedados para Mac/Linux
local WorldBrowser = Class(function(self)
    self.available_worlds = {}
    self.mod_worlds = {}
    self.all_worlds = {}
    self.last_scan = 0
    self.scan_interval = 10 -- segundos
end)

function WorldBrowser:Initialize()
    self.show_all_worlds = GetModConfigData("show_all_worlds")
    self.show_platform_tags = GetModConfigData("show_platform_tags")
    
    print("[WorldBrowser] Inicializado - Mostra todos: " .. tostring(self.show_all_worlds))
end

function WorldBrowser:ScanForWorlds()
    local current_time = os.time()
    
    if current_time - self.last_scan < self.scan_interval then
        return self.available_worlds
    end
    
    self.last_scan = current_time
    self.available_worlds = {}
    
    -- Escaneia mundos com o mod
    self:ScanModWorlds()
    
    -- Escaneia todos os mundos se configurado
    if self.show_all_worlds then
        self:ScanAllWorlds()
    end
    
    -- Combina e filtra resultados
    self:CombineWorldLists()
    
    print("[WorldBrowser] Encontrados " .. #self.available_worlds .. " mundos disponíveis")
    return self.available_worlds
end

function WorldBrowser:ScanModWorlds()
    -- Simula escaneamento de mundos que têm o mod
    -- Em implementação real, isso faria descoberta de rede
    
    self.mod_worlds = {
        {
            name = "Mundo Exemplo Mac",
            host = "Jogador_Mac",
            platform = "mac",
            players = 2,
            max_players = 6,
            has_mod = true,
            stable = true,
            world_id = "mac_world_001"
        },
        {
            name = "Servidor Linux Teste",
            host = "Linux_User",
            platform = "linux", 
            players = 1,
            max_players = 4,
            has_mod = true,
            stable = true,
            world_id = "linux_world_001"
        }
    }
end

function WorldBrowser:ScanAllWorlds()
    -- Simula escaneamento de todos os mundos disponíveis
    -- Inclui mundos sem o mod (pode ser instável)
    
    self.all_worlds = {
        {
            name = "Mundo Vanilla",
            host = "Windows_Player",
            platform = "windows",
            players = 3,
            max_players = 8,
            has_mod = false,
            stable = false, -- Pode cair a qualquer momento
            world_id = "vanilla_world_001"
        },
        {
            name = "Servidor Público",
            host = "Dedicated_Server",
            platform = "linux",
            players = 5,
            max_players = 10,
            has_mod = false,
            stable = false,
            world_id = "public_world_001"
        }
    }
end

function WorldBrowser:CombineWorldLists()
    self.available_worlds = {}
    
    -- Adiciona mundos com mod (sempre estáveis)
    for _, world in ipairs(self.mod_worlds) do
        table.insert(self.available_worlds, world)
    end
    
    -- Adiciona mundos sem mod se configurado
    if self.show_all_worlds then
        for _, world in ipairs(self.all_worlds) do
            table.insert(self.available_worlds, world)
        end
    end
    
    -- Ordena por estabilidade e plataforma
    table.sort(self.available_worlds, function(a, b)
        if a.has_mod ~= b.has_mod then
            return a.has_mod -- Mundos com mod primeiro
        end
        if a.stable ~= b.stable then
            return a.stable -- Mundos estáveis primeiro
        end
        return a.players < b.players -- Menos lotados primeiro
    end)
end

function WorldBrowser:GetWorldInfo(world_id)
    for _, world in ipairs(self.available_worlds) do
        if world.world_id == world_id then
            return world
        end
    end
    return nil
end

function WorldBrowser:CanJoinWorld(world_id)
    local world = self:GetWorldInfo(world_id)
    if not world then
        return false, "Mundo não encontrado"
    end
    
    if world.players >= world.max_players then
        return false, "Mundo lotado"
    end
    
    -- Aviso para mundos sem mod
    if not world.has_mod then
        return true, "AVISO: Mundo sem mod - pode cair a qualquer momento"
    end
    
    return true, "Mundo disponível"
end

function WorldBrowser:GetPlatformIcon(platform)
    local icons = {
        windows = "🖥️",
        mac = "🍎",
        linux = "🐧"
    }
    return icons[platform] or "❓"
end

function WorldBrowser:GetStabilityIcon(world)
    if world.has_mod then
        return "✅" -- Estável com mod
    else
        return "⚠️" -- Instável sem mod
    end
end

function WorldBrowser:FormatWorldEntry(world)
    local platform_icon = self:GetPlatformIcon(world.platform)
    local stability_icon = self:GetStabilityIcon(world)
    local mod_status = world.has_mod and "[MOD]" or "[VANILLA]"
    
    return string.format("%s %s %s %s (%d/%d) - %s", 
        stability_icon,
        platform_icon,
        mod_status,
        world.name,
        world.players,
        world.max_players,
        world.host
    )
end

function WorldBrowser:GetWorldList()
    local worlds = self:ScanForWorlds()
    local formatted_list = {}
    
    for _, world in ipairs(worlds) do
        table.insert(formatted_list, {
            display = self:FormatWorldEntry(world),
            world_id = world.world_id,
            world_data = world
        })
    end
    
    return formatted_list
end

function WorldBrowser:JoinWorld(world_id)
    local world = self:GetWorldInfo(world_id)
    if not world then
        print("[WorldBrowser] Erro: Mundo não encontrado")
        return false
    end
    
    local can_join, message = self:CanJoinWorld(world_id)
    if not can_join then
        print("[WorldBrowser] Não é possível entrar: " .. message)
        return false
    end
    
    print("[WorldBrowser] Entrando no mundo: " .. world.name)
    if message and message ~= "Mundo disponível" then
        print("[WorldBrowser] " .. message)
    end
    
    -- Em implementação real, isso iniciaria a conexão
    self:SimulateJoinWorld(world)
    
    return true
end

function WorldBrowser:SimulateJoinWorld(world)
    -- Simula processo de entrada no mundo
    print("[WorldBrowser] Conectando ao mundo " .. world.name .. "...")
    print("[WorldBrowser] Host: " .. world.host .. " (" .. world.platform .. ")")
    print("[WorldBrowser] Jogadores: " .. world.players .. "/" .. world.max_players)
    
    if world.has_mod then
        print("[WorldBrowser] ✅ Mundo com mod - conexão estável")
    else
        print("[WorldBrowser] ⚠️ Mundo sem mod - pode desconectar a qualquer momento")
    end
end

return WorldBrowser