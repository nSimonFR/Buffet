
----------------------
--      Locals      --
----------------------

local myname, ns = ...

local defaults = {macroHP = "#showtooltip\n%MACRO%", macroMP = "#showtooltip\n%MACRO%"}
local firstRun = true
local dirty = false
local bests = ns.bests
local buffetTooltipFromTemplate = nil
local lastScan = 0
local nextScan = 0
local lastScanDelay = 5
local nextScanDelay = 1
local tooltipCache = {}
local itemCache = {}
local stats = {}

local mylevel = 0
local myhealth = 0
local mymana = 0

-----------------------------
--      Event Handler      --
-----------------------------

Buffet = CreateFrame("frame")
Buffet:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
Buffet:RegisterEvent("ADDON_LOADED")
function Buffet:Print(...) ChatFrame1:AddMessage(string.join(" ", "|cFF33FF99Buffet|r:", ...)) end
function Buffet:Debug(...)
	--[[
	local arg = {...}
	local t = ""
	for i,v in ipairs(arg) do
		t = t .. " " .. tostring(v)
	end
	ChatFrame1:AddMessage("|cFF33FF99Buffet|r:" .. t)
	--]]
end

function Buffet:MyGetTime()
	return (debugprofilestop() / 1000)
end

function Buffet:SlashHandler(message, editbox)
	local _, _, cmd, args = string.find(message, "%s?(%w+)%s?(.*)")

	if cmd == "stats" then
		self:Print("Session Statistics:")
		self:Print("- Functions called:")
		for k,v in pairs(stats.timers) do
			local item = v
			local avgTime = 0
			if v.count > 0 then
				avgTime = v.totalTime / v.count
			end
			self:Print(string.format("  - %s: %d time(s), total time: %.5fs, average time: %.5fs", k, v.count, v.totalTime, avgTime))
		end
		self:Print("- Events raised:")
		for k,v in pairs(stats.events) do
			self:Print(string.format("  - %s: %d time(s)", k, v))
		end
	elseif cmd == "scan" then
		lastScan = 0
		self:Print("Scanning bags...")
		self:ScanDynamic()
		self:Print("Done!")
	else
		self:Print("Usage:")
		self:Print("/buffet scan: perform a manual scan of your bags")
		self:Print("/buffet stats: show some internal statistics")
	end
end
SLASH_BUFFET1 = "/buffet"
SlashCmdList["BUFFET"] = function(message, editbox) Buffet:SlashHandler(message, editbox) end

function Buffet:ADDON_LOADED(event, addon)
	if addon:lower() ~= "buffet" then return end

	BuffetDB = setmetatable(BuffetDB or {}, {__index = defaults})
	self.db = BuffetDB

	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil

	stats.events = {}
	stats.timers = {}

	if IsLoggedIn() then self:PLAYER_LOGIN() else self:RegisterEvent("PLAYER_LOGIN") end
end

function Buffet:PLAYER_LOGIN()
	stats.events["PLAYER_REGEN_ENABLED"] = 0
	stats.events["PLAYER_LEVEL_UP"] = 0
	stats.events["BAG_UPDATE_DELAYED"] = 0
	stats.events["UNIT_MAXHEALTH"] = 0
	stats.events["UNIT_MAXPOWER"] = 0

	stats.timers["ScanTooltip"] = { totalTime = 0, count = 0 }
	stats.timers["ScanDynamic"] = { totalTime = 0, count = 0 }
	stats.timers["ParseTexts"] = { totalTime = 0, count = 0 }
	stats.timers["UpdateCallback"] = { totalTime = 0, count = 0 }

	self:RegisterEvent("PLAYER_LOGOUT")

	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("BAG_UPDATE_DELAYED")
	self:RegisterEvent("UNIT_MAXHEALTH")
	self:RegisterEvent("UNIT_MAXPOWER")

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil

	mylevel = UnitLevel("player")
	myhealth = UnitHealthMax("player")
	mymana = UnitPowerMax("player")

	dirty = true
end

function Buffet:PLAYER_LOGOUT()
	for i,v in pairs(defaults) do
		if self.db[i] == v then
			self.db[i] = nil
		end
	end
end

function Buffet:PLAYER_REGEN_ENABLED()
	stats.events["PLAYER_REGEN_ENABLED"] = stats.events["PLAYER_REGEN_ENABLED"] + 1
	if dirty then self:ScanDynamic() end
end

