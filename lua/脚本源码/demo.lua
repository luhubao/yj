-- 脚本加载
print("脚本加载")

-- 使用 pcall 安全加载 WeaponLib 模块 (原 武器库)
local status, weaponLibModule = pcall(require, "WeaponLib")
local WeaponLib = nil -- 初始化为 nil

if status then
    WeaponLib = weaponLibModule -- 加载成功
    print("WeaponLib 模块加载成功。")
else
    -- 加载失败，打印错误并创建空表防止后续错误
    print("警告: WeaponLib 模块加载失败: " .. tostring(weaponLibModule))
    print("请确保存在名为 'WeaponLib.lua' 的文件，并且路径正确。")
    WeaponLib = {
        武器品质名字 = {},
        武器颜色值 = {}
    }
    print("将使用空的 WeaponLib 数据。")
end

--[[
表结构说明: (略)
...
--]]

-- ==== 模拟 ImGui 类型 (如果环境不提供) ====
local ImVec2 = function(x, y) return {x = x, y = y} end
local ImVec4 = function(r, g, b, a) return {r = r, g = g, b = b, a = a} end

-- ==== 常量 ====
local ARMOR_INFO = { -- 护甲信息
    [600] = { Desc = "白甲", R = 1.0, G = 1.0, B = 1.0, A = 1.0 },
    [900] = { Desc = "蓝甲", R = 0.2, G = 0.6, B = 0.7, A = 1.0 },
    [1200] = { Desc = "紫甲", R = 0.5, G = 0.0, B = 0.5, A = 1.0 },
    [1500] = { Desc = "金甲", R = 1.0, G = 0.6, B = 0.0, A = 1.0 },
    [1800] = { Desc = "红甲", R = 0.8, G = 0.2, B = 0.2, A = 1.0 }
}
local DEFAULT_ARMOR = { Desc = "无甲", R = 0.5, G = 0.5, B = 0.5, A = 0.7 } -- 默认护甲颜色

-- ==== 全局状态 和 配置 ====
local TabSettings = {
    -- 透视分页的设置
    透视 = {
        开启全局 = true, 显示玩家 = true, 显示人机 = true, 显示名字 = true,
        显示距离 = true, 显示血条 = true, 显示甲条 = true, 显示射线 = true,
        显示武器 = true, 显示头像 = false, 显示头标 = true, 显示物品 = false,
        危险提示 = true,
    },
    -- 振刀分页的设置
    振刀 = {
        启用自动 = false, 仅振红光 = true, 振刀范围 = 5.0,
    },
    -- 技能分页的设置
    技能 = {
        自动放F = false, 自动放V = false, 显示敌人CD = true,
        F优先目标 = "最近敌人", V条件 = "敌人聚集时",
    },
    -- 躲避分页的设置
    躲避 = {
        自动闪避普攻 = false, 自动闪避蓝霸体 = false, 自动下蹲 = false,
        闪避距离 = 1.0,
    },
    -- 连招分页的设置
    连招 = {
        启用 = false, 当前连招 = "太刀基础", 触发方式 = "按住左键",
    },
    -- 自瞄分页的设置
    自瞄 = {
        启用 = false, 瞄准部位 = "头部", 平滑度 = 15.0,
        瞄准范围FOV = 90.0, 按键触发 = false, 瞄准键 = "鼠标右键",
    }
}

local G = { -- 全局状态
    Matrix = {}, Players = {}, LocalPlayer = {}, Items = {},
    PlayerCount = 0, ImageResources = {}, IsReady = false,
    ScreenWidth = 0, ScreenHeight = 0, ScreenCenterX = 0, ScreenCenterY = 0,
}

-- ==== 工具函数 ====

-- 计算3D距离
local function getdis(localpos, pos)
    if not localpos or not pos or not localpos[1] or not pos[1] or not localpos[2] or not pos[2] or not localpos[3] or not pos[3] then
       return 0
    end
    local dx = localpos[1] - pos[1]
    local dy = localpos[2] - pos[2] -- 对应游戏 Z
    local dz = localpos[3] - pos[3] -- 对应游戏 Y (高度)
    local distSq = dx*dx + dy*dy + dz*dz
    if distSq < 0 then return 0 end
    return math.sqrt(distSq)
