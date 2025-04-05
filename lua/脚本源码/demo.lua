-- �ű�����
print("�ű�����")

-- ʹ�� pcall ��ȫ���� WeaponLib ģ�� (ԭ ������)
local status, weaponLibModule = pcall(require, "WeaponLib")
local WeaponLib = nil -- ��ʼ��Ϊ nil

if status then
    WeaponLib = weaponLibModule -- ���سɹ�
    print("WeaponLib ģ����سɹ���")
else
    -- ����ʧ�ܣ���ӡ���󲢴����ձ��ֹ��������
    print("����: WeaponLib ģ�����ʧ��: " .. tostring(weaponLibModule))
    print("��ȷ��������Ϊ 'WeaponLib.lua' ���ļ�������·����ȷ��")
    WeaponLib = {
        ����Ʒ������ = {},
        ������ɫֵ = {}
    }
    print("��ʹ�ÿյ� WeaponLib ���ݡ�")
end

--[[
��ṹ˵��: (��)
...
--]]

-- ==== ģ�� ImGui ���� (����������ṩ) ====
local ImVec2 = function(x, y) return {x = x, y = y} end
local ImVec4 = function(r, g, b, a) return {r = r, g = g, b = b, a = a} end

-- ==== ���� ====
local ARMOR_INFO = { -- ������Ϣ
    [600] = { Desc = "�׼�", R = 1.0, G = 1.0, B = 1.0, A = 1.0 },
    [900] = { Desc = "����", R = 0.2, G = 0.6, B = 0.7, A = 1.0 },
    [1200] = { Desc = "�ϼ�", R = 0.5, G = 0.0, B = 0.5, A = 1.0 },
    [1500] = { Desc = "���", R = 1.0, G = 0.6, B = 0.0, A = 1.0 },
    [1800] = { Desc = "���", R = 0.8, G = 0.2, B = 0.2, A = 1.0 }
}
local DEFAULT_ARMOR = { Desc = "�޼�", R = 0.5, G = 0.5, B = 0.5, A = 0.7 } -- Ĭ�ϻ�����ɫ

-- ==== ȫ��״̬ �� ���� ====
local TabSettings = {
    -- ͸�ӷ�ҳ������
    ͸�� = {
        ����ȫ�� = true, ��ʾ��� = true, ��ʾ�˻� = true, ��ʾ���� = true,
        ��ʾ���� = true, ��ʾѪ�� = true, ��ʾ���� = true, ��ʾ���� = true,
        ��ʾ���� = true, ��ʾͷ�� = false, ��ʾͷ�� = true, ��ʾ��Ʒ = false,
        Σ����ʾ = true,
    },
    -- �񵶷�ҳ������
    �� = {
        �����Զ� = false, ������ = true, �񵶷�Χ = 5.0,
    },
    -- ���ܷ�ҳ������
    ���� = {
        �Զ���F = false, �Զ���V = false, ��ʾ����CD = true,
        F����Ŀ�� = "�������", V���� = "���˾ۼ�ʱ",
    },
    -- ��ܷ�ҳ������
    ��� = {
        �Զ������չ� = false, �Զ����������� = false, �Զ��¶� = false,
        ���ܾ��� = 1.0,
    },
    -- ���з�ҳ������
    ���� = {
        ���� = false, ��ǰ���� = "̫������", ������ʽ = "��ס���",
    },
    -- �����ҳ������
    ���� = {
        ���� = false, ��׼��λ = "ͷ��", ƽ���� = 15.0,
        ��׼��ΧFOV = 90.0, �������� = false, ��׼�� = "����Ҽ�",
    }
}

local G = { -- ȫ��״̬
    Matrix = {}, Players = {}, LocalPlayer = {}, Items = {},
    PlayerCount = 0, ImageResources = {}, IsReady = false,
    ScreenWidth = 0, ScreenHeight = 0, ScreenCenterX = 0, ScreenCenterY = 0,
}

-- ==== ���ߺ��� ====

-- ����3D����
local function getdis(localpos, pos)
    if not localpos or not pos or not localpos[1] or not pos[1] or not localpos[2] or not pos[2] or not localpos[3] or not pos[3] then
       return 0
    end
    local dx = localpos[1] - pos[1]
    local dy = localpos[2] - pos[2] -- ��Ӧ��Ϸ Z
    local dz = localpos[3] - pos[3] -- ��Ӧ��Ϸ Y (�߶�)
    local distSq = dx*dx + dy*dy + dz*dz
    if distSq < 0 then return 0 end
    return math.sqrt(distSq)
