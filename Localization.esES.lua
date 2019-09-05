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

    -- Classic stuff
    Classic_KeyWords.Use = "Usar"
    Classic_KeyWords.Bandage = "primeros auxilios"

    Classic_Patterns.Bandage = "cura ([%d%.]+) p%. de daño durante ([%d%.]+) s"

    Classic_Patterns.Food = "restaura ([%d%.]+) p%. de salud durante ([%d%.]+) s"
    Classic_Patterns.Drink = "restaura ([%d%.]+) p%. de maná durante ([%d%.]+) s"

    Classic_Patterns.HealthPotion = "restaura ([%d%.]+) a ([%d%.]+) p. de salud"
    Classic_Patterns.ManaPotion = "restaura ([%d%.]+) a ([%d%.]+) p. de maná"

    --ItemType.Consumable = "Consumible"
    --
    --ItemSubType.Bandage = "Venda"
    --ItemSubType.Consumable = "Consumible"
    --ItemSubType.FoodAndDrink = "Comida y bebida"
    --ItemSubType.Other = "Otro"
    --ItemSubType.Potion = "Poción"
end
