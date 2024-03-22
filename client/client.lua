RegisterNetEvent('hud:client:updategetPlayers', function(newPlayers)
	SendNUIMessage { action = "setValue", divId = "players", value = newPlayers .. "/64" }
end)

RegisterNetEvent('hud:client:updateID', function(newId)
	SendNUIMessage { action = "setValue", divId = "info-id", value = "ID:" .. newId }
end)

RegisterNetEvent('hud:client:updateMoney', function(newBani)
	SendNUIMessage { action = "setValue", divId = "info-cash", value = "$" .. newBani }
end)

RegisterNetEvent('hud:client:updateMoneyBank', function(newBBani)
	SendNUIMessage { action = "setValue", divId = "info-bank", value = "$" .. newBBani }
end)

local PED_ID;
local PLAYER_ID;
local IS_HUD_VISIBLE = true
local isHudHidden = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if not HasPedLoaded() then
			PED_ID = PlayerPedId()
			PLAYER_ID = PlayerId()
		else
			Citizen.Wait(100)
		end
	end
end)

function HasPedLoaded()
	if PED_ID == PlayerPedId() then return true else return false end
end

RegisterNetEvent("vrp_status")
AddEventHandler("vrp_status", function(status)
	myhunger = 100 - status.hunger
	mythirst = 100 - status.thirst
end)


function set_hud_vis(show)
	IS_HUD_VISIBLE = show
	SendNUIMessage({
		action = "hudtick",
		show = not show,
		health = GetEntityHealth(PED_ID),
		armor = GetPedArmour(PED_ID),
		thirst = mythirst,
		hunger = myhunger,
		stamina = (100 - GetPlayerSprintStaminaRemaining(PLAYER_ID)),
		inwater = IsPedSwimmingUnderWater(PED_ID),
		oxygen = GetPlayerUnderwaterTimeRemaining(PLAYER_ID),
	})
end

RegisterNetEvent("h2o_hud:set_vis")
AddEventHandler("h2o_hud:set_vis", function(show)
	set_hud_vis(show)
end)

Citizen.CreateThread(function()
	while true do
		if IS_HUD_VISIBLE then
			SendNUIMessage({
				action = "hudtick",
				show = IsPauseMenuActive(),
				health = GetEntityHealth(PED_ID),
				armor = GetPedArmour(PED_ID),
				thirst = mythirst,
				hunger = myhunger,
				stamina = (100 - GetPlayerSprintStaminaRemaining(PLAYER_ID)),
				inwater = IsPedSwimmingUnderWater(PED_ID),
				oxygen = GetPlayerUnderwaterTimeRemaining(PLAYER_ID),
			})
		end

		Citizen.Wait(550)
	end
end)