end

-- ��������ת��Ļ���� (���ط�����Ϣ)
local function w2s(px, py, Matrix, x, y, z)
    if not px or not py or not Matrix or #Matrix ~= 16 or not x or not y or not z then
        return nil
    end
    local ���� ={}
    local mat_y, mat_z = z, y -- ����ӳ��
    local wi = Matrix[4] * x + Matrix[8] * mat_z + Matrix[12] * mat_y + Matrix[16]
    if (wi < 0.01) then return nil end
    local w = 1 / wi
    local BoxX = px + (Matrix[1] * x + Matrix[5] * mat_z + Matrix[9] * mat_y + Matrix[13]) * w * px
    local headOffset = 1.8
    local BoxY = py - (Matrix[2] * x + Matrix[6] * (mat_z + headOffset) + Matrix[10] * mat_y + Matrix[14]) * w * py
    local �ŵװ� = py - (Matrix[2] * x + Matrix[6] * mat_z + Matrix[10] * mat_y + Matrix[14]) * w * py
	local H = �ŵװ� - BoxY
	if H < 1 then H = 1 end
	����["x"] = BoxX - H / 4; ����["y"] = BoxY
	����["w"] = H / 2;       ����["h"] = H
    return ����
end

-- ��ȡ������ɫ (ImVec4 ��ʽ)
local function getArmorInfo(maxArmor)
    local info = ARMOR_INFO[maxArmor]
    if info then return ImVec4(info.R, info.G, info.B, info.A) end
    return ImVec4(DEFAULT_ARMOR.R, DEFAULT_ARMOR.G, DEFAULT_ARMOR.B, DEFAULT_ARMOR.A)
end

-- ����ͼƬ��Դ������
local function loadImage(path)
    if not ui or not ui.LoadImages then return nil end
    if G.ImageResources[path] then
        if G.ImageResources[path] == -1 then return nil end
        return G.ImageResources[path]
    end
    -- print("���Լ���ͼƬ: " .. path) -- ȡ��ע���Ե���
    local status, textureId = pcall(ui.LoadImages, path)
    if status and textureId and textureId > 0 then
        -- print("���سɹ�, ID:", textureId)
        G.ImageResources[path] = textureId
        return textureId
    else
        -- print("����ͼƬʧ��: " .. path .. " ����: " .. tostring(textureId))
        G.ImageResources[path] = -1
        return nil
    end
end

