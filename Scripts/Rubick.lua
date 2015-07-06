--<<Ultimates will automatically be stolen when the enemy casts them if you are in range.>>
require("libs.Utils")

local hero = {} local ls = {} local ult = {} local icon = {}
local BM = {124,102, 80} local range = nil

local xx = client.screenSize.x/1.33 local yy = client.screenSize.y/100

function Tick( tick )

        if not client.connected or client.loading or client.console then return	end	

		local me = entityList:GetMyHero()	

		if not me then
			return 
		end

		if me.classId ~= CDOTA_Unit_Hero_Rubick then
			script:Disable()
		else			
			if me:FindItem("item_ultimate_scepter") then
				range = 1600
			else 
				range = 1000
			end

			local enemies = entityList:FindEntities({type=LuaEntity.TYPE_HERO,illusion = false,team = (5-me.team)})
			table.sort( enemies, function (a,b) return a.playerId < b.playerId end )

			local steal = me:GetAbility(7)
			local stealing = me:GetAbility(5)

			for i =1,#enemies do
				local v = enemies[i]
				for d = 4,8 do
					if not hero[i] then					
						local spell = v:GetAbility(d)
						if spell ~= nil and spell.abilityType == 1 then						
							ult[i] = spell.name
						end
					else 
						ult[i] = nil
					end
				end

				if v.alive and v.health > 0 then

					if v.visible then
						local ability = v.abilities
						for g,h in ipairs(ability) do
							local spell = v:GetAbility(g)
							if spell ~= nil and spell.cd > 0 then
								 if v.name ~= "npc_dota_hero_brewmaster" then
									if math.ceil(spell.cd) ==  math.ceil(spell:GetCooldown(spell.level)) then										
										ls[i] = v:GetAbility(g).name
									end
								elseif v.name == "npc_dota_hero_brewmaster" then								
									if math.ceil(spell.cd) == BM[spell.level] then
										ls[i] = spell.name
									end									
								end
							end								
						end
					else 
						ls[i] = nil
					end

					if SleepCheck() and steal.state == -1 and me:CanCast() and not me:IsChanneling() then
						if v.visible then
							if not hero[i] then
								if GetDistance2D(v,me) < range then
									for d = 4,8 do									
										local spell = v:GetAbility(d)
										if spell ~= nil and spell.abilityType == 1 then
											if ls[i] == spell.name and spell.name ~= stealing.name then												
												if not v:IsLinkensProtected() then
													if stealing.name ~= ult[i] and stealing.cd ~= 0 then													
														me:CastAbility(steal,v)
														Sleep(200)
													elseif stealing.abilityType ~= 1 then
														me:CastAbility(steal,v)
														Sleep(200)
													end
												end
											end
										end
									end
								end
							end
						end
					end	
				end

				if not icon[i] then icon[i] = {}
					icon[i].board = drawMgr:CreateRect(xx-6+i*27,yy-3,27,23,0x000000FF) 
					icon[i].mini = drawMgr:CreateRect(xx-2+i*27,yy,16,16,0x000000FF)					
				end
			
				if not hero[i] then
					icon[i].mini.textureId = drawMgr:GetTextureId("NyanUI/miniheroes/"..v.name:gsub("npc_dota_hero_",""))				
				else
					icon[i].mini.textureId = drawMgr:GetTextureId("NyanUI/spellicons/doom_bringer_empty1")
				end	

			end		
		end
end

function Key(msg,code)

	if client.chat then return end

	for i = 1,5 do
		if IsMouseOnButton(xx-2+i*27,yy,16,16) then
			if msg == LBUTTON_DOWN and hero[i] == nil then
				hero[i] = i
			elseif msg == LBUTTON_DOWN and hero[i] ~= nil then
				hero[i] = nil
			end
		end
	end	

end

function IsMouseOnButton(x,y,h,w)
	local mx = client.mouseScreenPosition.x
	local my = client.mouseScreenPosition.y
	return mx > x and mx <= x + w and my > y and my <= y + h
end

function GetSpecial(spell,name,lvl)
	local specials = spell.specials
	for _,v in ipairs(specials) do
		if v.name == name then
			return v:GetData(lvl)
		else
			return 0
		end
	end
end

function GameClose()
	hero = {} ls = {} ult = {} icon = {}
	collectgarbage("collect")
end

script:RegisterEvent(EVENT_KEY,Key)
script:RegisterEvent(EVENT_CLOSE, GameClose)
script:RegisterEvent(EVENT_TICK,Tick)
