print("打印网络")
--print(km.Post("baidu.com",""))
local 上次按键=false
local 大小写键=20
local 开启菜单=true
local a=ui.LoadImages("1/1.png")
print("图片ID=",a)
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



-- 参数说明：
--   center    : ImVec2 类型，六边形中心坐标（必选）
--   color     : ImVec4 类型，线条颜色（默认白色）
--   long_width: 中间长边的水平宽度（默认 80）
--   short_width: 两侧短边水平宽度（默认 40）
--   height    : 垂直高度（默认 60）
--   thickness : 线条粗细（默认 4.0）
function DrawHexagon(center, color, long_width, short_width, height, thickness)
    -- 设置默认参数
    color = color or ImVec4(1.0, 1.0, 1.0, 1.0)  -- 默认白色
    long_width = long_width or 80
    short_width = short_width or 70
    height = height or 15
    thickness = thickness or 0.1

    -- 计算六个顶点坐标（相对中心点的偏移）
    local points = {
        ImVec2( long_width,  0),        -- 右中
        ImVec2( short_width, -height),  -- 右上
        ImVec2(-short_width, -height),  -- 左上
        ImVec2(-long_width,   0),       -- 左中
        ImVec2(-short_width,  height),  -- 左下
        ImVec2( short_width,  height)   -- 右下
    }

    -- 转换为绝对坐标并连接顶点
    for i = 1, #points do
        -- 将相对坐标转换为绝对坐标
        local start = ImVec2(
            center.x + points[i].x,
            center.y + points[i].y
        )
        
        -- 计算下一个点（循环连接）
        local next_index = (i % #points) + 1
        local end_p = ImVec2(
            center.x + points[next_index].x,
            center.y + points[next_index].y
        )

        -- 绘制线条
        ui.DrawLine(start, end_p, color, thickness)
    end
end


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
	ui.DrawLine(ImVec2(100,200),ImVec2(ui.getw()/2,0),ImVec4(1.0,0,0,1.0),4.0)
	ui.DrawCircle(ImVec2(300,200),30,ImVec4(1.0,0,0,1.0),0,1)
	ui.DrawCircleF(ImVec2(600,200),30,ImVec4(1.0,0,0,1.0),0)
	ui.DrawText("测试字符串",15,ImVec2(10,10),ImVec4(1.0,0,0,1.0))
	ui.DrawImage(a,ImVec2(300,30),ImVec2(100,200),ImVec2(0,0),ImVec2(1,1),ImVec4(1.0,0,0,1.0))
	DrawHexagon(ImVec2(100,100),ImVec4(1.0,0,0,1.0))

end