Citizen.CreateThread(function()
	RequestStreamedTextureDict("circlemap", false)
	while not HasStreamedTextureDictLoaded("circlemap") do
		Citizen.Wait(1)
	end

	local defaultAspectRatio = 1920 / 1080 -- Don't change this.
	local resolutionX, resolutionY = GetActiveScreenResolution()
	local aspectRatio = resolutionX / resolutionY
	local minimapOffsetX = 0
	local minimapOffsetY = -0.050
	if aspectRatio > defaultAspectRatio then
		minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
	end

	AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")
	AddReplaceTexture("platform:/textures/graphics", "radarmasklg", "circlemap", "radarmasklg")
	
	local cameraRotation = GetGameplayCamRot().z
	local maskRadius = 5.5
-- Calculate new mask position and size based on camera rotation
	local maskX = math.sin(math.rad(cameraRotation)) * maskRadius
	local maskY = math.cos(math.rad(cameraRotation)) * maskRadius


	SetMinimapComponentPosition("minimap", "C", "C", 0.002 + minimapOffsetX, -0.007 + minimapOffsetY, 0.1638, 0.183)
	SetMinimapComponentPosition("minimap_mask", "C", "C", 0.2 + minimapOffsetX, 0.0 + minimapOffsetY, 0.065, 0.20)
	SetMinimapComponentPosition('minimap_blur', 'C', 'C', -0.01 + minimapOffsetX, 0.065 + minimapOffsetY, 0.262, 0.300)
	SetBlipAlpha(GetNorthRadarBlip(), 0)

	local minimap = RequestScaleformMovie("minimap")
	SetRadarBigmapEnabled(true, false)
	Citizen.Wait(0)
	SetRadarBigmapEnabled(false, false)

	-- 1.0, 1.0 -> out of range
	SetHudComponentPosition(3, 1.0, 1.0)
	SetHudComponentPosition(4, 1.0, 1.0)
	SetHudComponentPosition(6, 1.0, 1.0)
	SetHudComponentPosition(7, 1.0, 1.0)
	SetHudComponentPosition(8, 1.0, 1.0)
	SetHudComponentPosition(9, 1.0, 1.0)
	SetHudComponentPosition(13, 1.0, 1.0)

	SetWeaponDamageModifier(GetHashKey("WEAPON_UNARMED"), 0.5)
	SetWeaponDamageModifier(GetHashKey("WEAPON_FLASHLIGHT"), 0.1)
	SetWeaponDamageModifier(GetHashKey("WEAPON_NIGHTSTICK"), 0.2)

	SetMapZoomDataLevel(0, 1.6, 0.9, 0.08, 0.0, 0.0)  -- Level 0
	SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0)  -- Level 1
	SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0)  -- Level 2
	SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0) -- Level 3
	SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0) -- Level 4
	SetRadarZoom(950)
	while true do
		SetRadarBigmapEnabled(false, false)
		SetRadarZoom(1100)
		Citizen.Wait(100)
	end
end)


local isInVehicle = false
local isEnteringVehicle = false

local currentVehicle = 0
local currentSeat = 0

Citizen.CreateThread(function()
	while true do
		InvalidateIdleCam()
		N_0x9e4cfff989258472() -- Disable the vehicle idle camera
		local ped = PlayerPedId()
		if not isInVehicle and not IsPlayerDead(PlayerId()) then
			if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not isEnteringVehicle then
				-- trying to enter a vehicle!
				local vehicle = GetVehiclePedIsTryingToEnter(ped)
				local seat = GetSeatPedIsTryingToEnter(ped)
				local netId = VehToNet(vehicle)
				isEnteringVehicle = true
				TriggerServerEvent('hudevents:enteringVehicle', vehicle, seat,
					GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), netId)
			elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and isEnteringVehicle then
				-- vehicle entering aborted
				TriggerServerEvent('hudevents:enteringAborted')
				isEnteringVehicle = false
			elseif IsPedInAnyVehicle(ped, false) then
				-- suddenly appeared in a vehicle, possible teleport
				isEnteringVehicle = false
				isInVehicle = true
				currentVehicle = GetVehiclePedIsUsing(ped)
				currentSeat = GetPedVehicleSeat(ped)
				local netId = VehToNet(currentVehicle)

				TriggerServerEvent('hudevents:enteredVehicle', currentVehicle, currentSeat,
					GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netId)
			end
		elseif isInVehicle then
			if not IsPedInAnyVehicle(ped, false) or IsPlayerDead(PlayerId()) then
				-- bye, vehicle
				local netId = VehToNet(currentVehicle)
				TriggerServerEvent('hudevents:leftVehicle', currentVehicle, currentSeat,
					GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netId)
				isInVehicle = false
				currentVehicle = 0
				currentSeat = 0
			end
		end
		Citizen.Wait(500)
	end
end)

function GetPedVehicleSeat(ped)
	local vehicle = GetVehiclePedIsIn(ped, false)
	for i = -2, GetVehicleMaxNumberOfPassengers(vehicle) do
		if (GetPedInVehicleSeat(vehicle, i) == ped) then return i end
	end
	return -2
end

local shouldSendNUIUpdate = false

local driftEnabled = false
local driftAvailable = true
local lastCarLS_r, lastCarLS_o, lastCarLS_h
local lastCarFuelAmount, lastCarHandbreak, lastCarBrakePressure, lastCarDrift, lastCarDriftAvailable
local lastCarIL, lastCarRPM, lastCarSpeed, lastCarGear
local lastCarEngineHealth

