print("博弈脚本1.0");
--第一次加载初始化
local 上次玩家信息={};
local 上次本人信息={};
local 鼠标下侧键=5;
local 蹲下了="_crouch_idle_01";
local 站立="_idle_01";
local 左僵直="hurt_stand_heavy";
local 左僵直2="stand_light_right";
local 右僵直="hurt_stand_light";
local 升龙="fly_back_01";
local 升龙僵直="_fly_";
print("初始化")
local function getdis(localpos, pos)
    if not localpos or not pos then
        print("Error: Invalid input positions.")
        return 0
    end
    local temp = {localpos[1] - pos[1], localpos[2] - pos[2], localpos[3] - pos[3]}
    return math.sqrt(temp[1]*temp[1] + temp[2]*temp[2] + temp[3]*temp[3])
end

local 上次操作时间 = {
	切刀 = 0,
	出刀 = 0,
	升龙 = 0,
	长闪A=0,
	钩锁=0,
	CCA=0,
	闪避=0,
	捏蓄=0,
	钩锁撞到=0
}


function 状态更新()
	local 当前时间=km.获取时间();
	--print(本人信息.武器槽)
	if 上次本人信息.武器槽~=本人信息.武器槽 then
		上次操作时间.切刀=当前时间;
	end
	if 上次本人信息.出刀==10 and 本人信息.出刀==12 then
		上次操作时间.出刀=当前时间;
	end
	
	
	--状态更新完，再次储存作为下一帧数据
	上次玩家信息=玩家信息;
	上次本人信息=本人信息;
end
function 寻找目标(目标)
	for index, 对象 in pairs(玩家信息) do
		if (目标.地址==对象.地址) then 
		目标=对象 
		break
		end
	end
	return 目标
end

function 目标选择器()
	local 最小距离=0.0;
	local 最近对象={};
	for index, 对象 in pairs(玩家信息) do
		local 当前距离=getdis({本人信息.x,本人信息.z,本人信息.y},{对象.x,对象.z,对象.y});
		if 最小距离==0.0 then
			最小距离=当前距离;
			最近对象=对象;
		elseif 当前距离<最小距离 then 
			最小距离=当前距离;
			最近对象=对象;
		end
	end
	--print(最小距离)
	return 最近对象;
end

function CCA()
	
	if km.获取时间()-上次操作时间.闪避<200 then km.延迟(100) end
	km.按下(6);
	local 超时=km.获取时间();
	print("执行CCA"..tostring(超时));
	local 蹲下=false;
	while (true)
	do
		数据.更新();
		if (km.寻找文本(本人信息.招式,蹲下了) or km.获取时间()-超时>400) then
			蹲下=true;
			print("蹲下成功了")
			break;
		end
		--print("循环结束")
	end
	if 蹲下==false then km.弹起(6); return end  
	--print("循环结束")
	km.弹起(6);
	km.延迟(3);
	km.按下(6);
	km.延迟(3);
	km.弹起(6);
	超时=km.获取时间();
	local 站起来了=false;
	while true do
		数据.更新();
		if ((km.寻找文本(本人信息.招式,蹲下了)==false and km.寻找文本(本人信息.招式,站立)) or km.获取时间()-超时>200) then
			站起来了=true;
			print("站起来了")
			break;
		end
	end
	if 站起来了==false then return end
	--km.延迟(130);
	km.左键(1);
	km.延迟(5);
	km.左键(0);
end
function 升龙()
	print("执行升龙",km.获取时间())
	km.按下(6);
	km.延迟(1);
	km.弹起(6);
	--km.按下(0x51);
	--km.弹起(0x51);
	km.右键(1);
	--km.按下(0x51);
	--km.弹起(0x51);
	km.延迟(5);
	km.右键(0);--等待后续
	
	
end
function 长闪A()
	print("执行长闪A")
	km.按下(225);
	km.延迟(150);
	km.左键(1);
	km.延迟(5);
	km.左键(0);
	km.延迟(50);
	km.弹起(225);
end
function A()
	print("执行A")
	km.左键(1);
	km.延迟(50);
	km.左键(0);
