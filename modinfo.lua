name = "Host Worlds Viewer (Mac/Linux Support)"
description = "VOCÊ PODE VER MUNDOS HOSPEDADOS E TORNAR DISPONÍVEL PARA MAC LINUX E WINDOWS. Outras pessoas hospedando mundo com ou sem mod você pode ver. Você pode cair do mundo a qualquer momento porque a Klei não ativou isso. Você pode criar mundo com mod mas só pessoas com mod podem ver seu mundo hospedado. Se hospetar mundo você não cai mais, outras pessoas podem cair. Você terá tag MAC/LINUX/WINDOWS pelo seu sistema."
author = "DST Community"
version = "1.0.0"

forumthread = ""

api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

all_clients_require_mod = false
client_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {"host", "multiplataforma", "mac", "linux", "windows", "viewer"}

configuration_options = {
    {
        name = "show_platform_tags",
        label = "Mostrar Tags de Plataforma",
        hover = "Mostra se o servidor é MAC/LINUX/WINDOWS",
        options = {
            {description = "Ativado", data = true},
            {description = "Desativado", data = false}
        },
        default = true
    },
    {
        name = "auto_reconnect",
        label = "Reconexão Automática",
        hover = "Tenta reconectar automaticamente se cair do mundo",
        options = {
            {description = "Ativado", data = true},
            {description = "Desativado", data = false}
        },
        default = true
    },
    {
        name = "show_all_worlds",
        label = "Mostrar Todos os Mundos",
        hover = "Mostra mundos mesmo sem o mod (pode ser instável)",
        options = {
            {description = "Ativado", data = true},
            {description = "Desativado", data = false}
        },
        default = true
    },
    {
        name = "host_stability",
        label = "Estabilidade do Host",
        hover = "Melhora estabilidade quando você hospeda",
        options = {
            {description = "Máxima", data = "max"},
            {description = "Alta", data = "high"},
            {description = "Normal", data = "normal"}
        },
        default = "max"
    },
    {
        name = "platform_detection",
        label = "Detecção de Plataforma",
        hover = "Como detectar a plataforma do jogador",
        options = {
            {description = "Automática", data = "auto"},
            {description = "Manual", data = "manual"}
        },
        default = "auto"
    },
    {
        name = "world_visibility",
        label = "Visibilidade do Mundo",
        hover = "Quem pode ver seu mundo hospedado",
        options = {
            {description = "Só com Mod", data = "mod_only"},
            {description = "Todos (Experimental)", data = "all"}
        },
        default = "mod_only"
    }
}