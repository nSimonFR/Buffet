--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]
if GetLocale() == "deDE" then
    ThousandSeparator = "%."

    KeyWords.Use = "Benutzen"
    KeyWords.Restores = "Stellt"
    KeyWords.Heals = "Heilt"
    KeyWords.ConjuredItem = "Herbeigezauberter Gegenstand"
    KeyWords.Health = "gesundheit"
    KeyWords.Damage = "schaden"
    KeyWords.Mana = "mana"
    KeyWords.WellFed = "essen verbringt"
    KeyWords.OverTime = "sec pro sekunde"

    Patterns.FlatHealth = "([%d%.]+) gesundheit"
    Patterns.FlatDamage = "([%d%.]+) schaden"
    Patterns.FlatMana = "([%d%.]+) mana"
    Patterns.PctHealth = "([%d%.]+)%% gesundheit"
    Patterns.PctMana = "([%d%.]+)%% mana"
    Patterns.OverTime = "von (%d+) sec"

    ItemType.Consumable = "Verbrauchbares"

    ItemSubType.Bandage = "Verband"
    ItemSubType.Consumable = "Verbrauchbares"
    ItemSubType.FoodAndDrink = "Speis & Trank"
    ItemSubType.Other = "Anderes"
    ItemSubType.Potion = "Trank"
end