end

-- 世界坐标转屏幕坐标 (返回方框信息)
local function w2s(px, py, Matrix, x, y, z)
    if not px or not py or not Matrix or #Matrix ~= 16 or not x or not y or not z then
        return nil
    end
    local 方框 ={}
    local mat_y, mat_z = z, y -- 坐标映射
    local wi = Matrix[4] * x + Matrix[8] * mat_z + Matrix[12] * mat_y + Matrix[16]
    if (wi < 0.01) then return nil end
    local w = 1 / wi
    local BoxX = px + (Matrix[1] * x + Matrix[5] * mat_z + Matrix[9] * mat_y + Matrix[13]) * w * px
    local headOffset = 1.8
    local BoxY = py - (Matrix[2] * x + Matrix[6] * (mat_z + headOffset) + Matrix[10] * mat_y + Matrix[14]) * w * py
    local 脚底板 = py - (Matrix[2] * x + Matrix[6] * mat_z + Matrix[10] * mat_y + Matrix[14]) * w * py
	local H = 脚底板 - BoxY
	if H < 1 then H = 1 end
	方框["x"] = BoxX - H / 4; 方框["y"] = BoxY
	方框["w"] = H / 2;       方框["h"] = H
    return 方框
end

-- 获取护甲颜色 (ImVec4 格式)
local function getArmorInfo(maxArmor)
    local info = ARMOR_INFO[maxArmor]
    if info then return ImVec4(info.R, info.G, info.B, info.A) end
    return ImVec4(DEFAULT_ARMOR.R, DEFAULT_ARMOR.G, DEFAULT_ARMOR.B, DEFAULT_ARMOR.A)
end

-- 加载图片资源并缓存
local function loadImage(path)
    if not ui or not ui.LoadImages then return nil end
    if G.ImageResources[path] then
        if G.ImageResources[path] == -1 then return nil end
        return G.ImageResources[path]
    end
    -- print("尝试加载图片: " .. path) -- 取消注释以调试
    local status, textureId = pcall(ui.LoadImages, path)
    if status and textureId and textureId > 0 then
        -- print("加载成功, ID:", textureId)
        G.ImageResources[path] = textureId
        return textureId
    else
        -- print("加载图片失败: " .. path .. " 错误: " .. tostring(textureId))
        G.ImageResources[path] = -1
        return nil
    end
end

