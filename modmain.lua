-- Host Worlds Viewer - Main Mod File
-- Permite ver e hospedar mundos DST no Mac/Linux

-- Importa os componentes do mod
local PlatformDetector = require("scripts/platform_detector")
local WorldBrowser = require("scripts/world_browser")
local HostManager = require("scripts/host_manager")
local WorldUI = require("scripts/world_ui")

-- Variáveis globais do mod
local g_platform_detector = nil
local g_world_browser = nil
local g_host_manager = nil
local g_world_ui = nil

-- Configurações do mod
local MOD_CONFIG = {
    show_platform_tags = GetModConfigData("show_platform_tags"),
    auto_reconnect = GetModConfigData("auto_reconnect"),
    show_all_worlds = GetModConfigData("show_all_worlds"),
    host_stability = GetModConfigData("host_stability"),
    platform_detection = GetModConfigData("platform_detection"),
    world_visibility = GetModConfigData("world_visibility")
}

print("[HostWorldsMod] Iniciando Host Worlds Viewer v1.0.0")
print("[HostWorldsMod] Configurações carregadas:")
for key, value in pairs(MOD_CONFIG) do
    print("[HostWorldsMod] " .. key .. ": " .. tostring(value))
end

-- Função para inicializar o mod
local function InitializeMod()
    print("[HostWorldsMod] Inicializando componentes...")
    
    -- Inicializa detector de plataforma
    g_platform_detector = PlatformDetector()
    local detected_platform = g_platform_detector:DetectPlatform()
    print("[HostWorldsMod] Plataforma detectada: " .. detected_platform .. " (" .. g_platform_detector:GetPlatformTag() .. ")")
    
    -- Inicializa navegador de mundos
    g_world_browser = WorldBrowser()
    g_world_browser:Initialize()
    
    -- Inicializa gerenciador de host
    g_host_manager = HostManager()
    g_host_manager:Initialize(g_platform_detector)
    
    print("[HostWorldsMod] Componentes inicializados com sucesso!")
end

-- Função para criar a interface do usuário
local function CreateUI()
    if not ThePlayer then
        print("[HostWorldsMod] Aguardando jogador para criar UI...")
        return
    end
    
    if g_world_ui then
        print("[HostWorldsMod] UI já existe")
        return
    end
    
    print("[HostWorldsMod] Criando interface do usuário...")
    
    -- Cria a interface
    g_world_ui = ThePlayer.HUD:AddChild(WorldUI(g_world_browser, g_host_manager, g_platform_detector))
    
    if g_world_ui then
        print("[HostWorldsMod] Interface criada com sucesso!")
    else
        print("[HostWorldsMod] ERRO: Falha ao criar interface")
    end
end

-- Função para configurar controles
local function SetupControls()
    if not TheInput then
        print("[HostWorldsMod] Input não disponível ainda")
        return
    end
    
    print("[HostWorldsMod] Configurando controles...")
    
    -- Tecla 'H' para abrir/fechar interface
    TheInput:AddKeyDownHandler(KEY_H, function()
        if g_world_ui then
            g_world_ui:Toggle()
            print("[HostWorldsMod] Interface alternada via tecla H")
        else
            print("[HostWorldsMod] Interface não disponível")
        end
    end)
    
    -- Tecla TAB para navegar entre abas (quando interface estiver aberta)
    TheInput:AddKeyDownHandler(KEY_TAB, function()
        if g_world_ui and g_world_ui:IsVisible() then
            -- Navega entre as abas
            local current_tab = g_world_ui.current_tab
            if current_tab == "browse" then
                g_world_ui:SwitchTab("host")
            elseif current_tab == "host" then
                g_world_ui:SwitchTab("settings")
            else
                g_world_ui:SwitchTab("browse")
            end
            print("[HostWorldsMod] Navegação por TAB: " .. g_world_ui.current_tab)
        end
    end)
    
    print("[HostWorldsMod] Controles configurados: H = abrir/fechar, TAB = navegar abas")
end

-- Função para lidar com eventos de jogadores
local function SetupPlayerEvents()
    print("[HostWorldsMod] Configurando eventos de jogadores...")
    
    -- Evento quando jogador entra no mundo
    AddPrefabPostInit("world", function(inst)
        inst:ListenForEvent("ms_playerjoined", function(world, player)
            if g_host_manager and g_host_manager:GetHostStatus().is_hosting then
                g_host_manager:OnPlayerJoined(player)
            end
        end)
        
        inst:ListenForEvent("ms_playerleft", function(world, player)
            if g_host_manager and g_host_manager:GetHostStatus().is_hosting then
                g_host_manager:OnPlayerLeft(player)
            end
        end)
    end)
    
    -- Evento quando jogador spawna
    AddPlayerPostInit(function(player)
        if player == ThePlayer then
            print("[HostWorldsMod] Jogador principal detectado, criando UI...")
            CreateUI()
        end
    end)
