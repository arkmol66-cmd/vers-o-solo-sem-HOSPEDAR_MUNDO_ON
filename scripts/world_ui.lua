-- Interface para visualizar e gerenciar mundos
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local ScrollableList = require "widgets/scrollablelist"

local WorldUI = Class(Widget, function(self, world_browser, host_manager, platform_detector)
    Widget._ctor(self, "WorldUI")
    
    self.world_browser = world_browser
    self.host_manager = host_manager
    self.platform_detector = platform_detector
    
    self.is_visible = false
    self.current_tab = "browse" -- browse, host, settings
    
    self:CreateInterface()
    self:Hide()
end)

function WorldUI:CreateInterface()
    -- Fundo escuro
    self.background = self:AddChild(Image("images/global_redux.xml", "bg_redux_dark.tex"))
    self.background:SetVRegPoint(ANCHOR_MIDDLE)
    self.background:SetHRegPoint(ANCHOR_MIDDLE)
    self.background:SetVAnchor(ANCHOR_MIDDLE)
    self.background:SetHAnchor(ANCHOR_MIDDLE)
    self.background:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.background:SetTint(0, 0, 0, 0.85)
    
    -- Painel principal
    self.main_panel = self:AddChild(Image("images/global_redux.xml", "panel_upsell.tex"))
    self.main_panel:SetPosition(0, 0, 0)
    self.main_panel:SetScale(1.5, 1.2, 1.0)
    
    -- Título
    self.title = self:AddChild(Text(CHATFONT, 36))
    self.title:SetPosition(0, 250, 0)
    self.title:SetString("🌍 Navegador de Mundos DST")
    self.title:SetColour(1, 1, 0, 1)
    
    -- Informação da plataforma
    self.platform_info = self:AddChild(Text(CHATFONT, 24))
    self.platform_info:SetPosition(0, 210, 0)
    self.platform_info:SetString("Detectando plataforma...")
    self.platform_info:SetColour(0.8, 0.8, 1, 1)
    
    -- Abas
    self:CreateTabs()
    
    -- Conteúdo das abas
    self:CreateBrowseTab()
    self:CreateHostTab()
    self:CreateSettingsTab()
    
    -- Botão fechar
    self.close_button = self:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.close_button:SetPosition(0, -280, 0)
    self.close_button:SetText("Fechar")
    self.close_button:SetOnClick(function() self:Hide() end)
    
    -- Instrução
    self.instruction = self:AddChild(Text(CHATFONT, 16))
    self.instruction:SetPosition(0, -320, 0)
    self.instruction:SetString("Pressione 'H' para abrir/fechar | Tab para navegar")
    self.instruction:SetColour(0.7, 0.7, 0.7, 1)
end

function WorldUI:CreateTabs()
    -- Aba Navegar
    self.tab_browse = self:AddChild(ImageButton("images/global_redux.xml", "button_carny_short_normal.tex", "button_carny_short_hover.tex", "button_carny_short_disabled.tex", "button_carny_short_down.tex"))
    self.tab_browse:SetPosition(-150, 170, 0)
    self.tab_browse:SetText("🔍 Navegar")
    self.tab_browse:SetOnClick(function() self:SwitchTab("browse") end)
    
    -- Aba Hospedar
    self.tab_host = self:AddChild(ImageButton("images/global_redux.xml", "button_carny_short_normal.tex", "button_carny_short_hover.tex", "button_carny_short_disabled.tex", "button_carny_short_down.tex"))
    self.tab_host:SetPosition(0, 170, 0)
    self.tab_host:SetText("🏠 Hospedar")
    self.tab_host:SetOnClick(function() self:SwitchTab("host") end)
    
    -- Aba Configurações
    self.tab_settings = self:AddChild(ImageButton("images/global_redux.xml", "button_carny_short_normal.tex", "button_carny_short_hover.tex", "button_carny_short_disabled.tex", "button_carny_short_down.tex"))
    self.tab_settings:SetPosition(150, 170, 0)
    self.tab_settings:SetText("⚙️ Config")
    self.tab_settings:SetOnClick(function() self:SwitchTab("settings") end)
end

function WorldUI:CreateBrowseTab()
    -- Container da aba navegar
    self.browse_content = self:AddChild(Widget("BrowseContent"))
    
    -- Lista de mundos
    self.world_list_title = self.browse_content:AddChild(Text(CHATFONT, 20))
    self.world_list_title:SetPosition(0, 120, 0)
    self.world_list_title:SetString("🌍 Mundos Disponíveis")
    self.world_list_title:SetColour(1, 1, 1, 1)
    
    -- Área da lista
    self.world_list_area = self.browse_content:AddChild(Widget("WorldListArea"))
    self.world_list_area:SetPosition(0, 0, 0)
    
    -- Status da busca
    self.search_status = self.browse_content:AddChild(Text(CHATFONT, 16))
    self.search_status:SetPosition(0, 80, 0)
    self.search_status:SetString("Buscando mundos...")
    self.search_status:SetColour(0.8, 0.8, 0.8, 1)
    
    -- Botão atualizar
    self.refresh_button = self.browse_content:AddChild(ImageButton("images/global_redux.xml", "button_carny_short_normal.tex", "button_carny_short_hover.tex", "button_carny_short_disabled.tex", "button_carny_short_down.tex"))
    self.refresh_button:SetPosition(0, -200, 0)
    self.refresh_button:SetText("🔄 Atualizar")
    self.refresh_button:SetOnClick(function() self:RefreshWorldList() end)
