print("��ӡ����")
--print(km.Post("baidu.com",""))
local �ϴΰ���=false
local ��Сд��=20
local �����˵�=true
local a=ui.LoadImages("1/1.png")
print("ͼƬID=",a)
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



-- ����˵����
--   center    : ImVec2 ���ͣ��������������꣨��ѡ��
--   color     : ImVec4 ���ͣ�������ɫ��Ĭ�ϰ�ɫ��
--   long_width: �м䳤�ߵ�ˮƽ��ȣ�Ĭ�� 80��
--   short_width: ����̱�ˮƽ��ȣ�Ĭ�� 40��
--   height    : ��ֱ�߶ȣ�Ĭ�� 60��
--   thickness : ������ϸ��Ĭ�� 4.0��
function DrawHexagon(center, color, long_width, short_width, height, thickness)
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
end


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
	ui.DrawLine(ImVec2(100,200),ImVec2(ui.getw()/2,0),ImVec4(1.0,0,0,1.0),4.0)
	ui.DrawCircle(ImVec2(300,200),30,ImVec4(1.0,0,0,1.0),0,1)
	ui.DrawCircleF(ImVec2(600,200),30,ImVec4(1.0,0,0,1.0),0)
	ui.DrawText("�����ַ���",15,ImVec2(10,10),ImVec4(1.0,0,0,1.0))
	ui.DrawImage(a,ImVec2(300,30),ImVec2(100,200),ImVec2(0,0),ImVec2(1,1),ImVec4(1.0,0,0,1.0))
	DrawHexagon(ImVec2(100,100),ImVec4(1.0,0,0,1.0))

end