print("��ӡ����")
print(km.Post("baidu.com",""))
local �ϴΰ���=false
local ��Сд��=20
local �����˵�=true
function ��������()
	local ��ǰ����״̬=km.�Ƿ���(��Сд��);
	if �ϴΰ���==false and km.�Ƿ���(��Сд��) then
		�ϴΰ���=true
		if �����˵� then �����˵�=false else
			�����˵�=true end
	end
	�ϴΰ���=��ǰ����״̬
end
local curindex=0

local ���={}
local ����={}
local ��ʼ=false
function OnTick()
	��������=#�����Ϣ
	���=�����Ϣ
	����=������Ϣ
	for index, ���� in pairs(���) do
		local ͷ����=����.��ȡ��������(����.����)
		--print(ͷ����.x,ͷ����.y,ͷ����.z)
	end
	��ʼ=true
end

function OnDraw()
	if not ��ʼ then
		return
	end
	��������()
	if �����˵� then
		ui.Begin("͸��UI")
		ui.Text("��ӭʹ��~")
		curindex=ui.Combo("����combo",curindex,{"����1","����2"})
		ui.End()
	end
	
	

end