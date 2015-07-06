--<<Auto use forcestaff on enemy heroes>>
--===By Blaxpirit===--

require("libs.Utils")
require("libs.ScriptConfig")
require("libs.TargetFind")

config = ScriptConfig.new()
config:SetParameter("Active", "H", config.TYPE_HOTKEY)
config:SetParameter("UseForce", "T", config.TYPE_HOTKEY)
config:Load()

local toggleKey = config.Active
local forceKey = config.UseForce

local monitor     = client.screenSize.x/1600
local x_ratio = client.screenSize.x/1600
local F11 = drawMgr:CreateFont("F11","Tahoma",20*monitor,878*monitor)
local F14 = drawMgr:CreateFont("F11","Tahoma",14*x_ratio,550*x_ratio)
local statusText = drawMgr:CreateText(3*x_ratio,107*x_ratio,-1,"(" .. string.char(toggleKey) .. ") Auto Force: On",F11) statusText.visible = false
local victimText = drawMgr:CreateText(-60*x_ratio,-77*x_ratio,0x5279FFff,"",F14) victimText.visible = false

local reg = false
local active = true

local sleepTick = nil

local effect = nil

function Key(msg,code)
	if not PlayingGame() or client.chat then return end
	
	if IsKeyDown(toggleKey) then
		active = not active
		if active then
			statusText.text = "(" .. string.char(toggleKey) .. ") Auto Force: On"
		else
			statusText.text = "(" .. string.char(toggleKey) .. ") Auto Force: Off"
		end
	end
	
	if active then
		if msg == KEY_DOWN then
			local me = entityList:GetMyHero()
			local forcestaff = me:FindItem("item_force_staff")
			if code == forceKey and forcestaff and forcestaff:CanBeCasted() and not effect then
				effect = Effect(me,"range_display")
				effect:SetVector(1,Vector(forcestaff.castRange,0,0))
			end
		end	
		if msg == KEY_UP then
			if code == forceKey and effect then
				RemoveEffect()
			end
		end
	end
end

function Tick(tick)
	if not PlayingGame() then return end
	if sleepTick and sleepTick > tick then return end
	
	local me = entityList:GetMyHero()
	
	if active then
		local forcestaff = me:FindItem("item_force_staff")
		if forcestaff and forcestaff:CanBeCasted() then
			statusText.visible = true
			local items = me:CanUseItems()
			local chanel = me:IsChanneling()
			if me.alive and items and not chanel then
				local victim = targetFind:GetClosestToMouse(100)
				if victim and not victim.visible then victim = nil end
				if victim and victim.alive and victim.visible then
					local IV  = victim:IsInvul()
					local MI  = victim:IsMagicImmune()
					local LS  = victim:IsLinkensProtected()
					if not (IV or MI or LS) then
						if GetDistance2D(me,victim) <= forcestaff.castRange then
							victimText.visible = true
							victimText.text = "Use the Force, Luke!"
							victimText.entity = victim
							if victim.healthbarOffset then
								victimText.entityPosition = Vector(0,0,victim.healthbarOffset)
							end	
							if IsKeyDown(forceKey) and not client.chat then 
								if victim:GetTurnTime(me) == 0 then
									me:CastAbility(forcestaff,victim)
									sleepTick = GetTick() + 250
								end
							end
						elseif victimText.visible then
							victimText.visible = false
						end
					end
				elseif victimText.visible then
					victimText.visible = false
				end	
			end
		elseif victimText and victimText.visible then
			statusText.visible = false
		end
	end
end

function RemoveEffect()
	effect = nil
	collectgarbage("collect")
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then 
			script:Disable()
		else
			reg = true
			script:RegisterEvent(EVENT_KEY,Key)
			script:RegisterEvent(EVENT_TICK,Tick)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	statusText.visible = false
	victimText.visible = false
	sleepTick = nil
	effect = nil
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Key)
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