-- ==== 主绘制函数 ====
function OnDraw()
    -- 检查数据是否就绪
    if not G or not G.IsReady then return end

    -- 更新屏幕尺寸和矩阵 (带错误检查)
    if ui and ui.getw and ui.geth then
        G.ScreenWidth = ui.getw(); G.ScreenHeight = ui.geth()
        G.ScreenCenterX = G.ScreenWidth / 2; G.ScreenCenterY = G.ScreenHeight / 2
    else G.ScreenWidth = 1920; G.ScreenHeight = 1080; G.ScreenCenterX = 960; G.ScreenCenterY = 540; end

    if not matrix or type(matrix) ~= "table" or #matrix < 16 then G.Matrix = {}
    else G.Matrix = matrix end

    -- ==== 功能菜单窗口 ====
    pcall(ui.SetNextWindowSize, 600, 450, 1) -- 尝试设置初始大小

    local beginWinOK, beginWinErr = pcall(ui.Begin, "多功能菜单")
    if not beginWinOK then return end -- 窗口开始失败则退出

    -- 创建分页栏
    local beginTabBarOK, beginTabBarErr = pcall(ui.BeginTabBar, "MainFunctionTabs")
    if beginTabBarOK then
        -- [此处省略所有分页的 UI 代码，保持不变]
        -- == 分页 1: 透视 ==
        local isTab1Selected = false; local tab1OK, tab1Ret = pcall(function() return ui.BeginTabItem("透视") end); if tab1OK then isTab1Selected = tab1Ret end
        if isTab1Selected then pcall(function() ui.Text("玩家透视选项:"); TabSettings.透视.开启全局 = ui.Checkbox("开启透视总开关", TabSettings.透视.开启全局); ui.Separator(); TabSettings.透视.显示玩家 = ui.Checkbox("显示玩家", TabSettings.透视.显示玩家); ui.SameLine(); TabSettings.透视.显示人机 = ui.Checkbox("显示人机", TabSettings.透视.显示人机); TabSettings.透视.显示名字 = ui.Checkbox("显示名字", TabSettings.透视.显示名字); ui.SameLine(); TabSettings.透视.显示距离 = ui.Checkbox("显示距离", TabSettings.透视.显示距离); TabSettings.透视.显示血条 = ui.Checkbox("显示血条", TabSettings.透视.显示血条); ui.SameLine(); TabSettings.透视.显示甲条 = ui.Checkbox("显示甲条", TabSettings.透视.显示甲条); TabSettings.透视.显示射线 = ui.Checkbox("显示射线", TabSettings.透视.显示射线); ui.SameLine(); TabSettings.透视.显示武器 = ui.Checkbox("显示武器", TabSettings.透视.显示武器); TabSettings.透视.显示头像 = ui.Checkbox("显示头像", TabSettings.透视.显示头像); ui.SameLine(); TabSettings.透视.显示头标 = ui.Checkbox("显示头标", TabSettings.透视.显示头标); ui.Separator(); ui.Text("其他透视选项:"); TabSettings.透视.显示物品 = ui.Checkbox("显示物品", TabSettings.透视.显示物品); TabSettings.透视.危险提示 = ui.Checkbox("危险提示 (屏幕中央)", TabSettings.透视.危险提示) end); pcall(ui.EndTabItem) end
        -- == 分页 2: 振刀 ==
        local isTab2Selected = false; local tab2OK, tab2Ret = pcall(function() return ui.BeginTabItem("振刀") end); if tab2OK then isTab2Selected = tab2Ret end
        if isTab2Selected then pcall(function() TabSettings.振刀.启用自动 = ui.Checkbox("启用自动振刀", TabSettings.振刀.启用自动); if TabSettings.振刀.启用自动 then TabSettings.振刀.仅振红光 = ui.Checkbox("仅振红光攻击", TabSettings.振刀.仅振红光); TabSettings.振刀.振刀范围 = ui.SliderFloat("振刀检测范围 (米)", TabSettings.振刀.振刀范围, 1.0, 15.0, "%.1f", 0); ui.Text("振刀按键设置: (待实现)") end end); pcall(ui.EndTabItem) end
        -- == 分页 3: 技能 ==
        local isTab3Selected = false; local tab3OK, tab3Ret = pcall(function() return ui.BeginTabItem("技能") end); if tab3OK then isTab3Selected = tab3Ret end
        if isTab3Selected then pcall(function() TabSettings.技能.自动放F = ui.Checkbox("自动释放 F 技能", TabSettings.技能.自动放F); if TabSettings.技能.自动放F then ui.Text("   F技能释放目标: " .. TabSettings.技能.F优先目标) end; TabSettings.技能.自动放V = ui.Checkbox("自动释放 V 大招", TabSettings.技能.自动放V); if TabSettings.技能.自动放V then ui.Text("   V技能释放条件: " .. TabSettings.技能.V条件) end; ui.Separator(); TabSettings.技能.显示敌人CD = ui.Checkbox("显示敌人技能冷却", TabSettings.技能.显示敌人CD) end); pcall(ui.EndTabItem) end
        -- == 分页 4: 躲避 ==
        local isTab4Selected = false; local tab4OK, tab4Ret = pcall(function() return ui.BeginTabItem("躲避") end); if tab4OK then isTab4Selected = tab4Ret end
        if isTab4Selected then pcall(function() TabSettings.躲避.自动闪避普攻 = ui.Checkbox("自动闪避普通攻击", TabSettings.躲避.自动闪避普攻); TabSettings.躲避.自动闪避蓝霸体 = ui.Checkbox("自动闪避蓝霸体攻击", TabSettings.躲避.自动闪避蓝霸体); TabSettings.躲避.自动下蹲 = ui.Checkbox("自动下蹲 (特定情况)", TabSettings.躲避.自动下蹲); if TabSettings.躲避.自动闪避普攻 or TabSettings.躲避.自动闪避蓝霸体 then TabSettings.躲避.闪避距离 = ui.SliderFloat("闪避距离系数", TabSettings.躲避.闪避距离, 0.5, 2.0, "%.1f", 0) end end); pcall(ui.EndTabItem) end
        -- == 分页 5: 连招 ==
        local isTab5Selected = false; local tab5OK, tab5Ret = pcall(function() return ui.BeginTabItem("连招") end); if tab5OK then isTab5Selected = tab5Ret end
        if isTab5Selected then pcall(function() TabSettings.连招.启用 = ui.Checkbox("启用自动连招", TabSettings.连招.启用); if TabSettings.连招.启用 then ui.Text("当前连招套路: " .. TabSettings.连招.当前连招); ui.Text("触发方式: " .. TabSettings.连招.触发方式); ui.Separator(); ui.Text("在这里可以添加具体连招的微调选项。") end end); pcall(ui.EndTabItem) end
        -- == 分页 6: 自瞄 ==
        local isTab6Selected = false; local tab6OK, tab6Ret = pcall(function() return ui.BeginTabItem("自瞄") end); if tab6OK then isTab6Selected = tab6Ret end
        if isTab6Selected then pcall(function() TabSettings.自瞄.启用 = ui.Checkbox("启用自瞄", TabSettings.自瞄.启用); if TabSettings.自瞄.启用 then ui.Text("瞄准部位: " .. TabSettings.自瞄.瞄准部位); TabSettings.自瞄.平滑度 = ui.SliderFloat("瞄准平滑度", TabSettings.自瞄.平滑度, 0.0, 100.0, "%.1f", 0); TabSettings.自瞄.瞄准范围FOV = ui.SliderFloat("瞄准范围 (FOV)", TabSettings.自瞄.瞄准范围FOV, 1.0, 180.0, "%.0f", 0); ui.Separator(); TabSettings.自瞄.按键触发 = ui.Checkbox("按键触发自瞄", TabSettings.自瞄.按键触发); if TabSettings.自瞄.按键触发 then ui.Text("瞄准键: " .. TabSettings.自瞄.瞄准键) end end end); pcall(ui.EndTabItem) end

        pcall(ui.EndTabBar)
    elseif beginTabBarErr then print("ui.BeginTabBar 错误: " .. tostring(beginTabBarErr)) end
    pcall(ui.End)

    -- ==== 功能逻辑执行区域 ====
    local shouldDrawESP = false
    if TabSettings and TabSettings.透视 and TabSettings.透视.开启全局 then shouldDrawESP = true end

    if shouldDrawESP then
        local playersOK = G.Players and type(G.Players) == "table"
        local matrixOK = G.Matrix and type(G.Matrix) == "table" and #G.Matrix == 16
        local localPlayerOK = G.LocalPlayer and G.LocalPlayer.x

        if playersOK and matrixOK then
            -- 绘制危险提示
            if TabSettings.透视.危险提示 and G.PlayerCount and G.PlayerCount > 0 then
                local warningText = string.format("注意 周围有 %d 个敌人", G.PlayerCount)
                local textWidth = #warningText * 14
                local warnX = G.ScreenCenterX - textWidth / 2
                local warnY = 100
                -- !! 修复点: 坐标用数字，颜色用 ImVec4 !!
                local warnColor = ImVec4(1, 0, 0, 1) -- 假设 ImVec4 是全局构造函数
                local drawWarnOK, drawWarnErr = pcall(ui.DrawText, warningText, 29, warnX, warnY, warnColor) -- 调整参数顺序
                if not drawWarnOK then print("绘制危险提示错误: "..tostring(drawWarnErr)) end
            end

            -- 遍历玩家并绘制
            for _, 对象 in pairs(G.Players) do
                if (对象.是人机 and not TabSettings.透视.显示人机) or (not 对象.是人机 and not TabSettings.透视.显示玩家) then
                   -- 跳过
                else
                    local w2sOK, box = pcall(w2s, G.ScreenCenterX, G.ScreenCenterY, G.Matrix, 对象.x, 对象.y, 对象.z)
                    if w2sOK and box then
                        local drawOK, drawErr = pcall(function()
                            local 屏幕坐标X = box.x + box.w / 2; local 屏幕坐标Y = box.y
                            local 底部坐标X = box.x + box.w / 2; local 底部坐标Y = box.y + box.h
                            local infoOffsetY = -5

                            -- 绘制射线
                            if TabSettings.透视.显示射线 then
                                -- !! 修复点: 坐标用数字，颜色用 ImVec4 !!
                                local lineX1, lineY1 = G.ScreenCenterX, 0
                                local lineX2, lineY2 = 底部坐标X, 底部坐标Y
                                local lineColor = ImVec4(1.0, 0, 0, 0.6) -- 半透明红
                                local lineThickness = 1.5
                                ui.DrawLine(lineX1, lineY1, lineX2, lineY2, lineColor, lineThickness) -- 调整参数顺序
                            end
                            -- 绘制名字
                            if TabSettings.透视.显示名字 then
                                local 名字 = 对象.是人机 and "人机" or 对象.姓名 or "未知"
                                local nameTextSize = 14
                                local textWidth = #名字 * nameTextSize * 0.5
                                -- !! 修复点: 坐标用数字，颜色用 ImVec4 !!
                                local nameX = 屏幕坐标X - textWidth / 2
                                local nameY = box.y + infoOffsetY - nameTextSize
                                local nameColor = ImVec4(1, 1, 1, 1) -- 白色
                                ui.DrawText(名字, nameTextSize, nameX, nameY, nameColor)
                                infoOffsetY = infoOffsetY - nameTextSize - 2
                            end
                            -- 绘制武器
                            if TabSettings.透视.显示武器 and WeaponLib and WeaponLib.武器品质名字 then
                                local 武器名字 = WeaponLib.武器品质名字[对象.武器]
                                if 武器名字 then
                                    local 武器颜色Info = (WeaponLib.武器颜色值 and WeaponLib.武器颜色值[string.sub(武器名字, 1, 6)]) or {r=1,g=1,b=1,a=1}
                                    local weaponTextSize = 13
                                    local textWidth = #武器名字 * weaponTextSize * 0.5
                                    -- !! 修复点: 坐标用数字，颜色用 ImVec4 !!
                                    local weaponX = 屏幕坐标X - textWidth / 2
                                    local weaponY = box.y + infoOffsetY - weaponTextSize
                                    local weaponColor = ImVec4(武器颜色Info.r, 武器颜色Info.g, 武器颜色Info.b, 1)
                                    ui.DrawText(武器名字, weaponTextSize, weaponX, weaponY, weaponColor)
                                     infoOffsetY = infoOffsetY - weaponTextSize - 2
                                end
                            end
                             -- 绘制血条和甲条
                            local barWidth = 4; local barSpacing = 2; local barHeight = box.h
                            -- 血条
                            if TabSettings.透视.显示血条 and 对象.当前血量 and 对象.最大血量 and 对象.最大血量 > 0 then
                                local healthRatio = math.max(0, math.min(1, 对象.当前血量 / 对象.最大血量))
                                local currentBarHeight = barHeight * healthRatio
                                local barX = box.x - barWidth - barSpacing
                                local bgColor = ImVec4(0.1, 0.1, 0.1, 0.7) -- 背景色
                                local fgColor = ImVec4(0, 1, 0, 1)     -- 前景色 (绿色)
                                -- !! 修复点: 坐标用数字，颜色用 ImVec4 !!
                                ui.DrawLine(barX, box.y + barHeight, barX, box.y, bgColor, barWidth) -- 背景
                                if currentBarHeight > 0 then ui.DrawLine(barX, box.y + barHeight, barX, box.y + barHeight - currentBarHeight, fgColor, barWidth) end -- 前景
                            end
                            -- 甲条
                            if TabSettings.透视.显示甲条 and 对象.当前护甲 and 对象.最大护甲 and 对象.最大护甲 > 0 then
                                local armorRatio = math.max(0, math.min(1, 对象.当前护甲 / 对象.最大护甲))
                                local armorColor = getArmorInfo(对象.最大护甲) -- 返回 ImVec4
                                local currentBarHeight = barHeight * armorRatio
                                local barX = box.x + box.w + barSpacing + barWidth/2
                                local bgColor = ImVec4(0.1, 0.1, 0.1, 0.7)
                                -- !! 修复点: 坐标用数字，颜色用 ImVec4 !!
                                ui.DrawLine(barX, box.y + barHeight, barX, box.y, bgColor, barWidth) -- 背景
                                if currentBarHeight > 0 then ui.DrawLine(barX, box.y + barHeight, barX, box.y + barHeight - currentBarHeight, armorColor, barWidth) end -- 前景
                            end
                            -- 绘制距离
                            if TabSettings.透视.显示距离 and localPlayerOK then
                                local 距离 = getdis({G.LocalPlayer.x, G.LocalPlayer.z, G.LocalPlayer.y}, {对象.x, 对象.z, 对象.y})
                                local distText = string.format("%.0fm", 距离)
                                local distTextSize = 14
                                local textWidth = #distText * distTextSize * 0.6
                                -- !! 修复点: 坐标用数字，颜色用 ImVec4 !!
                                local distX = 底部坐标X - textWidth / 2
                                local distY = 底部坐标Y + 5
                                local distColor = ImVec4(0, 1, 0, 1) -- 绿色
                                ui.DrawText(distText, distTextSize, distX, distY, distColor)
                            end
                        end)
                        if not drawOK then print("绘制玩家错误: "..tostring(drawErr)) end
                    -- elseif not w2sOK then print("w2s 调用失败: "..tostring(box)) end
                    end
                end
            end
        end
    end

    -- 其他功能逻辑 (根据 TabSettings 执行)
    if TabSettings and TabSettings.振刀 and TabSettings.振刀.启用自动 then end
    -- ... etc ...

