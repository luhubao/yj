local 武器库 = require("武器库")
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
local 可抓蓄武器={
	匕首=106,
	太刀=102,
	双刀=118,
	双截棍=116,
	棍=120,
	斩马刀=119,
	双戟=121,
	扇子=122,
	横刀=123,
	拳刃=124
}

local function 武器是否可以抓蓄力闪()
	for index, 武器 in pairs(可抓蓄武器) do
		if 本人信息.武器类型==武器 then return true end
	end
	return false
end
local 玩家状态机 = {}
local 操作时间=0.0
local 抓受击=true
local 抓跳A=true
local 抓白=true
local 抓振刀后摇=true
local 抓对面先进=true
local 抓蓄力闪=true
local 上次放蓄时间=0
function OnDraw()
	--你可以看作是update，每一帧处理一次
	--print("在跑")
	--矩阵=matrix--只可以在这里使用matrix
	ui.Begin("自动放蓄管理")
	抓受击=ui.Checkbox("抓受击",抓受击)
	抓跳A=ui.Checkbox("抓跳A",抓跳A)
	抓白=ui.Checkbox("抓白刀",抓白)
	抓蓄力闪=ui.Checkbox("抓蓄闪",抓蓄力闪)
	抓振刀后摇=ui.Checkbox("抓振刀后摇",抓振刀后摇)
	抓对面先进=ui.Checkbox("抓对面先进(猛蓄猛出逻辑)",抓对面先进)
	ui.Text("猛蓄猛出不适合拿斩马刀和阔刀")
	ui.End()
end
function OnTick()
	--这是数据回调，当器灵得到游戏数据时,会调用此方法
	--如果要在绘制回调里使用对象信息表,必须存到本地，否则绘制回调不允许访问
	local 尝试放=false
	local 有人振刀=false
	local 当前玩家状态 = {}
	if(本人信息.状态==31 or 本人信息.状态==30) then return end
	
	if(本人信息.蓄力>=0.495 and (本人信息.状态==20) and 本人信息.出刀==10) then 
		for index, 对象 in pairs(玩家信息) do
			local 地址 = 对象.地址
			-- 如果状态机中不存在此玩家，初始化他们的状态
			if not 玩家状态机[地址] then
				玩家状态机[地址] = {
					振刀状态 = 对象.振刀,
					--振刀处理 = false,
					振刀结束状态=false,
					振刀结束时间=km.获取时间();
				}
			end
			-- 更新当前玩家状态
			当前玩家状态[地址] = true
			-- 更新和处理状态逻辑
			if 玩家状态机[地址].振刀状态==1 and 对象.振刀==0 then
				玩家状态机[地址].振刀结束状态=true
				玩家状态机[地址].振刀结束时间=km.获取时间();
			elseif 对象.振刀==0 or km.获取时间()-玩家状态机[地址].振刀结束时间>300 then
				玩家状态机[地址].振刀结束状态=false
			end
			玩家状态机[地址].振刀状态=对象.振刀
			if(km.获取时间()-上次放蓄时间<500) then return end 
			local 距离=getdis({本人信息.x,本人信息.y,本人信息.z}, {对象.x,对象.y,对象.z})
			if(距离<=5) then
				自己至敌人角度=判断角度({x=本人信息.pitch,y=本人信息.roll,z=本人信息.yaw},{x=本人信息.x,y=本人信息.z,z=本人信息.y},{x=对象.x,y=对象.z,z=对象.y})
				敌人至自己角度=判断角度({x=对象.pitch,y=对象.roll,z=对象.yaw},{x=对象.x,y=对象.z,z=对象.y},{x=本人信息.x,y=本人信息.z,z=本人信息.y})
				if 自己至敌人角度<=60 then--猛蓄猛出逻辑
					if(抓对面先进 and 对象.蓄力>=0.5 and 对象.状态==20 and 对象.出刀==10 and 对象.振刀==0) then--抓后进无法振刀
						print("抓对面先进")
						尝试放=true
						goto continue
						--print(本人信息.蓄力,本人信息.状态,本人信息.出刀)
					end
					if(抓振刀后摇 and 玩家状态机[地址].振刀结束状态) then --抓振刀后摇
					--玩家状态机[地址].振刀处理=true
						print("振刀后摇")
						玩家状态机[地址].振刀结束状态=false
						尝试放=true
						goto continue
					end
					if 抓受击 and 对象.僵直时间>0.6 then --抓僵直
						print("抓僵直")
						尝试放=true
						goto continue
					end
					if 抓蓄力闪 and 武器是否可以抓蓄力闪() and 距离<2.0 and (对象.哈希 == 3206223861 or 对象.哈希 == 3334521573 or 对象.哈希 == 193657409 or 对象.哈希 == 616853143) then 
						print("抓蓄力闪",距离)
						尝试放=true
						goto continue
					end
					if 抓跳A and km.寻找文本(对象.招式,"jump_attack") and 对象.出刀==12 and 距离<3.0 then
						print("跳A",距离)
						尝试放=true
						goto continue
					end
					if 抓白 and 对象.出刀==12 and 对象.蓄力>0.1 and 对象.蓄力<0.48 and 距离<3.0 then
						print("抓白",距离,对象.蓄力)
						尝试放=true
						goto continue
					end
				end
				if 敌人至自己角度<=60 then
					if(对象.蓄力<=0.45 or 对象.振刀==1 or 对象.状态==5) then--标记本次有人振,0.45可以转振 状态=5代表能直接站振
						有人振刀=true
						goto continue
					end
				end
				
			end
			::continue::
		end
		
		-- 移除已经不存在的玩家
		for 地址 in pairs(玩家状态机) do
			if not 当前玩家状态[地址] then
				玩家状态机[地址] = nil
			end
		end
		
		if 尝试放 and 有人振刀==false then
			if(km.是否按下(1))then
				km.屏蔽左键(1)
				km.延迟(2)
				km.左键(0)
				km.延迟(2)
				km.屏蔽左键(0)
				print("释放左蓄")
			elseif(km.是否按下(2))then
				km.屏蔽右键(1)
				km.延迟(2)
				km.左键(0)
				km.延迟(2)
				km.屏蔽右键(0)
				print("释放右蓄")
			end
			上次放蓄时间=km.获取时间();
		end
	end
end