local currSpeed = 0.0
local prevVelocity = { x = 0.0, y = 0.0, z = 0.0 }
local seatbeltEjectSpeed = 45.0
local seatbeltEjectAccel = 100.0
local vehiclesCars = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 17, 18, 19, 20 };
displayKMH = 0
local nitro = 0

seat_belt = false

local function DisableVehicleExit()
	while seat_belt do
		Wait(0)
		DisableControlAction(0, 75, true)
	end
end

RegisterNetEvent("hudevents:leftVehicle")
AddEventHandler('hudevents:leftVehicle', function(currentVehicle, currentSeat, vehicle_name, net_id)
	isInVehicle = false
	driftEnabled = false
	DisableDrift(currentVehicle)
	if not isHudHidden then
		isHudHidden = true

		SendNUIMessage({
			action = "speedometertick",
			show = isHudHidden
		})
	end
end)

RegisterNetEvent("hudevents:enteredVehicle")
AddEventHandler('hudevents:enteredVehicle', function(currentVehicle, currentSeat, vehicle_name, net_id)
	isInVehicle = true
	SetPedConfigFlag(PlayerPedId(), 32, true)
	seat_belt = false

	if isHudHidden then
		isHudHidden = false
		SendNUIMessage({
			action = "speedometertick",
			show = isHudHidden
		})
	end

	while isInVehicle do
		Wait(50)

		if not isHudHidden then
			if IsVehicleEngineOn(currentVehicle) then
				local carRPM = GetVehicleCurrentRpm(currentVehicle)

				local multiplierUnit = 2.8

				if Config.Unit == "KMH" then
					multiplierUnit = 3.6
				end

				local carEngineHealth = math.floor((GetVehicleEngineHealth(currentVehicle) / 1000) * 100)
				local carSpeed = math.floor(GetEntitySpeed(currentVehicle) * multiplierUnit)
				local carGear = GetVehicleCurrentGear(currentVehicle)
				local carDrift = driftEnabled
				local carHandbrake = GetVehicleHandbrake(currentVehicle)
				local carBrakePressure = GetVehicleWheelBrakePressure(currentVehicle, 0)
				local fuelamount = GetVehicleFuelLevel(currentVehicle) or 0

				shouldSendNUIUpdate = false

				if lastCarEngineHealth ~= carEngineHealth then
					lastCarEngineHealth = carEngineHealth
					shouldSendNUIUpdate = true
				end
				if lastCarRPM ~= carRPM then
					lastCarRPM = carRPM
					shouldSendNUIUpdate = true
				end
				if lastCarSpeed ~= carSpeed then
					lastCarSpeed = carSpeed
					shouldSendNUIUpdate = true
				end
				if lastCarGear ~= carGear then
					lastCarGear = carGear
					shouldSendNUIUpdate = true
				end
				if lastCarDrift ~= carDrift then
					lastCarDrift = carDrift
					shouldSendNUIUpdate = true
				end
				if lastCarDriftAvailable ~= driftAvailable then
					lastCarDriftAvailable = driftAvailable
					shouldSendNUIUpdate = true
				end
				if lastCarHandbreak ~= carHandbrake then
					lastCarHandbreak = carHandbrake
					shouldSendNUIUpdate = true
				end
				if lastCarBrakePressure ~= carBrakePressure then
					lastCarBrakePressure = carBrakePressure
					shouldSendNUIUpdate = true
				end

				if lastCarFuelAmount ~= fuelamount then
					lastCarFuelAmount = fuelamount
					shouldSendNUIUpdate = true
				end

				if shouldSendNUIUpdate then
					SendNUIMessage({
						action = "speedometertick",
						show = IsPauseMenuActive(),
						rpm_value = carRPM * 10,
						gear_value = carGear,
						nitro_value = nitro,
						drift_value = carDrift,
						drift_available = driftAvailable,
						handbrake_value = carHandbrake,
						brake_value = carBrakePressure,
						speed_value = carSpeed,
						engine_health_value = carEngineHealth,
						unit_distance_type = Config.Unit,
						seatbelt = seat_belt
					})
				end
			end
		end
	end
end)