function Buffet:BAG_UPDATE_DELAYED()
	stats.events["BAG_UPDATE_DELAYED"] = stats.events["BAG_UPDATE_DELAYED"] + 1
	dirty = true
	if not InCombatLockdown() then self:ScanDynamic() end
end

function Buffet:PLAYER_LEVEL_UP(event, arg1)
	stats.events["PLAYER_LEVEL_UP"] = stats.events["PLAYER_LEVEL_UP"] + 1
	dirty = true
	mylevel = arg1
	if not InCombatLockdown() then self:ScanDynamic() end
end

function Buffet:UNIT_MAXHEALTH(event, arg1)
	if arg1 == "player" then
		stats.events["UNIT_MAXHEALTH"] = stats.events["UNIT_MAXHEALTH"] + 1
		dirty = true
		myhealth = UnitHealthMax("player")
		if not InCombatLockdown() then self:ScanDynamic() end
	end
end

function Buffet:UNIT_MAXPOWER(event, arg1, arg2)
	if (arg1 == "player") and (arg2 == "MANA") then
		stats.events["UNIT_MAXPOWER"] = stats.events["UNIT_MAXPOWER"] + 1
		dirty = true
		mymana = UnitPowerMax("player")
		if not InCombatLockdown() then self:ScanDynamic() end
	end
end

function Buffet:StatsTimerUpdate(key, t)
	stats.timers[key].count = stats.timers[key].count + 1
	local t2 = self:MyGetTime()
	stats.timers[key].totalTime = stats.timers[key].totalTime + (t2 - t)
end

function Buffet:UpdateCallback(...)
	local t = self:MyGetTime()
	if nextScan > 0 then
		if nextScan <= t then
			if not InCombatLockdown() then
				self:DisableDelayedScan()
				self:ScanDynamic(true)
			end
		end
	end
	self:StatsTimerUpdate("UpdateCallback", t)
end

function Buffet:EnableDelayedScan()
	if nextScan == 0 then -- enable it only once
		nextScan = self:MyGetTime() + nextScanDelay
		self:SetScript("OnUpdate", self.UpdateCallback)
	end
end

function Buffet:DisableDelayedScan()
	self:SetScript("OnUpdate", nil)
	nextScan = 0
end

function Buffet:TableCount(t)
	local c = 0
	if t then
		for v in pairs(t) do
			c = c + 1
		end
	end
	return c
end

function Buffet:MakeTooltip()
	local tooltip = buffetTooltipFromTemplate or CreateFrame("GAMETOOLTIP", "buffetTooltipFromTemplate", nil, "GameTooltipTemplate")
	return tooltip
end

