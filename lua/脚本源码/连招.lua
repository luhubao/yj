print("���Ľű�1.0");
--��һ�μ��س�ʼ��
local �ϴ������Ϣ={};
local �ϴα�����Ϣ={};
local ����²��=5;
local ������="_crouch_idle_01";
local վ��="_idle_01";
local ��ֱ="hurt_stand_heavy";
local ��ֱ2="stand_light_right";
local �ҽ�ֱ="hurt_stand_light";
local ����="fly_back_01";
local ������ֱ="_fly_";
print("��ʼ��")
local function getdis(localpos, pos)
    if not localpos or not pos then
        print("Error: Invalid input positions.")
        return 0
    end
    local temp = {localpos[1] - pos[1], localpos[2] - pos[2], localpos[3] - pos[3]}
    return math.sqrt(temp[1]*temp[1] + temp[2]*temp[2] + temp[3]*temp[3])
end

local �ϴβ���ʱ�� = {
	�е� = 0,
	���� = 0,
	���� = 0,
	����A=0,
	����=0,
	CCA=0,
	����=0,
	����=0,
	����ײ��=0
}


function ״̬����()
	local ��ǰʱ��=km.��ȡʱ��();
	--print(������Ϣ.������)
	if �ϴα�����Ϣ.������~=������Ϣ.������ then
		�ϴβ���ʱ��.�е�=��ǰʱ��;
	end
	if �ϴα�����Ϣ.����==10 and ������Ϣ.����==12 then
		�ϴβ���ʱ��.����=��ǰʱ��;
	end
	
	
	--״̬�����꣬�ٴδ�����Ϊ��һ֡����
	�ϴ������Ϣ=�����Ϣ;
	�ϴα�����Ϣ=������Ϣ;
end
function Ѱ��Ŀ��(Ŀ��)
	for index, ���� in pairs(�����Ϣ) do
		if (Ŀ��.��ַ==����.��ַ) then 
		Ŀ��=���� 
		break
		end
	end
	return Ŀ��
end

function Ŀ��ѡ����()
	local ��С����=0.0;
	local �������={};
	for index, ���� in pairs(�����Ϣ) do
		local ��ǰ����=getdis({������Ϣ.x,������Ϣ.z,������Ϣ.y},{����.x,����.z,����.y});
		if ��С����==0.0 then
			��С����=��ǰ����;
			�������=����;
		elseif ��ǰ����<��С���� then 
			��С����=��ǰ����;
			�������=����;
		end
	end
	--print(��С����)
	return �������;
end

function CCA()
	
	if km.��ȡʱ��()-�ϴβ���ʱ��.����<200 then km.�ӳ�(100) end
	km.����(6);
	local ��ʱ=km.��ȡʱ��();
	print("ִ��CCA"..tostring(��ʱ));
	local ����=false;
	while (true)
	do
		����.����();
		if (km.Ѱ���ı�(������Ϣ.��ʽ,������) or km.��ȡʱ��()-��ʱ>400) then
			����=true;
			print("���³ɹ���")
			break;
		end
		--print("ѭ������")
	end
	if ����==false then km.����(6); return end  
	--print("ѭ������")
	km.����(6);
	km.�ӳ�(3);
	km.����(6);
	km.�ӳ�(3);
	km.����(6);
	��ʱ=km.��ȡʱ��();
	local վ������=false;
	while true do
		����.����();
		if ((km.Ѱ���ı�(������Ϣ.��ʽ,������)==false and km.Ѱ���ı�(������Ϣ.��ʽ,վ��)) or km.��ȡʱ��()-��ʱ>200) then
			վ������=true;
			print("վ������")
			break;
		end
	end
	if վ������==false then return end
	--km.�ӳ�(130);
	km.���(1);
	km.�ӳ�(5);
	km.���(0);
end
function ����()
	print("ִ������",km.��ȡʱ��())
	km.����(6);
	km.�ӳ�(1);
	km.����(6);
	--km.����(0x51);
	--km.����(0x51);
	km.�Ҽ�(1);
	--km.����(0x51);
	--km.����(0x51);
	km.�ӳ�(5);
	km.�Ҽ�(0);--�ȴ�����
	
	
end
function ����A()
	print("ִ�г���A")
	km.����(225);
	km.�ӳ�(150);
	km.���(1);
	km.�ӳ�(5);
	km.���(0);
	km.�ӳ�(50);
	km.����(225);
end
function A()
	print("ִ��A")
	km.���(1);
	km.�ӳ�(50);
	km.���(0);
end
function ��������(Ŀ��)
	print("ִ�й���",km.��ȡʱ��());
	km.����(0x14);
	km.�ӳ�(1);
	km.����(0x14);
	km.�ӳ�(1);
	km.�Ҽ�(1);
	local ��ʱ=km.��ȡʱ��()+2000;
	km.�ӳ�(250);
	����.����();
	Ŀ��=Ѱ��Ŀ��(Ŀ��);
	
	if km.Ѱ���ı�(Ŀ��.��ʽ,������ֱ)==false then km.�Ҽ�(0) print(������Ϣ.����,Ŀ��.��ʽ) return end
	while(true)
	do
		����.����();
		Ŀ��=Ѱ��Ŀ��(Ŀ��);
		if ��ʱ- km.��ȡʱ��() < 0 then km.�Ҽ�(0) break end
		if ������Ϣ.����>=0.495 then km.�Ҽ�(0) break end 
		--print(��ʱ- km.��ȡʱ��(),������Ϣ.����,Ŀ��.��ʽ)
		km.�ӳ�(1);
		--print(��ʱ- km.��ȡʱ��(),������Ϣ.����,Ŀ��.��ʽ)
	end
	--print(��ʱ- km.��ȡʱ��(),������Ϣ.����)
