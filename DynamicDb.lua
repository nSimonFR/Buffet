--[[
	Db strcuture:
	ns.itemdb["bandage"] = { id: value, id: value, ... ]
	ns.allitems[id] = value
	ns.bests["bandage"] = {}

	categories:
	- bandage
	- healthstone
	- managem
	- hppot
	- mppot
	- water
	- food
	- percfood
	- percwater
--]]

local myname, ns = ...

ns.bests = {}
ns.categories = {}
ns.categories.bandage = "bandage"
ns.categories.hppot = "hppot"
ns.categories.mppot = "mppot"
ns.categories.healthstone = "healthstone"
ns.categories.managem = "managem"
ns.categories.water = "water"
ns.categories.food = "food"
ns.categories.percfood = "percfood"
ns.categories.percwater = "percwater"

for k,v in pairs(ns.categories) do
	ns.bests[v] = {val = -1, stack = -1, id = nil}
end