end

function WorldUI:CreateHostTab()
    -- Container da aba hospedar
    self.host_content = self:AddChild(Widget("HostContent"))
    
    -- Status do host
    self.host_status_title = self.host_content:AddChild(Text(CHATFONT, 20))
    self.host_status_title:SetPosition(0, 120, 0)
    self.host_status_title:SetString("🏠 Status da Hospedagem")
    self.host_status_title:SetColour(1, 1, 1, 1)
    
    -- Informações do host
    self.host_info_text = self.host_content:AddChild(Text(CHATFONT, 16))
    self.host_info_text:SetPosition(0, 60, 0)
    self.host_info_text:SetString("Não hospedando")
    self.host_info_text:SetColour(0.8, 0.8, 0.8, 1)
    
    -- Botão iniciar/parar host
    self.host_toggle_button = self.host_content:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.host_toggle_button:SetPosition(0, 0, 0)
    self.host_toggle_button:SetText("🚀 Iniciar Hospedagem")
    self.host_toggle_button:SetOnClick(function() self:ToggleHosting() end)
    
    -- Aviso sobre estabilidade
    self.stability_warning = self.host_content:AddChild(Text(CHATFONT, 14))
    self.stability_warning:SetPosition(0, -60, 0)
    self.stability_warning:SetString("⚠️ Como host, você não cairá do mundo\n✅ Outros jogadores podem cair a qualquer momento")
    self.stability_warning:SetColour(1, 0.8, 0.6, 1)
    
    -- Jogadores conectados
    self.connected_players = self.host_content:AddChild(Text(CHATFONT, 16))
    self.connected_players:SetPosition(0, -120, 0)
    self.connected_players:SetString("Jogadores: 0/0")
    self.connected_players:SetColour(0.6, 1, 0.6, 1)
end

function WorldUI:CreateSettingsTab()
    -- Container da aba configurações
    self.settings_content = self:AddChild(Widget("SettingsContent"))
    
    -- Título
    self.settings_title = self.settings_content:AddChild(Text(CHATFONT, 20))
    self.settings_title:SetPosition(0, 120, 0)
    self.settings_title:SetString("⚙️ Configurações do Mod")
    self.settings_title:SetColour(1, 1, 1, 1)
    
    -- Informações das configurações
    self.settings_info = self.settings_content:AddChild(Text(CHATFONT, 14))
    self.settings_info:SetPosition(0, 40, 0)
    self.settings_info:SetString("Configure o mod no menu principal\n\n🔍 Mostrar Todos os Mundos: Vê mundos sem mod\n🔄 Reconexão Automática: Tenta reconectar se cair\n🏠 Estabilidade do Host: Melhora performance\n👁️ Visibilidade: Quem pode ver seu mundo")
    self.settings_info:SetColour(0.9, 0.9, 0.9, 1)
    
    -- Aviso importante
    self.important_warning = self.settings_content:AddChild(Text(CHATFONT, 16))
    self.important_warning:SetPosition(0, -80, 0)
    self.important_warning:SetString("⚠️ IMPORTANTE ⚠️\n\nMundos SEM o mod podem desconectar\na qualquer momento (limitação da Klei)\n\nMundos COM o mod são mais estáveis")
    self.important_warning:SetColour(1, 0.6, 0.6, 1)
end

function WorldUI:SwitchTab(tab_name)
    self.current_tab = tab_name
    
    -- Esconde todos os conteúdos
    self.browse_content:Hide()
    self.host_content:Hide()
    self.settings_content:Hide()
    
    -- Mostra o conteúdo da aba selecionada
    if tab_name == "browse" then
        self.browse_content:Show()
        self:RefreshWorldList()
    elseif tab_name == "host" then
        self.host_content:Show()
        self:UpdateHostInfo()
    elseif tab_name == "settings" then
        self.settings_content:Show()
    end
    
    -- Atualiza aparência das abas
    self:UpdateTabAppearance()
end