Keys = {
	["ESC"] = 322,
	["F1"] = 288,
	["F2"] = 289,
	["F3"] = 170,
	["F5"] = 166,
	["F6"] = 167,
	["F7"] = 168,
	["F8"] = 169,
	["F9"] = 56,
	["F10"] = 57,
	["~"] = 243,
	["1"] = 157,
	["2"] = 158,
	["3"] = 160,
	["4"] = 164,
	["5"] = 165,
	["6"] = 159,
	["7"] = 161,
	["8"] = 162,
	["9"] = 163,
	["-"] = 84,
	["="] = 83,
	["BACKSPACE"] = 177,
	["TAB"] = 37,
	["Q"] = 44,
	["W"] = 32,
	["E"] = 38,
	["R"] = 45,
	["T"] = 245,
	["Y"] = 246,
	["U"] = 303,
	["P"] = 199,
	["["] = 39,
	["]"] = 40,
	["ENTER"] = 18,
	["CAPS"] = 137,
	["A"] = 34,
	["S"] = 8,
	["D"] = 9,
	["F"] = 23,
	["G"] = 47,
	["H"] = 74,
	["K"] = 311,
	["L"] = 182,
	["LEFTSHIFT"] = 21,
	["Z"] = 20,
	["X"] = 73,
	["C"] = 26,
	["V"] = 0,
	["B"] = 29,
	["N"] = 249,
	["M"] = 244,
	[","] = 82,
	["."] = 81,
	["LEFTCTRL"] = 36,
	["LEFTALT"] = 19,
	["SPACE"] = 22,
	["RIGHTCTRL"] = 70,
	["HOME"] = 213,
	["PAGEUP"] = 10,
	["PAGEDOWN"] = 11,
	["DELETE"] = 178,
	["LEFT"] = 174,
	["RIGHT"] = 175,
	["TOP"] = 27,
	["DOWN"] = 173,
}

function toggle_seatbelt(enabled)
	local PlayerVehicle = GetVehiclePedIsUsing(PlayerPedId())
	local VehicleClass = GetVehicleClass(PlayerVehicle)
	if VehicleClass ~= 8 and VehicleClass ~= 13 and VehicleClass ~= 14 then
		seat_belt = enabled
		if seat_belt then
			TriggerServerEvent('InteractSound_SV:PlayOnSource', 'carbuckle', 0.25)
		else
			TriggerServerEvent('InteractSound_SV:PlayOnSource', 'carunbuckle', 0.25)
		end

		SetPedConfigFlag(PlayerPed, 32, not seat_belt)

		SendNUIMessage({
			action = "speedometertick",
			show = IsPauseMenuActive(),
			rpm_value = lastCarRPM * 10,
			gear_value = lastCarGear,
			nitro_value = nitro,
			drift_value = lastCarDrift,
			drift_available = lastCarDriftAvailable,
			handbrake_value = lastCarHandbreak,
			brake_value = lastCarBrakePressure,
			speed_value = lastCarSpeed,
			engine_health_value = lastCarEngineHealth,
			unit_distance_type = Config.Unit,
			seatbelt = seat_belt
		})
	end
end

RegisterNetEvent("h2o_hud:toggle_seatbelt")
AddEventHandler("h2o_hud:toggle_seatbelt", function(enabled)
	toggle_seatbelt(enabled)
end)

