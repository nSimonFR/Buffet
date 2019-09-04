--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

ThousandSeparator = ","

KeyWords = {}
KeyWords.Use = "Use"
KeyWords.Restores = "Restores"
KeyWords.Heals = "Heals"
KeyWords.ConjuredItem = "Conjured item"
KeyWords.Health = "health"
KeyWords.Damage = "damage"
KeyWords.Mana = "mana"
KeyWords.WellFed = "well fed"
KeyWords.OverTime = "per second for"

Patterns = {}
Patterns.FlatHealth = "([%d,%.]+).-health"
Patterns.FlatDamage = "([%d,%.]+) damage"
Patterns.FlatMana = "([%d,%.]+).-mana"
Patterns.PctHealth = "([%d%.]+)%%.-health"
Patterns.PctMana = "([%d%.]+)%%.-mana"
Patterns.OverTime = "for (%d+) sec"

Classic_KeyWords = {}
Classic_KeyWords.Bandage = "first aid"

Classic_Patterns = {}
Classic_Patterns.Bandage = "heals ([%d%.]+) damage over ([%d%.]+) sec"

Classic_Patterns.Food = "restores ([%d%.]+) health over ([%d%.]+) sec"
Classic_Patterns.Drink = "restores ([%d%.]+) mana over ([%d%.]+) sec"

Classic_Patterns.HealthPotion = "([%d%.]+) to ([%d%.]+) health"
Classic_Patterns.ManaPotion = "([%d%.]+) to ([%d%.]+) mana"

--ItemType = {}
--ItemType.Consumable = "Consumable"
--
--ItemSubType = {}
--ItemSubType.Bandage = "Bandage"
--ItemSubType.Consumable = "Consumable"
--ItemSubType.FoodAndDrink = "Food & Drink"
--ItemSubType.Other = "Other"
--ItemSubType.Potion = "Potion"