function WorldUI:UpdateTabAppearance()
    -- Reseta todas as abas
    self.tab_browse:SetText("🔍 Navegar")
    self.tab_host:SetText("🏠 Hospedar")
    self.tab_settings:SetText("⚙️ Config")
    
    -- Destaca a aba ativa
    if self.current_tab == "browse" then
        self.tab_browse:SetText("🔍 [Navegar]")
    elseif self.current_tab == "host" then
        self.tab_host:SetText("🏠 [Hospedar]")
    elseif self.current_tab == "settings" then
        self.tab_settings:SetText("⚙️ [Config]")
    end
end

function WorldUI:RefreshWorldList()
    if self.current_tab ~= "browse" then return end
    
    self.search_status:SetString("🔄 Buscando mundos...")
    
    -- Busca mundos disponíveis
    local worlds = self.world_browser:GetWorldList()
    
    -- Limpa lista anterior
    if self.world_list_items then
        for _, item in ipairs(self.world_list_items) do
            item:Kill()
        end
    end
    self.world_list_items = {}
    
    -- Adiciona mundos encontrados
    if #worlds > 0 then
        self.search_status:SetString("✅ Encontrados " .. #worlds .. " mundos")
        
        for i, world in ipairs(worlds) do
            local world_item = self:CreateWorldListItem(world, i)
            table.insert(self.world_list_items, world_item)
        end
    else
        self.search_status:SetString("❌ Nenhum mundo encontrado")
    end
end

function WorldUI:CreateWorldListItem(world, index)
    local item = self.world_list_area:AddChild(Widget("WorldItem" .. index))
    local y_pos = 40 - (index * 25)
    item:SetPosition(0, y_pos, 0)
    
    -- Texto do mundo
    local world_text = item:AddChild(Text(CHATFONT, 14))
    world_text:SetString(world.display)
    world_text:SetColour(1, 1, 1, 1)
    
    -- Botão para entrar
    local join_button = item:AddChild(ImageButton("images/global_redux.xml", "button_carny_xshort_normal.tex", "button_carny_xshort_hover.tex", "button_carny_xshort_disabled.tex", "button_carny_xshort_down.tex"))
    join_button:SetPosition(200, 0, 0)
    join_button:SetText("Entrar")
    join_button:SetOnClick(function() 
        self:JoinWorld(world.world_id)
    end)
    
    return item
end

function WorldUI:JoinWorld(world_id)
    print("[WorldUI] Tentando entrar no mundo: " .. world_id)
    
    if self.world_browser:JoinWorld(world_id) then
        self:Hide() -- Fecha a interface ao entrar no mundo
    end
end

function WorldUI:ToggleHosting()
    if self.host_manager:GetHostStatus().is_hosting then
        self.host_manager:StopHosting()
    else
        self.host_manager:StartHosting()
    end
    
    self:UpdateHostInfo()
end

function WorldUI:UpdateHostInfo()
    if self.current_tab ~= "host" then return end
    
    local status = self.host_manager:GetHostStatus()
    local platform_info = self.platform_detector:GetHostInfo()
    
    if status.is_hosting then
        self.host_info_text:SetString(string.format(
            "🟢 Hospedando: %s\n%s\nJogadores: %d/%d\nTempo ativo: %ds",
            status.world_name,
            platform_info.tag,
            status.players,
            status.max_players,
            status.uptime
        ))
        self.host_toggle_button:SetText("🛑 Parar Hospedagem")
        self.connected_players:SetString(string.format("Jogadores: %d/%d", status.players, status.max_players))
    else
        self.host_info_text:SetString("🔴 Não hospedando\n" .. platform_info.tag)
        self.host_toggle_button:SetText("🚀 Iniciar Hospedagem")
        self.connected_players:SetString("Jogadores: 0/0")
    end
end

function WorldUI:Show()
    if self.is_visible then return end
    
    self.is_visible = true
    
    -- Atualiza informações da plataforma
    local platform_info = self.platform_detector:GetHostInfo()
    self.platform_info:SetString("Sua plataforma: " .. platform_info.tag)
    
    -- Mostra aba inicial
    self:SwitchTab("browse")
    
    -- Animação de entrada
    self:SetScale(0.8)
    self:ScaleTo(1.0, 0.2)
    
    -- Atualiza periodicamente
    if self.update_task then
        self.update_task:Cancel()
    end
    
    self.update_task = self.inst:DoPeriodicTask(2, function()
        if self.is_visible then
            if self.current_tab == "browse" then
                -- Atualiza lista de mundos periodicamente
            elseif self.current_tab == "host" then
                self:UpdateHostInfo()
            end
        end
    end)
end

function WorldUI:Hide()
    if not self.is_visible then return end
    
    self.is_visible = false
    
    if self.update_task then
        self.update_task:Cancel()
        self.update_task = nil
    end
    
    self:ScaleTo(0.8, 0.1, function()
        Widget.Hide(self)
    end)
end

function WorldUI:Toggle()
    if self.is_visible then
        self:Hide()
    else
        self:Show()
    end
end

function WorldUI:IsVisible()
    return self.is_visible
end

return WorldUI