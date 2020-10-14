-- LOCALS
local M = {}

local engtime = 0
local engtimer = 0
local particleAmount = 0
local ignkeySmoother = newExponentialSmoothing(6)
local oilPressureSmoother = newExponentialSmoothing(80)
local voltsSmoother = newExponentialSmoothing(5)
local fuelaltSmoother = newExponentialSmoothing(120)
local tempaltSmoother = newExponentialSmoothing(120)


local function updateGFX(dt)
--IGNITION
   if powertrain.getDevice("mainEngine").ignitionCoef ~= 0 and electrics.values.rpm > 100 then electrics.values.ignkey = 2
   else electrics.values.ignkey = 0 end

  if electrics.values.rpm < 100 and powertrain.getDevice("mainEngine").ignitionCoef ~= 0 then electrics.values.ignkey = 1 end

-- OIL PRESSURE
  if electrics.values.rpm > 500 and powertrain.getDevice("mainEngine").oilVolume > 2.5 then electrics.values.oilPressure = electrics.values.rpm  *0.0001000 * powertrain.getDevice("mainEngine").oilVolume / 0.05 + 55
else electrics.values.oilPressure = electrics.values.rpm  *0.2 * powertrain.getDevice("mainEngine").oilVolume / 12.5 end

 electrics.values.oilPressure = oilPressureSmoother:get(electrics.values['oilPressure'])

-- FUEL
 if electrics.values.ignkey < 1 then electrics.values.fuelalt = 0 end
electrics.values.fuelalt = fuelaltSmoother:get(electrics.values['fuelBase'])

-- TEMPERATURE
if electrics.values.ignkey < 1 then electrics.values.tempalt = 0 end
electrics.values.tempalt = fuelaltSmoother:get(electrics.values['tempBase'])

-- VOLTS

if electrics.values.ignkey > 1.5 then electrics.values.volts = 40
else electrics.values.volts = 5 end
if electrics.values.ignkey < 0.5 then electrics.values.volts = -45 end
if powertrain.getDevice("mainEngine").starterEngagedCoef > 0 then electrics.values.volts = -10 end

electrics.values.volts = voltsSmoother:get(electrics.values['volts'])

-- WARNING LIGHTS
  --oil pressure
	if electrics.values.oilPressure < 35 and electrics.values.ignkey > 0.5  then electrics.values.oillow = 1 else electrics.values.oillow = 0 end
  -- Volts
  if electrics.values.volts < 0 and electrics.values.ignkey > 0.5  then electrics.values.battery = 1 else electrics.values.battery = 0 end
  -- CEL
  if electrics.values.ignkey == 1 then electrics.values.checkengine = 1 end

end