function Buffet:ScanTooltip(itemlink, itemId)
	local t = self:MyGetTime()
	local cached = false

	if tooltipCache[itemId] then
		cached = true
		self:StatsTimerUpdate("ScanTooltip", t)
		return tooltipCache[itemId], cached
	end

	local texts = {}
	local tooltip = buffetTooltipFromTemplate or self:MakeTooltip()
	tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	tooltip:ClearLines()
	tooltip:SetHyperlink(itemlink)

	local isConjuredItem = false

	-- [[
	for i = 1, tooltip:NumLines() do
		local text = _G["buffetTooltipFromTemplateTextLeft"..i]:GetText() or ""
		if text ~= "" then
			texts[i] = text
			if self:StringContains(text:lower(), KeyWords.ConjuredItem:lower()) then
				isConjuredItem = true
			end
		end
	end
	--]]

	--[[
	-- not working :(
	for i=1,select("#",tooltip:GetRegions()) do
		local region=select(i,tooltip:GetRegions())
		if region and region:GetObjectType()=="FontString" and region:GetText() then
			local text = region:GetText()
			texts[i] = text
		end
	end
	--]]

	-- some time the tooltip is not properly generated on the first pass, all items should have at least 3 lines, 4 for conjured items
	local neededLines = 3
	if isConjuredItem then
		neededLines = 4
	end

	if self:TableCount(texts) >= neededLines then
		tooltipCache[itemId] = texts
		cached = true
	else
		dirty = true
		self:EnableDelayedScan()
	end

	self:StatsTimerUpdate("ScanTooltip", t)
	return texts, cached
end

function Buffet:IsValidItemClass(itemClassId)
	return itemClassId == ItemClasses.Consumable
end

function Buffet:IsValidItemSubClass(itemSubClassId)
	for k,v in pairs(ItemSubClasses) do
		if itemSubClassId == v then
			return true
		end
	end
	return false
end

function Buffet:StringContains(s, needle)
	local f = s:find(needle, 1, true)
	if f == nil then
		return false
	end
	return true
end

function Buffet:SetBest(cat, id, value, stack)
	local best = bests[cat];
	if best and id then
		if (value > best.val) or ((value == best.val) and (best.stack > stack)) then
			best.val = value
			best.id = id
			best.stack = stack
		end
	end
end

function Buffet:ScanDynamic(force)
	force = force or false
	local currentTime = self:MyGetTime()
	-- [[ avoid scanning bag too often, ie. on multiple consecutive bag update
	if not force and (lastScan + lastScanDelay > currentTime) then
		return
	end
	lastScan = currentTime
	--]]

	self:Debug("Scanning bags...")

	-- clear previous bests
	for k,t in pairs(bests) do
		t.val = -1
		t.id = nil
		t.stack = -1
	end

	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			local _, itemCount, _, _, _, _, _, _, _, itemId = GetContainerItemInfo(bag,slot)
			if itemId then -- slot not empty
				local itemName, itemLink, _, _, itemMinLevel, _, _, _, _, _, _, itemClassId, itemSubClassId = GetItemInfo(itemId)

				-- ensure itemMinLevel is not nil
				itemMinLevel = itemMinLevel or 0

				if itemLink and (itemMinLevel <= mylevel) and self:IsValidItemClass(itemClassId) and self:IsValidItemSubClass(itemSubClassId) then
					-- self:Debug("Debug:", itemName, itemClassId, itemSubClassId)

					local isHealth = false
					local isMana = false
					local isConjured = false
					local isWellFed = false
					local isPct = false

					local health = 0;
					local mana = 0;

					if itemCache[itemId] then
						--self:Debug("Use item cache for:", itemName)
						isHealth = itemCache[itemId].isHealth
						isMana = itemCache[itemId].isMana
						isConjured = itemCache[itemId].isConjured
						isWellFed = itemCache[itemId].isWellFed
						isPct = itemCache[itemId].isPct
						health = itemCache[itemId].health
						mana = itemCache[itemId].mana
					else
						--self:Debug("Live parsing for:", itemName)
						-- parse tooltip values
						local texts, cached = self:ScanTooltip(itemLink, itemId)
						isHealth, isMana, isConjured, isWellFed, health, mana, isPct = self:ParseTexts(texts, itemSubClassId)
						-- cache item only if tooltip was cached (and not Pct item)
						if cached and not isPct then
							itemCache[itemId] = {}
							itemCache[itemId].isHealth = isHealth
							itemCache[itemId].isMana = isMana
							itemCache[itemId].isConjured = isConjured
							itemCache[itemId].isWellFed = isWellFed
							itemCache[itemId].isPct = isPct
							itemCache[itemId].health = health
							itemCache[itemId].mana = mana
						end
					end

					-- set found values to best
					if not isWellFed and ((health and (health > 0)) or (mana and (mana > 0)) ) then
						--self:Debug("Found item: ", itemName, "isHealth: ", isHealth, "isMana: ", isMana, "health: ", health, "mana: ", mana, "isPct: ", isPct)

						local cat = nil
						if itemSubClassId == ItemSubClasses.FoodAndDrink then
							if isHealth then
								if isConjured then
									cat = ns.categories.percfood
								else
									cat = ns.categories.food
								end
								self:SetBest(cat, itemId, health, itemCount)
							end
							if isMana then
								if isConjured then
									cat = ns.categories.percwater
								else
									cat = ns.categories.water
								end
								self:SetBest(cat, itemId, mana, itemCount)
							end
						elseif itemSubClassId == ItemSubClasses.Potion then
							if isHealth then
								cat = ns.categories.hppot
								self:SetBest(cat, itemId, health, itemCount)
							end
							if isMana then
								cat = ns.categories.mppot
								self:SetBest(cat, itemId, mana, itemCount)
							end
						elseif itemSubClassId == ItemSubClasses.Bandage then
							if isHealth then
								cat = ns.categories.bandage
								self:SetBest(cat, itemId, health, itemCount)
							end
						elseif itemSubClassId == ItemSubClasses.Other then -- health stone / mana gem
							if isConjured then
								if isHealth then
									cat = ns.categories.healthstone
									self:SetBest(cat, itemId, health, itemCount)
								end
								if isMana then
									cat = ns.categories.manastone
									self:SetBest(cat, itemId, health, itemCount)
								end
							end
						end
					end
				end
			end
		end
	end

	local food = bests.percfood.id or bests.food.id or bests.healthstone.id or bests.hppot.id
	local water = bests.percwater.id or bests.water.id or bests.managem.id or bests.mppot.id

	self:Edit("AutoHP", self.db.macroHP, food, bests.healthstone.id or bests.hppot.id, bests.bandage.id)
	self:Edit("AutoMP", self.db.macroMP, water,bests.managem.id or bests.mppot.id)

	-- if we didn't found any food or water, and it is the first run, queue a delayed scan
	if not food and not water and firstRun then
		firstRun = false
		self:EnableDelayedScan()
	end

	dirty = false

	self:StatsTimerUpdate("ScanDynamic", currentTime)
end

function Buffet:ParseTexts(texts, itemSubClassId)
	local t = self:MyGetTime()

	local isHealth = false
	local isMana = false
	local isConjured = false
	local isWellFed = false
	local isPct = false
	local isOverTime = false

	local health = 0
	local mana = 0
	local overTime = 0

	for i,v in ipairs(texts) do
		local text = string.lower(v);

		-- Conjured item
		if self:StringContains(text, KeyWords.ConjuredItem:lower()) then
			isConjured = true
		end

		-- well fed
		if self:StringContains(text, KeyWords.WellFed:lower()) then
			isWellFed = true
		end

		-- OverTime
		if self:StringContains(text, KeyWords.OverTime:lower()) then
			isOverTime = true
		end

		-- Usable item
		if self:StringContains(text, KeyWords.Use:lower()) then
			if itemSubClassId == ItemSubClasses.Bandage then
				isHealth = self:StringContains(text, KeyWords.Damage:lower())
			else
				isHealth = self:StringContains(text, KeyWords.Health:lower())
			end

			isMana = self:StringContains(text, KeyWords.Mana:lower())

			if isHealth then
				if itemSubClassId == ItemSubClasses.Bandage then
					if self:StringContains(text, KeyWords.Heals:lower()) then
						value = text:match(Patterns.FlatDamage);
						if value then
							value = value:gsub(ThousandSeparator,"")
							health = tonumber(value)
						end
					end
				else
					if self:StringContains(text, KeyWords.Restores:lower()) then
						local value = text:match(Patterns.PctHealth);
						if value then
							isPct = true
							value = value:gsub(ThousandSeparator,"")
							health = (tonumber(value) / 100) * myhealth;
						else
							value = text:match(Patterns.FlatHealth);
							if value then
								value = value:gsub(ThousandSeparator,"")
								health = tonumber(value)
							end
						end
						if health and (health > 0 ) and isOverTime then
							local overTime = text:match(Patterns.OverTime)
							if overTime then
								health = health * tonumber(overTime)
							end
						end
					end
				end
			end

			if isMana then
				if self:StringContains(text, KeyWords.Restores:lower()) then
					local offsetMana = 1;
					if isHealth then
						offsetMana = text:find(KeyWords.Health)
					end

					local value = text:match(Patterns.PctMana, offsetMana);
					if value then
						isPct = true
						value = value:gsub(ThousandSeparator,"")
						mana = (tonumber(value) / 100) * mymana;
					else
						value = text:match(Patterns.FlatMana, offsetMana);
						if value then
							value = value:gsub(ThousandSeparator,"")
							mana = tonumber(value)
						end
					end

					-- in some cases there is only one value for health and mana, so we need to try without the offsetMana
					if not value then
						local value = text:match(Patterns.PctMana);
						if value then
							isPct = true
							value = value:gsub(ThousandSeparator,"")
							mana = (tonumber(value) / 100) * mymana;
						else
							value = text:match(Patterns.FlatMana);
							if value then
								value = value:gsub(ThousandSeparator,"")
								mana = tonumber(value)
							end
						end
					end

					if mana and (mana > 0) and isOverTime then
						local overTime = text:match(Patterns.OverTime)
						if overTime then
							mana = mana * tonumber(overTime)
						end
					end
				end
			end
		end
	end

	self:StatsTimerUpdate("ParseTexts", t)

	return isHealth, isMana, isConjured, isWellFed, health, mana, isPct
end

function Buffet:Edit(name, substring, food, pot, mod)
	local macroid = GetMacroIndexByName(name)
	if not macroid then return end

	local body = "/use "
	if mod then body = body .. "[mod,target=player] item:"..mod.."; " end
	if pot then body = body .. "[combat] item:"..pot.."; " end
	body = body.."item:"..(food or "6948")

	EditMacro(macroid, name, "INV_Misc_QuestionMark", substring:gsub("%%MACRO%%", body), 1)
end
