print("脚本加载")
local 武器库 = require("武器库")

--[[
表结构:
玩家信息
地址,姓名,招式,出刀,哈希,振刀,是人机,武器,状态,角色,蓄力,队伍,x,y,z,pitch,yaw,roll,
当前血量/护甲/怒气/精力
最大血量/护甲/怒气/精力
本人信息
招式,出刀,哈希,振刀,武器,状态,角色,蓄力,x,y,z,pitch,yaw,roll
当前血量/护甲/怒气/精力
最大血量/护甲/怒气/精力

matrix

ui
--print(ui.getw(),ui.geth())--宽高
--浮点滑条=ui.SliderFloat("test",浮点滑条,1.0,100.0,"%f",0);
--ui.Spacing()
--整数滑条=ui.SliderInt("测试滑条int",整数滑条,1,100,"%d",0);

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
勾了=ui.Checkbox("勾我",勾了)
SameLine()
Separator()
Text("hello")
SliderFloat()
浮点滑条=ui.SliderFloat("test",浮点滑条,1.0,100.0,"%f",0);
SliderInt()
整数滑条=ui.SliderInt("测试滑条int",整数滑条,1,100,"%d",0)
DrawLine()
DrawText()
ui.DrawLine(200,300,300,400,1.0,0,0,1,30)
ui.DrawText("测试文本",29,500,600,1,0,0,1)





km
延迟(12)
相对移动(100,20,30)--xy完成时间
左键(1)--1是按下，0是松开
中键(1)
右键(1)
按下(1)--按下键盘键
弹起(1)
滚轮(1)--1是往前1格，-1是往后1格
屏蔽左键(1)--1屏蔽，0解除 使用鼠标松开功能时，必须先屏蔽，才能松开，完成后必须解除，否则鼠标无法使用
屏蔽右键(1)
屏蔽X(1)--1屏蔽，0解除
屏蔽Y(1)
屏蔽滚轮(1)
屏蔽键(65)--屏蔽键盘键，必须键盘插盒子上才能使用，不插无效
解除键(65)
解除所有屏蔽()
是否按下(1)--左键1
--]]

local 对象数量=0;
local 提示信息="现在有";
local 提示信息2="个敌人";
local 危险提示=true;
local 显示名字=true;
local 开启透视=true;
local 显示射线=true
local 矩阵={}
local 玩家={}
local 本人={}
local 护甲={
			[600]={描述="白甲",r=1.0,g=1.0,b=1.0,a=1.0},
			[900]={描述="蓝甲",r=0.2,g=0.6,b=0.7,a=1.0},
			[1200]={描述="紫甲",r=0.5,g=0.0,b=0.5,a=1.0},
			[1500]={描述="金甲",r=1.0,g=0.6,b=0.0,a=1.0},
			[1800]={描述="红甲",r=0.8,g=0.2,b=0.2,a=1.0}
	}
local function getdis(localpos, pos)
    -- 检查输入是否有效
    if not localpos or not pos then
        print("Error: Invalid input positions.")
        return 0
    end

    local temp = {localpos[1] - pos[1], localpos[2] - pos[2], localpos[3] - pos[3]}
    -- 打印调试信息
    --print(temp[1], temp[2], temp[3])

    -- 计算两点间的欧几里得距离
    return math.sqrt(temp[1]*temp[1] + temp[2]*temp[2] + temp[3]*temp[3])
end
local function w2s(px, py, Matrix, x, y, z)
    local 方框 ={}
    local wi = Matrix[4] * x + Matrix[8] * z + Matrix[12] * y + Matrix[16]
    if (wi < 0.01) then return nil end
    local w = 1 / wi
    local BoxX = px + (Matrix[1] * x + Matrix[5] * z + Matrix[9] * y + Matrix[13]) * w * px -- X
    local BoxY = py - (Matrix[2] * x + Matrix[6] * (z+1.9) + Matrix[10] * y + Matrix[14]) * w * py -- Y
    local 脚底板 = py - (Matrix[2] * x + Matrix[6] * z + Matrix[10] * y + Matrix[14]) * w * py
	local H =脚底板-BoxY
	方框["x"]=BoxX-H/4
	方框["y"]=BoxY
	方框["w"]=H/2.5
	方框["h"]=H
    return 方框
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

local function 判断角度(角度,第一人称坐标,目标坐标)
    local yaw=rotateyaw(角度)
	--print(yaw,角度.x,角度.y)
	local war=CalcYaw(第一人称坐标,目标坐标)
    local phi = math.abs(war - yaw) % 360
    if phi > 180 then 
        return 360 - phi
    end
    return phi
end

