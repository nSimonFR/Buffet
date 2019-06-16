--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]
if GetLocale() == "esES" then
    ThousandSeparator = "%."

    KeyWords.Use = "Uso"
    KeyWords.Restores = "Restaura"
    KeyWords.Heals = "Sana"
    KeyWords.ConjuredItem = "Objeto mágico"
    KeyWords.Health = "salud"
    KeyWords.Damage = "daño"
    KeyWords.Mana = "maná"
    KeyWords.WellFed = "bien alimentado"
    KeyWords.OverTime = "por segundo durante"

    Patterns.FlatHealth = "([%d%.]+).-salud"
    Patterns.FlatDamage = "([%d%.]+).-daño"
    Patterns.FlatMana = "([%d%.]+).-maná"
    Patterns.PctHealth = "([%d%.]+)%%.-salud"
    Patterns.PctMana = "([%d%.]+)%%.-maná"
    Patterns.OverTime = "durante (%d+) sec"

    ItemType.Consumable = "Consumible"

    ItemSubType.Bandage = "Venda"
    ItemSubType.Consumable = "Consumible"
    ItemSubType.FoodAndDrink = "Comida y bebida"
    ItemSubType.Other = "Otro"
    ItemSubType.Potion = "Poción"
end
