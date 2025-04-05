print("打印网络")
print(km.Post("baidu.com",""))
local 上次按键=false
local 大小写键=20
local 开启菜单=true
function 按键开关()
	local 当前按键状态=km.是否按下(大小写键);
	if 上次按键==false and km.是否按下(大小写键) then
		上次按键=true
		if 开启菜单 then 开启菜单=false else
			开启菜单=true end
	end
	上次按键=当前按键状态
end
local curindex=0

local 玩家={}
local 本人={}
local 开始=false
function OnTick()
	对象数量=#玩家信息
	玩家=玩家信息
	本人=本人信息
	for index, 对象 in pairs(玩家) do
		local 头坐标=数据.获取骨骼坐标(对象.骨骼)
		--print(头坐标.x,头坐标.y,头坐标.z)
	end
	开始=true
end

function OnDraw()
	if not 开始 then
		return
	end
	按键开关()
	if 开启菜单 then
		ui.Begin("透视UI")
		ui.Text("欢迎使用~")
		curindex=ui.Combo("测试combo",curindex,{"测试1","测试2"})
		ui.End()
	end
	
	

end