local function 获取护甲颜色(最大护甲)
	--print(最大护甲)
	
	--print(#护甲)
	local 护甲名字=护甲[最大护甲]
	--print(护甲名字.描述)
	if 护甲名字 then
		return 护甲名字
	end
	return {描述="无甲",r=0.0,g=0.0,b=0.0,a=0.0}
end

function OnDraw()
	
	--你可以看作是update，每一帧处理一次
	--print("在跑")
	矩阵=matrix--只可以在这里使用matrix
	
	ui.Begin("透视UI")
	ui.Text("欢迎使用~")
	ui.Text(tostring(本人.角色).."现在有"..tostring(#本人.技能).."个技能")
	for index, 技能 in pairs(本人.技能) do
		if(技能.状态~=4) then--4代表是主动技能
			ui.Text("第"..index.."个技能信息")
			ui.Text("技能ID:"..技能.ID)
			ui.Text("技能状态:"..技能.状态)
			ui.Text("技能CD:"..技能.CD)
		end
	end
	ui.Text("招式:"..本人.招式)
	ui.Text("状态:"..tostring(本人.状态))
	ui.Text("出刀:"..tostring(本人.出刀))
	ui.Text("蓄力:"..tostring(本人.蓄力))
	ui.Text("哈希:"..tostring(本人.哈希))
	ui.Text("振刀:"..tostring(本人.振刀))
	ui.Text("僵直:"..tostring(本人.僵直时间))
	ui.Text("怒气:"..tostring(本人.当前怒气))
	ui.Text("护甲:"..tostring(本人.当前护甲))
	ui.Text("精力:"..tostring(本人.当前精力))
	ui.Text("最大精力:"..tostring(本人.最大精力))
	ui.Text("精力消耗:"..tostring(本人.精力消耗))
	ui.Text("当前武器槽位:"..tostring(本人.武器槽))
	ui.Text("武器栏A ID:"..tostring(本人.武器栏AID))
	ui.Text("武器栏A 耐久:"..tostring(本人.武器栏A当前耐久))
	ui.Text("武器栏A 最大耐久:"..tostring(本人.武器栏A最大耐久))
	ui.Text("武器栏B ID:"..tostring(本人.武器栏BID))
	ui.Text("武器栏B 耐久:"..tostring(本人.武器栏B当前耐久))
	ui.Text("武器栏B 最大耐久:"..tostring(本人.武器栏B最大耐久))
	ui.Spacing()
	开启透视=ui.Checkbox("开启透视",开启透视)
	危险提示=ui.Checkbox("危险提示",危险提示)
	显示名字=ui.Checkbox("显示名字",显示名字)
	显示射线=ui.Checkbox("显示射线",显示射线)
	ui.Spacing()
	ui.End()
	if(危险提示 and 对象数量>0) then 
		ui.DrawText("注意 周围有"..tostring(对象数量).."个敌人",29,ui.getw()/2-200,100,1,0,0,1)
	end
	--print(本人.pitch,本人.yaw,本人.roll)
	if(开启透视) then 
		for index, 对象 in pairs(玩家) do
			local 角度=判断角度({x=本人.pitch,y=本人.roll,z=本人.yaw},{x=本人.x,y=本人.z,z=本人.y},{x=对象.x,y=对象.z,z=对象.y})
			--print(角度)
			local 方框=w2s(ui.getw()/2,ui.geth()/2,矩阵,对象.x,对象.z,对象.y)
			if(方框~=nil) then 
				--print(方框.x,方框.y)
				if(显示射线) then
					ui.DrawLine(方框.x+方框.w/2,方框.y-16,ui.getw()/2,0,1.0,0,0,1,4)
				end
				if(显示名字) then
					--ui.DrawText(对象.姓名,18,方框.x+方框.w/2,方框.y-16,1,0,0,1)
					
					--ui.DrawText(对象.姓名,18,方框.x+方框.w/2,方框.y-16,1,0,0,1)
					local 名字=对象.姓名
					if 对象.是人机 then
						名字="人机"..tostring(对象.僵直时间)
					end
					ui.DrawText(名字,18,方框.x+方框.w/2,方框.y-10,1,1,1,1)
					local 护甲颜色=获取护甲颜色(对象.最大护甲)
					if 护甲颜色~=nil then
						--print(护甲颜色.描述,护甲颜色.r,护甲颜色.g,护甲颜色.b,护甲颜色.a)
						--ui.DrawText(护甲颜色.描述,18,方框.x+方框.w/2,方框.y-32,护甲颜色.r,护甲颜色.g,护甲颜色.b,1)
						ui.DrawLine(方框.x+方框.w,方框.y+方框.h/3*2-(方框.y+方框.h/3*2-方框.y-方框.h/3)/100*对象.当前护甲/对象.最大护甲*100,方框.x+方框.w,方框.y+方框.h/3*2+2,护甲颜色.r,护甲颜色.g,护甲颜色.b,护甲颜色.a,4)
					end
					ui.DrawLine(方框.x+2,方框.y+方框.h/3*2-(方框.y+方框.h/3*2-方框.y-方框.h/3)/100*对象.当前血量/对象.最大血量*100,方框.x+2,方框.y+方框.h/3*2+2,护甲颜色.r,护甲颜色.g,护甲颜色.b,护甲颜色.a,4)
					local 武器名字=武器库.武器品质名字[对象.武器]
					if 武器名字~= nil then
						local 武器颜色=武器库.武器颜色值[string.sub(武器名字,1,2)]
						if 武器颜色~=nil then
							ui.DrawText(武器名字,18,方框.x+方框.w/2,方框.y-48,武器颜色.r,武器颜色.g,武器颜色.b,武器颜色.a)
						end
					end
				end
				ui.DrawText(tostring(math.floor(getdis({本人.x,本人.z,本人.y},{对象.x,对象.z,对象.y}))),
					18,方框.x+方框.w/2,方框.y+方框.h+1,0,1,0,1)
				
			end
		end
	end
	--ui.DrawLine(200,300,300,400,1.0,0,0,1,30)
	--ui.DrawText("测试文本",29,500,600,1,0,0,1)
end


function OnTick()
	--这是数据回调，当器灵得到游戏数据时,会调用此方法
	--如果要在绘制回调里使用对象信息表,必须存到本地，否则绘制回调不允许访问
	
	对象数量=#玩家信息
	玩家=玩家信息
	本人=本人信息
end