--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]
if GetLocale() == "itIT" then
    ThousandSeparator = "%."

    KeyWords.Use = "Usa"
    KeyWords.Restores = "Rigenera"
    KeyWords.Heals = "Cura"
    KeyWords.ConjuredItem = "Oggetto evocato"
    KeyWords.Health = "salute"
    KeyWords.Damage = "cura"
    KeyWords.Mana = "mana"
    KeyWords.WellFed = "ben nutrito"
    KeyWords.OverTime = "ogni secondo per"

    Patterns.FlatHealth = "([%d%.]+).-salute"
    Patterns.FlatDamage = "di ([%d%.]+) in"
    Patterns.FlatMana = "([%d%.]+).-mana"
    Patterns.PctHealth = "([%d%.]+)%%.-salute"
    Patterns.PctMana = "([%d%.]+)%%.-mana"
    Patterns.OverTime = "per (%d+) sec"

    ItemType.Consumable = "Consumabili"

    ItemSubType.Bandage = "Benda"
    ItemSubType.Consumable = "Consumabili"
    ItemSubType.FoodAndDrink = "Cibo e bevande"
    ItemSubType.Other = "Altro"
    ItemSubType.Potion = "Pozione"
end
