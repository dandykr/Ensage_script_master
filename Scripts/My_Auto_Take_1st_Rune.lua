--<<Auto takes runes>>
--===By Blaxpirit===--

require("libs.Utils")
require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("Active", "H", config.TYPE_HOTKEY)
config:Load()

local toggleKey = config.Active

local reg = false
local active = true
local monitor = client.screenSize.x/1600
local F11 = drawMgr:CreateFont("F11","Tahoma",11*monitor,550*monitor) 
local statusText = drawMgr:CreateText(3*monitor,96*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Rune: On",F11) statusText.visible = true

function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if IsKeyDown(toggleKey) then
		active = not active
		if active then
			statusText.text = "(" .. string.char(toggleKey) .. ") Auto Rune: On"
		else
			statusText.text = "(" .. string.char(toggleKey) .. ") Auto Rune: Off"
		end
	end
end

function Tick(tick)
	if not PlayingGame() then return end

	if active and me.alive and not me:IsChanneling() then
		local runes = entityList:GetEntities(function (ent) return ent.classId==CDOTA_Item_Rune and GetDistance2D(ent,me) < 150 end)[1]
		if runes then
			mp:TakeRune(runes)
			mp:Move(client.mousePosition)
		end
	end
end

function Load()
	if PlayingGame() then
		me = entityList:GetMyHero()
		mp = entityList:GetMyPlayer()
		if not me then 
			script:Disable()
		else
			reg = true
			statusText.visible = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	statusText.visible = false
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