-- ==== �����ƺ��� ====
function OnDraw()
    -- ��������Ƿ����
    if not G or not G.IsReady then return end

    -- ������Ļ�ߴ�;��� (��������)
    if ui and ui.getw and ui.geth then
        G.ScreenWidth = ui.getw(); G.ScreenHeight = ui.geth()
        G.ScreenCenterX = G.ScreenWidth / 2; G.ScreenCenterY = G.ScreenHeight / 2
    else G.ScreenWidth = 1920; G.ScreenHeight = 1080; G.ScreenCenterX = 960; G.ScreenCenterY = 540; end

    if not matrix or type(matrix) ~= "table" or #matrix < 16 then G.Matrix = {}
    else G.Matrix = matrix end

    -- ==== ���ܲ˵����� ====
    pcall(ui.SetNextWindowSize, 600, 450, 1) -- �������ó�ʼ��С

    local beginWinOK, beginWinErr = pcall(ui.Begin, "�๦�ܲ˵�")
    if not beginWinOK then return end -- ���ڿ�ʼʧ�����˳�

    -- ������ҳ��
    local beginTabBarOK, beginTabBarErr = pcall(ui.BeginTabBar, "MainFunctionTabs")
    if beginTabBarOK then
        -- [�˴�ʡ�����з�ҳ�� UI ���룬���ֲ���]
        -- == ��ҳ 1: ͸�� ==
        local isTab1Selected = false; local tab1OK, tab1Ret = pcall(function() return ui.BeginTabItem("͸��") end); if tab1OK then isTab1Selected = tab1Ret end
        if isTab1Selected then pcall(function() ui.Text("���͸��ѡ��:"); TabSettings.͸��.����ȫ�� = ui.Checkbox("����͸���ܿ���", TabSettings.͸��.����ȫ��); ui.Separator(); TabSettings.͸��.��ʾ��� = ui.Checkbox("��ʾ���", TabSettings.͸��.��ʾ���); ui.SameLine(); TabSettings.͸��.��ʾ�˻� = ui.Checkbox("��ʾ�˻�", TabSettings.͸��.��ʾ�˻�); TabSettings.͸��.��ʾ���� = ui.Checkbox("��ʾ����", TabSettings.͸��.��ʾ����); ui.SameLine(); TabSettings.͸��.��ʾ���� = ui.Checkbox("��ʾ����", TabSettings.͸��.��ʾ����); TabSettings.͸��.��ʾѪ�� = ui.Checkbox("��ʾѪ��", TabSettings.͸��.��ʾѪ��); ui.SameLine(); TabSettings.͸��.��ʾ���� = ui.Checkbox("��ʾ����", TabSettings.͸��.��ʾ����); TabSettings.͸��.��ʾ���� = ui.Checkbox("��ʾ����", TabSettings.͸��.��ʾ����); ui.SameLine(); TabSettings.͸��.��ʾ���� = ui.Checkbox("��ʾ����", TabSettings.͸��.��ʾ����); TabSettings.͸��.��ʾͷ�� = ui.Checkbox("��ʾͷ��", TabSettings.͸��.��ʾͷ��); ui.SameLine(); TabSettings.͸��.��ʾͷ�� = ui.Checkbox("��ʾͷ��", TabSettings.͸��.��ʾͷ��); ui.Separator(); ui.Text("����͸��ѡ��:"); TabSettings.͸��.��ʾ��Ʒ = ui.Checkbox("��ʾ��Ʒ", TabSettings.͸��.��ʾ��Ʒ); TabSettings.͸��.Σ����ʾ = ui.Checkbox("Σ����ʾ (��Ļ����)", TabSettings.͸��.Σ����ʾ) end); pcall(ui.EndTabItem) end
        -- == ��ҳ 2: �� ==
        local isTab2Selected = false; local tab2OK, tab2Ret = pcall(function() return ui.BeginTabItem("��") end); if tab2OK then isTab2Selected = tab2Ret end
        if isTab2Selected then pcall(function() TabSettings.��.�����Զ� = ui.Checkbox("�����Զ���", TabSettings.��.�����Զ�); if TabSettings.��.�����Զ� then TabSettings.��.������ = ui.Checkbox("�����⹥��", TabSettings.��.������); TabSettings.��.�񵶷�Χ = ui.SliderFloat("�񵶼�ⷶΧ (��)", TabSettings.��.�񵶷�Χ, 1.0, 15.0, "%.1f", 0); ui.Text("�񵶰�������: (��ʵ��)") end end); pcall(ui.EndTabItem) end
        -- == ��ҳ 3: ���� ==
        local isTab3Selected = false; local tab3OK, tab3Ret = pcall(function() return ui.BeginTabItem("����") end); if tab3OK then isTab3Selected = tab3Ret end
        if isTab3Selected then pcall(function() TabSettings.����.�Զ���F = ui.Checkbox("�Զ��ͷ� F ����", TabSettings.����.�Զ���F); if TabSettings.����.�Զ���F then ui.Text("   F�����ͷ�Ŀ��: " .. TabSettings.����.F����Ŀ��) end; TabSettings.����.�Զ���V = ui.Checkbox("�Զ��ͷ� V ����", TabSettings.����.�Զ���V); if TabSettings.����.�Զ���V then ui.Text("   V�����ͷ�����: " .. TabSettings.����.V����) end; ui.Separator(); TabSettings.����.��ʾ����CD = ui.Checkbox("��ʾ���˼�����ȴ", TabSettings.����.��ʾ����CD) end); pcall(ui.EndTabItem) end
        -- == ��ҳ 4: ��� ==
        local isTab4Selected = false; local tab4OK, tab4Ret = pcall(function() return ui.BeginTabItem("���") end); if tab4OK then isTab4Selected = tab4Ret end
        if isTab4Selected then pcall(function() TabSettings.���.�Զ������չ� = ui.Checkbox("�Զ�������ͨ����", TabSettings.���.�Զ������չ�); TabSettings.���.�Զ����������� = ui.Checkbox("�Զ����������幥��", TabSettings.���.�Զ�����������); TabSettings.���.�Զ��¶� = ui.Checkbox("�Զ��¶� (�ض����)", TabSettings.���.�Զ��¶�); if TabSettings.���.�Զ������չ� or TabSettings.���.�Զ����������� then TabSettings.���.���ܾ��� = ui.SliderFloat("���ܾ���ϵ��", TabSettings.���.���ܾ���, 0.5, 2.0, "%.1f", 0) end end); pcall(ui.EndTabItem) end
        -- == ��ҳ 5: ���� ==
        local isTab5Selected = false; local tab5OK, tab5Ret = pcall(function() return ui.BeginTabItem("����") end); if tab5OK then isTab5Selected = tab5Ret end
        if isTab5Selected then pcall(function() TabSettings.����.���� = ui.Checkbox("�����Զ�����", TabSettings.����.����); if TabSettings.����.���� then ui.Text("��ǰ������·: " .. TabSettings.����.��ǰ����); ui.Text("������ʽ: " .. TabSettings.����.������ʽ); ui.Separator(); ui.Text("�����������Ӿ������е�΢��ѡ�") end end); pcall(ui.EndTabItem) end
        -- == ��ҳ 6: ���� ==
        local isTab6Selected = false; local tab6OK, tab6Ret = pcall(function() return ui.BeginTabItem("����") end); if tab6OK then isTab6Selected = tab6Ret end
        if isTab6Selected then pcall(function() TabSettings.����.���� = ui.Checkbox("��������", TabSettings.����.����); if TabSettings.����.���� then ui.Text("��׼��λ: " .. TabSettings.����.��׼��λ); TabSettings.����.ƽ���� = ui.SliderFloat("��׼ƽ����", TabSettings.����.ƽ����, 0.0, 100.0, "%.1f", 0); TabSettings.����.��׼��ΧFOV = ui.SliderFloat("��׼��Χ (FOV)", TabSettings.����.��׼��ΧFOV, 1.0, 180.0, "%.0f", 0); ui.Separator(); TabSettings.����.�������� = ui.Checkbox("������������", TabSettings.����.��������); if TabSettings.����.�������� then ui.Text("��׼��: " .. TabSettings.����.��׼��) end end end); pcall(ui.EndTabItem) end

        pcall(ui.EndTabBar)
    elseif beginTabBarErr then print("ui.BeginTabBar ����: " .. tostring(beginTabBarErr)) end
    pcall(ui.End)

    -- ==== �����߼�ִ������ ====
    local shouldDrawESP = false
    if TabSettings and TabSettings.͸�� and TabSettings.͸��.����ȫ�� then shouldDrawESP = true end

    if shouldDrawESP then
        local playersOK = G.Players and type(G.Players) == "table"
        local matrixOK = G.Matrix and type(G.Matrix) == "table" and #G.Matrix == 16
        local localPlayerOK = G.LocalPlayer and G.LocalPlayer.x

        if playersOK and matrixOK then
            -- ����Σ����ʾ
            if TabSettings.͸��.Σ����ʾ and G.PlayerCount and G.PlayerCount > 0 then
                local warningText = string.format("ע�� ��Χ�� %d ������", G.PlayerCount)
                local textWidth = #warningText * 14
                local warnX = G.ScreenCenterX - textWidth / 2
                local warnY = 100
                -- !! �޸���: ���������֣���ɫ�� ImVec4 !!
                local warnColor = ImVec4(1, 0, 0, 1) -- ���� ImVec4 ��ȫ�ֹ��캯��
                local drawWarnOK, drawWarnErr = pcall(ui.DrawText, warningText, 29, warnX, warnY, warnColor) -- ��������˳��
                if not drawWarnOK then print("����Σ����ʾ����: "..tostring(drawWarnErr)) end
            end

            -- ������Ҳ�����
            for _, ���� in pairs(G.Players) do
                if (����.���˻� and not TabSettings.͸��.��ʾ�˻�) or (not ����.���˻� and not TabSettings.͸��.��ʾ���) then
                   -- ����
                else
                    local w2sOK, box = pcall(w2s, G.ScreenCenterX, G.ScreenCenterY, G.Matrix, ����.x, ����.y, ����.z)
                    if w2sOK and box then
                        local drawOK, drawErr = pcall(function()
                            local ��Ļ����X = box.x + box.w / 2; local ��Ļ����Y = box.y
                            local �ײ�����X = box.x + box.w / 2; local �ײ�����Y = box.y + box.h
                            local infoOffsetY = -5

                            -- ��������
                            if TabSettings.͸��.��ʾ���� then
                                -- !! �޸���: ���������֣���ɫ�� ImVec4 !!
                                local lineX1, lineY1 = G.ScreenCenterX, 0
                                local lineX2, lineY2 = �ײ�����X, �ײ�����Y
                                local lineColor = ImVec4(1.0, 0, 0, 0.6) -- ��͸����
                                local lineThickness = 1.5
                                ui.DrawLine(lineX1, lineY1, lineX2, lineY2, lineColor, lineThickness) -- ��������˳��
                            end
                            -- ��������
                            if TabSettings.͸��.��ʾ���� then
                                local ���� = ����.���˻� and "�˻�" or ����.���� or "δ֪"
                                local nameTextSize = 14
                                local textWidth = #���� * nameTextSize * 0.5
                                -- !! �޸���: ���������֣���ɫ�� ImVec4 !!
                                local nameX = ��Ļ����X - textWidth / 2
                                local nameY = box.y + infoOffsetY - nameTextSize
                                local nameColor = ImVec4(1, 1, 1, 1) -- ��ɫ
                                ui.DrawText(����, nameTextSize, nameX, nameY, nameColor)
                                infoOffsetY = infoOffsetY - nameTextSize - 2
                            end
                            -- ��������
                            if TabSettings.͸��.��ʾ���� and WeaponLib and WeaponLib.����Ʒ������ then
                                local �������� = WeaponLib.����Ʒ������[����.����]
                                if �������� then
                                    local ������ɫInfo = (WeaponLib.������ɫֵ and WeaponLib.������ɫֵ[string.sub(��������, 1, 6)]) or {r=1,g=1,b=1,a=1}
                                    local weaponTextSize = 13
                                    local textWidth = #�������� * weaponTextSize * 0.5
                                    -- !! �޸���: ���������֣���ɫ�� ImVec4 !!
                                    local weaponX = ��Ļ����X - textWidth / 2
                                    local weaponY = box.y + infoOffsetY - weaponTextSize
                                    local weaponColor = ImVec4(������ɫInfo.r, ������ɫInfo.g, ������ɫInfo.b, 1)
                                    ui.DrawText(��������, weaponTextSize, weaponX, weaponY, weaponColor)
                                     infoOffsetY = infoOffsetY - weaponTextSize - 2
                                end
                            end
                             -- ����Ѫ���ͼ���
                            local barWidth = 4; local barSpacing = 2; local barHeight = box.h
                            -- Ѫ��
                            if TabSettings.͸��.��ʾѪ�� and ����.��ǰѪ�� and ����.���Ѫ�� and ����.���Ѫ�� > 0 then
                                local healthRatio = math.max(0, math.min(1, ����.��ǰѪ�� / ����.���Ѫ��))
                                local currentBarHeight = barHeight * healthRatio
                                local barX = box.x - barWidth - barSpacing
                                local bgColor = ImVec4(0.1, 0.1, 0.1, 0.7) -- ����ɫ
                                local fgColor = ImVec4(0, 1, 0, 1)     -- ǰ��ɫ (��ɫ)
                                -- !! �޸���: ���������֣���ɫ�� ImVec4 !!
                                ui.DrawLine(barX, box.y + barHeight, barX, box.y, bgColor, barWidth) -- ����
                                if currentBarHeight > 0 then ui.DrawLine(barX, box.y + barHeight, barX, box.y + barHeight - currentBarHeight, fgColor, barWidth) end -- ǰ��
                            end
                            -- ����
                            if TabSettings.͸��.��ʾ���� and ����.��ǰ���� and ����.��󻤼� and ����.��󻤼� > 0 then
                                local armorRatio = math.max(0, math.min(1, ����.��ǰ���� / ����.��󻤼�))
                                local armorColor = getArmorInfo(����.��󻤼�) -- ���� ImVec4
                                local currentBarHeight = barHeight * armorRatio
                                local barX = box.x + box.w + barSpacing + barWidth/2
                                local bgColor = ImVec4(0.1, 0.1, 0.1, 0.7)
                                -- !! �޸���: ���������֣���ɫ�� ImVec4 !!
                                ui.DrawLine(barX, box.y + barHeight, barX, box.y, bgColor, barWidth) -- ����
                                if currentBarHeight > 0 then ui.DrawLine(barX, box.y + barHeight, barX, box.y + barHeight - currentBarHeight, armorColor, barWidth) end -- ǰ��
                            end
                            -- ���ƾ���
                            if TabSettings.͸��.��ʾ���� and localPlayerOK then
                                local ���� = getdis({G.LocalPlayer.x, G.LocalPlayer.z, G.LocalPlayer.y}, {����.x, ����.z, ����.y})
                                local distText = string.format("%.0fm", ����)
                                local distTextSize = 14
                                local textWidth = #distText * distTextSize * 0.6
                                -- !! �޸���: ���������֣���ɫ�� ImVec4 !!
                                local distX = �ײ�����X - textWidth / 2
                                local distY = �ײ�����Y + 5
                                local distColor = ImVec4(0, 1, 0, 1) -- ��ɫ
                                ui.DrawText(distText, distTextSize, distX, distY, distColor)
                            end
                        end)
                        if not drawOK then print("������Ҵ���: "..tostring(drawErr)) end
                    -- elseif not w2sOK then print("w2s ����ʧ��: "..tostring(box)) end
                    end
                end
            end
        end
    end

    -- ���������߼� (���� TabSettings ִ��)
    if TabSettings and TabSettings.�� and TabSettings.��.�����Զ� then end
    -- ... etc ...