Citizen.CreateThread(function()
	while true do
		local PlayerPed = PlayerPedId()
		if IsPedInAnyVehicle(PlayerPed, false) then
			if IsControlJustReleased(0, Keys['B']) then
				local PlayerVehicle = GetVehiclePedIsUsing(PlayerPed)
				local VehicleClass = GetVehicleClass(PlayerVehicle)
				if VehicleClass ~= 8 and VehicleClass ~= 13 and VehicleClass ~= 14 then
					seat_belt = not seat_belt
					if seat_belt then
						TriggerServerEvent('InteractSound_SV:PlayOnSource', 'carbuckle', 0.25)
					else
						TriggerServerEvent('InteractSound_SV:PlayOnSource', 'carunbuckle', 0.25)
					end

					SetPedConfigFlag(PlayerPed, 32, not seat_belt)

					SendNUIMessage({
						action = "speedometertick",
						show = IsPauseMenuActive(),
						rpm_value = lastCarRPM * 10,
						gear_value = lastCarGear,
						nitro_value = nitro,
						drift_value = lastCarDrift,
						drift_available = lastCarDriftAvailable,
						handbrake_value = lastCarHandbreak,
						brake_value = lastCarBrakePressure,
						speed_value = lastCarSpeed,
						engine_health_value = lastCarEngineHealth,
						unit_distance_type = Config.Unit,
						seatbelt = seat_belt
					})
				end
			end
		else
			Citizen.Wait(100)
		end
		HideHudComponentThisFrame(3) -- CASH
		HideHudComponentThisFrame(4) -- MP CASH
		HideHudComponentThisFrame(2) -- weapon icon
		HideHudComponentThisFrame(9) -- STREET NAME
		HideHudComponentThisFrame(7) -- Area NAME
		HideHudComponentThisFrame(8) -- Vehicle Class
		HideHudComponentThisFrame(6) -- Vehicle Name
		Citizen.Wait(0)
	end
end)


