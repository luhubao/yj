os.execute("cls")
print("�ű�����")
local ������ = require("������")
local ��ʽ�� = require("��ʽ��")

--[[
��ṹ:
�����Ϣ
��ַ,����,��ʽ,����,��ϣ,��,���˻�,����,״̬,��ɫ,����,����,x,y,z,pitch,yaw,roll
������Ϣ
��ʽ,����,��ϣ,��,����,״̬,��ɫ,����,x,y,z,pitch,yaw,roll
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
local ������=true;
local ����={}
local ���={}
local ����={}
local ���״̬�� = {}
local ʱ��=0.0
local ����Ƕ�=180.0
local �������=12.0
local ���Ҽ�״̬={��=false,��=false}
local �ϴΰ���=false
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


function OnDraw()
	--����Կ�����update��ÿһ֡����һ��
	--print("����")
	
	
	local ��ǰ����״̬=km.�Ƿ���(20);
	if �ϴΰ���==false and km.�Ƿ���(20) then
		�ϴΰ���=true
		if ������ then ������=false else
			������=true end
	end
	�ϴΰ���=��ǰ����״̬
	
	ui.Begin("��UI")
	ui.Text("��ӭʹ��~")
	ui.Text("�����浽��ʽ���е���~")
	ui.Text("����Сд�� �ر�/������")
	
	������=ui.Checkbox("������",������)
	����Ƕ�=ui.SliderFloat("����>�Ƕ�",����Ƕ�,1.0,180.0,"%f",0);
	�������=ui.SliderFloat("��Զ�񵶴������",�������,1.0,16.0,"%f",0);
	ui.End()
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

local function ��ѯ����(��������, ��ʽ��, ����, �Ƕ�, ������������, ��һ����, ����ת��)
    local �񵶷�ʽ = "վ��"
    local ִ�д��� = 1
    local ִ���ӳ� = 0
    local ���� = false
    local ��ʽ���� = "δ֪"
    local ���������� = "վ��"
	--print(��������,��ʽ��)
    local ���� = ��ʽ��[��������][��ʽ��]
	--print(��������,��ʽ��)
    if ���� then
        -- ����һ��ͨ�õ�ƥ���߼�����
        local function ƥ���߼�(����ǰ׺, ����, �Ƕ�)
			local ǰ׺ = ����ǰ׺ .. "_"
			-- �������Ե������������������������鳤����ͬ
			local maxIndex = #(����[ǰ׺ .. "��С�񵶽Ƕ�"])
			for index = 1, maxIndex do
				-- ��̬����ÿ�����Ե���������������
				local ��С�񵶽Ƕ� = ����[ǰ׺ .. "��С�񵶽Ƕ�"][index]
				local ����񵶽Ƕ� = ����[ǰ׺ .. "����񵶽Ƕ�"][index]
				local ����񵶾��� = ����[ǰ׺ .. "����񵶾���"][index]
				local ��Զ�񵶾��� = ����[ǰ׺ .. "��Զ�񵶾���"][index]
		
				if ���� >= ����񵶾��� and ���� <= ��Զ�񵶾��� and �Ƕ� >= ��С�񵶽Ƕ� and �Ƕ� <= ����񵶽Ƕ� then
					return true, index
				end
			end
			return false, nil
		end
		
        local �ɹ�, ƥ������
        if ����ת�� then
            �ɹ�, ƥ������ = ƥ���߼�("��ת", ����, �Ƕ�)
            ���������� = "��ת"
        elseif ��һ���� then
            �ɹ�, ƥ������ = ƥ���߼�("�Ƚ�", ����, �Ƕ�)
            ���������� = "�Ƚ�"
        else  -- Ĭ��Ϊվ��
            �ɹ�, ƥ������ = ƥ���߼�("վ��", ����, �Ƕ�)
            ���������� = "վ��"
        end
		--print(����������,ƥ������)
        if �ɹ� then
            -- ��鴥������
            local ������������ = ����[���������� .. "_��������"][ƥ������]
            local ����, �������� = ��ʽ��.�Ƿ��޴�������(������������, ������������)
            if not ���� then
                local ���� = {
                    ���ӳ� = ����[���������� .. "_���ӳ�"][ƥ������],
                    �񵶷�ʽ = ����[���������� .. "_�񵶷�ʽ"][ƥ������],
                    ִ�д��� = ����[���������� .. "_ִ�д���"][ƥ������],
                    ִ���ӳ� = ����[���������� .. "_ִ���ӳ�"][ƥ������]
                }
                km.�ӳ�(����.���ӳ�)
                �񵶷�ʽ = ����.�񵶷�ʽ
                ִ�д��� = ����.ִ�д���
                ִ���ӳ� = ����.ִ���ӳ�
                ��ʽ���� = ����.����
                ���� = true
                return ����, �񵶷�ʽ, ִ�д���, ִ���ӳ�, ��ʽ����, ����������
            end
        end
    end
    return ����, �񵶷�ʽ, ִ�д���, ִ���ӳ�, ��ʽ����, ����������
end




local function �񵶹���(��������,��ʽ��,����,�Ƕ�,������������,����,״̬)
	
	local �񵶷�ʽ=0
	local ִ�д���=1
	local ִ���ӳ�=0
	local ����=false
	local ����=""
	local ����ת��=false
	local ��һ����=false
	local ����������=""
	if((״̬==20 or ״̬==11) and ����<0.499) then ����ת��=true end--����ת��
	���Ҽ�״̬={��=km.�Ƿ���(1),��=km.�Ƿ���(2)}
	if ����ת�� then
		if (����.����==12 and ����.����>=0.12 or (���Ҽ�״̬.�� or ���Ҽ�״̬.��)==false) then
			����ת��=false
		end
	end
	
	if(����>=0.499 and ״̬==20 and (���Ҽ�״̬.�� or ���Ҽ�״̬.��)) then ��һ����=true end --����1.0��
	--print(��������,��ʽ��,����,�Ƕ�,������������,��һ����,����ת��)
	if(������.�ǽ�ս����(��������)) then 
		--print("������ǰ ",��һ����,����ת��,����,��ʽ��)
		����,�񵶷�ʽ,ִ�д���,ִ���ӳ�,��ʽ����,����������=��ѯ����(��������,��ʽ��,����,�Ƕ�,������������,��һ����,����ת��)
	end
	return ����,�񵶷�ʽ,ִ�д���,ִ���ӳ�,��ʽ����,����������
end

function �ǲ�����״̬(����)
	if ����.״̬==31 or ����.״̬==51 or
		����.״̬==30 or ����.��==1 or ����.״̬==53 or ����.״̬==35
			then return true
	end
	return false
end
function OnTick()
	--�������ݻص���������õ���Ϸ����ʱ,����ô˷���
	--���Ҫ�ڻ��ƻص���ʹ�ö�����Ϣ��,����浽���أ�������ƻص����������
	local ��ǰ���״̬ = {}
	--local ����ȴ=false
	��������=#�����Ϣ
	���=�����Ϣ
	����=������Ϣ
	--print(���Ҽ�״̬.��)
	if �ǲ�����״̬(����) then return end--�Ѿ�������
	if(������) then
			for index, ���� in pairs(���) do
			--print(����.��ʽ)
				local ����=getdis({����.x,����.y,����.z}, {����.x,����.y,����.z})
				--print(����)
				if(����<=�������) then
					local ��ַ = ����.��ַ
					-- ���״̬���в����ڴ���ң���ʼ�����ǵ�״̬
					if not ���״̬��[��ַ] then
						���״̬��[��ַ] = {
							����״̬ = ����.����,
							�������� = false,
							��ʯ״̬ = ����.״̬,
							��ʯ���� = false
						}
					end
					-- ���µ�ǰ���״̬
					��ǰ���״̬[��ַ] = true
					-- ���ºʹ���״̬�߼�
					
					
					local ��������=����.��������
					
					if(���״̬��[��ַ].��ʯ״̬==6 and (��������==������.����_ն�� or ��������==������.����_����) and ����.״̬==20) then
						���״̬��[��ַ].��ʯ����=false
					end
					--����������Ҫ���⴦��,��Ȼ�񲻵��ģ�Ԥ��״̬���ӿڣ��ȿ���д
					���״̬��[��ַ].��ʯ״̬=����.״̬
					���״̬��[��ַ].����״̬=����.����
					if(���״̬��[��ַ].����״̬~=12 or ����.״̬==31) then--����,����״̬
						���״̬��[��ַ].��������=false
					end
					
					if(�жϽǶ�({x=����.pitch,y=����.roll,z=����.yaw},{x=����.x,y=����.z,z=����.y},{x=����.x,y=����.z,z=����.y})<=����Ƕ�) then
						if (���״̬��[��ַ].��������==false) then
							if(����.��������~=������.����_����) then 
								if(����.����==12) then
									--print("start time: ", km.��ȡʱ��())  -- �����YYYY-MM-DD HH:MM:SS
									--local �Լ�������Ƕ�=�жϽǶ�({x=����.pitch,y=����.roll,z=����.yaw},{x=����.x,y=����.z,z=����.y},{x=����.x,y=����.z,z=����.y})
									local �Ƕ�=�жϽǶ�({x=����.pitch,y=����.roll,z=����.yaw},{x=����.x,y=����.z,z=����.y},{x=����.x,y=����.z,z=����.y})
									
									local ����,�񵶷�ʽ,ִ�д���,ִ���ӳ�,��ʽ����,����������=�񵶹���(��������,����.��ʽ,����,�Ƕ�,����.��������,����.����,����.״̬)
									
									if ���� then
										���״̬��[��ַ].��������=true
										for i=1,ִ�д��� do
											�񵶷�ʽ()
											km.�ӳ�(ִ���ӳ�)
										end
										local ʧ������=""
										if ����.����==12 and ����.����>0.12 then
											ʧ������="ʧ�� ԭ��:�Լ�������ֱ"
										end
										if ����.״̬==6 or ����.��ֱʱ��>=0.5 then
											ʧ������="ʧ�� ԭ��:�ܻ��޷���"--�����һ������Ϊ��ʱ���н�ֱҲ����
										end
										print("[���¼�] ���� "..����������.." ��ʽ"..��ʽ����.." ����:"..tostring(����).." �����Ƕ�"..tostring(�Ƕ�).." ִ���ӳ�"..tostring(ִ���ӳ�))
										����ȴ=true
										if ʧ������~="" then
											--����ȴ=false--ʧ���ˣ����Գ����ٴ���
											print(ʧ������)
										end
										
									end
								end
							end
						end
					end
				end
			end
		-- �Ƴ��Ѿ������ڵ����
		for ��ַ in pairs(���״̬��) do
			if not ��ǰ���״̬[��ַ] then
				���״̬��[��ַ] = nil
			end
		end
	end
	
	
end