end
function 钩锁百烈(目标)
	print("执行钩锁",km.获取时间());
	km.按下(0x14);
	km.延迟(1);
	km.弹起(0x14);
	km.延迟(1);
	km.右键(1);
	local 超时=km.获取时间()+2000;
	km.延迟(250);
	数据.更新();
	目标=寻找目标(目标);
	
	if km.寻找文本(目标.招式,升龙僵直)==false then km.右键(0) print(本人信息.蓄力,目标.招式) return end
	while(true)
	do
		数据.更新();
		目标=寻找目标(目标);
		if 超时- km.获取时间() < 0 then km.右键(0) break end
		if 本人信息.蓄力>=0.495 then km.右键(0) break end 
		--print(超时- km.获取时间(),本人信息.蓄力,目标.招式)
		km.延迟(1);
		--print(超时- km.获取时间(),本人信息.蓄力,目标.招式)
	end
	--print(超时- km.获取时间(),本人信息.蓄力)
end

local 上次僵直动作=0.0;


function 太刀横刀博弈()
	if 本人信息.武器类型==102 or 本人信息.武器类型==123 then
		--print("选择目标")
	--判断一下武器
		--判断最近的人作为目标
		local 目标=目标选择器();
		if 目标=={} then return end;--没目标
		
		
		if 目标.僵直时间>0 and 上次僵直动作~=目标.招式 then
				上次僵直动作=目标.招式
				print("僵直动作 "..目标.招式.."僵直时间 "..tostring(目标.僵直时间))
			end
		if 本人信息.僵直时间==0 and 本人信息.出刀==10 and km.是否按下(鼠标下侧键) then
			local 当前时间=km.获取时间();
			if (km.寻找文本(目标.招式,站立) or 是否在跑动(目标) )and 当前时间-上次操作时间.出刀 > 800 then
				A();
				上次操作时间.出刀=当前时间;
				return;
			end
		
			--print("僵直动作 "..目标.招式.."僵直时间 "..tostring(目标.僵直时间))
			if 目标.僵直时间>0 and 上次僵直动作~=目标.招式 then
				上次僵直动作=目标.招式
				print("僵直动作 "..目标.招式.."僵直时间 "..tostring(目标.僵直时间))
			end
			
			
			--判断是否可以执行CCA
			if 目标.僵直时间>=0.8 and 目标.僵直时间<=1.3 and
			(km.寻找文本(目标.招式,左僵直) or km.寻找文本(目标.招式,左僵直2)) and
			当前时间-上次操作时间.CCA > 1000 and 当前时间-上次操作时间.出刀>400 then
				上次操作时间.CCA=当前时间;
				上次操作时间.出刀=当前时间;
				CCA();
				--print(当前时间);
				
				--return;
				
			end
			----判断是否可以执行升龙
			if 目标.僵直时间>0.5 and 目标.僵直时间<0.8 and km.寻找文本(目标.招式,左僵直) and 当前时间-上次操作时间.升龙 > 1000 and 当前时间-上次操作时间.CCA > 600 and 当前时间-上次操作时间.出刀 > 300 then
				升龙();
				km.延迟(350);
				钩锁百烈(目标);
				上次操作时间.出刀=当前时间;
				上次操作时间.升龙=当前时间;
			end
				
			
			
			if	目标.僵直时间>0.72 and 目标.僵直时间<1.35 and km.寻找文本(目标.招式,升龙僵直) and 当前时间-上次操作时间.钩锁>2000 then
				
				上次操作时间.钩锁=当前时间;
				return;
			end
			
			--判断是否可以执行钩锁
			--判断是否可以执行跳A
		end
	end
end


function 是否攻击中(目标)
	if km.寻找文本(目标.招式,"_sprint_attack_") and km.寻找文本(目标.招式,"_recover") then return true else return false end
end
function 是否在跑动(目标)
	if (km.寻找文本(目标.招式,"_sprint_") or km.寻找文本(目标.招式,"_dodge_") or
	km.寻找文本(目标.招式,"_spiritsman_") or km.寻找文本(目标.招式,"_run_")) and 是否攻击中(目标)==false then return true else return false end
end

function OnTick()
	--print("僵直动作 "..本人信息.招式)
	--print("当前武器类型:"..tostring(本人信息.武器类型))
	
	--数据.更新();
	if 上次玩家信息 =={} then 上次玩家信息=玩家信息 end;
	if 上次本人信息 =={} then 上次本人信息=本人信息 end;
	
	状态更新();
	
	--
	--第一套简单抓僵直后的连招
	
	
	
	太刀横刀博弈();--钩锁百烈
	
	
end