end

local �ϴν�ֱ����=0.0;


function ̫���ᵶ����()
	if ������Ϣ.��������==102 or ������Ϣ.��������==123 then
		--print("ѡ��Ŀ��")
	--�ж�һ������
		--�ж����������ΪĿ��
		local Ŀ��=Ŀ��ѡ����();
		if Ŀ��=={} then return end;--ûĿ��
		
		
		if Ŀ��.��ֱʱ��>0 and �ϴν�ֱ����~=Ŀ��.��ʽ then
				�ϴν�ֱ����=Ŀ��.��ʽ
				print("��ֱ���� "..Ŀ��.��ʽ.."��ֱʱ�� "..tostring(Ŀ��.��ֱʱ��))
			end
		if ������Ϣ.��ֱʱ��==0 and ������Ϣ.����==10 and km.�Ƿ���(����²��) then
			local ��ǰʱ��=km.��ȡʱ��();
			if (km.Ѱ���ı�(Ŀ��.��ʽ,վ��) or �Ƿ����ܶ�(Ŀ��) )and ��ǰʱ��-�ϴβ���ʱ��.���� > 800 then
				A();
				�ϴβ���ʱ��.����=��ǰʱ��;
				return;
			end
		
			--print("��ֱ���� "..Ŀ��.��ʽ.."��ֱʱ�� "..tostring(Ŀ��.��ֱʱ��))
			if Ŀ��.��ֱʱ��>0 and �ϴν�ֱ����~=Ŀ��.��ʽ then
				�ϴν�ֱ����=Ŀ��.��ʽ
				print("��ֱ���� "..Ŀ��.��ʽ.."��ֱʱ�� "..tostring(Ŀ��.��ֱʱ��))
			end
			
			
			--�ж��Ƿ����ִ��CCA
			if Ŀ��.��ֱʱ��>=0.8 and Ŀ��.��ֱʱ��<=1.3 and
			(km.Ѱ���ı�(Ŀ��.��ʽ,��ֱ) or km.Ѱ���ı�(Ŀ��.��ʽ,��ֱ2)) and
			��ǰʱ��-�ϴβ���ʱ��.CCA > 1000 and ��ǰʱ��-�ϴβ���ʱ��.����>400 then
				�ϴβ���ʱ��.CCA=��ǰʱ��;
				�ϴβ���ʱ��.����=��ǰʱ��;
				CCA();
				--print(��ǰʱ��);
				
				--return;
				
			end
			----�ж��Ƿ����ִ������
			if Ŀ��.��ֱʱ��>0.5 and Ŀ��.��ֱʱ��<0.8 and km.Ѱ���ı�(Ŀ��.��ʽ,��ֱ) and ��ǰʱ��-�ϴβ���ʱ��.���� > 1000 and ��ǰʱ��-�ϴβ���ʱ��.CCA > 600 and ��ǰʱ��-�ϴβ���ʱ��.���� > 300 then
				����();
				km.�ӳ�(350);
				��������(Ŀ��);
				�ϴβ���ʱ��.����=��ǰʱ��;
				�ϴβ���ʱ��.����=��ǰʱ��;
			end
				
			
			
			if	Ŀ��.��ֱʱ��>0.72 and Ŀ��.��ֱʱ��<1.35 and km.Ѱ���ı�(Ŀ��.��ʽ,������ֱ) and ��ǰʱ��-�ϴβ���ʱ��.����>2000 then
				
				�ϴβ���ʱ��.����=��ǰʱ��;
				return;
			end
			
			--�ж��Ƿ����ִ�й���
			--�ж��Ƿ����ִ����A
		end
	end
end


function �Ƿ񹥻���(Ŀ��)
	if km.Ѱ���ı�(Ŀ��.��ʽ,"_sprint_attack_") and km.Ѱ���ı�(Ŀ��.��ʽ,"_recover") then return true else return false end
end
function �Ƿ����ܶ�(Ŀ��)
	if (km.Ѱ���ı�(Ŀ��.��ʽ,"_sprint_") or km.Ѱ���ı�(Ŀ��.��ʽ,"_dodge_") or
	km.Ѱ���ı�(Ŀ��.��ʽ,"_spiritsman_") or km.Ѱ���ı�(Ŀ��.��ʽ,"_run_")) and �Ƿ񹥻���(Ŀ��)==false then return true else return false end
end

function OnTick()
	--print("��ֱ���� "..������Ϣ.��ʽ)
	--print("��ǰ��������:"..tostring(������Ϣ.��������))
	
	--����.����();
	if �ϴ������Ϣ =={} then �ϴ������Ϣ=�����Ϣ end;
	if �ϴα�����Ϣ =={} then �ϴα�����Ϣ=������Ϣ end;
	
	״̬����();
	
	--
	--��һ�׼�ץ��ֱ�������
	
	
	
	̫���ᵶ����();--��������
	
	
end
