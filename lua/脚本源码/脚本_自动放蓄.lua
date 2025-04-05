local ������ = require("������")
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
local ��ץ������={
	ذ��=106,
	̫��=102,
	˫��=118,
	˫�ع�=116,
	��=120,
	ն��=119,
	˫�=121,
	����=122,
	�ᵶ=123,
	ȭ��=124
}

local function �����Ƿ����ץ������()
	for index, ���� in pairs(��ץ������) do
		if ������Ϣ.��������==���� then return true end
	end
	return false
end
local ���״̬�� = {}
local ����ʱ��=0.0
local ץ�ܻ�=true
local ץ��A=true
local ץ��=true
local ץ�񵶺�ҡ=true
local ץ�����Ƚ�=true
local ץ������=true
local �ϴη���ʱ��=0
function OnDraw()
	--����Կ�����update��ÿһ֡����һ��
	--print("����")
	--����=matrix--ֻ����������ʹ��matrix
	ui.Begin("�Զ��������")
	ץ�ܻ�=ui.Checkbox("ץ�ܻ�",ץ�ܻ�)
	ץ��A=ui.Checkbox("ץ��A",ץ��A)
	ץ��=ui.Checkbox("ץ�׵�",ץ��)
	ץ������=ui.Checkbox("ץ����",ץ������)
	ץ�񵶺�ҡ=ui.Checkbox("ץ�񵶺�ҡ",ץ�񵶺�ҡ)
	ץ�����Ƚ�=ui.Checkbox("ץ�����Ƚ�(�����ͳ��߼�)",ץ�����Ƚ�)
	ui.Text("�����ͳ����ʺ���ն��������")
	ui.End()
end
function OnTick()
	--�������ݻص���������õ���Ϸ����ʱ,����ô˷���
	--���Ҫ�ڻ��ƻص���ʹ�ö�����Ϣ��,����浽���أ�������ƻص����������
	local ���Է�=false
	local ������=false
	local ��ǰ���״̬ = {}
	if(������Ϣ.״̬==31 or ������Ϣ.״̬==30) then return end
	
	if(������Ϣ.����>=0.495 and (������Ϣ.״̬==20) and ������Ϣ.����==10) then 
		for index, ���� in pairs(�����Ϣ) do
			local ��ַ = ����.��ַ
			-- ���״̬���в����ڴ���ң���ʼ�����ǵ�״̬
			if not ���״̬��[��ַ] then
				���״̬��[��ַ] = {
					��״̬ = ����.��,
					--�񵶴��� = false,
					�񵶽���״̬=false,
					�񵶽���ʱ��=km.��ȡʱ��();
				}
			end
			-- ���µ�ǰ���״̬
			��ǰ���״̬[��ַ] = true
			-- ���ºʹ���״̬�߼�
			if ���״̬��[��ַ].��״̬==1 and ����.��==0 then
				���״̬��[��ַ].�񵶽���״̬=true
				���״̬��[��ַ].�񵶽���ʱ��=km.��ȡʱ��();
			elseif ����.��==0 or km.��ȡʱ��()-���״̬��[��ַ].�񵶽���ʱ��>300 then
				���״̬��[��ַ].�񵶽���״̬=false
			end
			���״̬��[��ַ].��״̬=����.��
			if(km.��ȡʱ��()-�ϴη���ʱ��<500) then return end 
			local ����=getdis({������Ϣ.x,������Ϣ.y,������Ϣ.z}, {����.x,����.y,����.z})
			if(����<=5) then
				�Լ������˽Ƕ�=�жϽǶ�({x=������Ϣ.pitch,y=������Ϣ.roll,z=������Ϣ.yaw},{x=������Ϣ.x,y=������Ϣ.z,z=������Ϣ.y},{x=����.x,y=����.z,z=����.y})
				�������Լ��Ƕ�=�жϽǶ�({x=����.pitch,y=����.roll,z=����.yaw},{x=����.x,y=����.z,z=����.y},{x=������Ϣ.x,y=������Ϣ.z,z=������Ϣ.y})
				if �Լ������˽Ƕ�<=60 then--�����ͳ��߼�
					if(ץ�����Ƚ� and ����.����>=0.5 and ����.״̬==20 and ����.����==10 and ����.��==0) then--ץ����޷���
						print("ץ�����Ƚ�")
						���Է�=true
						goto continue
						--print(������Ϣ.����,������Ϣ.״̬,������Ϣ.����)
					end
					if(ץ�񵶺�ҡ and ���״̬��[��ַ].�񵶽���״̬) then --ץ�񵶺�ҡ
					--���״̬��[��ַ].�񵶴���=true
						print("�񵶺�ҡ")
						���״̬��[��ַ].�񵶽���״̬=false
						���Է�=true
						goto continue
					end
					if ץ�ܻ� and ����.��ֱʱ��>0.6 then --ץ��ֱ
						print("ץ��ֱ")
						���Է�=true
						goto continue
					end
					if ץ������ and �����Ƿ����ץ������() and ����<2.0 and (����.��ϣ == 3206223861 or ����.��ϣ == 3334521573 or ����.��ϣ == 193657409 or ����.��ϣ == 616853143) then 
						print("ץ������",����)
						���Է�=true
						goto continue
					end
					if ץ��A and km.Ѱ���ı�(����.��ʽ,"jump_attack") and ����.����==12 and ����<3.0 then
						print("��A",����)
						���Է�=true
						goto continue
					end
					if ץ�� and ����.����==12 and ����.����>0.1 and ����.����<0.48 and ����<3.0 then
						print("ץ��",����,����.����)
						���Է�=true
						goto continue
					end
				end
				if �������Լ��Ƕ�<=60 then
					if(����.����<=0.45 or ����.��==1 or ����.״̬==5) then--��Ǳ���������,0.45����ת�� ״̬=5������ֱ��վ��
						������=true
						goto continue
					end
				end
				
			end
			::continue::
		end
		
		-- �Ƴ��Ѿ������ڵ����
		for ��ַ in pairs(���״̬��) do
			if not ��ǰ���״̬[��ַ] then
				���״̬��[��ַ] = nil
			end
		end
		
		if ���Է� and ������==false then
			if(km.�Ƿ���(1))then
				km.�������(1)
				km.�ӳ�(2)
				km.���(0)
				km.�ӳ�(2)
				km.�������(0)
				print("�ͷ�����")
			elseif(km.�Ƿ���(2))then
				km.�����Ҽ�(1)
				km.�ӳ�(2)
				km.���(0)
				km.�ӳ�(2)
				km.�����Ҽ�(0)
				print("�ͷ�����")
			end
			�ϴη���ʱ��=km.��ȡʱ��();
		end
	end
end