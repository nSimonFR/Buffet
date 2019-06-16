
----------------------
--      Locals      --
----------------------

local myname, ns = ...

local defaults = {macroHP = "#showtooltip\n%MACRO%", macroMP = "#showtooltip\n%MACRO%"}
local dirty = false
local bests = ns.bests
local buffetTooltipFromTemplate = nil
local lastScan = 0
local tooltipCache = {}
local itemCache = {}

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

function Buffet:ADDON_LOADED(event, addon)
	if addon:lower() ~= "buffet" then return end

	BuffetDB = setmetatable(BuffetDB or {}, {__index = defaults})
	self.db = BuffetDB

	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil

	if IsLoggedIn() then self:PLAYER_LOGIN() else self:RegisterEvent("PLAYER_LOGIN") end
end

function Buffet:PLAYER_LOGIN()
	self:RegisterEvent("PLAYER_LOGOUT")

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("BAG_UPDATE_DELAYED")

	self:RegisterEvent("UNIT_MAXHEALTH")
	self:RegisterEvent("UNIT_MAXPOWER")

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

function Buffet:PLAYER_LOGOUT()
	for i,v in pairs(defaults) do
		if self.db[i] == v then
			self.db[i] = nil
		end
	end
end

function Buffet:PLAYER_REGEN_ENABLED()
	if dirty then self:ScanDynamic() end
end

function Buffet:PLAYER_ENTERING_WORLD()
	if not InCombatLockdown() then self:ScanDynamic() end
end

function Buffet:BAG_UPDATE_DELAYED()
	dirty = true
	if not InCombatLockdown() then self:ScanDynamic() end
end
Buffet.PLAYER_LEVEL_UP = Buffet.BAG_UPDATE_DELAYED
Buffet.UNIT_MAXHEALTH = Buffet.BAG_UPDATE_DELAYED
Buffet.UNIT_MAXPOWER = Buffet.BAG_UPDATE_DELAYED

function Buffet:TableCount(t)
	local c = 0
	if t then
		for v in pairs(t) do
			c = c + 1
		end
	end
	return c
end

function Buffet:ScanTooltip(itemlink, itemId)
	if tooltipCache[itemId] then
		return tooltipCache[itemId]
	end

	local texts = {}
	local tooltip = buffetTooltipFromTemplate or CreateFrame("GAMETOOLTIP", "buffetTooltipFromTemplate", nil, "GameTooltipTemplate")
	tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	tooltip:ClearLines()
	tooltip:SetHyperlink(itemlink)
	for i = 1, tooltip:NumLines() do
		local text = _G["buffetTooltipFromTemplateTextLeft"..i]:GetText() or ""
		if text ~= "" then
			texts[i] = text
		end
	end

	-- some time the tooltip is not properly generated on the first pass, all item should have at least 3 lines
	if self:TableCount(texts) >= 3 then
		tooltipCache[itemId] = texts
	end

	return texts
--[[
	-- this was suppose to works...
	local regions = tooltip:GetRegions()
	for i = 1, select("#", regions) do
		local region = select(i, regions)
		if region and region:GetObjectType() == "FontString" then
			local text = region:GetText()
			texts[i] = text -- string or nil
		end
	end
	return texts
--]]
end

function Buffet:IsValidItemType(itemType)
	return string.lower(itemType) == string.lower(ItemType.Consumable)
end

function Buffet:IsValidItemSubType(itemSubType)
	for k,v in pairs(ItemSubType) do
		if string.lower(v) == string.lower(itemSubType) then
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

