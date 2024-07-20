---

title: 'WindowsTerminal美化教程'

date: 2024-07-19T14:13:04+08:00

draft: false

summary: "美化 terminal 窗口"
categories: [教程]
---

<hr>

Windows终端的选型有很多，经过试用最终是选择了 WindowsTerminal + PowerShell的组合。但是默认的WindowsTerminal也没那么好看，下面就来介绍一下如何美化。

### oh-my-posh

[Home | Oh My Posh](https://ohmyposh.dev/)

先安装一下oh-my-posh，然后选择一个自己喜欢的主题就好了。

下面记录一下我的主题和配置。

#### 主题（emodipt-extend-custom）

效果展示：

![image-20240719142058629](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F19%2F14-20-59-aeae42e1d0619b1f80525559de988c83-image-20240719142058629-3a5622.png)

```json
{
    "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
    "blocks": [
        {
            "alignment": "left",
            "newline": true,
            "segments": [
                {
                    "foreground": "#E5C07B",
                    "properties": {
                        "time_format": "15:04:05"
                    },
                    "style": "plain",
                    "template": "[{{ .CurrentDate | date .Format }}]",
                    "type": "time"
                },
                {
                    "type": "os",
                    "style": "plain",
                    "foreground": "#26C6DA",
                    "template": " {{ .Icon }} {{ .UserName }}",
                    "properties": {
                        "windows": "",
                        "display_distro_name": true
                    }
                },
                {
                    "type": "java",
                    "properties": {
                        "home_enabled": true,
                        "display_mode": "always"
                    },
                    "style": "plain",
                    "foreground": "#E06C75",
                    "template": "  {{ .Full }}"
                },
                {
                    "type": "python",
                    "properties": {
                        "home_enabled": true,
                        "display_mode": "always",
                        "display_default": true
                    },
                    "style": "plain",
                    "foreground": "#295980",
                    "template": "   {{ .Venv }} {{ .Full }} "
                },
                {
                    "type": "node",
                    "properties": {
                        "home_enabled": true,
                        "display_mode": "always"
                    },
                    "style": "plain",
                    "foreground": "#417e38",
                    "template": "  {{ .Full }} "
                },
                {
                    "type": "go",
                    "style": "plain",
                    "foreground": "#007d9c",
                    "template": " go {{ .Full }} ",
                    "properties": {
                        "home_enabled": true,
                        "display_mode": "always"
                    }
                },
                {
                    "foreground": "#F3C267",
                    "foreground_templates": [
                        "{{ if or (.Working.Changed) (.Staging.Changed) }}#FF9248{{ end }}",
                        "{{ if and (gt .Ahead 0) (gt .Behind 0) }}#ff4500{{ end }}",
                        "{{ if gt .Ahead 0 }}#B388FF{{ end }}",
                        "{{ if gt .Behind 0 }}#B388FF{{ end }}"
                    ],
                    "properties": {
                        "branch_max_length": 25,
                        "fetch_stash_count": true,
                        "fetch_status": true,
                        "fetch_upstream_icon": true
                    },
                    "style": "plain",
                    "template": " {{ .UpstreamIcon }}{{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }}  {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }}  {{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }}  {{ .StashCount }}{{ end }} ",
                    "type": "git"
                }
            ],
            "type": "prompt"
        },
        {
            "alignment": "right",
            "segments": [
                {
                    "type": "status",
                    "style": "plain",
                    "foreground": "#b8ff75",
                    "foreground_templates": [
                        "{{ if gt .Code 0 }}#E06C75{{ end }}"
                    ],
                    "template": " x{{ reason .Code }}"
                },
                {
                    "foreground": "#b8ff75",
                    "foreground_templates": [
                        "{{ if gt .Code 0 }}#E06C75{{ end }}"
                    ],
                    "properties": {
                        "style": "roundrock",
                        "always_enabled": true
                    },
                    "style": "diamond",
                    "template": " {{ .FormattedMs }} ",
                    "type": "executiontime"
                }
            ],
            "type": "prompt"
        },
        {
            "alignment": "left",
            "newline": true,
            "segments": [
                {
                    "foreground": "#61AFEF",
                    "properties": {
                        "style": "full"
                    },
                    "style": "plain",
                    "template": " {{ .Path }}",
                    "type": "path"
                }
            ],
            "type": "prompt"
        },
        {
            "alignment": "left",
            "newline": true,
            "segments": [
                {
                    "foreground": "#E06C75",
                    "style": "plain",
                    "template": "!",
                    "type": "root"
                },
                {
                    "foreground": "#E06C75",
                    "style": "plain",
                    "template": "❯",
                    "type": "text"
                }
            ],
            "type": "prompt"
        }
    ],
    "final_space": true,
    "version": 2
}
```

#### WindowsTerminal设置

```json
{
    "$help": "https://aka.ms/terminal-documentation",
    "$schema": "https://aka.ms/terminal-profiles-schema-preview",
    "actions": 
    [
        {
            "command": 
            {
                "action": "copy",
                "singleLine": false
            },
            "id": "User.copy.644BA8F2",
            "keys": "ctrl+c"
        },
        {
            "command": "unbound",
            "keys": "alt+down"
        },
        {
            "command": "unbound",
            "keys": "alt+up"
        },
        {
            "command": "unbound",
            "keys": "ctrl+alt+left"
        },
        {
            "command": "unbound",
            "keys": "ctrl+shift+tab"
        },
        {
            "command": "paste",
            "id": "User.paste",
            "keys": "ctrl+v"
        },
        {
            "command": "find",
            "id": "User.find",
            "keys": "ctrl+shift+f"
        },
        {
            "command": 
            {
                "action": "splitPane",
                "split": "auto",
                "splitMode": "duplicate"
            },
            "id": "User.splitPane.A6751878",
            "keys": "alt+shift+d"
        },
        {
            "command": 
            {
                "action": "closeTab"
            },
            "keys": "ctrl+w"
        },
        {
            "command": 
            {
                "action": "splitPane",
                "split": "right"
            },
            "id": "User.splitPane.864CD510",
            "keys": "ctrl+alt+r"
        },
        {
            "command": 
            {
                "action": "prevTab"
            },
            "id": "User.prevTab.0",
            "keys": "alt+left"
        },
        {
            "command": 
            {
                "action": "splitPane",
                "split": "down"
            },
            "id": "User.splitPane.D5151347",
            "keys": "ctrl+alt+d"
        },
        {
            "command": 
            {
                "action": "moveFocus",
                "direction": "previous"
            },
            "id": "User.moveFocus.75247157"
        },
        {
            "command": 
            {
                "action": "nextTab"
            },
            "id": "User.nextTab.0",
            "keys": "alt+right"
        },
        {
            "command": 
            {
                "action": "moveFocus",
                "direction": "nextInOrder"
            },
            "id": "User.moveFocus.D7681B66",
            "keys": "ctrl+tab"
        }
    ],
    "alwaysOnTop": true,
    "copyFormatting": "none",
    "copyOnSelect": false,
    "defaultProfile": "{c4e4600c-ad53-446a-83ba-da0e5ff6429c}",
    "focusFollowMouse": false,
    "newTabMenu": 
    [
        {
            "type": "remainingProfiles"
        }
    ],
    "profiles": 
    {
        "defaults": {},
        "list": 
        [
            {
                "commandline": "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
                "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
                "hidden": false,
                "name": "Windows PowerShell"
            },
            {
                "commandline": "%SystemRoot%\\System32\\cmd.exe",
                "guid": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}",
                "hidden": false,
                "name": "\u547d\u4ee4\u63d0\u793a\u7b26"
            },
            {
                "guid": "{b453ae62-4e3d-5e58-b989-0a998ec441b8}",
                "hidden": false,
                "name": "Azure Cloud Shell",
                "source": "Windows.Terminal.Azure"
            },
            {
                "altGrAliasing": true,
                "antialiasingMode": "grayscale",
                "bellStyle": "none",
                "closeOnExit": "automatic",
                "colorScheme": "DIY",
                "commandline": "D:\\envs\\powershell7\\7\\pwsh.exe -nologo",
                "cursorShape": "vintage",
                "font": 
                {
                    "face": "CaskaydiaMono Nerd Font",
                    "size": 12
                },
                "guid": "{c4e4600c-ad53-446a-83ba-da0e5ff6429c}",
                "hidden": false,
                "historySize": 9001,
                "icon": "D:\\envs\\powershell7\\7\\assets\\Powershell_black.ico",
                "name": "pwsh",
                "opacity": 70,
                "padding": "8, 8, 8, 8",
                "snapOnInput": true,
                "startingDirectory": "%USERPROFILE%",
                "useAcrylic": false
            },
            {
                "guid": "{2ece5bfe-50ed-5f3a-ab87-5cd4baafed2b}",
                "hidden": false,
                "name": "Git Bash",
                "source": "Git"
            }
        ]
    },
    "schemes": 
    [
        {
            "background": "#000000",
            "black": "#0C0C0C",
            "blue": "#0037DA",
            "brightBlack": "#FFFFFF",
            "brightBlue": "#3B78FF",
            "brightCyan": "#61D6D6",
            "brightGreen": "#16C60C",
            "brightPurple": "#B4009E",
            "brightRed": "#E74856",
            "brightWhite": "#F2F2F2",
            "brightYellow": "#F9F1A5",
            "cursorColor": "#FFFFFF",
            "cyan": "#3A96DD",
            "foreground": "#FFFFFF",
            "green": "#13A10E",
            "name": "DIY",
            "purple": "#881798",
            "red": "#C50F1F",
            "selectionBackground": "#FFFFFF",
            "white": "#CCCCCC",
            "yellow": "#C19C00"
        }
    ],
    "themes": []
}
```