function has_value(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end

Citizen.CreateThread(function()
	while true do
		local player = PlayerPedId()
		if IsPedInAnyVehicle(player, false) then
			local vehicle = GetVehiclePedIsIn(player, false)
			local vehicleClass = GetVehicleClass(vehicle)
			if vehicleClass ~= 13 and vehicleClass ~= 14 then
				local vehicleSpeedSource = GetEntitySpeed(vehicle)
				local prevSpeed = currSpeed
				currSpeed = vehicleSpeedSource
				local position = GetEntityCoords(player)
				SetPedConfigFlag(player, 32, true)

				if not seat_belt then
					local vehIsMovingFwd = GetEntitySpeedVector(vehicle, true).y > 1.0
					local vehAcc = (prevSpeed - currSpeed) / GetFrameTime()
					if (vehIsMovingFwd and (prevSpeed > (seatbeltEjectSpeed / 2.237)) and (vehAcc > (seatbeltEjectAccel * 9.81))) then
						SetEntityCoords(player, position.x, position.y, position.z - 0.47, true, true, true)
						SetEntityVelocity(player, prevVelocity.x, prevVelocity.y, prevVelocity.z)
						SetPedToRagdoll(player, 1000, 1000, 0, 0, 0, 0)
					else
						prevVelocity = GetEntityVelocity(vehicle)
					end
				else
					DisableControlAction(0, 75, true)
				end
			end
		else
			Citizen.Wait(1000)
		end

		Citizen.Wait(10)
	end
end)

local function GetPedVehicleSeat(entity)
	local Vehicle = GetVehiclePedIsIn(entity, false)

	for i = -2, GetVehicleMaxNumberOfPassengers(Vehicle) do
		if GetPedInVehicleSeat(Vehicle, i) == entity then
			return i
		end
	end

	return -2
end

AddEventHandler('onResourceStart', function()
	local PlayerPed = PlayerPedId()

	if IsPedInAnyVehicle(PlayerPed, false) then
		local currentVehicle = GetVehiclePedIsUsing(PlayerPed)
		local currentSeat = GetPedVehicleSeat(PlayerPed)
		local netID = VehToNet(currentVehicle)

		TriggerEvent('hudevents:enteredVehicle', currentVehicle, currentSeat,
			GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netID)

		cruiser = true
		ExecuteCommand('cruiser')
	end
end)


local veh_hash_whitelist = {
    GetHashKey("fnfrx7dom"),
    GetHashKey("fnfjetta"),
    GetHashKey("350zm"),
    GetHashKey("350zdk"),
    GetHashKey("2f2frx7"),
    GetHashKey("ssmodern"),
    GetHashKey("fnfrx7"),
    GetHashKey("fnfmk4"),
    GetHashKey("fnfmits"),
    GetHashKey("fnflan"),
    GetHashKey("fnf4r34"),
    GetHashKey("ff4wrx"),
    GetHashKey("2f2fs2000")
}
local handleMods = {
	{ "fInitialDragCoeff",         90.22 },
	{ "fDriveInertia",             .31 },
	{ "fSteeringLock",             22 },
	{ "fTractionCurveMax",         -1.1 },
	{ "fTractionCurveMin",         -.4 },
	{ "fTractionCurveLateral",     2.5 },
	{ "fLowSpeedTractionLossMult", -.57 }
}

local ped, vehicle


Citizen.CreateThread(function()
	while true do
		ped = PlayerPedId()
		if IsPedInAnyVehicle(ped) then
			local vehicle = GetVehiclePedIsIn(ped, false)
			if (GetPedInVehicleSeat(vehicle, -1) == ped) then
				local is_not_front_wheel_car = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveBiasFront") ~= 1
				local has_all_wheels = IsVehicleOnAllWheels(vehicle)
				local is_car_whitelisted = IsVehicleHashWhitelisted(GetEntityModel(vehicle))
				if is_not_front_wheel_car and has_all_wheels and is_car_whitelisted then
					driftAvailable = true
					if IsControlJustReleased(0, 21) then
						EnableDrift(vehicle)
					end
				else
					driftAvailable = false
				end
				if GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDragCoeff") < 90 then
					SetVehicleEnginePowerMultiplier(vehicle, 0.0)
				else
					if GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveBiasFront") == 0.0 then
						SetVehicleEnginePowerMultiplier(vehicle, 190.0)
					else
						SetVehicleEnginePowerMultiplier(vehicle, 100.0)
					end
				end
			end
		else
			Citizen.Wait(200)
		end

		Citizen.Wait(10)
	end
end)

local originalHandling = {}  -- To store the original handling values

function BackupOriginalHandling(vehicle)
    for index, value in ipairs(handleMods) do
        originalHandling[value[1]] = GetVehicleHandlingFloat(vehicle, "CHandlingData", value[1])
    end
end

function RestoreOriginalHandling(vehicle)
    for key, value in pairs(originalHandling) do
        SetVehicleHandlingFloat(vehicle, "CHandlingData", key, value)
    end
    originalHandling = {}  -- Clear the original handling values after restoration
end


function EnableDrift(vehicle)
	driftEnabled = true
	BackupOriginalHandling(vehicle)
	for index, value in ipairs(handleMods) do
		SetVehicleHandlingFloat(vehicle, "CHandlingData", value[1],
			GetVehicleHandlingFloat(vehicle, "CHandlingData", value[1]) + value[2])
	end
end

--[[
function EnableDrift(vehicle)
	driftEnabled = true
	local modifier = 1
    local driftMode = not (GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDragCoeff") > 90)

	if not driftMode then
        modifier = -1
    end

    if driftMode then
        BackupOriginalHandling(vehicle)
		for index, value in ipairs(handleMods) do
			SetVehicleHandlingFloat(vehicle, "CHandlingData", value[1],
				GetVehicleHandlingFloat(vehicle, "CHandlingData", value[1]) + value[2] * modifier)
		end
    else
        RestoreOriginalHandling(vehicle)
    end
end
--]]

function DisableDrift(vehicle)
    RestoreOriginalHandling(vehicle)
	driftEnabled = false
end

--[[
function ToggleDrift(vehicle)
	local modifier = 1
	if GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDragCoeff") > 90 then
		driftMode = false
	else
		driftMode = true
	end

	if not driftMode then
		modifier = -1
	end

	for index, value in ipairs(handleMods) do
		SetVehicleHandlingFloat(vehicle, "CHandlingData", value[1],
			GetVehicleHandlingFloat(vehicle, "CHandlingData", value[1]) + value[2] * modifier)
	end
end
--]]

function PrintDebugInfo(mode)
	ped = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(ped, false)
	print(mode)
	for index, value in ipairs(handleMods) do
		print(GetVehicleHandlingFloat(vehicle, "CHandlingData", value[1]))
	end
end

function IsVehicleHashWhitelisted(hash)
    for _, whitelistedHash in ipairs(veh_hash_whitelist) do
        if hash == whitelistedHash then
            return true
        end
    end
    return false
end