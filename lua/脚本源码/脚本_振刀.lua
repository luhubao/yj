os.execute("cls")
print("脚本加载")
local 武器库 = require("武器库")
local 招式库 = require("招式库")

--[[
表结构:
玩家信息
地址,姓名,招式,出刀,哈希,振刀,是人机,武器,状态,角色,蓄力,队伍,x,y,z,pitch,yaw,roll
本人信息
招式,出刀,哈希,振刀,武器,状态,角色,蓄力,x,y,z,pitch,yaw,roll
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
local 开启振刀=true;
local 矩阵={}
local 玩家={}
local 本人={}
local 玩家状态机 = {}
local 时间=0.0
local 不振角度=180.0
local 处理距离=12.0
local 左右键状态={左=false,右=false}
local 上次按键=false
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


function OnDraw()
	--你可以看作是update，每一帧处理一次
	--print("在跑")
	
	
	local 当前按键状态=km.是否按下(20);
	if 上次按键==false and km.是否按下(20) then
		上次按键=true
		if 开启振刀 then 开启振刀=false else
			开启振刀=true end
	end
	上次按键=当前按键状态
	
	ui.Begin("振刀UI")
	ui.Text("欢迎使用~")
	ui.Text("调缓存到招式库中调整~")
	ui.Text("按大小写键 关闭/开启振刀")
	
	开启振刀=ui.Checkbox("开启振刀",开启振刀)
	不振角度=ui.SliderFloat("不振>角度",不振角度,1.0,180.0,"%f",0);
	处理距离=ui.SliderFloat("最远振刀处理距离",处理距离,1.0,16.0,"%f",0);
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

local function 查询缓存(武器类型, 招式名, 距离, 角度, 本人武器类型, 是一点零, 是蓄转振)
    local 振刀方式 = "站振"
    local 执行次数 = 1
    local 执行延迟 = 0
    local 处理 = false
    local 招式描述 = "未知"
    local 振刀描述类型 = "站振"
	--print(武器类型,招式名)
    local 缓存 = 招式库[武器类型][招式名]
	--print(武器类型,招式名)
    if 缓存 then
        -- 定义一个通用的匹配逻辑函数
        local function 匹配逻辑(动作前缀, 距离, 角度)
			local 前缀 = 动作前缀 .. "_"
			-- 计算属性的最大索引，假设所有相关数组长度相同
			local maxIndex = #(缓存[前缀 .. "最小振刀角度"])
			for index = 1, maxIndex do
				-- 动态构建每个属性的完整键名并访问
				local 最小振刀角度 = 缓存[前缀 .. "最小振刀角度"][index]
				local 最大振刀角度 = 缓存[前缀 .. "最大振刀角度"][index]
				local 最近振刀距离 = 缓存[前缀 .. "最近振刀距离"][index]
				local 最远振刀距离 = 缓存[前缀 .. "最远振刀距离"][index]
		
				if 距离 >= 最近振刀距离 and 距离 <= 最远振刀距离 and 角度 >= 最小振刀角度 and 角度 <= 最大振刀角度 then
					return true, index
				end
			end
			return false, nil
		end
		
        local 成功, 匹配索引
        if 是蓄转振 then
            成功, 匹配索引 = 匹配逻辑("蓄转", 距离, 角度)
            振刀描述类型 = "蓄转"
        elseif 是一点零 then
            成功, 匹配索引 = 匹配逻辑("先进", 距离, 角度)
            振刀描述类型 = "先进"
        else  -- 默认为站立
            成功, 匹配索引 = 匹配逻辑("站立", 距离, 角度)
            振刀描述类型 = "站立"
        end
		--print(振刀描述类型,匹配索引)
        if 成功 then
            -- 检查触发武器
            local 触发武器配置 = 缓存[振刀描述类型 .. "_触发武器"][匹配索引]
            local 触发, 触发索引 = 招式库.是否无触发武器(触发武器配置, 本人武器类型)
            if not 触发 then
                local 配置 = {
                    振刀延迟 = 缓存[振刀描述类型 .. "_振刀延迟"][匹配索引],
                    振刀方式 = 缓存[振刀描述类型 .. "_振刀方式"][匹配索引],
                    执行次数 = 缓存[振刀描述类型 .. "_执行次数"][匹配索引],
                    执行延迟 = 缓存[振刀描述类型 .. "_执行延迟"][匹配索引]
                }
                km.延迟(配置.振刀延迟)
                振刀方式 = 配置.振刀方式
                执行次数 = 配置.执行次数
                执行延迟 = 配置.执行延迟
                招式描述 = 缓存.描述
                处理 = true
                return 处理, 振刀方式, 执行次数, 执行延迟, 招式描述, 振刀描述类型
            end
        end
    end
    return 处理, 振刀方式, 执行次数, 执行延迟, 招式描述, 振刀描述类型
end




local function 振刀功能(武器类型,招式名,距离,角度,本人武器类型,蓄力,状态)
	
	local 振刀方式=0
	local 执行次数=1
	local 执行延迟=0
	local 处理=false
	local 描述=""
	local 是蓄转振=false
	local 是一点零=false
	local 振刀描述类型=""
	if((状态==20 or 状态==11) and 蓄力<0.499) then 是蓄转振=true end--是蓄转振
	左右键状态={左=km.是否按下(1),右=km.是否按下(2)}
	if 是蓄转振 then
		if (本人.出刀==12 and 本人.蓄力>=0.12 or (左右键状态.左 or 左右键状态.右)==false) then
			是蓄转振=false
		end
	end
	
	if(蓄力>=0.499 and 状态==20 and (左右键状态.左 or 左右键状态.右)) then 是一点零=true end --进了1.0了
	--print(武器类型,招式名,距离,角度,本人武器类型,是一点零,是蓄转振)
	if(武器库.是近战武器(武器类型)) then 
		--print("传参数前 ",是一点零,是蓄转振,蓄力,招式名)
		处理,振刀方式,执行次数,执行延迟,招式描述,振刀描述类型=查询缓存(武器类型,招式名,距离,角度,本人武器类型,是一点零,是蓄转振)
	end
	return 处理,振刀方式,执行次数,执行延迟,招式描述,振刀描述类型
end

function 是不可振刀状态(对象)
	if 对象.状态==31 or 对象.状态==51 or
		对象.状态==30 or 对象.振刀==1 or 对象.状态==53 or 对象.状态==35
			then return true
	end
	return false
end
function OnTick()
	--这是数据回调，当器灵得到游戏数据时,会调用此方法
	--如果要在绘制回调里使用对象信息表,必须存到本地，否则绘制回调不允许访问
	local 当前玩家状态 = {}
	--local 振刀冷却=false
	对象数量=#玩家信息
	玩家=玩家信息
	本人=本人信息
	--print(左右键状态.左)
	if 是不可振刀状态(本人) then return end--已经振不了了
	if(开启振刀) then
			for index, 对象 in pairs(玩家) do
			--print(对象.招式)
				local 距离=getdis({本人.x,本人.y,本人.z}, {对象.x,对象.y,对象.z})
				--print(距离)
				if(距离<=处理距离) then
					local 地址 = 对象.地址
					-- 如果状态机中不存在此玩家，初始化他们的状态
					if not 玩家状态机[地址] then
						玩家状态机[地址] = {
							出刀状态 = 对象.出刀,
							出刀处理 = false,
							磐石状态 = 对象.状态,
							磐石处理 = false
						}
					end
					-- 更新当前玩家状态
					当前玩家状态[地址] = true
					-- 更新和处理状态逻辑
					
					
					local 敌人武器=对象.武器类型
					
					if(玩家状态机[地址].磐石状态==6 and (敌人武器==武器库.武器_斩马刀 or 敌人武器==武器库.武器_阔刀) and 对象.状态==20) then
						玩家状态机[地址].磐石处理=false
					end
					--阔刀左磐需要特殊处理,不然振不到的，预留状态机接口，等空了写
					玩家状态机[地址].磐石状态=对象.状态
					玩家状态机[地址].出刀状态=对象.出刀
					if(玩家状态机[地址].出刀状态~=12 or 本人.状态==31) then--出刀,处决状态
						玩家状态机[地址].出刀处理=false
					end
					
					if(判断角度({x=本人.pitch,y=本人.roll,z=本人.yaw},{x=本人.x,y=本人.z,z=本人.y},{x=对象.x,y=对象.z,z=对象.y})<=不振角度) then
						if (玩家状态机[地址].出刀处理==false) then
							if(本人.武器类型~=武器库.武器_空手) then 
								if(对象.出刀==12) then
									--print("start time: ", km.获取时间())  -- 输出：YYYY-MM-DD HH:MM:SS
									--local 自己朝对象角度=判断角度({x=本人.pitch,y=本人.roll,z=本人.yaw},{x=本人.x,y=本人.z,z=本人.y},{x=对象.x,y=对象.z,z=对象.y})
									local 角度=判断角度({x=对象.pitch,y=对象.roll,z=对象.yaw},{x=对象.x,y=对象.z,z=对象.y},{x=本人.x,y=本人.z,z=本人.y})
									
									local 处理,振刀方式,执行次数,执行延迟,招式描述,振刀描述类型=振刀功能(敌人武器,对象.招式,距离,角度,本人.武器类型,本人.蓄力,本人.状态)
									
									if 处理 then
										玩家状态机[地址].出刀处理=true
										for i=1,执行次数 do
											振刀方式()
											km.延迟(执行延迟)
										end
										local 失败描述=""
										if 本人.出刀==12 and 本人.蓄力>0.12 then
											失败描述="失败 原因:自己出刀僵直"
										end
										if 本人.状态==6 or 本人.僵直时间>=0.5 then
											失败描述="失败 原因:受击无法振刀"--这个不一定，因为有时候有僵直也能振
										end
										print("[振刀事件] 类型 "..振刀描述类型.." 招式"..招式描述.." 距离:"..tostring(距离).." 触发角度"..tostring(角度).." 执行延迟"..tostring(执行延迟))
										振刀冷却=true
										if 失败描述~="" then
											--振刀冷却=false--失败了，可以尝试再次振
											print(失败描述)
										end
										
									end
								end
							end
						end
					end
				end
			end
		-- 移除已经不存在的玩家
		for 地址 in pairs(玩家状态机) do
			if not 当前玩家状态[地址] then
				玩家状态机[地址] = nil
			end
		end
	end
	
	
end