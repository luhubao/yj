print("�ű�����")
local ������ = require("������")

--[[
��ṹ:
�����Ϣ
��ַ,����,��ʽ,����,��ϣ,��,���˻�,����,״̬,��ɫ,����,����,x,y,z,pitch,yaw,roll,
��ǰѪ��/����/ŭ��/����
���Ѫ��/����/ŭ��/����
������Ϣ
��ʽ,����,��ϣ,��,����,״̬,��ɫ,����,x,y,z,pitch,yaw,roll
��ǰѪ��/����/ŭ��/����
���Ѫ��/����/ŭ��/����

matrix

ui
--print(ui.getw(),ui.geth())--���
--���㻬��=ui.SliderFloat("test",���㻬��,1.0,100.0,"%f",0);
--ui.Spacing()
--��������=ui.SliderInt("���Ի���int",��������,1,100,"%d",0);

Begin("hello")
End()
SetWindowPos(x,y,0)
BeginTabBar("123")
EndTabBar()
BeginTabItem(123)
EndTabItem()
Spacing()
Button()
Checkbox()
����=ui.Checkbox("����",����)
SameLine()
Separator()
Text("hello")
SliderFloat()
���㻬��=ui.SliderFloat("test",���㻬��,1.0,100.0,"%f",0);
SliderInt()
��������=ui.SliderInt("���Ի���int",��������,1,100,"%d",0)
DrawLine()
DrawText()
ui.DrawLine(200,300,300,400,1.0,0,0,1,30)
ui.DrawText("�����ı�",29,500,600,1,0,0,1)





km
�ӳ�(12)
����ƶ�(100,20,30)--xy���ʱ��
���(1)--1�ǰ��£�0���ɿ�
�м�(1)
�Ҽ�(1)
����(1)--���¼��̼�
����(1)
����(1)--1����ǰ1��-1������1��
�������(1)--1���Σ�0��� ʹ������ɿ�����ʱ�����������Σ������ɿ�����ɺ����������������޷�ʹ��
�����Ҽ�(1)
����X(1)--1���Σ�0���
����Y(1)
���ι���(1)
���μ�(65)--���μ��̼���������̲�����ϲ���ʹ�ã�������Ч
�����(65)
�����������()
�Ƿ���(1)--���1
--]]

local ��������=0;
local ��ʾ��Ϣ="������";
local ��ʾ��Ϣ2="������";
local Σ����ʾ=true;
local ��ʾ����=true;
local ����͸��=true;
local ��ʾ����=true
local ����={}
local ���={}
local ����={}
local ��Ʒ={}
local ����={
			[600]={����="�׼�",r=1.0,g=1.0,b=1.0,a=1.0},
			[900]={����="����",r=0.2,g=0.6,b=0.7,a=1.0},
			[1200]={����="�ϼ�",r=0.5,g=0.0,b=0.5,a=1.0},
			[1500]={����="���",r=1.0,g=0.6,b=0.0,a=1.0},
			[1800]={����="���",r=0.8,g=0.2,b=0.2,a=1.0}
}
local ͼƬ��Դ={}
local function getdis(localpos, pos)
    -- ��������Ƿ���Ч
    if not localpos or not pos then
        print("Error: Invalid input positions.")
        return 0
    end

    local temp = {localpos[1] - pos[1], localpos[2] - pos[2], localpos[3] - pos[3]}
    -- ��ӡ������Ϣ
    --print(temp[1], temp[2], temp[3])

    -- ����������ŷ����þ���
    return math.sqrt(temp[1]*temp[1] + temp[2]*temp[2] + temp[3]*temp[3])
end
local function w2s(px, py, Matrix, x, y, z)
    local ���� ={}
    local wi = Matrix[4] * x + Matrix[8] * z + Matrix[12] * y + Matrix[16]
    if (wi < 0.01) then return nil end
    local w = 1 / wi
    local BoxX = px + (Matrix[1] * x + Matrix[5] * z + Matrix[9] * y + Matrix[13]) * w * px -- X
    local BoxY = py - (Matrix[2] * x + Matrix[6] * (z+1.9) + Matrix[10] * y + Matrix[14]) * w * py -- Y
    local �ŵװ� = py - (Matrix[2] * x + Matrix[6] * z + Matrix[10] * y + Matrix[14]) * w * py
	local H =�ŵװ�-BoxY
	����["x"]=BoxX-H/4
	����["y"]=BoxY
	����["w"]=H/2.5
	����["h"]=H
    return ����
end
local function ����ת��Ļ(px, py, Matrix, x, y, z)
    local ���� ={}
    local wi = Matrix[4] * x + Matrix[8] * z + Matrix[12] * y + Matrix[16]
    if (wi < 0.01) then return nil end
    local w = 1 / wi
    local BoxX = px + (Matrix[1] * x + Matrix[5] * z + Matrix[9] * y + Matrix[13]) * w * px -- X
    local BoxY = py - (Matrix[2] * x + Matrix[6] * (z+1.9) + Matrix[10] * y + Matrix[14]) * w * py -- Y
    local �ŵװ� = py - (Matrix[2] * x + Matrix[6] * z + Matrix[10] * y + Matrix[14]) * w * py
	����["x"]=BoxX
	����["y"]=BoxY
    return ����
end
local function ����ת��Ļ2(px, py, Matrix, x, y, z)
    local ���� ={}
    local wi = Matrix[4] * x + Matrix[8] * z + Matrix[12] * y + Matrix[16]
    if (wi < 0.01) then return nil end
    local w = 1 / wi
    local BoxX = px + (Matrix[1] * x + Matrix[5] * z + Matrix[9] * y + Matrix[13]) * w * px -- X
    local BoxY = py - (Matrix[2] * x + Matrix[6] * z + Matrix[10] * y + Matrix[14]) * w * py -- Y
    local �ŵװ� = py - (Matrix[2] * x + Matrix[6] * z + Matrix[10] * y + Matrix[14]) * w * py
	����["x"]=BoxX
	����["y"]=BoxY
    return ����
end
--   center    : ImVec2 ���ͣ��������������꣨��ѡ��
--   color     : ImVec4 ���ͣ�������ɫ��Ĭ�ϰ�ɫ��
--   long_width: �м䳤�ߵ�ˮƽ��ȣ�Ĭ�� 80��
--   short_width: ����̱�ˮƽ��ȣ�Ĭ�� 40��
--   height    : ��ֱ�߶ȣ�Ĭ�� 60��
--   thickness : ������ϸ��Ĭ�� 4.0��
function DrawHexagon(Text,center, color, long_width, short_width, height, thickness)
    -- ����Ĭ�ϲ���
    color = color or ImVec4(1.0, 1.0, 1.0, 1.0)  -- Ĭ�ϰ�ɫ
    long_width = long_width or 80
    short_width = short_width or 70
    height = height or 15
    thickness = thickness or 0.1

    -- ���������������꣨������ĵ��ƫ�ƣ�
    local points = {
        ImVec2( long_width,  0),        -- ����
        ImVec2( short_width, -height),  -- ����
        ImVec2(-short_width, -height),  -- ����
        ImVec2(-long_width,   0),       -- ����
        ImVec2(-short_width,  height),  -- ����
        ImVec2( short_width,  height)   -- ����
    }

    -- ת��Ϊ�������겢���Ӷ���
    for i = 1, #points do
        -- ���������ת��Ϊ��������
        local start = ImVec2(
            center.x + points[i].x,
            center.y + points[i].y
        )
        
        -- ������һ���㣨ѭ�����ӣ�
        local next_index = (i % #points) + 1
        local end_p = ImVec2(
            center.x + points[next_index].x,
            center.y + points[next_index].y
        )

        -- ��������
        ui.DrawLine(start, end_p, color, thickness)
    end

    local text_size = ImVec2(#Text,13)
    local text_pos = ImVec2(center.x - text_size.x*text_size.y / 4, center.y - text_size.y / 2)
    ui.DrawText(Text, text_size.y, text_pos, ImVec4(1.0, 1.0, 1.0, 1.0))
end

local function rotateyaw(Direction)
    local Yaw = math.atan2(math.abs(Direction.x), math.abs(Direction.y)) * 360 / math.pi
	--print("Yaw",Yaw)
    if ((Direction.x > 0 and Direction.y > 0) or (Direction.x < 0 and Direction.y < 0))==false then
        Yaw = 360 - Yaw
    end
    Yaw = Yaw + 180
    if Yaw > 360 then
        Yaw = Yaw - 360
    end
    return Yaw
end
local function CalcYaw(A,B)
    local yaw = math.atan2(A.x - B.x, A.y - B.y) * 180 / math.pi
    if yaw <= 0 then
        yaw = yaw + 360
    end
    return yaw
end

local function �жϽǶ�(�Ƕ�,��һ�˳�����,Ŀ������)
    local yaw=rotateyaw(�Ƕ�)
	--print(yaw,�Ƕ�.x,�Ƕ�.y)
	local war=CalcYaw(��һ�˳�����,Ŀ������)
    local phi = math.abs(war - yaw) % 360
    if phi > 180 then 
        return 360 - phi
    end
    return phi
end

local function ��ȡ������ɫ(��󻤼�)
	--print(��󻤼�)
	
	--print(#����)
	local ��������=����[��󻤼�]
	--print(��������.����)
	if �������� then
		return ��������
	end
	return {����="�޼�",r=0.0,g=0.0,b=0.0,a=0.0}
end
local ��ʼ=false
function OnDraw()
	if not ��ʼ then
		return
	end
	--����Կ�����update��ÿһ֡����һ��
	--print("����")
	����=matrix--ֻ����������ʹ��matrix
	
	ui.Begin("͸��UI")
	ui.Text("��ӭʹ��~")
	ui.Text(tostring(����.��ɫ).."������"..tostring(#����.����).."������")
	for index, ���� in pairs(����.����) do
		if(����.״̬~=4) then--4��������������
			ui.Text("��"..index.."��������Ϣ")
			ui.Text("����ID:"..����.ID)
			ui.Text("����״̬:"..����.״̬)
			ui.Text("����CD:"..����.CD)
		end
	end
	ui.Text("��ʽ:"..����.��ʽ)
	ui.Text("��ɫ:"..tostring(����.��ɫ))
	ui.Text("״̬:"..tostring(����.״̬))
	ui.Text("����:"..tostring(����.����))
	ui.Text("����:"..tostring(����.����))
	ui.Text("��ϣ:"..tostring(����.��ϣ))
	ui.Text("��:"..tostring(����.��))
	ui.Text("��ֱ:"..tostring(����.��ֱʱ��))
	ui.Text("ŭ��:"..tostring(����.��ǰŭ��))
	ui.Text("����:"..tostring(����.��ǰ����))
	ui.Text("����:"..tostring(����.��ǰ����))
	ui.Text("�����:"..tostring(����.�����))
	ui.Text("��������:"..tostring(����.��������))
	ui.Text("��ǰ������λ:"..tostring(����.������))
	ui.Text("��ǰ��������:"..tostring(����.��������))
	ui.Text("������A ID:"..tostring(����.������AID))
	ui.Text("������A �;�:"..tostring(����.������A��ǰ�;�))
	ui.Text("������A ����;�:"..tostring(����.������A����;�))
	ui.Text("������B ID:"..tostring(����.������BID))
	ui.Text("������B �;�:"..tostring(����.������B��ǰ�;�))
	ui.Text("������B ����;�:"..tostring(����.������B����;�))
	ui.Spacing()
	����͸��=ui.Checkbox("����͸��",����͸��)
	Σ����ʾ=ui.Checkbox("Σ����ʾ",Σ����ʾ)
	��ʾ����=ui.Checkbox("��ʾ����",��ʾ����)
	��ʾ����=ui.Checkbox("��ʾ����",��ʾ����)
	ui.Spacing()
	ui.End()
	
	
	if	��Ʒ~=nil then
	ui.Begin("��Ʒ�б�")
		for index, ���� in pairs(��Ʒ) do
			if ui.TreeNode(tostring(����.ID)) then
				ui.Text("\nx:"..tostring(math.floor(����.x)).."\ny:"..tostring(math.floor(����.y)).."\nz:"..tostring(math.floor(����.z)))
				ui.TreePop()
			end
		end
	ui.End()
	end
	if(Σ����ʾ and ��������>0) then 
		ui.DrawText("ע�� ��Χ��"..tostring(��������).."������",29,ImVec2(ui.getw()/2-200,100),ImVec4(1,0,0,1))
	end
	--print(����.pitch,����.yaw,����.roll)
	if(����͸��) then 
		for index, ���� in pairs(���) do
			local �Ƕ�=�жϽǶ�({x=����.pitch,y=����.roll,z=����.yaw},{x=����.x,y=����.z,z=����.y},{x=����.x,y=����.z,z=����.y})
			--print(�Ƕ�)
			local ����=w2s(ui.getw()/2,ui.geth()/2,����,����.x,����.z,����.y)
			local ��Ļ����=����ת��Ļ(ui.getw()/2,ui.geth()/2,����,����.x,����.z,����.y)
			--print(ͷ.x,ͷ.y,ͷ.z)
			local ����=����ת��Ļ2(ui.getw()/2,ui.geth()/2,����,����.ͷ��.x,����.ͷ��.z,����.ͷ��.y)
			if(����~=nil) then 
				--print(����.x,����.y)
				if(��ʾ����) then
					ui.DrawLine(ImVec2(����.x+����.w/2,����.y-16),ImVec2(ui.getw()/2,0),ImVec4(1.0,0,0,1),4)
					
				end
				if ����~=nil then
					ui.DrawText("ͷ",13,ImVec2(����.x ,����.y),ImVec4(1,1,1,1))
				end
				if(��ʾ����) then
					--ui.DrawText(����.����,18,����.x+����.w/2,����.y-16,1,0,0,1)
					
					--ui.DrawText(����.����,18,����.x+����.w/2,����.y-16,1,0,0,1)
					local ����=����.����
					if ����.���˻� then
						����="�˻�"
					end
					--print(����)
					if ����~=nil then
						DrawHexagon(����,ImVec2(��Ļ����.x,��Ļ����.y-10),ImVec4(1,1,1,1))
						ui.DrawText(tostring(math.floor(((����.��ǰŭ��/75000)*100))),13,ImVec2(��Ļ����.x + #����*13/4 +25,��Ļ����.y-15),ImVec4(1,1,1,1))
						if not ͼƬ��Դ[����.��ɫ] then 
							
							ͼƬ��Դ[����.��ɫ]=ui.LoadImages("ͷ���/"..tostring(����.��ɫ)..".png")
							print(ͼƬ��Դ[����.��ɫ],"ͷ���/"..tostring(����.��ɫ)..".png")
						elseif ͼƬ��Դ[����.��ɫ]>0 then
							ui.DrawImage(ͼƬ��Դ[����.��ɫ],ImVec2(��Ļ����.x - #����*13 / 2 -15,��Ļ����.y-10-15),ImVec2(��Ļ����.x - #����*13 / 2+15,��Ļ����.y-10+15),ImVec2(0,0),ImVec2(1,1),ImVec4(1,1,1,1))
						end
						
						--ui.DrawText(����,14,ImVec2(����.x+����.w/2,����.y-10),ImVec4(1,1,1,1))
					end
					
					local ������ɫ=��ȡ������ɫ(����.��󻤼�)
					if ������ɫ~=nil then
						--print(������ɫ.����,������ɫ.r,������ɫ.g,������ɫ.b,������ɫ.a)
						--ui.DrawText(������ɫ.����,18,����.x+����.w/2,����.y-32,������ɫ.r,������ɫ.g,������ɫ.b,1)
						ui.DrawLine(ImVec2(����.x+����.w,����.y+����.h/3*2-(����.y+����.h/3*2-����.y-����.h/3)/100*����.��ǰ����/����.��󻤼�*100),ImVec2(����.x+����.w,����.y+����.h/3*2+2),ImVec4(������ɫ.r,������ɫ.g,������ɫ.b,������ɫ.a),4)
					end
					ui.DrawLine(ImVec2(����.x+2,����.y+����.h/3*2-(����.y+����.h/3*2-����.y-����.h/3)/100*����.��ǰѪ��/����.���Ѫ��*100),ImVec2(����.x+2,����.y+����.h/3*2+2),ImVec4(������ɫ.r,������ɫ.g,������ɫ.b,������ɫ.a),4)
					--print(����.����)
					local ��������=������.����Ʒ������[����.����]
					
					if ��������~= nil then
						local ������ɫ=������.������ɫֵ[string.sub(��������,1,2)]
						if ������ɫ~=nil then
							ui.DrawText(��������,18,ImVec2(����.x+����.w/2,����.y-48),ImVec4(������ɫ.r,������ɫ.g,������ɫ.b,������ɫ.a))
						end
					end
				end
				ui.DrawText(tostring(math.floor(getdis({����.x,����.z,����.y},{����.x,����.z,����.y}))),
					18,ImVec2(����.x+����.w/2,����.y+����.h+1),ImVec4(0,1,0,1))
				
			end
		end
	end
	--ui.DrawLine(200,300,300,400,1.0,0,0,1,30)
	--ui.DrawText("�����ı�",29,500,600,1,0,0,1)
end


function OnTick()
	--�������ݻص���������õ���Ϸ����ʱ,����ô˷���
	--���Ҫ�ڻ��ƻص���ʹ�ö�����Ϣ��,����浽���أ�������ƻص����������
	
	��������=#�����Ϣ
	���=�����Ϣ
	����=������Ϣ
	��Ʒ=��Ʒ��Ϣ
	if not ��ʼ then
		��ʼ=true
	end
end