function Buffet:ScanDynamic()
	-- avoid scanning bag too often
	local currentTime = GetTime()
	if lastScan + 5 > currentTime then
		dirty = true
		do return end
	end
	lastScan = currentTime

	self:Debug("Scanning bags...")

	-- clear previous bests
	for k,t in pairs(bests) do
		t.val = -1
		t.id = nil
		t.stack = -1
	end

	-- clear all pct item from cache as health/mana is dynamic
	for k,_ in pairs(itemCache) do
		if itemCache[k] and itemCache[k].isPct then
			itemCache[k] = nil
		end
	end

	mylevel = UnitLevel("player")
	myhealth = UnitHealthMax("player")
	mymana = UnitPowerMax("player")

	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			local _, itemCount, _, _, _, _, _, _, _, itemId = GetContainerItemInfo(bag,slot)
			if itemId then
				local itemName, itemLink, _, _, itemMinLevel, itemType, itemSubType = GetItemInfo(itemId)
				itemMinLevel = itemMinLevel or 0

				if itemLink and (itemMinLevel <= mylevel) and self:IsValidItemType(itemType) and self:IsValidItemSubType(itemSubType) then
					self:Debug("Debug:", itemName, itemType, itemSubType)

					local isHealth = false
					local isMana = false
					local isConjured = false
					local isWellFed = false
					local isPct = false

					local health = 0;
					local mana = 0;

					if itemCache[itemId] then
						self:Debug("Use item cache for:", itemName)
						isHealth = itemCache[itemId].isHealth
						isMana = itemCache[itemId].isMana
						isConjured = itemCache[itemId].isConjured
						isWellFed = itemCache[itemId].isWellFed
						isPct = itemCache[itemId].isPct
						health = itemCache[itemId].health
						mana = itemCache[itemId].mana
					else
						self:Debug("Live parsing for:", itemName)
						-- parse tooltip values
						local texts = self:ScanTooltip(itemLink, itemId)
						isHealth, isMana, isConjured, isWellFed, health, mana, isPct = self:ParseTexts(texts, itemSubType)
						itemCache[itemId] = {}
						itemCache[itemId].isHealth = isHealth
						itemCache[itemId].isMana = isMana
						itemCache[itemId].isConjured = isConjured
						itemCache[itemId].isWellFed = isWellFed
						itemCache[itemId].isPct = isPct
						itemCache[itemId].health = health
						itemCache[itemId].mana = mana
					end

					-- set found values to best
					if not isWellFed and ((health and (health > 0)) or (mana and (mana > 0)) ) then
						self:Debug("Found item: ", itemName, "isHealth: ", isHealth, "isMana: ", isMana, "health: ", health, "mana: ", mana, "isPct: ", isPct)

						local cat = nil
						if itemSubType == ItemSubType.FoodAndDrink then
							if isHealth then
								if isConjured then
									cat = ns.categories.percfood;
								else
									cat = ns.categories.food;
								end
								self:SetBest(cat, itemId, health, itemCount)
							end
							if isMana then
								if isConjured then
									cat = ns.categories.percwater;
								else
									cat = ns.categories.water;
								end
								self:SetBest(cat, itemId, mana, itemCount)
							end
						elseif itemSubType == ItemSubType.Potion then
							if isHealth then
								cat = ns.categories.hppot;
								self:SetBest(cat, itemId, health, itemCount)
							end
							if isMana then
								cat = ns.categories.mppot;
								self:SetBest(cat, itemId, mana, itemCount)
							end
						elseif itemSubType == ItemSubType.Bandage then
							if isHealth then
								cat = ns.categories.bandage;
								self:SetBest(cat, itemId, health, itemCount)
							end
						elseif itemSubType == ItemSubType.Other then -- health stone / mana gem
							if isConjured then
								if isHealth then
									cat = ns.categories.healthstone
									self:SetBest(cat, itemId, health, itemCount)
								end
								if isMana then
									cat = ns.categories.manastone;
									self:SetBest(cat, itemId, health, itemCount)
								end
							end
						else
							-- unknow case
							self:Print("Unknown item, please report it to the author: ", itemName)
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

	dirty = false
end

function Buffet:ParseTexts(texts, itemSubType)
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
			if itemSubType == ItemSubType.Bandage then
				isHealth = self:StringContains(text, KeyWords.Damage:lower())
			else
				isHealth = self:StringContains(text, KeyWords.Health:lower())
			end

			isMana = self:StringContains(text, KeyWords.Mana:lower())

			if isHealth then
				if itemSubType == ItemSubType.Bandage then
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