end

-- ==== 修改 getArmorInfo 函数 ====
-- 让它直接返回调用 ImVec4 的结果
local function getArmorInfo(maxArmor)
    local info = ARMOR_INFO[maxArmor]
    if info then
        -- 假设 ImVec4 是全局构造函数
        return ImVec4(info.R, info.G, info.B, info.A)
    end
    -- 返回默认颜色
    return ImVec4(DEFAULT_ARMOR.R, DEFAULT_ARMOR.G, DEFAULT_ARMOR.B, DEFAULT_ARMOR.A)
end

-- ==== 移除不再需要的辅助函数 ====
-- ImVec2 = nil -- 不再需要我们定义的 ImVec2
-- ImVec4 = nil -- 不再需要我们定义的 ImVec4

-- ==== 数据更新函数 ====
function OnTick()
    -- 复用之前的逻辑，将数据存入全局 G 表
    local success, err = pcall(function()
        -- 检查宿主环境提供的全局变量是否存在
        if 玩家信息 ~= nil and type(玩家信息) == "table" then G.Players = 玩家信息 else G.Players = {} end
        if 本人信息 ~= nil and type(本人信息) == "table" then G.LocalPlayer = 本人信息 else G.LocalPlayer = {} end
        if 物品信息 ~= nil and type(物品信息) == "table" then G.Items = 物品信息 else G.Items = {} end

        -- 计算玩家数量
        G.PlayerCount = #G.Players

        -- 确保本地玩家坐标存在，防止后续计算出错 (即使 本人信息 为空或缺少坐标)
        if G.LocalPlayer then
             G.LocalPlayer.x = G.LocalPlayer.x or 0
             G.LocalPlayer.y = G.LocalPlayer.y or 0 -- 游戏世界 Y (高度)
             G.LocalPlayer.z = G.LocalPlayer.z or 0 -- 游戏世界 Z
        else -- 如果 G.LocalPlayer 仍然是 nil (理论上不会因为上面处理了)，创建一个空表
             G.LocalPlayer = { x=0, y=0, z=0 }
        end


        -- 首次成功接收数据后，设置 IsReady 标志
        if not G.IsReady then
            G.IsReady = true
            print("数据已接收, ESP 初始化完成。")
        end
    end)

    -- 如果 pcall 捕获到错误
    if not success then
        print("OnTick 更新数据时出错: " .. tostring(err))
        -- 发生错误时，可以考虑重置 IsReady，防止 OnDraw 使用可能不一致的数据
        -- G.IsReady = false
    end
end

-- 脚本初始化完成提示
print("完整脚本已加载并初始化。")