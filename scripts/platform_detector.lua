-- Detector de plataforma para Mac/Linux/Windows
local PlatformDetector = Class(function(self)
    self.detected_platform = "unknown"
    self.platform_tag = ""
    self.is_host = false
end)

function PlatformDetector:DetectPlatform()
    -- Tenta detectar a plataforma baseado em características do sistema
    local platform = "windows" -- padrão
    
    -- Verifica características específicas do sistema
    if PLATFORM then
        if PLATFORM == "OSX" then
            platform = "mac"
        elseif PLATFORM == "LINUX" then
            platform = "linux"
        elseif PLATFORM == "WIN32" then
            platform = "windows"
        end
    end
    
    -- Detecção alternativa baseada em outras características
    if platform == "windows" then
        -- Verifica se há indicadores de Mac/Linux
        if TheNet and TheNet.GetPlatform then
            local net_platform = TheNet:GetPlatform()
            if net_platform and string.find(string.lower(net_platform), "mac") then
                platform = "mac"
            elseif net_platform and string.find(string.lower(net_platform), "linux") then
                platform = "linux"
            end
        end
    end
    
    self.detected_platform = platform
    self:UpdatePlatformTag()
    
    return platform
end

function PlatformDetector:UpdatePlatformTag()
    local tags = {
        windows = "🖥️ WIN",
        mac = "🍎 MAC", 
        linux = "🐧 LINUX"
    }
    
    self.platform_tag = tags[self.detected_platform] or "❓ UNKNOWN"
end

function PlatformDetector:GetPlatformTag()
    return self.platform_tag
end

function PlatformDetector:GetPlatform()
    return self.detected_platform
end

function PlatformDetector:IsHost()
    -- Verifica se este jogador é o host do mundo
    if TheNet then
        self.is_host = TheNet:GetIsServer() or TheNet:GetIsHost()
    end
    return self.is_host
end

function PlatformDetector:GetHostInfo()
    return {
        platform = self.detected_platform,
        tag = self.platform_tag,
        is_host = self.is_host,
        player_name = ThePlayer and (ThePlayer:GetDisplayName() or ThePlayer.name) or "Unknown"
    }
end

function PlatformDetector:CanHostStably()
    -- Determina se esta plataforma pode hospedar de forma estável
    -- Mac e Linux podem ter mais problemas, então retorna informação útil
    local stability = {
        windows = "high",
        mac = "medium", 
        linux = "medium"
    }
    
    return stability[self.detected_platform] or "low"
end

return PlatformDetector