end

-- ==== �޸� getArmorInfo ���� ====
-- ����ֱ�ӷ��ص��� ImVec4 �Ľ��
local function getArmorInfo(maxArmor)
    local info = ARMOR_INFO[maxArmor]
    if info then
        -- ���� ImVec4 ��ȫ�ֹ��캯��
        return ImVec4(info.R, info.G, info.B, info.A)
    end
    -- ����Ĭ����ɫ
    return ImVec4(DEFAULT_ARMOR.R, DEFAULT_ARMOR.G, DEFAULT_ARMOR.B, DEFAULT_ARMOR.A)
end

-- ==== �Ƴ�������Ҫ�ĸ������� ====
-- ImVec2 = nil -- ������Ҫ���Ƕ���� ImVec2
-- ImVec4 = nil -- ������Ҫ���Ƕ���� ImVec4

-- ==== ���ݸ��º��� ====
function OnTick()
    -- ����֮ǰ���߼��������ݴ���ȫ�� G ��
    local success, err = pcall(function()
        -- ������������ṩ��ȫ�ֱ����Ƿ����
        if �����Ϣ ~= nil and type(�����Ϣ) == "table" then G.Players = �����Ϣ else G.Players = {} end
        if ������Ϣ ~= nil and type(������Ϣ) == "table" then G.LocalPlayer = ������Ϣ else G.LocalPlayer = {} end
        if ��Ʒ��Ϣ ~= nil and type(��Ʒ��Ϣ) == "table" then G.Items = ��Ʒ��Ϣ else G.Items = {} end

        -- �����������
        G.PlayerCount = #G.Players

        -- ȷ���������������ڣ���ֹ����������� (��ʹ ������Ϣ Ϊ�ջ�ȱ������)
        if G.LocalPlayer then
             G.LocalPlayer.x = G.LocalPlayer.x or 0
             G.LocalPlayer.y = G.LocalPlayer.y or 0 -- ��Ϸ���� Y (�߶�)
             G.LocalPlayer.z = G.LocalPlayer.z or 0 -- ��Ϸ���� Z
        else -- ��� G.LocalPlayer ��Ȼ�� nil (�����ϲ�����Ϊ���洦����)������һ���ձ�
             G.LocalPlayer = { x=0, y=0, z=0 }
        end


        -- �״γɹ��������ݺ����� IsReady ��־
        if not G.IsReady then
            G.IsReady = true
            print("�����ѽ���, ESP ��ʼ����ɡ�")
        end
    end)

    -- ��� pcall ���񵽴���
    if not success then
        print("OnTick ��������ʱ����: " .. tostring(err))
        -- ��������ʱ�����Կ������� IsReady����ֹ OnDraw ʹ�ÿ��ܲ�һ�µ�����
        -- G.IsReady = false
    end
end

-- �ű���ʼ�������ʾ
print("�����ű��Ѽ��ز���ʼ����")