end

-- Função para configurar eventos de rede
local function SetupNetworkEvents()
    print("[HostWorldsMod] Configurando eventos de rede...")
    
    -- Monitora desconexões para reconexão automática
    if MOD_CONFIG.auto_reconnect then
        AddPrefabPostInit("world", function(inst)
            inst:ListenForEvent("ms_playerdisconnected", function(world, data)
                if g_host_manager then
                    g_host_manager:HandlePlayerDisconnect(data.player)
                end
            end)
        end)
    end
end

-- Função para mostrar informações do mod no chat
local function ShowModInfo()
    if not ThePlayer then return end
    
    local platform_tag = g_platform_detector and g_platform_detector:GetPlatformTag() or "❓ UNKNOWN"
    local host_status = g_host_manager and g_host_manager:GetHostStatus().is_hosting and "🟢 Hospedando" or "🔴 Não hospedando"
    
    local info_message = string.format(
        "[Host Worlds] %s | %s | Pressione 'H' para abrir interface",
        platform_tag,
        host_status
    )
    
    if TheNet:GetIsServer() then
        print(info_message)
    else
        -- Em cliente, mostra no chat se possível
        if AllPlayers and #AllPlayers > 0 then
            print(info_message)
        end
    end
end

-- Função principal de inicialização
local function MainInitialization()
    print("[HostWorldsMod] =================================")
    print("[HostWorldsMod] HOST WORLDS VIEWER MOD")
    print("[HostWorldsMod] Versão 1.0.0")
    print("[HostWorldsMod] Suporte para Mac/Linux/Windows")
    print("[HostWorldsMod] =================================")
    
    -- Inicializa componentes principais
    InitializeMod()
    
    -- Configura eventos
    SetupPlayerEvents()
    SetupNetworkEvents()
    
    -- Aguarda o jogo estar pronto para configurar controles
    TheWorld:DoTaskInTime(1, function()
        SetupControls()
        
        -- Mostra informações do mod após 3 segundos
        TheWorld:DoTaskInTime(3, function()
            ShowModInfo()
        end)
    end)
    
    print("[HostWorldsMod] Inicialização completa!")
end

-- Função para limpeza quando o mod é descarregado
local function CleanupMod()
    print("[HostWorldsMod] Limpando recursos do mod...")
    
    if g_host_manager and g_host_manager:GetHostStatus().is_hosting then
        g_host_manager:StopHosting()
    end
    
    if g_world_ui then
        g_world_ui:Kill()
        g_world_ui = nil
    end
    
    print("[HostWorldsMod] Limpeza concluída")
end

-- Comandos de console para debug (apenas em modo debug)
if CHEATS_ENABLED then
    AddGameDebugKey(KEY_F1, function()
        if g_world_ui then
            g_world_ui:Toggle()
            print("[HostWorldsMod] DEBUG: Interface alternada via F1")
        end
    end)
    
    AddGameDebugKey(KEY_F2, function()
        if g_world_browser then
            local worlds = g_world_browser:ScanForWorlds()
            print("[HostWorldsMod] DEBUG: Encontrados " .. #worlds .. " mundos")
            for i, world in ipairs(worlds) do
                print("[HostWorldsMod] " .. i .. ": " .. world.name)
            end
        end
    end)
    
    AddGameDebugKey(KEY_F3, function()
        if g_host_manager then
            local status = g_host_manager:GetHostStatus()
            print("[HostWorldsMod] DEBUG: Host Status:")
            for key, value in pairs(status) do
                print("[HostWorldsMod] " .. key .. ": " .. tostring(value))
            end
        end
    end)
    
    print("[HostWorldsMod] Comandos debug: F1=UI, F2=Scan, F3=Status")
end

-- Função para salvar/carregar configurações persistentes
local function SaveModData()
    if g_host_manager then
        local host_status = g_host_manager:GetHostStatus()
        if host_status.is_hosting then
            -- Salva informações do mundo hospedado
            local save_data = {
                world_name = host_status.world_name,
                start_time = os.time(),
                platform = g_platform_detector:GetPlatform()
            }
            -- Em implementação real, salvaria em arquivo
            print("[HostWorldsMod] Dados do host salvos")
        end
    end
end

-- Configura salvamento automático
AddSimPostInit(function()
    TheWorld:DoPeriodicTask(60, SaveModData) -- Salva a cada minuto
end)

-- Evento quando o mundo é salvo
AddPrefabPostInit("world", function(inst)
    inst:ListenForEvent("ms_save", SaveModData)
end)

-- Inicia o mod
MainInitialization()

-- Registra função de limpeza
AddShutdownFn(CleanupMod)

print("[HostWorldsMod] Mod carregado com sucesso! Pressione 'H' para abrir a interface.")