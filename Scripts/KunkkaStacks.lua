require("libs.Utils")
-- SCRIPT SETTINGS
sleep = 50
hotkey = 0x4F
x0,y0=5,50      -- gui pos
dude1=nil

start_time = 49                         -- game time seconds when start to stack (from wait point)

myFont = drawMgr:CreateFont("CounterHeroo","Arial",18,30)
StatusText1 = drawMgr:CreateText(x0,y0,0xFFFFFFFF,"Kunkka Creep stack on.",myFont);
StatusText2 = drawMgr:CreateText(x0,y0+20,0xFF0000FF,".",myFont);

--coils = nil

--StatusText2.visible = 1
--GLOBALS
hotkeyon = 1
--0=off
--1=stack
--2=attack


melocation = nil
dude1route =nil
dude2route =nil
dude3route =nil

route = nil
creep = nil
do_stack = false
sleeptick = nil
msg = nil -- msg = { TEXT, TICK, TIME, SIZE, COLOR, X, Y }
order_tick = nil
anc = nil
pressed = false
stack_n = 0
currentSelection = nil
--count = 1
dude1=nil
dude2=nil
dude3=nil
local p = Vector(1633,-3577,256)
function Tick( tick )
    if not client.connected or client.loading or client.console then return end
    local me = entityList:GetMyHero()
    if not me then return end
    if me.classId ~= CDOTA_Unit_Hero_Kunkka then
    script:Disable()
    StatusText1.text=""
    end
    if sleepTick and sleepTick > tick then return end
    if IsKeyDown(hotkey) then
        if hotkeyon==1 then
            hotkeyon=0
            StatusText1.text="Kunkka Creep stack off."
            sleepTick = GetTick() + 300
        else
            hotkeyon = 1
            StatusText1.text="Kunkka Creep stack on."
            sleepTick = GetTick() + 300
        end
    end --1633 -3577 256
--print(me.team)

	
	if me.team ==2 then
		p = Vector(1633,-3577,256)
	else
		p = Vector(1169,3296,256)
	end

    

    if hotkeyon==1 then
    	--print(me.position.x,me.position.y,me.position.z)
		--print(client.mousePosition)
        --if math.ceil(client.gameTime % 60) == 30 then 

		if math.ceil(client.gameTime % 60) == 47 then 
			--if GetDistance2D(me,p) > 1500 then
				--local d = Vector(0 , 0, 0)
	            StatusText2.text="Go to creep spawn position."
	            if e==nil then
					e = Effect(p,  "range_display")

					e:SetVector(0,p)
					e:SetVector(1, Vector( 1500, 0, 0) )    

					e:SetVector(0,p)
				end
				--else
			--	e=nil

			--end

		end

		--if GetDistance2D(me,p) < 1500 then

        if client.gameTime % 60 >= 57.35 - (client.latency * 1/1000) and client.gameTime % 60 <= 58 then 
        	--local p = Vector(1633,-3577,256)
        	StatusText2.text=""
        	e=nil
   			if GetDistance2D(me,p) < 1500 then

   				
   				--collectgarbage("collect")
        	--print("@32332")

	            if me:GetAbility(1) and me:GetAbility(1).state == -1 then
	            	
	            	--local p = Vector(-1080,-4086,128)
					--me:CastAbility(ember_spirit_fire_remnant,p)
					me:CastAbility(me:GetAbility(1),p)
					sleepTick = GetTick() + 3000
				end
			end
        end

        if math.ceil(client.gameTime % 60) == 30 then 
        	
        end



    end
--sleepTick = GetTick() + 30
end

function isPosEqual(v1, v2, d)
    return (v1-v2).length <= d
end


script:RegisterEvent(EVENT_TICK, Tick)